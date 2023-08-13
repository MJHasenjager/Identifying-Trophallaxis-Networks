%Using "calibration.csv" to locate the head of each ant and 
%create a distance matrix on each frame; Compare the distance with
% the spatial proximity of trophallaxis in "TrophallaxisApproximation.csv"; The 
%Spatial proximity networks for trophallaxis is built when the distance
%lesss than a spatial proximity threshold;
calibration= readtable([datafile1,'Trackinganalysis\Calibration.csv']); %Load calibration 
Len = size(calibration(1:end,3),1); % Extract the length of individual IDs in calibration.csv
IDIDID=calibration.number;
ContactThreshold=readtable([datafile1,'\Trackinganalysis\TrophallaxisApproximation.csv']); %Load csv for spatial proximity estimation
ContactThreshold=max(ContactThreshold.Distance); %Estimate the spatial proximity 
datafinalization=array2table(zeros(1,6)); %Create a table for interactions identified
datafinalization.Properties.VariableNames = {'ID1','ID2','locX','locY','time','Interpolation'};%Name the columns
AntTrackAggregate = readtable([datafile1,'Trackinganalysis\AfterOrder\AntTrackAggregate-order.csv']);
AntTrackAggregatespeed = readtable([datafile1,'Trackinganalysis\AfterOrder\AntTrackAggregate-speed.csv']);

AntTrackAggregate.speed=AntTrackAggregatespeed.Speed;
writetable(AntTrackAggregate,[datafile1,'Trackinganalysis\AntTrackAggregateUpdated.csv']) ;
AntTrackAggregate =readtable([datafile1,'Trackinganalysis\AntTrackAggregateUpdated.csv']);
AntTrackAggregate = AntTrackAggregate(AntTrackAggregate.Var18>=startframe,:);
for ii = (startframe+1):1:endframe 
    %%%%%%%%%%%%%
    %%%%%%%%%%%%%
  if rem(ii-1,5)==0
    ii
if isempty(AntTrackAggregate(AntTrackAggregate.Var18==ii,:)) == 0
 dataD = AntTrackAggregate(AntTrackAggregate.Var18==ii,:);
 dataD.Properties.VariableNames = {'x_cor' 'y_cor' 'number' 'frontX' 'frontY' 'corners1' 'corners2' 'corners3' 'corners4' 'corners5' 'corners6' 'corners7' 'corners8' 'order1' 'order2' 'order3' 'order4' 'frame' 'speed'} ; 
 dataD.Interpolate = zeros(size(dataD,1),1);
 dataD1=dataD((dataD.number == IDIDID(1,1)),:);
