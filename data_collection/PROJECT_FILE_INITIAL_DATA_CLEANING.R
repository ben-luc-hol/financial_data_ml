
######################################################################################################################################################################
#####                                                          DATA CLEANING                                                                                     #####
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



#Importing libraries

library(dplyr)
library(ggplot2)
library(lubridate)


companies <- read_csv("data/companies_full.csv")


########         CURRENT FORMAT  OF RAW, FULL DATASET:   #########

#--------------------------------TIME SERIES MAIN-------------------------------------------------------------------
#     Variable               Type     Description                                                              
#-------------------------------------------------------------------------------------------------------------------
#     symbol                  chr      Stock symbol for company                                  
#     name                    chr      Name of company                                           
#     exchange                chr      Exchange company is listed on                             
#     quarter_end_date        date     Date of fiscal quarter end for quarterly report           
#     sector                  chr      Main sector of company                                    
#     industry                chr      Industry subcategory                                      
#     description             chr      Text description of company                                             
#     address                 geo      Company HQ address                                          
#     state                   chr      HQ State                                                  
#     mkt_cap                 num      Total market capitalization (most recent quarter)  info   
#     eps                     num      Earnings per share                                        
#     eps_forecast            num      Estimated earnings per share                                   
#     surprise                num      EPS minus EPS estimate                                    
#     surprise_pct            num      Percent (magnitude) of surprise                           
#     gross_profit            num      Gross profit                                              
#     total_revenue           num      Total revenue                                             
#     op_income               num      Operating income                                          
#     rd                      num      R&D investments                                           
#     op_expenses             num      Operating expenses                                        
#     int_expense             num      Interest expenses                                         
#     ebitda                  num      Earnings before interest, taxes, depreciation and amortiz.
#     net_income              num      Net income / net sales / net profit                       
#     total_assets            num      Total assets                                              
#     current_assets          num      Current assets                                            
#     total_liabilities       num      Total liabilities                                         
#     current_liabilities     num      Current liabilities                                       
#     total_debt              num      Total short and long term debt                            
#     shareholder_equity      num      Equity held by shareholders, total                        
#     shares_outstanding      num     Common stock shares outstanding    

#-------------------------------------------------------------------------------------------------------------------

#In this file the data will be cleaned, missing values will be eliminated or otherwise dealt with, and 



#-----------------------------------  Missing Values --------------------------------------------------


#First - deal with missing values and NA's. There are enough companies in the dataset where any one of them that is missing
#a lot of values (this could be perfectly normal - e.g. if the company doesn't fit the profile for reporting a given metric)
#can be discarded.

#Get rid of *all* of the quarterly reports (rows) for a company if it misses a single value in any of the key features.
#Do it with an anti-join.

#missing_vals<- companies%>%summarize_all(funs(sum(is.na(.))))%>%transpose()
#missing_vals <- as.data.frame(missing_vals)

#ggplot(missing_vals, aes(x = `0`))+
#  geom_bar()

# Filter companies by symbol (group_by) where there are any missing values in
#revenue, gross profit, op income or expenses, ebitda, etc.

companies_w_missing_data <- companies%>%
  group_by(symbol)%>%
  filter((any(is.na(total_revenue))|
            any(is.na(gross_profit))|
            any(is.na(op_income))|
            any(is.na(op_expenses))|
            any(is.na(ebitda))|
            any(is.na(net_income))|
            any(is.na(current_assets))|
            any(is.na(total_liabilities))|
            any(is.na(total_debt))|
            any(is.na(shareholder_equity))|
            any(is.na(current_liabilities))|
            any(is.na(eps))|
            any(is.na(shares_outstanding))))%>%
  ungroup()

companies_inprog <- anti_join(companies, companies_w_missing_data, by = "symbol")

#store the file.
write_csv(companies_w_missing_data,"data/companies_with_missing_data.csv")

companies_inprog%>%distinct(symbol)%>%count()
#Down to 2,649 companies with full data.

companies_inprog%>%summarize_all(funs(sum(is.na(.))))

#Interest expense:
#Replace NAs and zeroes with 1, leave values > 1 intact:
companies_inprog <- companies_inprog%>%
  mutate(int_expense = if_else(int_expense > 1, int_expense, 1, missing = 1))


#Replace R&D with 0
companies_inprog <- companies_inprog%>%
  mutate(rd = replace_na(rd, 0))


#nas <-  companies_inprog%>%summarize_all(funs(sum(is.na(.))))



#-----------------------------------  EDA, normalization --------------------------------------------------
colnames(companies_inprog)



#Creating a lag variable for the next quarter's EPS
#companies_inprog <- companies_inprog%>%
#  group_by(symbol)%>%
#  mutate(eps_lead = lag(eps))%>%
#  relocate(eps_lead, .before = eps_forecast)%>%ungroup()


