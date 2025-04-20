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
            @click="markAsRead(notification.id)"
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
  name: 'NotificationSystem',
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
      pollingInterval: null
    };
  },
  mounted() {
    // Load notifications when component is mounted
    this.loadNotifications();
    
    // Start polling for new notifications every 30 seconds
    this.pollingInterval = setInterval(() => {
      this.loadNotifications();
    }, 30000);
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
    toggleNotificationPanel() {
      this.showNotifications = !this.showNotifications;
      
      if (this.showNotifications && this.notifications.length === 0) {
        this.loadNotifications();
      }
      
      // Emit event for parent components to react
      this.$emit('notification-panel-toggled', this.showNotifications);
    },
    
    async loadNotifications(page = 0) {
      const studentId = localStorage.getItem('studentDatabaseId');
      
      if (!studentId) {
        console.error('No student ID available');
        return; // No student ID, can't load notifications
      }
      
      this.isLoading = true;
      
      try {
        const response = await fetch(`http://localhost:8000/students/notifications?skip=${page * this.limit}&limit=${this.limit}&student_id=${studentId}`);
        
        if (response.ok) {
          const data = await response.json();
          
          if (page === 0) {
            // First load, replace all notifications
            this.notifications = data.notifications;
          } else {
            // Append to existing
            this.notifications = [...this.notifications, ...data.notifications];
          }
          
          this.totalNotifications = data.total;
          
          // Count unread
          this.updateUnreadCount();
        } else {
          console.error('Error loading notifications:', await response.text());
        }
      } catch (error) {
        console.error('Error loading notifications:', error);
      } finally {
        this.isLoading = false;
      }
    },
    
    async loadMoreNotifications() {
      if (this.isLoadingMore) return;
      
      this.page++;
      this.isLoadingMore = true;
      
      await this.loadNotifications(this.page);
      
      this.isLoadingMore = false;
    },
    
    async markAsRead(notificationId) {
      const studentId = localStorage.getItem('studentDatabaseId');
      
      if (!studentId) {
        console.error('No student ID available');
        return;
      }
      
      try {
        const response = await fetch(`http://localhost:8000/students/notifications/${notificationId}/read?student_id=${studentId}`, {
          method: 'PUT'
        });
        
        if (response.ok) {
          // Update local state
          const notification = this.notifications.find(n => n.id === notificationId);
          if (notification) {
            notification.is_read = true;
            
            // Update unread count
            this.updateUnreadCount();
          }
        } else {
          console.error('Error marking notification as read:', await response.text());
        }
      } catch (error) {
        console.error('Error marking notification as read:', error);
      }
    },
    
    async markAllAsRead() {
      const studentId = localStorage.getItem('studentDatabaseId');
      
      if (!studentId) {
        console.error('No student ID available');
        return;
      }
      
      try {
        const response = await fetch(`http://localhost:8000/students/notifications/read-all?student_id=${studentId}`, {
          method: 'PUT'
        });
        
        if (response.ok) {
          // Update local state
          this.notifications.forEach(notification => {
            notification.is_read = true;
          });
          
          // Update unread count
          this.updateUnreadCount();
        } else {
          console.error('Error marking all notifications as read:', await response.text());
        }
      } catch (error) {
        console.error('Error marking all notifications as read:', error);
      }
    },
    
    updateUnreadCount() {
      this.unreadCount = this.notifications.filter(n => !n.is_read).length;
    },
    
    async addNotification(notification) {
      const studentId = localStorage.getItem('studentDatabaseId');
      if (!studentId) {
        console.error('No student ID available');
        return;
      }

      try {
        // First save to database
        const response = await fetch('http://localhost:8000/students/notifications/add', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            student_id: parseInt(studentId),
            product_id: notification.product_id || 1, // Default to 1 for system notifications
            message: notification.message || notification.title,
            type: notification.type || 'info'
          })
        });

        if (response.ok) {
          const savedNotification = await response.json();
          
          // Add to front of list
          this.notifications.unshift(savedNotification);
          
          // Update unread count
          this.updateUnreadCount();
        } else {
          console.error('Error saving notification:', await response.text());
        }
      } catch (error) {
        console.error('Error saving notification:', error);
      }
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
        case 'product_update':
          return 'fas fa-shopping-bag';
        case 'stock_update':
          return 'fas fa-boxes';
        case 'price_update':
          return 'fas fa-tag';
        case 'error':
          return 'fas fa-exclamation-circle';
        case 'info':
          return 'fas fa-info-circle';
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
  background-color: #FFE4E1; /* Misty rose */
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  margin-right: 1rem;
}

.notification-icon i {
  font-size: 1.2rem;
  color: #FF1493; /* Deep pink */
}

.notification-badge {
  position: absolute;
  top: 0;
  right: 0;
  background-color: #FF1493; /* Deep pink */
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
  color: #FF1493; /* Deep pink */
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
  background-color: #FFF0F5; /* Lavender blush */
}

.notification-icon-container {
  margin-right: 0.75rem;
  width: 30px;
  height: 30px;
  background-color: #FFE4E1; /* Misty rose */
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.notification-icon-container i {
  font-size: 0.9rem;
  color: #FF1493; /* Deep pink */
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
  border: 1px solid #FFB6C1; /* Light pink */
  color: #FF1493; /* Deep pink */
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
  border: 3px solid #FFE4E1; /* Misty rose */
  border-top: 3px solid #FF1493; /* Deep pink */
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