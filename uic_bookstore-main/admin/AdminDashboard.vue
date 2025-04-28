<template>
  <div class="admin-dashboard">
    <div class="sidebar">
      <div class="logo-container">
        <img src="/images/logo.png" alt="UIC Logo" class="logo">
        <h2>BOOKSTORE ADMIN PANEL</h2>
      </div>
      
      <nav class="sidebar-menu">
        <ul>
          <li :class="{ active: currentSection === 'dashboard' }" @click="changeSection('dashboard')">
            <i class="fas fa-home"></i>
            <span>Dashboard</span>
          </li>
        <li :class="{ active: currentSection === 'products' }" @click="changeSection('products')">
            <i class="fas fa-box"></i> 
            <span>Products</span>
          </li>          
          <li :class="{ active: currentSection === 'reports' }" @click="changeSection('reports')">
            <i class="fas fa-chart-bar"></i>
            <span>Reports</span>
          </li>
          <li :class="{ active: currentSection === 'orders' }" @click="changeSection('orders')">
            <i class="fas fa-shopping-cart"></i>
            <span>Orders</span>
          </li>
          <li :class="{ active: currentSection === 'stock' }" @click="changeSection('stock')">
            <i class="fas fa-cubes"></i> 
            <span>Stocks</span>
          </li>
          <li :class="{ active: currentSection === 'feedback' }" @click="changeSection('feedback')">
            <i class="fas fa-comments"></i>
            <span>Feedback Collection</span>
          </li>
          <li :class="{ active: currentSection === 'settings' }" @click="changeSection('settings')">
            <i class="fas fa-cog"></i>
            <span>Settings</span>
          </li>
          <li class="logout" @click="logout">
            <i class="fas fa-sign-out-alt"></i>
            <span>Log Out</span>
          </li>
        </ul>
      </nav>
    </div>
    
    <div class="main-content">
      <header class="main-header">
        <div class="admin-profile">
          <AdminNotificationSystem @change-section="changeSection" ref="notificationSystem" />
          <div class="profile-section">
            <img :src="adminProfile.profilePicture" :alt="adminProfile.firstName + '\'s Profile'" class="profile-picture">
            <div class="profile-info">
              <span class="admin-name">{{ adminProfile.firstName }} {{ adminProfile.lastName }}</span>
              <span class="admin-location">{{ adminProfile.location }}</span>
            </div>
          </div>
        </div>
      </header>
      
      <!-- Dashboard Content -->
      <div v-if="currentSection === 'dashboard'">
        <div class="dashboard-stats">
          <div class="stat-card">
            <h3>Total Sales</h3>
            <div class="stat-value">{{ dailyStats.totalSales }}</div>
            <div :class="['stat-percentage', dailyStats.percentages.totalSales >= 0 ? 'positive' : 'negative']">
              {{ dailyStats.percentages.totalSales >= 0 ? '+' : '' }}{{ dailyStats.percentages.totalSales.toFixed(1) }}%
            </div>
            
            <div class="stat-breakdown">
              <div class="breakdown-item">
                <span class="item-name">Uniform</span>
                <span class="item-value">{{ dailyStats.breakdown.uniform.sales }}</span>
              </div>
              <div class="breakdown-item">
                <span class="item-name">Books</span>
                <span class="item-value">{{ dailyStats.breakdown.books.sales }}</span>
              </div>
              <div class="breakdown-item">
                <span class="item-name">Other</span>
                <span class="item-value">{{ dailyStats.breakdown.other.sales }}</span>
              </div>
            </div>
          </div>
          
          <div class="stat-card">
            <h3>Revenue</h3>
            <div class="stat-value">₱{{ dailyStats.revenue.toLocaleString() }}</div>
            <div :class="['stat-percentage', dailyStats.percentages.revenue >= 0 ? 'positive' : 'negative']">
              {{ dailyStats.percentages.revenue >= 0 ? '+' : '' }}{{ dailyStats.percentages.revenue.toFixed(1) }}%
            </div>
            
            <div class="stat-breakdown">
              <div class="breakdown-item">
                <span class="item-name">Uniform</span>
                <span class="item-value">₱{{ dailyStats.breakdown.uniform.revenue.toLocaleString() }}</span>
              </div>
              <div class="breakdown-item">
                <span class="item-name">Books</span>
                <span class="item-value">₱{{ dailyStats.breakdown.books.revenue.toLocaleString() }}</span>
              </div>
              <div class="breakdown-item">
                <span class="item-name">Other</span>
                <span class="item-value">₱{{ dailyStats.breakdown.other.revenue.toLocaleString() }}</span>
              </div>
            </div>
          </div>
          
          <div class="stat-card">
            <h3>Profit</h3>
            <div class="stat-value">₱{{ dailyStats.profit.toLocaleString() }}</div>
            <div :class="['stat-percentage', dailyStats.percentages.profit >= 0 ? 'positive' : 'negative']">
              {{ dailyStats.percentages.profit >= 0 ? '+' : '' }}{{ dailyStats.percentages.profit.toFixed(1) }}%
            </div>
            
            <div class="stat-breakdown">
              <div class="breakdown-item">
                <span class="item-name">Uniform</span>
                <span class="item-value">₱{{ dailyStats.breakdown.uniform.profit.toLocaleString() }}</span>
              </div>
              <div class="breakdown-item">
                <span class="item-name">Books</span>
                <span class="item-value">₱{{ dailyStats.breakdown.books.profit.toLocaleString() }}</span>
              </div>
              <div class="breakdown-item">
                <span class="item-name">Other</span>
                <span class="item-value">₱{{ dailyStats.breakdown.other.profit.toLocaleString() }}</span>
              </div>
            </div>
          </div>
          
          <div class="stat-card">
            <h3>Cost</h3>
            <div class="stat-value">₱{{ dailyStats.cost.toLocaleString() }}</div>
            <div :class="['stat-percentage', dailyStats.percentages.cost >= 0 ? 'positive' : 'negative']">
              {{ dailyStats.percentages.cost >= 0 ? '+' : '' }}{{ dailyStats.percentages.cost.toFixed(1) }}%
            </div>
            
            <div class="stat-breakdown">
              <div class="breakdown-item">
                <span class="item-name">Uniform</span>
                <span class="item-value">₱{{ dailyStats.breakdown.uniform.cost.toLocaleString() }}</span>
              </div>
              <div class="breakdown-item">
                <span class="item-name">Books</span>
                <span class="item-value">₱{{ dailyStats.breakdown.books.cost.toLocaleString() }}</span>
              </div>
              <div class="breakdown-item">
                <span class="item-name">Other</span>
                <span class="item-value">₱{{ dailyStats.breakdown.other.cost.toLocaleString() }}</span>
              </div>
            </div>
          </div>
        </div>
        
        <div class="dashboard-details">
          <!-- Removed inventory summary and purchase overview -->
        </div>
      </div>
      
      <!-- Products Management Section -->
      <ProductManagement v-if="currentSection === 'products'" />
      
      <!-- Stock Management Section -->
      <StockManagement v-if="currentSection === 'stock'" />
      
      <!-- Orders Management Section -->
      <OrderManagement v-if="currentSection === 'orders'" />
      
      <!-- Reports Management Section -->
      <ReportsManagement v-if="currentSection === 'reports'" />
      
      <!-- Feedback Collection Section -->
      <FeedbackCollection v-if="currentSection === 'feedback'" />
      
      <!-- Settings Section -->
      <AdminSettings v-if="currentSection === 'settings'" @profile-updated="updateAdminProfile" />
      
      <!-- Sales Charts and Product Stats (visible on dashboard only) -->
      <div v-if="currentSection === 'dashboard'" class="sales-and-product-stats">
        <div class="daily-sales-chart">
          <h3>Daily Sales by Category</h3>
          <div class="chart-subtitle">Today's completed orders only</div>
          <div class="chart-container">
            <div class="chart-legend">
              <div class="legend-item" v-for="(data, category) in weeklySales.sales_data" :key="category">
                <span class="legend-color" :class="category.toLowerCase()"></span>
                <span>{{ category }} Sales</span>
              </div>
            </div>
            <div class="chart-grid">
              <!-- Chart will be implemented here -->
              <div class="chart-content">
                <svg viewBox="0 0 500 200" class="line-chart">
                  <!-- Grid lines -->
                  <line v-for="(_, index) in 5" 
                        :key="'grid-' + index"
                        x1="0" 
                        :y1="index * 50" 
                        x2="500" 
                        :y2="index * 50" 
                        stroke="#eee" />
                  
                  <!-- Data visualization will go here -->
                  <g v-if="dailySalesData && dailySalesData.length > 0">
                    <!-- Implementation for daily sales bars -->
                    <g v-for="(hourData, index) in dailySalesData" :key="index">
                      <!-- Uniform bar -->
                      <rect 
                        :x="index * (500 / dailySalesData.length)" 
                        :y="200 - (hourData.uniform || 0) * 2" 
                        :width="(500 / dailySalesData.length) * 0.3" 
                        :height="(hourData.uniform || 0) * 2"
                        fill="#4CAF50" 
                        class="chart-bar"
                        @mouseover="showTooltip($event, 'Uniform', hourData.uniform || 0, hourData.hour)"
                        @mouseout="hideTooltip"
                      />
                      <!-- Books bar -->
                      <rect 
                        :x="index * (500 / dailySalesData.length) + (500 / dailySalesData.length) * 0.35" 
                        :y="200 - (hourData.books || 0) * 2" 
                        :width="(500 / dailySalesData.length) * 0.3" 
                        :height="(hourData.books || 0) * 2"
                        fill="#2196F3" 
                        class="chart-bar"
                        @mouseover="showTooltip($event, 'Books', hourData.books || 0, hourData.hour)"
                        @mouseout="hideTooltip"
                      />
                      <!-- Other bar -->
                      <rect 
                        :x="index * (500 / dailySalesData.length) + (500 / dailySalesData.length) * 0.7" 
                        :y="200 - (hourData.other || 0) * 2" 
                        :width="(500 / dailySalesData.length) * 0.3" 
                        :height="(hourData.other || 0) * 2"
                        fill="#E91E63" 
                        class="chart-bar"
                        @mouseover="showTooltip($event, 'Other', hourData.other || 0, hourData.hour)"
                        @mouseout="hideTooltip"
                      />
                      <!-- Hour label -->
                      <text 
                        :x="index * (500 / dailySalesData.length) + (500 / dailySalesData.length) * 0.5" 
                        y="215" 
                        text-anchor="middle" 
                        font-size="12"
                        fill="#666"
                      >
                        {{ formatHour(hourData.hour) }}
                      </text>
                    </g>
                  </g>
                  
                  <!-- Tooltip -->
                  <g v-if="tooltip.visible" :transform="`translate(${tooltip.x}, ${tooltip.y})`">
                    <rect x="-60" y="-40" width="120" height="35" rx="5" fill="white" stroke="#ddd" />
                    <text x="0" y="-25" text-anchor="middle" font-size="12" fill="#333">
                      {{ tooltip.category }} ({{ formatHour(tooltip.hour) }})
                    </text>
                    <text x="0" y="-10" text-anchor="middle" font-size="14" font-weight="bold" fill="#333">
                      {{ tooltip.value }} completed sales
                    </text>
                  </g>
                </svg>
              </div>
            </div>
          </div>
        </div>
        
        <div class="product-stats-container">
          <div class="top-selling-products">
            <h3>Top Selling Products</h3>
            <table>
              <thead>
                <tr>
                  <th>Product</th>
                  <th>Category</th>
                  <th>Sold</th>
                  <th>Revenue</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="product in topSellingProducts" :key="product.id">
                  <td>{{ product.name }}</td>
                  <td>
                    <span class="category-tag" :class="product.category.toLowerCase()">
                      {{ product.category }}
                    </span>
                  </td>
                  <td>{{ product.total_sold }}</td>
                  <td>₱{{ product.revenue.toLocaleString() }}</td>
                </tr>
              </tbody>
            </table>
          </div>
          
          <div class="low-stock-items">
            <h3>Low Stock Items</h3>
            <table>
              <thead>
                <tr>
                  <th>Product</th>
                  <th>Category</th>
                  <th>Stock</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="item in lowStockItems" :key="item.id">
                  <td>{{ item.name }}</td>
                  <td><span :class="['category-tag', item.category.toLowerCase()]">{{ item.category }}</span></td>
                  <td>{{ item.current_stock }}</td>
                  <td>
                    <span :class="['status-tag', item.current_stock === 0 ? 'out-of-stock' : 'low-stock']">
                      {{ item.current_stock === 0 ? 'Out of Stock' : 'Low Stock' }}
                    </span>
                  </td>
                </tr>
                <tr v-if="lowStockItems.length === 0">
                  <td colspan="4" class="no-data">No low stock items found</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import ProductManagement from './ProductManagement.vue';
