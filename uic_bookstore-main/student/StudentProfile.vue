<template>
  <div class="modal-backdrop" v-if="show" @click.self="closeModal">
    <div class="modal-content">
      <div class="modal-header">
        <h2>My Profile</h2>
        <button class="close-button" @click="closeModal">&times;</button>
      </div>
      
      <div class="profile-content">
        <div class="profile-header">
          <div class="profile-picture-container">
            <img :src="profilePictureUrl || defaultProfilePicture" alt="Profile Picture" class="profile-picture">
            <div class="profile-badge" v-if="studentId">
              <i class="fas fa-check-circle"></i>
            </div>
          </div>
          <div class="profile-info">
            <h2>{{ studentName }}</h2>
            <p>{{ studentEmail }}</p>
          </div>
        </div>

        <div class="profile-form">
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
            <div class="email-input">
              <i class="fas fa-envelope email-icon"></i>
              <input 
                type="email" 
                id="email" 
                v-model="form.email" 
                class="form-input email-field"
                disabled
              />
            </div>
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
            <button @click="cancel" class="cancel-button">Cancel</button>
            <button @click="saveChanges" class="save-button" :disabled="isLoading">
              {{ isLoading ? 'Saving...' : 'Save changes' }}
            </button>
          </div>

          <div v-if="error" class="error-message">{{ error }}</div>
          <div v-if="successMessage" class="success-message">{{ successMessage }}</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'StudentProfile',
  props: {
    show: {
      type: Boolean,
      default: false
    }
  },
  emits: ['close', 'profile-updated'],
  data() {
    return {
      studentName: '',
      studentEmail: '',
      studentId: '',
      profilePictureUrl: null,
      defaultProfilePicture: 'https://via.placeholder.com/150?text=User',
      form: {
        name: '',
        email: '',
        studentId: '',
        profilePicture: null
      },
      error: null,
      successMessage: null,
      isLoading: false,
      profileFile: null
    }
  },
  watch: {
    show(newVal) {
      if (newVal) {
        this.loadUserData();
      }
    }
  },
  mounted() {
    if (this.show) {
      this.loadUserData();
    }
  },
  methods: {
    loadUserData() {
      // Get student info from localStorage
      const studentId = localStorage.getItem('studentId');
      const databaseId = localStorage.getItem('studentDatabaseId');
      const name = localStorage.getItem('studentName');
      const email = localStorage.getItem('studentEmail');
      const profilePic = localStorage.getItem('profilePicture');
      
      // Initialize form data with localStorage values first
      this.form.name = name || '';
      this.form.email = email || '';
      this.form.studentId = studentId || '';
      
      // Fetch the latest user data from the server
      if (studentId) {
        this.fetchUserProfile(studentId);
      } else {
        console.error("No student ID available in localStorage");
        this.error = "Could not retrieve your profile data. Please log in again.";
      }
    },
    closeModal() {
      this.$emit('close');
      // Reset form data
      this.resetForm();
    },
    resetForm() {
      this.error = null;
      this.successMessage = null;
      this.profileFile = null;
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
      
      // Check file type
      if (!file.type.match('image.*')) {
        this.error = 'Please select an image file';
        return;
      }
      
      // Check file size (max 5MB)
      if (file.size > 5 * 1024 * 1024) {
        this.error = 'Image size should be less than 5MB';
        return;
      }
      
      this.profileFile = file;
      
      // Create a preview URL
      const reader = new FileReader();
      reader.onload = (e) => {
        this.profilePictureUrl = e.target.result;
      };
      reader.readAsDataURL(file);
      
      this.error = null;
    },
    async saveChanges() {
      this.isLoading = true;
      this.error = null;
      this.successMessage = null;
      
      try {
        const formData = new FormData();
        formData.append('name', this.form.name);
        
        const studentId = localStorage.getItem('studentId');
        const databaseId = localStorage.getItem('studentDatabaseId');
        
        if (!databaseId) {
          throw new Error('Could not identify your account');
        }
        
        formData.append('student_id', databaseId);
        
        if (this.profileFile) {
          formData.append('profile_picture', this.profileFile);
        }
        
        const response = await fetch('http://localhost:8000/students/profile', {
          method: 'PUT',
          body: formData
        });
        
        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(errorData.detail || 'Failed to update profile');
        }
        
        const updatedUser = await response.json();
        
        // Update all profile information
        this.studentName = updatedUser.name;
        this.studentEmail = updatedUser.email;
        
        // Update localStorage
        localStorage.setItem('studentName', updatedUser.name);
        
        // Update profile picture if changed
        if (updatedUser.profile_picture) {
          const profilePicUrl = `http://localhost:8000/uploads/${updatedUser.profile_picture}`;
          this.profilePictureUrl = profilePicUrl;
          localStorage.setItem('profilePicture', profilePicUrl);
        }
        
        this.successMessage = 'Profile updated successfully';
        
        // Emit event with updated data
        this.$emit('profile-updated', {
          name: updatedUser.name,
          profilePicture: this.profilePictureUrl
        });
        
        // Close modal after success
        setTimeout(() => {
          this.closeModal();
        }, 1500);
        
      } catch (error) {
        console.error('Error updating profile:', error);
        this.error = error.message || 'Failed to update profile';
      } finally {
        this.isLoading = false;
      }
    },
    cancel() {
      // Reset form to original values
      this.form.name = this.studentName;
      
      // Reset profile picture preview if changed
      const profilePic = localStorage.getItem('profilePicture');
      if (profilePic) {
        this.profilePictureUrl = profilePic;
      } else {
        this.profilePictureUrl = null;
      }
      
      this.profileFile = null;
      this.error = null;
      this.successMessage = null;
    }
  }
};
</script>

