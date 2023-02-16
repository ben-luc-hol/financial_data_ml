
# 1 ------------------------ Company Overview ------------------------------------------------
### ONE .py file is created for the API calls for each category of data.
### The process will likely become more streamlined through the process.
import pandas as pd
import requests

# creds is a local directory created to store any API key(s).
# This file is added to the project’s .gitignore so the API key(s) are protected.
# AlphaVantage generously granted premium API access for this project.
#For more information about this API see alphavantage.co/documentation.

from creds import apikeys

# Masked API key variable:
AV_key = apikeys.avkey

#The Nasdaq website has a comprehensive listing of the securities listed on the NYSE and NASDAQ exchanges.
#This list can be accessed at https://www.nasdaq.com/market-activity/stocks/screener.

# The only filter applied in the screening was under "COUNTRY", where only "United States" and "USA" were selected.
# Csv downloaded and stored as ‘nasdaq_screener_all.csv’

#From this, extract ALL common stock ticker symbols listed on the NYSE and NASDAQ exchanges:
# importing nasdaq securities list:
nasdaq_list = pd.read_csv('data/nasdaq_screener_all.csv')
#nasdaq_list = nasdaq_full
#we simply want the lists of symbols. Some of these are either holding companies, warrants, or other securities that in effect duplicates,
#The list of symbols will be used for the API call.

preview = nasdaq_list.head(50)
preview
len(nasdaq_list)
# In symbols, securities that are special securities connected to a given company (warrants and others) contain '^'.
# Filter these out:
nasdaq_list['filter_out'] = nasdaq_list.Symbol.str.contains('^', regex = False)
nasdaq_list = nasdaq_list[nasdaq_list['filter_out'] == False]

#Filter out any securities that are not explicitly listed as Common Stocks in the name field.
# That should return symbols for companies and can be used for the API.
nasdaq_list['common_stock'] = nasdaq_list.Name.str.contains('Common Stock', case=False)

#Filter only for common stocks, finally:
nasdaq_list = nasdaq_list[nasdaq_list['common_stock'] == True]
nasdaq_list = nasdaq_list[['Symbol', 'Name', 'Sector', 'Industry']]
nasdaq_list.head(50)
nasdaq_list.to_csv('data/nasdaq_screener_PROCESSED.csv')

nasdaq_list = pd.read_csv('data/nasdaq_screener_PROCESSED.csv')

#Creating list of stock symbols
companies_list = nasdaq_list['Symbol']
companies_list = list(companies_list)
#print(companies_list)
#len(companies_list) #4215 unique stock symbols.
companies_list

### Defining function to get company overview from AlphaVantage API:
def get_overview(symbol,apikey):
    url = f"https://www.alphavantage.co/query?function=OVERVIEW&symbol={symbol}&apikey={apikey}"
    r = requests.get(url)
    return r.json()

#The output is in JSON format. Try it with the first company on the list:
test = companies_list[19]
overview_test = get_overview(test,AV_key)
print('Test JSON output for company overview: \n', overview_test)
#print(overview_test.to_html())

# Writing function to convert JSON output to data frame:
def format_overview(json_string):
    overview = pd.json_normalize(json_string, max_level=0)
    return overview

overview_clean_test = format_overview(overview_test)
overview_clean_test

# Now, creating dataframe with all the company overviews:

overview_columns = overview_clean_test.columns.tolist()
#print(overview_columns)

#Data frame to concatenate
all_overviews = pd.DataFrame()
all_overviews[overview_columns] = overview_columns

# Iterating API call and JSON cleaning for each of the 4215 symbols in companies_list
# Note: This takes a while!
for i in companies_list:
    output = get_overview(i, avkey)
    clean_output = format_overview(output)
    all_overviews = pd.concat([all_overviews, clean_output])

all_overviews.reset_index(inplace=True)

#Storing the raw data:
all_overviews.to_csv('data/company_overview_raw.csv')

### Data will be cleaned in R.

all_overviews = pd.read_csv('data/company_overview_raw.csv')
all_overviews['Symbol'].nunique()
all_overviews