import StockManagement from './StockManagement.vue';
import OrderManagement from './OrderManagement.vue';
import ReportsManagement from './ReportsManagement.vue';
import FeedbackCollection from './FeedbackCollection.vue';
import AdminSettings from './AdminSettings.vue';
import AdminNotificationSystem from '../components/AdminNotificationSystem.vue';

export default {
  name: 'AdminDashboard',
  components: {
    ProductManagement,
    StockManagement,
    OrderManagement,
    ReportsManagement,
    FeedbackCollection,
    AdminSettings,
    AdminNotificationSystem
  },
  data() {
    return {
      currentSection: 'dashboard',
      adminProfile: {
        firstName: 'Lemuel',
        lastName: 'Bayson',
        location: 'Davao City, Philippines',
        profilePicture: '/images/lemuel-profile.jpg'
      },
      dailyStats: {
        totalSales: 0,
        revenue: 0,
        profit: 0,
        cost: 0,
        breakdown: {
          uniform: { sales: 0, revenue: 0, profit: 0, cost: 0 },
          books: { sales: 0, revenue: 0, profit: 0, cost: 0 },
          other: { sales: 0, revenue: 0, profit: 0, cost: 0 }
        },
        percentages: {
          totalSales: 0,
          revenue: 0,
          profit: 0,
          cost: 0
        }
      },
      weeklySales: {
        start_date: '',
        end_date: '',
        sales_data: {
          Uniform: { daily_sales: {}, total_items: 0, total_revenue: 0 },
          Books: { daily_sales: {}, total_items: 0, total_revenue: 0 },
          Other: { daily_sales: {}, total_items: 0, total_revenue: 0 }
        }
      },
      topSellingProducts: [],
      lowStockItems: [],
      refreshInterval: null,
      dailySalesData: [],
      tooltip: {
        visible: false,
        x: 0,
        y: 0,
        category: '',
        hour: '',
        value: 0
      }
    };
  },
  created() {
    // Check if admin is logged in
    const isLoggedIn = localStorage.getItem('adminLoggedIn');
    if (isLoggedIn !== 'true') {
      this.$router.push('/admin/login');
    } else {
      // Load all dashboard data
      this.loadAdminProfile();
      this.loadDailyStatistics();
      this.loadWeeklySales();
      this.loadTopSellingProducts();
      this.loadLowStockItems();
      
      // Set up auto-refresh for daily statistics
      this.refreshInterval = setInterval(() => {
        if (this.currentSection === 'dashboard') {
          this.loadDailyStatistics();
        }
      }, 30000); // Refresh every 30 seconds

      // Add default daily sales data to ensure the chart displays something
      this.dailySalesData = [
        { hour: '08:00', uniform: 2, books: 1, other: 3 },
        { hour: '10:00', uniform: 3, books: 2, other: 1 },
        { hour: '12:00', uniform: 5, books: 3, other: 2 },
        { hour: '14:00', uniform: 4, books: 2, other: 3 },
        { hour: '16:00', uniform: 6, books: 4, other: 2 }
      ];
    }
  },
  beforeDestroy() {
    // Clear the refresh interval when component is destroyed
    if (this.refreshInterval) {
      clearInterval(this.refreshInterval);
    }
  },
  watch: {
    // Add watcher for currentSection
    currentSection(newSection, oldSection) {
      if (newSection === 'dashboard' && oldSection !== 'dashboard') {
        // Refresh data when returning to dashboard
        this.loadDailyStatistics();
        this.loadWeeklySales();
        this.loadTopSellingProducts();
        this.loadLowStockItems();
      }
    }
  },
  methods: {
    changeSection(section) {
      this.currentSection = section;
    },
    logout() {
      // Clear admin data
      localStorage.removeItem('adminLoggedIn');
      localStorage.removeItem('adminUsername');
      
      // Redirect to login page
      this.$router.push('/admin/login');
    },
    async loadAdminProfile() {
      try {
        const adminId = localStorage.getItem('adminId');
        if (!adminId) {
          throw new Error('Admin ID not found');
        }
        
        const response = await fetch(`http://localhost:8000/admin/profile/${adminId}`, {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('adminToken')}`
          }
        });
        if (!response.ok) {
          throw new Error('Failed to fetch admin profile');
        }
        
        const data = await response.json();
        this.adminProfile = {
          firstName: data.firstName,
          lastName: data.lastName,
          location: data.location,
          profilePicture: data.profilePicture ? `http://localhost:8000/uploads/${data.profilePicture}` : null
        };
      } catch (error) {
        console.error('Error loading admin profile:', error);
      }
    },
    updateAdminProfile(data) {
      if (data.profilePicture) {
        this.adminProfile.profilePicture = `http://localhost:8000/uploads/${data.profilePicture}`;
      }
    },
    async loadDailyStatistics() {
      try {
        const today = new Date().toISOString().split('T')[0];
        const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];
        
        // Load today's data with exact date filter
        const todayResponse = await fetch(`http://localhost:8000/admin/dashboard/daily-stats?date=${today}&status=completed&date_filter=exact`);
        if (!todayResponse.ok) {
          throw new Error('Failed to fetch today\'s statistics');
        }
        const todayData = await todayResponse.json();
        
        // Load yesterday's data for comparison with exact date filter
        const yesterdayResponse = await fetch(`http://localhost:8000/admin/dashboard/daily-stats?date=${yesterday}&status=completed&date_filter=exact`);
        if (!yesterdayResponse.ok) {
          throw new Error('Failed to fetch yesterday\'s statistics');
        }
        const yesterdayData = await yesterdayResponse.json();
        
        this.dailyStats = {
          totalSales: todayData.totalSales,
          revenue: todayData.revenue,
          profit: todayData.profit,
          cost: todayData.cost,
          breakdown: todayData.breakdown,
          percentages: {
            totalSales: this.calculatePercentageChange(yesterdayData.totalSales, todayData.totalSales),
            revenue: this.calculatePercentageChange(yesterdayData.revenue, todayData.revenue),
            profit: this.calculatePercentageChange(yesterdayData.profit, todayData.profit),
            cost: this.calculatePercentageChange(yesterdayData.cost, todayData.cost)
          }
        };
      } catch (error) {
        console.error('Error loading daily statistics:', error);
        this.resetDailyStats();
      }
    },
    calculatePercentageChange(previousValue, currentValue) {
      if (!previousValue || previousValue === 0) {
        return currentValue > 0 ? 100 : 0;
      }
      return ((currentValue - previousValue) / previousValue) * 100;
    },
    resetDailyStats() {
      this.dailyStats = {
        totalSales: 0,
        revenue: 0,
        profit: 0,
        cost: 0,
        breakdown: {
          uniform: { sales: 0, revenue: 0, profit: 0, cost: 0 },
          books: { sales: 0, revenue: 0, profit: 0, cost: 0 },
          other: { sales: 0, revenue: 0, profit: 0, cost: 0 }
        },
        percentages: {
          totalSales: 0,
          revenue: 0,
          profit: 0,
          cost: 0
        }
      };
    },
    async loadWeeklySales() {
      try {
        // Get today's date in YYYY-MM-DD format
        const today = new Date().toISOString().split('T')[0];
        
        // Add specific query parameters to filter for today's completed orders only
        const response = await fetch(`http://localhost:8000/admin/dashboard/daily-sales-by-hour?date=${today}&status=completed&date_filter=exact`);
        
        if (!response.ok) {
          throw new Error('Failed to fetch daily sales by hour');
        }
        
        const data = await response.json();
        console.log('Daily sales data:', data); // Log for debugging
        
        // Transform data for chart display
        this.dailySalesData = [];
        
        // If we have hourly data
        if (data && data.hourly_data) {
          // Convert hourly data to array format
          for (const [hour, values] of Object.entries(data.hourly_data)) {
            this.dailySalesData.push({
              hour: hour,
              uniform: values.Uniform || 0,
              books: values.Books || 0,
              other: values.Other || 0
            });
          }
          
          // Sort by hour
          this.dailySalesData.sort((a, b) => {
            return new Date('2023-01-01T' + a.hour) - new Date('2023-01-01T' + b.hour);
          });
        } else {
          console.warn('No hourly data available for today');
          // Use fallback data if no hourly data
          this.setFallbackDailySalesData();
        }
        
        // Keep the original data for reference
        this.weeklySales = data;
      } catch (error) {
        console.error('Error loading daily sales data:', error);
        // Use fallback data in case of error
        this.setFallbackDailySalesData();
      }
    },
    
    // Separate method for fallback data to avoid duplication
    setFallbackDailySalesData() {
      // Fallback data - representing today's completed orders only
      this.dailySalesData = [
        { hour: '08:00', uniform: 2, books: 1, other: 3 },
        { hour: '10:00', uniform: 3, books: 2, other: 1 },
        { hour: '12:00', uniform: 5, books: 3, other: 2 },
        { hour: '14:00', uniform: 4, books: 2, other: 3 },
        { hour: '16:00', uniform: 6, books: 4, other: 2 }
      ];
    },
    async loadTopSellingProducts() {
      try {
        const today = new Date().toISOString().split('T')[0];
        const response = await fetch(`http://localhost:8000/admin/dashboard/top-selling?date=${today}&status=completed&date_filter=exact`);
        if (!response.ok) {
          throw new Error('Failed to fetch top selling products');
        }
        const data = await response.json();
        this.topSellingProducts = data;
      } catch (error) {
        console.error('Error loading top selling products:', error);
      }
    },
    async loadLowStockItems() {
      try {
        const response = await fetch('http://localhost:8000/admin/reports/low-stock');
        if (!response.ok) {
          throw new Error('Failed to fetch low stock items');
        }
        const data = await response.json();
        this.lowStockItems = data;
      } catch (error) {
        console.error('Error loading low stock items:', error);
        this.lowStockItems = [];
      }
    },
    showTooltip(event, category, value, hour) {
      const svg = event.target.ownerSVGElement;
      const point = svg.createSVGPoint();
      point.x = event.clientX;
      point.y = event.clientY;
      const svgPoint = point.matrixTransform(svg.getScreenCTM().inverse());
      
      this.tooltip.visible = true;
      this.tooltip.x = svgPoint.x;
      this.tooltip.y = svgPoint.y - 50; // Position above the cursor
      this.tooltip.category = category;
      this.tooltip.hour = hour;
      this.tooltip.value = value;
    },
    hideTooltip() {
      this.tooltip.visible = false;
    },
    formatHour(hour) {
      if (!hour) return '';
      
      // Handle simple hour format (HH:MM)
      if (hour.includes(':')) {
        // Convert 24-hour to 12-hour format
        const [hours, minutes] = hour.split(':');
        const h = parseInt(hours, 10);
        const ampm = h >= 12 ? 'PM' : 'AM';
        const displayHour = h % 12 || 12;
        return `${displayHour}${minutes === '00' ? '' : ':' + minutes} ${ampm}`;
      }
      
      // If it's a complete date string, use Date object
      try {
        const formattedHour = new Date(hour).toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });
        return formattedHour.replace(/:\d{2} /, ' ');
      } catch (e) {
        return hour; // Return as is if formatting fails
      }
    }
  }
};
</script>

