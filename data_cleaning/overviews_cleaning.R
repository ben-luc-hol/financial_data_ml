### Data cleaning & Prep:

library(tidyverse)
library(lubridate)
## Company overviews

## (Set wd at root directory ("findata_ml"))
#setwd("~/Documents/msds/boulder/fa22/findata_ml")

overview <- read_csv("data_collection/data/company_overview_raw.csv")


overview <- overview%>%select(-c(1,2),
                              -Information,
                              -`Error Message`)

### Missing values

#Replace strings for None / NONE with NA
overview_ip <- overview%>%
  filter(!is.na(Symbol))%>%
  mutate(Description = replace(Description, Description == "None", NA),
         Address = replace(Address, Address == "NONE", NA),
         FiscalYearEnd = replace(FiscalYearEnd, FiscalYearEnd == "None", NA),
         MarketCapitalization = replace(MarketCapitalization, MarketCapitalization == "None", NA),
         EBITDA = replace(EBITDA, EBITDA == "None", NA),
         PERatio = replace(PERatio, PERatio == "None", NA),
         PEGRatio = replace(PEGRatio, PEGRatio == "None", NA),
         BookValue = replace(BookValue, BookValue == "None", NA),
         DividendPerShare = replace(DividendPerShare, DividendPerShare == "None",NA),
         DividendYield = replace(DividendYield, DividendYield == "None",NA),
         EPS = replace(EPS, EPS == "None",NA),
         AnalystTargetPrice = replace(AnalystTargetPrice, AnalystTargetPrice == "None",NA),
         TrailingPE = replace(TrailingPE, TrailingPE == "-",NA),
         ForwardPE = replace(ForwardPE, ForwardPE == "-",NA),
         PriceToSalesRatioTTM = replace(PriceToSalesRatioTTM, PriceToSalesRatioTTM == "-",NA),
         PriceToBookRatio = replace(PriceToBookRatio, PriceToBookRatio == "-",NA),
         EVToRevenue = replace(EVToRevenue, EVToRevenue == "-",NA),
         EVToEBITDA = replace(EVToEBITDA, EVToEBITDA == "-",NA),
         Beta = replace(Beta, Beta == "None",NA),
         DividendDate = replace(DividendDate, DividendDate == "None",NA),
         ExDividendDate = replace(ExDividendDate, ExDividendDate == "None",NA))




#Some additional columns can be dropped since it's doubtful they will be used.
overview_ip <- overview_ip%>%
  select(-c(AssetType, #data set contains only common stock
            Currency, # data set contains only USD denominated assets
            Country)) #data set contains only U.S. companies

  
#Ensure numeric variables are in the right format. (Some character variables need to be numeric)
#Get structure of the dataset
str(overview_ip)

overview_ip <- overview_ip%>%
  mutate(LatestQuarter = as_date(LatestQuarter),
         MarketCapitalization = as.numeric(MarketCapitalization),
         EBITDA = as.numeric(EBITDA),
         PERatio = as.numeric(PERatio),
         PEGRatio = as.numeric(PEGRatio),
         BookValue = as.numeric(BookValue),
         DividendPerShare = as.numeric(DividendPerShare),
         DividendYield = as.numeric(DividendYield),
         EPS = as.numeric(EPS),
         AnalystTargetPrice = as.numeric(AnalystTargetPrice),
         TrailingPE = as.numeric(TrailingPE),
         ForwardPE = as.numeric(ForwardPE),
         PriceToSalesRatioTTM = as.numeric(PriceToSalesRatioTTM),
         PriceToBookRatio = as.numeric(PriceToBookRatio),
         EVToRevenue = as.numeric(EVToRevenue),
         EVToEBITDA = as.numeric(EVToEBITDA),
         Beta = as.numeric(Beta),
         DividendDate = as_date(DividendDate),
         ExDividendDate = as_date(ExDividendDate))
         

# Save .csv before cleaning further:
#write_csv(overview_ip, "data_collection/data/company_overview_in_progress.csv")

