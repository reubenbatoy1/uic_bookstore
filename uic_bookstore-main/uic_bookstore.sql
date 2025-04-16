-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 01, 2025 at 11:11 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `uic_bookstore`
--

-- --------------------------------------------------------

--
-- Table structure for table `students`
--

CREATE TABLE `students` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `student_id` varchar(20) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `students`
--

INSERT INTO `students` (`id`, `name`, `email`, `student_id`, `password_hash`, `created_at`, `updated_at`) VALUES
(1, '2312321', 'gets@uic.edu.ph', '213123', '$2b$12$sTv847q4iTVSTntbGX9KteNH2RSi1RejoSuRYr57BoIVJy1K85Zfm', '2025-04-01 08:44:39', '2025-04-01 08:44:39'),
(2, 'Lemuel', 'lemuel@uic.edu.ph', '5555', '$2b$12$gk2CB88u.Y2KQmcsYDzupep32nRpHPbweWGODbGrXpbJDJ5Qhw5by', '2025-04-01 08:47:18', '2025-04-01 08:47:18');

-- --------------------------------------------------------

--
-- Table structure for table `student_sessions`
--

CREATE TABLE `student_sessions` (
  `id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `session_token` varchar(255) NOT NULL,
  `expires_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- Products Table
CREATE TABLE `products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `category` varchar(50) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `stock` int(11) NOT NULL DEFAULT 0,
  `min_stock` int(11) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Insert sample products
INSERT INTO `products` (`name`, `category`, `price`, `stock`, `min_stock`, `description`, `image_url`) VALUES
('Polo', 'Uniform', 450.00, 30, NULL, 'School polo uniform', NULL),
('Jogging Pants', 'Uniform', 400.00, 25, NULL, 'School jogging pants', NULL),
('Blouse', 'Uniform', 425.00, 8, 10, 'School blouse uniform', NULL),
('Physics Book', 'Books', 750.00, 15, NULL, 'Physics textbook', NULL),
('Chemistry Book', 'Books', 750.00, 12, NULL, 'Chemistry textbook', NULL),
('PE Book', 'Books', 500.00, 3, 5, 'Physical Education textbook', NULL),
('Scantron', 'Other', 5.00, 45, 50, 'Scantron answer sheets', NULL); 

-- Stock Adjustments History Table
CREATE TABLE IF NOT EXISTS stock_adjustments (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    product_id INTEGER NOT NULL,
    type ENUM('add', 'remove', 'set') NOT NULL,
    quantity INTEGER NOT NULL,
    reason VARCHAR(20) NOT NULL,
    notes TEXT,
    previous_stock INTEGER NOT NULL,
    new_stock INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
);


-- Add indexes for the stock_adjustments table
CREATE INDEX IF NOT EXISTS idx_stock_adjustments_product_id ON stock_adjustments (product_id);
CREATE INDEX IF NOT EXISTS idx_stock_adjustments_created_at ON stock_adjustments (created_at);

--
-- Indexes for dumped tables
---- Add size column to products table
ALTER TABLE products ADD COLUMN size VARCHAR(10); 

--
-- Indexes for table `students`
--
ALTER TABLE `students`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `student_id` (`student_id`);

--
-- Indexes for table `student_sessions`
--
ALTER TABLE `student_sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `student_id` (`student_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `students`
--
ALTER TABLE `students`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `student_sessions`
--
ALTER TABLE `student_sessions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `student_sessions`
--
ALTER TABLE `student_sessions`
  ADD CONSTRAINT `student_sessions_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

-- Student Notifications Tables
CREATE TABLE IF NOT EXISTS notifications (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    student_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
);

-- Product subscriptions table - tracks which students want notifications for which products
CREATE TABLE IF NOT EXISTS product_subscriptions (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    student_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE,
    UNIQUE(student_id, product_id)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_notifications_student_id ON notifications (student_id);
CREATE INDEX IF NOT EXISTS idx_notifications_product_id ON notifications (product_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications (created_at);
CREATE INDEX IF NOT EXISTS idx_product_subscriptions_student_id ON product_subscriptions (student_id);
CREATE INDEX IF NOT EXISTS idx_product_subscriptions_product_id ON product_subscriptions (product_id);

-- Order tables
CREATE TABLE IF NOT EXISTS orders (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    customer_name TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS order_items (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE RESTRICT
);

-- Create indexes for orders tables
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items (order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items (product_id);

-- Sales reporting tables
CREATE TABLE IF NOT EXISTS sales_daily (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    date DATE NOT NULL,
    category VARCHAR(50) NOT NULL,
    total_sales INTEGER NOT NULL DEFAULT 0,
    revenue DECIMAL(10,2) NOT NULL DEFAULT 0,
    cost DECIMAL(10,2) NOT NULL DEFAULT 0,
    profit DECIMAL(10,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE(date, category)
);

-- Top selling products table for reporting
CREATE TABLE IF NOT EXISTS top_products (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    product_id INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    units_sold INTEGER NOT NULL DEFAULT 0,
    revenue DECIMAL(10,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_top_products_date_range (start_date, end_date),
    INDEX idx_top_products_product_id (product_id),
    CONSTRAINT fk_top_products_product FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
);

-- Indexes for sales reporting tables
CREATE INDEX IF NOT EXISTS idx_sales_daily_date ON sales_daily (date);
CREATE INDEX IF NOT EXISTS idx_sales_daily_category ON sales_daily (category);

-- Insert sample data for testing
INSERT INTO sales_daily (date, category, total_sales, revenue, cost, profit) VALUES
('2025-03-25', 'Uniform', 4, 1725.00, 1325.00, 400.00),
('2025-03-25', 'Books', 2, 1500.00, 1200.00, 300.00),
('2025-03-25', 'Other', 20, 100.00, 60.00, 40.00),
('2025-03-26', 'Uniform', 3, 1300.00, 1000.00, 300.00),
('2025-03-26', 'Books', 2, 1250.00, 1000.00, 250.00),
('2025-03-26', 'Other', 15, 75.00, 45.00, 30.00),
('2025-03-27', 'Uniform', 5, 2000.00, 1600.00, 400.00),
('2025-03-27', 'Books', 3, 2250.00, 1800.00, 450.00),
('2025-03-27', 'Other', 10, 50.00, 30.00, 20.00),
('2025-03-28', 'Uniform', 4, 1800.00, 1400.00, 400.00),
('2025-03-28', 'Books', 1, 750.00, 600.00, 150.00),
('2025-03-28', 'Other', 5, 25.00, 15.00, 10.00),
('2025-03-29', 'Uniform', 2, 900.00, 700.00, 200.00),
('2025-03-29', 'Books', 3, 2250.00, 1800.00, 450.00),
('2025-03-29', 'Other', 12, 60.00, 36.00, 24.00);

-- This needs to come after the products are inserted for the foreign key constraint to work
INSERT INTO top_products (product_id, start_date, end_date, units_sold, revenue) VALUES
(1, '2025-03-25', '2025-03-31', 2, 900.00),  -- Polo
(4, '2025-03-25', '2025-03-31', 1, 750.00),  -- Physics Book
(5, '2025-03-25', '2025-03-31', 1, 750.00),  -- Chemistry Book
(3, '2025-03-25', '2025-03-31', 1, 425.00),  -- Blouse
(2, '2025-03-25', '2025-03-31', 1, 400.00);  -- Jogging Pants

-- Feedback Table for storing student feedback
CREATE TABLE IF NOT EXISTS `feedback` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `student_id` int(11) NOT NULL,
  `type` enum('suggestion','bug','complaint','feature','other') NOT NULL,
  `message` text NOT NULL,
  `can_contact` tinyint(1) NOT NULL DEFAULT 0,
  `status` enum('new','in_progress','resolved','closed') NOT NULL DEFAULT 'new',
  `admin_notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `feedback_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Create indexes for the feedback table
CREATE INDEX IF NOT EXISTS idx_feedback_type ON feedback (type);
CREATE INDEX IF NOT EXISTS idx_feedback_status ON feedback (status);
CREATE INDEX IF NOT EXISTS idx_feedback_created_at ON feedback (created_at);

-- Admin Table for storing admin user details
CREATE TABLE IF NOT EXISTS `admin_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `profile_picture` varchar(255) DEFAULT NULL,
  `role` enum('admin','super_admin') NOT NULL DEFAULT 'admin',
  `country` varchar(100) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `address_line` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Insert a default admin user (password: admin123)
INSERT INTO `admin_users` (`username`, `email`, `password_hash`, `first_name`, `last_name`, `role`, `country`, `city`) 
VALUES ('admin', 'admin@uic.edu.ph', '$2b$12$sTv847q4iTVSTntbGX9KteNH2RSi1RejoSuRYr57BoIVJy1K85Zfm', 'Admin', 'User', 'super_admin', 'Philippines', 'Davao');