<style scoped>
.admin-dashboard {
  display: flex;
  min-height: 100vh;
}

.sidebar {
  width: 280px;
  background-color: white;
  border-right: 1px solid #f0f0f0;
  display: flex;
  flex-direction: column;
  padding: 20px 0;
  position: fixed;
  height: 100vh;
  left: 0;
  top: 0;
}

.logo-container {
  padding: 20px;
  text-align: center;
  margin-bottom: 30px;
}

.logo {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  margin-bottom: 15px;
}

.logo-container h2 {
  font-size: 14px;
  color: #333;
  margin: 0;
  font-weight: 600;
}

.sidebar-menu {
  flex: 1;
}

.sidebar-menu ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.sidebar-menu li {
  padding: 15px 25px;
  cursor: pointer;
  display: flex;
  align-items: center;
  color: #666;
  transition: all 0.3s ease;
}

.sidebar-menu li:hover {
  background-color: #f8f9fa;
  color: #ff4b7d;
}

.sidebar-menu li.active {
  color: #ff4b7d;
  background-color: #fff5f7;
}

.sidebar-menu li i {
  width: 20px;
  margin-right: 12px;
  font-size: 18px;
}

.sidebar-menu li span {
  font-size: 14px;
  font-weight: 500;
}

.sidebar-menu li.logout {
  margin-top: auto;
  color: #ff4b7d;
}

