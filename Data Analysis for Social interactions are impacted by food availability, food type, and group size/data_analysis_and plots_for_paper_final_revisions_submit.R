## this script takes network measures calculated in other scripts and runs statistical analysis and plotting
# initilize workspace
rm(list = ls())
graphics.off()

###################
# load packages
library(sjPlot)
library(lme4)
library(car)
library(performance) # https://easystats.github.io/performance/
library('ggplot2')
library(emmeans)

###################
# load group-level data:
## in this new DF network measures are calculated using the same distance threshold for all videos (102 pixels). 
global_data_new_thresh = read.csv('All_global_df_uniform_thresh_final.csv')

## this is the old global network DF, with information on average frame rate (avg_FR) - to combine with the new data
old_global_data_with_frame_rate_and_old_thresh = read.csv('GlobalMeasureNetworks_with frame_info.csv')

# merge the two  
merged_global_data <- merge(global_data_new_thresh, old_global_data_with_frame_rate_and_old_thresh, by = "ExperimentID")

# keep only relevant columns (i.e. remove old measures with changing threshold) 
global_data = merged_global_data[,-c(seq(14,25))]

# load individual-level data:
## in this new DF individual measures are calculated using the new distance threshold that is consistent across all videos (102 pixels)
## total distance traveled is also included now
ind_data_revised = read.csv('IndividualMeasureNetworksNewThreshold_final.csv')

# add  group level information to the individual information:
merged_ind_data <- merge(ind_data_revised, global_data, by = "ExperimentID")
## keep only columns needed for individual analysis:
ind_data = merged_ind_data[, -c(seq(8,13),20)]

# convert certain variables to factors:
global_data$FoodType = as.factor(global_data$FoodType)
global_data$Treatment = as.factor(global_data$Treatment)
global_data$Group.ID = as.factor(global_data$Group.ID)

ind_data$FoodType = as.factor(ind_data$FoodType)
ind_data$Treatment = as.factor(ind_data$Treatment)
ind_data$ColonyID = as.factor(ind_data$ColonyID)
ind_data$IndividualID = as.factor(ind_data$IndividualID)

##################
# create a theme for plotting that looks nice:
theme_mine <- function(base_size = 18, base_family = "Helvetica") {
  # Starts with theme_grey and then modify some parts
  theme_bw(base_size = base_size, base_family = base_family) %+replace%
    theme(
      strip.background = element_blank(),
      strip.text.x = element_text(size = 18),
      strip.text.y = element_text(size = 18),
      axis.text.x = element_text(size=14),
      axis.text.y = element_text(size=14,hjust=1),
      axis.ticks =  element_line(colour = "black"), 
      axis.title.x= element_text(size=16),
      axis.title.y= element_text(size=16,angle=90),
      panel.background = element_blank(), 
      panel.border =element_blank(), 
      panel.grid.major = element_blank(), 
      panel.grid.minor = element_blank(), 
      panel.margin = unit(1.0, "lines"), 
      plot.background = element_blank(), 
      plot.margin = unit(c(0.5,  0.5, 0.5, 0.5), "lines"),
      axis.line.x = element_line(color="black", size = 1),
      axis.line.y = element_line(color="black", size = 1)
    )
}

###################
# data analysis

###################
# group level analysis:
###################
###################
#Density:
# model selection:
mg1_dens=lmer(dens ~ FoodType.x * Treatment.x * GroupSize.1.x + Avg_FR + (1|Group.ID), data = global_data)
mg2_dens=lmer(dens ~ FoodType.x + Treatment.x + GroupSize.1.x + Avg_FR + (1|Group.ID), data = global_data)
mg3_dens=lmer(dens ~ FoodType.x * Treatment.x + GroupSize.1.x + Avg_FR + (1|Group.ID), data = global_data)
mg4_dens=lmer(dens ~ FoodType.x + Treatment.x * GroupSize.1.x + Avg_FR + (1|Group.ID), data = global_data)
mg5_dens=lmer(dens ~ FoodType.x * GroupSize.1.x + Treatment.x + Avg_FR + (1|Group.ID), data = global_data)

compare_performance(mg1_dens,mg2_dens,mg3_dens,mg4_dens, mg5_dens)

# results for best fitting model based on AIC:
windows()
check_model(mg2_dens)
Anova(mg2_dens) 

