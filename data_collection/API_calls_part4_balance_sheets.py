# 4 ------------------------ Company Balance Sheets ------------------------------------------------


import pandas as pd
import requests
from creds import apikeys

AV_key = apikeys.avkey
companies_list = pd.read_csv('data/companies_list_v2.csv')
companies_list = list(companies_list.iloc[:,0])
#companies_list
len(companies_list)

# 3,946 companies in the updated companies list from importing income statements.



#Function to get JSONs
def get_balsheet(symbol,apikey):
    url = f"https://www.alphavantage.co/query?function=BALANCE_SHEET&symbol={symbol}&apikey={apikey}"
    r = requests.get(url)
    return r.json()

#Function to format JSONs
def format_balsheet(json_file):
    balsheet = pd.json_normalize(json_file, max_level=1)
    balsheet_q = balsheet['quarterlyReports'].apply(pd.Series).transpose()
    balsheet_q = balsheet_q[0].apply(pd.Series)
    balsheet_q['ticker'] = balsheet.iloc[0,0]
    balsheet_q_cols = balsheet_q.columns.tolist()
    balsheet_q_cols = balsheet_q_cols[-1:] + balsheet_q_cols[:-1]
    balsheet_q = balsheet_q[balsheet_q_cols]
    return balsheet_q


#Function to test for error if API doesn't cooperate:
def test_for_errors(company):
    key = AV_key
    output = get_balsheet(company,key)
    try:
        clean_output = format_balsheet(output)
        return clean_output
    except:
        return "error"


testj = get_balsheet('ABNB', AV_key)
print("test JSON for balance sheets\n", testj)
test = format_balsheet(testj)
test
balsheet_cols = list(test.columns)
#balsheet_cols



### Main df:
company_balance_sheets = pd.DataFrame()
company_balance_sheets[balsheet_cols] = balsheet_cols
company_balance_sheets


#BATCHES


##### 1
batch1 = pd.DataFrame()
batch1[balsheet_cols] = balsheet_cols

for company in companies_list[0:200]:
    output = get_balsheet(company, AV_key)
    clean_output = format_balsheet(output)
    batch1 = pd.concat([batch1, clean_output])

batch1['ticker'].nunique() #200

#No errors.

company_balance_sheets = pd.concat([company_balance_sheets, batch1])
company_balance_sheets['ticker'].nunique()  # should now be 200.



##### 2
batch2 = pd.DataFrame()
batch2[balsheet_cols] = balsheet_cols

for company in companies_list[200:400]:
    output = get_balsheet(company, AV_key)
    clean_output = format_balsheet(output)
    batch2 = pd.concat([batch2, clean_output])

batch2['ticker'].nunique() #200

#No errors.

company_balance_sheets = pd.concat([company_balance_sheets, batch2])
company_balance_sheets['ticker'].nunique()  # should now be 400.




##### 3
batch3 = pd.DataFrame()
batch3[balsheet_cols] = balsheet_cols

for company in companies_list[400:600]:
    output = get_balsheet(company, AV_key)
    clean_output = format_balsheet(output)
    batch3 = pd.concat([batch3, clean_output])

batch3['ticker'].nunique() #200

#No errors.

company_balance_sheets = pd.concat([company_balance_sheets, batch3])
company_balance_sheets['ticker'].nunique()  # should now be 600.



##### 4
batch4 = pd.DataFrame()
batch4[balsheet_cols] = balsheet_cols

for company in companies_list[600:800]:
    output = get_balsheet(company, AV_key)
    clean_output = format_balsheet(output)
    batch4 = pd.concat([batch4, clean_output])

batch4['ticker'].nunique() #200

#No errors.

company_balance_sheets = pd.concat([company_balance_sheets, batch4])
company_balance_sheets['ticker'].nunique()  # should now be 800.


##### 5
batch5 = pd.DataFrame()
batch5[balsheet_cols] = balsheet_cols

for company in companies_list[800:1000]:
    output = get_balsheet(company, AV_key)
    clean_output = format_balsheet(output)
    batch5 = pd.concat([batch5, clean_output])

batch5['ticker'].nunique() #200

#No errors.

company_balance_sheets = pd.concat([company_balance_sheets, batch5])
company_balance_sheets['ticker'].nunique()  # should now be 1000.

#API trouble. Throttled. Saving progress at n = 1000
#company_balance_sheets.to_csv('data/company_balance_sheets_raw1000mark.csv', index = False)

