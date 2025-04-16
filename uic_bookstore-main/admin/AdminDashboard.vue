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
          <div class="notification-icon">
            <i class="fas fa-bell"></i>
          </div>
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
          <div class="dashboard-card inventory-summary">
            <h3>Inventory Summary</h3>
            
            <div class="summary-item">
              <span class="item-label">Currently in Stock</span>
              <span class="item-value">{{ inventorySummary.currently_in_stock }} items</span>
            </div>
            
            <div class="summary-item">
              <span class="item-label">Low Stock Items</span>
              <span class="item-value">{{ inventorySummary.low_stock_items }} items</span>
            </div>
            
            <div class="summary-item">
              <span class="item-label">To be Received</span>
              <span class="item-value">{{ inventorySummary.to_be_received }} items</span>
            </div>
            
            <div class="category-breakdown">
              <h4>Category Breakdown</h4>
              <ul>
                <li>Uniform: 63 items (1 low stock)</li>
                <li>Books: 30 items (1 low stock)</li>
                <li>Other: 45 items (1 low stock)</li>
              </ul>
            </div>
          </div>
          
          <div class="dashboard-card purchase-overview">
            <h3>Purchase Overview</h3>
            
            <div class="summary-item">
              <span class="item-label">Purchase Orders</span>
              <span class="item-value">{{ purchaseOverview.purchase_orders }}</span>
            </div>
            
            <div class="summary-item">
              <span class="item-label">Total Cost</span>
              <span class="item-value">₱{{ purchaseOverview.total_cost.toLocaleString() }}</span>
            </div>
            
            <div class="summary-item">
              <span class="item-label">Pending Delivery</span>
              <span class="item-value">{{ purchaseOverview.pending_delivery }}</span>
            </div>
          </div>
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
        <div class="weekly-sales-chart">
          <h3>Weekly Sales by Category</h3>
          <div class="chart-container">
            <div class="chart-legend">
              <div class="legend-item" v-for="(data, category) in weeklySales.sales_data" :key="category">
                <span class="legend-color" :class="category.toLowerCase()"></span>
                <span>{{ category }} Sales</span>
              </div>
            </div>
            <div class="chart-grid">
              <!-- Add dynamic chart rendering based on weeklySales.sales_data -->
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
                <tr>
                  <td>PE Book</td>
                  <td><span class="category-tag books">Books</span></td>
                  <td>3</td>
                  <td><span class="status-tag low-stock">Low Stock</span></td>
                </tr>
                <tr>
                  <td>Blouse</td>
                  <td><span class="category-tag uniform">Uniform</span></td>
                  <td>8</td>
                  <td><span class="status-tag low-stock">Low Stock</span></td>
                </tr>
                <tr>
                  <td>Scantron</td>
                  <td><span class="category-tag other">Other</span></td>
                  <td>45</td>
                  <td><span class="status-tag low-stock">Low Stock</span></td>
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

