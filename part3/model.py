import pandas as pd

# قراءة البيانات من ملفات CSV
cust_data = pd.read_csv('data\\cust.csv')
offices_data = pd.read_csv('data\\offices.csv')
product_data = pd.read_csv('data\\product.csv')
employee_data = pd.read_csv('data\\employee.csv')
fact_data = pd.read_csv('data\\fact.csv')

# استكشاف البيانات
print(cust_data.head())
print(offices_data.head())
print(product_data.head())
print(employee_data.head())
print(fact_data.head())

# دمج البيانات
merged_data = fact_data.merge(cust_data, on='customerNumber') \
                         .merge(offices_data, on='officeCode') \
                         .merge(product_data, on='productCode') \
                         .merge(employee_data, on='employeeNumber')

# تحقق من شكل البيانات المدمجة
print("Merged Data Shape:", merged_data.shape)
print("Merged Data Sample:")
print(merged_data.head())

# إعداد الخصائص
features = merged_data.groupby('customerNumber').agg({
    'orderNumber': 'count',                      # عدد الطلبات الإجمالي
    'priceEach': 'mean',                         # متوسط قيمة الطلبات
    'reviewID': 'count',                         # عدد التقييمات
    'reviewText': lambda x: (x == 'negative').sum(),  # عدد التقييمات السلبية
    'interactionID': 'count'                     # عدد التفاعلات
}).reset_index()

# إعادة تسمية الأعمدة
features.columns = ['customerNumber', 'totalOrders', 'avgOrderValue', 'totalReviews', 'negativeReviews', 'totalInteractions']

# تحقق من شكل البيانات بعد إعداد الخصائص
print("Features Data Shape:", features.shape)
print("Features Sample:")
print(features.head())

# إضافة عمود customerChurn بناءً على عدد المراجعات السلبية
# يمكن اعتبار العميل يتخلى عن الخدمة إذا كان لديه أكثر من 3 تقييمات سلبية
features['customerChurn'] = (features['negativeReviews'] > 3).astype(int)  # 1 إذا كان العميل قد تخلى، 0 خلاف ذلك

# إعداد البيانات للنموذج
y = features['customerChurn']  # متغير الهدف (توقع الانخفاض)
X = features[['totalOrders', 'avgOrderValue', 'totalReviews', 'negativeReviews', 'totalInteractions']]  # اختيار أهم 5 ميزات

# تقسيم البيانات
from sklearn.model_selection import train_test_split

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
print("Training data shape:", X_train.shape)
print("Testing data shape:", X_test.shape)

from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import accuracy_score, classification_report

# بناء النموذج
model = DecisionTreeClassifier(random_state=42)
model.fit(X_train, y_train)  # تدريب النموذج

# التقييم
y_pred = model.predict(X_test)  # توقع القيم
accuracy = accuracy_score(y_test, y_pred)  # حساب الدقة
print(f'Accuracy: {accuracy}')  # طباعة الدقة
print(classification_report(y_test, y_pred))  # طباعة تقرير التصنيف

# نظام التوقع
def predict_customer_churn(model):
    # طلب إدخال الميزات من المستخدم
    total_orders = int(input("Enter total orders: "))
    avg_order_value = float(input("Enter average order value: "))
    total_reviews = int(input("Enter total reviews: "))
    negative_reviews = int(input("Enter total negative reviews: "))
    total_interactions = int(input("Enter total interactions: "))
    
    # إنشاء DataFrame للميزات المدخلة
    input_data = pd.DataFrame({
        'totalOrders': [total_orders],
        'avgOrderValue': [avg_order_value],
        'totalReviews': [total_reviews],
        'negativeReviews': [negative_reviews],
        'totalInteractions': [total_interactions]
    })
    
    # توقع churn
    churn_prediction = model.predict(input_data)
    
    if churn_prediction[0] == 1:
        print("The customer is likely to churn.")
    else:
        print("The customer is not likely to churn.")

# استدعاء نظام التوقع
predict_customer_churn(model)
