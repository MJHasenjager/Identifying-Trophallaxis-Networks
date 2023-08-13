%Count the total occurances of each ID being tracked over frames
aggregateData= readtable([datafile1,'\Trackinganalysis\AntTrackAggregate.csv']);
numberFrame = (endframe)-startframe +1;
dataunique=unique(aggregateData.Var3);
occurance  = array2table(histc(aggregateData.Var3,dataunique));
IDList=[array2table(dataunique),occurance];
IDList.Properties.VariableNames = {'ID','occurance'};
np=numberFrame/10;
IDList =IDList(IDList.ID < 8000,:);%Excluding potential ID (a number) greater than a upper bound
IDList =IDList(IDList.ID > 800,:);%Excluding potential ID (a number) lower than a lower bound
IDList =IDList(IDList.occurance> np,:);%Excluding potential ID (a number) whose occurances being tracked less than 10% of total frames
writetable(IDList,[datafile1,'\Trackinganalysis\Filtered.csv'])

%List the frame number when all of ants have been tracked successfully
 A = (startframe:(endframe)/2);
 T=array2table(A.');
 T.Properties.VariableNames = {'Frame'};
 A = (startframe:(endframe)/2);
 T1=array2table(A.');
 T1.Properties.VariableNames = {'occurance'};
 T = [T,T1]; 
for xxx = startframe:(endframe/2)    
    aa_t = aggregateData(aggregateData.Var18 == xxx,:);
    T.Frame(xxx) = xxx;
   if isempty(aa_t) == 1        
     T.occurance(xxx) = 0;
   else
     T.occurance(xxx) = size(aa_t,1);
   end        
end 
FrameCapture = T(T.occurance >= numberOfAnts,:)
if isempty(FrameCapture)==0
   writetable(FrameCapture,[datafile1,'Trackinganalysis\FrameNumberCaptured.csv']) 
   writetable(T,[datafile1,'Trackinganalysis\CaptureOverFrame.csv'])
else
    FrameCapture = T(T.occurance == max(T.occurance),:) ;  
    writetable(FrameCapture,[datafile1,'Trackinganalysis\FrameNumberCaptured.csv'])
    writetable(T,[datafile1,'Trackinganalysis\CaptureOverFrame.csv'])
end



