
######################################################################################################################################################################
#####                                                          DATA CLEANING   PART 1                                                                            #####
######################################################################################################################################################################
library(tidyverse)
library(lubridate)


# PART 1: Initial data preprocessing and joining target variables:



####### To clean this, the 'None' values will be converted to NA's.
# 0 was tried as a substitute but that did not make a ton of sense.
#I will remove observations (potentially entire companies) that have too many missing values.
#There are 3,946 companies in the dataset currently, so shrinking this number is fine.
#Data quality is most important.

#Loading the list of companies:
companies_list <- read_csv("data/companies_list_v2.csv")
companies_list <- as.list(companies_list$`0`)




#-------------------------------------------------------------------------------------------------------------------------------------
 # EARNINGS DATASET           -
#-------------------------------------------------------------------------------------------------------------------------------------
earnings  <- read_csv("data/company_earnings_raw.csv")  
earnings

earnings <- earnings%>%select(-c(1,index)) #forgot to specify no index in python

summary(earnings)                          #summarize variables

# Trimming around the edges:

earnings_inprog <- earnings%>% 
              mutate(fiscalDateEnding = as_date(fiscalDateEnding))%>%        # quarter_end_date should be date-time format
                      rename(quarter_end_date = fiscalDateEnding,                    # renaming variables
                            symbol = ticker,                                  
                             eps = reportedEPS,
                              eps_forecast = estimatedEPS,
                               surprise_pct = surprisePercentage)%>%
                           filter(symbol %in% companies_list,                      # Filter to only contain the 3946 unique companies that yielded results in every API call
                              quarter_end_date >= as_date("2019-01-01"))%>%   # Hard cutoff date for dates to be included set to 2019-01-01. 
                             select(-reportedDate)                                 # dropping reportedDate

earnings_inprog


# Converting data types & "Nones" to NA
earnings_inprog <-  earnings_inprog%>% 
                    mutate(eps = replace(eps, eps == "None", NA),
                               eps_forecast = replace(eps_forecast, eps_forecast == "None", NA),
                                  surprise = replace(surprise, surprise == "None", NA),
                                     surprise_pct = replace(surprise_pct, surprise_pct == "None", NA))%>%
                                               #numerics only
                             mutate(eps = as.numeric(eps),
                                 eps_forecast = as.numeric(eps_forecast),
                                     surprise = as.numeric(surprise),
                                         surprise_pct = as.numeric(surprise_pct)/100)

#making sure it worked
summary(earnings_inprog)
#earnings_inprog%>%filter(eps <= -5000)
#will deal with outliers and other issues after full raw dataset is finished.
colnames(info)



#-------------------------------------------------------------------------------------------------------------------------------------
# INFO DATASET
#-------------------------------------------------------------------------------------------------------------------------------------

info      <- read_csv("data/company_overview_raw.csv") 
summary(info)


info_inprog <- info%>%
  select(-c(1,index))%>%
  filter(Symbol %in% companies_list)%>%
  select(Symbol, Name, Exchange, Sector, Industry, 
         Description, Address, MarketCapitalization) %>%
  rename(symbol=Symbol, name=Name, exchange=Exchange, sector=Sector,
         industry=Industry, description=Description,address = Address,
         mkt_cap = MarketCapitalization)%>%
  mutate(state = str_replace(address, "UNITED STATES", "US"))%>%
  mutate(state = str_sub(state, start = -7),
         state = str_sub(state, end = 3),
         mkt_cap = replace(mkt_cap, mkt_cap == "None", NA),
         mkt_cap = as.numeric(mkt_cap))
                             
                      
companies <- inner_join(info_inprog, earnings_inprog, by = "symbol")

colnames(companies)
summary(companies)

companies <-  companies%>%select(symbol, name,exchange,quarter_end_date,sector,industry,description,address,state,
                                 mkt_cap, eps, eps_forecast, surprise, surprise_pct)



#-------------------------------------------------------------------------------------------------------------------------------------
# INCOME DATASET           -
#-------------------------------------------------------------------------------------------------------------------------------------
income    <- read_csv("data/company_income_statements_raw.csv") 

summary(income)
colnames(income)

