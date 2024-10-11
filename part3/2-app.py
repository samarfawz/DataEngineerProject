from flask import Flask, request, render_template
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import accuracy_score, classification_report

app = Flask(__name__)

# قراءة البيانات من ملفات CSV
cust_data = pd.read_csv('data\\cust.csv')
offices_data = pd.read_csv('data\\offices.csv')
product_data = pd.read_csv('data\\product.csv')
employee_data = pd.read_csv('data\\employee.csv')
fact_data = pd.read_csv('data\\fact.csv')

# دمج البيانات
merged_data = fact_data.merge(cust_data, on='customerNumber') \
                         .merge(offices_data, on='officeCode') \
                         .merge(product_data, on='productCode') \
                         .merge(employee_data, on='employeeNumber')

# إعداد الخصائص
features = merged_data.groupby('customerNumber').agg({
    'orderNumber': 'count',                      
    'priceEach': 'mean',                         
    'reviewID': 'count',                         
    'reviewText': lambda x: (x == 'negative').sum(),  
    'interactionID': 'count'                     
}).reset_index()

# إعادة تسمية الأعمدة
features.columns = ['customerNumber', 'totalOrders', 'avgOrderValue', 'totalReviews', 'negativeReviews', 'totalInteractions']
features['customerChurn'] = (features['negativeReviews'] > 3).astype(int)

# إعداد البيانات للنموذج
y = features['customerChurn']
X = features[['totalOrders', 'avgOrderValue', 'totalReviews', 'negativeReviews', 'totalInteractions']]
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# بناء النموذج
model = DecisionTreeClassifier(random_state=42)
model.fit(X_train, y_train)

@app.route("/", methods=["GET"])
def index():
    return render_template("index.html")

@app.route("/predict", methods=["POST"])
def predict():
    try:
        # الحصول على القيم من النموذج
        total_orders = int(request.form['totalOrders'])
        avg_order_value = float(request.form['avgOrderValue'])
        total_reviews = int(request.form['totalReviews'])
        negative_reviews = int(request.form['negativeReviews'])
        total_interactions = int(request.form['totalInteractions'])

        # حالة خاصة: إذا كانت جميع القيم صفر، توقع أن العميل سيغادر
        if (total_orders == 0 and avg_order_value == 0 and
            total_reviews == 0 and negative_reviews == 0 and
            total_interactions == 0):
            return render_template("result.html", result="Customer Churn Prediction: Likely to churn")

        # إعداد البيانات للتوقع
        input_data = pd.DataFrame({
            'totalOrders': [total_orders],
            'avgOrderValue': [avg_order_value],
            'totalReviews': [total_reviews],
            'negativeReviews': [negative_reviews],
            'totalInteractions': [total_interactions]
        })

        # توقع churn
        result = model.predict(input_data)[0]

        # إعداد الرسالة بناءً على نتيجة التوقع
        if result == 1:
            message = "Customer Churn Prediction: Likely to churn"
        else:
            message = "Customer Churn Prediction: Not likely to churn"

        return render_template("result.html", result=message)

    except KeyError as e:
        return f"Missing key: {e}", 400  # إرجاع خطأ واضح إذا كان هناك حقل مفقود

    except Exception as e:
        return f"An error occurred: {e}", 500  # إرجاع خطأ عام في حال حدوث خطأ آخر

y_pred = model.predict(X_test)
print("Accuracy:", accuracy_score(y_test, y_pred))
print("Classification Report:\n", classification_report(y_test, y_pred))

if __name__ == "__main__":
    app.run(debug=True)