<style scoped>
.modal-backdrop {
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
  width: 90%;
  max-width: 600px;
  max-height: 90vh;
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  overflow-y: auto;
  animation: modal-appear 0.3s ease-out;
}

@keyframes modal-appear {
  from {
    opacity: 0;
    transform: translateY(-50px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 1.5rem;
  border-bottom: 1px solid #f0f0f0;
}

.modal-header h2 {
  margin: 0;
  font-size: 1.3rem;
  color: #333;
}

.close-button {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: #666;
  transition: color 0.2s;
}

.close-button:hover {
  color: #ff9dae;
}

.profile-content {
  padding: 1.5rem;
}

.profile-header {
  display: flex;
  align-items: center;
  margin-bottom: 1.5rem;
}

.profile-picture-container {
  position: relative;
  margin-right: 1.5rem;
}

.profile-picture {
  width: 70px;
  height: 70px;
  border-radius: 50%;
  object-fit: cover;
}

.profile-badge {
  position: absolute;
  bottom: 0;
  right: 0;
  width: 20px;
  height: 20px;
  background-color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #4CAF50;
  font-size: 0.8rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.profile-info h2 {
  margin: 0 0 0.5rem 0;
  font-size: 1.3rem;
  color: #333;
}

.profile-info p {
  margin: 0;
  color: #666;
  font-size: 0.9rem;
}

.profile-form {
  background-color: white;
  border-radius: 8px;
}

.form-group {
  margin-bottom: 1.5rem;
}

label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #333;
  font-size: 0.9rem;
}

.form-input {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
}

.form-input:disabled {
  background-color: #f9f9f9;
  color: #777;
}

.email-input {
  position: relative;
}

.email-icon {
  position: absolute;
  left: 0.75rem;
  top: 50%;
  transform: translateY(-50%);
  color: #777;
}

.email-field {
  padding-left: 2.5rem;
}

.profile-upload {
  display: flex;
  align-items: center;
}

.upload-preview {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  object-fit: cover;
  margin-right: 1rem;
}

.upload-button {
  display: inline-block;
  background-color: #f5f5f5;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: background-color 0.3s;
}

.upload-button:hover {
  background-color: #e0e0e0;
}

.file-input {
  display: none;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  margin-top: 2rem;
}

.cancel-button {
  background-color: white;
  border: 1px solid #ddd;
  color: #333;
  padding: 0.75rem 1.5rem;
  border-radius: 4px;
  margin-right: 1rem;
  cursor: pointer;
  font-size: 0.9rem;
  transition: background-color 0.3s;
}

.cancel-button:hover {
  background-color: #f5f5f5;
}

.save-button {
  background-color: #FF9DAE; /* Light pink theme */
  border: none;
  color: white;
  padding: 0.75rem 1.5rem;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: background-color 0.3s;
}

.save-button:hover {
  background-color: #ff89a0; /* Darker pink on hover */
}

.save-button:disabled {
  background-color: #ffbfc9;
  cursor: not-allowed;
}

.error-message {
  margin-top: 1.5rem;
  color: #D32F2F;
  padding: 0.75rem;
  background-color: #FFEBEE;
  border-radius: 4px;
}

.success-message {
  margin-top: 1.5rem;
  color: #388E3C;
  padding: 0.75rem;
  background-color: #E8F5E9;
  border-radius: 4px;
}
</style> 