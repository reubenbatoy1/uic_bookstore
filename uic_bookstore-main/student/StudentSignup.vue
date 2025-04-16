<template>
  <div class="signup-container">
    <div class="signup-content">
      <div class="signup-left">
        <h3>Create Your Account</h3>
        <p class="subtitle">Join UIC Bookstore Online Inquiry to see our services.</p>
      </div>
      <div class="signup-right">
        <h2>Sign Up</h2>
        <form @submit.prevent="signup" v-if="!signupSuccess">
          <div class="form-group">
            <div class="input-wrapper">
              <i class="fas fa-user"></i>
              <input
                type="text"
                id="name"
                v-model="name"
                required
                placeholder="Enter your full name"
              />
            </div>
          </div>
          <div class="form-group">
            <div class="input-wrapper">
              <i class="fas fa-envelope"></i>
              <input
                type="email"
                id="email"
                v-model="email"
                required
                placeholder="Enter your email"
              />
            </div>
          </div>
          <div class="form-group">
            <div class="input-wrapper">
              <i class="fas fa-id-card"></i>
              <input
                type="text"
                id="studentId"
                v-model="studentId"
                required
                placeholder="Enter your student ID"
              />
            </div>
          </div>
          <div class="form-group">
            <div class="input-wrapper">
              <i class="fas fa-lock"></i>
              <input
                type="password"
                id="password"
                v-model="password"
                required
                placeholder="Create a password"
              />
            </div>
          </div>
          <div class="form-group">
            <div class="input-wrapper">
              <i class="fas fa-lock"></i>
              <input
                type="password"
                id="confirmPassword"
                v-model="confirmPassword"
                required
                placeholder="Confirm your password"
              />
            </div>
          </div>
          <div class="form-actions">
            <button type="submit" :disabled="isLoading">
              {{ isLoading ? "Creating account..." : "Sign Up" }}
            </button>
          </div>
          <div class="form-footer">
            <p>Already have an account? <router-link to="/student/login">Login</router-link></p>
          </div>
        </form>
        
        <!-- Success Message -->
        <div v-if="signupSuccess" class="success-message">
          <div class="success-icon">✓</div>
          <h3>Account Created Successfully!</h3>
          <p>Your student account has been created. You can now sign in with your credentials.</p>
          <button @click="goToLogin" class="success-button">Go to Login</button>
        </div>
        
        <div v-if="error" class="error-message">
          {{ error }}
        </div>
      </div>
    </div>
    <!-- Background shapes -->
    <div class="shape shape-1"></div>
    <div class="shape shape-2"></div>
    <div class="shape shape-3"></div>
    <div class="shape shape-4"></div>
    <div class="dots dots-1"></div>
    <div class="dots dots-2"></div>
    <div class="curve curve-1"></div>
  </div>
</template>

<script>
export default {
  name: "StudentSignup",
  data() {
    return {
      name: "",
      email: "",
      studentId: "",
      password: "",
      confirmPassword: "",
      error: null,
      isLoading: false,
      signupSuccess: false
    };
  },
  methods: {
    goToLogin() {
      this.$router.push('/student/login');
    },
    async signup() {
      this.isLoading = true;
      this.error = null;
      
      if (this.password !== this.confirmPassword) {
        this.error = "Passwords do not match";
        this.isLoading = false;
        return;
      }
      
      try {
        const response = await fetch('http://localhost:8000/students/signup', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            name: this.name,
            email: this.email,
            student_id: this.studentId,
            password: this.password
          }),
        });
        
        const data = await response.json();
        
        if (!response.ok) {
          throw new Error(data.detail || 'Failed to create account');
        }
        
        this.signupSuccess = true;
        
        setTimeout(() => {
          this.$router.push('/student/login');
        }, 5000);
        
      } catch (err) {
        console.error("Signup error:", err);
        this.error = err.message || "Failed to create account. Please try again.";
      } finally {
        this.isLoading = false;
      }
    }
  }
};
</script>

<style scoped>
.signup-container {
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  background-image: url('/images/uic_building.jpg');
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  position: relative;
  overflow: hidden;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

.signup-container::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.85);
  z-index: 0;
}

