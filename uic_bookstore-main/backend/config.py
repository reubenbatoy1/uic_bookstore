# Database configuration
DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "",
    "database": "uic_bookstore",
    "port": 3306,
}

# JWT Authentication settings
JWT_SECRET_KEY = "your-secret-key-for-jwt"  # Change this in production
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30 