library(caret)
# install.packages("e1071")
library(dplyr)
# ##################
# ### QUESTION 5 ###
# ##################
df <- data.frame(
  a=c(rnorm(80), rnorm(20,1,2)),
  b=c(rnorm(80,0,3), rnorm(20,2,2)),
  c=c(rep(T,80), rep(F,20))
)

### BEGIN ANALYSIS AND GRAPHS ###############

### STEP 0: assess the types of variables involved in
### the model.  Here we see that variables 'a' and 'b'
### are both continuous and variable 'c' is discrete
### boolean/dichotmous.


### STEP 1:  partition the data into a training set and 
### a testing set.
set.seed(12345)
train_idx <- createDataPartition(
  df$c,
  p=0.68,
  list=F,
  times=1
)

train <- df[train_idx,]
test <- df[-train_idx,]



### STEP 2: Given the types of variables for predicted and
### predictors, We will look to the logistic regression model 
### for predicting 'c'. We use the binomial distribution 
### as the link function for the generalized linear model
c.glm <- train %>% 
  glm(
    formula=c ~ a+b,
    data=.,
    family=binomial
  )




### STEP 3:  predict how well the training model performs on the testing
### data.  Choose a threshold and apply boolean--here we choose a threshold of 60%
test$prob <- predict(c.glm, test, type='response')
threshold <- 0.60

test$pred <- test$prob > threshold





### STEP 4: test the accuracy of the model
test$accuracy <- ifelse( test$pred == test$c, 1, 0 )
sum(test$accuracy)/nrow(test)
  # output:> 0.8709677

# we can also use the confusion matrix to assess possible combinations
confusionMatrix(test$pred %>% factor(), test$c %>% factor())
  ### <OUTPUT FROM CONFUSION MATRIX>
  # Reference
  # Prediction FALSE TRUE
  # FALSE     2    0
  # TRUE      4   25
  # 
  # Accuracy : 0.871           
  # 95% CI : (0.7017, 0.9637)
  # No Information Rate : 0.8065          
  # P-Value [Acc > NIR] : 0.2563          
  # 
  # Kappa : 0.4464          
  # 
  # Mcnemar's Test P-Value : 0.1336          
  #                                           
  #             Sensitivity : 0.33333         
  #             Specificity : 1.00000         
  #          Pos Pred Value : 1.00000         
  #          Neg Pred Value : 0.86207         
  #              Prevalence : 0.19355         
  #          Detection Rate : 0.06452
  #    Detection Prevalence : 0.06452         
  #       Balanced Accuracy : 0.66667
  ###
### here we confirm 87% accuracy as well as other evaluations of 




### STEP 5: evaluate the significance of the relationships
### between predicted variable 'c' and predictor variables
### 'a' and 'b'. (aside: we know there shouldn't be as these values
### were generated psuedo-randomly from independent 'experiments', 
### but we will pretend we don't know this)
summary(c.glm)
  ### <OUTPUT OF SUMMARY>
  # Call:
  #   glm(formula = c ~ a + b, family = binomial, data = .)
  # 
  # Deviance Residuals: 
  #   Min       1Q   Median       3Q      Max  
  # -2.1121   0.2501   0.4991   0.6151   1.4755  
  # 
  # Coefficients:
  #   Estimate Std. Error z value Pr(>|z|)    
  # (Intercept)   1.8751     0.4224   4.439 9.03e-06 ***
  #   a            -0.1634     0.2532  -0.646   0.5186    
  # b            -0.3245     0.1248  -2.601   0.0093 ** 
  #   ---
  #   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
  # 
  # (Dispersion parameter for binomial family taken to be 1)
  # 
  # Null deviance: 69.606  on 68  degrees of freedom
  # Residual deviance: 61.033  on 66  degrees of freedom
  # AIC: 67.033
  # 
  # Number of Fisher Scoring iterations: 5
  ###
### seeing that the p-values are both greater than 0.05, so neither
### 'a' or 'b' shares a significant relationship to 'c' in the 
### logistic regression model.





# STEP 6:  CONCLUSION
# While the model did produce an accuracy of 87%, the relationship
# between predictors on predicted are insignificant given both 
# knowledge of the data produced and the results of significance
# testing.  The model is not a strong candidate for predicting
# values of 'c' based on 'a' and 'b'


### END ANALYSIS AND GRAPHS