################ 
# Number of clusters: 
# model selection:
mg1_cn=lmer(modul_cwt_num.x ~ FoodType.x * Treatment.x * GroupSize.1.x + Avg_FR +(1|Group.ID), data = global_data)
mg2_cn=lmer(modul_cwt_num.x ~ FoodType.x + Treatment.x + GroupSize.1.x + Avg_FR + (1|Group.ID), data = global_data)
mg3_cn=lmer(modul_cwt_num.x ~ FoodType.x * Treatment.x + GroupSize.1.x + Avg_FR + (1|Group.ID), data = global_data)
mg4_cn=lmer(modul_cwt_num.x ~ FoodType.x + Treatment.x * GroupSize.1.x + Avg_FR + (1|Group.ID), data = global_data)
mg5_cn=lmer(modul_cwt_num.x ~ FoodType.x * GroupSize.1.x + Treatment.x + Avg_FR + (1|Group.ID), data = global_data)

compare_performance(mg1_cn, mg2_cn, mg3_cn, mg4_cn,mg5_cn)

# results for best fitting model based on AIC:
check_model(mg2_cn)
Anova(mg2_cn)


# Figure 2:
windows()

plot(global_data$GroupSize.1.x , jitter(global_data$modul_cwt_num.x),cex.lab=1.75, cex.axis = 1.6, cex.main = 2, pch=16,
     ylab="Number of clusters", xlab = "Group size", las=1)
abline(lm(global_data$modul_cwt_num.x~global_data$GroupSize.1.x), lwd=2)


########################
## Individual level analysis
##################
##################
# Degree:
# model selection:
mi1_deg=lmer(IndividualDegree ~ FoodType.x * Treatment.x * NumberWorkers + (1|Avg_FR) + (1|ColonyID)+ (1|IndividualID), data = ind_data)
mi2_deg=lmer(IndividualDegree ~ FoodType.x + Treatment.x + NumberWorkers + (1|Avg_FR) + (1|ColonyID)+ (1|IndividualID), data = ind_data)
mi3_deg=lmer(IndividualDegree ~ FoodType.x * Treatment.x + NumberWorkers + (1|Avg_FR) + (1|ColonyID)+ (1|IndividualID), data = ind_data)
mi4_deg=lmer(IndividualDegree ~ FoodType.x + Treatment.x * NumberWorkers + (1|Avg_FR) + (1|ColonyID)+ (1|IndividualID), data = ind_data)
mi5_deg=lmer(IndividualDegree ~ FoodType.x  * NumberWorkers + Treatment.x + (1|Avg_FR) + (1|ColonyID)+ (1|IndividualID), data = ind_data)

compare_performance(mi1_deg,mi2_deg,mi3_deg,mi4_deg, mi5_deg) 

# results for best fitting model based on AIC:
check_model(mi3_deg)
Anova(mi3_deg)


# post hoc comparisons:
emmeans(mi3_deg, list(pairwise ~ c(FoodType.x,Treatment.x)), adjust = "tukey")

#  only difference in the interaction is between limited and unlimited for carbs
# C B - C T   -2.072 0.572 409.8  -3.623  0.0019

# Figure 3 
ind_data$group <- factor(paste(ind_data$Treatment.x, ind_data$FoodType.x, sep = "_"))
legend_order <- c("B_C", "T_C", "B_P", "T_P" )

windows() # open new window for plot
plt = ggplot(data = ind_data, aes(x = NumberWorkers, y = IndividualDegree, color = group, group = group)) # sets up the plot
plt + geom_point(size =2,alpha = 0.3,position = position_jitter(width = 0.2, height = 0.2)) +  # draw the points
  geom_smooth(aes(x = NumberWorkers, y = IndividualDegree, group = group, fill = group), method = 'lm') +  # draws the line and shaded error 
  scale_color_manual(values = c("T_P" = 'orange', "B_P" = 'orangered4', "T_C" = 'violet', "B_C" = 'purple4'), 
                     labels = c("T_P" ='Protein - limited',"B_P" = 'Protein - unlimited' ,"T_C" ='Carbohydrate - limited', "B_C" ='Carbohydrate - unlimited'),
                     name = "Food type and Availability",
                     breaks = legend_order) +
  scale_fill_manual(values = c("T_P" = 'orange', "B_P" = 'orangered4', "T_C" = 'violet', "B_C" = 'purple4'), 
                    labels = c("T_P" = 'Protein - limited',"B_P" = 'Protein - unlimited' ,"T_C" ='Carbohydrate - limited', "B_C" = 'Carbohydrate - unlimited'),
                    name = "Food type and Availability",
                    breaks = legend_order) +   # changes the color of the shading
  labs(x ="Group size", y = "Number of indiviudals one interacts with  (degree)") + # changes the text on the label - can also add to this row changes to the main titles if we want
  theme_mine()   # sets the theme to look nice - without grey background and grid 


#################
# Betweenness:
# need to get rid of zero values for model fit to work
ind_data$IndividualBetweenness[ind_data$IndividualBetweenness==0] = 0.00001

