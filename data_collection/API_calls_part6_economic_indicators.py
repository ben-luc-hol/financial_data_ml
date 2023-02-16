# 6 ------------------------ Macroeconomic indicators ------------------------------------------------

import pandas as pd
import requests
from creds import apikeys

AV_key = apikeys.avkey

# REAL GDP, QUARTERLY

url = f"https://www.alphavantage.co/query?function=REAL_GDP&interval=quarterly&apikey={AV_key}"
gdp = requests.get(url)
gdp = gdp.json()
gdpnorm = pd.json_normalize(gdp)
gdpnorm = pd.json_normalize(gdp['data'])
gdpnorm.columns = ["date", "real_quarterly_gdp"]
gdpnorm

#Data for yield curve
# 10-year treasury yields - weekly
url = f"https://www.alphavantage.co/query?function=TREASURY_YIELD&interval=weekly&maturity=10year&apikey={AV_key}"
yields = requests.get(url)
yields = yields.json()
yields10norm = pd.json_normalize(yields['data'], max_level=1)
yields10norm.columns = ["date", "treasury_10y_yield"]
yields10norm
# 2-year treasury yields - weekly
url = f"https://www.alphavantage.co/query?function=TREASURY_YIELD&interval=weekly&maturity=2year&apikey={AV_key}"
yields = requests.get(url)
yields = yields.json()
yields2norm = pd.json_normalize(yields['data'], max_level=1)
yields2norm.columns = ["date", "treasury_2y_yield"]
yields2norm


## Fed funds rate  - weekly
url = f"https://www.alphavantage.co/query?function=FEDERAL_FUNDS_RATE&interval=weekly&apikey={AV_key}"
fedrate = requests.get(url)
fedrate = fedrate.json()
fedratenorm = pd.json_normalize(fedrate['data'], max_level=1)
fedratenorm.columns = ["date", "federal_funds_rate"]
fedratenorm

#CPI - monthly

url = f'https://www.alphavantage.co/query?function=CPI&interval=monthly&apikey={AV_key}'
cpi = requests.get(url)
cpi = cpi.json()
cpinorm = pd.json_normalize(cpi['data'], max_level=1)
cpinorm.columns = ["date", "cpi"]
cpinorm

#Expected inflation - monthly
url = f'https://www.alphavantage.co/query?function=INFLATION_EXPECTATION&apikey={AV_key}'
expinf = requests.get(url)
expinf = expinf.json()
expinfnorm = pd.json_normalize(expinf['data'], max_level=1)
expinfnorm.columns = ["date", "expected_core_inflation"]
expinfnorm


#Consumer sentiment - monthly
url = f'https://www.alphavantage.co/query?function=CONSUMER_SENTIMENT&apikey={AV_key}'
csentiment = requests.get(url)
csentiment = csentiment.json()
csentnorm = pd.json_normalize(csentiment['data'], max_level=1)
csentnorm.columns = ["date", "consumer_sentiment"]
csentnorm

#Retail sales - monthly
url = f'https://www.alphavantage.co/query?function=RETAIL_SALES&apikey={AV_key}'
retail = requests.get(url)
retail = retail.json()
retailnorm = pd.json_normalize(retail['data'], max_level=1)
retailnorm.columns = ["date", "retail_sales"]
retailnorm



#Durable goods orders - monthly
url = f'https://www.alphavantage.co/query?function=DURABLES&apikey={AV_key}'
durables = requests.get(url)
durables = durables.json()
durablesnorm = pd.json_normalize(durables['data'], max_level=1)
durablesnorm.columns = ["date", "durable_orders"]
durablesnorm


### Storing weekly indicators in one csv
#yields10norm
#yields2norm
#fedratenorm

weekly_indicators = pd.merge(yields10norm, yields2norm, on='date', how = 'outer')
fedratenorm['date'] = weekly_indicators['date']  # The dates are only 2 days apart
weekly_indicators = pd.merge(weekly_indicators, fedratenorm, on='date', how = 'outer')
weekly_indicators

weekly_indicators.to_csv('data/weekly_economic_indicators.csv', index= False)


### Storing monthly indicators in one csv
from functools import reduce

dfs = [cpinorm, expinfnorm, csentnorm, retailnorm, durablesnorm]
monthly_indicators = reduce(lambda left, right: pd.merge(left, right, how= "outer"), dfs)
monthly_indicators.to_csv('data/monthly_economic_indicators.csv', index= False)
gdpnorm.to_csv('data/quarterly_gdp.csv', index= False)



### Real GDP per capita (not to use for project, I just want this for later use)

url = f'https://www.alphavantage.co/query?function=REAL_GDP_PER_CAPITA&apikey={AV_key}'
gdpcap = requests.get(url)
gdpcap = gdpcap.json()
gdpnormc = pd.json_normalize(gdpcap['data'], max_level=1)
gdpnormc.columns = ["date", "per_capita_gdp"]
gdpnormc.to_csv("data/gdp_per_capita.csv")




