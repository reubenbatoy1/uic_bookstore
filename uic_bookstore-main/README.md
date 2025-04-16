# UIC Bookstore - Student Portal

A Vue.js application for student login, signup, and dashboard for the UIC Bookstore.

## Features

- Student login and registration
- Dashboard with navigation
- Profile management

## Project Setup

### Prerequisites

- Node.js (v16 or newer recommended)
- npm (comes with Node.js)

### Installation

1. Clone the repository:
```
git clone <repository-url>
cd uic-bookstore
```

2. Install dependencies:
```
npm install
```

### Development

Run the development server:
```
npm run dev
```

This will start the development server at `http://localhost:5173/` (default Vite port).

### Building for Production

Build the application for production:
```
npm run build
```

Preview the production build:
```
npm run preview
```

## Project Structure

- `main.js` - Application entry point with Vue Router setup
- `App.vue` - Main application component
- `student/` - Student-related components
  - `StudentLogin.vue` - Login form
  - `StudentSignup.vue` - Registration form
  - `StudentHomepage.vue` - Student dashboard 