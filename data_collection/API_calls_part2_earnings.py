# 2 ------------------------ Company Earnings ------------------------------------------------

# Repeating steps from part 1.

import pandas as pd
import requests
from creds import apikeys
AV_key = apikeys.avkey


### Import proecessed company info data to create a list of unique companies:

company_overview = pd.read_csv('data/company_overview_in_progress.csv')
#company_overview.head(5)

companies_list_clean = list(company_overview['Symbol'])
#print(companies_list_clean)
#3967 companies that may return results in the API:
#len(companies_list_clean)

#Function to get earnings reports from the API:
def get_earnings(symbol,apikey):
    url = f"https://www.alphavantage.co/query?function=EARNINGS&symbol={symbol}&apikey={apikey}"
    r = requests.get(url)
    return r.json()

#Testing when the API didn't work:
#error_message = get_earnings('ASPI', avkey)
#test = companies_list_clean[0]

#Testing earnings data:
json_earn_test = get_earnings('ABNB',AV_key)


print("Test output for earnings:\n", json_earn_test)
#JSON Output for earnings data:
#print(json_earn_test)

#Defining function to clean earnings JSON to desired format:
#The JSON file(s) are nested. After some trial and error :
def format_earnings(json_file):
    earnings = pd.json_normalize(json_file, max_level=1)
    earnings_q = earnings['quarterlyEarnings'].apply(pd.Series).transpose()
    earnings_q = earnings_q[0].apply(pd.Series)
    earnings_q['ticker'] = earnings.iloc[0,0]
    earnings_q_cols = earnings_q.columns.tolist()
    earnings_q_cols = earnings_q_cols[-1:] + earnings_q_cols[:-1]
    earnings_q = earnings_q[earnings_q_cols]
    return earnings_q

test = format_earnings(json_earn_test)
test
#Some investigative work was needed when the API started throwing errors:
#print(error_message)
#error_message = pd.json_normalize(error_message, max_level=1)
#error_message

#Columns for the earnings data:
cols = ['ticker',
        'fiscalDateEnding',
        'reportedDate',
        'reportedEPS',
        'estimatedEPS',
        'surprise',
        'surprisePercentage']

#test_pd = clean_earnings(json_earn_test)
#earnings_cols = list(test_pd.columns)
#earnings_cols


###### The API sometimes gets overloaded with error messages.
# This is likely because some of the company symbols from the NASDAQ screener don't exist in the database.###

### BATCH 1
e_batch1 = pd.DataFrame()
e_batch1[cols] = cols #defined from test pandas frame

#This is more painstaking at first since we don't yet know which companies are in the API's database or not for this particular data.

#Starting with batches of 50.
for company in companies_list_clean[0:50]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch1 = pd.concat([e_batch1, clean_output])

e_batch1['ticker'].nunique()

## BATCH 2
e_batch2 = pd.DataFrame()
e_batch2[cols] = cols

for company in companies_list_clean[50:100]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch2 = pd.concat([e_batch2, clean_output])

e_batch2['ticker'].nunique()


### BATCH 3
e_batch3 = pd.DataFrame()
e_batch3[cols] = cols

for company in companies_list_clean[100:150]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch3 = pd.concat([e_batch3, clean_output])

e_batch3['ticker'].nunique()


### BATCH 4
e_batch4 = pd.DataFrame()
e_batch4[cols] = cols

for company in companies_list_clean[150:200]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch4 = pd.concat([e_batch4, clean_output])

e_batch4['ticker'].nunique()

### BATCH 5
e_batch5 = pd.DataFrame()
e_batch5[cols] = cols

for company in companies_list_clean[200:250]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch5 = pd.concat([e_batch5, clean_output])

e_batch5['ticker'].nunique()

### BATCH 6
e_batch6 = pd.DataFrame()
e_batch6[cols] = cols

for company in companies_list_clean[250:300]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch6 = pd.concat([e_batch6, clean_output])

e_batch6['ticker'].nunique()

### CONCATENATION AFTER BATCH 6
list_of_dfs = [e_batch1,e_batch2,e_batch3,e_batch4,e_batch5,e_batch6]

earnings_raw = pd.DataFrame()
earnings_raw[cols] = cols

for df in list_of_dfs:
    earnings_raw = pd.concat([earnings_raw, df])

earnings_raw
earnings_raw['ticker'].nunique()
#300 companies so far.


### BATCH 7
#'ASPI' NOT FOUND. REMOVE FROM COMPANIES LIST:
companies_list_clean.remove('ASPI')
print(companies_list_clean)
e_batch7 = pd.DataFrame()
e_batch7[cols] = cols

for company in companies_list_clean[300:350]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch7 = pd.concat([e_batch7, clean_output])

e_batch7['ticker'].nunique()


