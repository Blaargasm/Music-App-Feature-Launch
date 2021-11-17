rm(list=ls())

#load packages needed for analysis
library(dplyr)
library(ggplot2)
library(stats)
set.seed(1029)

#change margins for future graphs or charts
par(mar=c(6,9.5,6,2))

#import data from bigquery
data = read.csv('experiment.csv', skipNul = TRUE, header = TRUE,fileEncoding="UTF-8-BOM")

#histogram to observe minutes listened
#vast majority of participants spend between 50 and 150 minutes listening
hist(data$minutes_listening_during_experiment, main = 'Histogram of Minutes Listened during experiment', xlab = 'Minutes Listened during experiment')
summary(data$minutes_listening_during_experiment)

#split treatment and control data
t_data = data %>% filter(experiment_cohort == 'treatment')
c_data = data %>% filter(experiment_cohort == 'control')

#try two-sample t-test to compare differences in average minutes listened between control and treatment group
#results are statistically significant
res1 = t.test(t_data$minutes_listening_during_experiment, c_data$minutes_listening_during_experiment)
res1


##Since sample size is very large, apply Central Limit Theorem. Therefore, I am assuming sample mean is ~normally distributed.
#looks like control group has a few outliers that listen to music for over 8 hours/day, let's see what happens if they are removed
hist(c_data$minutes_listening_during_experiment, main='Histogram of Minutes Listened - Control Group', xlab = 'Minutes Listened during experiment')
hist(t_data$minutes_listening_during_experiment, main='Histogram of Minutes Listened - Treatment Group', xlab = 'Minutes Listened during experiment')
summary(c_data$minutes_listening_during_experiment)
summary(t_data$minutes_listening_during_experiment)

#filter out the two data points with >400 minutes listened
c2 = data.frame()
c2 = c_data %>% filter(minutes_listening_during_experiment < 400)
#try testing again
#low p-value of 0.014 even without outliers means we reject the null hypothesis (the new experience has no effect).
#however, i would not recommend launching the feature, because the negative t-value of 
#-2.4517 indicates that the mean of minutes listened during the experiment for the treatment group is 
#both statistically significant, and smaller than the mean of the control group, even with large outliers from the control group removed.
res2 = t.test(t_data$minutes_listening_during_experiment, c2$minutes_listening_during_experiment)
res2

#convert variables to factors, and assign numerical values for variables we want to examine
d2 = data
d2$device_type = factor(ifelse(d2$device_type == 'mobile', '1',
                        ifelse(d2$device_type == 'desktop','2',
                               ifelse(d2$device_type == 'tablet','3',0))))

d2$experiment_cohort = factor(ifelse(d2$experiment_cohort == 'control',0, 1))

d2$region = factor(ifelse(d2$region == 'west', '1',
                               ifelse(d2$region == 'south','2',
                                      ifelse(d2$region == 'midwest','3','4'))))

d2$day_of_experiment = factor(ifelse(d2$day_of_experiment < 8, 'Week 1',
                               ifelse(d2$day_of_experiment >7 & d2$day_of_experiment < 15,'Week 2',
                                      ifelse(d2$day_of_experiment >14 & d2$day_of_experiment < 22,'Week 3','Week 4'))))

d2$age2 = as.factor(ifelse(d2$age >= 18 & d2$age < 25, '18-24',
                              ifelse(d2$age >25 & d2$age <35, '25-34',
                                     ifelse(d2$age >=35 & d2$age < 45, '35-44',
                                            ifelse(d2$age >=45 & d2$age < 55, '45-54',
                                                   ifelse(d2$age >=55 & d2$age < 65, '55-64', '65+'))))))



#test device type by performing two way ANOVA with, and without interaction between the experiment cohort and device type
#also used Tukey's Honestly Significant Difference test to see which groups differ significantly
#included an interaction term for these tests to make graphing easier later
two.way.d = aov(minutes_listening_during_experiment ~ experiment_cohort + device_type, data = d2)
interaction.d = aov(minutes_listening_during_experiment ~ experiment_cohort:device_type, data = d2)

summary(two.way.d)
summary(interaction.d)
td = TukeyHSD(interaction.d)
plot(td, las = 1)


#test gender, first by removing unmarked genders
d3 = d2
d3 = d3[d3$gender !='X',]

two.way.g2 = aov(minutes_listening_during_experiment ~ experiment_cohort + gender, data = d3)
interaction.g2 = aov(minutes_listening_during_experiment ~ experiment_cohort:gender, data = d3)
tg2 = TukeyHSD(interaction.g2)
plot(tg2, las = 1)

#test region
two.way.r = aov(minutes_listening_during_experiment ~ experiment_cohort + region, data = d2)
interaction.r = aov(minutes_listening_during_experiment ~ experiment_cohort:region, data = d2)

summary(two.way.r)
summary(interaction.r)
tr = TukeyHSD(interaction.r)
plot(tr, las = 1)


#week of experiment
two.way.w = aov(minutes_listening_during_experiment ~ experiment_cohort + day_of_experiment, data = d2)
interaction.w = aov(minutes_listening_during_experiment ~ experiment_cohort:day_of_experiment, data = d2)

summary(two.way.w)
summary(interaction.w)
tw = TukeyHSD(interaction.w)
plot(tw, las = 1)

#age
two.way.a = aov(minutes_listening_during_experiment ~ experiment_cohort + age2, data = d2)
interaction.a = aov(minutes_listening_during_experiment ~ experiment_cohort:age2, data = d2)

summary(two.way.a)
summary(interaction.a)
ta = TukeyHSD(interaction.a)

plot(ta, las = 1)

#run linear regression to test assumptions
test = lm(formula = minutes_listening_during_experiment ~ ., data = d2)
summary(test)

