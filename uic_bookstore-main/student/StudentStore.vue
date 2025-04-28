<template>
  <StudentLayout>
    <div class="store-page">
      <header class="header">
        <div class="logo">
          <h1>UIC Bookstore Online Inquiry & Inventory System</h1>
        </div>
        <div class="header-right">
          <NotificationSystem @notification-panel-toggled="handleNotificationToggle" ref="notificationSystem" />
          <div class="user-menu" ref="userMenu">
            <div class="user-info" @click="toggleUserDropdown">
              <img :src="profilePictureUrl || defaultProfilePicture" alt="Profile" class="profile-picture">
              <span class="username">{{ studentName }}</span>
              <i class="fas fa-chevron-down"></i>
            </div>
            <div class="dropdown-menu" v-if="showUserDropdown">
              <ul>
                <li><a href="#" @click.prevent="openProfileModal">My Profile</a></li>
                <li><router-link to="/student/settings">Settings</router-link></li>
                <li><a href="#" @click.prevent="logout">Logout</a></li>
              </ul>
            </div>
          </div>
        </div>
      </header>

      <div class="store-container">
        <div class="back-button-container">
          <router-link to="/student/homepage" class="back-button">
            <i class="fas fa-arrow-left"></i> Back to Homepage
          </router-link>
        </div>
        
        <div class="search-filter-bar">
          <div class="search-box">
            <input type="text" placeholder="Search" v-model="searchQuery" @input="filterProducts">
          </div>
          <div class="filter-dropdown">
            <label>Filter By Category: </label>
            <select v-model="selectedCategory" @change="filterProducts">
              <option value="all">All</option>
              <option value="uniform">Uniform</option>
              <option value="books">Books</option>
              <option value="other">Other</option>
            </select>
          </div>
        </div>

        <div v-if="isLoading" class="loading-container">
          <div class="loading-spinner"></div>
          <p>Loading products...</p>
        </div>

        <div v-else-if="filteredProducts.length === 0" class="no-products">
          <p>No products found matching your criteria.</p>
        </div>

        <div v-else class="products-grid">
          <div class="product-card" v-for="product in filteredProducts" :key="product.id">
            <div class="product-image">
              <img v-if="product.image_url" :src="getImageUrl(product.image_url)" :alt="product.name">
              <img v-else :src="`https://via.placeholder.com/200x200?text=${encodeURIComponent(product.name)}`" :alt="product.name">
            </div>
            <div class="product-info">
              <h3>{{ product.name }}</h3>
              <div v-if="product.category === 'Uniform' && product.size" class="size-indicator">
                Size: {{ product.size }}
              </div>
              <div class="product-details">
                <p>Price: ₱{{ product.price }}</p>
                <p>Stock: {{ product.stock > 0 ? product.stock : 'Out of Stock' }}</p>
              </div>
              <div v-if="product.category" class="category-badge" :class="product.category.toLowerCase()">
                {{ product.category }}
              </div>
              <p v-if="product.description" class="product-description">{{ product.description }}</p>
              <button class="notify-btn" @click="triggerNotification(product)" :class="{'notified': isItemNotified(`product-${product.id}`)}">
                {{ isItemNotified(`product-${product.id}`) ? 'Notified!' : 'Notify me!' }}
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Add Profile Modal -->
      <StudentProfile 
        :show="showProfileModal" 
        @close="closeProfileModal"
        @profile-updated="handleProfileUpdated"
      />
    </div>
  </StudentLayout>
</template>

<script>
import StudentProfile from './StudentProfile.vue';
import NotificationSystem from '../components/NotificationSystem.vue';
import StudentLayout from '../layouts/StudentLayout.vue';