export default {
  name: 'AdminDashboard',
  components: {
    ProductManagement,
    StockManagement,
    OrderManagement,
    ReportsManagement,
    FeedbackCollection,
    AdminSettings
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
      inventorySummary: {
        currently_in_stock: 0,
        low_stock_items: 0,
        to_be_received: 0
      },
      purchaseOverview: {
        purchase_orders: 0,
        total_cost: 0,
        pending_delivery: 0
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
      topSellingProducts: []
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
      this.loadInventorySummary();
      this.loadPurchaseOverview();
      this.loadWeeklySales();
      this.loadTopSellingProducts();
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
        // Get today's date in YYYY-MM-DD format
        const today = new Date().toISOString().split('T')[0];
        
        // Fetch today's orders directly from the orders endpoint
        const todayResponse = await fetch(`http://localhost:8000/admin/orders?date=${today}`);
        if (!todayResponse.ok) {
          throw new Error('Failed to fetch today\'s orders');
        }
        const todayOrders = await todayResponse.json();
        
        // Get yesterday's date
        const yesterday = new Date();
        yesterday.setDate(yesterday.getDate() - 1);
        const yesterdayStr = yesterday.toISOString().split('T')[0];
        
        // Fetch yesterday's orders for comparison
        const yesterdayResponse = await fetch(`http://localhost:8000/admin/orders?date=${yesterdayStr}`);
        if (!yesterdayResponse.ok) {
          throw new Error('Failed to fetch yesterday\'s orders');
        }
        const yesterdayOrders = await yesterdayResponse.json();
        
        // Process today's orders data
        const todayData = this.processOrdersData(todayOrders);
        
        // Process yesterday's orders data for comparison
        const yesterdayData = this.processOrdersData(yesterdayOrders);
        
        // Calculate percentages and update stats
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
    async loadInventorySummary() {
      try {
        const response = await fetch('http://localhost:8000/admin/dashboard/inventory-summary');
        if (!response.ok) {
          throw new Error('Failed to fetch inventory summary');
        }
        const data = await response.json();
        this.inventorySummary = data;
      } catch (error) {
        console.error('Error loading inventory summary:', error);
      }
    },
    async loadPurchaseOverview() {
      try {
        const today = new Date().toISOString().split('T')[0];
        const response = await fetch(`http://localhost:8000/admin/dashboard/purchase-overview?date=${today}`);
        if (!response.ok) {
          throw new Error('Failed to fetch purchase overview');
        }
        const data = await response.json();
        this.purchaseOverview = data;
      } catch (error) {
        console.error('Error loading purchase overview:', error);
      }
    },
    async loadWeeklySales() {
      try {
        const today = new Date().toISOString().split('T')[0];
        const response = await fetch(`http://localhost:8000/admin/dashboard/weekly-sales?date=${today}`);
        if (!response.ok) {
          throw new Error('Failed to fetch weekly sales');
        }
        const data = await response.json();
        this.weeklySales = data;
      } catch (error) {
        console.error('Error loading weekly sales:', error);
      }
    },
    async loadTopSellingProducts() {
      try {
        const today = new Date().toISOString().split('T')[0];
        const response = await fetch(`http://localhost:8000/admin/dashboard/top-selling?date=${today}`);
        if (!response.ok) {
          throw new Error('Failed to fetch top selling products');
        }
        const data = await response.json();
        this.topSellingProducts = data;
      } catch (error) {
        console.error('Error loading top selling products:', error);
      }
    },
    // Process orders data to calculate statistics
    processOrdersData(orders) {
      const result = {
        totalSales: 0,
        revenue: 0,
        profit: 0,
        cost: 0,
        breakdown: {
          uniform: { sales: 0, revenue: 0, profit: 0, cost: 0 },
          books: { sales: 0, revenue: 0, profit: 0, cost: 0 },
          other: { sales: 0, revenue: 0, profit: 0, cost: 0 }
        }
      };
      
      // Only process completed orders
      const completedOrders = orders.filter(order => order.status === 'Completed');
      
      completedOrders.forEach(order => {
        if (order.items && Array.isArray(order.items)) {
          order.items.forEach(item => {
            // Update total sales count
            result.totalSales += item.quantity;
            
            // Update revenue
            const itemRevenue = item.price * item.quantity;
            result.revenue += itemRevenue;
            
            // Update cost
            const itemCost = item.cost * item.quantity;
            result.cost += itemCost;
            
            // Calculate profit
            const itemProfit = itemRevenue - itemCost;
            result.profit += itemProfit;
            
            // Update category breakdown
            const category = item.category ? item.category.toLowerCase() : 'other';
            if (result.breakdown[category]) {
              result.breakdown[category].sales += item.quantity;
              result.breakdown[category].revenue += itemRevenue;
              result.breakdown[category].cost += itemCost;
              result.breakdown[category].profit += itemProfit;
            }
          });
        }
      });
      
      return result;
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

.weekly-sales-chart {
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 5px rgba(0,0,0,0.05);
}

.weekly-sales-chart h3 {
  margin-top: 0;
  margin-bottom: 15px;
  color: #333;
  font-size: 18px;
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
  grid-template-columns: 40px 1fr;
  grid-template-rows: 1fr 30px;
  gap: 5px;
}

.y-axis {
  grid-row: 1;
  grid-column: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  align-items: flex-end;
  padding-right: 10px;
  font-size: 12px;
  color: #666;
}

.chart-area {
  grid-row: 1;
  grid-column: 2;
  border-left: 1px solid #ccc;
  border-bottom: 1px solid #ccc;
  position: relative;
}

.x-axis {
  grid-row: 2;
  grid-column: 2;
  display: flex;
  justify-content: space-between;
  padding: 5px 0;
  font-size: 12px;
  color: #666;
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

@media (min-width: 1024px) {
  .sales-and-product-stats {
    flex-direction: row;
  }
  
  .weekly-sales-chart {
    flex: 1;
  }
  
  .product-stats-container {
    flex: 1;
    flex-direction: column;
    margin-bottom: 0;
  }
}
</style>