cols_from_income = c("ticker", "fiscalDateEnding", "grossProfit", "totalRevenue", "operatingIncome", "researchAndDevelopment",   "operatingExpenses", "interestExpense", "ebitda", "netIncome")
cols_from_income_renamed = c("symbol", "quarter_end_date", "gross_profit", "total_revenue", "op_income", "rd", "op_expenses", "int_expense", "ebitda", "net_income")

income_inprog <- income%>%
  select(cols_from_income)%>%
  rename_at(vars(cols_from_income), ~ cols_from_income_renamed)%>%
  mutate(quarter_end_date = as_date(quarter_end_date),
  gross_profit = replace(gross_profit, gross_profit == "None", NA),
  gross_profit = as.numeric(gross_profit),
  total_revenue = replace(total_revenue, total_revenue == "None", NA),
  total_revenue = as.numeric(total_revenue),
  op_income =replace(op_income, op_income == "None", NA),
  op_income = as.numeric(op_income),
  rd = replace(rd, rd == "None", NA),
  rd =  as.numeric(rd),
  op_expenses = replace(op_expenses, op_expenses == "None",NA),
  op_expenses =  as.numeric(op_expenses),
  int_expense = replace(int_expense, int_expense == "None", NA),
  int_expense = as.numeric(int_expense),
  ebitda = replace(ebitda, ebitda == "None", NA),
  ebitda = as.numeric(ebitda),
  net_income = replace(net_income, net_income == "None", NA),
  net_income = as.numeric(net_income))

income_inprog


companies <- inner_join(companies, income_inprog, by = c("symbol", "quarter_end_date"))


#-------------------------------------------------------------------------------------------------------------------------------------
# BALANCE SHEET DATASET           -
#-------------------------------------------------------------------------------------------------------------------------------------

balsheet <- read_csv("data/company_balance_sheets_raw.csv") 

colnames(balsheet)
balsheet_cols <-  c("ticker", "fiscalDateEnding", "totalAssets", "totalCurrentAssets", "totalLiabilities", "totalCurrentLiabilities", "shortLongTermDebtTotal", "totalShareholderEquity", "commonStockSharesOutstanding")
balsheet_cols_renamed = c("symbol", "quarter_end_date", "total_assets", "current_assets", "total_liabilities", "current_liabilities", "total_debt", "shareholder_equity", "shares_outstanding")

summary(balsheet)

balsheet_inprog <-  balsheet%>%
  select(balsheet_cols)%>%
  rename_at(vars(balsheet_cols), ~ balsheet_cols_renamed)%>%
  mutate(quarter_end_date = as_date(quarter_end_date),
         total_assets = replace(total_assets, total_assets == "None", NA),
         total_assets =  as.numeric(total_assets),
         current_assets = replace(current_assets, current_assets == "None", NA),
         current_assets = as.numeric(current_assets),
         total_liabilities = replace(total_liabilities, total_liabilities == "None", NA),
         total_liabilities = as.numeric(total_liabilities),
         current_liabilities = replace(current_liabilities, current_liabilities == "None", NA),
         current_liabilities = as.numeric(current_liabilities),
         total_debt = replace(total_debt, total_debt == "None", NA),
         total_debt = as.numeric(total_debt),
         shareholder_equity = replace(shareholder_equity, shareholder_equity == "None", NA),
         shareholder_equity = as.numeric(shareholder_equity),
         shares_outstanding = replace(shares_outstanding, shares_outstanding == "None", NA),
         shares_outstanding = as.numeric(shares_outstanding))

balsheet_inprog

companies <- inner_join(companies, balsheet_inprog, by = c("symbol", "quarter_end_date"))