### BATCH 8
e_batch8 = pd.DataFrame()
e_batch8[cols] = cols

for company in companies_list_clean[350:400]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch8 = pd.concat([e_batch8, clean_output])

e_batch8['ticker'].nunique()

### BATCH 9
e_batch9 = pd.DataFrame()
e_batch9[cols] = cols

for company in companies_list_clean[400:450]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch9 = pd.concat([e_batch9, clean_output])

e_batch9['ticker'].nunique()


### BATCH 10
e_batch10 = pd.DataFrame()
e_batch10[cols] = cols

for company in companies_list_clean[450:500]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch10 = pd.concat([e_batch10, clean_output])

e_batch10['ticker'].nunique()


### BATCH 11
e_batch11 = pd.DataFrame()
e_batch11[cols] = cols

for company in companies_list_clean[500:550]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch11 = pd.concat([e_batch11, clean_output])

e_batch11['ticker'].nunique()

### BATCH 12 - Try to increase number!
e_batch12 = pd.DataFrame()
e_batch12[cols] = cols

for company in companies_list_clean[550:650]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch12 = pd.concat([e_batch12, clean_output])

e_batch12['ticker'].nunique()

### BATCH 13
e_batch13 = pd.DataFrame()
e_batch13[cols] = cols

for company in companies_list_clean[650:750]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch13 = pd.concat([e_batch13, clean_output])

e_batch13['ticker'].nunique()

### BATCH 14
e_batch14 = pd.DataFrame()
e_batch14[cols] = cols

for company in companies_list_clean[750:850]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch14 = pd.concat([e_batch14, clean_output])

e_batch14['ticker'].nunique()

### BATCH 15
e_batch15 = pd.DataFrame()
e_batch15[cols] = cols

for company in companies_list_clean[850:950]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch15 = pd.concat([e_batch15, clean_output])

e_batch15['ticker'].nunique()


### BATCH 16
e_batch16 = pd.DataFrame()
e_batch16[cols] = cols

for company in companies_list_clean[950:1050]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch16 = pd.concat([e_batch16, clean_output])

e_batch16['ticker'].nunique()

### BATCH 17
e_batch17 = pd.DataFrame()
e_batch17[cols] = cols

for company in companies_list_clean[1050:1150]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch17 = pd.concat([e_batch17, clean_output])

e_batch17['ticker'].nunique()


### BATCH 18
e_batch18 = pd.DataFrame()
e_batch18[cols] = cols

for company in companies_list_clean[1150:1250]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch18 = pd.concat([e_batch18, clean_output])

e_batch18['ticker'].nunique()


### BATCH 19 - Can the API handle more?
e_batch19 = pd.DataFrame()
e_batch19[cols] = cols

for company in companies_list_clean[1250:1400]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch19 = pd.concat([e_batch19, clean_output])

e_batch19['ticker'].nunique()

### BATCH 20

### 'FTHY' Not Found. Drop from list
companies_list_clean.remove('FTHY')
companies_list_clean.remove('GBBK')
companies_list_clean.remove('GLST')

e_batch20 = pd.DataFrame()
e_batch20[cols] = cols

for company in companies_list_clean[1400:1550]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch20 = pd.concat([e_batch20, clean_output])

e_batch20['ticker'].nunique()

### BATCH 21
e_batch21 = pd.DataFrame()
e_batch21[cols] = cols

for company in companies_list_clean[1550:1700]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch21 = pd.concat([e_batch21, clean_output])

e_batch21['ticker'].nunique()


### BATCH 22
e_batch22 = pd.DataFrame()
e_batch22[cols] = cols

for company in companies_list_clean[1700:1850]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch22 = pd.concat([e_batch22, clean_output])

e_batch22['ticker'].nunique()



#### Join Dataframes up to this point, housekeeping exercise.

list_of_dfs_2 = [e_batch7,e_batch8,e_batch9,e_batch10, e_batch11, e_batch12, e_batch13, e_batch14, e_batch15,
                 e_batch16, e_batch17, e_batch18, e_batch19, e_batch20,e_batch21,e_batch22]


for df in list_of_dfs_2:
    earnings_raw = pd.concat([earnings_raw, df])

earnings_raw['ticker'].nunique()

#Cont:



### BATCH 23
e_batch23 = pd.DataFrame()
e_batch23[cols] = cols

for company in companies_list_clean[1850:2000]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch23 = pd.concat([e_batch23, clean_output])

e_batch23['ticker'].nunique()

earnings_raw = pd.concat([earnings_raw, e_batch23])
earnings_raw['ticker'].nunique()



### BATCH 24
companies_list_clean.remove('LASE')
e_batch24 = pd.DataFrame()
e_batch24[cols] = cols

