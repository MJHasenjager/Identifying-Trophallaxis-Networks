clc;    % Clear the command window.
fprintf('Beginning to run %s.m ...\n', mfilename);
close all;  % Close all figures (except those of imtool.)
imtool close all;  % Close all imtool figures.
clear;  % Erase all existing variables.
workspace;  % Make sure the workspace panel is showing
datafile1=('Z:\Images\DESKTOP-M33S9D8\D\2-8-1\ImageAnt\'); %Define the directory
startframe = 21;
endframe = 100;
calibration= readtable([datafile1,'Trackinganalysis\Calibration.csv']); %Load calibration 
IDIDID = calibration(1:end,3);
Len = size(calibration(1:end,3),1); % Extract the length of individual IDs in calibration.csv

ContactThreshold=readtable([datafile1,'\Trackinganalysis\TrophallaxisApproximation.csv']); %Load csv for spatial proximity estimation
ContactThreshold=max(ContactThreshold.Distance); %Estimate the spatial proximity 

datafinalization=array2table(zeros(1,6)); %Create a table for interactions identified
datafinalization.Properties.VariableNames = {'ID1','ID2','locX','locY','time','Interpolation'};%Name the columns
AntTrackAggregate =readtable([datafile1,'Trackinganalysis\AntTrackAggregateUpdated.csv']);%Load raw data with ID, Loc of centroid of tag, Loc of front point of tag, Loc of corners of tag, Order of corners, # Frame, Speed

for ii = (startframe+1):1:endframe 
    
  if rem(ii-1,5)==0 % Focus on frames just under the single-spectrume LED light (5 frames under the full spectrume : 1 frame under the single spectrume)
    ii
  if isempty(AntTrackAggregate(AntTrackAggregate.Var18==ii,:)) == 0 % If there is a missing frame, do interplations for each individual ants based on their Loc at frames before and after the missing frame before and after.  
     dataD = AntTrackAggregate(AntTrackAggregate.Var18==ii,:);
 
     dataD.Properties.VariableNames = {'x_cor' 'y_cor' 'number' 'frontX' 'frontY' 'corners1' 'corners2' 'corners3' 'corners4' 'corners5' 'corners6' 'corners7' 'corners8' 'order1' 'order2' 'order3' 'order4' 'frame' 'speed'} ; 
     dataD.Interpolate = zeros(size(dataD,1),1);
     dataD1=dataD((dataD.number == table2array(IDIDID(1,1))),:);
for ixix = 1:1:Len
    datax = dataD((dataD.number == table2array(IDIDID(ixix,1))),:);
    dataD1 = vertcat(dataD1,datax);
    %dataDDDxx=zeros(1,size(dataD,2))
        if isempty(datax) == 1 && ii > startframe + 10 % Interpolate based on 10 frames before and after the missing frame
            for mmx = 10:-1:1 % Find the closest before-frame
            mmmx = ii - mmx;
            if isempty(AntTrackAggregate(AntTrackAggregate.Var18==mmmx,:)) == 0
            dataDDD = AntTrackAggregate(AntTrackAggregate.Var18==mmmx,:);
            dataDDD.Properties.VariableNames = {'x_cor' 'y_cor' 'number' 'frontX' 'frontY' 'corners1' 'corners2' 'corners3' 'corners4' 'corners5' 'corners6' 'corners7' 'corners8' 'order1' 'order2' 'order3' 'order4' 'frame' 'speed'};  
            dataDDD.Interpolate = ones(size(dataDDD,1),1);
            dataDDDx = dataDDD((dataDDD.number == table2array(IDIDID(ixix,1))),:);
            if exist('dataDDDx','var')==1  && isempty(dataDDDx) == 0              
                dataDDDxx = dataDDDx ;
            else
                dataDDDxx = array2table([]);
            end 
            end  
            end
        
        for mmx = 10:-1:1 % Find the closest after-frame
            mmmx = ii + mmx;
            if isempty(AntTrackAggregate(AntTrackAggregate.Var18==mmmx,:)) == 0
            dataDDD = AntTrackAggregate(AntTrackAggregate.Var18==mmmx,:);
            dataDDD.Properties.VariableNames = {'x_cor' 'y_cor' 'number' 'frontX' 'frontY' 'corners1' 'corners2' 'corners3' 'corners4' 'corners5' 'corners6' 'corners7' 'corners8' 'order1' 'order2' 'order3' 'order4' 'frame' 'speed'}  ;
            dataDDD.Interpolate = ones(size(dataDDD,1),1);
            dataDDDx = dataDDD((dataDDD.number == table2array(IDIDID(ixix,1))),:);
            if exist('dataDDDx','var')==1 && isempty(dataDDDx) == 0                
                dataDDDxxx = dataDDDx ;
                else
                dataDDDxxx = array2table([]);
            end 
            end  
        end  
            
         if exist('dataDDDxx','var')==1 && isempty(dataDDDxx) == 0 && exist('dataDDDxxx','var')==1 && isempty(dataDDDxxx) == 0  % Interpolate if the frame before and after the missing frame exist           
             points = [table2array(dataDDDxx(1,1)) table2array(dataDDDxx(1,2));table2array(dataDDDxxx(1,1)) table2array(dataDDDxxx(1,2))];
             Dist=pdist(points,'euclidean')  ;           
             if  Dist < 55  % If the ant doesn't move over 55 pixels between before- and after-frame, create a fabricate record including Loc of centroid of tag, Loc of front point of tag, Loc of corners of tag, Order of corners of tag, # Frame, and Speed 
             dataDDDxxxx = dataDDDxx       ;      
             dataDDDxxxx(1,1)= array2table((table2array(dataDDDxx(1,1))+table2array(dataDDDxxx(1,1)))/2);
             dataDDDxxxx(1,2)= array2table((table2array(dataDDDxx(1,2))+table2array(dataDDDxxx(1,2)))/2);
             dataDDDxxxx(1,3)= dataDDDxx(1,3);
             dataDDDxxxx(1,4)=array2table((table2array(dataDDDxx(1,4))+table2array(dataDDDxxx(1,4)))/2);
             dataDDDxxxx(1,5)=array2table((table2array(dataDDDxx(1,5))+table2array(dataDDDxxx(1,5)))/2);
             dataDDDxxxx(1,6)=array2table((table2array(dataDDDxx(1,6))+table2array(dataDDDxxx(1,6)))/2);
             dataDDDxxxx(1,7)=array2table((table2array(dataDDDxx(1,7))+table2array(dataDDDxxx(1,7)))/2);
             dataDDDxxxx(1,8)=array2table((table2array(dataDDDxx(1,8))+table2array(dataDDDxxx(1,8)))/2);
             dataDDDxxxx(1,9)=array2table((table2array(dataDDDxx(1,9))+table2array(dataDDDxxx(1,9)))/2);
             dataDDDxxxx(1,10)=array2table((table2array(dataDDDxx(1,10))+table2array(dataDDDxxx(1,10)))/2);
             dataDDDxxxx(1,12)=array2table((table2array(dataDDDxx(1,12))+table2array(dataDDDxxx(1,12)))/2);
             dataDDDxxxx(1,13)=array2table((table2array(dataDDDxx(1,13))+table2array(dataDDDxxx(1,13)))/2);
             dataDDDxxxx(1,14)=dataDDDxx(1,14);
             dataDDDxxxx(1,15)=dataDDDxx(1,15);
             dataDDDxxxx(1,16)=dataDDDxx(1,16);
             dataDDDxxxx(1,17)=dataDDDxx(1,17);             
             if exist('dataDDDxxxx','var')== 1 && isempty(dataDDDxxxx) == 0
               dataD1 = vertcat(dataD1,dataDDDxxxx);
             end  
             end
         end
         end
                  
end      
  end

if isempty(dataD1)== 0 % If the frabricated frame exsists, Create a table to store Loc of head of ants.
 dataD1(1,:)=[];
 n=size(dataD1);
 n=n(1);
 A = rand(n,1);
 A(1:n) = ii;
 T = array2table(A);
 %L = array2table(zeros(n,1));
 M = array2table(zeros(n,1));
 N = array2table(zeros(n,1));
 %InTer = array2table(zeros(n,1));
 T.Properties.VariableNames = {'time'};
 %L.Properties.VariableNames = {'light'};
 M.Properties.VariableNames = {'HeadX'};
 N.Properties.VariableNames = {'HeadY'};
 %InTer.Properties.VariableNames = {'interpolation'}
 dataD1 = [dataD1 T M N] ;
 datadissection = dataD1; 
end
%%%Add head corrdinates by using the information in calibration.csv

    for jj = 1:1:size(datadissection,1)        
    XXxx = datadissection.x_cor(jj);
    YYyy = datadissection.y_cor(jj)  ;   
    box=[datadissection.order3(jj),datadissection.order4(jj)]; % the orders are only valid for 4 cases: 1,2,3,4 or 2,3,4,1 or 3,4,1,2 or 4,1,2,3
           if any(box == 1) && any(box == 4)  % Locate the upper left corner of tag if it is the case 4,1,2,3.
            XXxx1 = datadissection.corners2(jj);
            YYyy1 = datadissection.corners1(jj);
           end    
           if any(box == 3) && any(box == 4)  % Locate the upper left corner of tag if it is the case 3,4,1,2.
            XXxx1 = datadissection.corners8(jj);
            YYyy1 = datadissection.corners7(jj);
           end
           if any(box == 1) && any(box == 2)  % Locate the upper left corner of tag if it is the case 1,2,3,4.
            XXxx1 = datadissection.corners4(jj);
            YYyy1 = datadissection.corners3(jj);
           end
           if any(box == 2) && any(box == 3)  % Locate the upper left corner of tag if it is the case 2,3,4,1.
            XXxx1 = datadissection.corners6(jj); 
            YYyy1 = datadissection.corners5(jj);
           end    
    XXxx2 = datadissection.frontX(jj); % load the Loc of front point of tag.
    YYyy2 = datadissection.frontY(jj); % load the Loc of front point of tag.
    IDindex=datadissection.number(jj); % load the ID of ant.
    distance4 = table2array(calibration(calibration.number == IDindex,25)); % load the distance between head and centroid of tag estimated in the calibration.csv.
    distance5 = table2array(calibration(calibration.number == IDindex,26)); % load the distance between head and the front point of tag estimated in the calibration.csv.
    distance6 = table2array(calibration(calibration.number == IDindex,27)); % load the distance between head and the upper left corner of tag estimated in the calibration.csv.
% Get coordinates of points on the circle (centroid of tag as the center of circle, distrance4 as the radius of circle).
Center(1)=XXxx;
Center(2)=YYyy;
Radius = distance4;
angles = linspace(0, 2*pi, 100);
x = cos(angles) * Radius + Center(1);
y = sin(angles) * Radius + Center(2);
% Get coordinates of points on the circle (front point of tag as the center of circle, distrance5 as the radius of circle).
Center(1)=XXxx2;
Center(2)=YYyy2;
Radius = distance5;
x2 = cos(angles) * Radius + Center(1);
y2 = sin(angles) * Radius + Center(2);    
% Get coordinates of points on the circle (upper left corner of tag as the center of circle, distrance6 as the radius of circle).
Center(1)=XXxx1;
Center(2)=YYyy1;
Radius = distance6;
x1 = cos(angles) * Radius + Center(1);
y1 = sin(angles) * Radius + Center(2);    

%Find the point on all of three circles above as the Loc of head of ants
[xi,yi]=polyxpoly(x1,y1,x,y);
[xii,yii]=polyxpoly(x2,y2,x1,y1);
[xiii,yiii]=polyxpoly(x2,y2,x,y);
if isempty(xi)== 1 && isempty(xii)== 1 && isempty(xiii) == 1
PP = [x; y]';
PQ = [x2; y2]';
[k,dist] = dsearchn(PP,PQ);
index=[k,dist];
index = index(index(:,2)==min(dist),:);
k = index(1,1);
a = [PP(k,1),PP(k,2)];
PP = [x; y]';
PQ = [x1; y1]';
[k,dist] = dsearchn(PP,PQ);
index=[k,dist];
index = index(index(:,2)==min(dist),:);
k = index(1,1);
a=[a;[PP(k,1),PP(k,2)]];
PP = [x1; y1]';
PQ = [x2; y2]';
[k,dist] = dsearchn(PP,PQ);
index=[k,dist];
index = index(index(:,2)==min(dist),:);
k = index(1,1);
a=[a;[PP(k,1),PP(k,2)]];
xhead = cortotal1(I_row,1);
yhead = cortotal1(I_row,2);
else
  cortotal1=[[xi,yi];[xii,yii];[xiii,yiii]];
  findsamepoint = zeros ([size(cortotal1,1) size(cortotal1,1)]);
 for imim = 1:size(cortotal1,1)
     cortotal2 = cortotal1;
     %cortotal2(imim,:)=[]
     compareX = cortotal1(imim,1);
     compareY = cortotal1(imim,2);
     for mimi = 1:size(cortotal2,1)
         compareXX = cortotal2(mimi,1);
         compareYY = cortotal2(mimi,2);
         findsamepoint(imim, mimi)=compareX-compareXX;
     end 
 end 
 findsamepoint(findsamepoint==0)=100;
 [M,I] = min(abs(findsamepoint(:)));
 [I_row, I_col] = ind2sub(size(findsamepoint),I);

xhead = cortotal1(I_row,1);
yhead = cortotal1(I_row,2);
end
% Get coordinates of the head of ants.
datadissection.HeadX(jj)= xhead;
datadissection.HeadY(jj)= yhead   ; 
    end
%Estimate the distance between each pair of ants and build adj matrix for
%network if the distance is less than spatial proximity defined above
datadissectionmiddle=table2array(datadissection);
dx = bsxfun(@minus, datadissectionmiddle(:,22), datadissectionmiddle(:,22)');
dy = bsxfun(@minus, datadissectionmiddle(:,23), datadissectionmiddle(:,23)');
realcontactmatrix = sqrt(dx.^2 + dy.^2);
realcontactmatrix = triu(realcontactmatrix);

realcontactmatrix(realcontactmatrix == 0 ) = 10000;
realcontactmatrix(realcontactmatrix <= ContactThreshold )=1; 
realcontactmatrix(realcontactmatrix > ContactThreshold)=0;
[row,col] = find(realcontactmatrix ==1); %Have the ID of ants that contact with her neighbors
IDrowcollist=[row,col];

ListID = datadissection.number;
datafinalization2=array2table(zeros(1,6));
datafinalization2.Properties.VariableNames = {'ID1','ID2','locX','locY','time','Interpolation'};
   
for jmx = 1:1:size(IDrowcollist,1) %Track back the speed of ants that contact with their neighbors
    
    if table2array(datadissection(datadissection.number==ListID(IDrowcollist(jmx,1)),19))< 5  %If the speed is less than 5 pixel/frame, consider the contact is a trophallaxis interaction.
        
    datafinalizationMiddle=array2table(zeros(1,6));
    datafinalizationMiddle.Properties.VariableNames = {'ID1','ID2','locX','locY','time','Interpolation'}; 
    
    
    datafinalizationMiddle.ID1 = ListID(IDrowcollist(jmx,1),1); %Have ID of ant1
    datafinalizationMiddle.ID2 = ListID(IDrowcollist(jmx,2),1); %Have ID of ant2
    datafinalizationMiddle.time = (ii-1)/5; %Have the # frame
    locationXID1=table2array(datadissection(datadissection.number==ListID(IDrowcollist(jmx,1)),22)); %Have locX of ant1
    locationYID1=table2array(datadissection(datadissection.number==ListID(IDrowcollist(jmx,1)),23)); %Have locY of ant1     
    locationXID2=table2array(datadissection(datadissection.number==ListID(IDrowcollist(jmx,2)),22)); %Have locX of ant2
    locationYID2=table2array(datadissection(datadissection.number==ListID(IDrowcollist(jmx,2)),23)); %Have locY of ant2    
    datafinalizationMiddle.locX = (locationXID1+locationXID2)/2; %Have x-cor of location where the interaction occurred
    datafinalizationMiddle.locY = (locationYID1+locationYID2)/2; %Have y-cor of location where the interaction occurred    
    datafinalization2 = vertcat(datafinalization2,datafinalizationMiddle); %Aggregate data over individuals 
    
    end
end

datafinalization2(1,:)=[];
IdforInterpolation = datadissection(datadissection.Interpolate == 1,3); %Mark Interpolation
if exist('IdforInterpolation','var') == 1 && isempty(IdforInterpolation) == 0    
    for xy = 1:1:size(IdforInterpolation,1)
        for yx = 1:1:(size(datafinalization2,1))
            if datafinalization2.ID1(yx) == IdforInterpolation.number(xy) || datafinalization2.ID2(yx) == IdforInterpolation.number(xy)
            datafinalization2.Interpolation(yx) = 1;
            end
        end
    end
end

datafinalization = vertcat(datafinalization,datafinalization2); %Aggregate data over frames
  end
end
datafinalization(1,:) =[] ;
writetable(datafinalization,[datafile1,'Trackinganalysis\DataFinalizeOnlyForNetwork-Test.csv']) ;






 
