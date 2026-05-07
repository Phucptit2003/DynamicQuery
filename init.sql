-- ==========================================
-- 1. XÓA BẢNG CŨ (NẾU CÓ) ĐỂ TRÁNH LỖI KHI CHẠY LẠI
-- ==========================================

ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = myuser;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE ORDER_ITEMS CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE ORDERS CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE CUSTOMERS CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE SYSTEM_LOGS CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE COMPANY_EVENTS CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- ==========================================
-- 2. TẠO 3 BẢNG CÓ QUAN HỆ (JOIN)
-- ==========================================

-- Bảng 1: Khách hàng
CREATE TABLE CUSTOMERS (
                           CUSTOMER_ID NUMBER PRIMARY KEY,
                           FULL_NAME VARCHAR2(100),
                           EMAIL VARCHAR2(100),
                           PHONE VARCHAR2(20)
);

-- Bảng 2: Đơn hàng (Khóa ngoại trỏ tới CUSTOMERS)
CREATE TABLE ORDERS (
                        ORDER_ID NUMBER PRIMARY KEY,
                        CUSTOMER_ID NUMBER,
                        ORDER_DATE DATE,
                        STATUS VARCHAR2(50),
                        CONSTRAINT FK_ORD_CUST FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMERS(CUSTOMER_ID)
);

-- Bảng 3: Chi tiết đơn hàng (Khóa ngoại trỏ tới ORDERS)
CREATE TABLE ORDER_ITEMS (
                             ITEM_ID NUMBER PRIMARY KEY,
                             ORDER_ID NUMBER,
                             PRODUCT_NAME VARCHAR2(100),
                             QUANTITY NUMBER,
                             PRICE NUMBER(10, 2),
                             CONSTRAINT FK_ITEM_ORD FOREIGN KEY (ORDER_ID) REFERENCES ORDERS(ORDER_ID)
);

-- ==========================================
-- 3. TẠO 2 BẢNG ĐỘC LẬP
-- ==========================================

-- Bảng 4: Nhật ký hệ thống
CREATE TABLE SYSTEM_LOGS (
                             LOG_ID NUMBER PRIMARY KEY,
                             LOG_LEVEL VARCHAR2(20),
                             MESSAGE VARCHAR2(500),
                             CREATED_AT TIMESTAMP
);

-- Bảng 5: Sự kiện công ty
CREATE TABLE COMPANY_EVENTS (
                                EVENT_ID NUMBER PRIMARY KEY,
                                EVENT_NAME VARCHAR2(200),
                                EVENT_DATE DATE,
                                LOCATION VARCHAR2(200)
);

-- ==========================================
-- 4. CHÈN DỮ LIỆU MẪU
-- ==========================================

-- Dữ liệu CUSTOMERS
INSERT INTO CUSTOMERS VALUES (1, 'Nguyen Van A', 'a.nguyen@email.com', '0901111111');
INSERT INTO CUSTOMERS VALUES (2, 'Tran Thi B', 'b.tran@email.com', '0902222222');
INSERT INTO CUSTOMERS VALUES (3, 'Le Van C', 'c.le@email.com', '0903333333');
INSERT INTO CUSTOMERS VALUES (4, 'Pham Thi D', 'd.pham@email.com', '0904444444');
INSERT INTO CUSTOMERS VALUES (5, 'Hoang Van E', 'e.hoang@email.com', '0905555555');
INSERT INTO CUSTOMERS VALUES (6, 'Vu Thi F', 'f.vu@email.com', '0906666666');
INSERT INTO CUSTOMERS VALUES (7, 'Dang Van G', 'g.dang@email.com', '0907777777');
INSERT INTO CUSTOMERS VALUES (8, 'Bui Thi H', 'h.bui@email.com', '0908888888');
INSERT INTO CUSTOMERS VALUES (9, 'Do Van I', 'i.do@email.com', '0909999999');
INSERT INTO CUSTOMERS VALUES (10, 'Ngo Thi J', 'j.ngo@email.com', '0910000000');

-- Dữ liệu ORDERS
INSERT INTO ORDERS VALUES (101, 1, TO_DATE('2026-05-01', 'YYYY-MM-DD'), 'COMPLETED');
INSERT INTO ORDERS VALUES (102, 1, TO_DATE('2026-05-02', 'YYYY-MM-DD'), 'PENDING');
INSERT INTO ORDERS VALUES (103, 2, TO_DATE('2026-05-03', 'YYYY-MM-DD'), 'COMPLETED');
INSERT INTO ORDERS VALUES (104, 3, TO_DATE('2026-05-04', 'YYYY-MM-DD'), 'CANCELLED');
INSERT INTO ORDERS VALUES (105, 4, TO_DATE('2026-05-05', 'YYYY-MM-DD'), 'COMPLETED');
INSERT INTO ORDERS VALUES (106, 5, TO_DATE('2026-05-05', 'YYYY-MM-DD'), 'PENDING');
INSERT INTO ORDERS VALUES (107, 6, TO_DATE('2026-05-06', 'YYYY-MM-DD'), 'COMPLETED');
INSERT INTO ORDERS VALUES (108, 7, TO_DATE('2026-05-07', 'YYYY-MM-DD'), 'PROCESSING');
INSERT INTO ORDERS VALUES (109, 8, TO_DATE('2026-05-07', 'YYYY-MM-DD'), 'COMPLETED');
INSERT INTO ORDERS VALUES (110, 9, TO_DATE('2026-05-08', 'YYYY-MM-DD'), 'PENDING');