for company in companies_list_clean[2000:2150]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch24 = pd.concat([e_batch24, clean_output])

e_batch24['ticker'].nunique()

earnings_raw = pd.concat([earnings_raw, e_batch24])
earnings_raw['ticker'].nunique()



### BATCH 25
companies_list_clean.remove('LUCY')
companies_list_clean.remove('MGAM')
e_batch25 = pd.DataFrame()
e_batch25[cols] = cols

for company in companies_list_clean[2150:2300]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch25 = pd.concat([e_batch25, clean_output])

e_batch25['ticker'].nunique()

earnings_raw = pd.concat([earnings_raw, e_batch25])
earnings_raw['ticker'].nunique()

### BATCH 26
companies_list_clean.remove('NDACW')
e_batch26 = pd.DataFrame()
e_batch26[cols] = cols


for company in companies_list_clean[2300:2450]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch26 = pd.concat([e_batch26, clean_output])
e_batch26['ticker'].nunique()

earnings_raw = pd.concat([earnings_raw, e_batch26])
earnings_raw['ticker'].nunique()



### BATCH 27
companies_list_clean.remove('NXL')
e_batch27 = pd.DataFrame()
e_batch27[cols] = cols


for company in companies_list_clean[2450:2650]:   # increase to 200/batch
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch27 = pd.concat([e_batch27, clean_output])
e_batch27['ticker'].nunique()

earnings_raw = pd.concat([earnings_raw, e_batch27])
earnings_raw['ticker'].nunique()


### BATCH 28
e_batch28 = pd.DataFrame()
e_batch28[cols] = cols


for company in companies_list_clean[2650:2850]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch28 = pd.concat([e_batch28, clean_output])
e_batch28['ticker'].nunique()

earnings_raw = pd.concat([earnings_raw, e_batch28])
earnings_raw['ticker'].nunique()



### BATCH 29
e_batch29 = pd.DataFrame()
e_batch29[cols] = cols


for company in companies_list_clean[2850:3050]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch29 = pd.concat([e_batch29, clean_output])
e_batch29['ticker'].nunique()

earnings_raw = pd.concat([earnings_raw, e_batch29])
earnings_raw['ticker'].nunique()


### BATCH 30
companies_list_clean.remove('SNAL')
e_batch30 = pd.DataFrame()
e_batch30[cols] = cols


for company in companies_list_clean[3050:3250]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch30 = pd.concat([e_batch30, clean_output])
e_batch30['ticker'].nunique()

earnings_raw = pd.concat([earnings_raw, e_batch30])
earnings_raw['ticker'].nunique()



### BATCH 31
companies_list_clean.remove('SQFTW')
companies_list_clean.remove('STEW')
companies_list_clean.remove('TBLD')

e_batch31 = pd.DataFrame()
e_batch31[cols] = cols


for company in companies_list_clean[3250:3450]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch31 = pd.concat([e_batch31, clean_output])
e_batch31['ticker'].nunique()

earnings_raw = pd.concat([earnings_raw, e_batch31])
earnings_raw['ticker'].nunique()

### BATCH 32
companies_list_clean.remove('TMKRW')
companies_list_clean.remove('UHALB')

e_batch32 = pd.DataFrame()
e_batch32[cols] = cols


for company in companies_list_clean[3450:3650]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch32 = pd.concat([e_batch32, clean_output])
e_batch32['ticker'].nunique()

earnings_raw = pd.concat([earnings_raw, e_batch32])
earnings_raw['ticker'].nunique()

### BATCH 33
e_batch33 = pd.DataFrame()
e_batch33[cols] = cols


for company in companies_list_clean[3650:3850]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch33 = pd.concat([e_batch33, clean_output])
e_batch33['ticker'].nunique()

earnings_raw = pd.concat([earnings_raw, e_batch33])
earnings_raw['ticker'].nunique()



### BATCH 34
companies_list_clean.remove('WTMAR')

e_batch34 = pd.DataFrame()
e_batch34[cols] = cols


for company in companies_list_clean[3850:]:
    output = get_earnings(company,AV_key)
    clean_output = format_earnings(output)
    e_batch34 = pd.concat([e_batch34, clean_output])
e_batch34['ticker'].nunique()

earnings_raw = pd.concat([earnings_raw, e_batch34])
earnings_raw['ticker'].nunique()



earnings_raw = earnings_raw.reset_index()
earnings_raw.to_csv('data/company_earnings_raw.csv')


#Length of the list of companies now equals the number of unique stock symbols found in the earnings dataset.
len(companies_list_clean) == earnings_raw['ticker'].nunique()


#Exporting list of companies that successfully made it through the first API round.
companieslist = pd.DataFrame(companies_list_clean)
companieslist.to_csv('data/companies_list_v1.csv', index = False)