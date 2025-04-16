<template>
  <div class="admin-settings">
    <div class="page-header">
      <h1>Settings</h1>
    </div>
    
    <div class="settings-container">
      <!-- Profile Section -->
      <div class="profile-section">
        <div class="profile-card">
          <div class="profile-header">
            <h2>My Profile</h2>
          </div>
          
          <div class="profile-info">
            <div class="profile-picture">
              <img 
                :src="profileImageUrl || '/images/default-avatar.png'" 
                alt="Profile Picture" 
                class="avatar"
              >
              <div class="upload-overlay" @click="triggerFileInput">
                <i class="fas fa-camera"></i>
                <span>Change Photo</span>
              </div>
              <input 
                type="file" 
                ref="fileInput" 
                @change="handleFileUpload" 
                accept="image/*" 
                style="display: none"
              >
            </div>
            
            <div class="profile-details">
              <h3>{{ adminData.first_name }} {{ adminData.last_name }}</h3>
              <p class="role">{{ formatRole(adminData.role) }}</p>
              <p class="location" v-if="adminData.city && adminData.country">
                <i class="fas fa-map-marker-alt"></i> {{ adminData.city }}, {{ adminData.country }}
              </p>
            </div>
          </div>
        </div>
      </div>

      <!-- Personal Information Section -->
      <div class="personal-info-section">
        <div class="info-card">
          <div class="card-header">
            <h2>Personal Information</h2>
            <button class="edit-button" @click="editPersonalInfo = !editPersonalInfo">
              <i class="fas fa-pencil-alt"></i> {{ editPersonalInfo ? 'Cancel' : 'Edit' }}
            </button>
          </div>
          
          <div class="error-message" v-if="personalInfoError">{{ personalInfoError }}</div>
          <div class="success-message" v-if="personalInfoSuccess">{{ personalInfoSuccess }}</div>
          
          <form v-if="editPersonalInfo" @submit.prevent="savePersonalInfo" class="edit-form">
            <div class="form-row">
              <div class="form-group">
                <label for="firstName">First Name</label>
                <input 
                  type="text" 
                  id="firstName" 
                  v-model="formData.first_name" 
                  required
                >
              </div>
              <div class="form-group">
                <label for="lastName">Last Name</label>
                <input 
                  type="text" 
                  id="lastName" 
                  v-model="formData.last_name" 
                  required
                >
              </div>
            </div>
            
            <div class="form-row">
              <div class="form-group">
                <label for="email">Email Address</label>
                <input 
                  type="email" 
                  id="email" 
                  v-model="formData.email" 
                  required
                >
              </div>
              <div class="form-group">
                <label for="phone">Phone Number</label>
                <input 
                  type="tel" 
                  id="phone" 
                  v-model="formData.phone_number"
                >
              </div>
            </div>
            
            <div class="form-row">
              <div class="form-group">
                <label for="username">Username</label>
                <input 
                  type="text" 
                  id="username" 
                  v-model="formData.username" 
                  required
                >
              </div>
              <div class="form-group">
                <label for="dob">Date of Birth</label>
                <input 
                  type="date" 
                  id="dob" 
                  v-model="formData.date_of_birth"
                >
              </div>
            </div>
            
            <div class="form-actions">
              <button type="button" class="cancel-btn" @click="editPersonalInfo = false">Cancel</button>
              <button type="submit" class="save-btn" :disabled="isSubmitting">
                {{ isSubmitting ? 'Saving...' : 'Save Changes' }}
              </button>
            </div>
          </form>
          
          <div v-else class="info-display">
            <div class="info-row">
              <div class="info-group">
                <label>First Name</label>
                <p>{{ adminData.first_name }}</p>
              </div>
              <div class="info-group">
                <label>Last Name</label>
                <p>{{ adminData.last_name }}</p>
              </div>
            </div>
            
            <div class="info-row">
              <div class="info-group">
                <label>Email Address</label>
                <p>{{ adminData.email }}</p>
              </div>
              <div class="info-group">
                <label>Phone Number</label>
                <p>{{ adminData.phone_number || 'Not specified' }}</p>
              </div>
            </div>
            
            <div class="info-row">
              <div class="info-group">
                <label>Username</label>
                <p>{{ adminData.username }}</p>
              </div>
              <div class="info-group">
                <label>Date of Birth</label>
                <p>{{ formatDate(adminData.date_of_birth) || 'Not specified' }}</p>
              </div>
            </div>
            
            <div class="info-row">
              <div class="info-group">
                <label>User Role</label>
                <p>{{ formatRole(adminData.role) }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Address Section -->
      <div class="address-section">
        <div class="info-card">
          <div class="card-header">
            <h2>Address</h2>
            <button class="edit-button" @click="editAddress = !editAddress">
              <i class="fas fa-pencil-alt"></i> {{ editAddress ? 'Cancel' : 'Edit' }}
            </button>
          </div>
          
          <div class="error-message" v-if="addressError">{{ addressError }}</div>
          <div class="success-message" v-if="addressSuccess">{{ addressSuccess }}</div>
          
          <form v-if="editAddress" @submit.prevent="saveAddress" class="edit-form">
            <div class="form-row">
              <div class="form-group">
                <label for="country">Country</label>
                <input 
                  type="text" 
                  id="country" 
                  v-model="formData.country"
                >
              </div>
              <div class="form-group">
                <label for="city">City</label>
                <input 
                  type="text" 
                  id="city" 
                  v-model="formData.city"
                >
              </div>
            </div>
            
            <div class="form-row">
              <div class="form-group">
                <label for="postalCode">Postal Code</label>
                <input 
                  type="text" 
                  id="postalCode" 
                  v-model="formData.postal_code"
                >
              </div>
              <div class="form-group full-width">
                <label for="addressLine">Address Line</label>
                <input 
                  type="text" 
                  id="addressLine" 
                  v-model="formData.address_line"
                >
              </div>
            </div>
            
            <div class="form-actions">
              <button type="button" class="cancel-btn" @click="editAddress = false">Cancel</button>
              <button type="submit" class="save-btn" :disabled="isSubmitting">
                {{ isSubmitting ? 'Saving...' : 'Save Changes' }}
              </button>
            </div>
          </form>
          
          <div v-else class="info-display">
            <div class="info-row">
              <div class="info-group">
                <label>Country</label>
                <p>{{ adminData.country || 'Not specified' }}</p>
              </div>
              <div class="info-group">
                <label>City</label>
                <p>{{ adminData.city || 'Not specified' }}</p>
              </div>
            </div>
            
            <div class="info-row">
              <div class="info-group">
                <label>Postal Code</label>
                <p>{{ adminData.postal_code || 'Not specified' }}</p>
              </div>
              <div class="info-group">
                <label>Address Line</label>
                <p>{{ adminData.address_line || 'Not specified' }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Password Change Section -->
      <div class="password-section">
        <div class="info-card">
          <div class="card-header">
            <h2>Change Password</h2>
          </div>
          
          <div class="error-message" v-if="passwordError">{{ passwordError }}</div>
          <div class="success-message" v-if="passwordSuccess">{{ passwordSuccess }}</div>
          
          <form @submit.prevent="changePassword" class="edit-form">
            <div class="form-row">
              <div class="form-group">
                <label for="currentPassword">Current Password</label>
                <input 
                  type="password" 
                  id="currentPassword" 
                  v-model="passwordData.current_password" 
                  required
                >
              </div>
            </div>
            
            <div class="form-row">
              <div class="form-group">
                <label for="newPassword">New Password</label>
                <input 
                  type="password" 
                  id="newPassword" 
                  v-model="passwordData.new_password" 
                  required
                >
              </div>
              <div class="form-group">
                <label for="confirmPassword">Confirm New Password</label>
                <input 
                  type="password" 
                  id="confirmPassword" 
                  v-model="passwordData.confirm_password" 
                  required
                >
              </div>
            </div>
            
            <div class="password-requirements">
              <p>Password must:</p>
              <ul>
                <li>Be at least 8 characters long</li>
                <li>Include at least one uppercase letter</li>
                <li>Include at least one number</li>
                <li>Include at least one special character</li>
              </ul>
            </div>
            
            <div class="form-actions">
              <button type="submit" class="save-btn" :disabled="isSubmittingPassword">
                {{ isSubmittingPassword ? 'Updating...' : 'Update Password' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AdminSettings',
  data() {
    return {
      adminData: {
        id: null,
        username: '',
        email: '',
        first_name: '',
        last_name: '',
        phone_number: '',
        date_of_birth: '',
        profile_picture: '',
        role: 'admin',
        country: '',
        city: '',
        postal_code: '',
        address_line: ''
      },
      formData: {
        username: '',
        email: '',
        first_name: '',
        last_name: '',
        phone_number: '',
        date_of_birth: '',
        country: '',
        city: '',
        postal_code: '',
        address_line: ''
      },
      passwordData: {
        current_password: '',
        new_password: '',
        confirm_password: ''
      },
      editPersonalInfo: false,
      editAddress: false,
      isSubmitting: false,
      isSubmittingPassword: false,
      personalInfoError: '',
      personalInfoSuccess: '',
      addressError: '',
      addressSuccess: '',
      passwordError: '',
      passwordSuccess: '',
      profileImageUrl: null
    };
  },
  created() {
    this.loadAdminData();
  },
  methods: {
    async loadAdminData() {
      try {
        const adminId = localStorage.getItem('adminId');
        if (!adminId) {
          this.$router.push('/admin/login');
          return;
        }
        
        const response = await fetch(`http://localhost:8000/admin/users/${adminId}`);
        if (!response.ok) {
          throw new Error('Failed to load admin data');
        }
        
        this.adminData = await response.json();
        this.formData = { ...this.adminData };
        this.profileImageUrl = this.adminData.profile_picture ? 
          `http://localhost:8000/uploads/${this.adminData.profile_picture}` : 
          null;
      } catch (error) {
        console.error('Error loading admin data:', error);
      }
    },
    formatRole(role) {
      if (role === 'super_admin') return 'Super Admin';
      return 'Admin';
    },
    formatDate(dateString) {
      if (!dateString) return '';
      
      const date = new Date(dateString);
      return date.toLocaleDateString();
    },
    triggerFileInput() {
      this.$refs.fileInput.click();
    },
    async handleFileUpload(event) {
      const file = event.target.files[0];
      if (!file) return;
      
      // Check file type
      if (!file.type.match('image.*')) {
        alert('Please select an image file');
        return;
      }
      
      // Check file size (max 2MB)
      if (file.size > 2 * 1024 * 1024) {
        alert('File size should not exceed 2MB');
        return;
      }
      
      try {
        const formData = new FormData();
        formData.append('profile_picture', file);
        formData.append('admin_id', this.adminData.id);
        
        const response = await fetch('http://localhost:8000/admin/users/profile-picture', {
          method: 'POST',
          body: formData,
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('adminToken')}`
          }
        });
        
        if (!response.ok) {
          throw new Error('Failed to upload profile picture');
        }
        
        const result = await response.json();
        
        // Update local profile picture URL
        this.profileImageUrl = `http://localhost:8000/uploads/${result.profile_picture}`;
        this.adminData.profile_picture = result.profile_picture;
        
        // Emit event to update profile picture in parent components
        this.$emit('profile-updated', {
          profilePicture: result.profile_picture
        });
        
        // Show success message
        this.personalInfoSuccess = 'Profile picture updated successfully!';
      } catch (error) {
        console.error('Error uploading profile picture:', error);
        this.personalInfoError = 'Failed to upload profile picture. Please try again.';
      }
    },
    async savePersonalInfo() {
      this.personalInfoError = '';
      this.personalInfoSuccess = '';
      this.isSubmitting = true;
      
      try {
        const response = await fetch(`http://localhost:8000/admin/users/${this.adminData.id}`, {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            username: this.formData.username,
            email: this.formData.email,
            first_name: this.formData.first_name,
            last_name: this.formData.last_name,
            phone_number: this.formData.phone_number,
            date_of_birth: this.formData.date_of_birth
          })
        });
        
        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(errorData.detail || 'Failed to update personal information');
        }
        
        const updatedData = await response.json();
        this.adminData = { ...this.adminData, ...updatedData };
        this.personalInfoSuccess = 'Personal information updated successfully!';
        this.editPersonalInfo = false;
        
        // Update localStorage if username changed
        if (this.adminData.username !== localStorage.getItem('adminUsername')) {
          localStorage.setItem('adminUsername', this.adminData.username);
        }
      } catch (error) {
        this.personalInfoError = error.message;
      } finally {
        this.isSubmitting = false;
      }
    },
    async saveAddress() {
      this.addressError = '';
      this.addressSuccess = '';
      this.isSubmitting = true;
      
      try {
        const response = await fetch(`http://localhost:8000/admin/users/${this.adminData.id}/address`, {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            country: this.formData.country,
            city: this.formData.city,
            postal_code: this.formData.postal_code,
            address_line: this.formData.address_line
          })
        });
        
        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(errorData.detail || 'Failed to update address');
        }
        
        const updatedData = await response.json();
        this.adminData = { ...this.adminData, ...updatedData };
        this.addressSuccess = 'Address updated successfully!';
        this.editAddress = false;
      } catch (error) {
        this.addressError = error.message;
      } finally {
        this.isSubmitting = false;
      }
    },
    async changePassword() {
      this.passwordError = '';
      this.passwordSuccess = '';
      this.isSubmittingPassword = true;
      
      // Validate password match
      if (this.passwordData.new_password !== this.passwordData.confirm_password) {
        this.passwordError = 'New passwords do not match';
        this.isSubmittingPassword = false;
        return;
      }
      
      // Validate password strength
      const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
      if (!passwordRegex.test(this.passwordData.new_password)) {
        this.passwordError = 'Password does not meet requirements';
        this.isSubmittingPassword = false;
        return;
      }
      
      try {
        const response = await fetch(`http://localhost:8000/admin/users/${this.adminData.id}/password`, {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            current_password: this.passwordData.current_password,
            new_password: this.passwordData.new_password
          })
        });
        
        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(errorData.detail || 'Failed to change password');
        }
        
        this.passwordSuccess = 'Password changed successfully!';
        this.passwordData = {
          current_password: '',
          new_password: '',
          confirm_password: ''
        };
      } catch (error) {
        this.passwordError = error.message;
      } finally {
        this.isSubmittingPassword = false;
      }
    }
  }
};
</script>