#NYSE stock screener - compare sectors, industries, and descriptions.
#Adding these give additional information about the individual sector and industry of a firm.
list_of_companies <- overview_ip$Symbol

nasdaq <- read_csv("data_collection/data/nasdaq_screener_all.csv")
nasdaq <- nasdaq%>%
  filter(Symbol %in% list_of_companies)%>%
  select(Symbol, `Market Cap`, Sector, Industry)

colnames(nasdaq)
colnames(nasdaq) <- c("Symbol", "Mkt_Cap_NDAQ", "Sector_NDAQ", "Industry_NDAQ")
  
#Shuffle some columns around
overview_ip <- left_join(overview_ip, nasdaq, by= "Symbol")
overview_ip <-  overview_ip%>%
  relocate(Sector_NDAQ, .after = Sector)%>%
  relocate(Industry_NDAQ, .after = Industry)%>%
  relocate(Mkt_Cap_NDAQ, .after= MarketCapitalization)

#Select variables
overview_ip <- overview_ip%>%
  select(Symbol,
         Name,
         Sector,
         Sector_NDAQ,
         Industry,
         Industry_NDAQ,
         Description,
         Exchange,
         LatestQuarter,
         MarketCapitalization,
         Mkt_Cap_NDAQ,
         EBITDA,
         BookValue,
         DividendYield,
         DividendPerShare,
         EPS,
         RevenuePerShareTTM,
         ProfitMargin,
         OperatingMarginTTM,
         ReturnOnAssetsTTM,
         ReturnOnEquityTTM,
         RevenueTTM,
         GrossProfitTTM,
         DilutedEPSTTM,
         QuarterlyEarningsGrowthYOY,
         QuarterlyRevenueGrowthYOY)




#Missing values, overview
missing_val <-  overview_ip%>%summarize(across(everything(),~sum(is.na(.x))))
dim(overview_ip)
missing_val <- missing_val%>%mutate_all(funs(./3967))%>%gather(key = "Variable", value = "NA%")

ggplot(missing_val, aes(x = Variable, y = `NA%`))+
  geom_col(fill = "darkblue")+ theme_bw() + theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  scale_y_continuous(labels = scales::percent)




# EBITDA (get from other datasets)

#ebitda <- income_statements_ip%>%select(ticker, fiscalDateEnding, ebitda)
#overview_ip <- overview_ip%>%
#  left_join(ebitda, by = c("Symbol" = "ticker"))%>%
#  relocate(fiscalDateEnding, .after = LatestQuarter)%>%
#  relocate(ebitda, .after = EBITDA)




#Exclude variables from other dataset(s). Replace missing Market Cap values with NASDAQ data
overview_ip <- overview_ip%>%
  select(-ebitda, -fiscalDateEnding, -reportedEPS)%>%
  mutate(MarketCapitalization = if_else(is.na(MarketCapitalization), Mkt_Cap_NDAQ, MarketCapitalization))

#Drop NASDAQ market cap column
overview_ip <- overview_ip%>%
  select(-Mkt_Cap_NDAQ)


# Given a lot of missing values for EBITDA with no straightforward remedy, I will reluctantly drop it from the dataset.
missing_ebitda <- overview_ip%>%filter(is.na(EBITDA))

overview_ip <- overview_ip%>%
  select(-EBITDA)


# Get rid of all missing values (numeric data)
summary(overview_ip)

overview_ip <- overview_ip%>%filter(!is.na(LatestQuarter))



overview_ip <-  overview_ip%>%filter(!is.na(MarketCapitalization))

overview_ip <- overview_ip%>%filter(!is.na(BookValue))


overview_ip <- overview_ip%>%
  mutate(EPS = ifelse(is.na(EPS), DilutedEPSTTM, EPS))%>%
  select(-DilutedEPSTTM)


summary(overview_ip)


write_csv(overview_ip, "data_cleaning/data/firms_3883.csv")


