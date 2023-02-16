library(tidyverse)



# Exploratory data analysis


data <- read_csv("data_cleaning/data/firms_3883.csv")


#Log of revenue vs. log of market capitalization - 
ggplot(data, aes(log(MarketCapitalization), log(RevenueTTM), color = EPS>=0, size = abs(EPS))) +
  geom_point(alpha = 0.6)+ 
  theme_bw() + 
  ggtitle("Market Cap vs. Revenue") +
   xlab("Natural log of Market Capitalization") +
   ylab("Natural log of Revenue")

ggplot(data, aes(log(MarketCapitalization), log(RevenueTTM), color = EPS>=0, size = abs(EPS))) +
  geom_point(alpha = 0.6)+ 
  theme_bw() + 
  ggtitle("Market Cap vs. Revenue by AV Sector classification") +
  xlab("Natural log of Market Capitalization") +
  ylab("Natural log of Revenue") +
  facet_wrap(~Sector, nrow = 4)

data%>%filter(!is.na(Sector_NDAQ))%>%
  ggplot(aes(log(MarketCapitalization), log(RevenueTTM), color = EPS>=0)) +
  geom_point(alpha = 0.6)+ 
  theme_bw() + 
  ggtitle("Market Cap vs. Revenue by NASDAQ Sector classification") +
  xlab("Natural log of Market Capitalization") +
  ylab("Natural log of Revenue") +
  facet_wrap(~Sector_NDAQ, nrow = 4)


#data_eda <- data%>%
#  unite(sectorCombo, c("Sector", "Sector_NDAQ"), sep = "/")%>%
#  unite(industryCombo, c("Industry", "Industry_NDAQ"), sep = "/")
#
#data_eda%>%group_by(sectorCombo)%>%count()

quantile(data$QuarterlyEarningsGrowthYOY)
quantile(data$QuarterlyEarningsGrowthYOY, 0.95)
quantile(data$QuarterlyRevenueGrowthYOY, 0.95)

data%>%filter(QuarterlyEarningsGrowthYOY < 2.8788 & QuarterlyEarningsGrowthYOY != 0,
              QuarterlyRevenueGrowthYOY < 1.3516 & QuarterlyRevenueGrowthYOY)%>%
  ggplot(aes(QuarterlyEarningsGrowthYOY, QuarterlyRevenueGrowthYOY, color = Sector)) +
  geom_point(alpha = 0.3)+ 
  theme_bw() + 
  ggtitle("Quarterly Year-over-Year growth") +
  xlab("Revenue growth") +
  ylab("Earnings (EPS) growth")


quantile(data$BookValue, 0.01)
quantile(data$BookValue, 0.99)

# Book value
ggplot(data, aes(x = BookValue)) +
  geom_histogram(bins = 280, fill = "darkblue") +
  xlim(-80, 200)+
  theme_bw() +
  ggtitle("Book Value") +
  xlab("") +
  ylab("No of companies")

# DPS
data <-  data%>%
  mutate(paysDividends = DividendPerShare > 0.0)%>%
  relocate(paysDividends, .after = DividendPerShare)

data%>%summarize(prop = sum(paysDividends) / n())%>%
  pull(prop)

data%>%filter(paysDividends == "TRUE")%>%
ggplot(aes(x = DividendPerShare)) +
  geom_histogram(fill = "darkblue", bins = 100) +
  theme_bw() +
  ggtitle("Dividend per share (DPS). 36.1% of companies paid dividends") +
  xlab("") +
  ylab("No of companies")

#Dividend yield
data%>%filter(paysDividends == "TRUE")%>%
  ggplot(aes(x = DividendYield)) +
  geom_histogram(fill = "darkblue", bins = 100) +
  theme_bw() +
  ggtitle("Dividend yield for 36.1% of companies that paid dividends") +
  xlab("") +
  ylab("No of companies")+
  xlim(0,0.3)

  

quantile(data$DividendYield, 0.01)
quantile(data$DividendYield, 0.99)

ggplot(data, aes(x = BookValue)) +
  geom_histogram(bins = 280, fill = "darkblue") +
  xlim(-80, 200)+
  theme_bw() +
  ggtitle("Book Value") +
  xlab("") +
  ylab("No of companies")



#EPS
summary(data$Rev)
quantile(data$EPS, 0.01)
quantile(data$EPS, 0.99)

data%>%filter(between(EPS, -9.8396, 29.3432))%>%
  ggplot(aes(x = EPS)) +
  geom_histogram(bins = 160, fill = "darkblue") +
  theme_bw() +
  ggtitle("Earnings Per Share") +
  xlab("") +
  ylab("No of companies")


#Revenue per share
summary(data$RevenuePerShareTTM)
quantile(data$RevenuePerShareTTM, 0.01)
quantile(data$RevenuePerShareTTM, 0.99)

data%>%filter(between(RevenuePerShareTTM, 0, 368.4824))%>%
  ggplot(aes(x = RevenuePerShareTTM)) +
  geom_histogram(bins = 150, fill = "darkblue") +
  theme_bw() +
  ggtitle("Revenue Per Share, Trailing Twelve Months") +
  xlab("") +
  ylab("No of companies")


#Profit margin
colnames(data)
summary(data$ProfitMargin)
quantile(data$ProfitMargin, 0.01)
quantile(data$ProfitMargin, 0.99)

data%>%filter(between(ProfitMargin, -2, 2))%>%
  ggplot(aes(x = ProfitMargin)) +
  geom_histogram(bins = 200, fill = "darkblue") +
  theme_bw() +
  ggtitle("Profit Margin") +
  xlab("") +
  ylab("No of companies")


#Operating margin
colnames(data)
summary(data$OperatingMarginTTM)
q<- quantile(data$OperatingMarginTTM, 0.05)
qq <- quantile(data$OperatingMarginTTM, 0.98)

data%>%filter(between(OperatingMarginTTM, q, qq))%>%
  ggplot(aes(x = OperatingMarginTTM)) +
  geom_histogram(bins = 200, fill = "darkblue") +
  theme_bw() +
  ggtitle("Operating Margin, Trailing Twelve Months") +
  xlab("") +
  ylab("No of companies")

#ROA
colnames(data)
summary(data$ReturnOnAssetsTTM)

q<- quantile(data$ReturnOnAssetsTTM, 0.001)
qq <- quantile(data$ReturnOnAssetsTTM, 0.999)

data%>%
  ggplot(aes(x = ReturnOnAssetsTTM)) +
  geom_histogram(bins = 200, fill = "darkblue") +
  theme_bw() +
  ggtitle("Return on assets (TTM)") +
  xlab("") +
  ylab("No of companies")+
  xlim(q,qq)



#ROE
colnames(data)
summary(data$ReturnOnEquityTTM)

q<- quantile(data$ReturnOnEquityTTM, 0.025)
qq <- quantile(data$ReturnOnEquityTTM, 0.975)

data%>%
  ggplot(aes(x = ReturnOnEquityTTM)) +
  geom_histogram(bins = 200, fill = "darkblue") +
  theme_bw() +
  ggtitle("Return on equity (TTM)") +
  xlab("") +
  ylab("No of companies")+
  xlim(q,qq)m