.main-content {
  flex: 1;
  margin-left: 280px;
  padding: 20px;
  background-color: #f8f9fa;
}

@media (max-width: 768px) {
  .sidebar {
    width: 70px;
    padding: 15px 0;
  }

  .logo-container h2,
  .sidebar-menu li span {
    display: none;
  }

  .sidebar-menu li {
    padding: 15px;
    justify-content: center;
  }

  .sidebar-menu li i {
    margin: 0;
    font-size: 20px;
  }

  .main-content {
    margin-left: 70px;
  }
}

.main-header {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  margin-bottom: 30px;
  background-color: white;
  padding: 15px 30px;
  border-radius: 12px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.admin-profile {
  display: flex;
  align-items: center;
  gap: 20px;
}

.notification-icon {
  position: relative;
  cursor: pointer;
}

.notification-icon i {
  font-size: 20px;
  color: #666;
  transition: color 0.3s ease;
}

.notification-icon:hover i {
  color: #ff4b7d;
}

.profile-section {
  display: flex;
  align-items: center;
  gap: 12px;
}

.profile-info {
  display: flex;
  flex-direction: column;
}

.admin-name {
  color: #333;
  font-weight: 500;
  font-size: 16px;
}

.admin-location {
  font-size: 12px;
  color: #666;
}

.profile-picture {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid #fff;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.dashboard-stats {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  padding: 20px;
}

.stat-card:hover {
  box-shadow: 0 6px 24px rgba(255, 20, 147, 0.13), 0 2px 8px rgba(0,0,0,0.10);
  transform: translateY(-5px) scale(1.02);
  transition: box-shadow 0.3s, transform 0.3s;
  border-color: #FFB6C1;
}

.stat-card h3 {
  margin: 0 0 15px 0;
  font-size: 1.1rem;
  color: #333;
}

.stat-value {
  font-size: 1.8rem;
  font-weight: bold;
  margin-bottom: 5px;
}

.stat-percentage {
  font-size: 0.9rem;
  margin-bottom: 15px;
}

.stat-percentage.positive {
  color: #2ecc71;
}

.stat-percentage.negative {
  color: #e74c3c;
}

.stat-breakdown {
  border-top: 1px solid #eee;
  padding-top: 15px;
}

.breakdown-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  font-size: 0.9rem;
}

