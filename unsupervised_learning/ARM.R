## ASSOCIATION RULE MINING FOR FINANCIAL DATA ##

library(tidyverse)
library(arulesViz)

# Data preprocessing for Association Rule Mining


#Objective:
# * Data needs to be in transaction format.
# * Most of the data is numeric. It needs to be discretized in the way that makes sense.
# * Include top 15 rules for support, confidence, and lift.
# * Create two network graphs to illustrate top associations.


## import data:
data <- read_csv("data_cleaning/data/firms_3883.csv")

#Column by column (starting from Sector going right, keep unique identifiers until discretization done)

#Concatenate AV and NASDAQ sector and industry classifications. For NAs in NASDAQ sector/industry put "Unspecified"
data%>%filter(is.na(Industry_NDAQ))

transaction_data <- data%>%
  mutate(Sector_NDAQ = replace_na(Sector_NDAQ, "Unspecified"))%>%
  mutate(Industry_NDAQ = replace_na(Industry_NDAQ, "Unspecified"))%>%
  unite(sectorCombo, c("Sector", "Sector_NDAQ"), sep = ",")%>%
  unite(industryCombo, c("Industry", "Industry_NDAQ"), sep = ",")

#Drop company description
transaction_data <- transaction_data%>%
  select(-Description)

#Keep exchange

#Drop Latest Quarter
transaction_data <- transaction_data%>%
  select(-LatestQuarter)

# Discretize Market Capitalization
#quantile(transaction_data$MarketCapitalization, c(seq(0,1,0.01)))
cuts <- c(0, 0.15,.33, .5, .63, .8, .87, .94, .99, .1)
bins <- quantile(transaction_data$MarketCapitalization, cuts)

transaction_data <- transaction_data%>%
  mutate(marketCapDecile = cut(MarketCapitalization, 
                                     breaks = bins, 
                                     labels = c("Bottom 15% by Market Cap[<50 million appx]",
                                                "15-33% Market Cap[50-200 million appx]",
                                                "33-50% Market Cap[200-600 million appx]",
                                                "50-63% Market Cap[600m - 1.5bn appx",
                                                "63-80% Market Cap[1.5 - 5bn appx]",
                                                "80-87% Market Cap[5bn - 10bn appx]",
                                                "87-94% Market Cap[10bn - 30bn appx]",
                                                "94-99% Market Cap[30bn - 150bn appx]",
                                                "Top 1% by Market Cap[>150bn appx]")))%>%
  relocate(marketCapDecile, .after= MarketCapitalization)%>%
  select(-MarketCapitalization)

#Discretize Book Value
quantile(transaction_data$BookValue, seq(0,1,.01))
#quantiles <- quantile(transaction_data$BookValue, seq(0,1,0.01))
#which(quantiles >= 0)[1]
cuts <- c(0,.015,.202, .5, .8 ,1)
bins <- quantile(transaction_data$BookValue,cuts)
bvlabels <- c("NEGATIVE BOOK VALUE", 
              "LOW BOOK VALUE 1-20% [0.000,1.000]",
              "MODERATE BOOK VALUE 20-50% [1.06966, 7.08000]",
              "HIGH BOOK VALUE 50-80% [7.08000,24.74000]",
              "VERY HIGH BOOK VALUE 80-100% [24.74000,4093.80000]")

transaction_data <-  transaction_data%>%
  mutate(BookValue = cut(BookValue,
                         breaks = bins, 
                         labels = bvlabels))



## Drop dividend per share. Discretize based on a) whether or not company pays dividends at all (No dividends)
## b) size of dividend yield (Small yield (0-33th percentile), Med yield (33th-67th percentile), High yield (67th percentile))


transaction_data <- transaction_data%>%
  mutate(dividends = if_else(DividendYield == 0, "NA", as.character(DividendYield)))%>%
  relocate(dividends, .after = DividendYield)%>%
  mutate(dividends = replace(dividends, dividends == "NA", NA),
         dividends = as.numeric(dividends))
  
