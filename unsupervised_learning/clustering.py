
import pandas as pd
from sklearn.metrics import silhouette_score, pairwise_distances
from sklearn.cluster import KMeans, DBSCAN, AgglomerativeClustering
import matplotlib.pyplot as plt
from sklearn.preprocessing import StandardScaler
import numpy as np
import scipy.cluster.hierarchy as sch

## Objectives:
# * Select numeric data only
# * Perform partition / K-Means clustering, 3 values of K
# * Perform hierarchical / Ward clustering, 3 distance metrics

# * Perform density/DBSCAN clustering,


#Select numeric data only, use winsorized and/or reduced data.

data_w = pd.read_csv('data/data_winsorized.csv')


#Drop DPS, Revenue, and Gross Profit
data_w = data_w.select_dtypes(include=['number'])
data_w = data_w.drop(columns = ['DividendPerShare', 'RevenueTTM', 'GrossProfitTTM'], axis = 1)
data_w = data_w.drop(columns = data_w.columns[0], axis = 1)
data_w.head(100)




#Standardize
#data_standardized = (numdata - numdata.mean()) / numdata.std()
#data_standardized.head()

def goplot(data, x, y):
    x = data[f'{x}']
    y = data[f'{y}']
    plt.scatter(x,y)
    plt.title(f'{x.name} vs. {y.name}')
    plt.xlabel(f'{x.name}')
    plt.ylabel(f'{y.name}')
    plt.show()


#def cluscatter(data, x, y var2, method):
#    lowerbound_var1 = np.percentile(var1, .5)
#    upperbound_var1 = np.percentile(var1, 99.5)
#    lowerbound_var2 = np.percentile(var2, .5)
#    upperbound_var2 = np.percentile(var2, 99.5)
#    plt.scatter(var1, var2)
#    plt.xlim(lowerbound_var1, upperbound_var1)
#    plt.ylim(lowerbound_var2, upperbound_var2)
#    plt.title(f"{method} Clustering")
#    plt.xlabel(f"{var1.name}")
#    plt.ylabel(f"{var2.name}")
#    plt.show()

print(list(data_w.columns))

goplot(data_w, 'ProfitMargin', 'EPS')
marketcap = data_w['MarketCapitalization']
data_w = data_w.drop(columns = ['MarketCapitalization'], axis = 1)

scaler = StandardScaler()
data_w_s = scaler.fit_transform(data_w)
data_w_s
#book value v div yield
#book value v eps !
#profit margin v roa

#Run an elbow method for KMeans to illustrate
scores = []
for k in range(2,12):
    kmeans = KMeans(n_clusters = k)
    kmeans.fit(data_w)
    average_silhouette = silhouette_score(data_w, kmeans.labels_)
    scores.append(average_silhouette)

fig = plt.figure(figsize=(10,6))
plt.plot(range(2,12), scores)
plt.xlabel('No. of clusters')
plt.ylabel('Silhouette score')
plt.title('Elbow method: Winsorized')
plt.savefig('elbow1.png')
plt.show()


scores = []
for k in range(2,12):
    kmeans = KMeans(n_clusters = k)
    kmeans.fit(data_w_s)
    average_silhouette = silhouette_score(data_w_s, kmeans.labels_)
    scores.append(average_silhouette)

fig = plt.figure(figsize=(10,6))
plt.plot(range(2,12), scores)
plt.xlabel('No. of clusters')
plt.ylabel('Silhouette score')
plt.title('Elbow method: Winsorized - Standardized ')
plt.savefig('elbow2.png')
plt.show()




scores = []
for k in range(2,12):
    kmeans = KMeans(n_clusters = k)
    kmeans.fit(data_w)
    average_silhouette = silhouette_score(data_w, kmeans.labels_)
    scores.append(average_silhouette)

fig = plt.figure(figsize=(10,6))
plt.plot(range(2,12), scores)
plt.xlabel('No. of clusters')
plt.ylabel('Silhouette score')
plt.title('Elbow method: Winsorized')
plt.savefig('elbow1.png')
plt.show()



# FOR VISUALIZATION:
#marketcap = marketcap.replace(0, 0.000000000001)
x = np.log(marketcap)
y = data_w['RevenuePerShareTTM']
#y = y.replace(0,0.00000000000)
y = np.log(y)


##### 3 CLUSTERS
k3 = KMeans(n_clusters=3, random_state=0).fit(data_w)
k3_labels = k3.predict(data_w)


