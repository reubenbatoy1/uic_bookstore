import pymysql
from config import DB_CONFIG
import sys

def test_connection():
    try:
        # Connect to the MySQL server
        connection = pymysql.connect(
            host=DB_CONFIG["host"],
            user=DB_CONFIG["user"],
            password=DB_CONFIG["password"],
            database=DB_CONFIG["database"],
            connect_timeout=5
        )
        
        print(f"✅ Successfully connected to MySQL database '{DB_CONFIG['database']}'!")
        
        # Try to create the tables to verify permissions
        with connection.cursor() as cursor:
            cursor.execute("SHOW TABLES")
            tables = cursor.fetchall()
            print(f"Existing tables in database: {[t[0] for t in tables]}")
        
        connection.close()
        return True
        
    except pymysql.MySQLError as e:
        print(f"❌ Database connection error: {e}")
        print("\nPlease check:")
        print("1. MySQL server is running")
        print(f"2. Database '{DB_CONFIG['database']}' exists")
        print("3. User credentials in config.py are correct")
        print("4. User has proper permissions")
        return False

if __name__ == "__main__":
    print("Testing database connection...")
    print(f"Using config: {DB_CONFIG}")
    
    success = test_connection()
    
    if not success:
        sys.exit(1) 