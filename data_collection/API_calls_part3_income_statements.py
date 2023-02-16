# 3 ------------------------ Company Income Statements ------------------------------------------------



import pandas as pd
import requests
from creds import apikeys

AV_key = apikeys.avkey

companies_list = pd.read_csv('data/companies_list_v1.csv')
companies_list
companies_list = list(companies_list.iloc[:,0])
len(companies_list)

## Function to call API and format JSON outputs for income statements

def get_income_statement(symbol,apikey):
    url = f"https://www.alphavantage.co/query?function=INCOME_STATEMENT&symbol={symbol}&apikey={apikey}"
    r = requests.get(url)
    return r.json()

def format_income(json_file):
    income = pd.json_normalize(json_file, max_level=1)
    income_q = income.drop(columns='annualReports', axis = 1)
    income_q = income_q['quarterlyReports'].to_json()
    income_q = pd.read_json(income_q, orient = 'records')#.transpose()
    income_q = income_q[0].apply(pd.Series)
    income_q['ticker'] = income.iloc[0,0]
    income_q_cols = income_q.columns.tolist()
    income_q_cols = income_q_cols[-1:] + income_q_cols[:-1]
    income_q = income_q[income_q_cols]
    return income_q

test_i_json = get_income_statement('ABNB', AV_key)

print("test income statement JSON: \n",test_i_json)
test_i = format_income(test_i_json)
test_i


#Successful.
income_cols = list(test_i.columns)
#Main df:
company_income_statements_raw = pd.DataFrame()
company_income_statements_raw[income_cols] = income_cols

#Batching - 500 at a time now

#Some companies do not have full income statements available.
#These are identified and checked with the following function when the for loop crashes:
def test_for_errors(company):
    key = AV_key
    output = get_income_statement(company,key)
    try:
        clean_output = format_income(output)
        return clean_output
    except:
        return "error"


test_error = test_for_errors('obviousError')
test_error

#And removed:
companies_list.remove('ACAC')

batch1 = pd.DataFrame()
batch1[income_cols] = income_cols

for company in companies_list[0:276]:
    output = get_income_statement(company, AV_key)
    clean_output = format_income(output)
    batch1 = pd.concat([batch1, clean_output])

batch1['ticker'].nunique() #API stalled at 276
batch1.tail(1)
companies_list[275]
#ARBG.  --- API jammed at 276th company symbol. Concat to main DF and do next batch:
companies_list[276] # -- next one up is ARC.

company_income_statements_raw = pd.concat([company_income_statements_raw, batch1])
company_income_statements_raw['ticker'].nunique()  # should now be 276.

##### Next
batch2 = pd.DataFrame()
batch2[income_cols] = income_cols

for company in companies_list[276:550]:
    output = get_income_statement(company, AV_key)
    clean_output = format_income(output)
    batch2 = pd.concat([batch2, clean_output])

#check unique tickers:
batch2['ticker'].nunique() # 274

#no issues.
company_income_statements_raw = pd.concat([company_income_statements_raw, batch2])
company_income_statements_raw['ticker'].nunique()  # 550

##### Next
batch3 = pd.DataFrame()
batch3[income_cols] = income_cols

for company in companies_list[550:850]:
    output = get_income_statement(company, AV_key)
    clean_output = format_income(output)
    batch3 = pd.concat([batch3, clean_output])

#check unique tickers:
batch3['ticker'].nunique() # 300
company_income_statements_raw = pd.concat([company_income_statements_raw, batch3])
company_income_statements_raw['ticker'].nunique()  # 850


##### Next
batch4 = pd.DataFrame()
batch4[income_cols] = income_cols

for company in companies_list[850:1150]:
    output = get_income_statement(company, AV_key)
    clean_output = format_income(output)
    batch4 = pd.concat([batch4, clean_output])

batch4['ticker'].nunique() # 300


company_income_statements_raw = pd.concat([company_income_statements_raw, batch4])
company_income_statements_raw['ticker'].nunique()  # 1150



##### Next
batch5 = pd.DataFrame()
batch5[income_cols] = income_cols
companies_list.remove('FLFV')