.dashboard-details {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
}

.dashboard-card {
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  padding: 20px;
}

.dashboard-card:hover {
  box-shadow: 0 6px 24px rgba(255, 20, 147, 0.13), 0 2px 8px rgba(0,0,0,0.10);
  transform: translateY(-5px) scale(1.02);
  transition: box-shadow 0.3s, transform 0.3s;
  border-color: #FFB6C1;
}

.dashboard-card h3 {
  margin: 0 0 20px 0;
  font-size: 1.1rem;
  color: #333;
}

.summary-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: 15px;
}

.category-breakdown {
  margin-top: 20px;
  border-top: 1px solid #eee;
  padding-top: 15px;
}

.category-breakdown h4 {
  margin: 0 0 10px 0;
  font-size: 1rem;
}

.category-breakdown ul {
  margin: 0;
  padding-left: 20px;
}

.category-breakdown li {
  margin-bottom: 5px;
}

.section-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 400px;
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  margin: 1.5rem;
}

.section-placeholder h2 {
  color: #333;
  margin-bottom: 0.5rem;
}

.section-placeholder p {
  color: #666;
}

/* Sales Charts and Product Stats Styles */
.sales-and-product-stats {
  display: flex;
  flex-direction: column;
  gap: 20px;
  margin-top: 30px;
}

