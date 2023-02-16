# DECISION TREES IN R
library(tidyverse)
library(rpart)
library(rattle)
library(caret)
data <- read_csv("supervised_learning/data/firms_3883.csv")

#Decision tree for MIXED data, without normalization
#Outcome: Dividend payment (Y/N) by dividend yield

set.seed(9999)

data_dt <- data%>%
  select(Sector, Exchange, MarketCapitalization, BookValue, EPS, RevenuePerShareTTM,
         ProfitMargin, OperatingMarginTTM, ReturnOnAssetsTTM, ReturnOnEquityTTM, 
         RevenueTTM, QuarterlyEarningsGrowthYOY, QuarterlyRevenueGrowthYOY, DividendYield)%>%
  mutate(Dividend = DividendYield>0)%>%
  select(-DividendYield)

train <- data_dt%>%sample_frac(0.75, replace = FALSE)
test <- data_dt%>%anti_join(train)


data_dt


#Data appears mostly balanced
summary(train)
summary(test)

#Store label and remove from test set
test_label <- test$Dividend
test <- test%>%select(-Dividend)


#Train the Decision Tree
dt1 <- rpart(Dividend ~ ., data = train, method = "class", cp =0.003)
summary(dt1)

#Visualize the tree
fancyRpartPlot(dt1)

#Predict Labels
dt1_pred = predict(dt1, test, type = "class")
test_label <- as.factor(test_label)

#Confusion matrix
confusionMatrix(dt1_pred, test_label)




#Decision tree for discretized data
#Import discretized data from ARM section?
#Outcome variable: DIVIDEND


#Discretized: 
# Select attributes
data_dt2 <- data%>%
  select(Sector, Sector_NDAQ, Exchange, MarketCapitalization, BookValue, EPS, RevenuePerShareTTM,
         ProfitMargin, OperatingMarginTTM, ReturnOnAssetsTTM, ReturnOnEquityTTM, 
         QuarterlyEarningsGrowthYOY, QuarterlyRevenueGrowthYOY, DividendYield)



#Discretize variables:

#Dividend, binary (True if div paid, else false)
data_dt2 <- data_dt2%>%
  mutate(Dividend = DividendYield>0)%>%
  select(-DividendYield)

#EPS, pos or negative
# Negative - Zero - Positive : Profit Margin, Operating Margin, Earnings Growth, Revenue Growth, ROA, ROE

data_dt2 <- data_dt2%>%
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


#Split dataset
train2 <- data_dt2%>%sample_frac(0.75, replace = FALSE)
test2 <- data_dt2%>%anti_join(train2)


test2_label <- test2$Dividend
test2 <- test2%>%select(-Dividend)


#Run 2nd DT in R with discrete data

dt2 <- rpart(Dividend ~ ., data = train2, method = "class", cp =0.003)
summary(dt1)

fancyRpartPlot(dt2)

dt2_pred = predict(dt2, test2, type = "class")
test2_label <- as.factor(test2_label)

confusionMatrix(dt2_pred, test2_label)

