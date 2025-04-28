<template>
  <div class="stock-management">
    <div class="page-header">
      <h2>Stock Management</h2>
      <button class="add-btn" @click="openStockAdjustmentModal('', 'add')">
        <i class="fas fa-plus"></i> Stock Adjustment
      </button>
    </div>
    
    <div class="search-filter-bar">
      <div class="search-box">
        <input type="text" v-model="searchQuery" placeholder="Search products..." @input="filterProducts">
      </div>
      <div class="category-filter">
        <select v-model="selectedCategory" @change="filterProducts">
          <option value="all">All Categories</option>
          <option value="uniform">Uniform</option>
          <option value="books">Books</option>
          <option value="other">Other</option>
        </select>
      </div>
    </div>
    
    <div class="products-table">
      <table>
        <thead>
          <tr>
            <th>Product</th>
            <th>Category</th>
            <th>Current Stock</th>
            <th>Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="product in filteredProducts" :key="product.id" :class="{'selected': selectedProduct === product}" @click="selectProduct(product)">
            <td>{{ product.name }}</td>
            <td>
              <span :class="'category-badge ' + product.category.toLowerCase()">
                {{ product.category }}
              </span>
            </td>
            <td>{{ product.stock }}</td>
            <td>
              <span :class="getStockStatusClass(product)">
                {{ getStockStatus(product) }}
              </span>
            </td>
            <td class="actions-cell">
              <button class="history-btn" @click="viewStockHistory(product)" title="View Stock History">
                <i class="fas fa-history"></i> History
              </button>
              <button class="adjust-btn" @click="openStockAdjustmentModal(product)" title="Adjust Stock">
                <i class="fas fa-edit"></i> Adjust
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    
    <!-- Stock Adjustment Modal -->
    <div class="modal" v-if="showAdjustmentModal">
      <div class="modal-content">
        <div class="modal-header">
          <h3>Stock Adjustment</h3>
          <button class="close-btn" @click="closeAdjustmentModal">&times;</button>
        </div>
        <div class="modal-body">
          <form @submit.prevent="saveStockAdjustment" class="adjustment-form">
            <div class="form-group">
              <label for="product">Product</label>
              <select id="product" v-model="adjustment.productId" required>
                <option v-for="product in products" :key="product.id" :value="product.id">
                  {{ product.name }}
                </option>
              </select>
            </div>
            
            <div class="form-group">
              <label for="adjustmentType">Type</label>
              <select id="adjustmentType" v-model="adjustment.type" required @change="handleTypeChange">
                <option value="add">Add Stock</option>
                <option value="remove">Remove Stock</option>
              </select>
            </div>
            
            <div class="form-group">
              <label for="quantity">Quantity</label>
              <input 
                type="number" 
                id="quantity" 
                v-model="adjustment.quantity" 
                min="1" 
                required
              >
            </div>
            
            <div class="form-group">
              <label for="reason">Reason</label>
              <select id="reason" v-model="adjustment.reason" required>
                <option value="">Select reason</option>
                <template v-if="adjustment.type === 'add'">
                  <option value="purchase">New Purchase</option>
                  <option value="return">Customer Return</option>
                  <option value="inventory">Inventory Correction</option>
                  <option value="other">Other</option>
                </template>
                <template v-else-if="adjustment.type === 'remove'">
                  <option value="sale">Sale</option>
                  <option value="damage">Damaged Items</option>
                  <option value="inventory">Inventory Correction</option>
                  <option value="other">Other</option>
                </template>
              </select>
            </div>
            
            <div class="form-group">
              <label for="notes">Notes</label>
              <textarea 
                id="notes" 
                v-model="adjustment.notes" 
                rows="3" 
                placeholder="Additional notes (optional)"
              ></textarea>
            </div>
            
            <div class="form-actions">
              <button type="button" class="cancel-btn" @click="closeAdjustmentModal">Cancel</button>
              <button type="submit" class="save-btn" :disabled="isLoading">
                {{ isLoading ? 'Saving...' : 'Save' }}
              </button>
            </div>
            
            <div class="notification-hint">
              <i class="fas fa-bell"></i>
              <span>Students subscribed to this product will be notified of stock changes.</span>
            </div>
            
            <div v-if="error" class="error-message">{{ error }}</div>
          </form>
        </div>
      </div>
    </div>
    
    <!-- Stock History Modal -->
    <div class="modal" v-if="showHistoryModal">
      <div class="modal-content history-modal">
        <div class="modal-header">
          <h3>Stock History: {{ selectedProduct?.name }}</h3>
          <button class="close-btn" @click="closeHistoryModal">&times;</button>
        </div>
        <div class="modal-body">
          <div v-if="isLoadingHistory" class="loading-container">
            <div class="loading-spinner"></div>
            <p>Loading history...</p>
          </div>
          
          <div v-else-if="stockHistory.length === 0" class="no-history">
            <p>No stock adjustments found for this product.</p>
          </div>
          
          <div v-else class="history-list">
            <div class="history-item" v-for="(item, index) in stockHistory" :key="index">
              <div class="history-header">
                <span class="history-date">{{ formatDate(item.created_at) }}</span>
                <span class="history-type" :class="getAdjustmentTypeClass(item.type)">
                  {{ getAdjustmentTypeLabel(item.type) }}
                </span>
              </div>
              <div class="history-details">
                <div class="history-quantity">
                  <strong>Quantity:</strong> 
                  <span>{{ item.quantity }}</span>
                </div>
                <div class="history-reason">
                  <strong>Reason:</strong> 
                  <span>{{ getReasonLabel(item.reason) }}</span>
                </div>
                <div class="history-user">
                  <strong>User:</strong> 
                  <span>Admin</span>
                </div>
                <div v-if="item.notes" class="history-notes">
                  <strong>Notes:</strong> 
                  <span>{{ item.notes }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Confirmation Modal -->
    <div class="modal" v-if="showConfirmationModal">
      <div class="modal-content confirmation-modal">
        <div class="modal-header">
          <h3>Confirm Stock Adjustment</h3>
          <button class="close-btn" @click="closeConfirmationModal">&times;</button>
        </div>
        <div class="modal-body">
          <div class="confirmation-details">
            <p class="confirmation-message">Are you sure you want to make the following adjustment?</p>
            
            <div class="confirmation-info">
              <div class="info-row">
                <span class="info-label">Product:</span>
                <span class="info-value">{{ getProductName(adjustment.productId) }}</span>
              </div>
              <div class="info-row">
                <span class="info-label">Type:</span>
                <span class="info-value" :class="adjustment.type === 'add' ? 'type-add' : 'type-remove'">
                  {{ adjustment.type === 'add' ? 'Add Stock' : 'Remove Stock' }}
                </span>
              </div>
              <div class="info-row">
                <span class="info-label">Quantity:</span>
                <span class="info-value">{{ adjustment.quantity }}</span>
              </div>
              <div class="info-row">
                <span class="info-label">Reason:</span>
                <span class="info-value">{{ getReasonLabel(adjustment.reason) }}</span>
              </div>
              <div class="info-row" v-if="adjustment.notes">
                <span class="info-label">Notes:</span>
                <span class="info-value">{{ adjustment.notes }}</span>
              </div>
            </div>
          </div>
          
          <div class="confirmation-actions">
            <button class="cancel-btn" @click="closeConfirmationModal">Cancel</button>
            <button class="confirm-btn" @click="proceedWithSave" :disabled="isLoading">
              {{ isLoading ? 'Saving...' : 'Confirm' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'StockManagement',
  data() {
    return {
      products: [],
      filteredProducts: [],
      searchQuery: '',
      selectedCategory: 'all',
      showAdjustmentModal: false,
      showHistoryModal: false,
      selectedProduct: null,
      adjustment: {
        productId: '',
        type: 'add',
        quantity: 1,
        reason: '',
        notes: ''
      },
      stockHistory: [],
      isLoading: false,
      isLoadingHistory: false,
      error: null,
      showConfirmationModal: false
    };
  },
  created() {
    this.loadProducts();
  },
  methods: {
    async loadProducts() {
      try {
        const response = await fetch('http://localhost:8000/products');
        const data = await response.json();
        
        if (response.ok) {
          this.products = data.products;
          this.filterProducts();
        }
      } catch (error) {
        console.error('Error loading products:', error);
      }
    },
    
    filterProducts() {
      let filtered = [...this.products];
      
      // Apply search filter
      if (this.searchQuery) {
        const query = this.searchQuery.toLowerCase();
        filtered = filtered.filter(product => 
          product.name.toLowerCase().includes(query)
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
    
    getStockStatus(product) {
      if (!product.min_stock) {
        return product.stock > 0 ? 'In Stock' : 'Out of Stock';
      }
      
      if (product.stock <= 0) {
        return 'Out of Stock';
      } else if (product.stock <= product.min_stock) {
        return 'Low Stock';
      } else {
        return 'In Stock';
      }
    },
    
    getStockStatusClass(product) {
      if (!product.min_stock) {
        return product.stock > 0 ? 'in-stock' : 'out-of-stock';
      }
      
      if (product.stock <= 0) {
        return 'out-of-stock';
      } else if (product.stock <= product.min_stock) {
        return 'low-stock';
      } else {
        return 'in-stock';
      }
    },
    
    handleTypeChange() {
      // Reset reason when type changes
      this.adjustment.reason = '';
    },
    
    openStockAdjustmentModal(product, type = 'add') {
      this.selectedProduct = product;
      
      // Reset form
      this.adjustment = {
        productId: product ? product.id : '',
        type: type || 'add',
        quantity: 1,
        reason: '',
        notes: ''
      };
      
      this.error = null;
      this.showAdjustmentModal = true;
    },
    
    closeAdjustmentModal() {
      this.showAdjustmentModal = false;
      this.selectedProduct = null;
    },
    
    async saveStockAdjustment() {
      // Show confirmation modal instead of saving directly
      this.showConfirmationModal = true;
    },
    
    closeConfirmationModal() {
      this.showConfirmationModal = false;
    },
    
    getProductName(productId) {
      const product = this.products.find(p => p.id === productId);
      return product ? product.name : '';
    },
    
    async proceedWithSave() {
      this.isLoading = true;
      this.error = null;
      
      try {
        const adjustmentData = {
          product_id: parseInt(this.adjustment.productId),
          type: this.adjustment.type,
          quantity: parseInt(this.adjustment.quantity),
          reason: this.adjustment.reason,
          notes: this.adjustment.notes || null
        };
        
        const response = await fetch('http://localhost:8000/admin/stock/adjust', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(adjustmentData)
        });
        
        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(errorData.detail || 'Failed to adjust stock');
        }
        
        // Update products list
        await this.loadProducts();
        this.closeConfirmationModal();
        this.closeAdjustmentModal();
      } catch (error) {
        this.error = error.message || 'Failed to adjust stock. Please try again.';
        console.error('Stock adjustment error:', error);
      } finally {
        this.isLoading = false;
      }
    },
    
    async viewStockHistory(product) {
      this.selectedProduct = product;
      this.showHistoryModal = true;
      this.isLoadingHistory = true;
      this.stockHistory = [];
      
      try {
        const response = await fetch(`http://localhost:8000/admin/stock/history/${product.id}`);
        const data = await response.json();
        
        if (response.ok) {
          this.stockHistory = data.history;
        } else {
          throw new Error(data.detail || 'Failed to load stock history');
        }
      } catch (error) {
        console.error('Error loading stock history:', error);
      } finally {
        this.isLoadingHistory = false;
      }
    },
    
    closeHistoryModal() {
      this.showHistoryModal = false;
      this.selectedProduct = null;
    },
    
    formatDate(dateString) {
      if (!dateString) return '';
      
      const date = new Date(dateString);
      return date.toLocaleString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    },
    
    getAdjustmentTypeLabel(type) {
      switch (type) {
        case 'add': return 'Added Stock';
        case 'remove': return 'Removed Stock';
        case 'set': return 'Stock Set';
        default: return type;
      }
    },
    
    getAdjustmentTypeClass(type) {
      switch (type) {
        case 'add': return 'type-add';
        case 'remove': return 'type-remove';
        case 'set': return 'type-set';
        default: return '';
      }
    },
    
    getReasonLabel(reason) {
      switch (reason) {
        case 'purchase': return 'New Purchase';
        case 'return': return 'Customer Return';
        case 'damage': return 'Damaged Items';
        case 'inventory': return 'Inventory Correction';
        case 'sale': return 'Sale';
        case 'other': return 'Other';
        default: return reason;
      }
    },
    
    selectProduct(product) {
      this.selectedProduct = product;
    }
  }
};
</script>

<style scoped>
.stock-management {
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

.add-btn {
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

.add-btn i {
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

.category-filter select {
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  width: 180px;
}

.products-table {
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
}

th {
  background-color: #f5f5f5;
  font-weight: 600;
  color: #333;
}

tr {
  border-bottom: 1px solid #eee;
}

tr:last-child {
  border-bottom: none;
}

tr:hover {
  background-color: #fff5f7;
  transition: background 0.2s;
}

.category-badge {
  display: inline-block;
  padding: 0.2rem 0.5rem;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 500;
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

.in-stock {
  color: #2e7d32;
  background-color: #e8f5e9;
  padding: 0.2rem 0.5rem;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 500;
}

.low-stock {
  color: #f57c00;
  background-color: #fff3e0;
  padding: 0.2rem 0.5rem;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 500;
}

.out-of-stock {
  color: #c62828;
  background-color: #ffebee;
  padding: 0.2rem 0.5rem;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 500;
}

.actions-cell {
  display: flex;
  gap: 0.5rem;
}

.history-btn, .adjust-btn {
  padding: 0.3rem 0.6rem;
  border-radius: 4px;
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  font-size: 0.8rem;
}

.history-btn {
  background-color: #e3f2fd;
  color: #1565c0;
}

.adjust-btn {
  background-color: #e8f5e9;
  color: #2e7d32;
}

.history-btn i, .adjust-btn i {
  margin-right: 0.25rem;
}

.history-btn:hover, .adjust-btn:hover {
  background-color: #bbdefb;
  color: #1565c0;
}

/* Modal styles */
.modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  max-width: 500px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
}

.history-modal {
  max-width: 600px;
  border-radius: 8px;
  overflow: hidden;
}

.modal-header {
  padding: 1rem 1.5rem;
  border-bottom: 1px solid #f0f0f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
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
  cursor: pointer;
  color: #999;
}

.modal-body {
  padding: 1.5rem;
  overflow-y: auto;
  max-height: calc(80vh - 60px); /* 60px accounts for the modal header */
}

.adjustment-form .form-group {
  margin-bottom: 1rem;
}

label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #333;
}

input, select, textarea {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 0.9rem;
}

textarea {
  resize: vertical;
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
  border: none;
  font-weight: 500;
  cursor: pointer;
}

.cancel-btn {
  background-color: #f0f0f0;
  color: #333;
}

.save-btn {
  background-color: #0066cc;
  color: white;
}

.error-message {
  margin-top: 1rem;
  color: #e53935;
  background-color: #ffebee;
  padding: 0.5rem;
  border-radius: 4px;
}

/* History Modal Styles */
.history-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.history-item {
  border: 1px solid #eee;
  border-radius: 8px;
  overflow: hidden;
}

.history-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem 1rem;
  background-color: #f5f5f5;
}

.history-date {
  font-weight: 500;
  color: #555;
  font-size: 0.9rem;
}

.history-type {
  font-size: 0.8rem;
  font-weight: 600;
  padding: 0.2rem 0.5rem;
  border-radius: 12px;
}

.type-add {
  background-color: #e8f5e9;
  color: #2e7d32;
}

.type-remove {
  background-color: #ffebee;
  color: #c62828;
}

.type-set {
  background-color: #e3f2fd;
  color: #1565c0;
}

.history-details {
  padding: 0.75rem 1rem;
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.5rem 1rem;
  font-size: 0.9rem;
}

.history-notes {
  grid-column: span 2;
  border-top: 1px solid #eee;
  padding-top: 0.5rem;
  margin-top: 0.25rem;
}

.no-history {
  text-align: center;
  padding: 2rem 0;
  color: #666;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 2rem 0;
}

.loading-spinner {
  border: 3px solid #f3f3f3;
  border-top: 3px solid #0066cc;
  border-radius: 50%;
  width: 30px;
  height: 30px;
  animation: spin 1s linear infinite;
  margin-bottom: 1rem;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.notification-hint {
  margin-top: 1rem;
  color: #666;
  background-color: #f0f0f0;
  padding: 0.5rem;
  border-radius: 4px;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.notification-hint i {
  color: #0066cc;
}

.confirmation-modal {
  max-width: 450px;
}

.confirmation-details {
  margin-bottom: 1.5rem;
}

.confirmation-message {
  font-size: 1.1rem;
  color: #333;
  margin-bottom: 1.5rem;
}

.confirmation-info {
  background-color: #f8f9fa;
  border-radius: 8px;
  padding: 1rem;
}

.info-row {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 0.75rem;
  font-size: 0.95rem;
}

.info-row:last-child {
  margin-bottom: 0;
}

.info-label {
  color: #666;
  font-weight: 500;
  min-width: 80px;
}

.info-value {
  color: #333;
  font-weight: 500;
  text-align: right;
  flex: 1;
  margin-left: 1rem;
}

.confirmation-actions {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  margin-top: 1.5rem;
}

.confirm-btn {
  background-color: #FF9DAE;
  color: white;
  border: none;
  padding: 0.5rem 1.5rem;
  border-radius: 4px;
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.2s;
}

.confirm-btn:hover {
  background-color: #ff89a0;
}

.confirm-btn:disabled {
  background-color: #ffbfc9;
  cursor: not-allowed;
}

.type-add {
  color: #2e7d32;
}

.type-remove {
  color: #c62828;
}

button, .add-btn, .view-btn, .edit-btn, .delete-btn, .save-btn, .cancel-btn, .confirm-btn, .history-btn, .adjust-btn {
  transition: background 0.2s, color 0.2s, box-shadow 0.2s;
}

.add-btn:hover {
  background-color: #ff4b7d;
  color: #fff;
  box-shadow: 0 2px 8px rgba(255, 20, 147, 0.13);
}

.view-btn:hover, .history-btn:hover {
  background-color: #bbdefb;
  color: #1565c0;
}

.edit-btn:hover, .adjust-btn:hover {
  background-color: #c8e6c9;
  color: #2e7d32;
}

.delete-btn:hover {
  background-color: #ffcdd2;
  color: #c62828;
}

.save-btn:hover, .confirm-btn:hover {
  background-color: #ff4b7d;
  color: #fff;
}

.cancel-btn:hover {
  background-color: #ffe4e1;
  color: #ff4b7d;
}
</style> 