export default {
  name: 'StudentStore',
  components: {
    StudentProfile,
    NotificationSystem,
    StudentLayout
  },
  data() {
    return {
      showUserDropdown: false,
      showProfileModal: false,
      studentName: 'Student',
      searchQuery: '',
      selectedCategory: 'all',
      notifiedItems: {}, // We still need this for button text display
      profilePictureUrl: null,
      defaultProfilePicture: "https://via.placeholder.com/40?text=User",
      products: [],
      filteredProducts: [],
      isLoading: true,
      error: null
    };
  },
  created() {
    // Check if user is logged in
    const isLoggedIn = localStorage.getItem('studentLoggedIn');
    const token = localStorage.getItem('studentToken');
    
    if (!isLoggedIn || !token) {
      this.$router.push('/student/login');
      return;
    }
    
    // Verify token validity by making a test request
    this.verifyAuthentication();
    
    // Get student info from localStorage
    const name = localStorage.getItem('studentName');
    const profilePic = localStorage.getItem('profilePicture');
    
    if (name) this.studentName = name;
    if (profilePic) this.profilePictureUrl = profilePic;
    
    // Load saved notified items
    const savedNotifiedItems = localStorage.getItem('notifiedItems');
    if (savedNotifiedItems) {
      this.notifiedItems = JSON.parse(savedNotifiedItems);
    }

    // Load products from API
    this.loadProducts();

    // Load subscriptions after verifying authentication
    this.loadSubscriptions();
  },
  mounted() {
    // Add global click event listener to close dropdown when clicking outside
    document.addEventListener('click', this.handleOutsideClick);
  },
  beforeUnmount() {
    // Remove global click event listener
    document.removeEventListener('click', this.handleOutsideClick);
  },
  methods: {
    async loadProducts() {
      this.isLoading = true;
      this.error = null;
      
      try {
        const response = await fetch('http://localhost:8000/products');
        const data = await response.json();
        
        if (response.ok) {
          this.products = data.products;
          this.filterProducts();
        } else {
          throw new Error(data.detail || 'Failed to load products');
        }
      } catch (error) {
        console.error('Error loading products:', error);
        this.error = 'Failed to load products. Please try again.';
      } finally {
        this.isLoading = false;
      }
    },
    
    filterProducts() {
      let filtered = [...this.products];
      
      // Apply search filter
      if (this.searchQuery) {
        const query = this.searchQuery.toLowerCase();
        filtered = filtered.filter(product => 
          product.name.toLowerCase().includes(query) ||
          (product.description && product.description.toLowerCase().includes(query))
        );
      }
      
      // Apply category filter
      if (this.selectedCategory !== 'all') {
        filtered = filtered.filter(product => 
          product.category.toLowerCase() === this.selectedCategory.toLowerCase()
        );
      }
      
      this.filteredProducts = filtered;
    },
    
    getImageUrl(imageName) {
      return `http://localhost:8000/uploads/${imageName}`;
    },
    
    handleOutsideClick(event) {
      const userMenu = this.$refs.userMenu;
      if (userMenu && !userMenu.contains(event.target)) {
        this.showUserDropdown = false;
      }
    },
    
    toggleUserDropdown() {
      this.showUserDropdown = !this.showUserDropdown;
    },
    
    logout() {
      // Clear localStorage
      localStorage.removeItem('studentLoggedIn');
      localStorage.removeItem('studentToken');
      localStorage.removeItem('studentName');
      localStorage.removeItem('profilePicture');
      
      // Redirect to login page
      this.$router.push('/student/login');
    },
    
    async verifyAuthentication() {
      const studentId = localStorage.getItem('studentId');
      if (!studentId) {
        this.$router.push('/student/login');
        return false;
      }
      
      try {
        const response = await fetch(`http://localhost:8000/students/me?student_id=${encodeURIComponent(studentId)}`);
        
        if (response.ok) {
          const userData = await response.json();
          // Save database ID for future use
          localStorage.setItem('studentDatabaseId', userData.id);
          return true;
        } else {
          // Cannot get student data, redirect to login
          localStorage.removeItem('studentLoggedIn');
          localStorage.removeItem('studentToken');
          this.$router.push('/student/login');
          return false;
        }
      } catch (error) {
        console.error('Authentication verification failed:', error);
        return false;
      }
    },
    
    async triggerNotification(product) {
      // Verify authentication and get student ID
      if (!(await this.verifyAuthentication())) {
        return;
      }
      
      const studentId = localStorage.getItem('studentDatabaseId');
      if (!studentId) {
        this.$refs.notificationSystem.addNotification({
          message: 'Unable to identify your account. Please log in again.',
          type: 'error'
        });
        return;
      }
      
      const productId = product.id;
      const itemId = `product-${productId}`;
      
      try {
        if (this.isItemNotified(itemId)) {
          // Unsubscribe from product
          const response = await fetch(`http://localhost:8000/students/unsubscribe/${productId}?student_id=${studentId}`, {
            method: 'DELETE'
          });
          
          // Handle 404 Subscription not found error differently
          if (response.status === 404) {
            // The subscription doesn't exist on the server, but we have it tracked locally
            // Just update the local state to reflect this
            console.log("Subscription not found on server but marked as notified locally. Fixing local state.");
            this.$refs.notificationSystem.addNotification({
              message: `Notification settings updated for ${product.name}.`,
              type: 'info'
            });
          } else if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.detail || 'Failed to unsubscribe');
          }
          
          // Update local state
          this.notifiedItems = {
            ...this.notifiedItems,
            [itemId]: false
          };
          localStorage.setItem('notifiedItems', JSON.stringify(this.notifiedItems));
          
          // Only show confirmation if it wasn't a 404
          if (response.status !== 404) {
            // Show confirmation
            this.$refs.notificationSystem.addNotification({
              message: `Unsubscribed from ${product.name}. You will no longer receive notifications for this product.`,
              type: 'info'
            });
          }
        } else {
          // Subscribe to product
          const response = await fetch(`http://localhost:8000/students/subscribe/${productId}?student_id=${studentId}`, {
            method: 'POST'
          });
          
          if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.detail || 'Failed to subscribe');
          }
          
          // Update local state
          this.notifiedItems = {
            ...this.notifiedItems,
            [itemId]: true
          };
          localStorage.setItem('notifiedItems', JSON.stringify(this.notifiedItems));
          
          // Show confirmation
          this.$refs.notificationSystem.addNotification({
            message: `Subscribed to ${product.name}. You will be notified when there are updates to this product.`,
            type: 'product_update'
          });
        }
      } catch (error) {
        console.error('Error updating subscription:', error);
        
        // Show error notification
        this.$refs.notificationSystem.addNotification({
          message: error.message || 'Could not update subscription. Please try again.',
          type: 'error'
        });
      }
    },
    
    isItemNotified(itemId) {
      return this.notifiedItems[itemId] === true;
    },
    
    handleNotificationToggle(isOpen) {
      // Close user dropdown when notification panel opens
      if (isOpen) {
        this.showUserDropdown = false;
      }
    },
    
    openProfileModal() {
      this.showProfileModal = true;
      this.showUserDropdown = false;
    },
    
    closeProfileModal() {
      this.showProfileModal = false;
    },
    
    handleProfileUpdated(updatedProfile) {
      // Update student name if changed
      if (updatedProfile.name) {
        this.studentName = updatedProfile.name;
        localStorage.setItem('studentName', updatedProfile.name);
      }
      
      // Update profile picture if changed
      if (updatedProfile.profilePicture) {
        this.profilePictureUrl = updatedProfile.profilePicture;
        localStorage.setItem('profilePicture', updatedProfile.profilePicture);
      }
    },

    // Load subscriptions method
    async loadSubscriptions() {
      const studentId = localStorage.getItem('studentDatabaseId');
      if (!studentId) {
        console.log("Cannot load subscriptions: No student ID available");
        return;
      }
      
      try {
        const response = await fetch(`http://localhost:8000/students/subscriptions?student_id=${studentId}`);
        
        if (response.ok) {
          const productIds = await response.json();
          
          // Create a new notifiedItems object with existing values
          const updatedNotifiedItems = { ...this.notifiedItems };
          
          // Remove all previous subscription notifications first
          // (since they'll be re-added below if still active)
          Object.keys(updatedNotifiedItems).forEach(key => {
            if (key.startsWith('product-')) {
              updatedNotifiedItems[key] = false;
            }
          });
          
          // Update notifiedItems based on current subscriptions from server
          productIds.forEach(productId => {
            updatedNotifiedItems[`product-${productId}`] = true;
          });
          
          // Replace the entire object
          this.notifiedItems = updatedNotifiedItems;
          
          // Save to localStorage
          localStorage.setItem('notifiedItems', JSON.stringify(this.notifiedItems));
          
          console.log(`Loaded ${productIds.length} product subscriptions from server.`);
        } else {
          // Don't throw on error, just log it - we can still show products
          console.error('Error loading subscriptions:', await response.text());
        }
      } catch (error) {
        console.error('Error loading subscriptions:', error);
      }
    }
  }
};
</script>

