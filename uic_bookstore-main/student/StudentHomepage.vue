<template>
  <StudentLayout>
    <div class="student-homepage">
      <header class="header">
        <div class="logo">
          <h1>UIC Bookstore Online Inquiry & Inventory System</h1>
        </div>
        <div class="header-right">
          <NotificationSystem @notification-panel-toggled="handleNotificationToggle" />
          <div class="user-menu" ref="userMenu">
            <div class="user-info" @click="toggleUserDropdown">
              <img :src="profilePictureUrl || defaultProfilePicture" alt="Profile" class="profile-picture">
              <span class="username">{{ studentName }}</span>
              <i class="fas fa-chevron-down"></i>
            </div>
            <div class="dropdown-menu" v-if="showUserDropdown">
              <ul>
                <li><a href="#" @click.prevent="openProfileModal">My Profile</a></li>
                <li><router-link to="/student/settings">Settings</router-link></li>
                <li><a href="#" @click.prevent="logout">Logout</a></li>
              </ul>
            </div>
          </div>
        </div>
      </header>
      
      <main class="main-content">
        <div class="content-container">
          <div class="left-column">
            <div class="welcome-text">
              <h1 class="title">UIC Bookstore Online</h1>
              <h2 class="subtitle">Inquiry and Inventory System</h2>
              <h3 class="campus">(Fr. Seiga Campus)</h3>
              
              <p class="description">
                This UIC Bookstore Online Inquiry and Inventory System was made by the 3rd Year Student of
                Bachelor of Science in Information Technology. We encourage you to use this platform in order to
                have a applicable and usable website to encourage students to have this kind of platform online.
              </p>
            </div>
          </div>
          
          <div class="right-column">
            <div class="carousel-container">
              <div class="carousel">
                <div class="carousel-slide" v-for="(slide, index) in slides" :key="index" 
                     :class="{ active: currentSlide === index }">
                  <img :src="slide.image" :alt="slide.alt" class="campus-image">
                </div>
                
                <button class="carousel-control prev" @click="prevSlide">
                  <i class="fas fa-chevron-left"></i>
                </button>
                
                <button class="carousel-control next" @click="nextSlide">
                  <i class="fas fa-chevron-right"></i>
                </button>
                
                <div class="carousel-indicators">
                  <span v-for="(slide, index) in slides" :key="'dot-'+index" 
                        :class="{ active: currentSlide === index }"
                        @click="goToSlide(index)"></span>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <div class="action-button-container">
          <router-link to="/student/books" class="action-button">
            GO TO STORE <i class="fas fa-arrow-right"></i>
          </router-link>
        </div>
      </main>
      
      <!-- Add Profile Modal -->
      <StudentProfile 
        :show="showProfileModal" 
        @close="closeProfileModal"
        @profile-updated="handleProfileUpdated"
      />
    </div>
  </StudentLayout>
</template>

<script>
import StudentProfile from './StudentProfile.vue';
import NotificationSystem from '../components/NotificationSystem.vue';
import StudentLayout from '../layouts/StudentLayout.vue';

