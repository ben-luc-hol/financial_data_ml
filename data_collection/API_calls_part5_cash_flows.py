# 5 ------------------------ Company Cash Flows ------------------------------------------------

import pandas as pd
import requests
from creds import apikeys

AV_key = apikeys.avkey

companies_list = pd.read_csv('data/companies_list_v2.csv')
companies_list = list(companies_list.iloc[:,0])
companies_list
#len(companies_list)


#Function to get JSONs
def get_cash_flow(symbol,apikey):
    url = f"https://www.alphavantage.co/query?function=CASH_FLOW&symbol={symbol}&apikey={apikey}"
    r = requests.get(url)
    return r.json()

#Function to format JSONs
def format_cashflow(json_file):
    cashflow = pd.json_normalize(json_file, max_level=1)
    cashflow_q = cashflow['quarterlyReports'].apply(pd.Series).transpose()
    cashflow_q = cashflow_q[0].apply(pd.Series)
    cashflow_q['ticker'] = cashflow.iloc[0,0]
    cashflow_q_cols = cashflow_q.columns.tolist()
    cashflow_q_cols = cashflow_q_cols[-1:] + cashflow_q_cols[:-1]
    cashflow_q = cashflow_q[cashflow_q_cols]
    return cashflow_q


#Function to test for error if API doesn't cooperate:
def test_for_errors(company):
    key = AV_key
    output = format_cashflow(company,key)
    try:
        clean_output = format_cashflow(output)
        return clean_output
    except:
        return "error"


testj = get_cash_flow(companies_list[0], AV_key)
test = format_cashflow(testj)
test.head(5)


cashflow_cols = list(test.columns)
#balsheet_cols



### Main df:
company_cash_flows = pd.DataFrame()
company_cash_flows[cashflow_cols] = cashflow_cols
company_cash_flows


#BATCHES

def run_batch(list_of_companies):
    key = AV_key
    batch = pd.DataFrame()
    batch[cashflow_cols] = cashflow_cols
    for company in list_of_companies:
        output = get_cash_flow(company, key)
        data = format_cashflow(output)
        batch = pd.concat([batch, data])
    return batch


#1
batch1 = run_batch(companies_list[0:200])
#batch1['ticker'].nunique()
company_cash_flows = pd.concat([company_cash_flows, batch1])
#company_cash_flows['ticker'].nunique()

#2
batch2 = run_batch(companies_list[200:600])
#batch2['ticker'].nunique()
company_cash_flows = pd.concat([company_cash_flows, batch2])
#company_cash_flows['ticker'].nunique() #600

#3
batch3 = run_batch(companies_list[600:1000])
#batch3['ticker'].nunique()
company_cash_flows = pd.concat([company_cash_flows, batch3])
#company_cash_flows['ticker'].nunique() #1000

#4
batch4 = run_batch(companies_list[1000:1400])
#batch4['ticker'].nunique()
company_cash_flows = pd.concat([company_cash_flows, batch4])
#company_cash_flows['ticker'].nunique() #1400

#company_cash_flows.to_csv('data/company_cash_flows_inprog1400.csv', index = False)


#5
batch5 = run_batch(companies_list[1400:1800])
#batch5['ticker'].nunique()
company_cash_flows = pd.concat([company_cash_flows, batch5])
#company_cash_flows['ticker'].nunique() #1800


#6
batch6 = run_batch(companies_list[1800:2200])
#batch6['ticker'].nunique()
company_cash_flows = pd.concat([company_cash_flows, batch6])
#company_cash_flows['ticker'].nunique() #2200

#company_cash_flows.to_csv('data/company_cash_flows_inprog2200.csv', index = False)

#7
batch7 = run_batch(companies_list[2200:2600])
#batch7['ticker'].nunique()
company_cash_flows = pd.concat([company_cash_flows, batch7])
#company_cash_flows['ticker'].nunique()
#company_cash_flows.to_csv('data/company_cash_flows_inprog2600.csv', index = False)

#8
batch8 = run_batch(companies_list[2600:2800])
#batch8['ticker'].nunique()
company_cash_flows = pd.concat([company_cash_flows, batch8])
#company_cash_flows['ticker'].nunique()

#9
batch9 = run_batch(companies_list[2800:3200])
#batch9['ticker'].nunique()
company_cash_flows = pd.concat([company_cash_flows, batch9])
#company_cash_flows['ticker'].nunique()

#10
batch10 = run_batch(companies_list[3200:3400])
#batch10['ticker'].nunique()
company_cash_flows = pd.concat([company_cash_flows, batch10])
#company_cash_flows['ticker'].nunique()

#11
batch11 = run_batch(companies_list[3400:3600])
#batch11['ticker'].nunique()
company_cash_flows = pd.concat([company_cash_flows, batch11])
#company_cash_flows['ticker'].nunique()


#12
batch12 = run_batch(companies_list[3600:3800])
#batch12['ticker'].nunique()
company_cash_flows = pd.concat([company_cash_flows, batch12])
#company_cash_flows['ticker'].nunique()

#13
batch13 = run_batch(companies_list[3800:])
#batch13['ticker'].nunique()
company_cash_flows = pd.concat([company_cash_flows, batch13])
#company_cash_flows['ticker'].nunique()



##### Finally:

company_cash_flows.to_csv('data/company_cash_flows_raw.csv')

company_cash_flows = pd.read_csv("data/company_cash_flows_raw.csv")
company_cash_flows['ticker'].nunique()

company_cash_flows


company_cash_flows.columns




#%%