##-------------------------------------------------------------------------------------------------------------------------------------
## CASH FLOW DATASET    # Leave out for now
##-------------------------------------------------------------------------------------------------------------------------------------
#cashflow <- read_csv("data/company_cash_flows_raw.csv")
#cashflow <- cashflow%>%select(-1)
#colnames(cashflow)
#
#cashflow_cols <- c("ticker", "fiscalDateEnding", "operatingCashflow", "capitalExpenditures", "profitLoss", "dividendPayout")
#cashflow_cols_renamed <- c("symbol", "quarter_end_date", "operating_cash_flow", "capital_exp", "profit_loss", "div_payout")
#
#cashflow_inprog <- cashflow%>%
#  select(cashflow_cols)%>%
#  rename_at(vars(cashflow_cols), ~cashflow_cols_renamed)%>%
#  mutate(quarter_end_date = as_date(quarter_end_date),
#         operating_cash_flow = replace(operating_cash_flow, operating_cash_flow == "None", NA),
#         operating_cash_flow = as.numeric(operating_cash_flow),
#         capital_exp = replace(capital_exp, capital_exp == "None", NA),
#         capital_exp = as.numeric(capital_exp),
#         profit_loss = replace(profit_loss, profit_loss == "None", NA),
#         profit_loss = as.numeric(profit_loss),
#         div_payout = replace(div_payout, div_payout == "None", NA),
#         div_payout = as.numeric(div_payout))
#
#cashflow_inprog
#
#
#inner_join(companies, cashflow_inprog, by = c("symbol", "quarter_end_date"))



summary(companies)
colnames(companies)
#Some last observations need to be converted to numeric that were missed initially: 
#total_assets
#current_assets
#total_liabilities
#current_liabilities
#total_debt
#shareholder_equity
#shares_outstanding


#companies <- companies%>%
#  mutate(total_assets = as.numeric(replace(total_assets, total_assets == "None", NA)),
#         current_assets = as.numeric(replace(current_assets, current_assets == "None", NA)),
#         total_liabilities = as.numeric(replace(total_liabilities, total_liabilities == "None", NA)),
#         current_liabilities = as.numeric(replace(current_liabilities, current_liabilities == "None", NA)),
#         total_debt = as.numeric(replace(total_debt, total_debt == "None", NA)),
#         shareholder_equity = as.numeric(replace(shareholder_equity, shareholder_equity == "None", NA)),
#         shares_outstanding = as.numeric(replace(shares_outstanding, shares_outstanding == "None", NA)))




########         FORMAT  OF RAW, FULL DATASET:   #########

#--------------------------------MAIN--------------------------------------------------------------------------
#     Variable               Type     Description                                            Source dataset        
#---------------------------------------------------------------------------------------------------------------
#     symbol                  chr      Stock symbol for company                                  info
#     name                    chr      Name of company                                           info         
#     exchange                chr      Exchange company is listed on                             info
#     quarter_end_date        date     Date of fiscal quarter end for quarterly report           all
#     sector                  chr      Main sector of company                                    info
#     industry                chr      Industry subcategory                                      info
#     description             chr      Text description of company                               info                         
#     address                 geo      Company HQ address                                        info             
#     state                   chr      HQ State                                                  info
#     mkt_cap                 num      Total market capitalization (most recent quarter)  info   info
#     eps                     num      Earnings per share                                        earnings 
#     eps_forecast            num      Estimated earnings per share                              earnings            
#     surprise                num      EPS minus EPS estimate                                    earnings 
#     surprise_pct            num      Percent (magnitude) of surprise                           earnings
#     gross_profit            num      Gross profit                                              income
#     total_revenue           num      Total revenue                                             income
#     op_income               num      Operating income                                          income
#     rd                      num      R&D investments                                           income
#     op_expenses             num      Operating expenses                                        income
#     int_expense             num      Interest expenses                                         income
#     ebitda                  num      Earnings before interest, taxes, depreciation and amortiz.income
#     net_income              num      Net income / net sales / net profit                       income
#     total_assets            num      Total assets                                              balsheet
#     current_assets          num      Current assets                                            balsheet
#     total_liabilities       num      Total liabilities                                         balsheet
#     current_liabilities     num      Current liabilities                                       balsheet
#     total_debt              num      Total short and long term debt                            balsheet 
#     shareholder_equity      num      Equity held by shareholders, total                        balsheet
#     shares_outstanding      num     Common stock shares outstanding                            balsheet 
#---------------------------------------------------------------------------------------------------------------

# Arrange if needed
#companies <- companies%>%arrange(desc(quarter_end_date), symbol)



write_csv(companies, "data/companies_full.csv")










  