for ixix = 1:1:Len
    %%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%
    datax = dataD((dataD.number == IDIDID(ixix,1)),:);
    dataD1 = vertcat(dataD1,datax);
    
        if isempty(datax) == 1 && ii > 30
        for mmx = 10:-1:1
            mmmx = ii - mmx;
            if isempty(AntTrackAggregate(AntTrackAggregate.Var18==mmmx,:)) == 0
            dataDDD = AntTrackAggregate(AntTrackAggregate.Var18==mmmx,:);%readtable([datafile1,'\Trackingdata\AfterOrder\AntTrack-',num2str(mmmx),'.csv']);
            %dataDDD(1,:) = [];
            dataDDD.Properties.VariableNames = {'x_cor' 'y_cor' 'number' 'frontX' 'frontY' 'corners1' 'corners2' 'corners3' 'corners4' 'corners5' 'corners6' 'corners7' 'corners8' 'order1' 'order2' 'order3' 'order4' 'frame' 'speed'};  
            dataDDD.Interpolate = ones(size(dataDDD,1),1);
            dataDDDx = dataDDD((dataDDD.number == IDIDID(ixix,1)),:);
            if exist('dataDDDx','var')==1  && isempty(dataDDDx) == 0              
                dataDDDxx = dataDDDx ;
            else
                dataDDDxx = array2table([]);
            end 
            end  
            end        
        for mmx = 10:-1:1
            mmmx = ii + mmx;
            %if isfile([datafile1,'\Trackingdata\AfterOrder\AntTrack-',num2str(mmmx),'.csv'])
            if isempty(AntTrackAggregate(AntTrackAggregate.Var18==mmmx,:)) == 0
            %dataDDD = readtable([datafile1,'\Trackingdata\AfterOrder\AntTrack-',num2str(mmmx),'.csv']);
            dataDDD = AntTrackAggregate(AntTrackAggregate.Var18==mmmx,:);
            %dataDDD(1,:) = [];
            dataDDD.Properties.VariableNames = {'x_cor' 'y_cor' 'number' 'frontX' 'frontY' 'corners1' 'corners2' 'corners3' 'corners4' 'corners5' 'corners6' 'corners7' 'corners8' 'order1' 'order2' 'order3' 'order4' 'frame' 'speed'}  ;
            dataDDD.Interpolate = ones(size(dataDDD,1),1);
            dataDDDx = dataDDD((dataDDD.number == IDIDID(ixix,1)),:);
            if exist('dataDDDx','var')==1 && isempty(dataDDDx) == 0                
                dataDDDxxx = dataDDDx ;
                else
                dataDDDxxx = array2table([]);
            end 
            end  
        end            
         if exist('dataDDDxx','var')==1 && isempty(dataDDDxx) == 0 && exist('dataDDDxxx','var')==1 && isempty(dataDDDxxx) == 0             
             points = [table2array(dataDDDxx(1,1)) table2array(dataDDDxx(1,2));table2array(dataDDDxxx(1,1)) table2array(dataDDDxxx(1,2))];
             Dist=pdist(points,'euclidean')  ;           
             if  Dist < 55 
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
if isempty(dataD1)== 0
 dataD1(1,:)=[];
 n=size(dataD1);
 n=n(1);
 A = rand(n,1);
 A(1:n) = ii;
 T = array2table(A);
 L = array2table(zeros(n,1));
 M = array2table(zeros(n,1));
 N = array2table(zeros(n,1));
 %InTer = array2table(zeros(n,1));
 T.Properties.VariableNames = {'time'};
 L.Properties.VariableNames = {'light'};
 M.Properties.VariableNames = {'HeadX'};
 N.Properties.VariableNames = {'HeadY'};
 %InTer.Properties.VariableNames = {'interpolation'}
 dataD1 = [dataD1 T L M N] ;
 datadissection = dataD1;
end
%%%Add head corrdinates
%%%Add head corrdinates
%%%Add head corrdinates
    for jj = 1:1:size(datadissection,1)        
    XXxx = datadissection.x_cor(jj);
    YYyy = datadissection.y_cor(jj)  ;   
    box=[datadissection.order3(jj),datadissection.order4(jj)]; % the orders are only valid for 1,2,3,4 or 2,3,4,1 or 3,4,1,2 or 4,1,2,3
           if any(box == 1) && any(box == 4)
            XXxx1 = datadissection.corners2(jj);
            YYyy1 = datadissection.corners1(jj);
           end    
        if any(box == 3) && any(box == 4)
            XXxx1 = datadissection.corners8(jj);
            YYyy1 = datadissection.corners7(jj);
        end
        if any(box == 1) && any(box == 2)
            XXxx1 = datadissection.corners4(jj);
            YYyy1 = datadissection.corners3(jj);
        end
        if any(box == 2) && any(box == 3)
            XXxx1 = datadissection.corners6(jj);
            YYyy1 = datadissection.corners5(jj);
        end    
    XXxx2 = datadissection.frontX(jj);
    YYyy2 = datadissection.frontY(jj);
    IDindex=datadissection.number(jj);
    distance4 = table2array(calibration(calibration.number == IDindex,25));
    distance5 = table2array(calibration(calibration.number == IDindex,26));
    distance6 = table2array(calibration(calibration.number == IDindex,27));    
Center(1)=XXxx;
Center(2)=YYyy;
Radius = distance4;
% % Get coordinates of the circle.
angles = linspace(0, 2*pi, 100);
%angles=(0:pi/5:pi);
x = cos(angles) * Radius + Center(1);
y = sin(angles) * Radius + Center(2);
% Show circle over image.

