<template>
  <div class="product-management">
    <div class="page-header">
      <h2>Product Management</h2>
      <button class="add-btn" @click="openAddProductModal">
        <i class="fas fa-plus"></i> Add Product
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
            <th>Price</th>
            <th>Stock</th>
            <th>Description</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="product in filteredProducts" :key="product.id" :class="{ 'low-stock': isLowStock(product) }" @click="viewProduct(product)" @mouseenter="highlightRow(product)" @mouseleave="unhighlightRow(product)">
            <td class="product-cell">
              <div class="product-image">
                <img v-if="product.image_url" :src="getImageUrl(product.image_url)" :alt="product.name">
                <div v-else class="no-image">No Image</div>
              </div>
              <div>
                {{ product.name }}
                <span v-if="product.category === 'Uniform' && product.size" class="size-indicator">
                  Size: {{ product.size }}
                </span>
              </div>
            </td>
            <td>
              <span :class="'category-badge ' + product.category.toLowerCase()">
                {{ product.category }}
              </span>
            </td>
            <td>₱{{ product.price }}</td>
            <td :class="{ 'low-stock': isLowStock(product) }">
              {{ product.stock }}
              <span v-if="isLowStock(product)" class="stock-warning">
                Low stock: {{ product.stock }} units (min: {{ product.min_stock }})
              </span>
            </td>
            <td>{{ product.description }}</td>
            <td class="actions-cell">
              <button class="view-btn" @click="viewProduct(product); $event.stopPropagation()">
                <i class="fas fa-eye"></i>
              </button>
              <button class="edit-btn" @click="editProduct(product); $event.stopPropagation()">
                <i class="fas fa-edit"></i>
              </button>
              <button class="delete-btn" @click="confirmDelete(product); $event.stopPropagation()">
                <i class="fas fa-trash"></i>
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    
    <!-- Product Modal (Add/Edit) -->
    <div class="modal" v-if="showProductModal">
      <div class="modal-content product-form-modal">
        <div class="modal-header">
          <h3>{{ isEditing ? 'Edit Product' : 'New Product' }}</h3>
          <button class="close-btn" @click="closeProductModal">&times;</button>
        </div>
        <div class="modal-body">
          <form @submit.prevent="confirmSaveProduct" class="product-form">
            <div class="form-layout">
              <div class="image-section">
                <div class="image-upload-container" @click="uploadImage">
                  <div class="preview-container">
                    <img v-if="imagePreview" :src="imagePreview" alt="Product Preview" class="image-preview">
                    <div v-else class="upload-placeholder">
                      <div class="upload-text">
                        Drag image here<br>or<br>
                        <span class="browse-link">Browse image</span>
                      </div>
                    </div>
                  </div>
                  <input type="file" id="image" @change="handleImageChange" accept="image/*" ref="fileInput" class="hidden-file-input">
                </div>
              </div>
              
              <div class="form-fields">
                <div class="form-group">
                  <label for="name">Product Name</label>
                  <input type="text" id="name" v-model="productForm.name" required placeholder="Enter product name">
                </div>
                
                <div class="form-group">
                  <label for="category">Category</label>
                  <select id="category" v-model="productForm.category" required placeholder="Select product category">
                    <option value="" disabled selected>Select product category</option>
                    <option value="Uniform">Uniform</option>
                    <option value="Books">Books</option>
                    <option value="Other">Other</option>
                  </select>
                </div>
                
                <!-- Size field for Uniform category -->
                <div class="form-group" v-if="productForm.category === 'Uniform'">
                  <label for="size">Size</label>
                  <select id="size" v-model="productForm.size" placeholder="Select size">
                    <option value="">Not Specified</option>
                    <option value="XS">Extra Small (XS)</option>
                    <option value="S">Small (S)</option>
                    <option value="M">Medium (M)</option>
                    <option value="L">Large (L)</option>
                    <option value="XL">Extra Large (XL)</option>
                    <option value="XXL">Double XL (XXL)</option>
                  </select>
                </div>
                
                <div class="form-group">
                  <label for="cost_price">Buying Price (₱)</label>
                  <input type="number" id="cost_price" v-model="productForm.cost_price" step="0.01" min="0" required placeholder="Enter buying price">
                </div>
                
                <div class="form-group">
                  <label for="price">Selling Price (₱)</label>
                  <input type="number" id="price" v-model="productForm.price" step="0.01" min="0" required placeholder="Enter selling price">
                </div>
                
                <div class="form-group">
                  <label for="stock">Quantity</label>
                  <input type="number" id="stock" v-model="productForm.stock" min="0" required disabled placeholder="Enter product quantity">
                  <small class="form-hint">Stock can only be adjusted in Stock Management</small>
                </div>
                
                <div class="form-group">
                  <label for="min_stock">Threshold Value</label>
                  <input type="number" id="min_stock" v-model="productForm.min_stock" min="0" placeholder="Enter threshold value">
                </div>
                
                <div class="form-group">
                  <label for="description">Description</label>
                  <textarea id="description" v-model="productForm.description" rows="3" placeholder="Enter product description"></textarea>
                </div>
              </div>
            </div>
            
            <div class="form-actions">
              <button type="button" class="cancel-btn" @click="closeProductModal">Discard</button>
              <button type="submit" class="save-btn" :disabled="isLoading">
                {{ isLoading ? 'Saving...' : (isEditing ? 'Save Changes' : 'Add Product') }}
              </button>
            </div>
            
            <div v-if="error" class="error-message">{{ error }}</div>
            <div v-if="successMessage" class="success-message">{{ successMessage }}</div>
          </form>
        </div>
      </div>
    </div>
    
    <!-- Confirmation Modal -->
    <div class="modal" v-if="showConfirmationModal">
      <div class="modal-content confirmation-modal">
        <div class="modal-header">
          <h3>Confirm Changes</h3>
          <button class="close-btn" @click="closeConfirmationModal">&times;</button>
        </div>
        <div class="modal-body">
          <p>Are you sure you want to {{ isEditing ? 'update' : 'add' }} this product?</p>
          
          <div class="confirmation-details">
            <p><strong>Product:</strong> {{ productForm.name }}</p>
            <p><strong>Category:</strong> {{ productForm.category }}</p>
            <p v-if="productForm.category === 'Uniform' && productForm.size"><strong>Size:</strong> {{ productForm.size }}</p>
            <p><strong>Selling Price:</strong> ₱{{ productForm.price }}</p>
          </div>
          
          <div class="form-actions">
            <button class="cancel-btn" @click="closeConfirmationModal">Cancel</button>
            <button class="confirm-btn" @click="saveProduct" :disabled="isLoading">
              {{ isLoading ? 'Saving...' : 'Confirm' }}
            </button>
          </div>
        </div>
      </div>
    </div>
    
    <!-- View Product Modal -->
    <div class="modal" v-if="showViewModal">
      <div class="modal-content view-modal-content">
        <div class="modal-header view-modal-header">
          <h3>{{ productToView.name }}</h3>
          <button class="close-btn" @click="closeViewModal">×</button>
        </div>
        <div class="modal-body product-details-view">
          <div class="product-view-info">
            <h4 class="section-title">Primary Details</h4>
            
            <div class="detail-row">
              <div class="detail-label">Product name</div>
              <div class="detail-value">{{ productToView.name }}</div>
            </div>
            
            <div class="detail-row">
              <div class="detail-label">Product category</div>
              <div class="detail-value">
                <span :class="'category-badge ' + productToView.category?.toLowerCase()">
                  {{ productToView.category }}
                </span>
              </div>
            </div>
            
            <div class="detail-row" v-if="productToView.category === 'Uniform' && productToView.size">
              <div class="detail-label">Size</div>
              <div class="detail-value">{{ productToView.size }}</div>
            </div>
            
            <div class="detail-row">
              <div class="detail-label">Selling Price</div>
              <div class="detail-value">₱ {{ productToView.price }}</div>
            </div>
            
            <div class="detail-row">
              <div class="detail-label">Cost Price</div>
              <div class="detail-value">₱ {{ productToView.cost_price }}</div>
            </div>
            
            <div class="detail-row">
              <div class="detail-label">Current Stock</div>
              <div class="detail-value" :class="{ 'low-stock': isLowStock(productToView) }">
                {{ productToView.stock }}
              </div>
            </div>
            
            <div class="detail-row">
              <div class="detail-label">Minimum Stock</div>
              <div class="detail-value">{{ productToView.min_stock }}</div>
            </div>
          </div>
          
          <div class="product-view-image-container">
            <div class="product-view-image">
              <img v-if="productToView.image_url" :src="getImageUrl(productToView.image_url)" alt="Product Image">
              <div v-else class="no-image-view">No Image Available</div>
            </div>
            
            <div class="description-section">
              <h4 class="section-title">Description</h4>
              <p class="product-description">{{ productToView.description || 'No description available' }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Delete Confirmation Modal -->
    <div class="modal" v-if="showDeleteModal">
      <div class="modal-content confirmation-modal">
        <div class="modal-header">
          <h3>Confirm Delete</h3>
          <button class="close-btn" @click="showDeleteModal = false">&times;</button>
        </div>
        <div class="modal-body">
          <p>Are you sure you want to delete <strong>{{ productToDelete?.name }}</strong>?</p>
          <p class="warning">This action cannot be undone.</p>
          
          <div class="form-actions">
            <button class="cancel-btn" @click="showDeleteModal = false">Cancel</button>
            <button class="confirm-btn delete" @click="deleteProduct" :disabled="isLoading">
              {{ isLoading ? 'Deleting...' : 'Delete Product' }}
            </button>
          </div>
          
          <div v-if="error" class="error-message">{{ error }}</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ProductManagement',
  data() {
    return {
      products: [],
      filteredProducts: [],
      searchQuery: '',
      selectedCategory: 'all',
      showProductModal: false,
      showDeleteModal: false,
      showViewModal: false,
      showConfirmationModal: false,
      isEditing: false,
      productForm: {
        id: null,
        name: '',
        category: 'Uniform',
        price: 0,
        cost_price: 0,
        stock: 0,
        min_stock: null,
        description: '',
        image_url: null,
        size: ''
      },
      productToDelete: null,
      productToView: null,
      isLoading: false,
      error: null,
      successMessage: null,
      imageFile: null,
      imagePreview: null,
      imageFileName: '',
      highlightedRow: null
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
        this.error = 'Failed to load products. Please try again.';
      }
    },
    
    filterProducts() {
      let filtered = [...this.products];
      
      // Apply search filter
      if (this.searchQuery) {
        const query = this.searchQuery.toLowerCase();
        filtered = filtered.filter(product => 
          product.name.toLowerCase().includes(query) ||
          product.description?.toLowerCase().includes(query)
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
    
    openAddProductModal() {
      this.isEditing = false;
      this.resetForm();
      this.showProductModal = true;
    },
    
    editProduct(product) {
      this.isEditing = true;
      this.resetForm();
      
      // Copy product data to form
      this.productForm = {
        id: product.id,
        name: product.name,
        category: product.category,
        price: product.price,
        cost_price: product.cost_price,
        stock: product.stock,
        min_stock: product.min_stock,
        description: product.description,
        image_url: product.image_url,
        size: product.size
      };
      
      // Set image preview if available
      if (product.image_url) {
        this.imagePreview = this.getImageUrl(product.image_url);
      }
      
      this.showProductModal = true;
    },
    
    viewProduct(product) {
      this.productToView = product;
      this.showViewModal = true;
    },
    
    confirmDelete(product) {
      this.productToDelete = product;
      this.showDeleteModal = true;
    },
    
    resetForm() {
      this.productForm = {
        id: null,
        name: '',
        category: 'Uniform',
        price: 0,
        cost_price: 0,
        stock: 0,
        min_stock: null,
        description: '',
        image_url: null,
        size: ''
      };
      this.imageFile = null;
      this.imagePreview = null;
      this.imageFileName = '';
      this.error = null;
      this.successMessage = null;
      
      // Reset file input if exists
      if (this.$refs.fileInput) {
        this.$refs.fileInput.value = '';
      }
    },
    
    handleImageChange(event) {
      const file = event.target.files[0];
      if (!file) {
        this.imageFile = null;
        this.imagePreview = null;
        this.imageFileName = '';
        return;
      }
      
      // Validate file type
      if (!file.type.startsWith('image/')) {
        this.error = 'Please select an image file';
        this.imageFile = null;
        this.imagePreview = null;
        this.imageFileName = '';
        return;
      }
      
      // Update state
      this.imageFile = file;
      this.imageFileName = file.name;
      
      // Create preview
      const reader = new FileReader();
      reader.onload = (e) => {
        this.imagePreview = e.target.result;
      };
      reader.readAsDataURL(file);
    },
    
    async saveProduct() {
      this.isLoading = true;
      this.error = null;
      this.successMessage = null;
      
      try {
        const formData = new FormData();
        
        // Add form fields
        formData.append('name', this.productForm.name);
        formData.append('category', this.productForm.category);
        formData.append('price', this.productForm.price);
        formData.append('cost_price', this.productForm.cost_price);
        formData.append('stock', this.productForm.stock);
        
        if (this.productForm.min_stock !== null && this.productForm.min_stock !== '') {
          formData.append('min_stock', this.productForm.min_stock);
        }
        
        if (this.productForm.description) {
          formData.append('description', this.productForm.description);
        }

        // Add size if it's provided (especially for Uniform items)
        if (this.productForm.size) {
          formData.append('size', this.productForm.size);
        }
        
        // Add image if selected
        if (this.imageFile) {
          formData.append('image', this.imageFile);
        }
        
        let response;
        
        if (this.isEditing) {
          // Update existing product
          response = await fetch(`http://localhost:8000/admin/products/${this.productForm.id}`, {
            method: 'PUT',
            body: formData
          });
        } else {
          // Create new product
          response = await fetch('http://localhost:8000/admin/products', {
            method: 'POST',
            body: formData
          });
        }
        
        const data = await response.json();
        
        if (!response.ok) {
          throw new Error(data.detail || 'Failed to save product');
        }
        
        // Update product list
        await this.loadProducts();
        
        // Show success message
        this.successMessage = `Product ${this.isEditing ? 'updated' : 'created'} successfully!`;
        
        // Close confirmation modal immediately
        this.closeConfirmationModal();
        
        // Close product modal after delay
        setTimeout(() => {
          this.closeProductModal();
        }, 500);
      } catch (error) {
        this.error = error.message || 'Failed to save product. Please try again.';
      } finally {
        this.isLoading = false;
      }
    },
    
    async deleteProduct() {
      if (!this.productToDelete) return;
      
      this.isLoading = true;
      this.error = null;
      
      try {
        const response = await fetch(`http://localhost:8000/admin/products/${this.productToDelete.id}`, {
          method: 'DELETE'
        });
        
        if (!response.ok) {
          const data = await response.json();
          throw new Error(data.detail || 'Failed to delete product');
        }
        
        // Update product list
        await this.loadProducts();
        
        // Close modal
        this.showDeleteModal = false;
        this.productToDelete = null;
      } catch (error) {
        this.error = error.message || 'Failed to delete product. Please try again.';
      } finally {
        this.isLoading = false;
      }
    },
    
    closeProductModal() {
      this.showProductModal = false;
      this.resetForm();
    },
    
    getImageUrl(imageName) {
      return `http://localhost:8000/uploads/${imageName}`;
    },
    
    isLowStock(product) {
      return product.min_stock !== null && product.stock <= product.min_stock;
    },
    
    editFromView(product) {
      this.isEditing = true;
      this.resetForm();
      
      // Copy product data to form
      this.productForm = {
        id: product.id,
        name: product.name,
        category: product.category,
        price: product.price,
        cost_price: product.cost_price,
        stock: product.stock,
        min_stock: product.min_stock,
        description: product.description,
        image_url: product.image_url,
        size: product.size
      };
      
      // Set image preview if available
      if (product.image_url) {
        this.imagePreview = this.getImageUrl(product.image_url);
      }
      
      this.showProductModal = true;
    },
    
    closeViewModal() {
      this.showViewModal = false;
      this.productToView = null;
    },
    
    confirmSaveProduct() {
      this.showConfirmationModal = true;
    },
    
    closeConfirmationModal() {
      this.showConfirmationModal = false;
    },
    
    uploadImage() {
      if (this.$refs.fileInput) {
        this.$refs.fileInput.click();
      }
    },
    
    highlightRow(product) {
      this.highlightedRow = product;
    },
    
    unhighlightRow(product) {
      this.highlightedRow = null;
    }
  }
};
</script>

<style scoped>
.product-management {
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
  transition: background 0.2s, color 0.2s, box-shadow 0.2s;
}

.add-btn i {
  margin-right: 0.5rem;
}

.add-btn:hover {
  background-color: #ff4b7d;
  color: #fff;
  box-shadow: 0 2px 8px rgba(255, 20, 147, 0.13);
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

/* Table styles */
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
  transition: background 0.2s;
}

tr:last-child {
  border-bottom: none;
}

tr:hover {
  background-color: #fff5f7;
}

.product-cell {
  display: flex;
  align-items: center;
}

.product-image {
  width: 40px;
  height: 40px;
  margin-right: 0.75rem;
  background-color: #f9f9f9;
  border-radius: 4px;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
}

.product-image img {
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
}

.no-image {
  font-size: 0.7rem;
  color: #999;
  text-align: center;
}

/* Category badges */
.category-badge {
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

/* Stock styling */
.low-stock {
  color: #e53935;
  position: relative;
}

.stock-warning {
  position: absolute;
  top: 100%;
  left: 0;
  background-color: #ffebee;
  color: #c62828;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.8rem;
  white-space: nowrap;
  display: none;
  z-index: 10;
}

.low-stock:hover .stock-warning {
  display: block;
}

/* Action buttons */
.actions-cell {
  display: flex;
  gap: 0.5rem;
}

.view-btn, .edit-btn, .delete-btn {
  width: 32px;
  height: 32px;
  border-radius: 4px;
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.2s, color 0.2s, box-shadow 0.2s;
}

.view-btn {
  background-color: #e3f2fd;
  color: #1565c0;
}

.view-btn:hover {
  background-color: #bbdefb;
  color: #1565c0;
}

.edit-btn {
  background-color: #e8f5e9;
  color: #2e7d32;
}

.edit-btn:hover {
  background-color: #c8e6c9;
  color: #2e7d32;
}

.delete-btn {
  background-color: #ffebee;
  color: #c62828;
}

.delete-btn:hover {
  background-color: #ffcdd2;
  color: #c62828;
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
  max-width: 600px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
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

/* Product Form Styles */
.product-form-modal {
  max-width: 700px;
  border-radius: 8px;
  overflow: hidden;
}

.form-layout {
  display: flex;
  gap: 2rem;
  margin-bottom: 1.5rem;
}

.image-section {
  flex: 0 0 200px;
}

.form-fields {
  flex: 1;
}

.form-group {
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
  padding: 0.75rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 0.95rem;
  color: #333;
  background-color: white;
}

input::placeholder, select::placeholder, textarea::placeholder {
  color: #aaa;
}

textarea {
  resize: vertical;
}

.form-hint {
  display: block;
  font-size: 0.75rem;
  color: #777;
  margin-top: 0.25rem;
}

/* Image upload */
.image-upload-container {
  width: 100%;
  height: 200px;
  border: 1px dashed #ccc;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: background-color 0.2s;
}

.image-upload-container:hover {
  background-color: #f9f9f9;
}

.preview-container {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.image-preview {
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
}

.upload-placeholder {
  color: #999;
  text-align: center;
  padding: 1rem;
}

.upload-text {
  font-size: 0.9rem;
  text-align: center;
  line-height: 1.6;
}

.browse-link {
  color: #0066cc;
  font-weight: 500;
}

.hidden-file-input {
  display: none;
}

/* Form actions */
.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  margin-top: 1.5rem;
}

.cancel-btn, .save-btn, .confirm-btn {
  padding: 0.5rem 1rem;
  border-radius: 4px;
  border: none;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.2s, color 0.2s, box-shadow 0.2s;
}

.cancel-btn {
  background-color: #f0f0f0;
  color: #333;
}

.save-btn, .confirm-btn {
  background-color: #0066cc;
  color: white;
}

.save-btn:hover, .confirm-btn:hover {
  background-color: #ff4b7d;
  color: #fff;
}

.confirm-btn.delete {
  background-color: #e53935;
}

/* Messages */
.error-message {
  margin-top: 1rem;
  color: #e53935;
  background-color: #ffebee;
  padding: 0.5rem;
  border-radius: 4px;
}

.success-message {
  margin-top: 1rem;
  color: #2e7d32;
  background-color: #e8f5e9;
  padding: 0.5rem;
  border-radius: 4px;
}

.warning {
  color: #e53935;
  font-style: italic;
}

/* View product modal */
.view-modal-content {
  max-width: 700px;
}

.view-modal-header {
  background-color: white;
  border-bottom: 1px solid #eee;
}

.view-modal-header h3 {
  font-size: 1.4rem;
  font-weight: 600;
}

.product-details-view {
  display: flex;
  gap: 2rem;
  padding: 0;
}

.product-view-info {
  flex: 1;
  padding: 1.5rem;
}

.section-title {
  font-size: 1.1rem;
  font-weight: 600;
  color: #333;
  margin-bottom: 1.25rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid #eee;
}

.detail-row {
  margin-bottom: 1rem;
  display: flex;
  flex-direction: column;
  border-bottom: none;
  padding-bottom: 0;
}

.detail-label {
  font-weight: 400;
  color: #666;
  font-size: 0.9rem;
  margin-bottom: 0.25rem;
  width: auto;
}

.detail-value {
  font-weight: 500;
  color: #333;
  font-size: 1rem;
}

.product-view-image-container {
  flex: 1;
  padding: 1.5rem 1.5rem 1.5rem 0;
  display: flex;
  flex-direction: column;
}

.product-view-image {
  width: 100%;
  height: 200px;
  border: 1px dashed #ddd;
  border-radius: 4px;
  overflow: hidden;
  margin-bottom: 1.5rem;
  display: flex;
  align-items: center;
  justify-content: center;
}

.product-view-image img {
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
}

.no-image-view {
  color: #999;
  text-align: center;
  font-size: 0.9rem;
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #f9f9f9;
}

.description-section {
  margin-top: 1rem;
}

.product-description {
  color: #666;
  font-size: 0.95rem;
  white-space: pre-wrap;
  margin-top: 0.5rem;
  line-height: 1.5;
}

/* Confirmation modal */
.confirmation-modal {
  max-width: 400px;
}

.confirmation-details {
  background-color: #f9f9f9;
  padding: 1rem;
  border-radius: 4px;
  margin: 1rem 0;
}

.confirmation-details p {
  margin: 0.5rem 0;
  font-size: 0.95rem;
}

.confirmation-details strong {
  font-weight: 600;
}

.size-indicator {
  font-size: 0.8rem;
  color: #666;
  margin-left: 0.5rem;
}
</style> 