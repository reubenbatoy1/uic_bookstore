<template>
  <div class="login-container">
    <div class="login-content">
      <div class="login-left">
        <h3>Welcome to UIC Bookstore Online Inquiry!</h3>
        <p class="subtitle">You can sign in to access with your existing account.</p>
      </div>
      <div class="login-right">
        <h2>Sign In</h2>
        <form @submit.prevent="login">
          <div class="form-group">
            <div class="input-wrapper">
              <i class="fas fa-user"></i>
              <input
                type="email"
                id="email"
                v-model="email"
                required
                placeholder="Username or email"
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
                placeholder="Password"
              />
            </div>
          </div>
          <div class="form-options">
            <label class="remember-me">
              <input type="checkbox" />
              <span>Remember me</span>
            </label>
            <a href="#" class="forgot-password">Forgot password?</a>
          </div>
          <div class="form-actions">
            <button type="submit" :disabled="isLoading">
              {{ isLoading ? "Signing in..." : "Sign In" }}
            </button>
          </div>
          <div class="form-footer">
            <p>New here? <router-link to="/student/signup">Create an Account</router-link></p>
          </div>
        </form>
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
  name: "StudentLogin",
  data() {
    return {
      email: "",
      password: "",
      error: null,
      isLoading: false
    };
  },
  methods: {
    async login() {
      this.isLoading = true;
      this.error = null;
      
      try {
        console.log("Attempting login with:", { email: this.email });
        
        const response = await fetch('http://localhost:8000/students/login', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            email: this.email,
            password: this.password
          }),
        });
        
        console.log("Login response status:", response.status);
        
        let data;
        try {
          data = await response.json();
          console.log("Login response data:", data);
        } catch (e) {
          console.error("Error parsing response:", e);
        }
        
        if (!response.ok) {
          throw new Error(data?.detail || 'Invalid credentials');
        }
        
        localStorage.setItem('studentToken', data.access_token);
        localStorage.setItem('studentLoggedIn', 'true');
        
        const profileResponse = await fetch(`http://localhost:8000/students/me?email=${encodeURIComponent(this.email)}`);
        
        console.log("Profile response status:", profileResponse.status);
        
        if (profileResponse.ok) {
          const profileData = await profileResponse.json();
          console.log("Profile data:", profileData);
          
          localStorage.setItem('studentName', profileData.name);
          localStorage.setItem('studentEmail', profileData.email);
          localStorage.setItem('studentId', profileData.student_id);
          localStorage.setItem('studentDatabaseId', profileData.id);
          
          if (profileData.profile_picture) {
            localStorage.setItem('profilePicture', `http://localhost:8000/uploads/${profileData.profile_picture}`);
          }
        } else {
          console.error("Failed to fetch profile:", await profileResponse.text());
        }
        
        this.$router.push('/student/homepage');
      } catch (err) {
        console.error("Login error:", err);
        this.error = err.message || "Invalid email or password. Please try again.";
      } finally {
        this.isLoading = false;
      }
    }
  }
};
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  background-image: url('/images/uic_building.jpg'); /* Add your image path here */
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  position: relative;
  overflow: hidden;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

/* Add an overlay to ensure text readability */
.login-container::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.85); /* Semi-transparent white overlay */
  z-index: 0;
}

.login-content {
  display: flex;
  background: rgba(255, 255, 255, 0.9); /* Make the content box slightly transparent */
  backdrop-filter: blur(10px); /* Add blur effect to the background */
  border-radius: 20px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  width: 1000px;
  position: relative;
  z-index: 1;
  padding: 40px;
  margin: 20px;
}

.login-left {
  flex: 1;
  padding: 40px;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.login-right {
  flex: 1;
  padding: 40px;
}

h1 {
  font-size: 3.5rem;
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
h3 {
  font-size: 2.5rem;
  color: #333;
  
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

.form-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
}

.remember-me {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #666;
  font-size: 0.9rem;
}

.remember-me input[type="checkbox"] {
  margin: 0;
  width: auto;
  padding: 0;
}

.forgot-password {
  color: #666;
  text-decoration: none;
  font-size: 0.9rem;
  transition: color 0.3s ease;
}

.forgot-password:hover {
  color: #ff4b7d;
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
  .login-content {
    flex-direction: column;
    width: 100%;
    margin: 0;
    border-radius: 0;
  }

  .login-left, .login-right {
    padding: 20px;
  }

  h1 {
    font-size: 2.5rem;
  }

  .subtitle {
    font-size: 1rem;
  }
}
</style>
