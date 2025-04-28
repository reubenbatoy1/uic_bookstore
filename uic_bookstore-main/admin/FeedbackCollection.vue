<template>
  <div class="feedback-collection">
    <div class="page-header">
      <h1>Feedback Collection</h1>
      <div class="filters">
        <select v-model="typeFilter" class="filter-select">
          <option value="">All Types</option>
          <option value="suggestion">Suggestions</option>
          <option value="bug">Bug Reports</option>
          <option value="complaint">Complaints</option>
          <option value="feature">Feature Requests</option>
          <option value="other">Other</option>
        </select>
        <select v-model="statusFilter" class="filter-select">
          <option value="">All Statuses</option>
          <option value="new">New</option>
          <option value="in_progress">In Progress</option>
          <option value="resolved">Resolved</option>
          <option value="closed">Closed</option>
        </select>
      </div>
    </div>

    <div v-if="loading" class="loading-state">
      <div class="spinner"></div>
      <p>Loading feedback submissions...</p>
    </div>

    <div v-else-if="error" class="error-state">
      <p>{{ error }}</p>
      <button @click="loadFeedback" class="retry-button">Retry</button>
    </div>

    <div v-else-if="feedbackList.length === 0" class="empty-state">
      <div class="empty-icon">📬</div>
      <h3>No feedback submissions found</h3>
      <p v-if="typeFilter || statusFilter">Try changing the filters to see more results.</p>
      <p v-else>When students submit feedback, it will appear here.</p>
    </div>

    <div v-else class="feedback-list">
      <div 
        v-for="feedback in filteredFeedback" 
        :key="feedback.id" 
        class="feedback-card"
        :class="{ 'highlighted': highlightFeedbackId === feedback.id }"
      >
        <div class="feedback-header">
          <div class="feedback-meta">
            <span class="feedback-date">{{ formatDate(feedback.created_at) }}</span>
            <span :class="['feedback-type', feedback.type]">{{ formatType(feedback.type) }}</span>
            <span :class="['feedback-status', feedback.status]">{{ formatStatus(feedback.status) }}</span>
            <span v-if="feedback.can_contact" class="contact-badge" title="Student can be contacted">
              <i class="fas fa-envelope"></i>
            </span>
          </div>
          <div class="student-info">
            <strong>{{ feedback.student_name }}</strong>
            <span class="student-id">{{ feedback.student_id }}</span>
          </div>
        </div>

        <div class="feedback-content">
          <p>{{ feedback.message }}</p>
        </div>

        <div class="feedback-actions">
          <select v-model="feedback.status" @change="updateFeedbackStatus(feedback.id, feedback.status)" class="status-select">
            <option value="new">New</option>
            <option value="in_progress">In Progress</option>
            <option value="resolved">Resolved</option>
            <option value="closed">Closed</option>
          </select>
          
          <button @click="openNotesModal(feedback)" class="notes-button">
            <i class="fas fa-sticky-note"></i> Admin Notes
          </button>
        </div>
      </div>
    </div>

    <!-- Pagination controls -->
    <div v-if="feedbackList.length > 0" class="pagination">
      <button 
        :disabled="currentPage === 1" 
        @click="currentPage--" 
        class="pagination-button"
      >
        Previous
      </button>
      <span class="page-info">Page {{ currentPage }} of {{ totalPages }}</span>
      <button 
        :disabled="currentPage === totalPages" 
        @click="currentPage++" 
        class="pagination-button"
      >
        Next
      </button>
    </div>

    <!-- Admin Notes Modal -->
    <div v-if="showNotesModal" class="modal-overlay" @click.self="closeNotesModal">
      <div class="modal-content">
        <div class="modal-header">
          <h3>Admin Notes</h3>
          <button class="close-button" @click="closeNotesModal">&times;</button>
        </div>
        <div class="modal-body">
          <textarea 
            v-model="selectedFeedback.admin_notes" 
            rows="5" 
            placeholder="Add your notes about this feedback item here..."
            class="notes-textarea"
          ></textarea>
          <div class="modal-actions">
            <button @click="closeNotesModal" class="cancel-button">Cancel</button>
            <button @click="saveAdminNotes" class="save-button">Save Notes</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'FeedbackCollection',
  data() {
    return {
      feedbackList: [],
      loading: true,
      error: null,
      typeFilter: '',
      statusFilter: '',
      currentPage: 1,
      itemsPerPage: 10,
      showNotesModal: false,
      selectedFeedback: null,
      highlightFeedbackId: null
    }
  },
  computed: {
    filteredFeedback() {
      let filtered = this.feedbackList;
      
      if (this.typeFilter) {
        filtered = filtered.filter(item => item.type === this.typeFilter);
      }
      
      if (this.statusFilter) {
        filtered = filtered.filter(item => item.status === this.statusFilter);
      }
      
      // Apply pagination
      const startIndex = (this.currentPage - 1) * this.itemsPerPage;
      const endIndex = startIndex + this.itemsPerPage;
      
      return filtered.slice(startIndex, endIndex);
    },
    totalPages() {
      // Calculate total pages based on filtered items
      let filtered = this.feedbackList;
      
      if (this.typeFilter) {
        filtered = filtered.filter(item => item.type === this.typeFilter);
      }
      
      if (this.statusFilter) {
        filtered = filtered.filter(item => item.status === this.statusFilter);
      }
      
      return Math.ceil(filtered.length / this.itemsPerPage);
    }
  },
  created() {
    this.loadFeedback();
    
    // Check if we were directed here from a notification
    const params = new URLSearchParams(window.location.search);
    if (params.get('highlight')) {
      this.highlightFeedbackId = parseInt(params.get('highlight'));
    }
  },
  mounted() {
    // If we have a highlighted feedback, scroll to it
    this.$nextTick(() => {
      this.scrollToHighlightedFeedback();
    });
  },
  updated() {
    // If we have a highlighted feedback, scroll to it after update
    this.$nextTick(() => {
      this.scrollToHighlightedFeedback();
    });
  },
  methods: {
    async loadFeedback() {
      this.loading = true;
      this.error = null;
      
      try {
        const response = await fetch('http://localhost:8000/admin/feedback');
        
        if (!response.ok) {
          throw new Error('Failed to load feedback data');
        }
        
        const data = await response.json();
        // Sort feedback by created_at date in descending order (newest first)
        this.feedbackList = data.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
        
        // Reset to page 1 when reloading data
        this.currentPage = 1;
      } catch (error) {
        this.error = error.message || 'An error occurred while fetching feedback data';
      } finally {
        this.loading = false;
      }
    },
    formatDate(dateString) {
      const options = { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' };
      return new Date(dateString).toLocaleDateString(undefined, options);
    },
    formatType(type) {
      const typeMap = {
        'suggestion': 'Suggestion',
        'bug': 'Bug Report',
        'complaint': 'Complaint',
        'feature': 'Feature Request',
        'other': 'Other'
      };
      
      return typeMap[type] || type;
    },
    formatStatus(status) {
      const statusMap = {
        'new': 'New',
        'in_progress': 'In Progress',
        'resolved': 'Resolved',
        'closed': 'Closed'
      };
      
      return statusMap[status] || status;
    },
    async updateFeedbackStatus(feedbackId, newStatus) {
      try {
        const response = await fetch(`http://localhost:8000/admin/feedback/${feedbackId}/status`, {
          method: 'PATCH',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ status: newStatus })
        });
        
        if (!response.ok) {
          throw new Error('Failed to update status');
        }
        
        // No need to reload the entire list; the local list is already updated through v-model
      } catch (error) {
        alert(`Error updating status: ${error.message}`);
        // Reload the list to revert changes in case of error
        this.loadFeedback();
      }
    },
    openNotesModal(feedback) {
      this.selectedFeedback = { ...feedback };
      this.showNotesModal = true;
    },
    closeNotesModal() {
      this.showNotesModal = false;
      this.selectedFeedback = null;
    },
    async saveAdminNotes() {
      if (!this.selectedFeedback) return;
      
      try {
        const response = await fetch(`http://localhost:8000/admin/feedback/${this.selectedFeedback.id}/notes`, {
          method: 'PATCH',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ admin_notes: this.selectedFeedback.admin_notes })
        });
        
        if (!response.ok) {
          throw new Error('Failed to save notes');
        }
        
        // Update the note in the local list
        const index = this.feedbackList.findIndex(f => f.id === this.selectedFeedback.id);
        if (index !== -1) {
          this.feedbackList[index].admin_notes = this.selectedFeedback.admin_notes;
        }
        
        this.closeNotesModal();
      } catch (error) {
        alert(`Error saving notes: ${error.message}`);
      }
    },
    scrollToHighlightedFeedback() {
      if (this.highlightFeedbackId) {
        const highlightedElement = document.querySelector(`.feedback-card.highlighted`);
        if (highlightedElement) {
          highlightedElement.scrollIntoView({ behavior: 'smooth', block: 'center' });
          
          // Clear highlight after 5 seconds
          setTimeout(() => {
            this.highlightFeedbackId = null;
          }, 5000);
        }
      }
    }
  }
}
</script>