for company in companies_list[1150:1650]:
    output = get_income_statement(company, AV_key)
    clean_output = format_income(output)
    batch5 = pd.concat([batch5, clean_output])

batch5['ticker'].nunique() # 500


company_income_statements_raw = pd.concat([company_income_statements_raw, batch5])
company_income_statements_raw['ticker'].nunique()  # 1650


##### Next
batch6 = pd.DataFrame()
batch6[income_cols] = income_cols
#companies_list.remove('')

for company in companies_list[1650:(1650+493)]:
    output = get_income_statement(company, AV_key)
    clean_output = format_income(output)
    batch6 = pd.concat([batch6, clean_output])

batch6['ticker'].nunique() # 500
#API stalled at 493
#batch6.tail(1)             #Last company LRMR
companies_list[2142]  #No 2142 is LRMR
companies_list[2143]  #NO 2143 is LRB


company_income_statements_raw = pd.concat([company_income_statements_raw, batch6])
company_income_statements_raw['ticker'].nunique()  # 2143


##### Next
batch6 = pd.DataFrame()
batch6[income_cols] = income_cols
#companies_list.remove('')

for company in companies_list[1650:(1650+493)]:
    output = get_income_statement(company, AV_key)
    clean_output = format_income(output)
    batch6 = pd.concat([batch6, clean_output])

batch6['ticker'].nunique() # 500
#API stalled at 493
#batch6.tail(1)             #Last company LRMR
companies_list[2142]  #No 2142 is LRMR
companies_list[2143]  #NO 2143 is LRB


company_income_statements_raw = pd.concat([company_income_statements_raw, batch6])
company_income_statements_raw['ticker'].nunique()  # 2143
#company_income_statements_raw.tail(1)


##### Next
companies_list.remove('MCAC')
companies_list.remove('MOBV')
batch7 = pd.DataFrame()
batch7[income_cols] = income_cols

for company in companies_list[2143:2650]: #506
    output = get_income_statement(company, AV_key)
    clean_output = format_income(output)
    batch7 = pd.concat([batch7, clean_output])

batch7['ticker'].nunique() # 507

#test_for_errors('MCAC') # Returned error. Removed above and re-run.
#test_for_errors('MOBV') # Returned error. Removed above and re-run.


company_income_statements_raw = pd.concat([company_income_statements_raw, batch7])
company_income_statements_raw['ticker'].nunique()  # 2650



##### Next
companies_list.remove('PTWO')

batch8 = pd.DataFrame()
batch8[income_cols] = income_cols

for company in companies_list[2650:3150]: #500
    output = get_income_statement(company, AV_key)
    clean_output = format_income(output)
    batch8 = pd.concat([batch8, clean_output])

batch8['ticker'].nunique() # 500

#test_for_errors('PTWO') # API stalled @ 199, threw error for PTWO console + test. Removed above and re-run.

company_income_statements_raw = pd.concat([company_income_statements_raw, batch8])
company_income_statements_raw['ticker'].nunique()  # 3150


##### Next
batch9 = pd.DataFrame()
batch9[income_cols] = income_cols

for company in companies_list[3150:3650]: #500
    output = get_income_statement(company, AV_key)
    clean_output = format_income(output)
    batch9 = pd.concat([batch9, clean_output])

batch9['ticker'].nunique() # 500

company_income_statements_raw = pd.concat([company_income_statements_raw, batch9])
company_income_statements_raw['ticker'].nunique()  # 3650


##### Final
batch10 = pd.DataFrame()
batch10[income_cols] = income_cols
for company in companies_list[3650:]:
    output = get_income_statement(company, AV_key)
    clean_output = format_income(output)
    batch10 = pd.concat([batch10, clean_output])

batch10['ticker'].nunique() # target 296

company_income_statements_raw = pd.concat([company_income_statements_raw, batch10])
company_income_statements_raw['ticker'].nunique()  # 3946


company_income_statements_raw.to_csv('data/company_income_statements_raw.csv', index = False)
companies_list_after_income = pd.DataFrame(companies_list)
companies_list_after_income.to_csv('data/companies_list_v2.csv', index = False)
