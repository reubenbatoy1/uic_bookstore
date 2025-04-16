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
          <tr v-for="product in filteredProducts" :key="product.id">
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
              <button class="view-btn" @click="viewProduct(product)">
                <i class="fas fa-eye"></i>
              </button>
              <button class="edit-btn" @click="editProduct(product)">
                <i class="fas fa-edit"></i>
              </button>
              <button class="delete-btn" @click="confirmDelete(product)">
                <i class="fas fa-trash"></i>
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    
    <!-- Product Modal (Add/Edit) -->
    <div class="modal" v-if="showProductModal">
      <div class="modal-content">
        <div class="modal-header">
          <h3>{{ isEditing ? 'Edit Product' : 'Add New Product' }}</h3>
          <button class="close-btn" @click="closeProductModal">&times;</button>
        </div>
        <div class="modal-body">
          <form @submit.prevent="saveProduct" class="product-form">
            <div class="form-group">
              <label for="name">Product Name</label>
              <input type="text" id="name" v-model="productForm.name" required>
            </div>
            
            <div class="form-group">
              <label for="category">Category</label>
              <select id="category" v-model="productForm.category" required>
                <option value="Uniform">Uniform</option>
                <option value="Books">Books</option>
                <option value="Other">Other</option>
              </select>
            </div>
            
            <!-- Size field for Uniform category -->
            <div class="form-group" v-if="productForm.category === 'Uniform'">
              <label for="size">Size</label>
              <select id="size" v-model="productForm.size">
                <option value="">Not Specified</option>
                <option value="XS">Extra Small (XS)</option>
                <option value="S">Small (S)</option>
                <option value="M">Medium (M)</option>
                <option value="L">Large (L)</option>
                <option value="XL">Extra Large (XL)</option>
                <option value="XXL">Double XL (XXL)</option>
              </select>
            </div>
            
            <div class="form-row">
              <div class="form-group">
                <label for="price">Price (₱)</label>
                <input type="number" id="price" v-model="productForm.price" step="0.01" min="0" required>
              </div>
              
              <div class="form-group">
                <label for="stock">Stock</label>
                <input type="number" id="stock" v-model="productForm.stock" min="0" required disabled>
                <small class="form-hint">Stock can only be adjusted in Stock Management</small>
              </div>
              
              <div class="form-group">
                <label for="min_stock">Min Stock</label>
                <input type="number" id="min_stock" v-model="productForm.min_stock" min="0">
              </div>
            </div>
            
            <div class="form-group">
              <label for="description">Description</label>
              <textarea id="description" v-model="productForm.description" rows="3"></textarea>
            </div>
            
            <div class="form-group">
              <label>Product Image</label>
              <div class="image-upload">
                <div class="preview-container">
                  <img v-if="imagePreview" :src="imagePreview" alt="Product Preview" class="image-preview">
                  <div v-else class="no-preview">No image selected</div>
                </div>
                <div class="file-input-container">
                  <input type="file" id="image" @change="handleImageChange" accept="image/*" ref="fileInput">
                  <label for="image" class="file-input-label">Choose File</label>
                  <span class="file-name">{{ imageFileName || 'No file chosen' }}</span>
                </div>
              </div>
            </div>
            
            <div class="form-actions">
              <button type="button" class="cancel-btn" @click="closeProductModal">Cancel</button>
              <button type="submit" class="save-btn" :disabled="isLoading">
                {{ isLoading ? 'Saving...' : 'Save Product' }}
              </button>
            </div>
            
            <div v-if="isEditing" class="notification-hint">
              <i class="fas fa-bell"></i>
              <span>Students subscribed to this product will be notified of any changes.</span>
            </div>
            
            <div v-if="error" class="error-message">{{ error }}</div>
            <div v-if="successMessage" class="success-message">{{ successMessage }}</div>
          </form>
        </div>
      </div>
    </div>
    
    <!-- Delete Confirmation Modal -->
    <div class="modal" v-if="showDeleteModal">
      <div class="modal-content delete-modal">
        <div class="modal-header">
          <h3>Confirm Delete</h3>
          <button class="close-btn" @click="showDeleteModal = false">&times;</button>
        </div>
        <div class="modal-body">
          <p>Are you sure you want to delete <strong>{{ productToDelete?.name }}</strong>?</p>
          <p class="warning">This action cannot be undone.</p>
          
          <div class="form-actions">
            <button class="cancel-btn" @click="showDeleteModal = false">Cancel</button>
            <button class="delete-confirm-btn" @click="deleteProduct" :disabled="isLoading">
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
      isEditing: false,
      productForm: {
        id: null,
        name: '',
        category: 'Uniform',
        price: 0,
        stock: 0,
        min_stock: null,
        description: '',
        image_url: null,
        size: ''
      },
      productToDelete: null,
      isLoading: false,
      error: null,
      successMessage: null,
      imageFile: null,
      imagePreview: null,
      imageFileName: ''
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
      // Open view-only modal or navigate to product details
      this.editProduct(product); // For now, just open in edit mode
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
        
        // Close modal after delay
        setTimeout(() => {
          this.closeProductModal();
        }, 1500);
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
}

.view-btn {
  background-color: #e3f2fd;
  color: #1565c0;
}

.edit-btn {
  background-color: #e8f5e9;
  color: #2e7d32;
}

.delete-btn {
  background-color: #ffebee;
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

.delete-modal {
  max-width: 400px;
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
}

.product-form .form-group {
  margin-bottom: 1rem;
}

.form-row {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
}

.form-row .form-group {
  flex: 1;
  margin-bottom: 0;
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

.image-upload {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.preview-container {
  width: 100%;
  height: 150px;
  border: 1px dashed #ccc;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.image-preview {
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
}

.no-preview {
  color: #999;
}

.file-input-container {
  display: flex;
  align-items: center;
}

input[type="file"] {
  display: none;
}

.file-input-label {
  display: inline-block;
  padding: 0.5rem 1rem;
  background-color: #f0f0f0;
  color: #333;
  border-radius: 4px;
  cursor: pointer;
  margin-right: 1rem;
}

.file-name {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  margin-top: 1.5rem;
}

.cancel-btn, .save-btn, .delete-confirm-btn {
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

.delete-confirm-btn {
  background-color: #e53935;
  color: white;
}

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

.form-hint {
  display: block;
  font-size: 0.75rem;
  color: #666;
  margin-top: 0.25rem;
}

.size-indicator {
  font-size: 0.8rem;
  color: #666;
  margin-left: 0.5rem;
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
</style> 