.signup-content {
  display: flex;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(10px);
  border-radius: 20px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  width: 1000px;
  position: relative;
  z-index: 1;
  padding: 40px;
  margin: 20px;
}

.signup-left {
  flex: 1;
  padding: 40px;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.signup-right {
  flex: 1;
  padding: 40px;
}

h3 {
  font-size: 2.5rem;
  color: #333;
  margin-bottom: 20px;
  font-weight: 600;
}

.subtitle {
  font-size: 1.2rem;
  color: #666;
  line-height: 1.6;
  margin-bottom: 30px;
}

h2 {
  font-size: 2rem;
  color: #333;
  margin-bottom: 30px;
}

.form-group {
  margin-bottom: 25px;
}

.input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.input-wrapper i {
  position: absolute;
  left: 15px;
  color: #999;
}

input {
  width: 100%;
  padding: 15px 15px 15px 45px;
  border: 1px solid #e1e1e1;
  border-radius: 10px;
  font-size: 1rem;
  transition: all 0.3s ease;
  background: #f8f9fa;
}

input:focus {
  outline: none;
  border-color: #ff4b7d;
  box-shadow: 0 0 0 3px rgba(255, 75, 125, 0.1);
}

button {
  width: 100%;
  padding: 15px;
  background-color: #ff4b7d;
  color: white;
  border: none;
  border-radius: 10px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.3s ease;
}

button:hover {
  background-color: #ff3368;
}

button:disabled {
  background-color: #ffb3c7;
  cursor: not-allowed;
}

.form-footer {
  text-align: center;
  margin-top: 25px;
  color: #666;
}

.form-footer a {
  color: #ff4b7d;
  text-decoration: none;
  font-weight: 500;
}

.error-message {
  background-color: #fff2f5;
  color: #ff4b7d;
  padding: 15px;
  border-radius: 10px;
  margin-top: 20px;
  text-align: center;
}

.success-message {
  text-align: center;
  padding: 30px;
}

.success-icon {
  width: 60px;
  height: 60px;
  background-color: #4CAF50;
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 30px;
  margin: 0 auto 20px;
}

.success-button {
  margin-top: 20px;
  background-color: #4CAF50;
}

.success-button:hover {
  background-color: #388E3C;
}

/* Background shapes */
.shape {
  position: absolute;
  z-index: 0;
}

.shape-1 {
  width: 300px;
  height: 300px;
  background-color: #a7e8ff;
  border-radius: 50%;
  top: -150px;
  left: -150px;
  opacity: 0.3;
}

.shape-2 {
  width: 200px;
  height: 200px;
  background-color: #ffd875;
  border-radius: 50%;
  bottom: -100px;
  right: -100px;
  opacity: 0.2;
}

.shape-3 {
  width: 150px;
  height: 150px;
  background-color: #ff4b7d;
  border-radius: 50%;
  top: 50%;
  right: -75px;
  opacity: 0.1;
}

.shape-4 {
  width: 100px;
  height: 100px;
  background-color: #a7e8ff;
  border-radius: 50%;
  bottom: 50px;
  left: 50px;
  opacity: 0.2;
}

.dots {
  position: absolute;
  width: 100px;
  height: 100px;
  background-image: radial-gradient(#333 2px, transparent 2px);
  background-size: 10px 10px;
  opacity: 0.1;
}

.dots-1 {
  top: 20%;
  right: 20%;
}

.dots-2 {
  bottom: 20%;
  left: 20%;
}

.curve {
  position: absolute;
  width: 200px;
  height: 200px;
  border: 2px solid #ff4b7d;
  border-radius: 50%;
  opacity: 0.1;
}

.curve-1 {
  top: 30%;
  left: 30%;
  transform: rotate(45deg);
}

@media (max-width: 768px) {
  .signup-content {
    flex-direction: column;
    width: 100%;
    margin: 0;
    border-radius: 0;
  }

  .signup-left, .signup-right {
    padding: 20px;
  }

  h3 {
    font-size: 2rem;
  }

  .subtitle {
    font-size: 1rem;
  }
}
</style>
