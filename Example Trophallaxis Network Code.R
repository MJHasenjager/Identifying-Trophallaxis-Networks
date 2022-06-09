#Load packages
library(simplextree)
library(ggplot2)

#Set working directory
setwd("C://Users/mjhas/OneDrive/Desktop/Supply Chain Network Models/Ant Interaction Networks/Data/")

#Load functions
source("C://Users/mjhas/OneDrive/Desktop/Supply Chain Network Models/Ant Interaction Networks/extractTrophallaxisInteractions_Functions.R")

#Load data

#Proximity interaction data
sugarD1_ProxData <- read.csv("ProximityData-Small-Sugar-10-28-Disruption.csv", header=TRUE)

#Load raw trajectory data
sugarD1_TrajData <- read.csv("TrajectoryData-Small-Sugar-10-28-Disruption.csv", header=TRUE)

#Correct frames to match between the two data sets
sugarD1_TrajData$time <- (sugarD1_TrajData$time - 1)/5

#Extract trophallaxis interactions
sugarD1TrophData <- extractTrophallaxisInteractions(data = sugarD1_ProxData, trajData = sugarD1_TrajData, maxTimeGap = 10)

#Identify higher-order interactions involving > 2 participants
sugarD1TrophData$hoInteraction <- identify_higherOrder_exchanges(sugarD1TrophData)

#Standardised fluorescence amounts
sugarD1TrophData$DonateVolumeStd <- (sugarD1TrophData$DonateVolume - mean(c(sugarD1TrophData$DonateVolume, sugarD1TrophData$ReceiveVolume)))/sd(c(sugarD1TrophData$DonateVolume, sugarD1TrophData$ReceiveVolume))
sugarD1TrophData$ReceiveVolumeStd <- (sugarD1TrophData$ReceiveVolume - mean(c(sugarD1TrophData$DonateVolume, sugarD1TrophData$ReceiveVolume)))/sd(c(sugarD1TrophData$DonateVolume, sugarD1TrophData$ReceiveVolume))

#Extract interactions that are strictly pairwise
sugarDisruptionPairwiseData <- sugarD1TrophData[which(sugarD1TrophData$hoInteraction==0),]

#Examine correlation between estimated donation and recieving volume
ggplot(sugarDisruptionPairwiseData, aes(y = ReceiveVolumeStd, x = DonateVolumeStd))+
  xlim(c(-1,5))+ylim(c(-1,5))+
  geom_point()+
  geom_smooth(method = "lm", se = FALSE)


#Examine correlation across all interactions, though this is not corrected for donation amount as a function of group size
ggplot(data = sugarD1TrophData, aes(y = ReceiveVolumeStd, x = DonateVolumeStd))+
  xlim(c(-1,6))+ylim(c(-1,6))+
  geom_point()+
  geom_smooth(method = "lm", se = FALSE)

#Examine distribution of trophallaxis duration
hist(sugarD1TrophData$Duration_Frames/2.5, breaks = 30)

#Extract simplices from interaction list
sugarD1SimplexData <- extract_simplices(data = sugarD1TrophData, timeStart = 1, timeEnd = max(sugarD1TrophData$TimeEnd))

#Create simplicial set
sugarD1Complex <- simplex_tree()
sugarD1Complex %>% insert(sugarD1SimplexData[[2]])

#There are 17 individuals identified (0-simplices)
#33 pairwise dyads (1-simplices)
#2 triadic interactions (2-simplices)
sugarD1Complex

#Plot the trophallaxis network
#Individuals that donated at least once are colored in blue
#The filled triangles indicate those triadic interactions
#One obvious next step for the code is to implement functionality to easily specify time windows over which to construct the network
plot_trophallaxis_network(st = sugarD1Complex, donors = sugarD1SimplexData[[1]])
