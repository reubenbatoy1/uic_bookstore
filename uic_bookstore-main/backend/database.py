from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from config import DB_CONFIG

# Build the connection string from the config
db_user = DB_CONFIG["user"]
db_password = DB_CONFIG["password"]
db_host = DB_CONFIG["host"]
db_name = DB_CONFIG["database"]

# Create connection string
if db_password:
    SQLALCHEMY_DATABASE_URL = f"mysql+pymysql://{db_user}:{db_password}@{db_host}/{db_name}"
else:
    # For connections without password
    SQLALCHEMY_DATABASE_URL = f"mysql+pymysql://{db_user}@{db_host}/{db_name}"

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

# Dependency to get DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close() 