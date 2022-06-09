#data are the identified proximity-based interactions
#trajData are the corresponding movement trajectories
#maxTimeGap indicates how many frames must elapse before two interactions between the same dyad are considered separate interactions
#In other words, all interactions within maxTimeGap between the same pair are aggregated into a single interaction with a start and stop time

#The procedure first aggregates consecutive frames involving the same pair of individuals in spatial proximity to generate interactions with start and stop times
#Next, the mean fluorescence values for each individual during periods where they are not interacting are extracted
#Finally, for each potential interaction in the aggregated list, only interactions with both a donor and receiver are retained
#Donor and receiver are identified based on change in mean fluorescence pre- vs. post-interaction
extractTrophallaxisInteractions <- function(data, trajData, maxTimeGap) {
  
  nrowDat <- nrow(data)
  
  #Reorder the proximity interaction data so that for each dyad, each ant is always in the same column
  #e.g., for dyad A-B, ant A will always be in "ID1" and B will always be in "ID2"
  #This makes it easier to manipulate the dataframe later on
  reorderedDat <- data.frame("ID1" = rep(0, nrowDat), 
                             "ID2" = rep(0, nrowDat), 
                             "locX" = rep(0, nrowDat), 
                             "locY" = rep(0, nrowDat), 
                             "time" = rep(0, nrowDat), 
                             "Fluo1" = rep(0, nrowDat), 
                             "Fluo2" = rep(0, nrowDat), 
                             "Interpolation" = rep(0, nrowDat) 
  )
  
  for(i in 1:nrowDat) {
    if(data[i,1] < data[i,2]) {
      reorderedDat[i,] <- data[i,]
    } else{
      reorderedDat[i,1] <- data[i,2]
      reorderedDat[i,2] <- data[i,1]
      reorderedDat[i,3] <- data[i,3]
      reorderedDat[i,4] <- data[i,4]
      reorderedDat[i,5] <- data[i,5]
      reorderedDat[i,6] <- data[i,7]
      reorderedDat[i,7] <- data[i,6]
      reorderedDat[i,8] <- data[i,8]
    }
  }
  
  #Reorder the proximity interaction data from the earliest to the latest interaction start time
  reorderedDat <- reorderedDat[order(reorderedDat$time), ]
  
  #Identify the unique IDs present in each column
  ID1List <- unique(reorderedDat$ID1)
  ID2List <- unique(reorderedDat$ID2)
  
  #Create new variables to hold the list of interactions following aggregation
  ID1 <- c()
  ID2 <- c()
  TimeStart <- c()
  TimeEnd <- c()
  
  #Identify the unique IDs present in the trajectory data
  IDList <- unique(trajData$number)

  #For each dyad, aggregate any interactions that occurred between them and within maxTimeGap into a single interaction
  for (i in IDList) {
    for (j in IDList) {
      dataTemp <- reorderedDat[reorderedDat$ID1 == i & reorderedDat$ID2 == j, ]
      
      #If dyad [i,j] interacted, first identify the last frame they were recorded as interacting interacted (maxTime)
      if(nrow(dataTemp) > 0) {
        maxTime <- max(dataTemp$time)
        
        #Work through each identified proximity interaction
        for (t in 1:nrow(dataTemp)) {
          #First identify when that interaction may have started
          potentialStart <- dataTemp[t,"time"]
          iteration <- 1
          #If the potential start time is less than the max time, this means that other interactions were identified after the current row
          if(potentialStart < maxTime){
            repeat{
              #Work through each row and determine whether it is still within maxTimeGap from the current start time
              #If yes, continue to the next row down; if no, then the potential end time is the time for the last row that was within maxTimeGap
              #If maxTime is reached during this process, that indicates that everything from potentialStart to maxTime should be considered a single interaction
              potentialEnd <- dataTemp[t + iteration, "time"]
              previousStep <- dataTemp[t + iteration - 1, "time"]
              if(potentialEnd - previousStep > maxTimeGap){
                potentialEnd <- dataTemp[t + iteration - 1, "time"]
                iteration <- iteration - 1
                break
              }
              if(potentialEnd == maxTime){
                break
              }
              iteration <- iteration + 1
            }} else{
              potentialEnd <- potentialStart
            }
          
          #Record the new interaction according to its identified start and stop time
          #The procedure slightly differs depending on whether or not it is the first time a dyad has interacted
          #This step should also means rows aren't double counted, as an interaction is only recorded if it's start time occurs at least maxTimeGap from the previous row
          if(t > 1 && (dataTemp[t,"time"] - dataTemp[t-1,"time"]) > maxTimeGap && potentialStart < potentialEnd) {
              ID1 <- c(ID1, i)
              ID2 <- c(ID2, j)
              TimeStart <- c(TimeStart, potentialStart)
              TimeEnd <- c(TimeEnd, potentialEnd)
          }

          if(t == 1 && potentialStart < potentialEnd){
              ID1 <- c(ID1, i)
              ID2 <- c(ID2, j)
              TimeStart <- c(TimeStart, potentialStart)
              TimeEnd <- c(TimeEnd, potentialEnd)
          }
        }
      }
    }
  }
  
  #At the end of this process, we have an aggregated list of proximity interactions with start and stop times
  potentialInteractions <- data.frame("ID1" = ID1, 
                                      "ID2" = ID2, 
                                      "TimeStart"= TimeStart, 
                                      "TimeEnd" = TimeEnd)
  
  potentialInteractions <- potentialInteractions[order(potentialInteractions$TimeStart), ]
  
  #Next, create the variables that will store information on each individuals fluorescence at the start and end of each interaction
  ID <- c()
  TimeStart <- c()
  TimeEnd <- c()
  wMeanFluo <- c()
  
  #Work through each individual involved in the previously aggregated list of interactions
  for(i in unique(c(potentialInteractions$ID1, potentialInteractions$ID2))) {
    potIntDatTemp <- potentialInteractions[which(potentialInteractions$ID1 == i | potentialInteractions$ID2 == i), ]
    
    #These next lines identify potential interactions that began when individual i was still identified as being engaged in a previous interaction
    potIntDatTemp$flag <- 0
    if(nrow(potIntDatTemp)>1){
    for(r in 2:nrow(potIntDatTemp)){
      if(potIntDatTemp[r, "TimeStart"] <= potIntDatTemp[r-1,"TimeEnd"]){
        potIntDatTemp[r,"flag"] <-1
      }
    }
    }
    
    for(r in nrow(potIntDatTemp):1) {
      if(potIntDatTemp[r,"flag"]==1){
        potIntDatTemp[r-1,"TimeEnd"] <- max(potIntDatTemp[r,"TimeEnd"],potIntDatTemp[r-1,"TimeEnd"])
      }
    }
    
    #Extract non-overlapping interactions
    potIntDatTemp<-potIntDatTemp[which(potIntDatTemp$flag==0),]
    
    #Pull out the trajectory data for individual i
    trajDatTemp <- trajData[which(trajData$number == i),]
    
    #Procedures slightly differ depending on if an individual was involved in multiple potential interactions
    #Note, as you can see, I also tried out weighted means, with higher weights assigned to frames in which an ant was moving more slowly or not at all
    #Medians could also be used, or as Noa suggested, introducing a time window over which to estimate the central tendency of fluorescence
    if(nrow(potIntDatTemp) == 1 ){
      #First, identify an individual's mean fluorescence up to right before its first potential interaction
      ID <- c(ID, i)
      TimeStart <- c(TimeStart, min(trajDatTemp$time))
      TimeEnd <- c(TimeEnd, potIntDatTemp[1, "TimeStart"]-1)
      wMeanFluo <- c(wMeanFluo, 
                     mean(trajDatTemp$light[trajDatTemp$time < potIntDatTemp[1, "TimeStart"]], na.rm = TRUE))
                     #weighted.mean(trajDatTemp$light[trajDatTemp$time < potIntDatTemp[1,"TimeStart"]], 1-trajDatTemp$speed[trajDatTemp$time < potIntDatTemp[1,"TimeStart"]]))
      
      #Next, identify an individual's mean fluorescence following its last interaction to the end of the trial
      ID <- c(ID, i)
      TimeStart <- c(TimeStart, potIntDatTemp[nrow(potIntDatTemp), "TimeEnd"]+1)
      TimeEnd <- c(TimeEnd, max(trajDatTemp$time))
      wMeanFluo <- c(wMeanFluo, 
                     mean(trajDatTemp$light[trajDatTemp$time > potIntDatTemp[nrow(potIntDatTemp), "TimeEnd"]], na.rm = TRUE))
                     #weighted.mean(trajDatTemp$light[trajDatTemp$time > potIntDatTemp[nrow(potIntDatTemp), "TimeEnd"]], 1-trajDatTemp$speed[trajDatTemp$time > potIntDatTemp[nrow(potIntDatTemp), "TimeEnd"]]))
    } else{
      if(nrow(potIntDatTemp) > 1) {
        #First, identify an individual's mean fluorescence up to right before its first potential interaction
        ID <- c(ID, i)
        TimeStart <- c(TimeStart, min(trajDatTemp$time))
        TimeEnd <- c(TimeEnd, potIntDatTemp[1, "TimeStart"]-1)
        wMeanFluo <- c(wMeanFluo, mean(trajDatTemp$light[trajDatTemp$time < potIntDatTemp[1, "TimeStart"]], na.rm = TRUE))
                       #weighted.mean(trajDatTemp$light[trajDatTemp$time < potIntDatTemp[1,"TimeStart"]], 1-trajDatTemp$speed[trajDatTemp$time < potIntDatTemp[1,"TimeStart"]]))
        
        #Next, identify an individual's mean flourescence for each gap between potential interactions
        for(r in 1:(nrow(potIntDatTemp)-1)) {
          ID <- c(ID, i)
          TimeStart <- c(TimeStart, potIntDatTemp[r, "TimeEnd"]+1)
          TimeEnd <- c(TimeEnd, potIntDatTemp[r+1, "TimeStart"] - 1)
          wMeanFluo <- c(wMeanFluo, 
                         mean(trajDatTemp$light[trajDatTemp$time > potIntDatTemp[r, "TimeEnd"] & trajDatTemp$time < potIntDatTemp[r+1, "TimeStart"]], na.rm = TRUE))
                         #weighted.mean(trajDatTemp$light[trajDatTemp$time > potIntDatTemp[r, "TimeEnd"] & trajDatTemp$time < potIntDatTemp[r+1, "TimeStart"]], 
                          #             1-trajDatTemp$speed[trajDatTemp$time > potIntDatTemp[r, "TimeEnd"] & trajDatTemp$time < potIntDatTemp[r+1, "TimeStart"]]))
        }
        
        #Finally, identify an individual's mean fluorescence following its last interaction to the end of the trial
        ID <- c(ID, i)
        TimeStart <- c(TimeStart, potIntDatTemp[nrow(potIntDatTemp), "TimeEnd"]+1)
        TimeEnd <- c(TimeEnd, max(trajDatTemp$time))
        wMeanFluo <- c(wMeanFluo, 
                       mean(trajDatTemp$light[trajDatTemp$time > potIntDatTemp[nrow(potIntDatTemp), "TimeEnd"]], na.rm = TRUE))
                       #weighted.mean(trajDatTemp$light[trajDatTemp$time > potIntDatTemp[nrow(potIntDatTemp), "TimeEnd"]], 1-trajDatTemp$speed[trajDatTemp$time > potIntDatTemp[nrow(potIntDatTemp), "TimeEnd"]]))
        
      }
    }
  }
  
  #Combine the fluorescence data between interactions into a dataframe
  nonInteractingFluo <- data.frame("ID" = ID,
                                   "TimeStart" = TimeStart,
                                   "TimeEnd" = TimeEnd,
                                   "wMeanFluo" = wMeanFluo)
  
  #There are instances in which the above code produced NaNs, but could be corrected by taking the next flourescence value down
  #This only works if the next row down is always the same individual, which I believe was the case here
  #I believe NaNs only occurred for periods between interactions, not prior the first or after the final interaction,
  #If this is not the case, though, this code will need to be modified
  #In either case, it can likely be improved, but it was a quick fix when implemented
  for(r in 1:nrow(nonInteractingFluo)){
    if(is.nan(nonInteractingFluo[r,"wMeanFluo"])){
      nonInteractingFluo[r,"wMeanFluo"] <- nonInteractingFluo[r+1,"wMeanFluo"]
    }
  }
   
  DonorID <- c()
  RecipientID <- c()
  TimeStart <- c()
  TimeEnd <- c()
  initDonorFluo <- c()
  finalDonorFluo <- c()
  initRecFluo <- c()
  finalRecFluo <- c()
  
  #Finally, for each potential interaction, identify if there is a paired potential donor and recipient
  #Donors would exhibit a net decrease in fluorescence when looking at their pre- and post-interaction fluorescence
  #Likewise, recipients would exhibit a net increase
  #Potential interactions that did not have both a donor and receiver were discarded
  #Otherwise, the donor and receiver were identified
  for(r in 1:nrow(potentialInteractions)){

    ID1StartFluo <- nonInteractingFluo$wMeanFluo[nonInteractingFluo$ID==potentialInteractions[r,"ID1"] & 
                                                   nonInteractingFluo$TimeEnd == max(nonInteractingFluo$TimeEnd[nonInteractingFluo$ID==potentialInteractions[r,"ID1"] & 
                                                                                                                  nonInteractingFluo$TimeEnd < potentialInteractions[r,"TimeStart"]])]
    ID1EndFluo <- nonInteractingFluo$wMeanFluo[nonInteractingFluo$ID==potentialInteractions[r,"ID1"] & 
                                                   nonInteractingFluo$TimeStart == min(nonInteractingFluo$TimeStart[nonInteractingFluo$ID==potentialInteractions[r,"ID1"] & 
                                                                                                                  nonInteractingFluo$TimeStart > potentialInteractions[r,"TimeEnd"]])]
        
    ID2StartFluo <- nonInteractingFluo$wMeanFluo[nonInteractingFluo$ID==potentialInteractions[r,"ID2"] & 
                                                   nonInteractingFluo$TimeEnd == max(nonInteractingFluo$TimeEnd[nonInteractingFluo$ID==potentialInteractions[r,"ID2"] & 
                                                                                                                  nonInteractingFluo$TimeEnd < potentialInteractions[r,"TimeStart"]])]
    ID2EndFluo <- nonInteractingFluo$wMeanFluo[nonInteractingFluo$ID==potentialInteractions[r,"ID2"] & 
                                                 nonInteractingFluo$TimeStart == min(nonInteractingFluo$TimeStart[nonInteractingFluo$ID==potentialInteractions[r,"ID2"] & 
                                                                                                                    nonInteractingFluo$TimeStart > potentialInteractions[r,"TimeEnd"]])]
    if(!is.na(ID1StartFluo) & !is.na(ID1EndFluo) & !is.na(ID2StartFluo) & !is.na(ID2EndFluo)){
    if ((ID1EndFluo - ID1StartFluo) < 0 && (ID2EndFluo - ID2StartFluo) > 0) {
      DonorID <- c(DonorID, potentialInteractions[r,"ID1"])
      RecipientID <- c(RecipientID, potentialInteractions[r,"ID2"])
      TimeStart <- c(TimeStart, potentialInteractions[r,"TimeStart"])
      TimeEnd <- c(TimeEnd, potentialInteractions[r,"TimeEnd"])
      initDonorFluo <- c(initDonorFluo, ID1StartFluo)
      finalDonorFluo <- c(finalDonorFluo, ID1EndFluo)
      initRecFluo <- c(initRecFluo, ID2StartFluo)
      finalRecFluo <- c(finalRecFluo, ID2EndFluo)
    } else {
      if ((ID2EndFluo - ID2StartFluo) < 0 && (ID1EndFluo - ID1StartFluo) > 0) {
        DonorID <- c(DonorID, potentialInteractions[r,"ID2"])
        RecipientID <- c(RecipientID, potentialInteractions[r,"ID1"])
        TimeStart <- c(TimeStart, potentialInteractions[r,"TimeStart"])
        TimeEnd <- c(TimeEnd, potentialInteractions[r,"TimeEnd"])
        initDonorFluo <- c(initDonorFluo, ID2StartFluo)
        finalDonorFluo <- c(finalDonorFluo, ID2EndFluo)
        initRecFluo <- c(initRecFluo, ID1StartFluo)
        finalRecFluo <- c(finalRecFluo, ID1EndFluo)
      }
    }
  }
  }
   
  dfTemp <- data.frame("Observation" = seq(1:length(DonorID)),
                       "DonorID" = DonorID,
                       "RecipientID" = RecipientID, 
                       "TimeStart" = TimeStart, 
                       "TimeEnd" = TimeEnd, 
                       "initDonorFluo" = initDonorFluo, 
                       "finalDonorFluo" = finalDonorFluo, 
                       "initRecFluo" = initRecFluo, 
                       "finalRecFluo" = finalRecFluo, 
                       "DonateVolume" = initDonorFluo - finalDonorFluo, 
                       "ReceiveVolume" = finalRecFluo - initRecFluo,
                       "Duration_Frames" = TimeEnd - TimeStart)
  return(dfTemp)
}