-- Dữ liệu ORDER_ITEMS
INSERT INTO ORDER_ITEMS VALUES (1001, 101, 'Laptop Dell XPS', 1, 1500.00);
INSERT INTO ORDER_ITEMS VALUES (1002, 101, 'Mouse Logitech', 2, 25.50);
INSERT INTO ORDER_ITEMS VALUES (1003, 102, 'Bàn phím cơ', 1, 120.00);
INSERT INTO ORDER_ITEMS VALUES (1004, 103, 'Màn hình LG 27 inch', 2, 300.00);
INSERT INTO ORDER_ITEMS VALUES (1005, 104, 'Tai nghe Sony', 1, 150.00);
INSERT INTO ORDER_ITEMS VALUES (1006, 105, 'Điện thoại iPhone 15', 1, 999.00);
INSERT INTO ORDER_ITEMS VALUES (1007, 106, 'Cáp sạc Type C', 5, 10.00);
INSERT INTO ORDER_ITEMS VALUES (1008, 107, 'Pin dự phòng Anker', 2, 45.00);
INSERT INTO ORDER_ITEMS VALUES (1009, 108, 'Loa Bluetooth JBL', 1, 80.00);
INSERT INTO ORDER_ITEMS VALUES (1010, 109, 'Máy tính bảng iPad', 1, 500.00);

-- Dữ liệu SYSTEM_LOGS
INSERT INTO SYSTEM_LOGS VALUES (1, 'INFO', 'Hệ thống khởi động thành công', CURRENT_TIMESTAMP);
INSERT INTO SYSTEM_LOGS VALUES (2, 'WARNING', 'Tài nguyên RAM đang ở mức 80%', CURRENT_TIMESTAMP);
INSERT INTO SYSTEM_LOGS VALUES (3, 'ERROR', 'Lỗi kết nối database ở port 1521', CURRENT_TIMESTAMP);
INSERT INTO SYSTEM_LOGS VALUES (4, 'INFO', 'Người dùng ID 5 đã đăng nhập', CURRENT_TIMESTAMP);
INSERT INTO SYSTEM_LOGS VALUES (5, 'INFO', 'Bản sao lưu dữ liệu đã hoàn tất', CURRENT_TIMESTAMP);
INSERT INTO SYSTEM_LOGS VALUES (6, 'ERROR', 'Không tìm thấy file cấu hình', CURRENT_TIMESTAMP);
INSERT INTO SYSTEM_LOGS VALUES (7, 'WARNING', 'Mật khẩu người dùng ID 2 sắp hết hạn', CURRENT_TIMESTAMP);
INSERT INTO SYSTEM_LOGS VALUES (8, 'INFO', 'Cập nhật hệ thống lên phiên bản 2.1', CURRENT_TIMESTAMP);
INSERT INTO SYSTEM_LOGS VALUES (9, 'INFO', 'Tiến trình dọn dẹp cache đã chạy', CURRENT_TIMESTAMP);
INSERT INTO SYSTEM_LOGS VALUES (10, 'ERROR', 'Timeout khi gọi API thanh toán', CURRENT_TIMESTAMP);

-- Dữ liệu COMPANY_EVENTS
INSERT INTO COMPANY_EVENTS VALUES (1, 'Họp giao ban đầu năm', TO_DATE('2026-01-15', 'YYYY-MM-DD'), 'Phòng họp A');
INSERT INTO COMPANY_EVENTS VALUES (2, 'Tiệc tất niên', TO_DATE('2026-01-20', 'YYYY-MM-DD'), 'Nhà hàng Sao Biển');
INSERT INTO COMPANY_EVENTS VALUES (3, 'Đào tạo nhân viên mới', TO_DATE('2026-02-10', 'YYYY-MM-DD'), 'Phòng Đào tạo');
INSERT INTO COMPANY_EVENTS VALUES (4, 'Team Building Quý 1', TO_DATE('2026-03-25', 'YYYY-MM-DD'), 'Đà Lạt');
INSERT INTO COMPANY_EVENTS VALUES (5, 'Ra mắt sản phẩm mới', TO_DATE('2026-04-05', 'YYYY-MM-DD'), 'Trung tâm Hội nghị');
INSERT INTO COMPANY_EVENTS VALUES (6, 'Khám sức khỏe định kỳ', TO_DATE('2026-05-12', 'YYYY-MM-DD'), 'Bệnh viện Đa khoa');
INSERT INTO COMPANY_EVENTS VALUES (7, 'Hội thảo Công nghệ', TO_DATE('2026-06-18', 'YYYY-MM-DD'), 'Phòng họp B');
INSERT INTO COMPANY_EVENTS VALUES (8, 'Sinh nhật Công ty', TO_DATE('2026-08-01', 'YYYY-MM-DD'), 'Hội trường chính');
INSERT INTO COMPANY_EVENTS VALUES (9, 'Du lịch hè', TO_DATE('2026-07-15', 'YYYY-MM-DD'), 'Phú Quốc');
INSERT INTO COMPANY_EVENTS VALUES (10, 'Tổng kết cuối năm', TO_DATE('2026-12-25', 'YYYY-MM-DD'), 'Khách sạn InterContinental');

-- Ghi nhận dữ liệu
COMMIT;
