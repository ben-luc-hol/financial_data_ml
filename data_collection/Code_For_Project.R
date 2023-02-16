library(tidyverse)
library(scales)

####### 



#### EDA and features
data <- read_csv("data/final_data_q3_22.csv")
data <- data%>%select(-mkt_cap)
summary(data)

# exchanges
ggplot(data, aes(x = sector, fill = exchange))+
  geom_bar() + theme_bw() + coord_flip()+ ylab("Number of companies")


#mkt_cap

#ggplot(data, aes(x = mkt_cap)) +
#  geom_histogram(bins = 100)









#There are outliers, but the leverage remains to be seen.

data%>%filter(eps < -100)
data%>%filter(eps > 100)

ggplot(data, aes(x = eps, fill = (eps >= 0.00000 ))) +
  theme_bw()+
  geom_histogram(bins = 100)+
  xlim(-10, 10)


############### Company Size
ggplot(data, aes(x = total_revenue)) +
  theme_bw()+
  geom_histogram(bins = 100)
  #xlim(-10, 10)


data%>%filter(total_revenue > 5000000000)
data%>%filter(between(total_revenue,1000000000, 4999999999))
data%>%filter(between(total_revenue,100000000, 1000000000))
data%>%filter(between(total_revenue,10000000, 100000000))
data%>%filter(between(total_revenue,1000000, 10000000))
data%>%filter(total_revenue < 1000000)


#discretizing company sizes based on revenue:
# 5bn +  = 5
# 1-5bn = 4
# 100 mill - 1 bill = 3
# 10 mill - 100 mill = 2
# 1 mill - 10 mill = 1
# less than 1 mill = 0
sizes = c(0, 1000000, 10000000, 100000000, 1000000000, 5000000000, Inf)
sizelab = c(0, 1, 2, 3, 4, 5)
data <- data%>%
  mutate(size = cut(total_revenue, breaks = sizes, labels = sizelab))%>%
  relocate(size, .after = eps_change_binary)



data <- data%>%filter(!is.na(size))

ggplot(data, aes(x = size)) +
  theme_bw()+
  geom_bar()


################ Profit margin

data%>%filter(profit_margin < -50)%>%arrange(profit_margin)%>%select(symbol, name, profit_margin, size)
data%>%filter(profit_margin > 50)%>%arrange(desc(profit_margin))%>%select(symbol, name, profit_margin, size)

ggplot(data, aes(x = profit_margin)) +
  theme_bw()+
  geom_histogram()+
  xlim(-20, 20)

################ Operating margin

data%>%filter(operating_margin < -50)%>%arrange(operating_margin)%>%select(symbol, name, operating_margin, size)
data%>%filter(operating_margin > 50)%>%arrange(desc(operating_margin))%>%select(symbol, name, operating_margin, size)
ggplot(data, aes(x = operating_margin)) +
  theme_bw()+
  geom_histogram()+
  xlim(-20, 20)

################ Current ratio X
summary(data)
data%>%filter(current_ratio < 0)%>%arrange(current_ratio)%>%select(symbol, name, current_ratio, size)
data%>%filter(current_ratio > 400)%>%arrange(desc(current_ratio))%>%select(symbol, name, current_ratio, size)
ggplot(data, aes(x = current_ratio)) +
  theme_bw()+
  geom_histogram()
  #xlim(-20, 20)

################ Debt ratio  V
ggplot(data, aes(x = debt_ratio)) +
  theme_bw()+
  geom_histogram()

data%>%filter(debt_ratio < 0)%>%arrange(debt_ratio)%>%select(symbol, name, debt_ratio, size)
data%>%filter(debt_ratio > 300)%>%arrange(desc(debt_ratio))%>%select(symbol, name, debt_ratio, size)



# Debt-equity (drop)
summary(data)


ggplot(data, aes(x = debt_equity)) +
  theme_bw()+
  geom_histogram()

data%>%filter(debt_equity < 0)%>%arrange(debt_equity)%>%select(symbol, name, debt_equity, size)
data%>%filter(debt_equity > 300)%>%arrange(desc(debt_equity))%>%select(symbol, name, debt_equity, size)



## EBITDA
summary(data)
ggplot(data, aes(x = ebitda)) +
  theme_bw()+
  geom_histogram()

data%>%filter(ebitda < -500)%>%arrange(ebitda)%>%select(symbol, name, ebitda, size)
data%>%filter(ebitda > 100)%>%arrange(desc(ebitda))%>%select(symbol, name, ebitda, size)


