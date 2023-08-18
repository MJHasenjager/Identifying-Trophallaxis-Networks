This folder contains 7 analytic tools for tracking ants movement and interactions, and the data outputs from those analytic tools are furhter utilized for the manuscript “Social interactions are impacted by food availability, food type, and group size”.

These 7 matlab scripts should be run in the folder of BeeTag (https://figshare.com/articles/dataset/_BEEtag_A_Low_Cost_Image_Based_Tracking_System_for_the_Study_of_Animal_Behavior_and_Locomotion_/1534065).  

The matlab script ‘Tracking’ traverses all thresholds in a range pre-defined to maximize the detection rate of Beetags. The output of this script is saved and subsequently utilized for further analyses.

The matlab script 'AddlabelSpeed' labels four corners of each tag in a sequence of numbers from 1 to 4, and sort those labels based on their relative distance with the center of the tag. Labels will be used for further analyses, e.g. calibration of heading direction for each ant on each frame. Meanwhile, speed of ant at each frame is added into the output of "tracking.m" as well.

network measures at the individual level based on the networks extracted from the 'network data.' It calculates 'betweenness' and 'degree' for each node in the networks, alongside additional information such as group size, conditions, and the date of data collection. The output of this script is saved and subsequently is added utilized in the 'Data_analysis_and_plots_for_paper_final' script for further analysis and visualization.

 The matlab script 'AddlabelSpeed' – information on the treatment (limited or unlimited food, carbohydrate or protein food, and group size) for each group in the experiment. 

‘GlobalMeasureNetworks_final.csv’ global network measures extracted using the script ‘calculate_global_network_measures’

‘IndividualMeasureNetwroks.csv’ individual level network measures extracted when creating the networks in the network data folder – see image analysis folder in parent folder.

The script “Data_analysis_and_plots_for_paper_final” contains all the statistical analysis for the manuscript, as well as the plotting of the data figures in the manuscript. This script requires the two files ‘GlobalMeasureNetworks_final.csv’ and ‘IndividualMeasureNetworks.csv’


