# this script makes networks from edgelists from Guo and calculates network measures

# init
rm(list = ls())
graphics.off()

# load packages
library(igraph)


# load data
# get directory
direct = "C:/Users/nmpin/Dropbox/supply chain comparing netwroks - guo/Data and analysis/network data"
all_nets=dir(direct)

## set up some variables to fill in loop
modul_bet = rep(NA, length(all_nets))
modul_bet_num = rep(NA, length(all_nets))
modul_cwt = rep(NA, length(all_nets))
modul_cwt_num = rep(NA, length(all_nets))
modul_cfg = rep(NA, length(all_nets))
modul_cfg_num = rep(NA, length(all_nets))
modul_lou = rep(NA, length(all_nets))
modul_lou_num = rep(NA, length(all_nets))
dens = rep(NA, length(all_nets))
trans = rep(NA, length(all_nets))
avg_deg = rep(NA, length(all_nets))
n_node = rep(NA, length(all_nets))
col_names= rep(NA, length(all_nets))
  
for(i in 1:length(all_nets)){
  data = as.data.frame(read.csv(paste(direct, '/', all_nets[i], sep = "")))
  # I used simplify below because every frame in which two ants interact is counted as an interaction. but this could be made a bit more elaborate, to get actual number of interactions by deciding that consecutive frames are considered as one interaction.
  
  net=simplify(graph_from_data_frame(data,directed = FALSE)) 
  
  windows()
  par(mfrow=c(2,2))
  community_detect_bet <- cluster_edge_betweenness(net)
  plot(net, vertex.color = community_detect_bet$membership, main= paste( all_nets[i],"\n cluster_edge_betweenness"))
  modul_bet[i] = modularity(net, membership(community_detect_bet))
  modul_bet_num[i] = length(unique(community_detect_bet$membership))
    
  community_detect_cwt <- cluster_walktrap(net)
  plot(net, vertex.color = community_detect_cwt$membership, main= paste( all_nets[i],"\n cluster_walktrap"))
  modul_cwt[i] = modularity(net, membership(community_detect_cwt))
  modul_cwt_num[i] = length(unique(community_detect_cwt$membership))
  
  community_detect_cfg <- cluster_fast_greedy(net)
  plot(net, vertex.color = community_detect_cfg$membership, main= paste( all_nets[i],"\n cluster_fast_greedy"))
  modul_cfg[i] = modularity(net, membership(community_detect_cfg))
  modul_cfg_num[i] = length(unique(community_detect_cfg$membership))
  
  community_detect_lou <- cluster_louvain(net)
  plot(net, vertex.color = community_detect_lou$membership, main= paste( all_nets[i],"\n cluster_louvain"))
  modul_lou[i] = modularity(net, membership(community_detect_lou))
  modul_lou_num[i] = length(unique(community_detect_lou$membership))
  
  dens[i] = edge_density(net)
  
  avg_deg[i] = mean(degree(net))
  
  trans[i] = transitivity(net) 
  
  n_node[i] = length(V(net))
  
  col_names[i] = unlist(strsplit(all_nets[i], ".csv"))
}
global_measures = as.data.frame(cbind(col_names,
                        modul_bet, modul_bet_num,
                        modul_cwt, modul_cwt_num,
                        modul_cfg, modul_cfg_num,
                        modul_lou, modul_lou_num,
                        trans, dens, avg_deg, n_node ))


## compare with Guo's output and consolidate for other information:
guo_global_measures = read.csv('GlobalMeasureNetworks.csv')
names(guo_global_measures)[4] = "col_names"
merged_df = merge(global_measures, guo_global_measures, by = "col_names")
for(j in 2:13){ merged_df[,j]=as.numeric(merged_df[,j])}

boxplot(merged_df$modul_lou_num/merged_df$n_node~as.factor(merged_df$Treatment))
plot(merged_df$modul_lou_num, merged_df$modul_cfg_num)
hist(merged_df$modul_bet_num/merged_df$n_node)
hist(merged_df$trans)

#save(merged_df,file = "C:/Users/nmpin/Dropbox/IARPA/Interaction data from Guo/data analysis/Global_measures_extended.RData")
#write.table(merged_df, file = "All_global_df.csv") 