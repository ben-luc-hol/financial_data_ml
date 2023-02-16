# NAÏVE BAYES

import pandas as pd
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, confusion_matrix
from sklearn.naive_bayes import GaussianNB
import seaborn as sns
import numpy as np



data = pd.read_csv("data/data_winsorized.csv")

X = data[['MarketCapitalization', 'BookValue','DividendYield', 'RevenuePerShareTTM',
          'ProfitMargin', 'OperatingMarginTTM', 'ReturnOnAssetsTTM', 'ReturnOnEquityTTM',
          'QuarterlyEarningsGrowthYOY','QuarterlyRevenueGrowthYOY']]

y = data['EPS']>=0

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.2, random_state = 40)

##### NB WITHOUT LAPLACE SMOOTHING
nb = GaussianNB()
nb.fit(X_train, y_train)
y_predicted = nb.predict(X_test)

confmatrix = confusion_matrix(y_test, y_predicted)
columns = ['Predicted Positive', 'Predicted Positive']
rows = ['Actual Positive', 'Actual Negative']
fig, ax = plt.subplots(figsize = (8,6))
sns.heatmap(confmatrix, annot = True, fmt = 'd', xticklabels = columns, yticklabels = rows, ax = ax)
plt.title("Confusion Matrix")
plt.savefig("NB1.png")


print(classification_report(y_test, y_predicted))