export default {
  name: "StudentHomepage",
  components: {
    StudentProfile,
    NotificationSystem,
    StudentLayout
  },
  data() {
    return {
      showUserDropdown: false,
      showProfileModal: false,
      studentName: "Student",
      studentEmail: "",
      studentId: "",
      profilePictureUrl: null,
      defaultProfilePicture: "https://via.placeholder.com/40?text=User",
      currentSlide: 0,
      slides: [
        {
          image: "/images/uic_building.jpg",
          alt: "UIC Building"
        },
        {
          image: "/images/uic_campus.jpg",
          alt: "UIC Campus"
        }
      ],
      carouselInterval: null
    };
  },
  created() {
    // Check if user is logged in
    const isLoggedIn = localStorage.getItem('studentLoggedIn');
    const token = localStorage.getItem('studentToken');
    
    if (!isLoggedIn || !token) {
      this.$router.push('/student/login');
      return;
    }
    
    // Get student info from localStorage
    const name = localStorage.getItem('studentName');
    const email = localStorage.getItem('studentEmail');
    const id = localStorage.getItem('studentId');
    const profilePic = localStorage.getItem('profilePicture');
    
    if (name) this.studentName = name;
    if (email) this.studentEmail = email;
    if (id) this.studentId = id;
    if (profilePic) this.profilePictureUrl = profilePic;
    
    // Verify token with backend
    this.verifyToken(token);
  },
  mounted() {
    // Add global click event listener to close dropdown when clicking outside
    document.addEventListener('click', this.handleOutsideClick);
    
    // Start carousel autoplay
    this.startCarousel();
  },
  beforeUnmount() {
    // Remove event listener when component is destroyed
    document.removeEventListener('click', this.handleOutsideClick);
    
    // Clear carousel interval
    this.stopCarousel();
  },
  methods: {
    async verifyToken(token) {
      const studentId = localStorage.getItem('studentId');
      if (!studentId) {
        this.logout();
        return;
      }
      
      try {
        const response = await fetch(`http://localhost:8000/students/me?student_id=${encodeURIComponent(studentId)}`);
        
        if (!response.ok) {
          // Student ID is invalid, redirect to login
          this.logout();
          return;
        }
        
        // Update user info with data from server
        const userData = await response.json();
        this.studentName = userData.name;
        this.studentEmail = userData.email;
        this.studentId = userData.student_id;
        
        // Save database ID for future use with API calls
        localStorage.setItem('studentDatabaseId', userData.id);
        
        // Update localStorage
        localStorage.setItem('studentName', userData.name);
        localStorage.setItem('studentEmail', userData.email);
        localStorage.setItem('studentId', userData.student_id);
        
        // Update profile picture if available
        if (userData.profile_picture) {
          const profilePicUrl = `http://localhost:8000/uploads/${userData.profile_picture}`;
          this.profilePictureUrl = profilePicUrl;
          localStorage.setItem('profilePicture', profilePicUrl);
        }
      } catch (error) {
        console.error('Error verifying token:', error);
      }
    },
    handleNotificationToggle(isOpen) {
      // Close user dropdown if notifications panel is open
      if (isOpen) {
        this.showUserDropdown = false;
      }
    },
    toggleUserDropdown() {
      this.showUserDropdown = !this.showUserDropdown;
    },
    handleOutsideClick(event) {
      // Check if click is outside the dropdown
      if (this.$refs.userMenu && !this.$refs.userMenu.contains(event.target)) {
        this.showUserDropdown = false;
      }
    },
    logout() {
      // Clear user data
      localStorage.removeItem('studentLoggedIn');
      localStorage.removeItem('studentName');
      localStorage.removeItem('studentEmail');
      localStorage.removeItem('studentId');
      localStorage.removeItem('studentToken');
      
      // Redirect to login page
      this.$router.push('/student/login');
    },
    openProfileModal() {
      this.showProfileModal = true;
      this.showUserDropdown = false; // Close dropdown when opening modal
    },
    closeProfileModal() {
      this.showProfileModal = false;
    },
    handleProfileUpdated(data) {
      // Update UI with new profile data
      if (data.name) {
        this.studentName = data.name;
        localStorage.setItem('studentName', data.name);
      }
      
      // Update profile picture if changed
      if (data.profilePicture) {
        this.profilePictureUrl = data.profilePicture;
        localStorage.setItem('profilePicture', data.profilePicture);
        console.log("Profile picture updated in homepage:", data.profilePicture);
      }
    },
    // Carousel methods
    startCarousel() {
      this.carouselInterval = setInterval(() => {
        this.nextSlide();
      }, 5000); // Change slide every 5 seconds
    },
    
    stopCarousel() {
      if (this.carouselInterval) {
        clearInterval(this.carouselInterval);
      }
    },
    
    nextSlide() {
      this.currentSlide = (this.currentSlide + 1) % this.slides.length;
    },
    
    prevSlide() {
      this.currentSlide = (this.currentSlide - 1 + this.slides.length) % this.slides.length;
    },
    
    goToSlide(index) {
      this.currentSlide = index;
    }
  }
};
</script>

