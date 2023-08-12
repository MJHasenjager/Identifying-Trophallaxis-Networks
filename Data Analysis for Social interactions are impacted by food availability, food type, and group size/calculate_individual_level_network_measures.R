library(igraph)
################################################################################################################################
IDgrouplist<-read.csv("ExperimentsMetadata.csv")
TreatmentType<-unique(IDgrouplist$Group)
individuallevel<-as.data.frame(matrix(0,ncol=6,nrow = 1))
colnames(individuallevel)<-c("IndividualID","IndividualDegree","IndividualBetweenness","Condition","ColonyID","NumberWorkers")
for (i in TreatmentType) {
  setwd("D:/PostDoc-Noa-2021/ForNoa/New/TrophallaxisNetworks1frames")
  a = IDgrouplist[which(IDgrouplist$Group==i),]
  aa = a$FileName
  bb=a$GroupSize
  for (j in aa) {
    index=which(aa %in% j)
    networkdata<-read.csv(paste(noquote(j),".csv",sep = ""))[,c(1,2)]
    numberWorker<-bb[index]
    colnames(networkdata)<- c("From","To")
    ID<-matrix(0,ncol = 1,nrow = length(networkdata$From)*2)
    ID[c(1:length(networkdata$From)),1] = networkdata$From
    ID[c((length(networkdata$From)+1):(length(networkdata$From)*2)),1] = networkdata$To
    IDLIST<-unique(ID)
    net <- graph_from_data_frame(d=networkdata, vertices=IDLIST, directed=F) 
    net <- simplify(net, remove.multiple = T, remove.loops = F) 
    modu<-modularity(net , membership(leading.eigenvector.community(net)))
    degree(net)
    betweenness(net)
    individuallevel1<-as.data.frame(matrix(0,ncol=6,nrow = length(matrix(betweenness(net)))))
    colnames(individuallevel1)<-c("IndividualID","IndividualDegree","IndividualBetweenness","Condition","ColonyID","NumberWorkers")
    individuallevel1$IndividualID<-as.numeric(rownames( as.data.frame(betweenness(net))))
    individuallevel1$IndividualBetweenness=matrix(betweenness(net))
    individuallevel1$Condition<-i
    individuallevel1$ColonyID<-j
    individuallevel1$IndividualDegree<-matrix(degree(net))
    individuallevel1$NumberWorkers<-numberWorker
    individuallevel<-rbind(individuallevel,individuallevel1)
  }
}
individuallevel<-individuallevel[-1,]
write.csv(individuallevel,"IndividualMeasureNetworksNewCommunityAlgorithm.csv")