## gross marg
summary(data)
ggplot(data, aes(x = gross_margin)) +
  theme_bw()+
  geom_histogram()

data%>%filter(gross_margin < -100)%>%arrange(gross_margin)%>%select(symbol, name, gross_margin, size)
data%>%filter(gross_margin > 500)%>%arrange(desc(gross_margin))%>%select(symbol, name, gross_margin, size)



#roa
summary(data)
ggplot(data, aes(x = roa)) +
  theme_bw()+
  geom_histogram()



#roe
summary(data)
ggplot(data, aes(x = roe)) +
  theme_bw()+
  geom_histogram()

data%>%filter(roe < -100)%>%arrange(roe)%>%select(symbol, name, roe, size)
data%>%filter(roe > 500)%>%arrange(desc(roe))%>%select(symbol, name, roe, size)
# drop current ratio, debt-equity,  and filter out size = 0

#overviews <- read_csv("data/company_overview_raw.csv")
#overviews%>%select(ProfitMargin)


### # drop current ratio, debt-equity,  and filter out size = 0.


data<- data%>%filter(total_revenue >= 1000000)#%>%
 # select(-c(current_ratio, debt_equity))





#eliminate outliers with non-finite values
data <- data%>%filter(operating_margin < Inf)%>%
  select(-interest_cov)


#summary(data)


### Eliminate outliers to get anything at all ###

slashed_data <- data%>%arrange(profit_margin)
summary(slashed_data)
p5 <- quantile(slashed_data$profit_margin, 0.01)
p95 <- quantile(slashed_data$profit_margin, 0.99)
slashed_data <- slashed_data%>%filter(profit_margin >=p5& profit_margin <=p95)
summary(slashed_data)

slashed_data <- slashed_data%>%arrange(operating_margin)
p5 <- quantile(slashed_data$operating_margin, 0.01)
p95 <- quantile(slashed_data$operating_margin, 0.99)
slashed_data <- slashed_data%>%filter(operating_margin >=p5 & operating_margin <=p95)
summary(slashed_data)


slashed_data <- slashed_data%>%arrange(ebitda)
p5 <- quantile(slashed_data$ebitda, 0.01)
p95 <- quantile(slashed_data$ebitda, 0.99)
slashed_data <- slashed_data%>%filter(ebitda >=p5 & ebitda <=p95)
summary(slashed_data)


slashed_data <- slashed_data%>%arrange(current_ratio)
p5 <- quantile(slashed_data$current_ratio, 0.01)
p95 <- quantile(slashed_data$current_ratio, 0.99)
slashed_data <- slashed_data%>%filter(current_ratio >=p5 & current_ratio <=p95)
summary(slashed_data)

slashed_data <- slashed_data%>%arrange( debt_equity )
p5 <- quantile(slashed_data$ debt_equity , 0.05)
p95 <- quantile(slashed_data$ debt_equity , 0.95)
slashed_data <- slashed_data%>%filter( debt_equity  >=p5 &  debt_equity  <=p95)
summary( slashed_data )

slashed_data <- slashed_data%>%arrange( gross_margin )
p5 <- quantile(slashed_data$ gross_margin , 0.01)
p95 <- quantile(slashed_data$ gross_margin , 0.99)
slashed_data <- slashed_data%>%filter( gross_margin  >=p5 &  gross_margin  <=p95)
summary( slashed_data )



### some models


mlr <- lm(eps~profit_margin+ebitda+operating_margin+debt_ratio+current_ratio + debt_ratio + debt_equity + gross_margin + roa+roe+size, data = slashed_data)
summary(mlr)
plot(mlr)

pairs(slashed_data[,c("profit_margin","ebitda","operating_margin","debt_ratio","current_ratio","debt_equity","gross_margin","roa","roe")])


#logistic regression

set.seed(123)
sample <- sample(c(TRUE,FALSE), nrow(slashed_data), replace = TRUE, prob = c(0.7,0.3))
train <- slashed_data[sample,]
test <- slashed_data[!sample,]



a1 <- glm(eps_binary ~ size + ebitda +gross_margin + debt_ratio +roa, data = slashed_data,  family = binomial(link = "logit"))
summary(a1)


a2 <- glm(eps_binary ~ sector + ebitda+operating_margin + gross_margin + roa,  family = binomial(link = "logit"), data = slashed_data)
summary(a2)



test_data <- cbind(test$size, test$ebitda, test$gross_margin, test$debt_ratio, test$roa)

predict(logistic, test_data)
#classification tree

library(trees)


