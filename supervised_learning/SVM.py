from sklearn.metrics import confusion_matrix, classification_report
from sklearn.model_selection import train_test_split
import pandas as pd
from sklearn.svm import SVC
from sklearn.svm import LinearSVC
import matplotlib.pyplot as plt
import seaborn as sns

data = pd.read_csv("data/data_winsorized.csv")


#outcome variable
data['Dividend'] = data['DividendYield'] > 0
#select numeric continuous attributes ONLY
numeric_data = data[['BookValue', 'RevenuePerShareTTM', 'ProfitMargin',
                     'OperatingMarginTTM', 'ReturnOnAssetsTTM', 'ReturnOnEquityTTM',
                     'QuarterlyEarningsGrowthYOY','QuarterlyRevenueGrowthYOY',
                     'Dividend']]


#Split data into training and testing
train, test = train_test_split(numeric_data, test_size=0.25, random_state=42)

#Extracting labels for each
test_label = test['Dividend']
train_label = train['Dividend']

#print(train_label)
#print(test_label)

test = test.drop(columns = ['Dividend'], axis = 1)
train = train.drop(columns = ['Dividend'], axis = 1)

#Confusion matrix

def confmatrix(test, prediction, savename):
    cmx = confusion_matrix(test, prediction)
    columns = ['Predicted Positive', 'Predicted Positive']
    rows = ['Actual Positive', 'Actual Negative']
    fig, ax = plt.subplots(figsize = (8,6))
    sns.heatmap(cmx, annot = True, fmt = 'd', xticklabels = columns, yticklabels = rows, ax = ax)
    plt.title("Confusion Matrix")
    plt.savefig(f'{savename}')
    plt.show()




### Run SVM for 3 kernels, cost
linear = LinearSVC(C=50)
linear.fit(train, train_label)
linear_pred = linear.predict(test)
linear_pred

print(classification_report(test_label, linear_pred))
confmatrix(test_label, linear_pred, "SVM0.png")



poly = SVC(C=50, kernel= 'poly')
poly.fit(train, train_label)
poly_pred = poly.predict(test)
poly_pred
print(classification_report(test_label, poly_pred))
confmatrix(test_label, poly_pred, "SVM1.png")


rbf = SVC(C=120, kernel= 'rbf', gamma=0.001)
rbf.fit(train, train_label)
rbf_pred = rbf.predict(test)
rbf_pred
print(classification_report(test_label, rbf_pred))
confmatrix(test_label, rbf_pred, "SVM2.png")

rbf = SVC(C=120, kernel= 'rbf')
rbf.fit(train, train_label)
rbf_pred = rbf.predict(test)
rbf_pred
print(classification_report(test_label, rbf_pred))
confmatrix(test_label, rbf_pred, "SVM4.png")


sig = SVC(C=4, kernel= 'sigmoid')
sig.fit(train, train_label)
sig_pred = sig.predict(test)
sig_pred
print(classification_report(test_label, sig_pred))
confmatrix(test_label, sig_pred, 'SVM3.png')

#lin_SVM = LinearSVC(C=2, max_iter = 1000)
#lin_SVM.fit(train, train_label)
#lin_prediction = lin_SVM.predict(test)
#lin_prediction
#print(classification_report(test_label, lin_prediction))














