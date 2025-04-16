import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import App from './App.vue'

// Import components
import StudentLogin from './student/StudentLogin.vue'
import StudentSignup from './student/StudentSignup.vue'
import StudentHomepage from './student/StudentHomepage.vue'
import StudentStore from './student/StudentStore.vue'
// Admin components
import AdminLogin from './admin/AdminLogin.vue'
import AdminDashboard from './admin/AdminDashboard.vue'
import ProductManagement from './admin/ProductManagement.vue'
import StockManagement from './admin/StockManagement.vue'
import OrderManagement from './admin/OrderManagement.vue'
import AdminSignup from './admin/AdminSignup.vue'

// Create the router instance
const router = createRouter({
  history: createWebHistory(),
  routes: [
    // Redirect root to student login
    { 
      path: '/', 
      redirect: '/student/login' 
    },
    
    // Student routes
    { 
      path: '/student/login', 
      component: StudentLogin 
    },
    { 
      path: '/student/signup', 
      component: StudentSignup 
    },
    { 
      path: '/student/homepage', 
      component: StudentHomepage 
    },
    { 
      path: '/student/books', 
      component: StudentStore 
    },
    
    // Admin routes
    {
      path: '/admin/login',
      component: AdminLogin
    },
    {
      path: '/admin/signup',
      component: AdminSignup
    },
    {
      path: '/admin/dashboard',
      component: AdminDashboard
    },
    {
      path: '/admin/products',
      component: ProductManagement
    },
    {
      path: '/admin/stock',
      component: StockManagement
    },
    {
      path: '/admin/orders',
      component: OrderManagement
    },
    
    // Fallback route (404)
    { 
      path: '/:pathMatch(.*)*', 
      redirect: '/student/login' 
    }
  ]
})

// Create the Vue app using the App component
const app = createApp(App)

// Use router
app.use(router)

// Mount the app
app.mount('#app') 