# model selection:
mi1_bet=glmer(IndividualBetweenness ~ FoodType.x * Treatment.x * NumberWorkers + (1|Avg_FR) + (1|ColonyID)+ (1|IndividualID), data = ind_data, family=Gamma(link = "log"))
mi2_bet=glmer(IndividualBetweenness ~ FoodType.x + Treatment.x + NumberWorkers + (1|Avg_FR) + (1|ColonyID)+ (1|IndividualID), data = ind_data, family=Gamma(link = "log"))
mi3_bet=glmer(IndividualBetweenness ~ FoodType.x * Treatment.x + NumberWorkers + (1|Avg_FR) + (1|ColonyID)+ (1|IndividualID), data = ind_data, family=Gamma(link = "log"))
mi4_bet=glmer(IndividualBetweenness ~ FoodType.x + Treatment.x * NumberWorkers + (1|Avg_FR) + (1|ColonyID)+ (1|IndividualID), data = ind_data, family=Gamma(link = "log"))
mi5_bet=glmer(IndividualBetweenness ~ FoodType.x * NumberWorkers + Treatment.x + (1|Avg_FR) + (1|ColonyID)+ (1|IndividualID), data = ind_data, family=Gamma(link = "log"))

compare_performance(mi1_bet,mi2_bet,mi3_bet,mi4_bet,mi5_bet) # 2 is best fit

# results for best fitting model based on AIC:
check_model(mi2_bet)
Anova(mi2_bet)

# Figure 4:
windows()
plot(ind_data$NumberWorkers, ind_data$IndividualBetweenness,cex.lab=1.5, cex.axis = 1.6, cex.main = 2, pch=16,
     ylab="Betweenness", xlab = "Group size", las=1)
abline(lm(ind_data$IndividualBetweenness~ind_data$NumberWorkers), lwd=2)


##################
### activity 
##################
# distance moved
# model selection:

mi1_dst=lmer(SumDistance   ~ FoodType.x * Treatment.x * NumberWorkers + (1|Avg_FR) + (1|ColonyID)+ (1|IndividualID), data = ind_data)
mi2_dst=lmer(SumDistance   ~ FoodType.x + Treatment.x + NumberWorkers + (1|Avg_FR) + (1|ColonyID)+ (1|IndividualID), data = ind_data)
mi3_dst=lmer(SumDistance   ~ FoodType.x * Treatment.x + NumberWorkers + (1|Avg_FR) + (1|ColonyID)+ (1|IndividualID), data = ind_data)
mi4_dst=lmer(SumDistance   ~ FoodType.x + Treatment.x * NumberWorkers + (1|Avg_FR) + (1|ColonyID)+ (1|IndividualID), data = ind_data)
mi5_dst=lmer(SumDistance   ~ FoodType.x * NumberWorkers + Treatment.x + (1|Avg_FR) + (1|ColonyID)+ (1|IndividualID), data = ind_data)

compare_performance(mi1_dst,mi2_dst,mi3_dst,mi4_dst,mi5_dst) # 2 is best fit

check_model(mi2_dst)
Anova(mi2_dst)


## Figure 5:
windows()
plot(as.factor(ind_data$Treatment.x), ind_data$SumDistance/1000, cex.lab=1.5, cex.axis = 1.2, cex.main = 2, pch=16,
     ylab="Total distance moved (1000 pixels)", xlab = "Food Avaliability", las=1, names = c("Unlimited", "Limited"), 
     col = c('grey15','grey85'), border = c('grey30', 'black'))


########################
### supplementary figures and analysis:
# Figure S2
cor.test(global_data$GroupSize.1.x,global_data$n_node.x)

windows()
plot(global_data$GroupSize.1.x,global_data$n_node.x,
     ylab='Network size (number of nodes)', xlab="Group size (number of ants)", 
     pch =16, col='blue',las=1, cex.axes = 1.75, cex.lab=1.75,
     ylim= c(0,30), xlim = c(0,30))
abline(c(0,0), c(1,1), lty=2, lwd=2)
abline(lm(global_data$n_node.x~global_data$GroupSize.1.x), col="red", lwd=2)


## number of participants in the interaction network:
m1=lmer(n_node.x/GroupSize.1.x ~ FoodType.x * Treatment.x + (1|Group.ID), data = global_data)
m2=lmer(n_node.x/GroupSize.1.x ~ FoodType.x + Treatment.x + (1|Group.ID), data = global_data)

compare_performance(m1,m2)

# results for best fitting model based on AIC:
Anova(m1)

# Figure S3
y1 = global_data$n_node.x[global_data$FoodType.x=='C']/global_data$GroupSize.1.x[global_data$FoodType.x=='C']
x1 = global_data$Treatment.x[global_data$FoodType.x=='C']

