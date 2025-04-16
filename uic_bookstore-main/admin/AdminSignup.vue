<template>
  <div class="signup-container">
    <div class="signup-form-container">
      <div class="logo-section">
        <img src="/images/logo.png" alt="UIC Logo" class="logo">
        <h2>UIC BOOKSTORE</h2>
      </div>
      
      <div class="signup-form">
        <h1>Create Admin Account</h1>
        <p class="description">Create a new administrator account for the UIC Bookstore system.</p>
        
        <div class="error-message" v-if="error">{{ error }}</div>
        
        <form @submit.prevent="signUp">
          <!-- Personal Details -->
          <div class="form-section">
            <h3>Personal Details</h3>
            
            <div class="form-row">
              <div class="form-group">
                <label for="first_name">First Name</label>
                <input 
                  type="text" 
                  id="first_name" 
                  v-model="formData.first_name" 
                  required
                >
              </div>
              <div class="form-group">
                <label for="last_name">Last Name</label>
                <input 
                  type="text" 
                  id="last_name" 
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
          </div>
          
          <!-- Account Details -->
          <div class="form-section">
            <h3>Account Details</h3>
            
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
                <label for="role">Role</label>
                <select 
                  id="role" 
                  v-model="formData.role" 
                  required
                >
                  <option value="admin">Admin</option>
                  <option value="super_admin">Super Admin</option>
                </select>
              </div>
            </div>
            
            <div class="form-row">
              <div class="form-group">
                <label for="password">Password</label>
                <input 
                  type="password" 
                  id="password" 
                  v-model="formData.password" 
                  required
                >
              </div>
              <div class="form-group">
                <label for="confirm_password">Confirm Password</label>
                <input 
                  type="password" 
                  id="confirm_password" 
                  v-model="formData.confirm_password" 
                  required
                >
              </div>
            </div>
            
            <div class="password-requirements">
              <p>Password must:</p>
              <ul>
                <li :class="{ valid: passwordCriteria.length }">Be at least 8 characters long</li>
                <li :class="{ valid: passwordCriteria.uppercase }">Include at least one uppercase letter</li>
                <li :class="{ valid: passwordCriteria.number }">Include at least one number</li>
                <li :class="{ valid: passwordCriteria.special }">Include at least one special character</li>
              </ul>
            </div>
          </div>
          
          <!-- Location Details (Optional) -->
          <div class="form-section">
            <h3>Location Details <span class="optional">(Optional)</span></h3>
            
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
                <label for="postal_code">Postal Code</label>
                <input 
                  type="text" 
                  id="postal_code" 
                  v-model="formData.postal_code"
                >
              </div>
              <div class="form-group">
                <label for="address_line">Address Line</label>
                <input 
                  type="text" 
                  id="address_line" 
                  v-model="formData.address_line"
                >
              </div>
            </div>
          </div>
          
          <div class="form-actions">
            <router-link to="/admin/login" class="back-to-login">
              Back to Login
            </router-link>
            <button type="submit" class="submit-btn" :disabled="isSubmitting">
              {{ isSubmitting ? 'Creating Account...' : 'Create Account' }}
            </button>
          </div>
        </form>
      </div>
    </div>
    
    <div class="welcome-section">
      <div class="welcome-content">
        <h2>Welcome to UIC Bookstore Admin Panel</h2>
        <p>Create a new administrator account to access the dashboard, manage products, and handle student inquiries.</p>
        <div class="features">
          <div class="feature">
            <i class="fas fa-box"></i>
            <span>Manage Products</span>
          </div>
          <div class="feature">
            <i class="fas fa-chart-bar"></i>
            <span>View Reports</span>
          </div>
          <div class="feature">
            <i class="fas fa-cubes"></i>
            <span>Track Inventory</span>
          </div>
          <div class="feature">
            <i class="fas fa-shopping-cart"></i>
            <span>Process Orders</span>
          </div>
          <div class="feature">
            <i class="fas fa-comments"></i>
            <span>Review Feedback</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AdminSignup',
  data() {
    return {
      formData: {
        username: '',
        email: '',
        password: '',
        confirm_password: '',
        first_name: '',
        last_name: '',
        phone_number: '',
        role: 'admin',
        country: '',
        city: '',
        postal_code: '',
        address_line: ''
      },
      isSubmitting: false,
      error: ''
    };
  },
  computed: {
    passwordCriteria() {
      const password = this.formData.password;
      return {
        length: password.length >= 8,
        uppercase: /[A-Z]/.test(password),
        number: /[0-9]/.test(password),
        special: /[^A-Za-z0-9]/.test(password)
      };
    },
    isPasswordValid() {
      const criteria = this.passwordCriteria;
      return criteria.length && criteria.uppercase && criteria.number && criteria.special;
    }
  },
  methods: {
    async signUp() {
      this.error = '';
      
      // Validate password match
      if (this.formData.password !== this.formData.confirm_password) {
        this.error = 'Passwords do not match';
        return;
      }
      
      // Validate password strength
      if (!this.isPasswordValid) {
        this.error = 'Password does not meet the requirements';
        return;
      }
      
      this.isSubmitting = true;
      
      try {
        const response = await fetch('http://localhost:8000/admin/signup', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            username: this.formData.username,
            email: this.formData.email,
            password: this.formData.password,
            first_name: this.formData.first_name,
            last_name: this.formData.last_name,
            phone_number: this.formData.phone_number || null,
            role: this.formData.role,
            country: this.formData.country || null,
            city: this.formData.city || null,
            postal_code: this.formData.postal_code || null,
            address_line: this.formData.address_line || null
          })
        });
        
        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(errorData.detail || 'Failed to create admin account');
        }
        
        // Redirect to login page on success
        this.$router.push('/admin/login?created=true');
      } catch (error) {
        this.error = error.message;
      } finally {
        this.isSubmitting = false;
      }
    }
  }
};
</script>

