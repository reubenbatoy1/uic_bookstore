from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Boolean, Float, Text, DECIMAL
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from database import Base
import datetime

class Student(Base):
    __tablename__ = "students"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    email = Column(String(100), unique=True, nullable=False, index=True)
    student_id = Column(String(20), unique=True, nullable=False, index=True)
    password_hash = Column(String(255), nullable=False)
    profile_picture = Column(String(255), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # Relationships
    notifications = relationship("Notification", back_populates="student", cascade="all, delete-orphan")
    subscriptions = relationship("ProductSubscription", back_populates="student", cascade="all, delete-orphan")

class StudentSession(Base):
    __tablename__ = "student_sessions"
    
    id = Column(Integer, primary_key=True, index=True)
    student_id = Column(Integer, ForeignKey("students.id", ondelete="CASCADE"), nullable=False)
    session_token = Column(String(255), nullable=False)
    expires_at = Column(DateTime(timezone=True), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class Product(Base):
    __tablename__ = "products"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    category = Column(String(50), nullable=False)
    price = Column(DECIMAL(10, 2), nullable=False)
    cost_price = Column(DECIMAL(10, 2), nullable=False)
    stock = Column(Integer, nullable=False, default=0)
    min_stock = Column(Integer, nullable=True)
    description = Column(Text, nullable=True)
    image_url = Column(String(255), nullable=True)
    size = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    stock_adjustments = relationship("StockAdjustment", back_populates="product", cascade="all, delete-orphan")
    notifications = relationship("Notification", back_populates="product", cascade="all, delete-orphan")
    subscribers = relationship("ProductSubscription", back_populates="product", cascade="all, delete-orphan")
    order_items = relationship("OrderItem", back_populates="product")

class StockAdjustment(Base):
    __tablename__ = "stock_adjustments"

    id = Column(Integer, primary_key=True, index=True)
    product_id = Column(Integer, ForeignKey("products.id", ondelete="CASCADE"), nullable=False)
    type = Column(String, nullable=False)  # 'add', 'remove', 'set'
    quantity = Column(Integer, nullable=False)
    reason = Column(String, nullable=False)
    notes = Column(Text, nullable=True)
    previous_stock = Column(Integer, nullable=False)
    new_stock = Column(Integer, nullable=False)
    created_at = Column(DateTime, nullable=False, default=datetime.datetime.utcnow)

    # Relationship with Product
    product = relationship("Product", back_populates="stock_adjustments") 

class Notification(Base):
    __tablename__ = "notifications"
    
    id = Column(Integer, primary_key=True, index=True)
    student_id = Column(Integer, ForeignKey("students.id", ondelete="CASCADE"), nullable=False)
    product_id = Column(Integer, ForeignKey("products.id", ondelete="CASCADE"), nullable=False)
    message = Column(Text, nullable=False)
    type = Column(String(50), nullable=False)
    is_read = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime, nullable=False, default=datetime.datetime.utcnow)
    
    # Relationships
    student = relationship("Student", back_populates="notifications")
    product = relationship("Product", back_populates="notifications")


class ProductSubscription(Base):
    __tablename__ = "product_subscriptions"
    
    id = Column(Integer, primary_key=True, index=True)
    student_id = Column(Integer, ForeignKey("students.id", ondelete="CASCADE"), nullable=False)
    product_id = Column(Integer, ForeignKey("products.id", ondelete="CASCADE"), nullable=False)
    created_at = Column(DateTime, nullable=False, default=datetime.datetime.utcnow)
    
    # Relationships
    student = relationship("Student", back_populates="subscriptions")
    product = relationship("Product", back_populates="subscribers")

class Order(Base):
    __tablename__ = "orders"

    id = Column(Integer, primary_key=True, index=True)
    customer_name = Column(String, nullable=False)
    status = Column(String, default="Pending")
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
    
    # Relationships
    items = relationship("OrderItem", back_populates="order", cascade="all, delete-orphan")

class OrderItem(Base):
    __tablename__ = "order_items"

    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id", ondelete="CASCADE"))
    product_id = Column(Integer, ForeignKey("products.id", ondelete="RESTRICT"))
    quantity = Column(Integer, nullable=False)
    price = Column(DECIMAL(10, 2), nullable=False)
    
    # Relationships
    order = relationship("Order", back_populates="items")
    product = relationship("Product", back_populates="order_items")

# Add the Feedback model at the end of the file
class Feedback(Base):
    __tablename__ = "feedback"
    
    id = Column(Integer, primary_key=True, index=True)
    student_id = Column(Integer, ForeignKey("students.id", ondelete="CASCADE"), nullable=False)
    type = Column(String(50), nullable=False)  # suggestion, bug, complaint, feature, other
    message = Column(Text, nullable=False)
    can_contact = Column(Boolean, default=False, nullable=False)
    status = Column(String(20), default="new", nullable=False)  # new, in_progress, resolved, closed
    admin_notes = Column(Text, nullable=True)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)
    
    # Relationship with Student
    student = relationship("Student", backref="feedback") 

# Add the AdminUser model at the end of the file
class AdminUser(Base):
    __tablename__ = "admin_users"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, nullable=False)
    email = Column(String(100), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    phone_number = Column(String(20), nullable=True)
    date_of_birth = Column(DateTime, nullable=True)
    profile_picture = Column(String(255), nullable=True)
    role = Column(String(20), nullable=False, default="admin")
    country = Column(String(100), nullable=True)
    city = Column(String(100), nullable=True)
    postal_code = Column(String(20), nullable=True)
    address_line = Column(String(255), nullable=True)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False) 