bins <- quantile(transaction_data$dividends, seq(0,1,(1/3)), na.rm = TRUE)
divlabels <- c("LOW DIV YIELD <0.0002 - 0.0184>", "MEDIUM DIV YIELD <0.01840000 - 0.03486667>", "HIGH DIV YIELD <0.03486667 - 1.38000000")

transaction_data <- transaction_data%>%
  mutate(dividends = cut(dividends,
                         breaks = bins,
                         labels = divlabels))

#transaction_data_ip$dividends <- ifelse(is.na(transaction_data_ip$dividends), "NO DIVIDENDS", transaction_data_ip$dividends)

transaction_data <- transaction_data%>%
  mutate(dividends = ifelse(DividendYield == 0, "NO DIVIDEND", as.character(dividends)),
         dividends = as.factor(dividends))
  
#Drop div yield
transaction_data <- transaction_data%>%
  select(-DividendYield,
         -DividendPerShare)





# Discretize EPS
quantile(transaction_data$EPS, seq(0,1,0.01))

cuts <- c(0,.05,.2, .366, .59, .89, 1)

bins <- quantile(transaction_data$EPS, cuts)
epslabels <- c("HIGH EPS LOSS,0-5% [-201.8000, -3.5230]", 
               "MODERATE EPS LOSS,5-20% [-3.5230, -0.9172]",
               "SLIGHT EPS LOSS, 20% - 37% [-0.9172 , -0.003376]", 
               "ZERO OR SLIGHT POS EPS , 37-59% [0.0000, 1.0000]",
               "MODERATE POS EPS, 59-89% [1.0000 , 6.10980]", 
               "HIGHLY POS EPS, 89-100% [6.10980 , 441.99000]")

transaction_data <- transaction_data%>%
  mutate(EPS = cut(EPS,
                   breaks = bins,
                   labels = epslabels))

#Discretize Revenue Per Share
quantile(transaction_data$RevenuePerShareTTM, seq(0,1,0.01))# 0 at 12th percentile, looks fine to discretize in deciles w/ top 3%
bins <- quantile(transaction_data$RevenuePerShareTTM, c(0,.13, .26, .69,.88,1)) 

rpslabels <- c("NEGATIVE RPS, 0-13%[-14.4500, 0.0000]", 
               "LOW RPS 12-26% RPS [0.0000, 1.04600]",
               "MODERATE RPS 26-69% [1.04600, 20.59160]", 
               "HIGH RPS 69-88%[20.59160, 59.50480]",
              "VERY HIGH RPS 88-100% [59.50480, 9511.72000]")

transaction_data <- transaction_data%>%
  mutate(RevenuePerShareTTM = cut(RevenuePerShareTTM, 
                                  breaks = bins,
                                  labels = rpslabels))



# Discretize Profit Margin
quantile(transaction_data$ProfitMargin, seq(0,1,0.01))
bins <- quantile(transaction_data$ProfitMargin, c(0, 0.1, 0.26, 0.48, .7, .86, 1))
pmlabels <- c("MODERATE TO HIGH NEG PM 0-10% [-2.97400, -0.361400]", 
              "SLIGHT TO MOD NEG PM 10-26% [-0.361400, -0.003668]",
              "ZERO PM, 26-48% [0.00000]", 
              "SLIGHT TO MOD POS PM, 48-70% [0.00000, 0.13000]",
              "MODERATE TO HIGH POS PM, 70-86% [0.13000,0.255000]",
              "VERY HIGH POS PM, 86-100% [0.29880, 0.77754]")

transaction_data <- transaction_data%>%
  mutate(ProfitMargin = cut(ProfitMargin,
                            breaks = bins,
                            labels = pmlabels))

