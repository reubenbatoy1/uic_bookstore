<template>
  <StudentLayout>
    <div class="settings-page">
      <div class="page-header">
        <div class="header-left">
          <button class="back-button" @click="$router.go(-1)">
            <i class="fas fa-arrow-left"></i> Back
          </button>
          <div class="title-section">
            <h1>Account Settings</h1>
            <p>Manage your account details and password</p>
          </div>
        </div>
      </div>

      <div class="settings-container">
        <div class="tabs">
          <button 
            :class="['tab-button', { active: activeTab === 'profile' }]" 
            @click="activeTab = 'profile'"
          >
            <i class="fas fa-user"></i> Profile Details
          </button>
          <button 
            :class="['tab-button', { active: activeTab === 'password' }]" 
            @click="activeTab = 'password'"
          >
            <i class="fas fa-lock"></i> Change Password
          </button>
        </div>

        <div class="tab-content">
          <!-- Profile Details Tab -->
          <div v-if="activeTab === 'profile'" class="profile-details">
            <div class="profile-header">
              <div class="profile-picture-container">
                <img :src="profilePictureUrl || defaultProfilePicture" alt="Profile Picture" class="profile-picture">
              </div>
              <div class="profile-info">
                <h2>{{ studentName }}</h2>
                <p>{{ studentEmail }}</p>
                <p class="student-id">Student ID: {{ studentId }}</p>
              </div>
            </div>

            <div class="form-group">
              <label for="name">Name</label>
              <input 
                type="text" 
                id="name" 
                v-model="form.name" 
                class="form-input"
              />
            </div>

            <div class="form-group">
              <label for="email">Email address</label>
              <input 
                type="email" 
                id="email" 
                v-model="form.email" 
                class="form-input"
                disabled
              />
              <small>Email cannot be changed</small>
            </div>

            <div class="form-group">
              <label for="studentId">ID Number</label>
              <input 
                type="text" 
                id="studentId" 
                v-model="form.studentId" 
                class="form-input"
                disabled
              />
              <small>Student ID cannot be changed</small>
            </div>

            <div class="form-group">
              <label>Profile photo</label>
              <div class="profile-upload">
                <img :src="profilePictureUrl || defaultProfilePicture" alt="Profile" class="upload-preview">
                <label for="profile-upload" class="upload-button">Click to replace</label>
                <input 
                  type="file" 
                  id="profile-upload" 
                  @change="handleProfilePictureChange" 
                  accept="image/*"
                  class="file-input"
                />
              </div>
            </div>

            <div class="form-actions">
              <button @click="saveChanges" class="save-button" :disabled="isLoading">
                {{ isLoading ? 'Saving...' : 'Save changes' }}
              </button>
            </div>
          </div>

          <!-- Change Password Tab -->
          <div v-if="activeTab === 'password'" class="change-password">
            <div class="form-group">
              <label for="current-password">Current Password</label>
              <input 
                type="password" 
                id="current-password" 
                v-model="passwordForm.currentPassword" 
                class="form-input"
                placeholder="Enter your current password"
              />
            </div>

            <div class="form-group">
              <label for="new-password">New Password</label>
              <input 
                type="password" 
                id="new-password" 
                v-model="passwordForm.newPassword" 
                class="form-input"
                placeholder="Enter your new password"
              />
              <small>Password must be at least 8 characters long</small>
            </div>

            <div class="form-group">
              <label for="confirm-password">Confirm New Password</label>
              <input 
                type="password" 
                id="confirm-password" 
                v-model="passwordForm.confirmPassword" 
                class="form-input"
                placeholder="Confirm your new password"
              />
            </div>

            <div class="form-actions">
              <button @click="changePassword" class="save-button" :disabled="isChangingPassword">
                {{ isChangingPassword ? 'Updating...' : 'Update Password' }}
              </button>
            </div>
          </div>
        </div>
      </div>

      <div v-if="error" class="error-message">{{ error }}</div>
      <div v-if="successMessage" class="success-message">{{ successMessage }}</div>
    </div>
  </StudentLayout>
</template>

<script>
import StudentLayout from '../layouts/StudentLayout.vue';