<style scoped>
.store-page {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: white;
  font-family: Arial, sans-serif;
}

.header {
  background-color: #FFF0F5; /* Lavender blush */
  color: black;
  padding: 0.75rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #FFB6C1; /* Light pink */
}

.logo h1 {
  margin: 0;
  font-size: 1.2rem;
  font-weight: 600;
  color: #FF1493; /* Deep pink */
}

.header-right {
  display: flex;
  align-items: center;
}

.user-menu {
  position: relative;
}

.user-info {
  display: flex;
  align-items: center;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 4px;
  transition: background-color 0.3s;
}

.user-info:hover {
  background-color: #FFE4E1; /* Misty rose */
}

.profile-picture {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid #FFB6C1; /* Light pink */
}

.username {
  margin: 0 0.5rem;
  font-weight: 500;
  color: #333;
}

.dropdown-menu {
  position: absolute;
  top: 100%;
  right: 0;
  background-color: white;
  border-radius: 4px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  width: 200px;
  z-index: 100;
  margin-top: 0.5rem;
}

.dropdown-menu ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.dropdown-menu li a {
  display: block;
  padding: 0.75rem 1rem;
  color: #FF1493; /* Deep pink */
  text-decoration: none;
  transition: background-color 0.3s;
}

.dropdown-menu li a:hover {
  background-color: #FFE4E1; /* Misty rose */
}

