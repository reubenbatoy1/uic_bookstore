<template>
  <i :class="['fas', `fa-${name}`]" :style="customStyle"></i>
</template>

<script>
export default {
  name: 'Icon',
  props: {
    name: {
      type: String,
      required: true
    },
    size: {
      type: String,
      default: 'md'
    },
    color: {
      type: String,
      default: null
    }
  },
  computed: {
    customStyle() {
      const style = {};
      
      // Set font size based on size prop
      if (this.size === 'xs') style.fontSize = '0.75rem';
      else if (this.size === 'sm') style.fontSize = '0.875rem';
      else if (this.size === 'md') style.fontSize = '1rem';
      else if (this.size === 'lg') style.fontSize = '1.25rem';
      else if (this.size === 'xl') style.fontSize = '1.5rem';
      else if (this.size === '2x') style.fontSize = '2rem';
      
      // Set color if provided
      if (this.color) style.color = this.color;
      
      return style;
    }
  }
};
</script>

<style scoped>
i {
  display: inline-flex;
  align-items: center;
  justify-content: center;
}
</style> 