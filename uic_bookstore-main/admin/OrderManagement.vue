<template>
  <div class="order-management">
    <div class="page-header">
      <h2>Overall Orders</h2>
      <div class="header-buttons">
        <button class="import-btn" @click="openImportModal">
          <i class="fas fa-file-import"></i> Import Orders
        </button>
        <button class="add-btn" @click="openAddOrderModal">
          <i class="fas fa-plus"></i> Add Order
        </button>
      </div>
    </div>
    
    <div class="search-filter-bar">
      <div class="search-box">
        <input type="text" v-model="searchQuery" placeholder="Search orders..." @input="filterOrders">
      </div>
      <div class="status-filter">
        <select v-model="selectedStatus" @change="loadOrders">
          <option value="all">All Status</option>
          <option value="Pending">Pending</option>
          <option value="Completed">Completed</option>
          <option value="Cancelled">Cancelled</option>
        </select>
      </div>
    </div>
    
    <div class="orders-table">
      <table>
        <thead>
          <tr>
            <th>Order ID</th>
            <th>Customer</th>
            <th>Date</th>
            <th>Total</th>
            <th>Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="order in filteredOrders" :key="order.id">
            <td>#{{ order.id }}</td>
            <td>{{ order.customer_name }}</td>
            <td>{{ formatDate(order.created_at) }}</td>
            <td>₱{{ order.total }}</td>
            <td>
              <span :class="'status-badge ' + order.status.toLowerCase()">
                {{ order.status }}
              </span>
            </td>
            <td class="actions-cell">
              <button class="view-btn" @click="viewOrder(order)">
                <i class="fas fa-eye"></i> View
              </button>
              <button class="edit-btn" @click="editOrder(order)">
                <i class="fas fa-edit"></i> Edit
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    
    <!-- Add Order Modal -->
    <div class="modal" v-if="showAddOrderModal">
      <div class="modal-content order-modal">
        <div class="modal-header">
          <h3>Create New Order</h3>
          <button class="close-btn" @click="closeAddOrderModal">&times;</button>
        </div>
        <div class="modal-body">
          <form @submit.prevent="saveOrder" class="order-form">
            <div class="form-group">
              <label for="customerName">Customer Name</label>
              <input 
                type="text" 
                id="customerName" 
                v-model="orderForm.customer_name" 
                placeholder="Enter customer name"
                required
              />
            </div>
            
            <h4>Items</h4>
            <div class="order-items">
              <div 
                v-for="(item, index) in orderForm.items" 
                :key="index" 
                class="order-item"
              >
                <div class="item-row">
                  <div class="item-select">
                    <select v-model="item.product_id" @change="updateItemPrice(index)" required>
                      <option value="" disabled>Select product</option>
                      <option 
                        v-for="product in products" 
                        :key="product.id" 
                        :value="product.id"
                        :disabled="product.stock <= 0"
                      >
                        {{ product.name }} - ₱{{ product.price }} ({{ product.stock }} in stock)
                      </option>
                    </select>
                  </div>
                  
                  <div class="item-quantity">
                    <input 
                      type="number" 
                      v-model.number="item.quantity" 
                      min="1" 
                      :max="getMaxQuantity(item.product_id)" 
                      required
                      @change="validateItemQuantity(index)"
                    />
                  </div>
                  
                  <div class="item-remove">
                    <button type="button" @click="removeItem(index)" class="remove-item-btn">
                      <i class="fas fa-trash"></i>
                    </button>
                  </div>
                </div>
              </div>
              
              <button type="button" @click="addItem" class="add-item-btn">
                + Add Item
              </button>
            </div>
            
            <div class="order-summary">
              <div class="summary-row">
                <span>Total Items:</span>
                <span>{{ getTotalItems() }}</span>
              </div>
              
              <div class="summary-row">
                <span>Total Amount:</span>
                <span>₱{{ calculateTotal() }}</span>
              </div>
            </div>
            
            <div class="form-actions">
              <button type="button" class="cancel-btn" @click="closeAddOrderModal">Cancel</button>
              <button type="submit" class="save-btn" :disabled="isLoading || !isOrderValid()">
                {{ isLoading ? 'Creating...' : 'Create Order' }}
              </button>
            </div>
            
            <div v-if="error" class="error-message">{{ error }}</div>
          </form>
        </div>
      </div>
    </div>
    
    <!-- View Order Modal (view only) -->
    <div class="modal" v-if="showViewOrderModal && !selectedOrder.isEditable">
      <div class="modal-content view-order-modal">
