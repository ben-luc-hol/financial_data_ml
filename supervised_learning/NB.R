#NAÏVE BAYES

library(dplyr)
library(e1071)

data <- read_csv("supervised_learning/data/firms_3883.csv")



### Prepare DF for 1st model
set.seed(9999)
data_nb1 <- data%>%
  select(Sector, Exchange, MarketCapitalization, BookValue, EPS, RevenuePerShareTTM,
         ProfitMargin, OperatingMarginTTM, ReturnOnAssetsTTM, ReturnOnEquityTTM, 
         RevenueTTM, QuarterlyEarningsGrowthYOY, QuarterlyRevenueGrowthYOY, DividendYield)%>%
  mutate(Dividend = DividendYield>0)%>%
  select(-DividendYield)

train1 <- data_nb1%>%sample_frac(0.75, replace = FALSE)
test1 <- data_nb1%>%anti_join(train1)

# - Labels separate
train1_labels <- as.factor(train1$Dividend)
test1_labels <-  as.factor(test1$Dividend)


train1 <- train1%>%select(-Dividend)
test1 <- test1%>%select(-Dividend)


#Prepare data for 2nd model
data_nb2 <- data%>%
  select(Sector, Sector_NDAQ, Exchange, MarketCapitalization, BookValue, EPS, RevenuePerShareTTM,
         ProfitMargin, OperatingMarginTTM, ReturnOnAssetsTTM, ReturnOnEquityTTM, 
         QuarterlyEarningsGrowthYOY, QuarterlyRevenueGrowthYOY, DividendYield)


data_nb2 <- data_nb2%>%
  mutate(Dividend = DividendYield>0)%>%
  select(-DividendYield)


data_nb2 <- data_nb2%>%
  mutate(EPS = EPS>0)%>% 
  mutate(ProfitMargin = if_else(ProfitMargin < 0, 
                                "Negative", 
                                if_else(ProfitMargin == 0, 
                                        "Zero",
                                        "Positive")),
         OperatingMarginTTM = if_else(OperatingMarginTTM < 0, 
                                      "Negative", 
                                      if_else(OperatingMarginTTM == 0, 
                                              "Zero",
                                              "Positive")),
         QuarterlyEarningsGrowthYOY = if_else(QuarterlyEarningsGrowthYOY < 0, 
                                              "Negative", 
                                              if_else(QuarterlyEarningsGrowthYOY == 0, 
                                                      "Zero",
                                                      "Positive")),
         QuarterlyRevenueGrowthYOY = if_else(QuarterlyRevenueGrowthYOY < 0, 
                                             "Negative", 
                                             if_else(QuarterlyRevenueGrowthYOY == 0, 
                                                     "Zero",
                                                     "Positive")),
         ReturnOnAssetsTTM = if_else(ReturnOnAssetsTTM < 0, 
                                     "Negative", 
                                     if_else(ReturnOnAssetsTTM == 0, 
                                             "Zero",
                                             "Positive")),
         ReturnOnEquityTTM = if_else(ReturnOnEquityTTM < 0, 
                                     "Negative", 
                                     if_else(ReturnOnEquityTTM == 0, 
                                             "Zero",
                                             "Positive")))


train2 <- data_nb2%>%sample_frac(0.75, replace = FALSE)
test2 <- data_nb2%>%anti_join(train2)

#Labels separate
train2_labels <- train2$Dividend
train2 <- train2%>%select(-Dividend)

test2_label <- test2$Dividend
test2 <- test2%>%select(-Dividend)


### Run NB

NB1 <- naiveBayes(train1, train1_labels, laplace = 1)
NB1_pred <- predict(NB1, test1)

caret::confusionMatrix(NB1_pred, test1_labels)

NB2 <- naiveBayes(train2, train2_labels, laplace = 1)
NB2_pred <- predict(NB2, test2)
test2_label <- as.factor(test2_label)

caret::confusionMatrix(NB2_pred, test2_label)