# -   -   -   -   -   -   - Ratios calculated from original variables  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -    
#     rps                     num      Revenue per share (total_revenue/shares_outstanding)     ***                          total_revenue/shares_outstanding
#     profit_margin           num      Profit margin                                            ***                           net_income / total_revenue
#     current_ratio           num      Current ratio - current accounts to settle current liabilities                         current_assets/current_liabilities
#     debt_ratio              num      Leverage - proportion of company's debt to total assets                                total_debt/total_assets
#     debt_equity             num      Debt-to-equity ratio                                                                   total_debt/shareholder_equity
#     interest_cov            num      Interest coverage ratio                                                                op_income / int_expense
#     gross_margin            num      Gross margin ratio - profit vs net sales                                               gross_profit / net_income
#     operating_margin        num      Operating margin - income generated from net sales                                      op_income / net_income
#     roa                     num      Return on assets                                                                        net_income / total_assets
#     roe                     num      Return on equity                                                                        net_income / shareholder_equity
# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -    -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   - 

companies_inprog <- companies_inprog%>%
  mutate(rps = (total_revenue/shares_outstanding)*100,
         profit_margin = (net_income / total_revenue)*100,
         current_ratio = (current_assets/current_liabilities)*100,
         debt_ratio = (total_debt/total_assets)*100,
         debt_equity = (total_debt/shareholder_equity)*100,
         interest_cov = (op_income / int_expense)*100,
         gross_margin = (gross_profit/net_income)*100,
         operating_margin = (op_income / net_income)*100,
         roa = (net_income / total_assets)*100,
         roe = (net_income / shareholder_equity)*100)



# -   -   -   -   -   -   - Normalization of existing variables to account for company size  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   
#     total_revenue           num      Total revenue           The variables will be recalculated as ratios to total revenue  ( variable / total_revenue)
# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -    -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   - 
#     gross_profit            num      Gross profit  in percent                                               
#     op_income               num      Operating income  in percent                                           
#     rd                      num      R&D investments   in percent                                 
#     op_expenses             num      Operating expenses in percent                               
#     int_expense             num      Interest expenses  in percent                            
#     ebitda                  num      Earnings before interest, taxes, depreciation and amortization  in percent 
#     net_income              num      Net income / net sales / net profit  in percent 
#     total_assets            num      Total assets   in percent           
#     current_assets          num      Current assets  in percent                                 
#     total_liabilities       num      Total liabilities in percent                                
#     current_liabilities     num      Current liabilities in percent                              
#     total_debt              num      Total short and long term debt in percent                            
# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -    -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   - 

companies_inprog <- companies_inprog%>%
  mutate(gross_profit = (gross_profit / total_revenue)*100,
         op_income = (op_income / total_revenue)*100,
         rd = (rd / total_revenue)*100,
         op_expenses = (op_expenses / total_revenue)*100,
         int_expense = (int_expense / total_revenue)*100,
         ebitda = (ebitda / total_revenue)*100,
         net_income_perc = (net_income / total_revenue)*100,
         total_assets = (total_assets / total_revenue)*100,
         current_assets = (current_assets / total_revenue)*100,
         total_liabilities = (total_liabilities / total_revenue)*100,
         current_liabilities = (current_liabilities / total_revenue)*100,
         total_debt = (total_debt / total_revenue)*100)




### Lead variable to hem in economic indicators data for a given quarter (companies report earnings at different times)
companies_inprog <-  companies_inprog%>%
  group_by(symbol)%>%
  mutate(prev_quarter_end_date = lead(quarter_end_date),
         prev_quarter_end_date = as_date(prev_quarter_end_date))%>%
  ungroup()%>%
  relocate(prev_quarter_end_date, .after = quarter_end_date)

write_csv(companies_inprog, "")

#companies_inprog%>%
  #EPS per share
  # Not needed. The EPS measure is adequate.
  #test <- companies_inprog%>%
  #  mutate(eps_manual = (eps / 100,
  #         shares_outstanding_millions = shares_outstanding/1000)
  
  
  #quantile(test$eps_per_share, seq(0,1,0.05))
  
  # -----------------------------------  Economic indicators --------------------------------------------------

### GDP (QUARTERLY)

# Use FRED data instead: https://fred.stlouisfed.org/series/GDPC1# - saved as gdp_fred.csv
#target measure: Quarterly real GDP change:

#gdp <-  read_csv("data/gdp_fred.csv")
#colnames(gdp) <- c("date", "real_gdp")
#
#gdp <- gdp%>% 
#  arrange(desc(as_date(date)))%>%
#  mutate(prev_year_gdp = lead(real_gdp,4),
#         gdp_change_yoy = ((real_gdp/prev_year_gdp)-1)*100,
#         date = date + months(3) - days(1))%>%
#  filter(date > as_date("2018-01-01"))%>%
#  select(date, gdp_change_yoy)%>%
#  complete(date = (seq(from = min(date), to = max(date), by= "day")))

# fill in latest posted GDP figure by day, and join to main df for companies so each company's latest posted GDP figure is current for when their fiscal quarter ended.

#current_date = min(gdp$date)+days(1)
#max_date = max(gdp$date)

#while (current_date <= max_date) {
#  gdp <- gdp%>%
#    mutate(gdp_change_yoy = ifelse(date == current_date & is.na(gdp_change_yoy), lag(gdp_change_yoy), gdp_change_yoy))
#  current_date <- current_date + days(1)
#}
#
#companies_inprog <- companies_inprog%>%
#  left_join(gdp, by = c("quarter_end_date" = "date"))
#