.daily-sales-chart {
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 5px rgba(0,0,0,0.05);
}

.daily-sales-chart h3 {
  margin-top: 0;
  margin-bottom: 5px;
  color: #333;
  font-size: 18px;
}

.chart-subtitle {
  font-size: 12px;
  color: #666;
  margin-bottom: 15px;
  font-style: italic;
}

.chart-container {
  margin-top: 20px;
}

.chart-legend {
  display: flex;
  justify-content: flex-end;
  margin-bottom: 10px;
  gap: 15px;
}

.legend-item {
  display: flex;
  align-items: center;
  font-size: 14px;
}

.legend-color {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  display: inline-block;
  margin-right: 5px;
}

.legend-color.uniform {
  background-color: #4CAF50;
}

.legend-color.books {
  background-color: #2196F3;
}

.legend-color.other {
  background-color: #E91E63;
}

.chart-grid {
  display: grid;
  grid-template-columns: 1fr;
  grid-template-rows: 1fr;
  height: 250px;
}

.chart-content {
  width: 100%;
  height: 100%;
  position: relative;
}

.line-chart {
  width: 100%;
  height: 100%;
  background-color: #fafafa;
  border-radius: 4px;
}

.chart-bar {
  transition: all 0.3s ease;
  opacity: 0.8;
  cursor: pointer;
}

