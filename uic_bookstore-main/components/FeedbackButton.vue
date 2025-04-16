<template>
  <div class="feedback-system">
    <!-- Floating Action Button -->
    <button class="fab-button" @click="openFeedbackModal" title="Send Feedback">
      <i class="fas fa-comment-dots"></i>
    </button>

    <!-- Feedback Modal -->
    <div class="feedback-modal" v-if="showModal" @click.self="closeFeedbackModal">
      <div class="modal-content">
        <div class="modal-header">
          <h3>Help Us Improve!</h3>
          <button class="close-button" @click="closeFeedbackModal">&times;</button>
        </div>
        
        <div class="modal-body">
          <!-- App Description -->
          <div class="app-description">
            <h4>About UIC Bookstore Online</h4>
            <p>The UIC Bookstore Online Inquiry & Inventory System is designed to help students easily check the availability of books, uniforms, and other school supplies. Your feedback helps us improve our services and better meet your needs.</p>
          </div>

          <form @submit.prevent="submitFeedback">
            <div class="form-group">
              <label for="feedbackType">Type of Feedback</label>
              <select id="feedbackType" v-model="feedback.type" required>
                <option value="">Select type</option>
                <option value="suggestion">Suggestion</option>
                <option value="bug">Bug Report</option>
                <option value="complaint">Complaint</option>
                <option value="feature">Feature Request</option>
                <option value="other">Other</option>
              </select>
            </div>

            <div class="form-group">
              <label for="feedbackMessage">Your Message</label>
              <textarea 
                id="feedbackMessage" 
                v-model="feedback.message" 
                rows="5" 
                placeholder="Tell us what you think..."
                required
              ></textarea>
            </div>

            <!-- Contact Permission -->
            <div class="form-group contact-permission">
              <label class="checkbox-label">
                <input 
                  type="checkbox" 
                  v-model="feedback.canContact"
                >
                <span class="checkbox-text">
                  I agree to be contacted about this feedback if needed for clarification or follow-up.
                </span>
              </label>
            </div>

            <!-- Additional Information -->
            <div class="additional-info">
              <p>By submitting feedback, you help us:</p>
              <ul>
                <li>Improve the user experience</li>
                <li>Fix technical issues</li>
                <li>Add new features</li>
                <li>Better serve the UIC community</li>
              </ul>
              <p class="privacy-note">Your feedback will be handled according to our privacy policy. If you've agreed to be contacted, we'll only use your contact information for matters related to this feedback.</p>
            </div>

            <div class="form-actions">
              <button type="button" class="cancel-btn" @click="closeFeedbackModal">Cancel</button>
              <button type="submit" class="submit-btn" :disabled="isSubmitting">
                {{ isSubmitting ? 'Sending...' : 'Send Feedback' }}
              </button>
            </div>
          </form>

          <div v-if="error" class="error-message">{{ error }}</div>
          <div v-if="successMessage" class="success-message">{{ successMessage }}</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'FeedbackButton',
  data() {
    return {
      showModal: false,
      isSubmitting: false,
      error: null,
      successMessage: null,
      feedback: {
        type: '',
        message: '',
        canContact: false
      }
    }
  },
  methods: {
    openFeedbackModal() {
      this.showModal = true;
      this.resetForm();
    },
    closeFeedbackModal() {
      this.showModal = false;
      this.resetForm();
    },
    resetForm() {
      this.feedback = {
        type: '',
        message: '',
        canContact: false
      };
      this.error = null;
      this.successMessage = null;
    },
    async submitFeedback() {
      this.isSubmitting = true;
      this.error = null;
      this.successMessage = null;

      try {
        const studentId = localStorage.getItem('studentDatabaseId');
        if (!studentId) {
          throw new Error('You must be logged in to submit feedback');
        }

        const response = await fetch('http://localhost:8000/students/feedback', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            student_id: studentId,
            type: this.feedback.type,
            message: this.feedback.message,
            can_contact: this.feedback.canContact
          })
        });

        if (!response.ok) {
          const data = await response.json();
          throw new Error(data.detail || 'Failed to submit feedback');
        }

        this.successMessage = 'Thank you for your feedback! We appreciate your help in improving our service.';
        setTimeout(() => {
          this.closeFeedbackModal();
        }, 2000);
      } catch (error) {
        this.error = error.message;
      } finally {
        this.isSubmitting = false;
      }
    }
  }
}
</script>