.store-container {
  padding: 1.5rem;
}

.search-filter-bar {
  display: flex;
  justify-content: space-between;
  margin-bottom: 2rem;
  align-items: center;
}

.search-box input {
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  width: 300px;
}

.filter-dropdown select {
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  margin-left: 0.5rem;
}

.products-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 1.5rem;
}

.product-card {
  background-color: white;
  border-radius: 8px;
  padding: 1rem;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s, box-shadow 0.2s;
  display: flex;
  flex-direction: column;
  height: 100%;
}

.product-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 6px 12px rgba(0, 0, 0, 0.1);
}

.product-image {
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #f9f9f9;
  height: 180px;
}

.product-image img {
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
}

.product-info {
  padding: 1rem;
  display: flex;
  flex-direction: column;
  flex-grow: 1;
}

.product-info h3 {
  margin: 0 0 0.5rem 0;
  font-size: 1rem;
  text-align: center;
}

.product-details {
  display: flex;
  flex-direction: column;
  margin-bottom: 0.5rem;
  font-size: 0.85rem;
}

.product-details p {
  margin: 0 0 0.25rem 0;
  color: #666;
}

.size-indicator {
  display: inline-block;
  background-color: #e3f2fd;
  color: #1565c0;
  padding: 0.25rem 0.5rem;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 500;
  margin-bottom: 0.5rem;
}

.product-description {
  font-size: 0.9rem;
  color: #666;
  margin-bottom: 1rem;
  flex-grow: 1;
}

.notify-btn {
  width: 100%;
  padding: 0.5rem;
  background-color: #FF69B4; /* Hot pink */
  border: none;
  border-radius: 4px;
  font-size: 0.85rem;
  cursor: pointer;
  transition: background-color 0.3s;
  color: white;
  margin-top: auto;
}

.notify-btn:hover {
  background-color: #FF1493; /* Deep pink */
}

.notify-btn.notified {
  background-color: #DB7093; /* Pale violet red */
}

.notify-btn.notified:hover {
  background-color: #C71585; /* Medium violet red */
}

.back-button-container {
  margin-bottom: 1.5rem;
}

.back-button {
  display: inline-flex;
  align-items: center;
  padding: 0.5rem 1rem;
  background-color: #FFE4E1; /* Misty rose */
  border-radius: 4px;
  color: #FF1493; /* Deep pink */
  text-decoration: none;
  font-size: 0.9rem;
  transition: background-color 0.3s;
}

.back-button:hover {
  background-color: #FFB6C1; /* Light pink */
}

.back-button i {
  margin-right: 0.5rem;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 300px;
}

.loading-spinner {
  border: 4px solid #f3f3f3;
  border-top: 4px solid #FF1493; /* Deep pink */
  border-radius: 50%;
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
  margin-bottom: 1rem;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.no-products {
  text-align: center;
  padding: 3rem;
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.category-badge {
  display: inline-block;
  padding: 0.2rem 0.6rem;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 500;
  margin-bottom: 0.5rem;
  align-self: flex-start;
}

.category-badge.uniform {
  background-color: #e3f2fd;
  color: #1565c0;
}

.category-badge.books {
  background-color: #f3e5f5;
  color: #6a1b9a;
}

.category-badge.other {
  background-color: #f5f5f5;
  color: #616161;
}

.product-description {
  font-size: 0.9rem;
  color: #666;
  margin-bottom: 1rem;
}
</style> 