export default {
  name: 'StudentSettings',
  components: {
    StudentLayout
  },
  data() {
    return {
      activeTab: 'profile',
      studentName: '',
      studentEmail: '',
      studentId: '',
      studentDatabaseId: '',
      profilePictureUrl: null,
      defaultProfilePicture: 'https://via.placeholder.com/150?text=User',
      form: {
        name: '',
        email: '',
        studentId: ''
      },
      passwordForm: {
        currentPassword: '',
        newPassword: '',
        confirmPassword: ''
      },
      error: null,
      successMessage: null,
      isLoading: false,
      isChangingPassword: false,
      profileFile: null
    }
  },
  created() {
    // Check if user is logged in
    const isLoggedIn = localStorage.getItem('studentLoggedIn');
    const token = localStorage.getItem('studentToken');
    
    if (!isLoggedIn || !token) {
      this.$router.push('/student/login');
      return;
    }
    
    // Load user data
    this.loadUserData();
  },
  methods: {
    loadUserData() {
      // Get student info from localStorage
      const studentId = localStorage.getItem('studentId');
      const databaseId = localStorage.getItem('studentDatabaseId');
      const name = localStorage.getItem('studentName');
      const email = localStorage.getItem('studentEmail');
      const profilePic = localStorage.getItem('profilePicture');
      
      this.studentDatabaseId = databaseId;
      
      // Initialize form data with localStorage values first
      this.form.name = name || '';
      this.form.email = email || '';
      this.form.studentId = studentId || '';
      this.studentName = name || '';
      this.studentEmail = email || '';
      this.studentId = studentId || '';
      
      if (profilePic) {
        this.profilePictureUrl = profilePic;
      }
      
      // Fetch the latest user data from the server
      if (studentId) {
        this.fetchUserProfile(studentId);
      } else {
        console.error("No student ID available in localStorage");
        this.error = "Could not retrieve your profile data. Please log in again.";
      }
    },
    async fetchUserProfile(studentId) {
      try {
        const response = await fetch(`http://localhost:8000/students/me?student_id=${encodeURIComponent(studentId)}`);
        
        if (!response.ok) {
          throw new Error('Failed to load profile data');
        }
        
        const userData = await response.json();
        
        // Update all profile information
        this.studentName = userData.name;
        this.studentEmail = userData.email;
        this.studentId = userData.student_id;
        this.studentDatabaseId = userData.id;
        
        // Update form values
        this.form.name = userData.name;
        this.form.email = userData.email;
        this.form.studentId = userData.student_id;
        
        // Update profile picture if available
        if (userData.profile_picture) {
          this.profilePictureUrl = `http://localhost:8000/uploads/${userData.profile_picture}`;
        }
        
        // Store in localStorage for persistence
        localStorage.setItem('studentName', userData.name);
        localStorage.setItem('studentEmail', userData.email);
        localStorage.setItem('studentId', userData.student_id);
        localStorage.setItem('studentDatabaseId', userData.id);
        if (userData.profile_picture) {
          localStorage.setItem('profilePicture', this.profilePictureUrl);
        }
        
      } catch (error) {
        console.error('Error fetching user profile:', error);
        this.error = "Failed to load your profile. Please try again.";
      }
    },
    handleProfilePictureChange(event) {
      const file = event.target.files[0];
      if (!file) return;
      
      if (!file.type.includes('image/')) {
        this.error = "Please select an image file.";
        return;
      }
      
      this.profileFile = file;
      this.profilePictureUrl = URL.createObjectURL(file);
    },
    async saveChanges() {
      this.error = null;
      this.successMessage = null;
      this.isLoading = true;
      
      try {
        // Create form data to handle file upload
        const formData = new FormData();
        formData.append('name', this.form.name);
        formData.append('student_id', this.studentDatabaseId);
        
        if (this.profileFile) {
          formData.append('profile_picture', this.profileFile);
        }
        
        // Send update request
        const response = await fetch('http://localhost:8000/students/profile', {
          method: 'PUT',
          body: formData,
        });
        
        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(errorData.detail || 'Failed to update profile');
        }
        
        const updatedData = await response.json();
        
        // Update local state
        this.studentName = updatedData.name;
        localStorage.setItem('studentName', updatedData.name);
        
        if (updatedData.profile_picture) {
          this.profilePictureUrl = `http://localhost:8000/uploads/${updatedData.profile_picture}`;
          localStorage.setItem('profilePicture', this.profilePictureUrl);
        }
        
        this.successMessage = "Profile updated successfully!";
        
        // Reset file input
        this.profileFile = null;
        const fileInput = document.getElementById('profile-upload');
        if (fileInput) fileInput.value = '';
        
      } catch (error) {
        console.error('Error updating profile:', error);
        this.error = error.message || "Failed to update profile. Please try again.";
      } finally {
        this.isLoading = false;
      }
    },
    async changePassword() {
      this.error = null;
      this.successMessage = null;
      
      // Validate password inputs
      if (!this.passwordForm.currentPassword) {
        this.error = "Please enter your current password.";
        return;
      }
      
      if (!this.passwordForm.newPassword) {
        this.error = "Please enter a new password.";
        return;
      }
      
      if (this.passwordForm.newPassword.length < 8) {
        this.error = "New password must be at least 8 characters long.";
        return;
      }
      
      if (this.passwordForm.newPassword !== this.passwordForm.confirmPassword) {
        this.error = "New passwords do not match.";
        return;
      }
      
      this.isChangingPassword = true;
      
      try {
        // Make API call to change password
        const response = await fetch('http://localhost:8000/students/change-password', {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            student_id: this.studentDatabaseId,
            current_password: this.passwordForm.currentPassword,
            new_password: this.passwordForm.newPassword
          }),
        });
        
        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(errorData.detail || 'Failed to change password');
        }
        
        // Reset password form
        this.passwordForm.currentPassword = '';
        this.passwordForm.newPassword = '';
        this.passwordForm.confirmPassword = '';
        
        this.successMessage = "Password changed successfully!";
        
      } catch (error) {
        console.error('Error changing password:', error);
        this.error = error.message || "Failed to change password. Please try again.";
      } finally {
        this.isChangingPassword = false;
      }
    }
  }
}
</script>