<style scoped>
.feedback-collection {
  padding: 1.5rem;
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.page-header h1 {
  margin: 0;
  color: #333;
  font-size: 1.8rem;
}

.filters {
  display: flex;
  gap: 1rem;
}

.filter-select {
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  background-color: white;
  font-size: 0.9rem;
}

.loading-state, .error-state, .empty-state {
  padding: 3rem;
  text-align: center;
  background-color: #f9f9f9;
  border-radius: 8px;
  margin: 2rem 0;
}

.spinner {
  border: 4px solid rgba(0, 0, 0, 0.1);
  border-radius: 50%;
  border-top: 4px solid #ff4b7d;
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
  margin: 0 auto 1rem;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.empty-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.retry-button {
  margin-top: 1rem;
  padding: 0.5rem 1rem;
  background-color: #ff4b7d;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.feedback-list {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.feedback-card {
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  padding: 1.5rem;
}

.feedback-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 1rem;
}

.feedback-meta {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.feedback-date {
  color: #666;
  font-size: 0.85rem;
}

.feedback-type, .feedback-status {
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 500;
}

.feedback-type.suggestion {
  background-color: #e3f2fd;
  color: #1565c0;
}

.feedback-type.bug {
  background-color: #ffebee;
  color: #c62828;
}

.feedback-type.complaint {
  background-color: #fff3e0;
  color: #e65100;
}

.feedback-type.feature {
  background-color: #e8f5e9;
  color: #2e7d32;
}

.feedback-type.other {
  background-color: #f5f5f5;
  color: #616161;
}

.feedback-status.new {
  background-color: #e8eaf6;
  color: #3949ab;
}

.feedback-status.in_progress {
  background-color: #fff8e1;
  color: #ffa000;
}

.feedback-status.resolved {
  background-color: #e8f5e9;
  color: #2e7d32;
}

.feedback-status.closed {
  background-color: #eeeeee;
  color: #616161;
}

.contact-badge {
  background-color: #f3e5f5;
  color: #7b1fa2;
  padding: 0.25rem;
  border-radius: 50%;
  width: 24px;
  height: 24px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 0.8rem;
}

.student-info {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}

.student-id {
  font-size: 0.85rem;
  color: #666;
}

.feedback-content {
  padding: 1rem;
  background-color: #f9f9f9;
  border-radius: 4px;
  margin-bottom: 1rem;
}

.feedback-content p {
  margin: 0;
  color: #333;
  white-space: pre-line; /* Preserve line breaks */
}

.feedback-actions {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
}

.status-select {
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  background-color: white;
}

.notes-button {
  padding: 0.5rem 1rem;
  background-color: #f0f0f0;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.notes-button:hover {
  background-color: #e0e0e0;
}

.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-top: 2rem;
  gap: 1rem;
}

.pagination-button {
  padding: 0.5rem 1rem;
  background-color: #f0f0f0;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.pagination-button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.page-info {
  color: #666;
}

/* Modal Styles */
.modal-overlay {
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
  background-color: white;
  border-radius: 8px;
  width: 90%;
  max-width: 600px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 1.5rem;
  border-bottom: 1px solid #eee;
}

.modal-header h3 {
  margin: 0;
  color: #333;
}

.close-button {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: #666;
}

.modal-body {
  padding: 1.5rem;
}

.notes-textarea {
  width: 100%;
  padding: 1rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  resize: vertical;
  font-family: inherit;
  font-size: 1rem;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  margin-top: 1.5rem;
}

.cancel-button, .save-button {
  padding: 0.75rem 1.5rem;
  border-radius: 4px;
  font-size: 0.9rem;
  cursor: pointer;
  border: none;
}

.cancel-button {
  background-color: #f5f5f5;
  color: #666;
}

.save-button {
  background-color: #ff4b7d;
  color: white;
}

.feedback-card.highlighted {
  border: 2px solid #ff4b7d;
  background-color: #fff5f7;
  animation: highlight-pulse 2s infinite alternate;
}

@keyframes highlight-pulse {
  from {
    box-shadow: 0 0 5px rgba(255, 75, 125, 0.5);
  }
  to {
    box-shadow: 0 0 15px rgba(255, 75, 125, 0.8);
  }
}
<<<<<<< HEAD

tr:hover {
  background-color: #fff5f7;
  transition: background 0.2s;
}
button, .add-btn, .view-btn, .edit-btn, .delete-btn, .save-btn, .cancel-btn, .confirm-btn {
  transition: background 0.2s, color 0.2s, box-shadow 0.2s;
}
.add-btn:hover {
  background-color: #ff4b7d;
  color: #fff;
  box-shadow: 0 2px 8px rgba(255, 20, 147, 0.13);
}
.view-btn:hover {
  background-color: #bbdefb;
  color: #1565c0;
}
.edit-btn:hover {
  background-color: #c8e6c9;
  color: #2e7d32;
}
.delete-btn:hover {
  background-color: #ffcdd2;
  color: #c62828;
}
.save-btn:hover, .confirm-btn:hover {
  background-color: #ff4b7d;
  color: #fff;
}
.cancel-btn:hover {
  background-color: #ffe4e1;
  color: #ff4b7d;
}
=======
>>>>>>> 81b584e837377ff81d30f83eefd8cd3b44eb81ba
</style> 