<<<<<<< HEAD
        <div class="modal-header view-header">
          <h3><i class="fas fa-receipt"></i> View Order #{{ selectedOrder.id }}</h3>
=======
        <div class="modal-header">
          <h3>{{ selectedOrder.isEditable ? 'Edit Order' : 'View Order' }} #{{ selectedOrder.id }}</h3>
>>>>>>> 81b584e837377ff81d30f83eefd8cd3b44eb81ba
          <button class="close-btn" @click="closeViewOrderModal">&times;</button>
        </div>
        <div class="modal-body view-body">
          <div class="order-details view-details">
            <div class="detail-row">
              <strong><i class="fas fa-user"></i> Customer:</strong>
              <span class="detail-value">{{ selectedOrder.customer_name }}</span>
            </div>
            <div class="detail-row">
              <strong><i class="fas fa-calendar-alt"></i> Date:</strong>
              <span class="detail-value">{{ formatDate(selectedOrder.created_at) }}</span>
            </div>
            <div class="detail-row">
<<<<<<< HEAD
              <strong><i class="fas fa-info-circle"></i> Status:</strong>
              <span class="detail-value">
                <span :class="'status-badge ' + selectedOrder.status.toLowerCase()">
                  {{ selectedOrder.status }}
                </span>
=======
              <strong>Status:</strong>
              <span>
                <select v-model="selectedOrder.status" @change="updateOrderStatus" :disabled="isUpdatingStatus || !selectedOrder.isEditable">
                  <option value="Pending">Pending</option>
                  <option value="Completed">Completed</option>
                  <option value="Cancelled">Cancelled</option>
                </select>