<style scoped>
.feedback-system {
  position: fixed;
  bottom: 30px;
  right: 30px;
  z-index: 1000;
}

.fab-button {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background-color: #ff4b7d;
  color: white;
  border: none;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  transition: all 0.3s ease;
}

.fab-button:hover {
  transform: scale(1.1);
  background-color: #ff3366;
}

.feedback-modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1001;
}

.modal-content {
  background-color: white;
  border-radius: 8px;
  width: 90%;
  max-width: 600px;
  max-height: 90vh;
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

.modal-header h3 {
  margin: 0;
  color: #333;
  font-size: 1.2rem;
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
  color: #ff4b7d;
}

.modal-body {
  padding: 1.5rem;
  max-height: 80vh;
  overflow-y: auto;
}

.app-description {
  margin-bottom: 1.5rem;
  padding: 1rem;
  background-color: #f8f9fa;
  border-radius: 4px;
}

.app-description h4 {
  margin: 0 0 0.5rem 0;
  color: #333;
  font-size: 1.1rem;
}

.app-description p {
  margin: 0;
  color: #666;
  font-size: 0.9rem;
  line-height: 1.5;
}

.contact-permission {
  margin: 1.5rem 0;
}

.checkbox-label {
  display: flex;
  align-items: flex-start;
  cursor: pointer;
}

.checkbox-label input[type="checkbox"] {
  margin-top: 0.25rem;
  margin-right: 0.5rem;
}

.checkbox-text {
  font-size: 0.9rem;
  color: #555;
  line-height: 1.4;
}

.additional-info {
  margin: 1.5rem 0;
  padding: 1rem;
  background-color: #fff3e0;
  border-radius: 4px;
  font-size: 0.9rem;
}

.additional-info p {
  margin: 0 0 0.5rem 0;
  color: #555;
}

.additional-info ul {
  margin: 0.5rem 0;
  padding-left: 1.5rem;
  color: #666;
}

.additional-info li {
  margin-bottom: 0.25rem;
}

.privacy-note {
  margin-top: 1rem !important;
  font-size: 0.8rem;
  color: #777;
  font-style: italic;
}

.form-group {
  margin-bottom: 1.5rem;
}

label {
  display: block;
  margin-bottom: 0.5rem;
  color: #333;
  font-weight: 500;
}

select, textarea {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
  transition: border-color 0.3s;
}

select:focus, textarea:focus {
  outline: none;
  border-color: #ff4b7d;
}

textarea {
  resize: vertical;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  margin-top: 1.5rem;
}

.cancel-btn, .submit-btn {
  padding: 0.75rem 1.5rem;
  border-radius: 4px;
  font-size: 0.9rem;
  cursor: pointer;
  transition: all 0.3s;
}

.cancel-btn {
  background-color: #f5f5f5;
  border: none;
  color: #666;
}

.cancel-btn:hover {
  background-color: #e0e0e0;
}

.submit-btn {
  background-color: #ff4b7d;
  border: none;
  color: white;
}

.submit-btn:hover {
  background-color: #ff3366;
}

.submit-btn:disabled {
  background-color: #ffb3c6;
  cursor: not-allowed;
}

.error-message {
  margin-top: 1rem;
  padding: 0.75rem;
  background-color: #ffebee;
  color: #c62828;
  border-radius: 4px;
}

.success-message {
  margin-top: 1rem;
  padding: 0.75rem;
  background-color: #e8f5e9;
  color: #2e7d32;
  border-radius: 4px;
}
</style> 