-- ==========================================
-- ۱. جداول مربوط به اطلاعات پایه‌ای و مقالات
-- ==========================================

-- جدول تعداد آجر دیوارچینی بر اساس ضخامت دیوار
CREATE TABLE wall_bricks_data (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    wall_thickness_cm INTEGER,
    lefton_10x20x5_5_count INTEGER,
    sofali_count INTEGER,
    feshari_10x20x5_count INTEGER
);

INSERT INTO wall_bricks_data (wall_thickness_cm, lefton_10x20x5_5_count, sofali_count, feshari_10x20x5_count) VALUES 
(10, 74, 23, 80),
(15, 111, 23, 120),
(20, 148, 23, 160),
(25, 185, 46, 200),
(30, 222, 46, 240),
(35, 259, 46, 280);

-- جدول تعداد آجر نما در هر متر مربع و هر کارتن
CREATE TABLE facade_bricks_data (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    brick_type VARCHAR(255),
    dimensions VARCHAR(100),
    bricks_per_sq_meter VARCHAR(50),
    bricks_per_box INTEGER
);

INSERT INTO facade_bricks_data (brick_type, dimensions, bricks_per_sq_meter, bricks_per_box) VALUES 
('آجر نسوز پلاک 7 سانتی', '2.5×33×7', '37 الی 40 عدد', 20),
('آجر نما 20×5.5 سانتی', '2.5×20×5.5', '80 عدد', 20),
('آجر نما 26×5.5 سانتی', '2.5×26×5.5', '60 عدد', 28),
('آجر قزاقی پلاک نما', '2.5×20×5.5', '80 عدد', 30),
('آجر تایل 60×10 نما', '3×50×10', '16 عدد', 8),
('آجر تایل 50×10 نما', '3×50×10', '18 عدد', 8);


-- ==========================================
-- ۲. جداول مربوط به سیستم «محاسبه‌گر» سایت
-- ==========================================

-- جدول فرمول محاسبه تعداد آجر در متر مربع
CREATE TABLE calculator_formulas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    formula_name VARCHAR(255),
    formula_logic VARCHAR(500),
    description TEXT
);

INSERT INTO calculator_formulas (formula_name, formula_logic, description) VALUES 
('محاسبه آجر در یک متر مربع', '10000 / [(طول آجر + ضخامت بندکشی) × (عرض آجر + ضخامت بندکشی)]', 'عدد به دست آمده ضربدر مساحت کل دیوار (به متر مربع) می‌شود. در فرمول سایت پیش‌فرض بندکشی 1 سانت در نظر گرفته شده بود.');


-- جدول گزینه‌های محل استفاده در محاسبه‌گر
CREATE TABLE calc_usage_locations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    location_name VARCHAR(100)
);

INSERT INTO calc_usage_locations (location_name) VALUES 
('آجر نما'),
('آجر دیوارچینی');


-- جدول ابعاد آجرهای موجود در لیست کشویی محاسبه‌گر
CREATE TABLE calc_brick_options (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    brick_name VARCHAR(255),
    brick_category VARCHAR(100) -- نما یا دیوارچینی
);

INSERT INTO calc_brick_options (brick_name, brick_category) VALUES 
('آجر نما 7*32', 'نما'),
('آجر نما 7*33', 'نما'),
('آجر نما 7*31', 'نما'),
('آجر نما 5.5*20', 'نما'),
('آجر نما 5.5*26', 'نما'),
('آجر نما تایل 10*60', 'نما'),
('آجر نما تایل 10*50', 'نما'),
('آجر لفتون (10 سوراخ)', 'دیوارچینی'),
('آجر سفال 20*20*7 سانتی', 'دیوارچینی'),
('آجر سفال 20*20*10 سانتی', 'دیوارچینی'),
('آجر سفال 20*20*15 سانتی', 'دیوارچینی'),
('آجر سفال 20*20*20 سانتی', 'دیوارچینی'),
('آجر فشاری', 'دیوارچینی');


-- جدول گزینه‌های ضخامت دیوار در محاسبه‌گر
CREATE TABLE calc_wall_thickness_options (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    thickness_cm INTEGER
);

INSERT INTO calc_wall_thickness_options (thickness_cm) VALUES 
(10), (15), (20), (25), (30), (35);


-- جدول گزینه‌های ضخامت بندکشی در محاسبه‌گر
CREATE TABLE calc_joint_thickness_options (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    joint_name VARCHAR(100),
    joint_value_cm INTEGER
);

INSERT INTO calc_joint_thickness_options (joint_name, joint_value_cm) VALUES 
('بدون بندکشی', 0),
('1 سانت بندکشی استاندارد', 1),
('2 سانت بندکشی', 2);