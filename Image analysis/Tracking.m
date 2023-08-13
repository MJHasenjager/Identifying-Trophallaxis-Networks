%Example to locate and identify visual barcodes within a picture
%Remember to add folder with code to your matlab path
addpath('C:\Users\Guo\Desktop\Guo\BEEtag-master')
addpath('C:\Users\Guo\Desktop\Guo\BEEtag-master\src')  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A_frist_line = zeros(1,18)
for xx = (startframe+1):endframe
%Read in example file
im = imread([datafile1,'AntTrack',num2str(xx),'.tif']);
Centroid = [0 0];
number = 0;
frontX=0;
frontY=0;
corners1 = 0;
corners2 = 0;
corners3 = 0;
corners4 = 0;
corners5 = 0;
corners6 = 0;
corners7 = 0;
corners8 = 0;
corners9 = 0;
corners10 = 0;
corners11 = 0;
corners12 = 0;
aa_t = table(Centroid,number,frontX, frontY, corners1,corners2,corners3,corners4,corners5,corners6,corners7,corners8,corners9,corners10,corners11,corners12);

for m=10:2:80
    n=m*0.01;
    codes = locateCodes(im, 'colMode', 1, 'thresh', n);
    if isempty(codes)==0;
    codes1 = rmfield(codes,'corners');
    %codes1 = rmfield(codes1,'frontX')
    %codes1 = rmfield(codes1,'frontY')
    codes1 = rmfield(codes1,'pts');
    codes1 = rmfield(codes1,'code');
    codes1 = rmfield(codes1,'Area');
    codes1 = rmfield(codes1,'BoundingBox') ;
    bb_t = struct2table(codes1);
    medium=cell2mat({codes(1:numel(codes)).corners}');
    corners = [0 0 0 0 0 0 0 0 0 0 0 0];
    corners=array2table(corners);
    corners.Properties.VariableNames={'corners1' 'corners2' 'corners3' 'corners4' 'corners5' 'corners6' 'corners7' 'corners8' 'corners9' 'corners10' 'corners11' 'corners12'};
    corners1 = [0 0 0 0 0 0 0 0 0 0 0 0];
    bb_t = struct2table(codes1);
    medium=cell2mat({codes(1:numel(codes)).corners}');

    for ix = 1:numel(codes)
        corners1 = [0 0 0 0 0 0 0 0 0 0 0 0];
        corners1(1,1:2) = medium((1+((ix-1)*2)):(2+((ix-1)*2)),1);
        corners1(1,3:4) = medium((1+((ix-1)*2)):(2+((ix-1)*2)),2);
       corners1(1,5:6) = medium((1+((ix-1)*2)):(2+((ix-1)*2)),3);
       corners1(1,7:8) = medium((1+((ix-1)*2)):(2+((ix-1)*2)),4);
       corners1 = array2table(corners1);
       corners1.Properties.VariableNames = {'corners1' 'corners2' 'corners3' 'corners4' 'corners5' 'corners6' 'corners7' 'corners8' 'corners9' 'corners10' 'corners11' 'corners12'};
       corners = vertcat(corners,corners1);
    end
    corners(1,:)=[];    
    bb_t = [bb_t, corners];    
    aa_t = [aa_t; bb_t]; 
    end    
   
    if isempty(aa_t)==0;
    A = table2array(aa_t);
[~,uidx] = unique(A(:,3),'stable');
A_without_dup = A(uidx,:);
    end
end
timestep = zeros(size(A_without_dup,1), 1);
A_without_dup = [A_without_dup,timestep];
A_without_dup(1:size(A_without_dup,1),size(A_without_dup,2))= xx;
A_without_dup(1,:)=[];
A_frist_line = [A_frist_line;A_without_dup];
end
A_frist_line(1,:)=[]
writematrix(A_frist_line,[datafile1,'Trackinganalysis\AntTrackAggregate.csv']) 