#Identify overlapping interactions involving the same donor individual and >1 recipients
identify_higherOrder_exchanges <- function(data) {
  higherOrderExchanges <- c()
  if(nrow(data)>0) {
    for(i in 1:nrow(data)) {
      if(nrow(data[which(data$TimeStart < data[i,"TimeEnd"] & data$TimeStart >= data[i,"TimeStart"]),]) > 1) {
        nrows <- nrow(data[which(data$TimeStart < data[i,"TimeEnd"] & data$TimeStart >= data[i,"TimeStart"]),])
        dataTemp <- data[i:(i+nrows-1),]
        donorID <- dataTemp[1,"DonorID"]
        recMatchData <- dataTemp[which(dataTemp$DonorID == donorID),]
        if(nrow(recMatchData) > 1) {
          higherOrderExchanges <- c(higherOrderExchanges,recMatchData$Observation)
        }
      }
    }
  }
  higherOrderExchanges <- unique(higherOrderExchanges)
  higherOrderInteraction <- rep(0, nrow(data))
  for(i in higherOrderExchanges) {
    higherOrderInteraction[i] <- 1
  }
  return(higherOrderInteraction)
}

#From the list of dyadic and higher-order (>2 participants), extract the simplicial set
extract_simplices <- function(data, timeStart, timeEnd) {
  nodes <- unique(c(data$DonorID, data$RecipientID))
  data <- data[order(data$TimeStart),]
  data <- data[data$TimeStart >= timeStart & data$TimeStart <= timeEnd,]
  simplicesList <- list()
  donorList <- list()
  if(nrow(data)>0) {
    
    #Record food donors
    donorList <- unique(data$DonorID)
    
    #Record 1-simplices
    for(i in 1:nrow(data)) {
      simplicesList[[i]] <- c(data[i,"DonorID"],data[i,"RecipientID"])
    }
    
    #Record higher-order simplices
    for(i in 1:nrow(data)) {
      if(nrow(data[which(data$TimeStart < data[i,"TimeEnd"] & data$TimeStart >= data[i,"TimeStart"]),]) > 1) {
        nrows <- nrow(data[which(data$TimeStart < data[i,"TimeEnd"] & data$TimeStart >= data[i,"TimeStart"]),])
        dataTemp <- data[i:(i+nrows-1),]
        donorID <- dataTemp[1,"DonorID"]
        recMatchData <- dataTemp[which(dataTemp$DonorID == donorID),]
        if(nrow(recMatchData) > 1) {
          simplex <- c(donorID, recMatchData$RecipientID)
          simplicesList[[(length(simplicesList)+1)]] <- c(simplex)
        }
      }
    }
    
    #Record 0-simplices
    simplicesList <- c(simplicesList, nodes)
  }
  return(list(donorList, simplicesList))
}

plot_trophallaxis_network <- function(st, donors) {
  colorVect <- c(rep("red", length(st$vertices)), rep("purple", nrow(st$edges)), rep("yellow", st$n_simplices[3]))
  for(i in 1:length(st$vertices)) {
    if (st$vertices[i] %in% donors) {
      colorVect[i] <- "blue"
    }
  }
  return(plot(st, color_pal = colorVect))
}