y2 = global_data$n_node.x[global_data$FoodType.x=='P']/global_data$GroupSize.1.x[global_data$FoodType.x=='P']
x2 = global_data$Treatment.x[global_data$FoodType.x=='P']

windows()
par(mfrow=c(1,2))
par(mar = c(5.1, 6.2, 4.1, 2.1))
plot(y1~as.factor(x1),
     las=1, ylim=c(0,1), col=c('purple4', 'violet'), main='(A) Carbohydrates', cex.axes = 1.75, cex.lab=1.3, cex.main=2,
     xlab='Food availability', ylab = 'Proportion of ants participating in interaction network \n (number of nodes/group size)',
     names = c('Unlimited', 'Limited'))
plot(y2~as.factor(x2),
     las=1, ylim=c(0,1), col=c('orangered4', 'orange'), main='(B) Protein', cex.axes = 1.75, cex.lab=1.3, cex.main=2,
     xlab='Food availability', ylab = 'Proportion of ants participating in interaction network \n (number of nodes/group size)',
     names = c('Unlimited', 'Limited'))

########
## a linear fit to group size works best, so there are no effects of group size 'above and beyond' random expectation 
global_data$GroupSize.1.x_squared <- global_data$GroupSize.1.x^2
mg2_cn_poly=lmer(modul_cwt_num.x ~ FoodType.x + Treatment.x + (GroupSize.1.x) + GroupSize.1.x_squared + Avg_FR + (1|Group.ID), data = global_data)
Anova(mg2_cn_poly)
compare_performance(mg2_cn_poly,mg2_cn)

ind_data$NumberWorkers_squared <- ind_data$NumberWorkers^2
mi3_deg_poly=lmer(IndividualDegree ~ FoodType.x * Treatment.x + NumberWorkers + NumberWorkers_squared +(1|Avg_FR) + (1|ColonyID)+ (1|IndividualID), data = ind_data)
Anova(mi3_deg_poly)
compare_performance(mi3_deg_poly,mi3_deg)

mi2_bet_poly=glmer(IndividualBetweenness ~ FoodType.x + Treatment.x + NumberWorkers + NumberWorkers_squared + (1|Avg_FR) + (1|ColonyID)+ (1|IndividualID), data = ind_data, family=Gamma(link = "log"))
Anova(mi2_bet_poly)
compare_performance(mi2_bet_poly,mi2_bet)








###################
### response to reviewers:
###################

###################
### look at potential bias of treatments to old (changing) distance threshold assignment  
###############

# food type does not differ in threshold:
t.test(merged_global_data$DistanceThreshold.pix.[merged_global_data$FoodType.y == "C"],merged_global_data$DistanceThreshold.pix.[merged_global_data$FoodType.y == "P"])

# food avaliability does not differ in threshold:
t.test(merged_global_data$DistanceThreshold.pix.[merged_global_data$Treatment.y == "B"],merged_global_data$DistanceThreshold.pix.[merged_global_data$Treatment.y == "T"])

# group size does not differ in threshold:
cor.test(merged_global_data$DistanceThreshold.pix., merged_global_data$GroupSize.1.y)

#############
## treatments are not biased to one threshold or the other
#############

###################
### look at effect of old (changing) distance threshold on network measures
##################

cor.test(merged_global_data$modul_cwt_num.y, merged_global_data$DistanceThreshold.pix.)
cor.test(merged_global_data$Density, merged_global_data$DistanceThreshold.pix.)
cor.test(merged_global_data$avg_deg,merged_global_data$DistanceThreshold.pix.)
cor.test(merged_global_data$Betweenness,merged_global_data$DistanceThreshold.pix.)

windows()
par(mfrow=c(2,2))
plot(merged_global_data$modul_cwt_num.y, merged_global_data$DistanceThreshold.pix., ylab="Distance threshold", xlab = "Number of clusters")
abline(lm(merged_global_data$DistanceThreshold.pix.~merged_global_data$modul_cwt_num.y))
plot(merged_global_data$Density, merged_global_data$DistanceThreshold.pix., ylab="Distance threshold", xlab = "Network density")
abline(lm(merged_global_data$DistanceThreshold.pix.~merged_global_data$Density))
plot(merged_global_data$avg_deg,merged_global_data$DistanceThreshold.pix., ylab="Distance threshold", xlab = "Average degree")
abline(lm(merged_global_data$DistanceThreshold.pix.~merged_global_data$avg_deg))
plot(merged_global_data$Betweenness,merged_global_data$DistanceThreshold.pix., ylab="Distance threshold", xlab = "Betweenness")
abline(lm(merged_global_data$DistanceThreshold.pix.~merged_global_data$Betweenness))