Center(1)=XXxx2;
Center(2)=YYyy2;
Radius = distance5;
% Get coordinates of the circle.
x2 = cos(angles) * Radius + Center(1);
y2 = sin(angles) * Radius + Center(2);    

Center(1)=XXxx1;
Center(2)=YYyy1;
Radius = distance6;
% % Get coordinates of the circle.
x1 = cos(angles) * Radius + Center(1);
y1 = sin(angles) * Radius + Center(2);    

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
% Get coordinates of the circle.
 datadissection.light(jj)=0;
 datadissection.HeadX(jj)= xhead;
 datadissection.HeadY(jj)= yhead   ; 
    end 
%%%Add head corrdinates
%%%Add head corrdinates
%%%Add head corrdinates
datadissectionmiddle=table2array(datadissection);

dx = bsxfun(@minus, datadissectionmiddle(:,23), datadissectionmiddle(:,23)');
dy = bsxfun(@minus, datadissectionmiddle(:,24), datadissectionmiddle(:,24)');
realcontactmatrix = sqrt(dx.^2 + dy.^2);
realcontactmatrix = triu(realcontactmatrix);
realcontactmatrix(realcontactmatrix == 0 ) = 10000;
realcontactmatrix(realcontactmatrix <= ContactThreshold )=1;
realcontactmatrix(realcontactmatrix > ContactThreshold)=0;
[row,col] = find(realcontactmatrix ==1);
IDrowcollist=[row,col];
ListID = datadissection.number;
datafinalization2=array2table(zeros(1,6));
datafinalization2.Properties.VariableNames = {'ID1','ID2','locX','locY','time','Interpolation'};   
   numberframe = (ii -1)/5;
    addpath('C:\Users\Guo\Desktop\Guo\BEEtag-master');
    addpath('C:\Users\Guo\Desktop\Guo\BEEtag-master\src') ;

for jmx = 1:1:size(IDrowcollist,1)
    
    if table2array(datadissection(datadissection.number==ListID(IDrowcollist(jmx,1)),19))< 5
        
    datafinalizationMiddle=array2table(zeros(1,6));
    datafinalizationMiddle.Properties.VariableNames = {'ID1','ID2','locX','locY','time','Interpolation'};    
    datafinalizationMiddle.ID1 = ListID(IDrowcollist(jmx,1),1);
    datafinalizationMiddle.ID2 = ListID(IDrowcollist(jmx,2),1);
    datafinalizationMiddle.time = numberframe;
    locationXID1=table2array(datadissection(datadissection.number==ListID(IDrowcollist(jmx,1)),23));
    locationYID1=table2array(datadissection(datadissection.number==ListID(IDrowcollist(jmx,1)),24));     
    locationXID2=table2array(datadissection(datadissection.number==ListID(IDrowcollist(jmx,2)),23));
    locationYID2=table2array(datadissection(datadissection.number==ListID(IDrowcollist(jmx,2)),24));    
    datafinalizationMiddle.locX = (locationXID1+locationXID2)/2;
    datafinalizationMiddle.locY = (locationYID1+locationYID2)/2; 
    datafinalization2 = vertcat(datafinalization2,datafinalizationMiddle);
    end
end
datafinalization2(1,:)=[];
close all;
IdforInterpolation = datadissection(datadissection.Interpolate == 1,3);
if exist('IdforInterpolation','var') == 1 && isempty(IdforInterpolation) == 0
    for xy = 1:1:size(IdforInterpolation,1) 
        for yx = 1:1:(size(datafinalization2,1))
            if datafinalization2.ID1(yx) == IdforInterpolation.number(xy) || datafinalization2.ID2(yx) == IdforInterpolation.number(xy)
            datafinalization2.Interpolation(yx) = 1;
            end
        end
    end
end
datafinalization = vertcat(datafinalization,datafinalization2);
end
end

datafinalization(1,:) =[] ;
writetable(datafinalization,[datafile1,'Trackinganalysis\DataFinalizeOnlyForNetwork.csv']) ;






 
