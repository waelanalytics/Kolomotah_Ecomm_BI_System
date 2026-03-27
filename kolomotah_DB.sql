USE Kolomotah_DB;

-- مسح الجدول القديم عشان نبدأ على نظافة
DROP TABLE IF EXISTS Kolomotah_Orders;

-- إنشاء الجدول بأسماء أعمدة صغيرة (Lowercase)
CREATE TABLE Kolomotah_Orders (
    order_id VARCHAR(50),
    order_date VARCHAR(50),
    platform VARCHAR(50),
    product_name TEXT,
    code VARCHAR(50),
    quantity INT,
    cost_price DECIMAL(10, 2),
    selling_price DECIMAL(10, 2),
    status VARCHAR(50),
    city VARCHAR(50),
    ad_spend DECIMAL(10, 2)
);

USE Kolomotah_DB;

SELECT 
    o.order_id, 
    o.product_name, 
    o.city,
    o.selling_price AS 'سعر البيع',
    r.rate AS 'تكلفة شحن تاجر',
    (o.selling_price - o.cost_price - r.rate - o.ad_spend) AS 'صافي ربحي الصافي'
FROM Kolomotah_Orders o
JOIN Shipping_Rates r ON o.city = r.city;
USE Kolomotah_DB;

SELECT 
    o.order_id, 
    o.product_name, 
    o.city,
    o.selling_price AS 'سعر البيع',
    r.rate AS 'تكلفة شحن تاجر',
    -- استخدمنا COALESCE عشان نحول أي خانة فاضية لصفر ونعرف نحسب
    (o.selling_price - o.cost_price - r.rate - COALESCE(o.ad_spend, 0)) AS 'صافي الربح'
FROM Kolomotah_Orders o
JOIN Shipping_Rates r ON o.city = r.city;

CREATE OR REPLACE VIEW v_Kolomotah_Dashboard AS
SELECT 
    o.order_id, o.order_date, o.product_name, o.city, o.status,
    o.selling_price AS sales,
    r.Rate AS shipping_cost,
    COALESCE(o.ad_spend, 0) AS ads,
    (o.selling_Price - o.cost_price - r.rate - COALESCE(o.ad_spend, 0)) AS net_profit
FROM Kolomotah_Orders o
JOIN Shipping_Rates r ON o.city = r.city;

USE Kolomotah_DB;

-- إضافة عمود اسم العميل
ALTER TABLE Kolomotah_Orders ADD COLUMN customer_name VARCHAR(100);

-- إضافة عمود تليفون العميل
ALTER TABLE Kolomotah_Orders ADD COLUMN customer_phone VARCHAR(20);

USE Kolomotah_DB;
DESC Kolomotah_Orders;

USE Kolomotah_DB;

CREATE OR REPLACE VIEW v_Kolomotah_Dashboard AS
SELECT 
    o.order_id, 
    o.order_date, 
    o.product_name, 
    o.city, 
    o.status,
    o.customer_name, -- العمود الجديد
    o.customer_phone, -- العمود الجديد
    o.selling_price AS sales,
    r.Rate AS shipping_cost,
    COALESCE(o.ad_spend, 0) AS ads,
    (o.selling_price - o.cost_price - r.rate - COALESCE(o.ad_spend, 0)) AS net_profit
FROM Kolomotah_Orders o
JOIN Shipping_Rates r ON o.city = r.city;
USE Kolomotah_DB;
ALTER TABLE Kolomotah_Orders ADD COLUMN order_id VARCHAR(50) FIRST;

USE Kolomotah_DB;

SELECT 
    customer_name AS 'العميل',
    product_name AS 'المنتج',
    selling_price AS 'سعر البيع',
    (selling_price - cost_price - 75) AS 'صافي ربحي التقريبي'
FROM Kolomotah_Orders;

USE Kolomotah_DB;
ALTER TABLE Kolomotah_Orders ADD COLUMN platform_fees DECIMAL(10, 2);

CREATE OR REPLACE VIEW v_Kolomotah_Dashboard AS
SELECT 
    *,
    -- الربح الصافي = سعر البيع - التكلفة - الشحن - الإعلانات - عمولة المنصة
    (selling_price - cost_price - 75 - COALESCE(ad_spend, 0) - COALESCE(platform_fees, 0)) AS net_profit_final
FROM Kolomotah_Orders;
USE Kolomotah_DB;