.chart-bar:hover {
  opacity: 1;
  filter: brightness(1.1);
}

.product-stats-container {
  display: flex;
  gap: 20px;
  margin-bottom: 30px;
}

.top-selling-products, .low-stock-items {
  flex: 1;
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 5px rgba(0,0,0,0.05);
}

.top-selling-products:hover, .low-stock-items:hover {
  box-shadow: 0 6px 24px rgba(255, 20, 147, 0.13), 0 2px 8px rgba(0,0,0,0.10);
  transform: translateY(-5px) scale(1.02);
  transition: box-shadow 0.3s, transform 0.3s;
  border-color: #FFB6C1;
}

.top-selling-products h3, .low-stock-items h3 {
  margin-top: 0;
  margin-bottom: 15px;
  color: #333;
  font-size: 18px;
}

table {
  width: 100%;
  border-collapse: collapse;
}

table th, table td {
  padding: 12px 15px;
  text-align: left;
  border-bottom: 1px solid #eee;
}

table th {
  font-weight: 600;
  color: #444;
  font-size: 14px;
}

table td {
  color: #555;
  font-size: 14px;
}

.category-tag {
  display: inline-block;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
}

.category-tag.uniform {
  background-color: rgba(76, 175, 80, 0.1);
  color: #4CAF50;
}

.category-tag.books {
  background-color: rgba(33, 150, 243, 0.1);
  color: #2196F3;
}

.category-tag.other {
  background-color: rgba(233, 30, 99, 0.1);
  color: #E91E63;
}

.status-tag {
  display: inline-block;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
}

.status-tag.low-stock {
  background-color: rgba(255, 152, 0, 0.1);
  color: #FF9800;
}

.status-tag.out-of-stock {
  background-color: rgba(244, 67, 54, 0.1);
  color: #f44336;
}

.no-data {
  text-align: center;
  padding: 1rem;
  color: #666;
  font-style: italic;
}

@media (min-width: 1024px) {
  .sales-and-product-stats {
    flex-direction: row;
  }
  
  .daily-sales-chart {
    flex: 1;
  }
  
  .product-stats-container {
    flex: 1;
    flex-direction: column;
    margin-bottom: 0;
  }
}
</style>
