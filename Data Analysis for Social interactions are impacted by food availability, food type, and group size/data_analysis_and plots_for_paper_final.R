## this script takes network measures calculated in other scripts and runs statistical analysis and plotting
# initilise workspace
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
# load data
global_data = read.csv('GlobalMeasureNetworks_final.csv')
ind_data = read.csv('IndividualMeasureNetworks.csv')

# convert certain variables to factors:
global_data$FoodType=as.factor(global_data$FoodType)
global_data$Treatment = as.factor(global_data$Treatment)
global_data$GroupSize = as.factor(global_data$GroupSize)
global_data$Group.ID = as.factor(global_data$Group.ID)

ind_data$FoodType=as.factor(ind_data$FoodType)
ind_data$Treatment = as.factor(ind_data$Treatment)
ind_data$GroupSize = as.factor(ind_data$GroupSize)
ind_data$Group.ID = as.factor(ind_data$Group.ID)
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

theme_mine2 <- function(base_size = 18, base_family = "Helvetica") {
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
      axis.line.y = element_line(color="black", size = 1),
      legend.position = c(0.2, 0.8)
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
mg1_dens=lmer(Density ~ FoodType * Treatment * GroupSize.1 + (1|Group.ID), data = global_data)
mg2_dens=lmer(Density ~ FoodType + Treatment + GroupSize.1 + (1|Group.ID), data = global_data)
mg3_dens=lmer(Density ~ FoodType * Treatment + GroupSize.1 + (1|Group.ID), data = global_data)
mg4_dens=lmer(Density ~ FoodType + Treatment * GroupSize.1 + (1|Group.ID), data = global_data)
mg5_dens=lmer(Density ~ FoodType * GroupSize.1 + Treatment + (1|Group.ID), data = global_data)

compare_performance(mg1_dens,mg2_dens,mg3_dens,mg4_dens, mg5_dens)

# results for best fitting model based on AIC:
check_model(mg2_dens)
Anova(mg2_dens)

################ 
# Number of clusters: 
# model selection:
mg1_cn=lmer(modul_cwt_num ~ FoodType * Treatment * GroupSize.1 + (1|Group.ID), data = global_data)
mg2_cn=lmer(modul_cwt_num ~ FoodType + Treatment + GroupSize.1 + (1|Group.ID), data = global_data)
mg3_cn=lmer(modul_cwt_num ~ FoodType * Treatment + GroupSize.1 + (1|Group.ID), data = global_data)
mg4_cn=lmer(modul_cwt_num ~ FoodType + Treatment * GroupSize.1 + (1|Group.ID), data = global_data)
mg5_cn=lmer(modul_cwt_num ~ FoodType * GroupSize.1 + Treatment + (1|Group.ID), data = global_data)

compare_performance(mg1_cn, mg2_cn, mg3_cn, mg4_cn,mg5_cn)

# results for best fitting model based on AIC:
check_model(mg2_cn)
Anova(mg2_cn)

# Figure 2:
windows()
par(mfrow=c(1,3))

plot(global_data$GroupSize.1 , jitter(global_data$modul_cwt_num),cex.lab=1.75, cex.axis = 1.6, cex.main = 2, pch=16,
     ylab="Number of clusters", xlab = "Group size",  main = "(A) Group size", las=1)
abline(lm(global_data$modul_cwt_num~global_data$GroupSize.1), lwd=2)

plot(global_data$FoodType , global_data$modul_cwt_num, cex.lab=1.75, cex.axis = 1.6, cex.main = 2,
     names=c('Carbohydrates', 'Protein'),
     ylab="Number of clusters", xlab = "Food Type",  main = "(B) Food Type", las=1,col=c('purple', 'orange'))

plot(global_data$Treatment , global_data$modul_cwt_num, cex.lab=1.75, cex.axis = 1.6,cex.main = 2,
     names = c('Unlimited', 'Limited'),     
     ylab="Number of clusters", xlab = "Food availability",  main = "(C) Food availability", las=1,col=c('black', 'grey'))


########################
## Individual level analysis:
##################
##################
# Degree:
# model selection:
mi1_deg=lmer(IndividualDegree ~ FoodType * Treatment * NumberWorkers + (1|Group.ID)+ (1|IndividualID), data = ind_data)
mi2_deg=lmer(IndividualDegree ~ FoodType + Treatment + NumberWorkers + (1|Group.ID)+ (1|IndividualID), data = ind_data)
mi3_deg=lmer(IndividualDegree ~ FoodType * Treatment + NumberWorkers + (1|Group.ID)+ (1|IndividualID), data = ind_data)
mi4_deg=lmer(IndividualDegree ~ FoodType + Treatment * NumberWorkers + (1|Group.ID)+ (1|IndividualID), data = ind_data)
mi5_deg=lmer(IndividualDegree ~ FoodType  * NumberWorkers + Treatment + (1|Group.ID)+ (1|IndividualID), data = ind_data)

compare_performance(mi1_deg,mi2_deg,mi3_deg,mi4_deg, mi5_deg) 

# results for best fitting model based on AIC:
check_model(mi1_deg)
Anova(mi1_deg)

# posthoc comparisons:
emmeans(mi1_deg, list(pairwise ~ c(FoodType,NumberWorkers)), adjust = "tukey")
emmeans(mi1_deg, list(pairwise ~ c(Treatment,NumberWorkers)), adjust = "tukey")
emmeans(mi1_deg, list(pairwise ~ c(FoodType,Treatment)), adjust = "tukey")
emmeans(mi1_deg, list(pairwise ~ c(FoodType,Treatment,NumberWorkers)), adjust = "tukey")

# Figure 3 
ind_data$group <- factor(paste(ind_data$Treatment, ind_data$FoodType, sep = "_"))
legend_order <- c("B_C", "T_C", "B_P", "T_P" )

windows() # open new window for plot
plt = ggplot(data = ind_data, aes(x = NumberWorkers, y = IndividualDegree, color = group, group = group)) # sets up the plot
plt + geom_point(size =2,alpha = 0.3,position = position_jitter(width = 0.2, height = 0.2)) +  # draw the points
  geom_smooth(aes(x = NumberWorkers, y = IndividualDegree, group = group, fill = group), method = 'lm') +  # draws the line and shaded error 
  scale_color_manual(values = c("T_P" = 'orange1', "B_P" = 'orange4', "T_C" = 'purple1', "B_C" = 'purple4'), 
                     labels = c("T_P" ='Protein - limited',"B_P" = 'Protein - unlimited' ,"T_C" ='Carbohydrate - limited', "B_C" ='Carbohydrate - unlimited'),
                     name = "Food type and Availability",
                     breaks = legend_order) +
  scale_fill_manual(values = c("T_P" = 'orange1', "B_P" = 'orange4', "T_C" = 'purple1', "B_C" = 'purple4'), 
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
mi1_bet=glmer(IndividualBetweenness ~ FoodType * Treatment * NumberWorkers + (1|Group.ID)+ (1|IndividualID), data = ind_data, family=Gamma(link = "log"))
mi2_bet=glmer(IndividualBetweenness ~ FoodType + Treatment + NumberWorkers + (1|Group.ID)+ (1|IndividualID), data = ind_data, family=Gamma(link = "log"))
mi3_bet=glmer(IndividualBetweenness ~ FoodType * Treatment + NumberWorkers + (1|Group.ID)+ (1|IndividualID), data = ind_data, family=Gamma(link = "log"))
mi4_bet=glmer(IndividualBetweenness ~ FoodType + Treatment * NumberWorkers + (1|Group.ID)+ (1|IndividualID), data = ind_data, family=Gamma(link = "log"))
mi5_bet=glmer(IndividualBetweenness ~ FoodType * NumberWorkers + Treatment + (1|Group.ID)+ (1|IndividualID), data = ind_data, family=Gamma(link = "log"))

compare_performance(mi1_bet,mi2_bet,mi3_bet,mi4_bet,mi5_bet) # 1 is best fit

# results for best fitting model based on AIC:
check_model(mi1_bet)
Anova(mi1_bet)

# posthoc comparisons:
emmeans(mi1_bet, list(pairwise ~ c(FoodType,Treatment)), adjust = "tukey")
emmeans(mi1_bet, list(pairwise ~ c(Treatment,NumberWorkers)), adjust = "tukey")

# Figure 4:
windows()
par(mfrow=c(1,3))
plot(ind_data$IndividualBetweenness~ind_data$Treatment,
     las=1, ylim=c(0,60), col=c('black','grey'), main='(A) Food avaliability - all',  names = c('Unlimited', 'Limited'),cex.lab=1.6,cex.axis =1.2,cex.main = 2,
     xlab='Food availability', ylab = 'Betweeness', border = c('grey30', 'black'))

plot(ind_data$IndividualBetweenness[ind_data$FoodType=='C']~ind_data$Treatment[ind_data$FoodType=='C'],
     las=1, ylim=c(0,60), col=c('purple4', 'purple1'), main='(B) Carbohydrates', names = c('Unlimited', 'Limited'),cex.lab=1.6,cex.axis =1.2,cex.main = 2,
     xlab='Food availability', ylab = 'Betweeness')


plot(ind_data$IndividualBetweenness[ind_data$FoodType=='P']~ind_data$Treatment[ind_data$FoodType=='P'],
     las=1, ylim=c(0,60), col=c('orange4', 'orange1'), main='(C) Protein',  names = c('Unlimited', 'Limited'),cex.lab=1.6,cex.axis =1.2,cex.main = 2,
     xlab='Food availability', ylab = 'Betweeness')


# Figure 5:
windows() # open new window for plot
plt = ggplot(data = ind_data, aes(x = NumberWorkers, y = IndividualBetweenness, color = Treatment)) # sets up the plot
plt + geom_point(size =2,alpha = 0.5,position = position_jitter(width = 0.2, height = 0.2)) +  # draw the points
  geom_smooth(aes(x = NumberWorkers, y = IndividualBetweenness, group = Treatment, fill = Treatment), method = 'lm') +  # draws the line and shaded error 
  scale_color_manual(values = c("T" = 'grey45', "B" = 'black'), 
                     labels = c("T" ='Limited food',"B" = 'Unlimited food'),
                     name = "Treatment")+
  scale_fill_manual(values = c("T" = 'grey45', "B" = 'black'), 
                    labels = c("T" ='Limited food',"B" = 'Unlimited food'),
                    name = "Treatment") +   # changes the color of the shading
  ggtitle("Food availability and group size") +
  labs(x ="Group size", y = "Betweeness") + # changes the text on the label - can also add to this row changes to the main titles 
  theme_mine2()   # sets the theme to look nice - without grey background and grid 



########################
### supplementary figures:
# Figure S1
cor.test(global_data$GroupSize.1,global_data$n_node)

windows()
plot(global_data$GroupSize.1,global_data$n_node,
     ylab='Network size (number of nodes)', xlab="Group size (number of ants)", 
     pch =16, col='blue',las=1, cex.axes = 1.75, cex.lab=1.75,
     ylim= c(0,30), xlim = c(0,30))
abline(c(0,0), c(1,1), lty=2, lwd=2)
abline(lm(global_data$n_node~global_data$GroupSize.1), col="red", lwd=2)


## number of participants in the interaction network:
m1=lmer(n_node/GroupSize.1 ~ FoodType * Treatment + (1|Group.ID), data = global_data)
m2=lmer(n_node/GroupSize.1 ~ FoodType + Treatment + (1|Group.ID), data = global_data)

compare_performance(m1,m2)

# results for best fitting model based on AIC:
Anova(m1)

# Figure S2
windows()
par(mfrow=c(1,2))
par(mar = c(5.1, 6.2, 4.1, 2.1))
plot(global_data$n_node[global_data$FoodType=='C']/global_data$GroupSize.1[global_data$FoodType=='C']~global_data$Treatment[global_data$FoodType=='C'],
     las=1, ylim=c(0,1), col=c('purple4', 'purple1'), main='(A) Carbohydrates', cex.axes = 1.75, cex.lab=1.3, cex.main=2,
     xlab='Food availability', ylab = 'Proportion of ants participating in interaction network \n (number of nodes/group size)',
     names = c('Unlimited', 'Limited'))
plot(global_data$n_node[global_data$FoodType=='P']/global_data$GroupSize.1[global_data$FoodType=='P']~global_data$Treatment[global_data$FoodType=='P'],
     las=1, ylim=c(0,1), col=c('orange4', 'orange1'), main='(B) Protein', cex.axes = 1.75, cex.lab=1.3, cex.main=2,
     xlab='Food availability', ylab = 'Proportion of ants participating in interaction network \n (number of nodes/group size)',
     names = c('Unlimited', 'Limited'))