CREATE OR REPLACE VIEW v_Kolomotah_Dashboard AS
SELECT 
    order_id, 
    order_date, 
    platform, 
    product_name, 
    city, 
    status,
    selling_price AS sales,
    -- حساب صافي الربح النهائي بدقة
    -- (سعر البيع - سعر التكلفة - 75 شحن ثابت - مصاريف الإعلان - عمولة المنصة)
    (selling_price - cost_price - 75 - COALESCE(ad_spend, 0) - COALESCE(platform_fees, 0)) AS net_profit,
    -- مراقبة هل حققنا الربح المستهدف أم لا
    CASE 
        WHEN (selling_price - cost_price - 75 - COALESCE(ad_spend, 0) - COALESCE(platform_fees, 0)) >= target_profit THEN 'Success ✅'
        ELSE 'Review Pricing ⚠️'
    END AS profit_status
FROM Kolomotah_Orders;
USE Kolomotah_DB;

-- إضافة الأعمدة الناقصة ليكون المجموع 15 عمود
ALTER TABLE Kolomotah_Orders ADD COLUMN target_profit DECIMAL(10, 2);
ALTER TABLE Kolomotah_Orders ADD COLUMN platform_fees DECIMAL(10, 2);

-- تأكد إن الجدول دلوقتي فيه 15 عمود
DESC Kolomotah_Orders;

USE Kolomotah_DB;

CREATE OR REPLACE VIEW v_Kolomotah_Dashboard AS
SELECT 
    order_id, 
    order_date, 
    platform, 
    product_name, 
    city, 
    status,
    selling_price AS sales,
    -- حساب صافي الربح النهائي بدقة
    -- (سعر البيع - سعر التكلفة - 75 شحن ثابت - مصاريف الإعلان - عمولة المنصة)
    (selling_price - cost_price - 75 - COALESCE(ad_spend, 0) - COALESCE(platform_fees, 0)) AS net_profit,
    -- مراقبة هل حققنا الربح المستهدف أم لا
    CASE 
        WHEN (selling_price - cost_price - 75 - COALESCE(ad_spend, 0) - COALESCE(platform_fees, 0)) >= target_profit THEN 'Success ✅'
        ELSE 'Review Pricing ⚠️'
    END AS profit_status
FROM Kolomotah_Orders;

USE Kolomotah_DB;

-- إضافة الأعمدة بالأسماء البسيطة لضمان نجاح كود بايثون
ALTER TABLE Kolomotah_Orders 
ADD COLUMN clicks INT DEFAULT 0,
ADD COLUMN tracking_id VARCHAR(100),
ADD COLUMN region VARCHAR(50) DEFAULT 'Egypt',
ADD COLUMN currency VARCHAR(10) DEFAULT 'EGP';

-- تأكد إن الجدول بقى 17 عمود
DESC Kolomotah_Orders;

USE Kolomotah_DB;

-- 1. التأكد من وجود عمود order_id في البداية (لو مش موجود هيضيفه)
-- ملاحظة: لو موجود فعلاً السيرفر هيطلع تنبيه بسيط تجاهله
ALTER TABLE Kolomotah_Orders ADD COLUMN IF NOT EXISTS order_id VARCHAR(50) FIRST;

-- 2. التأكد من أن الجدول يحتوي على الـ 19 عمود بالتمام
-- لو نفذت الأوامر دي قبل كدة مفيش مشكلة
DESC Kolomotah_Orders;

USE Kolomotah_DB;
DESC Kolomotah_Orders;

USE Kolomotah_DB;

CREATE OR REPLACE VIEW v_Kolomotah_Dashboard AS
SELECT 
    order_id, 
    order_date, 
    platform, 
    product_name, 
    city, 
    status,
    clicks, -- 👈 تأكدنا من إضافة العمود هنا
    selling_price AS sales,
    -- معادلة الربح
    (selling_price - cost_price - 75 - COALESCE(ad_spend, 0) - COALESCE(platform_fees, 0)) AS net_profit,
    -- حالة الربح
    CASE 
        WHEN (selling_price - cost_price - 75 - COALESCE(ad_spend, 0) - COALESCE(platform_fees, 0)) >= target_profit THEN 'Success ✅'
        ELSE 'Review Pricing ⚠️'
    END AS profit_status
FROM Kolomotah_Orders;