plt.figure(figsize=(18,10))
plt.scatter(x, data_w['RevenuePerShareTTM'], c = k3_labels)
plt.title('K-Means clustering - K = 3, Non-standardized')
plt.xlabel('Natural log of market capitalization')
plt.ylabel('Revenue per share')
plt.savefig('k3_1.png')
plt.show()

## 3 CLUSTERS - STANDARDIZED

#K = 5 WITHOUT RPS
k3b = KMeans(n_clusters=5, random_state=0).fit(data_w_s)
k3b_labels = k3b.predict(data_w_s)


data_w['K3N'] = k3b_labels
data_w['LogMarketCap'] = x
data_w

plt.figure(figsize=(18,10))
plt.scatter('LogMarketCap', 'RevenuePerShareTTM', data = data_w, c = 'K3N')
plt.title('K-Means clustering - K = 3, Standardized')
plt.xlabel('Natural log of market capitalization')
plt.ylabel('Revenue per share')
plt.legend()
#plt.savefig('k3_b.png')
plt.show()





### K = 5
k5 = KMeans(n_clusters=5, random_state=0).fit(data_w)
k5_labels = k5.predict(data_w)


logRPS = np.log(data_w['RevenuePerShareTTM'])
data_w['logRPS'] = logRPS


plt.figure(figsize=(18,10))
plt.scatter(x, logRPS, c = k5_labels)
plt.title('K-Means clustering - K = 5, Non-Standardized')
plt.xlabel('Natural log of market capitalization')
plt.ylabel('Natural log of revenue per share')
plt.savefig('k5_1.png')
plt.show()


#K = 5 STANDARDIZED
k5b = KMeans(n_clusters=5, random_state=0).fit(data_w_s)
k5b_labels = k5b.predict(data_w_s)
data_w['K5N'] = k5b_labels


plt.figure(figsize=(18,10))
plt.scatter(x, logRPS, c = k5b_labels, alpha= 0.7)
plt.title('K-Means clustering - K = 5, Standardized')
plt.xlabel('Natural log of market capitalization')
plt.ylabel('Natural log of revenue per share')
plt.savefig('k5_b.png')
plt.show()


plt.figure(figsize=(18,10))
plt.scatter(x, data_w['EPS'], c = k5b_labels, alpha = 0.5)
plt.title('K-Means clustering - K = 5, Standardized')
plt.xlabel('Natural log of market capitalization')
plt.ylabel('Earnings Per Share')
plt.savefig('k5_c.png')
plt.show()

plt.figure(figsize=(18,10))
plt.scatter(logRPS, data_w['EPS'],c = k5b_labels, alpha = 0.5)
plt.title('K-Means clustering - K = 5, standardized')
plt.xlabel('Revenue per share (natural log)')
plt.ylabel('Earnings per share')
plt.savefig('k5_d.png')
plt.show()


## K = 10 STANDARDIZED

k10 = KMeans(n_clusters=10, random_state=0).fit(data_w_s)
k10_labels = k10.predict(data_w_s)
data_w['K10N'] = k10_labels

plt.figure(figsize=(18,10))
plt.scatter('LogMarketCap', 'logRPS', data = data_w, c = 'K10N', alpha= 0.6)
plt.title('K-Means clustering - K = 10, Standardized')
plt.xlabel('Natural log of market capitalization')
plt.ylabel('Natural log of revenue per share')
plt.savefig('k10_a.png')
plt.show()

plt.figure(figsize=(18,10))
plt.scatter('logRPS', 'EPS', data = data_w, c = 'K10N', alpha= 0.6)
plt.title('K-Means clustering - K = 10, Standardized')
plt.xlabel('Revenue per share (natural log)')
plt.ylabel('Earnings per share')
plt.savefig('k10_b.png')
plt.show()






### HIERARCHICAL CLUSTERING


#Continuing with the STANDARDIZED dataset and 5 clusters

#visualizing dendrogram:
plt.figure(figsize=(18, 18))
plt.title("Dendrogram, Ward")
dend = sch.dendrogram(sch.linkage(data_w_s, method='ward'))
plt.savefig('dendro1.png')


## Ward linkage
# Euclidean
h1 = AgglomerativeClustering(n_clusters=5, linkage='ward').fit(data_w_s)
h1_labels = h1.labels_
data_w['H10'] = h1_labels
data_w

