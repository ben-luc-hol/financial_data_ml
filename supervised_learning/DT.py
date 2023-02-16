import pandas as pd
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn import tree
from sklearn.metrics import confusion_matrix, classification_report
import seaborn as sns

data = pd.read_csv("data/firms_3883.csv")

# Numeric Data DT - Predicting positive or negative EPS

X = data[['MarketCapitalization', 'BookValue','DividendYield', 'RevenuePerShareTTM',
          'ProfitMargin', 'OperatingMarginTTM', 'ReturnOnAssetsTTM', 'ReturnOnEquityTTM',
          'QuarterlyEarningsGrowthYOY','QuarterlyRevenueGrowthYOY']]

y = data['EPS']>=0

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.2, random_state = 40)

dt = tree.DecisionTreeClassifier()
dt.fit(X_train, y_train)

y_predicted = dt.predict(X_test)

confmatrix = confusion_matrix(y_test, y_predicted)
columns = ['Predicted Positive', 'Predicted Positive']
rows = ['Actual Positive', 'Actual Negative']
fig, ax = plt.subplots(figsize = (8,6))
sns.heatmap(confmatrix, annot = True, fmt = 'd', xticklabels = columns, yticklabels = rows, ax = ax)
plt.title("Confusion Matrix")
plt.savefig("confmatrix1.png")



print(classification_report(y_test, y_predicted))

fig = plt.figure(figsize = (100,80))
e = tree.plot_tree(dt,
                   fontsize = 8,
                   feature_names=X.columns,
                   class_names=True,
                   filled = True)
plt.savefig("dt1.png")


