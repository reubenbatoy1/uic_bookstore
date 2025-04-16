<template>
  <div class="student-store">
    <div class="store-header">
      <h2>UIC Bookstore</h2>
      <div class="user-controls">
        <NotificationSystem />
        <div class="user-profile">
          <span>{{ studentName }}</span>
          <div class="profile-image">
            <img :src="profilePicture || '/default-profile.png'" alt="Profile Picture" />
          </div>
        </div>
        <button class="logout-btn" @click="logout">Logout</button>
      </div>
    </div>
    // ... existing code ...
  </div>
</template>

<script>
import NotificationSystem from './NotificationSystem.vue';
// ... existing code ...

export default {
  components: {
    NotificationSystem
  },
  // ... existing code ...
}
</script>

<style scoped>
// ... existing code ...

.user-controls {
  display: flex;
  align-items: center;
}

// ... existing code ...
</style> 