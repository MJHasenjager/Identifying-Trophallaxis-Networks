library(igraph)
################################################################################################################################
IDgrouplist<-read.csv("IDList.csv")
TreatmentType<-unique(IDgrouplist$Group)
total<-as.data.frame(matrix(0,ncol = 5,nrow = 1))
colnames(total)=c("Density","Betweenness","Modularity","Condition","ColonyID")
individualbetweenness<-as.data.frame(matrix(0,ncol=6,nrow = 1))
colnames(individualbetweenness)<-c("IndividualID","IndividualDegree","IndividualBetweenness","Condition","ColonyID","NumberWorkers")
for (i in TreatmentType) {
  setwd("D:/PostDoc-Noa-2021/ForNoa/New/TrophallaxisNetworks1frames")
  a = IDgrouplist[which(IDgrouplist$Group==i),]
  aa = a$FileName
  bb=a$GroupSize
  for (j in aa) {
    index=which(aa %in% j)
    total1<-as.data.frame(matrix(0,ncol = 5,nrow = 1))
    colnames(total1)=c("Density","Betweenness","Modularity","Condition","ColonyID")
    networkdata<-read.csv(paste(noquote(j),".csv",sep = ""))[,c(1,2)]
    numberWorker<-bb[index]
    colnames(networkdata)<- c("From","To")
    ID<-matrix(0,ncol = 1,nrow = length(networkdata$From)*2)
    ID[c(1:length(networkdata$From)),1] = networkdata$From
    ID[c((length(networkdata$From)+1):(length(networkdata$From)*2)),1] = networkdata$To
    IDLIST<-unique(ID)
    net <- graph_from_data_frame(d=networkdata, vertices=IDLIST, directed=F) 
    net <- simplify(net, remove.multiple = T, remove.loops = F) 
    density <- edge_density(net)
    betweenness <- betweenness(net)
    modu<-modularity(net , membership(leading.eigenvector.community(net)))
    total1$Density[1]=density
    total1$Betweenness[1]=mean(betweenness)
    total1$Modularity[1]= modu
    total1$ColonyID[1]=j
    total1$Condition[1]=i
    degree(net)
    betweenness(net)
    individualbetweenness1<-as.data.frame(matrix(0,ncol=6,nrow = length(matrix(betweenness(net)))))
    colnames(individualbetweenness1)<-c("IndividualID","IndividualDegree","IndividualBetweenness","Condition","ColonyID","NumberWorkers")
    individualbetweenness1$IndividualID<-as.numeric(rownames( as.data.frame(betweenness(net))))
    individualbetweenness1$IndividualBetweenness=matrix(betweenness(net))
    individualbetweenness1$Condition<-i
    individualbetweenness1$ColonyID<-j
    individualbetweenness1$IndividualDegree<-matrix(degree(net))
    individualbetweenness1$NumberWorkers<-numberWorker
    total<-rbind(total,total1)
    individualbetweenness<-rbind(individualbetweenness,individualbetweenness1)
  }
}
total<-total[-1,]
individualbetweenness<-individualbetweenness[-1,]
write.csv(total,"GlobalMeasureNetworksNewCommunityAlgorithm.csv")
write.csv(individualbetweenness,"IndividualMeasureNetworksNewCommunityAlgorithm.csv")
