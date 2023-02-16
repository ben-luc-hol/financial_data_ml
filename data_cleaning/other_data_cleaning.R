library(tidyverse)
library(lubridate)

#In this file, features from the cash flows, earnings, 

#Extract latest quarter date from overview
overview <- read_csv("data_cleaning/data/firms_3883.csv")
latest_overview_date <- overview%>%select(Symbol, LatestQuarter)


#Inserting NAs, ensuring correct format, and checking missing values proportions in the other data sets.#

##Import the other csv files:
balance_sheets <- read_csv("data_collection/data/company_balance_sheets_raw.csv")
earnings <- read_csv("data_collection/data/company_earnings_raw.csv")
income_statements <- read_csv("data_collection/data/company_income_statements_raw.csv")
cash_flows <- read_csv("data_collection/data/company_cash_flows_raw.csv")



#Features to select & merge:
# To calculate financial ratios, select:
cols_from_earnings <- c("ticker", "fiscalDateEnding", "reportedEPS")

cols_from_income <- c("ticker", "fiscalDateEnding", "grossProfit", "totalRevenue",
                      "netIncome", "ebitda", "operatingIncome")

cols_from_balsheets <- c("ticker", "totalAssets", "fiscalDateEnding", "totalCurrentAssets", 
                         "totalCurrentLiabilities", "cashAndShortTermInvestments", 
                         "currentNetReceivables", "cashAndCashEquivalentsAtCarryingValue", 
                         "totalShareholderEquity", "totalAssets", "totalLiabilities", "totalCurrentLiabilities")

cols_from_cashflows <- c("ticker", "fiscalDateEnding", "operatingCashflow")



###### 
##Code below does the following:
## - makess sure the date variable does not interfere with mutate_all
## - mutates all instances of "None" to NA
## - mutates cols 4:39 to numeric
## - includes only USD common stock
## - filters to include only those quarterly reports that correspond to the LATEST quarter by date given in the OVERVIEWS data set, 
## in addition to the same quarter last year.
## selects variables from above


balance_sheets <- balance_sheets%>%
  filter(fiscalDateEnding %in% latest_overview_date)%>%
  mutate(fiscalDateEnding = as.character(fiscalDateEnding))%>% 
  mutate_all(funs(replace(., . == "None", NA)))%>%
  mutate(fiscalDateEnding = as_date(fiscalDateEnding))%>%
  mutate_at(vars(4:39), as.numeric)%>%
  filter(reportedCurrency == "USD")%>%
  left_join(latest_overview_date, by= c("ticker" = "Symbol"))%>%
  relocate(LatestQuarter, .after = fiscalDateEnding)%>%
  mutate( LatestQuarter = as_date(LatestQuarter))%>%
  filter(fiscalDateEnding == LatestQuarter | fiscalDateEnding == (LatestQuarter - years(1)))%>%
  select(cols_from_balsheets)


# Repeat process for earnings
earnings <- earnings%>%
  filter(fiscalDateEnding %in% latest_overview_date)%>%
  select(-c(1,2))%>%
  select(ticker, fiscalDateEnding, reportedEPS)%>%
  mutate(reportedEPS =replace(reportedEPS, reportedEPS == "None", NA))%>%
  left_join(latest_overview_date, by= c("ticker" = "Symbol"))%>%
  relocate(LatestQuarter, .after = fiscalDateEnding)%>%
  mutate(LatestQuarter = as_date(LatestQuarter),
         fiscalDateEnding = as_date(fiscalDateEnding))%>%
  filter(fiscalDateEnding == LatestQuarter | fiscalDateEnding == (LatestQuarter - years(1)))


# cash flows
cash_flows <- cash_flows%>%
  filter(fiscalDateEnding %in% latest_overview_date)%>%
  mutate(fiscalDateEnding = as.character(fiscalDateEnding))%>%
  mutate_all(funs(replace(., . == "None", NA)))%>%
  mutate(fiscalDateEnding = as_date(fiscalDateEnding))%>%
  mutate_at(vars(5:31), as.numeric)%>%
  select(-1)%>%
  left_join(latest_overview_date, by= c("ticker" = "Symbol"))%>% 
  relocate(LatestQuarter, .after = fiscalDateEnding)%>%
  filter(fiscalDateEnding == LatestQuarter | fiscalDateEnding == (LatestQuarter - years(1)))%>%
  select(all_of(cols_from_cashflows))


#income statements
income_statements <- income_statements%>%
  filter(fiscalDateEnding %in% latest_overview_date)%>%
  filter(reportedCurrency == "USD")%>%
  select(all_of(cols_from_income))%>%
  mutate(grossProfit = replace(grossProfit, grossProfit == "None", NA),
         totalRevenue = replace(totalRevenue, totalRevenue == "None", NA),
         netIncome = replace(netIncome, netIncome == "None", NA),
         ebitda = replace(ebitda, ebitda == "None", NA),
         operatingIncome = replace(operatingIncome, operatingIncome == "None", NA))%>%
  mutate(fiscalDateEnding = as_date(fiscalDateEnding))%>%
  mutate_at(vars(3:7), as.numeric)%>%
  left_join(latest_overview_date, by= c("ticker" = "Symbol"))%>%
  relocate(LatestQuarter, .after = fiscalDateEnding)%>%
  mutate(LatestQuarter = as_date(LatestQuarter))%>%
  filter(fiscalDateEnding == LatestQuarter | fiscalDateEnding == (LatestQuarter - years(1)))%>%
  select(-LatestQuarter)
  

### Merge
joins <- c("ticker", "fiscalDateEnding")

ratios <- earnings%>%
  left_join(cash_flows, by = joins)%>%
  left_join(income_statements, by=joins)%>%
  left_join(balance_sheets, by=joins)


# RATIOS TO CALCULATE
# grossProfitMargin

ratios <- ratios%>%
          #financial ratios
  mutate( currentRatio = grossProfit / totalRevenue,
          netProfitMargin = netIncome/ totalRevenue, 
          returnOnAssets = netIncome / totalAssets,
          returnOnEquity = netIncome / totalShareholderEquity,
          ebitdaMargin = ebitda / totalRevenue,
          operatingMargin = operatingIncome / totalRevenue,
          currentRatio = totalCurrentAssets / totalCurrentLiabilities,
          quickRatio = cashAndShortTermInvestments / totalLiabilities,
          cashRatio = cashAndCashEquivalentsAtCarryingValue / totalCurrentLiabilities,
          debtEquity = totalLiabilities / totalShareholderEquity,
          opCashFlowMargin = operatingCashflow / totalRevenue)%>%
  group_by(ticker)%>%
  slice_max(fiscalDateEnding)%>%
  select(ticker, fiscalDateEnding, totalRevenue, currentRatio, reportedEPS,
         netProfitMargin, returnOnAssets, returnOnEquity, ebitdaMargin,
         operatingMargin, currentRatio, quickRatio, cashRatio, debtEquity,
         opCashFlowMargin)%>%
  ungroup()
  
  
write_csv(ratios, "data_cleaning/data/financial_ratios_raw.csv")
  

## other
wins <- read_csv("data_cleaning/data/data_winsorized.csv")
redu <- read_csv("data_cleaning/data/companies_list_reduced.csv")

write_csv(wins, "supervised_learning/data/data_winsorized.csv")
write_csv(wins, "supervised_learning/data/reduced_data.csv")

write_csv(wins, "unsupervised_learning/data/data_winsorized.csv")
write_csv(wins, "unsupervised_learning/data/reduced_data.csv")


