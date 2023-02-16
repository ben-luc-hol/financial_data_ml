import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
data = pd.read_csv('data/firms_3883.csv')
### Make dataset smaller to eliminate extreme values
### ADDITIONAL DATA PREPROCESSING
#def cut(variable, lower_bound, upper_bound):
#    low = variable.quantile(lower_bound)
#    high = variable.quantile(upper_bound)
#    result = variable.clip(low, high)
#    return result

numdata = data.select_dtypes(include=['number'])
numdata.nunique()




#see percentiles for data to determine where to cut extreme values
percentiles = pd.DataFrame()
percentiles['percentile'] = np.arange(0.0, 1.001, .001)
for variable in numdata:
    percentiles[f'{variable}'] = np.quantile(data[f'{variable}'], percentiles['percentile'])
percentiles

#plot the distributions
def distplot(variable):
    x = np.arange(0.0,1.001,0.001)
    y = np.quantile(variable, x)
    plt.plot(x, y)
    plt.xlabel('Percentile')
    plt.ylabel(f'{variable.name}')
    plt.show()


def showtails(variable):
    v = variable.name
    displ = percentiles[['percentile', f'{v}']]
    print(displ.head(50))
    print(displ.tail(50))

   print(data.head())

def winsorize(variable, lowerbound, upperbound):
    variable = np.array(variable)
    variable[variable < lowerbound] = lowerbound
    variable[variable > upperbound] = upperbound
    return variable

def quickhist(variable, bins):
    plt.hist(variable, bins)
    plt.xlabel(variable.name)
    plt.ylabel('# companies')
    plt.show()



### filtered_data shows the value distribution for a variable down to one tenth of a percent.
#Winsorise extreme values.

# Mkt cap kept as-is.

## Revenue
#Filter out companies reporting zero or negative revenue:
winsor_data = data[data['RevenueTTM']>0]

winsor_data = pd.DataFrame(winsor_data)


#Book Value
distplot(winsor_data['BookValue'])
showtails(winsor_data['BookValue'])
#winsorise book value, min = 0, 1.5th percentile. max = 60, ~ 96th percentile..
winsor_data['BookValue'] = winsorize(winsor_data['BookValue'], 0, 60)
distplot(winsor_data['BookValue'])

#Div per share
distplot(winsor_data['DividendPerShare'])
showtails(winsor_data['DividendPerShare'])


#Div yield
distplot(winsor_data['DividendYield'])
showtails(winsor_data['DividendYield'])
winsor_data['DividendYield'] = winsorize(winsor_data['DividendYield'], 0, 1)
distplot(winsor_data['DividendYield'])



#EPS - 1st & 98th
distplot(winsor_data['EPS'])
showtails(winsor_data['EPS'])
winsor_data['EPS'] = winsorize(winsor_data['EPS'], -10, 20)
distplot(winsor_data['EPS'])

#Revenue per share - 0.4th & 97.5th
distplot(winsor_data['RevenuePerShareTTM'])
showtails(winsor_data['RevenuePerShareTTM'])
winsor_data['RevenuePerShareTTM'] = winsorize(winsor_data['RevenuePerShareTTM'], 0, 186)
distplot(winsor_data['RevenuePerShareTTM'])


#Profit margin - 4.6th - 99.5th - percentages
distplot(winsor_data['ProfitMargin'])
showtails(winsor_data['ProfitMargin'])
winsor_data['ProfitMargin'] = winsorize(winsor_data['ProfitMargin'], -1, 1)
distplot(winsor_data['ProfitMargin'])


#Op margin - ---15th  - 99.5th - percentages
distplot(winsor_data['OperatingMarginTTM'])
showtails(winsor_data['OperatingMarginTTM'])
winsor_data['OperatingMarginTTM'] = winsorize(winsor_data['OperatingMarginTTM'], -3, 1)
distplot(winsor_data['OperatingMarginTTM'])

#ROA - ---1st  - 99.9th - percentages
distplot(winsor_data['ReturnOnAssetsTTM'])
showtails(winsor_data['ReturnOnAssetsTTM'])
winsor_data['ReturnOnAssetsTTM'] = winsorize(winsor_data['ReturnOnAssetsTTM'], -1, 1)
distplot(winsor_data['ReturnOnAssetsTTM'])



#  2.5th - 97.5th
distplot(winsor_data['ReturnOnEquityTTM'])
showtails(winsor_data['ReturnOnEquityTTM'])
winsor_data['ReturnOnEquityTTM'] = winsorize(winsor_data['ReturnOnEquityTTM'], -8, 24)
distplot(winsor_data['ReturnOnEquityTTM'])



#  0 - 98th
distplot(winsor_data['QuarterlyEarningsGrowthYOY'])
showtails(winsor_data['QuarterlyEarningsGrowthYOY'])
winsor_data['QuarterlyEarningsGrowthYOY'] = winsorize(winsor_data['QuarterlyEarningsGrowthYOY'], -1, 10)
distplot(winsor_data['QuarterlyEarningsGrowthYOY'])

#  0 - 99th
distplot(winsor_data['QuarterlyRevenueGrowthYOY'])
showtails(winsor_data['QuarterlyRevenueGrowthYOY'])
winsor_data['QuarterlyRevenueGrowthYOY'] = winsorize(winsor_data['QuarterlyRevenueGrowthYOY'], -1, 10)
distplot(winsor_data['QuarterlyRevenueGrowthYOY'])



winsor_data.to_csv('data/data_winsorized.csv')


cut_data = data[data['BookValue'] >= 0]
cut_data = cut_data[cut_data['BookValue'] < 60]

cut_data = cut_data[cut_data['DividendYield'] < 1]
cut_data = cut_data[cut_data['DividendYield'] >= 0]

cut_data = cut_data[cut_data['EPS'] >= -10]
cut_data = cut_data[cut_data['EPS'] < 20]

cut_data = cut_data[cut_data['RevenuePerShareTTM'] >= 0]
cut_data = cut_data[cut_data['RevenuePerShareTTM'] < 186]

cut_data = cut_data[cut_data['ProfitMargin'] > -1]
cut_data = cut_data[cut_data['ProfitMargin'] < 1]

cut_data = cut_data[cut_data['OperatingMarginTTM'] > -3]
cut_data = cut_data[cut_data['OperatingMarginTTM'] < 1]

cut_data = cut_data[cut_data['ReturnOnAssetsTTM'] > -1]
cut_data = cut_data[cut_data['ReturnOnAssetsTTM'] < 1]

cut_data = cut_data[cut_data['ReturnOnEquityTTM'] > -8]
cut_data = cut_data[cut_data['ReturnOnEquityTTM'] < 24]

cut_data = cut_data[cut_data['RevenueTTM'] > 0]

cut_data = cut_data[cut_data['QuarterlyEarningsGrowthYOY'] > -1]
cut_data = cut_data[cut_data['QuarterlyEarningsGrowthYOY'] < 10]

cut_data = cut_data[cut_data['QuarterlyRevenueGrowthYOY'] > -1]
cut_data = cut_data[cut_data['QuarterlyRevenueGrowthYOY'] < 10]


#(2390 companies left)
cut_data.to_csv('data/companies_list_reduced.csv')