#company_balance_sheets = pd.read_csv('data/company_balance_sheets_raw1000mark.csv')
#company_balance_sheets.tail(5)

##### 6
batch6 = pd.DataFrame()
batch6[balsheet_cols] = balsheet_cols

for company in companies_list[1000:1200]:
    output = get_balsheet(company, AV_key)
    clean_output = format_balsheet(output)
    batch6 = pd.concat([batch6, clean_output])

batch6['ticker'].nunique() #200
#batch6.tail(5)
#companies_list[1143]
#test_for_errors('EDIT')

company_balance_sheets = pd.concat([company_balance_sheets, batch6])
company_balance_sheets['ticker'].nunique()  # should now be 1143.
#company_balance_sheets.to_csv('data/company_balance_sheets_raw_inprog.csv', index = False)


##### 7
batch7 = pd.DataFrame()
batch7[balsheet_cols] = balsheet_cols

for company in companies_list[1200:1400]:
    output = get_balsheet(company, AV_key)
    clean_output = format_balsheet(output)
    batch7 = pd.concat([batch7, clean_output])

batch7['ticker'].nunique() #200

#No errors.

company_balance_sheets = pd.concat([company_balance_sheets, batch7])
company_balance_sheets['ticker'].nunique()  # should now be 1400.
#company_balance_sheets.to_csv('data/company_balance_sheets_raw_inprog.csv', index = False)


##### 8
batch8 = pd.DataFrame()
batch8[balsheet_cols] = balsheet_cols

for company in companies_list[1400:1600]:
    output = get_balsheet(company, AV_key)
    clean_output = format_balsheet(output)
    batch8 = pd.concat([batch8, clean_output])

batch8['ticker'].nunique() #200

#No errors.

company_balance_sheets = pd.concat([company_balance_sheets, batch8])
company_balance_sheets['ticker'].nunique() # 1600
#company_balance_sheets.to_csv('data/company_balance_sheets_raw_inprog.csv', index = False)

##### 9
batch9 = pd.DataFrame()
batch9[balsheet_cols] = balsheet_cols

for company in companies_list[1600:1800]:
    output = get_balsheet(company, AV_key)
    clean_output = format_balsheet(output)
    batch9 = pd.concat([batch9, clean_output])

batch9['ticker'].nunique() #200

#No errors.

company_balance_sheets = pd.concat([company_balance_sheets, batch9])
company_balance_sheets['ticker'].nunique() # 1800
#company_balance_sheets.to_csv('data/company_balance_sheets_raw_inprog.csv', index = False)


##### 10
batch10 = pd.DataFrame()
batch10[balsheet_cols] = balsheet_cols

for company in companies_list[1800:2000]:
    output = get_balsheet(company, AV_key)
    clean_output = format_balsheet(output)
    batch10 = pd.concat([batch10, clean_output])

batch10['ticker'].nunique() #200

#No errors.

company_balance_sheets = pd.concat([company_balance_sheets, batch10])
company_balance_sheets['ticker'].nunique() # 2000
#company_balance_sheets.to_csv('data/company_balance_sheets_raw_inprog.csv', index = False)


##### 11
batch11 = pd.DataFrame()
batch11[balsheet_cols] = balsheet_cols

for company in companies_list[2000:2200]:
    output = get_balsheet(company, AV_key)
    clean_output = format_balsheet(output)
    batch11 = pd.concat([batch11, clean_output])

batch11['ticker'].nunique() #200

#No errors.

company_balance_sheets = pd.concat([company_balance_sheets, batch11])
company_balance_sheets['ticker'].nunique() # 2200
#company_balance_sheets.to_csv('data/company_balance_sheets_raw_inprog.csv', index = False)


##### 12
batch12 = pd.DataFrame()
batch12[balsheet_cols] = balsheet_cols

for company in companies_list[2200:2400]:
    output = get_balsheet(company, AV_key)
    clean_output = format_balsheet(output)
    batch12 = pd.concat([batch12, clean_output])

batch12['ticker'].nunique() #200

#No errors.

company_balance_sheets = pd.concat([company_balance_sheets, batch12])
company_balance_sheets['ticker'].nunique() # 2400
company_balance_sheets.to_csv('data/company_balance_sheets_raw_inprog.csv', index = False)


##### 13
batch13 = pd.DataFrame()
batch13[balsheet_cols] = balsheet_cols

for company in companies_list[2400:2600]:
    output = get_balsheet(company, AV_key)
    clean_output = format_balsheet(output)
    batch13 = pd.concat([batch13, clean_output])

