from pydantic import BaseModel, EmailStr, Field, validator
from typing import Optional, List, Dict, Union, Any
from datetime import datetime, date
from decimal import Decimal

# Student schemas
class StudentBase(BaseModel):
    name: str
    email: EmailStr
    student_id: str

class StudentCreate(StudentBase):
    password: str

class StudentLogin(BaseModel):
    email: EmailStr
    password: str

class StudentResponse(StudentBase):
    id: int
    created_at: datetime
    profile_picture: Optional[str] = None
    
    class Config:
        from_attributes = True

# Token schemas
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: Optional[str] = None
    student_id: Optional[str] = None

# Product Schemas
class ProductBase(BaseModel):
    name: str
    category: str
    price: Decimal
    cost_price: Decimal
    stock: int
    min_stock: Optional[int] = None
    description: Optional[str] = None
    image_url: Optional[str] = None
    size: Optional[str] = None

class ProductCreate(ProductBase):
    pass

class ProductUpdate(BaseModel):
    name: Optional[str] = None
    category: Optional[str] = None
    price: Optional[Decimal] = None
    cost_price: Optional[Decimal] = None
    stock: Optional[int] = None
    min_stock: Optional[int] = None
    description: Optional[str] = None
    image_url: Optional[str] = None

class ProductResponse(ProductBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True

class ProductList(BaseModel):
    products: List[ProductResponse]
    total: int

# Stock Adjustment Schemas
class StockAdjustmentBase(BaseModel):
    product_id: int
    type: str  # 'add', 'remove', 'set'
    quantity: int
    reason: str
    notes: Optional[str] = None

class StockAdjustmentCreate(StockAdjustmentBase):
    pass

class StockAdjustmentResponse(StockAdjustmentBase):
    id: int
    previous_stock: int
    new_stock: int
    created_at: datetime
    
    class Config:
        from_attributes = True

class StockAdjustmentList(BaseModel):
    history: List[StockAdjustmentResponse]
    
    class Config:
        from_attributes = True

# Notification Schemas
class NotificationBase(BaseModel):
    product_id: int
    student_id: int
    message: str
    type: str

class NotificationCreate(NotificationBase):
    pass

class NotificationResponse(NotificationBase):
    id: int
    is_read: bool
    created_at: datetime
    
    class Config:
        from_attributes = True

class NotificationList(BaseModel):
    notifications: List[NotificationResponse]
    total: int

# Product Subscription Schemas
class ProductSubscriptionBase(BaseModel):
    product_id: int
    student_id: int

class ProductSubscriptionCreate(ProductSubscriptionBase):
    pass

class ProductSubscriptionResponse(ProductSubscriptionBase):
    id: int
    created_at: datetime
    
    class Config:
        from_attributes = True

# Order Schemas
class OrderItemBase(BaseModel):
    product_id: int
    quantity: int
    price: Decimal = Field(..., ge=0)

class OrderItemCreate(OrderItemBase):
    pass

class OrderItemResponse(OrderItemBase):
    id: int
    order_id: int
    
    class Config:
        from_attributes = True

class OrderItemWithProduct(OrderItemResponse):
    product_name: str
    
    @validator('product_name', pre=True)
    def extract_product_name(cls, v, values, **kwargs):
        if hasattr(v, 'name'):
            return v.name
        return v

class OrderBase(BaseModel):
    customer_name: str
    status: str = "Pending"

class OrderCreate(OrderBase):
    items: List[OrderItemCreate]

class OrderUpdate(BaseModel):
    customer_name: Optional[str] = None
    status: Optional[str] = None

class OrderResponse(OrderBase):
    id: int
    created_at: datetime
    updated_at: datetime
    items: List[OrderItemWithProduct] = []
    
    class Config:
        from_attributes = True

class OrderListItem(BaseModel):
    id: int
    customer_name: str
    status: str
    created_at: datetime
    total: Decimal
    
    class Config:
        from_attributes = True

class OrderList(BaseModel):
    orders: List[OrderListItem]
    total: int

# Report schemas
class SalesReportResponse(BaseModel):
    chart_data: Dict[str, Any]
    category_totals: Dict[str, Dict[str, Union[int, float]]]
    overall_totals: Dict[str, Union[int, float]]
    raw_data: List[Dict[str, Any]]

class TopProductResponse(BaseModel):
    id: int
    product: str
    category: str
    sold: int
    revenue: float

class LowStockItemResponse(BaseModel):
    id: int
    product: str
    category: str
    stock: int
    min_stock: int
    status: str

class LowStockProduct(BaseModel):
    id: int
    name: str
    category: str
    current_stock: int
    min_stock: int
    price: float
    status: str = Field(description="Stock status: 'Out of Stock' or 'Low Stock'")

class CategoryPerformanceResponse(BaseModel):
    categories: Dict[str, Dict[str, Union[int, float]]]
    distribution: Dict[str, Any] 

# Feedback Schemas
class FeedbackBase(BaseModel):
    student_id: int
    type: str
    message: str
    can_contact: bool = False

class FeedbackCreate(FeedbackBase):
    pass

class FeedbackUpdate(BaseModel):
    status: Optional[str] = None
    admin_notes: Optional[str] = None

class FeedbackResponse(FeedbackBase):
    id: int
    status: str
    admin_notes: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    student_name: str
    
    class Config:
        from_attributes = True

class FeedbackListResponse(BaseModel):
    feedback: List[FeedbackResponse]
    total: int

# Admin User Schemas
class AdminUserBase(BaseModel):
    username: str
    email: EmailStr
    first_name: str
    last_name: str
    role: str
    phone_number: Optional[str] = None
    date_of_birth: Optional[date] = None
    country: Optional[str] = None
    city: Optional[str] = None
    postal_code: Optional[str] = None
    address_line: Optional[str] = None

class AdminUserCreate(AdminUserBase):
    password: str

class AdminUserLogin(BaseModel):
    username: str
    password: str

class AdminUserUpdate(BaseModel):
    username: Optional[str] = None
    email: Optional[EmailStr] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone_number: Optional[str] = None
    date_of_birth: Optional[date] = None
    role: Optional[str] = None

class AdminAddressUpdate(BaseModel):
    country: Optional[str] = None
    city: Optional[str] = None
    postal_code: Optional[str] = None
    address_line: Optional[str] = None

class AdminPasswordUpdate(BaseModel):
    current_password: str
    new_password: str

class AdminUserResponse(AdminUserBase):
    id: int
    profile_picture: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True 