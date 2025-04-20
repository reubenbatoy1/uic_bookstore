<template>
  <div class="notification-system">
    <div class="notification-icon" @click="toggleNotificationPanel">
      <i class="fas fa-bell"></i>
      <span v-if="unreadCount > 0" class="notification-badge">{{ unreadCount }}</span>
    </div>
    
    <div class="notification-panel" v-if="showNotifications">
      <div class="panel-header">
        <h3>Notifications</h3>
        <div class="header-actions">
          <button v-if="notifications.length > 0" class="mark-all-read" @click="markAllAsRead">
            Mark all as read
          </button>
          <button class="close-btn" @click="toggleNotificationPanel">&times;</button>
        </div>
      </div>
      
      <div class="notification-list" ref="notificationList">
        <div v-if="isLoading" class="loading-container">
          <div class="loading-spinner"></div>
          <p>Loading notifications...</p>
        </div>
        
        <div v-else-if="notifications.length === 0" class="empty-state">
          <i class="fas fa-bell-slash"></i>
          <p>No notifications yet</p>
        </div>
        
        <div v-else>
          <div 
            v-for="notification in notifications" 
            :key="notification.id"
            class="notification-item"
            :class="{ 'unread': !notification.is_read }"
            @click="handleNotificationClick(notification)"
          >
            <div class="notification-icon-container">
              <i :class="getNotificationIcon(notification.type)"></i>
            </div>
            <div class="notification-content">
              <div class="notification-message">{{ notification.message }}</div>
              <div class="notification-time">{{ formatTime(notification.created_at) }}</div>
            </div>
          </div>
          
          <div v-if="hasMoreNotifications" class="load-more">
            <button @click="loadMoreNotifications" :disabled="isLoadingMore">
              {{ isLoadingMore ? 'Loading...' : 'Load more' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AdminNotificationSystem',
  data() {
    return {
      showNotifications: false,
      notifications: [],
      isLoading: false,
      isLoadingMore: false,
      page: 0,
      limit: 10,
      totalNotifications: 0,
      unreadCount: 0,
      pollingInterval: null,
      lastFeedbackCheck: null,
      readNotifications: {},
      lastStockCheck: {}
    };
  },
  mounted() {
    // Load read status from localStorage
    this.loadReadStatus();
    
    // Load notifications when component is mounted
    this.loadNotifications();
    
    // Start polling for new notifications every 10 seconds (reduced from 30)
    this.pollingInterval = setInterval(() => {
      this.checkForNewNotifications();
    }, 10000);
    
    // Initialize last feedback check timestamp
    this.lastFeedbackCheck = localStorage.getItem('lastFeedbackCheck') 
      ? new Date(localStorage.getItem('lastFeedbackCheck')) 
      : new Date();
    
    // Save initial timestamp if not set
    if (!localStorage.getItem('lastFeedbackCheck')) {
      localStorage.setItem('lastFeedbackCheck', this.lastFeedbackCheck.toISOString());
    }
  },
  beforeUnmount() {
    // Clear polling interval when component is destroyed
    if (this.pollingInterval) {
      clearInterval(this.pollingInterval);
    }
  },
  computed: {
    hasMoreNotifications() {
      return this.notifications.length < this.totalNotifications;
    }
  },
  methods: {
    loadReadStatus() {
      try {
        const storedReadStatus = localStorage.getItem('readNotifications');
        if (storedReadStatus) {
          this.readNotifications = JSON.parse(storedReadStatus);
        }
      } catch (error) {
        console.error('Error loading read status from localStorage:', error);
        this.readNotifications = {};
      }
    },
    
    saveReadStatus() {
      try {
        localStorage.setItem('readNotifications', JSON.stringify(this.readNotifications));
      } catch (error) {
        console.error('Error saving read status to localStorage:', error);
      }
    },
    
    toggleNotificationPanel() {
      this.showNotifications = !this.showNotifications;
      
      if (this.showNotifications && this.notifications.length === 0) {
        this.loadNotifications();
      }
      
      // Emit event for parent components to react
      this.$emit('notification-panel-toggled', this.showNotifications);
    },
    
    async loadNotifications(page = 0) {
      this.isLoading = true;
      
      try {
        // Clear existing notifications to prevent duplicates
        this.notifications = [];
        
        // Combine all notification sources
        await Promise.all([
          this.loadFeedbackNotifications(),
          this.loadStockNotifications()
        ]);
        
        // Sort notifications by date (newest first)
        this.notifications.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
        
        // Apply read status from storage
        this.applyReadStatus();
        
        // Update unread count
        this.updateUnreadCount();
      } catch (error) {
        console.error('Error loading notifications:', error);
      } finally {
        this.isLoading = false;
      }
    },
    
    applyReadStatus() {
      this.notifications.forEach(notification => {
        if (this.readNotifications[notification.id]) {
          notification.is_read = true;
        }
      });
    },
    
    async loadFeedbackNotifications() {
      try {
        const response = await fetch('http://localhost:8000/admin/feedback');
        
        if (response.ok) {
          const feedbackItems = await response.json();
          const currentTime = new Date();
          
          // Get the timestamp of the last feedback check
          const lastCheck = this.lastFeedbackCheck;
          
          feedbackItems.forEach(feedback => {
            const feedbackDate = new Date(feedback.created_at);
            const isNew = feedback.status === 'new';
            const isRecent = feedbackDate > lastCheck;
            
            // Add all new feedback and those that were created after our last check
            if (isNew || isRecent) {
              // Check if we already have this notification
              const existingIndex = this.notifications.findIndex(
                n => n.type === 'feedback' && n.sourceId === feedback.id
              );
              
              if (existingIndex === -1) {
                // Add as new notification if not already present
                this.notifications.push({
                  id: `feedback_${feedback.id}`,
                  sourceId: feedback.id,
                  type: 'feedback',
                  message: `New feedback from ${feedback.student_name}: ${feedback.type}`,
                  created_at: feedback.created_at,
                  is_read: false,
                  meta: {
                    feedbackId: feedback.id,
                    feedbackType: feedback.type
                  }
                });
              }
            }
          });
          
          // Update the last check timestamp
          this.lastFeedbackCheck = currentTime;
          localStorage.setItem('lastFeedbackCheck', currentTime.toISOString());
        }
      } catch (error) {
        console.error('Error loading feedback notifications:', error);
      }
    },
    
    async loadStockNotifications() {
      try {
        const response = await fetch('http://localhost:8000/products');
        
        if (response.ok) {
          const data = await response.json();
          const products = data.products;
          
          // Initialize stock check status if not present
          if (!this.lastStockCheck || Object.keys(this.lastStockCheck).length === 0) {
            const storedStockCheck = localStorage.getItem('lastStockCheck');
            this.lastStockCheck = storedStockCheck ? JSON.parse(storedStockCheck) : {};
          }
          
          // Track current product statuses for comparison
          const currentProductStatus = {};
          
          // Check for low stock and out of stock items
          products.forEach(product => {
            // Skip if product has no ID
            if (!product.id) return;
            
            // Keep track of current product state
            currentProductStatus[product.id] = {
              stock: product.stock,
              min_stock: product.min_stock
            };
            
            const lastStatus = this.lastStockCheck[product.id] || { notified: false };
            
            // Out of stock
            if (product.stock <= 0) {
              // Only add notification if we haven't notified for this state or stock changed
              const stockChanged = lastStatus.stock !== product.stock;
              const shouldNotify = !lastStatus.notified || stockChanged;
              
              if (shouldNotify) {
                const existingIndex = this.notifications.findIndex(
                  n => n.type === 'stock_out' && n.sourceId === product.id
                );
                
                if (existingIndex === -1) {
                  this.notifications.push({
                    id: `stock_out_${product.id}`,
                    sourceId: product.id,
                    type: 'stock_out',
                    message: `${product.name} is out of stock!`,
                    created_at: new Date().toISOString(),
                    is_read: false,
                    meta: {
                      productId: product.id,
                      productName: product.name
                    }
                  });
                }
              }
            } 
            // Low stock
            else if (product.min_stock && product.stock <= product.min_stock) {
              // Only add notification if stock has changed or we haven't notified
              const stockChanged = lastStatus.stock !== product.stock;
              const becameLow = lastStatus.stock > product.min_stock && product.stock <= product.min_stock;
              const shouldNotify = !lastStatus.notified || stockChanged || becameLow;
              
              if (shouldNotify) {
                const existingIndex = this.notifications.findIndex(
                  n => n.type === 'stock_low' && n.sourceId === product.id
                );
                
                if (existingIndex === -1) {
                  this.notifications.push({
                    id: `stock_low_${product.id}`,
                    sourceId: product.id,
                    type: 'stock_low',
                    message: `${product.name} is running low (${product.stock} remaining)`,
                    created_at: new Date().toISOString(),
                    is_read: false,
                    meta: {
                      productId: product.id,
                      productName: product.name,
                      currentStock: product.stock,
                      minStock: product.min_stock
                    }
                  });
                }
              }
            }
            
            // Update notification status for this product
            currentProductStatus[product.id].notified = true;
          });
          
          // Save current product status for next comparison
          this.lastStockCheck = currentProductStatus;
          localStorage.setItem('lastStockCheck', JSON.stringify(currentProductStatus));
        }
      } catch (error) {
        console.error('Error loading stock notifications:', error);
      }
    },
    
    async checkForNewNotifications() {
      // This is similar to loadNotifications but doesn't show loading state
      try {
        const prevUnreadCount = this.unreadCount;
        
        await Promise.all([
          this.loadFeedbackNotifications(),
          this.loadStockNotifications()
        ]);
        
        // Sort notifications by date (newest first)
        this.notifications.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
        
        // Apply read status from storage
        this.applyReadStatus();
        
        // Update unread count
        this.updateUnreadCount();
        
        // Play notification sound if we have new notifications
        if (this.unreadCount > prevUnreadCount) {
          this.playNotificationSound();
        }
      } catch (error) {
        console.error('Error checking for new notifications:', error);
      }
    },
    
    async loadMoreNotifications() {
      // For now, we're not paginating admin notifications
      // This is a placeholder for future implementation
    },
    
    playNotificationSound() {
      // Create and play notification sound
      const audio = new Audio('/sounds/notification.mp3');
      audio.play().catch(e => console.log('Could not play notification sound', e));
    },
    
    handleNotificationClick(notification) {
      // Mark as read
      this.markAsRead(notification.id);
      
      // Handle specific notification types
      switch (notification.type) {
        case 'feedback':
          // Navigate to feedback page with highlight parameter
          this.$router.push({
            path: '/admin/dashboard',
            query: { highlight: notification.meta.feedbackId }
          });
          this.$emit('change-section', 'feedback');
          break;
        
        case 'stock_low':
        case 'stock_out':
          // Navigate to stock management
          this.$router.push('/admin/dashboard');
          this.$emit('change-section', 'stock');
          break;
          
        default:
          // Just mark as read for other notification types
          break;
      }
      
      // Close notification panel
      this.showNotifications = false;
    },
    
    markAsRead(notificationId) {
      // Find notification and mark as read
      const notification = this.notifications.find(n => n.id === notificationId);
      if (notification) {
        notification.is_read = true;
        
        // Store read status in localStorage
        this.readNotifications[notificationId] = true;
        this.saveReadStatus();
        
        // Update unread count
        this.updateUnreadCount();
      }
    },
    
    markAllAsRead() {
      // Mark all notifications as read
      this.notifications.forEach(notification => {
        notification.is_read = true;
        this.readNotifications[notification.id] = true;
      });
      
      // Save to localStorage
      this.saveReadStatus();
      
      // Update unread count
      this.updateUnreadCount();
    },
    
    updateUnreadCount() {
      this.unreadCount = this.notifications.filter(n => !n.is_read).length;
    },
    
    formatTime(timestamp) {
      if (!timestamp) return '';
      
      const date = new Date(timestamp);
      
      // If today, show time
      const today = new Date();
      if (date.toDateString() === today.toDateString()) {
        return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
      }
      
      // If this year, show month and day
      if (date.getFullYear() === today.getFullYear()) {
        return date.toLocaleDateString([], { month: 'short', day: 'numeric' });
      }
      
      // Otherwise full date
      return date.toLocaleDateString([], { year: 'numeric', month: 'short', day: 'numeric' });
    },
    
    getNotificationIcon(type) {
      switch (type) {
        case 'feedback':
          return 'fas fa-comment-alt';
        case 'stock_low':
          return 'fas fa-exclamation-triangle';
        case 'stock_out':
          return 'fas fa-times-circle';
        default:
          return 'fas fa-bell';
      }
    }
  }
};
</script>

<style scoped>
.notification-system {
  position: relative;
}

.notification-icon {
  position: relative;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background-color: #f0f0f0;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  margin-right: 1rem;
}

.notification-icon i {
  font-size: 1.2rem;
  color: #666;
  transition: color 0.3s;
}

.notification-icon:hover i {
  color: #ff4b7d;
}

.notification-badge {
  position: absolute;
  top: 0;
  right: 0;
  background-color: #ff4b7d;
  color: white;
  font-size: 0.7rem;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.notification-panel {
  position: absolute;
  top: calc(100% + 0.5rem);
  right: 0;
  width: 350px;
  max-height: 500px;
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 3px 12px rgba(0, 0, 0, 0.15);
  z-index: 200;
  display: flex;
  flex-direction: column;
}

.panel-header {
  padding: 1rem;
  border-bottom: 1px solid #eee;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.panel-header h3 {
  margin: 0;
  font-size: 1.1rem;
  color: #333;
}

.header-actions {
  display: flex;
  align-items: center;
}

.mark-all-read {
  background: none;
  border: none;
  color: #ff4b7d;
  font-size: 0.8rem;
  cursor: pointer;
  margin-right: 1rem;
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.5rem;
  line-height: 1;
  color: #999;
  cursor: pointer;
}

.notification-list {
  flex-grow: 1;
  overflow-y: auto;
  max-height: 450px;
}

.notification-item {
  padding: 1rem;
  border-bottom: 1px solid #f0f0f0;
  cursor: pointer;
  display: flex;
  align-items: flex-start;
  transition: background-color 0.2s;
}

.notification-item:hover {
  background-color: #f9f9f9;
}

.notification-item.unread {
  background-color: #fff5f7;
}

.notification-icon-container {
  margin-right: 0.75rem;
  width: 30px;
  height: 30px;
  background-color: #f0f0f0;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.notification-item.unread .notification-icon-container {
  background-color: #ffecf0;
}

.notification-icon-container i {
  font-size: 0.9rem;
  color: #666;
}

.notification-item.unread .notification-icon-container i {
  color: #ff4b7d;
}

.notification-content {
  flex-grow: 1;
}

.notification-message {
  font-size: 0.9rem;
  color: #333;
  margin-bottom: 0.25rem;
  line-height: 1.4;
}

.notification-time {
  font-size: 0.75rem;
  color: #999;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem 1rem;
  color: #999;
}

.empty-state i {
  font-size: 2rem;
  margin-bottom: 1rem;
}

.empty-state p {
  margin: 0;
}

.load-more {
  padding: 1rem;
  text-align: center;
}

.load-more button {
  background-color: transparent;
  border: 1px solid #eee;
  color: #666;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9rem;
}

.load-more button:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 2rem;
}

.loading-spinner {
  border: 3px solid #f0f0f0;
  border-top: 3px solid #ff4b7d;
  border-radius: 50%;
  width: 24px;
  height: 24px;
  animation: spin 1s linear infinite;
  margin-bottom: 0.5rem;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style> 