<style scoped>
.admin-settings {
  padding: 1.5rem;
}

.page-header {
  margin-bottom: 2rem;
}

.page-header h1 {
  margin: 0;
  color: #333;
  font-size: 1.8rem;
}

.settings-container {
  display: flex;
  flex-direction: column;
  gap: 2rem;
  max-width: 900px;
}

.profile-card, .info-card {
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.profile-header, .card-header {
  padding: 1.25rem 1.5rem;
  border-bottom: 1px solid #eee;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.profile-header h2, .card-header h2 {
  margin: 0;
  font-size: 1.2rem;
  color: #333;
}

.edit-button {
  background: none;
  border: none;
  color: #ff4b7d;
  font-size: 0.9rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.edit-button:hover {
  text-decoration: underline;
}

.profile-info {
  padding: 1.5rem;
  display: flex;
  align-items: center;
  gap: 2rem;
}

.profile-picture {
  position: relative;
  width: 120px;
  height: 120px;
  border-radius: 50%;
  overflow: hidden;
}

.avatar {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.upload-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  color: white;
  opacity: 0;
  transition: opacity 0.3s;
  cursor: pointer;
}

.upload-overlay:hover {
  opacity: 1;
}

.upload-overlay i {
  font-size: 1.5rem;
  margin-bottom: 0.5rem;
}

.upload-overlay span {
  font-size: 0.8rem;
}

.profile-details h3 {
  margin: 0 0 0.5rem 0;
  font-size: 1.5rem;
  color: #333;
}

.role {
  color: #666;
  font-size: 0.9rem;
  margin-bottom: 0.75rem;
}

.location {
  color: #666;
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.info-display {
  padding: 1.5rem;
}

.info-row {
  display: flex;
  margin-bottom: 1.5rem;
}

.info-row:last-child {
  margin-bottom: 0;
}

.info-group {
  flex: 1;
}

.info-group label {
  display: block;
  color: #666;
  font-size: 0.85rem;
  margin-bottom: 0.25rem;
}

.info-group p {
  margin: 0;
  color: #333;
  font-size: 1rem;
}

.edit-form {
  padding: 1.5rem;
}

.form-row {
  display: flex;
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

.form-group {
  flex: 1;
}

.form-group.full-width {
  flex: 2;
}

.form-group label {
  display: block;
  color: #666;
  font-size: 0.85rem;
  margin-bottom: 0.5rem;
}

.form-group input {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
}

.form-group input:focus {
  outline: none;
  border-color: #ff4b7d;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
}

.cancel-btn, .save-btn {
  padding: 0.75rem 1.5rem;
  border-radius: 4px;
  font-size: 0.9rem;
  cursor: pointer;
  transition: all 0.3s;
  border: none;
}

.cancel-btn {
  background-color: #f5f5f5;
  color: #666;
}

.cancel-btn:hover {
  background-color: #e0e0e0;
}

.save-btn {
  background-color: #ff4b7d;
  color: white;
}

.save-btn:hover {
  background-color: #ff3366;
}

.save-btn:disabled {
  background-color: #ffb3c6;
  cursor: not-allowed;
}

.error-message, .success-message {
  margin: 0.75rem 1.5rem;
  padding: 0.75rem;
  border-radius: 4px;
}

.error-message {
  background-color: #ffebee;
  color: #c62828;
}

.success-message {
  background-color: #e8f5e9;
  color: #2e7d32;
}

.password-requirements {
  background-color: #f9f9f9;
  padding: 1rem;
  border-radius: 4px;
  margin-bottom: 1.5rem;
}

.password-requirements p {
  margin: 0 0 0.5rem 0;
  font-weight: 500;
}

.password-requirements ul {
  margin: 0;
  padding-left: 1.5rem;
}

.password-requirements li {
  font-size: 0.85rem;
  color: #666;
  margin-bottom: 0.25rem;
}

@media (max-width: 768px) {
  .form-row {
    flex-direction: column;
    gap: 1rem;
  }
  
  .profile-info {
    flex-direction: column;
    text-align: center;
  }
}
</style> 