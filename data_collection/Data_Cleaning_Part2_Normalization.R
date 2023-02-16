######################################################################################################################################################################
#####                                                          DATA CLEANING   PART 2   NORMALIZATION & EDA                                                      #####
######################################################################################################################################################################
library(tidyverse)
library(zoo)

#Import full dataset
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

missing_vals<- companies%>%summarize_all(funs(sum(is.na(.))))%>%transpose()
missing_vals <- as.data.frame(missing_vals)

ggplot(missing_vals, aes(x = `0`))+
  geom_bar()

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


nas <-  companies_inprog%>%summarize_all(funs(sum(is.na(.))))



#-----------------------------------  EDA, normalization --------------------------------------------------
colnames(companies_inprog)



#Creating a lag variable for the next quarter's EPS
companies_inprog <- companies_inprog%>%
  group_by(symbol)%>%
  mutate(eps_lead = lag(eps))%>%
  relocate(eps_lead, .before = eps_forecast)%>%ungroup()


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


companies_inprog%>%
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

gdp <-  read_csv("data/gdp_fred.csv")
colnames(gdp) <- c("date", "real_gdp")

gdp <- gdp%>% 
  arrange(desc(as_date(date)))%>%
  mutate(prev_year_gdp = lead(real_gdp,4),
         gdp_change_yoy = ((real_gdp/prev_year_gdp)-1)*100,
         date = date + months(3) - days(1))%>%
  filter(date > as_date("2018-01-01"))%>%
  select(date, gdp_change_yoy)%>%
  complete(date = (seq(from = min(date), to = max(date), by= "day")))

# fill in latest posted GDP figure by day, and join to main df for companies so each company's latest posted GDP figure is current for when their fiscal quarter ended.

current_date = min(gdp$date)+days(1)
max_date = max(gdp$date)

while (current_date <= max_date) {
  gdp <- gdp%>%
    mutate(gdp_change_yoy = ifelse(date == current_date & is.na(gdp_change_yoy), lag(gdp_change_yoy), gdp_change_yoy))
    current_date <- current_date + days(1)
}

companies_inprog <- companies_inprog%>%
  left_join(gdp, by = c("quarter_end_date" = "date"))


#Fed funds rate:
rates <- read_csv("data/weekly_economic_indicators.csv")
rates <-  rates%>%slice(1:280) #fix dates

rates <- rates%>%select(date, federal_funds_rate)%>%
  complete(date = (seq(from = min(date), to = max(date), by= "day")))
  
  
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