#Discretize Operating Margin
#quantile(transaction_data$OperatingMarginTTM, seq(0,1,0.01))
cuts <- c(0, .06, .20, .31, .44, .67, 0.95, 1)
bins <- quantile(transaction_data$OperatingMarginTTM, cuts)
bins
opmarglabels <- c("HIGHLY NEGATIVE OP.MARGIN, 0-6% [-1558.540000,-5.944000]",
                  "MODERATE NEGATIVE OP.MARGIN, 6-20% [-5.944000,-0.241600]",
                  "SLIGHT NEGATIVE OP.MARGIN, 20-32% [-0.241600,0.000000]",
                  "ZERO OP.MARGIN, 32-44% [0]",
                  "SLIGHT POSITIVE OP.MARGIN, 44-67% [0.002908,0.130000]",
                  "MODERATE POSITIVE OP.MARGIN, 67-95% [0.130000,0.500000]",
                  "HIGHLY POSITIVE OP.MARGIN, 95-100% [0.500000,102910.000000]")

transaction_data <- transaction_data%>%
  mutate(OperatingMarginTTM = cut(OperatingMarginTTM,
                            breaks = bins,
                            labels = opmarglabels))

#Discretize ROA
#quantile(transaction_data$ReturnOnAssetsTTM, seq(0,1,0.001))
cuts <- c(0, .13, .25, .40, .441 ,.76, 0.9, 1)
bins <- quantile(transaction_data$ReturnOnAssetsTTM, cuts)
roalabels <- c("HIGHLY NEGATIVE ROA, 0-13% [-4.993000,-0.266000]",
               "MODERATE NEGATIVE ROA, 13-25% [-0.266000,-0.104000]",
               "SLIGHT NEGATIVE ROA, 25-40% [-0.104000,0.000000]",
               "ZERO ROA 40-45% [0]",
               "SLIGHT POSITIVE ROA, 40%-76% [0.000000,0.048432",
               "MODERATE POSITIVE ROA, 76%-90% [0.048432,0.097400]",
               "HIGHLY POSITIVE ROA, 90%-100% [0.097400,11.490000]")

transaction_data <- transaction_data%>%
  mutate(ReturnOnAssetsTTM = cut(ReturnOnAssetsTTM,
                              breaks = bins,
                              labels = roalabels))



#Discretize ROE
quantile(transaction_data$ReturnOnEquityTTM, seq(0,1,0.005))
cuts <- c(0, 0.12, .33, .41, .49, .7, .92, 1 )
bins <- quantile(transaction_data$ReturnOnEquityTTM, cuts)
roelabels <- c("HIGHLY NEGATIVE ROE, 0-12% [-99999.990000,-0.968320]",
               "MODERATE NEGATIVE ROE, 12-33% [-0.968320,-0.151940]",
               "SLIGHT NEGATIVE ROE, 33-41% [-0.151940,0.000000]",
               "ZERO ROE 41-49% [0]",
               "SLIGHT POSITIVE ROE, 49%-70% [0.001918,0.128000",
               "MODERATE POSITIVE ROE, 70%-92% [0.128000,0.838760]",
               "HIGHLY POSITIVE ROE, 92%-100% [0.838760,1465.490000]")

transaction_data <- transaction_data%>%
  mutate(ReturnOnEquityTTM = cut(ReturnOnEquityTTM,
                              breaks = bins,
                              labels = roelabels))


#Drop Revenue - Market cap is a good proxy. Drop gross profit - profit margin is better.
transaction_data <-  transaction_data%>%select(-RevenueTTM, GrossProfitTTM)




#Discretize Quart YOY Earnings Growth
quantile(transaction_data$QuarterlyEarningsGrowthYOY, seq(0,1,0.001))
cuts <-  c(0, .13, .221, .296, .667, .79, .898, 1 )
bins <- quantile(transaction_data$QuarterlyEarningsGrowthYOY, cuts)