#write_csv(companies_inprog, "data/MASTER_PROCESSED_companies_all_features.csv"))

companies_inprog <- read_csv("data/MASTER_PROCESSED_companies_all_features.csv")




#Fed funds rate:
rates <- read_csv("data/weekly_economic_indicators.csv")
rates <-  rates%>%slice(1:280) #fix dates

rates <- rates%>%select(date, federal_funds_rate)%>%
  tidyr::complete(date = (seq(from = min(date), to = max(date), by= "day")))


current_date = min(rates$date)+days(1)
max_date = max(rates$date)

while (current_date <= max_date) {
  rates <- rates%>%
    mutate(federal_funds_rate = ifelse(date == current_date & is.na(federal_funds_rate), lag(federal_funds_rate), federal_funds_rate))
  current_date <- current_date + days(1)
}


rates_lag <- rates%>%rename(fed_funds_prev = federal_funds_rate)

companies_inprog <- companies_inprog%>%
  left_join(rates, by = c("quarter_end_date" = "date"))%>%
  left_join(rates_lag, by = c("prev_quarter_end_date" = "date"))

companies_inprog <- companies_inprog%>%
  mutate(fed_rate_change = federal_funds_rate - fed_funds_prev)%>%
  select(-fed_funds_prev)

#colnames(rates)
##Moving averages for rates:

# Scrap yield curve.
#rate1 <- rates%>% arrange(date)%>% select(-federal_funds_rate)%>%
#  mutate(treasury_10y_yield = rollmean(treasury_10y_yield,10, align = "right"),
#         treasury_2y_yield  = rollmean(treasury_2y_yield,10), align = "right")


#not including ^^^^^






#monthly_indicators <- read_csv("data/monthly_economic_indicators.csv")
# Drop for now.
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#



### FINAL BEFORE SELECTING FEATURES
companies_inprog%>%distinct(symbol)%>%count()

write_csv(companies_inprog, "data/MASTER_PROCESSED_companies_all_features.csv")









#### Background Vis

rates <- read_csv("data/weekly_economic_indicators.csv")
rates <- rates%>%
  mutate(date = as_date(date))%>%
  filter(date > as_date("2005-01-01"))%>%
  slice(1:935)

## Interest rates ggplot
ggplot(rates, aes(date,(federal_funds_rate/100))) + theme_bw()+
  geom_line(color = "#910f0a", 
            size = 1.1) +
  scale_x_date(date_breaks= "years", 
               date_labels = "%Y", 
               limits = as.Date(c('2005-01-01', '2022-12-02')), 
               expand = (c(0.03,0.03))) +
  labs(x = "Year", 
       y = "Federal Funds Rate",
       title = "U.S. Federal Reserve Interest Rates, 2005 - 2022")+
  scale_y_continuous(breaks = seq(0,0.055,.005),
                     minor_breaks = seq(0,0.055,0.0025),
                     labels = scales::percent,
                     expand = c(0,.0005)) +
  theme(axis.text.x = element_text(angle = 310, size = 10, hjust = -0.1))





full_companies <- read_csv("data/MASTER_PROCESSED_companies_all_features.csv")

full_companies%>%distinct(symbol)%>%count()
full_companies%>%distinct(sector)

model_data <- full_companies%>%
  select(symbol, name, exchange, quarter_end_date, sector, mkt_cap, industry, 
         state, eps, total_revenue, profit_margin, ebitda, operating_margin, 
         current_ratio, debt_ratio, debt_equity, interest_cov, gross_margin,
         roa, roe, federal_funds_rate, fed_rate_change)%>%
  group_by(symbol)%>%
  slice(1:2)%>%
  ungroup()%>%
  mutate(previous_eps = lead(eps),
         eps_change = previous_eps - eps,
         eps_binary = if_else(eps >= 0, 1, 0),
         eps_change_binary = if_else(eps_change >= 0, 1, 0))%>%
  relocate(eps_change_binary, .after = eps)%>%
  relocate(eps_binary, .after = eps)%>%
  relocate(eps_change, .after = eps)%>%
  relocate(previous_eps, .after = eps)

### Rounding parameters to 5 digits:
colnames(model_data)
model_data <- model_data%>%
  mutate(profit_margin = round(profit_margin,5),
         ebitda = round(ebitda, 5),
         operating_margin = round(operating_margin,5),
         current_ratio = round(current_ratio,3),
         debt_ratio = round(debt_ratio, 3),
         debt_equity = round(debt_equity, 3),
         interest_cov = round(interest_cov, 1),
         gross_margin = round(gross_margin, 3),
         roa = round(roa, 3),
         roe = round(roe, 3))



# Current Quarter Dataset:

model_data_q3 <- model_data%>%
  group_by(symbol)%>%
  slice(1)%>%
  filter(quarter_end_date >= as_date("2022-07-31"))
  
write_csv(model_data_q3, "data/final_data_q3_22.csv")
  
  
  