>>>>>>> 81b584e837377ff81d30f83eefd8cd3b44eb81ba
              </span>
            </div>
          </div>
          <hr class="section-divider" />
          <h4 class="section-title"><i class="fas fa-box"></i> Order Items</h4>
          <table class="order-items-table">
            <thead>
              <tr>
                <th>Product</th>
                <th>Price</th>
                <th>Quantity</th>
                <th>Subtotal</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="item in selectedOrder.items" :key="item.id">
                <td>{{ item.product_name }}</td>
                <td>₱{{ item.price }}</td>
                <td>{{ item.quantity }}</td>
                <td>₱{{ (item.price * item.quantity).toFixed(2) }}</td>
              </tr>
            </tbody>
            <tfoot>
              <tr>
                <td colspan="3" class="total-label">Total:</td>
                <td class="total-value">₱{{ calculateOrderTotal(selectedOrder) }}</td>
              </tr>
            </tfoot>
          </table>
        </div>
        
        <div class="modal-footer" v-if="selectedOrder.isEditable">
          <button class="cancel-btn" @click="closeViewOrderModal">Cancel</button>
          <button class="save-btn" @click="updateOrderStatus" :disabled="isUpdatingStatus">
            {{ isUpdatingStatus ? 'Saving...' : 'Save Changes' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Import Modal -->
    <div class="modal" v-if="showImportModal">
      <div class="modal-content import-modal">
        <div class="modal-header">
          <h3>Import Orders</h3>
          <button class="close-btn" @click="closeImportModal">&times;</button>
        </div>
        <div class="modal-body">
          <div class="import-instructions">
            <p>Please select a CSV file with the following columns:</p>
            <ul>
              <li>customer_name</li>
              <li>product_id</li>
              <li>quantity</li>
            </ul>
          </div>
          <div class="file-upload">
            <input 
              type="file" 
              ref="fileInput" 
              accept=".csv"
              @change="handleFileUpload" 
              class="file-input"
            >
          </div>
          <div v-if="importError" class="error-message">{{ importError }}</div>
        </div>
        <div class="modal-footer">
          <button class="cancel-btn" @click="closeImportModal">Cancel</button>
          <button 
            class="save-btn" 
            @click="importOrders" 
            :disabled="!selectedFile || isImporting"
          >
            {{ isImporting ? 'Importing...' : 'Import' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Edit Order Modal (edit only) -->
    <div class="modal" v-if="showViewOrderModal && selectedOrder.isEditable">
      <div class="modal-content view-order-modal">
        <div class="modal-header">
          <h3>Edit Order #{{ selectedOrder.id }}</h3>
          <button class="close-btn" @click="closeViewOrderModal">&times;</button>
        </div>
        <div class="modal-body">
          <div class="order-details">
            <div class="detail-row">
              <strong>Customer:</strong>
              <span>{{ selectedOrder.customer_name }}</span>
            </div>
            <div class="detail-row">
              <strong>Date:</strong>
              <span>{{ formatDate(selectedOrder.created_at) }}</span>
            </div>
            <div class="detail-row">
              <strong>Status:</strong>
              <span>
                <select v-model="selectedOrder.status" @change="updateOrderStatus" :disabled="isUpdatingStatus || !selectedOrder.isEditable">
                  <option value="Pending">Pending</option>
                  <option value="Completed">Completed</option>
                  <option value="Cancelled">Cancelled</option>
                </select>
              </span>
            </div>
          </div>
          <h4>Order Items</h4>
          <table class="order-items-table">
            <thead>
              <tr>
                <th>Product</th>
                <th>Price</th>
                <th>Quantity</th>
                <th>Subtotal</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="item in selectedOrder.items" :key="item.id">
                <td>{{ item.product_name }}</td>
                <td>₱{{ item.price }}</td>
                <td>{{ item.quantity }}</td>
                <td>₱{{ (item.price * item.quantity).toFixed(2) }}</td>
              </tr>
            </tbody>
            <tfoot>
              <tr>
                <td colspan="3" class="total-label">Total:</td>
                <td class="total-value">₱{{ calculateOrderTotal(selectedOrder) }}</td>
              </tr>
            </tfoot>
          </table>
        </div>
        <div class="modal-footer">
          <button class="cancel-btn" @click="closeViewOrderModal">Cancel</button>
          <button class="save-btn" @click="updateOrderStatus" :disabled="isUpdatingStatus">
            {{ isUpdatingStatus ? 'Saving...' : 'Save Changes' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Import Modal -->
    <div class="modal" v-if="showImportModal">
      <div class="modal-content import-modal">
        <div class="modal-header">
          <h3>Import Orders</h3>
          <button class="close-btn" @click="closeImportModal">&times;</button>
        </div>
        <div class="modal-body">
          <div class="import-instructions">
            <p>Please select a CSV file with the following columns:</p>
            <ul>
              <li>customer_name</li>
              <li>product_id</li>
              <li>quantity</li>
              <li>order_date (YYYY-MM-DD format)</li>
            </ul>
          </div>
          <div class="file-upload">
            <input 
              type="file" 
              ref="fileInput" 
              accept=".csv"
              @change="handleFileUpload" 
              class="file-input"
            >
          </div>
          <div v-if="importError" class="error-message">{{ importError }}</div>
        </div>
        <div class="modal-footer">
          <button class="cancel-btn" @click="closeImportModal">Cancel</button>
          <button 
            class="save-btn" 
            @click="importOrders" 
            :disabled="!selectedFile || isImporting"
          >
            {{ isImporting ? 'Importing...' : 'Import' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'OrderManagement',
  data() {
    return {
      orders: [],
      filteredOrders: [],
      products: [],
      searchQuery: '',
      selectedStatus: 'all',
      showAddOrderModal: false,
      showViewOrderModal: false,
      selectedOrder: {},
      orderForm: {
        customer_name: '',
        items: [
          { product_id: '', quantity: 1, price: 0 }
        ]
      },
      isLoading: false,
      isUpdatingStatus: false,
      error: null,
      showImportModal: false,
      selectedFile: null,
      isImporting: false,
      importError: null
    };
  },
  created() {
    this.loadOrders();
    this.loadProducts();
  },
  methods: {
    async loadOrders() {
      try {
        const url = this.selectedStatus === 'all' 
          ? 'http://localhost:8000/admin/orders' 
          : `http://localhost:8000/admin/orders?status=${this.selectedStatus}`;
          
        const response = await fetch(url);
        const data = await response.json();
        
        if (response.ok) {
          this.orders = data.orders;
          this.filterOrders();
        } else {
          throw new Error(data.detail || 'Failed to load orders');
        }
      } catch (error) {
        console.error('Error loading orders:', error);
        this.error = 'Failed to load orders. Please try again.';
      }
    },
    
    async loadProducts() {
      try {
        const response = await fetch('http://localhost:8000/products');
        const data = await response.json();
        
        if (response.ok) {
          this.products = data.products;
        } else {
          throw new Error(data.detail || 'Failed to load products');
        }
      } catch (error) {
        console.error('Error loading products:', error);
        this.error = 'Failed to load products. Please try again.';
      }
    },
    
    filterOrders() {
      if (!this.searchQuery) {
        this.filteredOrders = [...this.orders];
        return;
      }
      
      const query = this.searchQuery.toLowerCase();
      this.filteredOrders = this.orders.filter(order => 
        order.customer_name.toLowerCase().includes(query) ||
        String(order.id).includes(query)
      );
    },
    
    formatDate(dateString) {
      const date = new Date(dateString);
      return date.toLocaleString('en-US', {
        year: 'numeric',
        month: 'numeric',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        hour12: true
      });
    },
    
    openAddOrderModal() {
      this.showAddOrderModal = true;
      this.resetOrderForm();
    },
    
    closeAddOrderModal() {
      this.showAddOrderModal = false;
      this.resetOrderForm();
    },
    
    resetOrderForm() {
      this.orderForm = {
        customer_name: '',
        items: [
          { product_id: '', quantity: 1, price: 0 }
        ]
      };
      this.error = null;
    },
    
    viewOrder(order) {
      // Need to fetch the full order with items
      this.fetchOrderDetails(order.id, false);
    },
    
    async fetchOrderDetails(orderId, isEditable = false) {
      try {
        const response = await fetch(`http://localhost:8000/admin/orders/${orderId}`);
        
        if (response.ok) {
          const data = await response.json();
          this.selectedOrder = data;
          this.selectedOrder.isEditable = isEditable; // Add flag to indicate if editable
          this.showViewOrderModal = true;
        } else {
          const errorData = await response.json();
          throw new Error(errorData.detail || 'Failed to load order details');
        }
      } catch (error) {
        console.error('Error loading order details:', error);
        alert('Failed to load order details. Please try again.');
      }
    },
    
    closeViewOrderModal() {
      this.showViewOrderModal = false;
      this.selectedOrder = {};
    },
    
    editOrder(order) {
      this.fetchOrderDetails(order.id, true);
    },
    
    updateItemPrice(index) {
      const item = this.orderForm.items[index];
      if (item.product_id) {
        const product = this.products.find(p => p.id === item.product_id);
        if (product) {
          item.price = parseFloat(product.price);
          
          // Ensure quantity doesn't exceed available stock
          if (item.quantity > product.stock) {
            item.quantity = product.stock;
          }
        }
      } else {
        item.price = 0;
      }
    },
    
    getMaxQuantity(productId) {
      if (!productId) return 1;
      const product = this.products.find(p => p.id === productId);
      return product ? product.stock : 1;
    },
    
    validateItemQuantity(index) {
      const item = this.orderForm.items[index];
      if (!item.product_id) return;
      
      const product = this.products.find(p => p.id === item.product_id);
      if (product && item.quantity > product.stock) {
        item.quantity = product.stock;
      }
      
      if (item.quantity < 1) {
        item.quantity = 1;
      }
    },
    
    addItem() {
      this.orderForm.items.push({ product_id: '', quantity: 1, price: 0 });
    },
    
    removeItem(index) {
      if (this.orderForm.items.length > 1) {
        this.orderForm.items.splice(index, 1);
      }
    },
    
    getTotalItems() {
      return this.orderForm.items.reduce((total, item) => total + (item.quantity || 0), 0);
    },
    
    calculateTotal() {
      return this.orderForm.items.reduce((total, item) => {
        if (item.product_id && item.quantity && item.price) {
          return total + (item.quantity * item.price);
        }
        return total;
      }, 0).toFixed(2);
    },
    
    calculateOrderTotal(order) {
      if (!order || !order.items) return '0.00';
      
      return order.items.reduce((total, item) => {
        return total + (item.quantity * item.price);
      }, 0).toFixed(2);
    },
    
    isOrderValid() {
      // Check if customer name is provided
      if (!this.orderForm.customer_name.trim()) return false;
      
      // Check if there's at least one valid item
      return this.orderForm.items.some(item => 
        item.product_id && item.quantity > 0 && item.price > 0
      );
    },
    
    async saveOrder() {
      if (!this.isOrderValid()) return;
      
      this.isLoading = true;
      this.error = null;
      
      try {
        // Filter out any invalid items
        const validItems = this.orderForm.items.filter(item => 
          item.product_id && item.quantity > 0 && item.price > 0
        );
        
        const orderData = {
          customer_name: this.orderForm.customer_name,
          status: 'Pending',
          items: validItems
        };
        
        const response = await fetch('http://localhost:8000/admin/orders', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(orderData)
        });
        
        const data = await response.json();
        
        if (response.ok) {
          // Close modal and refresh orders list
          this.closeAddOrderModal();
          this.loadOrders();
        } else {
          throw new Error(data.detail || 'Failed to create order');
        }
      } catch (error) {
        console.error('Error creating order:', error);
        this.error = error.message || 'Failed to create order. Please try again.';
      } finally {
        this.isLoading = false;
      }
    },
    
    async updateOrderStatus() {
      if (!this.selectedOrder.id) return;
      
      // If we're in edit mode, show confirmation dialog
      if (this.selectedOrder.isEditable) {
        const confirmed = confirm("Are you sure you want to save the changes?");
        if (!confirmed) {
          return;
        }
      }
      
      this.isUpdatingStatus = true;
      
      try {
        const response = await fetch(`http://localhost:8000/admin/orders/${this.selectedOrder.id}`, {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            status: this.selectedOrder.status
          })
        });
        
        if (response.ok) {
          // Refresh order list
          this.loadOrders();
          // Close the modal after successfully saving changes
          this.closeViewOrderModal();
        } else {
          const errorData = await response.json();
          throw new Error(errorData.detail || 'Failed to update order status');
        }
      } catch (error) {
        console.error('Error updating order status:', error);
        alert('Failed to update order status. Please try again.');
        // Revert status change
        this.fetchOrderDetails(this.selectedOrder.id);
      } finally {
        this.isUpdatingStatus = false;
      }
    },
    
    openImportModal() {
      this.showImportModal = true;
    },
    
    closeImportModal() {
      this.showImportModal = false;
      this.selectedFile = null;
      this.importError = null;
    },
    
    handleFileUpload(event) {
      const file = event.target.files[0];
      if (file) {
        this.selectedFile = file;
      }
    },
    
    async importOrders() {
      if (!this.selectedFile) {
        this.importError = 'Please select a file to import';
        return;
      }
      
      this.isImporting = true;
      this.importError = null;
      
      try {
        const formData = new FormData();
        formData.append('file', this.selectedFile);
        
        const response = await fetch('http://localhost:8000/admin/orders/import', {
          method: 'POST',
          body: formData
        });
        
        if (response.ok) {
          this.closeImportModal();
          this.loadOrders();
        } else {
          const errorData = await response.json();
          throw new Error(errorData.detail || 'Failed to import orders');
        }
      } catch (error) {
        console.error('Error importing orders:', error);
        this.importError = error.message || 'Failed to import orders. Please try again.';
      } finally {
        this.isImporting = false;
      }
    }
  }
};
</script>

<style scoped>
.order-management {
  padding: 1.5rem;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.page-header h2 {
  margin: 0;
  font-size: 1.5rem;
  color: #333;
}

.header-buttons {
  display: flex;
  gap: 0.5rem;
}

.import-btn, .add-btn {
  background-color: #0066cc;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  font-size: 0.9rem;
  font-weight: 500;
  cursor: pointer;
  display: flex;
  align-items: center;
}

.import-btn i, .add-btn i {
  margin-right: 0.5rem;
}

.search-filter-bar {
  display: flex;
  justify-content: space-between;
  margin-bottom: 1.5rem;
  gap: 1rem;
}

.search-box {
  flex: 1;
}

.search-box input {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.status-filter select {
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  width: 180px;
}

.orders-table {
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  overflow: hidden;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th, td {
  padding: 0.75rem 1rem;
  text-align: left;
  border-bottom: 1px solid #f0f0f0;
}

th {
  background-color: #f9f9f9;
  font-weight: 600;
  color: #555;
}

.status-badge {
  display: inline-block;
  padding: 0.25rem 0.5rem;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 500;
}

.status-badge.pending {
  background-color: #fff8e1;
  color: #ffa000;
}

.status-badge.completed {
  background-color: #e8f5e9;
  color: #43a047;
}

.status-badge.cancelled {
  background-color: #ffebee;
  color: #e53935;
}

.actions-cell {
  display: flex;
  gap: 0.5rem;
}

.view-btn, .edit-btn {
  background: none;
  border: 1px solid #ddd;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.8rem;
  display: flex;
  align-items: center;
}

.view-btn {
  color: #0066cc;
}

.edit-btn {
  color: #43a047;
}

.view-btn i, .edit-btn i {
  margin-right: 0.25rem;
}

.modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  width: 95%;
  max-width: 600px;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.order-modal, .view-order-modal {
  max-width: 700px;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  border-bottom: 1px solid #f0f0f0;
}

.modal-header h3 {
  margin: 0;
  font-size: 1.2rem;
  color: #333;
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.5rem;
  line-height: 1;
  color: #999;
  cursor: pointer;
}

.modal-body {
  padding: 1rem;
  overflow-y: auto;
}

.form-group {
  margin-bottom: 1rem;
}

label {
  display: block;
  margin-bottom: 0.25rem;
  font-weight: 500;
  color: #555;
}

input[type="text"],
input[type="number"],
select,
textarea {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 0.9rem;
}

.order-items {
  margin-bottom: 1.5rem;
}

.order-item {
  margin-bottom: 0.5rem;
  background-color: #f9f9f9;
  padding: 0.75rem;
  border-radius: 4px;
}

.item-row {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}

.item-select {
  flex: 3;
}

.item-quantity {
  flex: 1;
}

.item-remove {
  flex: 0 0 auto;
}

.remove-item-btn {
  background: none;
  border: none;
  color: #e53935;
  cursor: pointer;
  font-size: 1rem;
}

.add-item-btn {
  width: 100%;
  padding: 0.5rem;
  background-color: #f0f0f0;
  border: 1px dashed #ccc;
  border-radius: 4px;
  color: #666;
  cursor: pointer;
  margin-top: 0.5rem;
}

.order-summary {
  margin: 1.5rem 0;
  padding: 1rem;
  background-color: #f9f9f9;
  border-radius: 4px;
}

.summary-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 0.5rem;
}

.summary-row:last-child {
  margin-bottom: 0;
  font-weight: bold;
  font-size: 1.1rem;
  border-top: 1px solid #ddd;
  padding-top: 0.5rem;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  margin-top: 1.5rem;
}

.cancel-btn, .save-btn {
  padding: 0.5rem 1rem;
  border-radius: 4px;
  font-size: 0.9rem;
  cursor: pointer;
}

.cancel-btn {
  background-color: white;
  border: 1px solid #ddd;
  color: #666;
}

.save-btn {
  background-color: #0066cc;
  border: none;
  color: white;
}

.save-btn:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}

.error-message {
  margin-top: 1rem;
  padding: 0.5rem;
  background-color: #ffebee;
  color: #c62828;
  border-radius: 4px;
  font-size: 0.9rem;
}

.order-details {
  margin-bottom: 1.5rem;
}

.detail-row {
  display: flex;
  margin-bottom: 0.5rem;
}

.detail-row strong {
  width: 100px;
  font-weight: 600;
  color: #555;
}

.order-items-table {
  margin-top: 1rem;
  width: 100%;
  border-collapse: collapse;
}

.order-items-table th,
.order-items-table td {
  padding: 0.5rem;
  text-align: left;
  border-bottom: 1px solid #f0f0f0;
}

.order-items-table th {
  background-color: #f9f9f9;
  font-weight: 600;
  color: #555;
}

.total-label {
  text-align: right;
  font-weight: bold;
}

.total-value {
  font-weight: bold;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  padding: 1rem;
  border-top: 1px solid #f0f0f0;
}

.import-instructions {
  margin-bottom: 1rem;
}

.file-upload {
  margin-bottom: 1rem;
}

.file-input {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
}
<<<<<<< HEAD

.view-header {
  background: #e3f2fd;
  border-bottom: 1px solid #b3e5fc;
}
.view-header h3 {
  color: #1976d2;
  font-weight: bold;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}
.view-body {
  background: #f7fbff;
}
.view-details {
  background: #f1f8e9;
  border-radius: 6px;
  padding: 1rem;
  margin-bottom: 1rem;
  border: 1px solid #c8e6c9;
}
.detail-row {
  display: flex;
  align-items: center;
  margin-bottom: 0.5rem;
}
.detail-row strong {
  width: 140px;
  font-weight: 600;
  color: #388e3c;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}
.detail-value {
  font-size: 1.05rem;
  color: #333;
}
.section-divider {
  border: none;
  border-top: 1px solid #bdbdbd;
  margin: 1.5rem 0 1rem 0;
}
.section-title {
  color: #1976d2;
  font-weight: 600;
  margin-bottom: 0.5rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}
=======
>>>>>>> 81b584e837377ff81d30f83eefd8cd3b44eb81ba
</style> 