plt.figure(figsize=(18,10))
plt.scatter('LogMarketCap', 'logRPS', data = data_w, c = 'H10', alpha= 0.6)
plt.title('Hierarchical clustering, Ward linkage - K = 5, Standardized')
plt.xlabel('Natural log of market capitalization')
plt.ylabel('Natural log of revenue per share')
plt.savefig('h10_a.png')
plt.show()

plt.figure(figsize=(18,10))
plt.scatter('logRPS', 'EPS', data = data_w, c = 'H10', alpha= 0.6)
plt.title('Hierarchical clustering, Ward linkage - K = 5, Standardized')
plt.xlabel('Revenue per share (natural log)')
plt.ylabel('Earnings per share')
plt.savefig('h10_b.png')
plt.show()


## cosine similarity
h2 = AgglomerativeClustering(n_clusters=5, linkage="average", affinity = 'cosine').fit(data_w_s)
h2_labels = h2.labels_
data_w['H10_cos'] = h2_labels
data_w

plt.figure(figsize=(18,10))
plt.scatter('LogMarketCap', 'logRPS', data = data_w, c = 'H10_cos', alpha= 0.6)
plt.title('Hierarchical clustering, Avg. linkage, Cosine Similarity - K = 5, Standardized')
plt.xlabel('Natural log of market capitalization')
plt.ylabel('Natural log of revenue per share')
plt.savefig('h10_c.png')
plt.show()

plt.figure(figsize=(18,10))
plt.scatter('logRPS', 'EPS', data = data_w, c = 'H10_cos', alpha= 0.6)
plt.title('Hierarchical clustering, Avg. linkage, Cosine Similarity - K = 5, Standardized')
plt.xlabel('Revenue per share (natural log)')
plt.ylabel('Earnings per share')
plt.savefig('h10_d.png')
plt.show()

### Manhattan distance
h3 = AgglomerativeClustering(n_clusters=5, linkage="average", affinity = 'manhattan').fit(data_w_s)
h3_labels = h3.labels_
data_w['H10_manhattan'] = h3_labels
data_w

plt.figure(figsize=(18,10))
plt.scatter('LogMarketCap', 'logRPS', data = data_w, c = 'H10_manhattan', alpha= 0.6)
plt.title('Hierarchical clustering, Avg. linkage, Manhattan distance - K = 5, Standardized')
plt.xlabel('Natural log of market capitalization')
plt.ylabel('Natural log of revenue per share')
plt.savefig('h10_e.png')
plt.show()

plt.figure(figsize=(18,10))
plt.scatter('logRPS', 'EPS', data = data_w, c = 'H10_manhattan', alpha= 0.6)
plt.title('Hierarchical clustering, Avg. linkage, Manhattan distance - K = 5, Standardized')
plt.xlabel('Revenue per share (natural log)')
plt.ylabel('Earnings per share')
plt.savefig('h10_f.png')
plt.show()
###### DBSCAN
eps_values = [0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8, 0.9, 1, 1.1, 1.2, 1.3, 1.4, 1.5]
clusters = []
for e in eps_values:
    dbscan = DBSCAN(eps=e, min_samples = 75)
    cluster = dbscan.fit_predict(data_w_s)
    clusters.append (len(set(cluster)) - (1 if -1 in clusters else 0))

plt.figure(figsize=(12,12))
plt.plot(eps_values, clusters)
plt.xlabel('eps')
plt.ylabel('No. of clusters')
plt.title('No. clusters by EPS')
plt.savefig('elbow3.png')
plt.show()

### run DBSCAN
dbscan = DBSCAN(eps = 1, min_samples=75)
dbscan_labels = dbscan.fit_predict(data_w_s)
data_w['DBSCAN'] = dbscan_labels


plt.figure(figsize=(18,10))
plt.scatter('LogMarketCap', 'logRPS', data = data_w, c = 'DBSCAN', alpha= 0.6)
plt.title('DBSCAN, Standardized - K=3')
plt.xlabel('Natural log of market capitalization')
plt.ylabel('Natural log of revenue per share')
plt.savefig('db_1.png')
plt.show()

plt.figure(figsize=(18,10))
plt.scatter('logRPS', 'EPS', data = data_w, c = 'DBSCAN', alpha= 0.6)
plt.title('DBSCAN, Standardized - K=3')
plt.xlabel('Revenue per share (natural log)')
plt.ylabel('Earnings per share')
plt.savefig('db_2.png')
plt.show()
