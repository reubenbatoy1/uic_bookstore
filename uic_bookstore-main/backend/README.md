# UIC Bookstore Backend

FastAPI backend for the UIC Bookstore student login system.

## Setup

### 1. Database Setup

First, create the MySQL database using the following SQL commands:

```sql
-- Create the database
CREATE DATABASE IF NOT EXISTS uic_bookstore;
USE uic_bookstore;

-- Create students table
CREATE TABLE IF NOT EXISTS students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    student_id VARCHAR(20) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create a table for session tracking (optional)
CREATE TABLE IF NOT EXISTS student_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    session_token VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
);
```

### 2. Update Database Configuration

Edit the `database.py` file and update the database connection string with your MySQL credentials:

```python
SQLALCHEMY_DATABASE_URL = "mysql+pymysql://username:password@localhost/uic_bookstore"
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 4. Run the Server

```bash
python run.py
```

The server will start on http://localhost:8000.

## API Endpoints

- `POST /students/` - Register a new student
- `POST /students/login` - Login with email and password
- `GET /students/me` - Get the current authenticated student's profile

## Security

In a production environment, make sure to:

1. Change the SECRET_KEY in auth.py
2. Set specific CORS origins
3. Use HTTPS 