epsyoylab <- c("LARGE EARNINGS DECREASE, 0-13% [-0.99900,-0.50000]",
               "MODERATE EARNINGS DECREASE, 13-22% [-0.50000,-0.20096]",
               "SLIGHT EARNINGS DECREASE, 22-30% [-0.20096,0,00000]",
               "NO CHANGE IN EARNINGS, 30-67% [0]",
               "SLIGHT EARNINGS INCREASE, 67-79% [0.000294,0.250000]",
               "MODERATE EARNINGS INCREASE, 79-90% [0.250000,1.000000]",
               "LARGE EARNINGS INCREASE, 90-100% [1.000000,45664.500000]")

transaction_data <- transaction_data%>%
  mutate(QuarterlyEarningsGrowthYOY = cut(QuarterlyEarningsGrowthYOY,
                                       breaks = bins,
                                       labels = epsyoylab))


#Discretize Quart YOY Revenue Growth
quantile(transaction_data$QuarterlyRevenueGrowthYOY, seq(0,1,0.001))
cuts <- c(0.000, .084, .173, .241, .373, .631, .931, 1.000)
bins <- quantile(transaction_data$QuarterlyRevenueGrowthYOY, cuts)
revyoylab <- c("LARGE REVENUE DECREASE, 0-8% [-1.000000,-0.200000]",
               "MODERATE REVENUE DECREASE, 8-17% [-0.200000,-0.050000]",
               "SLIGHT REVENUE DECREASE, 17-24% [-0.050000,0.00000]",
               "NO CHANGE IN REVENUE, 24-37% [0]",
               "SLIGHT REVENUE INCREASE, 37-63% [0.002000,0.150000]",
               "MODERATE REVENUE INCREASE, 63-90% [0.150000,1.007000]",
               "LARGE REVENUE INCREASE, 90-100% [1.007000,136058.690000]")

transaction_data <- transaction_data%>%
  mutate(QuarterlyRevenueGrowthYOY = cut(QuarterlyRevenueGrowthYOY,
                                          breaks = bins,
                                          labels = revyoylab))

transaction_data <- transaction_data%>%
  select(-GrossProfitTTM)

write_csv(transaction_data, "unsupervised_learning/data/transaction_data_LABELED.csv")

# TAKE ANY  LABELS OFF
transaction_data_unlabeled <- transaction_data%>%
  select(-industryCombo,
         -Symbol,
         -Name,
         -Exchange)

write_csv(transaction_data, "unsupervised_learning/data/transaction_data_LABELED.csv")
write_csv(transaction_data_unlabeled, "unsupervised_learning/data/transaction_data_UNLABELED.csv")

########## ASSOCIATION RULE MINING #############


corporations <- read.transactions("unsupervised_learning/data/transaction_data_LABELED.csv",
                                  format = "basket",
                                  sep = ",",
                                  cols = NULL)

inspect(corporations)

corp_rules <- apriori(corporations, parameter = list(support = 0.11,
                                                     confidence = 0.6,
                                                     minlen = 3))

inspect(corp_rules)

### TOP 15 RULES BY CONFIDENCE
confrules <- sort(corp_rules, by = "confidence", decreasing = TRUE)
inspect(confrules[1:15])

### TOP 15 RULES BY SUPPORT
suprules <- sort(corp_rules, by = "support", decreasing = TRUE)
inspect(suprules[1:15])


### TOP 15 RULES BY LIFT

liftrules <- sort(corp_rules, by = "lift", decreasing = TRUE)
inspect(liftrules[1:15])


inspect(corp_rules)



#### VISUALIZATION

plot(confrules, method = "graph", engine = "interactive", limit = 15)
plot(liftrules[1:15], method = "graph", engine = "htmlwidget")


## Making sure the data is in the right folders for python
companiesdata <- read_csv("data_cleaning/data/firms_3883.csv")
write_csv(companiesdata, "unsupervised_learning/data/firms_3883.csv")
write_csv(companiesdata, "supervised_learning/data/firms_3883.csv")


