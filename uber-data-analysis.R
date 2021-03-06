
# Install Packages and Library

install.packages("ggplot2")
install.packages("dplyr")
install.packages("reshape2")
library(ggplot2)
library(dplyr)
library(reshape2)

#Read CSV File
getwd()

trips = read.csv("F:/Projects/R/Uber Data Analysis in R/Uber Request Data Original.csv")
head(trips)

summary(trips)

names(trips)

#58% of trips are failed, either 'Cancelled' or 'No Cars Available' Status is 'Cancelled', the 'Drop_timestamp' would be NA Status is 'No Cars Available', the 'Drop_timestamp' and Driver_id would be NA. The numbers of 'Pickup_point' from Airport and City are close, 3238 and 3507

#======= Data Analysis -Exploration and Processing ========

#1. Bar chart of status- Bar chart is optimal to observe the frequency based on pickup location
ggplot(trips, aes(x=Status))+
  geom_bar() +
  scale_y_continuous(breaks = seq(0, 3000, 500)) +
  ggtitle('The frequency of different status') +
  theme(plot.title = element_text(hjust = 0.5))

# 2. Bar chart of Pickup_point on different status
ggplot(trips, aes(x=Pickup.point, fill=Status))+
  geom_bar() +
  scale_y_continuous(breaks = seq(0, 4500, 500)) +
  ggtitle('The frequency of different types of requests in status') +
  theme(plot.title = element_text(hjust = 0.5))


# Get time(hour)
r_time_hour = function(r_time){
  # Extract hour from the timestamp
  r_time = toString(r_time)
  if(grepl('/', r_time)){
    s_time = as.POSIXlt(strptime(r_time,"%d/%m/%Y %H:%M"))
  }
  else if(grepl('-', r_time)) {
    s_time = as.POSIXlt(strptime(r_time,"%d-%m-%Y %H:%M:%S"))
  }
  return(s_time$hour)
}
trips$Request.timehour = unlist(lapply(X = trips$Request.timestamp,FUN = r_time_hour))


# Analyzing Status of requests from both locations at differents timings
# Calculate the number of trips in different status by time
supp_demand = trips %>%
  group_by(Pickup.point, Request.timehour, Status) %>%
  summarise(cnt = n())
supp_demand = as.data.frame(supp_demand)

# Reshape data to get the numbers for plotting
supp_demand.wide = dcast(supp_demand,
                         Pickup.point + Request.timehour ~ Status,
                         value.var = 'cnt')
supp_demand.wide[is.na(supp_demand.wide)] = 0
head(supp_demand.wide)

#Plot to analyze demand and supply based on pickup point and Time of request
# Draw the line plot of number of trips in 3 Status in airport and city by time
ggplot(aes(x = Request.timehour), data = supp_demand.wide) +
  geom_line(aes(y = Cancelled, color='Cancelled')) +
  geom_line(aes(y=`No Cars Available`, color='No Cars Available')) +
  geom_line(aes(y=`Trip Completed`, color='Trip Completed')) +
  ylab('The Number of Trips') +
  scale_x_continuous(breaks = seq(0,23,1)) +
  facet_wrap(~Pickup.point)

#Final Verdict 
#In the airport, the most of problems are due to 'No Cars Available', and it happened from 17 to 22 PM. From 5 to 9 AM, there is hardly any problem happened. In the City, the main problems are due to 'Cancelled', and it happened mainly from 5 to 10 AM. 
# The main problems become 'No Cars Available' from 11 to 16 PM, but they are not very serious, and after 17 PM, there are only few problems happened.