
aggregateData= readtable([datafile1,'Trackinganalysis\AntTrackAggregate.csv']);
aggregateData = aggregateData(aggregateData.Var18 < endframe +1, :);
%%% Labeling four corners of the tag in a sequence of numbers from 1 to 4, and sort those labels based on their relative
%%% distance with the center of the tag, and adding lables of four corners into the tracking data for further analysis
for numberFrame = startframe:1:endframe 
    numberFrame
aa_t = aggregateData(aggregateData.Var18 == numberFrame,:);
for lml = 1:size(aa_t,1)    
    lml
        points=[table2array(aa_t(lml,4)) table2array(aa_t(lml,5));table2array(aa_t(lml,7)) table2array(aa_t(lml,6))];
        DDD1=pdist(points,'euclidean');
        points=[table2array(aa_t(lml,4)) table2array(aa_t(lml,5));table2array(aa_t(lml,9)) table2array(aa_t(lml,8))];
        DDD2=pdist(points,'euclidean');
        points=[table2array(aa_t(lml,4)) table2array(aa_t(lml,5));table2array(aa_t(lml,11)) table2array(aa_t(lml,10))];
        DDD3=pdist(points,'euclidean');
        points1=[table2array(aa_t(lml,4)) table2array(aa_t(lml,5));table2array(aa_t(lml,13)) table2array(aa_t(lml,12))];
        DDD4=pdist(points1,'euclidean');
        NewDDDMatrix= [DDD1, DDD2, DDD3, DDD4;1,2,3,4];        
        [S,I]=sort(NewDDDMatrix(1,:));
        result = [S;NewDDDMatrix(2,I)];
        aa_t(lml,14:17)=array2table(result(2,1:4));
        aggregateData(aggregateData.Var18 == numberFrame,:)=aa_t;
end    
end
%Add speed of ant at each frame into the tracking data for further analysis 
aggregateData = aggregateData(aggregateData.Var18 < endframe+1,:);
aggregateData.Speed = zeros(size(aggregateData,1),1);
IDuniqueList = unique(aggregateData.Var3);
for AntID = 1:1:size(IDuniqueList,1)       
    AntID 
aa_t = aggregateData(aggregateData.Var3 == IDuniqueList(AntID),:);
if size(aa_t,1) > 1
for lml = 2:1:size(aa_t,1)    
    lml 
        points=[table2array(aa_t(lml-1,1)) table2array(aa_t(lml-1,2));table2array(aa_t(lml,1)) table2array(aa_t(lml,2))];
        DDD=pdist(points,'euclidean');
        TimeStep = (aa_t.Var18(lml)) - (aa_t.Var18(lml-1));
        aa_t.Speed(lml) = DDD/TimeStep;        
end
end
  aggregateData(aggregateData.Var3 == IDuniqueList(AntID),:)=aa_t;
end
writetable(aggregateData,[datafile1,'Trackinganalysis\AfterOrder\AntTrackAggregate_ordere_speed.csv']) 