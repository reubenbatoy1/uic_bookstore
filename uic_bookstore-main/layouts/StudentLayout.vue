<template>
  <div class="student-layout">
    <!-- Main content -->
    <slot></slot>

    <!-- Feedback Button (always visible) -->
    <FeedbackButton />
  </div>
</template>

<script>
import FeedbackButton from '../components/FeedbackButton.vue';

export default {
  name: 'StudentLayout',
  components: {
    FeedbackButton
  }
}
</script>

<style scoped>
.student-layout {
  min-height: 100vh;
  position: relative;
}
</style> 