<style scoped>
.settings-page {
  max-width: 900px;
  margin: 20px auto;
  padding: 25px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
}

.page-header {
  margin-bottom: 30px;
  border-bottom: 1px solid #eee;
  padding-bottom: 20px;
}

.header-left {
  display: flex;
  align-items: flex-start;
  gap: 20px;
}

.back-button {
  display: flex;
  align-items: center;
  gap: 8px;
  background: none;
  border: none;
  color: #666;
  font-size: 15px;
  cursor: pointer;
  padding: 8px 12px;
  border-radius: 6px;
  transition: all 0.2s;
}

.back-button:hover {
  background: #f5f5f5;
  color: #333;
}

.title-section {
  flex: 1;
}

.title-section h1 {
  font-size: 24px;
  margin: 0 0 8px 0;
  color: #333;
}

.title-section p {
  color: #666;
  margin: 0;
  font-size: 14px;
}

.tabs {
  display: flex;
  margin-bottom: 30px;
  border-bottom: 1px solid #eee;
}

.tab-button {
  padding: 12px 24px;
  background: none;
  border: none;
  font-size: 15px;
  cursor: pointer;
  color: #666;
  margin-right: 10px;
  border-bottom: 3px solid transparent;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: 8px;
}

.tab-button:hover {
  color: #FF9DAE;
}

.tab-button.active {
  color: #FF9DAE;
  border-bottom: 3px solid #FF9DAE;
  font-weight: 600;
}

.tab-button i {
  margin-right: 8px;
}

.tab-content {
  padding: 20px 0;
}

.profile-header {
  display: flex;
  align-items: center;
  margin-bottom: 30px;
}

.profile-picture-container {
  position: relative;
  margin-right: 20px;
}

.profile-picture {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  object-fit: cover;
  border: 3px solid #eee;
}

.profile-info h2 {
  margin: 0 0 5px 0;
  font-size: 24px;
  color: #333;
}

.profile-info p {
  margin: 0;
  color: #666;
}

.student-id {
  font-size: 14px;
  color: #888;
  margin-top: 5px !important;
}

.form-group {
  margin-bottom: 25px;
  max-width: 600px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 600;
  color: #444;
  font-size: 14px;
}

.form-group small {
  display: block;
  color: #888;
  margin-top: 5px;
  font-size: 12px;
}

.form-input {
  width: 100%;
  padding: 12px 15px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 15px;
  transition: all 0.2s;
}

.form-input:focus {
  border-color: #FF9DAE;
  outline: none;
  box-shadow: 0 0 0 3px rgba(255, 157, 174, 0.1);
}

.form-input:disabled {
  background-color: #f9f9f9;
  color: #666;
  cursor: not-allowed;
}

.profile-upload {
  display: flex;
  align-items: center;
  gap: 15px;
}

.upload-preview {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  object-fit: cover;
  border: 3px solid #f0f0f0;
}

.upload-button {
  display: inline-block;
  padding: 10px 16px;
  background-color: #f5f5f5;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 14px;
  color: #444;
}

.upload-button:hover {
  background-color: #e8e8e8;
}

.file-input {
  display: none;
}

.form-actions {
  margin-top: 30px;
}

.save-button {
  padding: 12px 24px;
  background-color: #FF9DAE;
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 15px;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: 8px;
}

.save-button:hover {
  background-color: #ff89a0;
}

.save-button:disabled {
  background-color: #ffbfc9;
  cursor: not-allowed;
}

.error-message, .success-message {
  margin-top: 20px;
  padding: 15px;
  border-radius: 8px;
  font-size: 14px;
}

.error-message {
  background-color: #fff5f5;
  color: #d32f2f;
  border-left: 4px solid #d32f2f;
}

.success-message {
  background-color: #f0fff4;
  color: #2e7d32;
  border-left: 4px solid #2e7d32;
}

@media (max-width: 768px) {
  .settings-page {
    margin: 0;
    padding: 20px;
    border-radius: 0;
  }

  .header-left {
    flex-direction: column;
    gap: 15px;
  }

  .back-button {
    padding: 6px 10px;
  }

  .tabs {
    flex-wrap: wrap;
    gap: 10px;
  }

  .tab-button {
    padding: 10px 16px;
    font-size: 14px;
  }

  .form-group {
    margin-bottom: 20px;
  }

  .profile-upload {
    flex-direction: column;
    align-items: flex-start;
  }
}
</style> 