batch13['ticker'].nunique() #200

#No errors.

company_balance_sheets = pd.concat([company_balance_sheets, batch13])
company_balance_sheets['ticker'].nunique() # 2600
#company_balance_sheets.to_csv('data/company_balance_sheets_raw_inprog.csv', index = False)

##### 14
batch14 = pd.DataFrame()
batch14[balsheet_cols] = balsheet_cols

for company in companies_list[2600:2800]:
    output = get_balsheet(company, AV_key)
    clean_output = format_balsheet(output)
    batch14 = pd.concat([batch14, clean_output])

batch14['ticker'].nunique() #200

#No errors.

company_balance_sheets = pd.concat([company_balance_sheets, batch14])
company_balance_sheets['ticker'].nunique() # 2800
#company_balance_sheets.to_csv('data/company_balance_sheets_raw_inprog.csv', index = False)


##### 15
batch15 = pd.DataFrame()
batch15[balsheet_cols] = balsheet_cols

for company in companies_list[2800:3000]:
    output = get_balsheet(company, AV_key)
    clean_output = format_balsheet(output)
    batch15 = pd.concat([batch15, clean_output])

batch15['ticker'].nunique() #200

#No errors.

company_balance_sheets = pd.concat([company_balance_sheets, batch15])
company_balance_sheets['ticker'].nunique() # 3000
#company_balance_sheets.to_csv('data/company_balance_sheets_raw_inprog.csv', index = False)

##### 16
batch16 = pd.DataFrame()
batch16[balsheet_cols] = balsheet_cols

for company in companies_list[3000:3200]:
    output = get_balsheet(company, AV_key)
    clean_output = format_balsheet(output)
    batch16 = pd.concat([batch16, clean_output])

batch16['ticker'].nunique() #200

#No errors.

company_balance_sheets = pd.concat([company_balance_sheets, batch16])
company_balance_sheets['ticker'].nunique() # 3200
#company_balance_sheets.to_csv('data/company_balance_sheets_raw_inprog.csv', index = False)

##### 17
batch17 = pd.DataFrame()
batch17[balsheet_cols] = balsheet_cols

for company in companies_list[3200:3400]:
    output = get_balsheet(company, AV_key)
    clean_output = format_balsheet(output)
    batch17 = pd.concat([batch17, clean_output])

batch17['ticker'].nunique() #200

#No errors.

company_balance_sheets = pd.concat([company_balance_sheets, batch17])
company_balance_sheets['ticker'].nunique() # 3400
company_balance_sheets.to_csv('data/company_balance_sheets_raw_inprog.csv', index = False)


##### 18
batch18 = pd.DataFrame()
batch18[balsheet_cols] = balsheet_cols

for company in companies_list[3400:3600]:
    output = get_balsheet(company, AV_key)
    clean_output = format_balsheet(output)
    batch18 = pd.concat([batch18, clean_output])

batch18['ticker'].nunique() #200

#No errors.

company_balance_sheets = pd.concat([company_balance_sheets, batch18])
company_balance_sheets['ticker'].nunique() # 3600
#company_balance_sheets.to_csv('data/company_balance_sheets_raw_inprog.csv', index = False)


##### 19
batch19 = pd.DataFrame()
batch19[balsheet_cols] = balsheet_cols

for company in companies_list[3600:3800]:
    output = get_balsheet(company, AV_key)
    clean_output = format_balsheet(output)
    batch19 = pd.concat([batch19, clean_output])

batch19['ticker'].nunique() #200

#No errors.

company_balance_sheets = pd.concat([company_balance_sheets, batch19])
company_balance_sheets['ticker'].nunique() # 3800

##### 20 finito
batch20 = pd.DataFrame()
batch20[balsheet_cols] = balsheet_cols

for company in companies_list[3800:]:
    output = get_balsheet(company, AV_key)
    clean_output = format_balsheet(output)
    batch20 = pd.concat([batch20, clean_output])

batch20['ticker'].nunique() #200

#No errors.

company_balance_sheets = pd.concat([company_balance_sheets, batch20])
company_balance_sheets['ticker'].nunique() # 3800

len(companies_list)



##### Finally:

company_balance_sheets.to_csv('data/company_balance_sheets_raw.csv', index = False)




company_balance_sheets = pd.read_csv("data/company_balance_sheets_raw.csv")

company_balance_sheets['ticker'].nunique()

company_balance_sheets