<style scoped>
.student-homepage {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: white;
  font-family: Arial, sans-serif;
}

.header {
  background-color: white;
  color: black;
  padding: 0.75rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #f0f0f0;
}

.logo h1 {
  margin: 0;
  font-size: 1.2rem;
  font-weight: 600;
  color: #333;
}

.header-right {
  display: flex;
  align-items: center;
}

.notification-icon {
  margin-right: 1.5rem;
  font-size: 1.2rem;
  color: #444;
  cursor: pointer;
}

.user-menu {
  position: relative;
}

.user-info {
  display: flex;
  align-items: center;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 4px;
  transition: background-color 0.3s;
}

.user-info:hover {
  background-color: #f5f5f5;
}

.profile-picture {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid #f0f0f0;
}

.username {
  margin: 0 0.5rem;
  font-weight: 500;
  color: #333;
}

.dropdown-menu {
  position: absolute;
  top: 100%;
  right: 0;
  background-color: white;
  border-radius: 4px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  width: 200px;
  z-index: 100;
  margin-top: 0.5rem;
}

.dropdown-menu ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.dropdown-menu li a {
  display: block;
  padding: 0.75rem 1rem;
  color: #333;
  text-decoration: none;
  transition: background-color 0.3s;
}

.dropdown-menu li a:hover {
  background-color: #f5f5f5;
}

.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  padding: 0;
}

.content-container {
  display: flex;
  flex: 1;
  padding: 2rem;
}

.left-column {
  flex: 1;
  padding: 2rem;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.right-column {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
}

.welcome-text {
  max-width: 600px;
}

.title {
  color: #FF9DAE; /* Light pink */
  font-size: 2.5rem;
  margin: 0;
  font-weight: 700;
}

.subtitle {
  color: #FF9DAE; /* Light pink */
  font-size: 2rem;
  margin-top: 0.5rem;
  font-weight: 700;
}

.campus {
  color: #FF9DAE; /* Light pink */
  font-size: 1.5rem;
  margin-top: 0.5rem;
  font-weight: 600;
}

.description {
  margin-top: 2rem;
  line-height: 1.6;
  color: #444;
  font-size: 1rem;
}

.campus-image {
  max-width: 100%;
  height: auto;
  display: block;
}

.action-button-container {
  display: flex;
  justify-content: flex-end;
  padding: 2rem;
}

.action-button {
  display: inline-flex;
  align-items: center;
  background-color: white;
  color: #FF9DAE; /* Light pink */
  border: 1px solid #FF9DAE;
  padding: 0.75rem 2rem;
  border-radius: 50px;
  text-decoration: none;
  font-weight: 600;
  transition: all 0.3s;
}

.action-button i {
  margin-left: 0.5rem;
}

.action-button:hover {
  background-color: #FF9DAE;
  color: white;
}

.carousel-container {
  width: 100%;
  max-width: 800px;
  position: relative;
}

.carousel {
  position: relative;
  overflow: hidden;
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.carousel-slide {
  display: none;
  width: 100%;
}

.carousel-slide.active {
  display: block;
  animation: fadeIn 0.8s ease-in-out;
}

.carousel-control {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  background-color: rgba(255, 255, 255, 0.7);
  border: none;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  opacity: 0.8;
  transition: opacity 0.3s;
  z-index: 2;
}

.carousel-control:hover {
  opacity: 1;
  background-color: rgba(255, 255, 255, 0.9);
}

.carousel-control.prev {
  left: 10px;
}

.carousel-control.next {
  right: 10px;
}

.carousel-indicators {
  position: absolute;
  bottom: 15px;
  width: 100%;
  display: flex;
  justify-content: center;
  gap: 8px;
  z-index: 2;
}

.carousel-indicators span {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background-color: rgba(255, 255, 255, 0.5);
  cursor: pointer;
  transition: all 0.3s;
}

.carousel-indicators span.active {
  background-color: white;
  transform: scale(1.2);
}

@keyframes fadeIn {
  from { opacity: 0.4; }
  to { opacity: 1; }
}
</style>
