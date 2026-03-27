import pandas as pd
import mysql.connector
import numpy as np

# 1. قراءة البيانات من الإكسيل
try:
    print("⏳ جاري قراءة ملف الإكسيل وتنظيف الأعمدة...")
    df = pd.read_excel('kolomotah_input.xlsx')
    
    # السطر السحري: تحويل كل العناوين لحروف صغيرة (Lowercase) ومسح المسافات
    # كدة 'Order_ID' هتبقى 'order_id' أوتوماتيكياً
    df.columns = df.columns.str.strip().str.lower()
    
    # القائمة الإجبارية بالترتيب اللي MySQL مستنياه (19 عمود)
    required_cols = [
        'order_id', 'order_date', 'platform', 'product_name', 'code', 
        'quantity', 'cost_price', 'selling_price', 'status', 'city', 
        'ad_spend', 'target_profit', 'customer_name', 'customer_phone', 
        'platform_fees', 'clicks', 'tracking_id', 'region', 'currency'
    ]
    
    # لو فيه عمود ناقص في الإكسيل (بسبب إن الصورة مقطوعة أو نسيته) بايثون هيكريه ويحطه صفر
    for col in required_cols:
        if col not in df.columns:
            df[col] = None
            
    # إعادة ترتيب الأعمدة وفلترتها (هنا بناخد الـ 19 بس وبنهمل أي حاجة تانية)
    df = df[required_cols]
    
    # تحويل الـ nan لـ None عشان الـ SQL ما يزعلش
    df = df.replace({np.nan: None})
    
    print("✅ البيانات جاهزة وموحدة (كل الحروف الآن lowercase)")

except Exception as e:
    print(f"❌ خطأ في تجهيز البيانات: {e}")
    exit()

# 2. الاتصال بـ MySQL 8.4 والرفع
try:
    conn = mysql.connector.connect(
        host="localhost",
        user="root",
        password="", # باسوورد السيرفر الجديد
        database="Kolomotah_DB",
        port=3306
    )
    cursor = conn.cursor()

    # تنظيف الجدول قبل الرفع
    cursor.execute("TRUNCATE TABLE Kolomotah_Orders")

    # جملة الإدخال لـ 19 عمود (19 علامة %s)
    sql = "INSERT INTO Kolomotah_Orders VALUES (" + ", ".join(["%s"] * 19) + ")"
    
    for i, row in df.iterrows():
        cursor.execute(sql, tuple(row))

    conn.commit()
    print("-" * 30)
    print(f"🚀 مبروك يا وائل! السيستم العالمي اشتغل ونقل {len(df)} أوردر بنجاح.")
    print("-" * 30)

    cursor.close()
    conn.close()

except mysql.connector.Error as err:
    print(f"❌ خطأ في MySQL: {err}")