<style scoped>
.signup-container {
  display: flex;
  min-height: 100vh;
}

.signup-form-container {
  flex: 1;
  max-width: 650px;
  padding: 2rem;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
}

.logo-section {
  display: flex;
  align-items: center;
  margin-bottom: 2rem;
}

.logo {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  margin-right: 1rem;
}

.logo-section h2 {
  font-size: 1.2rem;
  color: #333;
  margin: 0;
}

.signup-form {
  flex: 1;
  padding: 1rem 0;
}

.signup-form h1 {
  margin: 0 0 0.5rem 0;
  color: #333;
  font-size: 1.8rem;
}

.description {
  color: #666;
  margin-bottom: 2rem;
}

.error-message {
  background-color: #ffebee;
  color: #c62828;
  padding: 0.75rem;
  border-radius: 4px;
  margin-bottom: 1.5rem;
}

.form-section {
  margin-bottom: 2rem;
  border: 1px solid #f0f0f0;
  border-radius: 8px;
  padding: 1.5rem;
  background-color: #fcfcfc;
}

.form-section h3 {
  margin: 0 0 1.5rem 0;
  font-size: 1.2rem;
  color: #333;
  display: flex;
  align-items: center;
}

.optional {
  font-weight: normal;
  color: #888;
  font-size: 0.9rem;
  margin-left: 0.5rem;
}

.form-row {
  display: flex;
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

.form-row:last-child {
  margin-bottom: 0;
}

.form-group {
  flex: 1;
}

.form-group label {
  display: block;
  color: #666;
  font-size: 0.85rem;
  margin-bottom: 0.5rem;
}

.form-group input, .form-group select {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
  background-color: white;
}

.form-group input:focus, .form-group select:focus {
  outline: none;
  border-color: #ff4b7d;
}

.password-requirements {
  background-color: #f9f9f9;
  padding: 1rem;
  border-radius: 4px;
  margin-top: 1rem;
}

.password-requirements p {
  margin: 0 0 0.5rem 0;
  font-weight: 500;
  font-size: 0.9rem;
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

.password-requirements li.valid {
  color: #2e7d32;
}

.password-requirements li.valid::before {
  content: "✓ ";
  color: #2e7d32;
}

.form-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 2rem;
}

.back-to-login {
  color: #666;
  text-decoration: none;
  font-size: 0.9rem;
}

.back-to-login:hover {
  color: #ff4b7d;
  text-decoration: underline;
}

.submit-btn {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 4px;
  background-color: #ff4b7d;
  color: white;
  font-size: 1rem;
  cursor: pointer;
  transition: background-color 0.3s;
}

.submit-btn:hover {
  background-color: #ff3366;
}

.submit-btn:disabled {
  background-color: #ffb3c6;
  cursor: not-allowed;
}

.welcome-section {
  flex: 1;
  background-color: #ff4b7d;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem;
  position: relative;
  overflow: hidden;
}

.welcome-content {
  position: relative;
  z-index: 1;
  max-width: 500px;
}

.welcome-content h2 {
  font-size: 2rem;
  margin: 0 0 1rem 0;
}

.welcome-content p {
  font-size: 1.1rem;
  margin-bottom: 2rem;
  opacity: 0.9;
}

.features {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1.5rem;
}

.feature {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.feature i {
  font-size: 1.5rem;
}

.feature span {
  font-size: 1rem;
}

@media (max-width: 1024px) {
  .welcome-section {
    display: none;
  }
  
  .signup-form-container {
    max-width: none;
  }
}

@media (max-width: 768px) {
  .form-row {
    flex-direction: column;
    gap: 1rem;
  }
  
  .signup-form-container {
    padding: 1.5rem;
  }
}
</style> 