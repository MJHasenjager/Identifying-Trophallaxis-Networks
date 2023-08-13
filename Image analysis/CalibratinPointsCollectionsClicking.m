f1=figure

f2=figure
%figure('Name','Simulation Plot Window','NumberTitle','off')
figure(f1)


imagecalibration=imread([datafile1,'Trackinganalysis\manualcorrection',num2str(imagenumber),'.png']);
imshow(imagecalibration);
MaximizeFigureWindow;
Framenumbercaptured=readtable([datafile1,'Trackinganalysis\FrameNumberCaptured.csv']);

%imagenumber=2
figure(f2)


%imagenumber=1197
imagenumber = Framenumbercaptured.Frame(FrameID);
image= imread([datafile1,'AntTrack',num2str(imagenumber),'.tif']);
MaximizeFigureWindow;
Calibration = readtable([datafile1,'Trackinganalysis\AfterOrder\AntTrackAggregate-order.csv'])
Calibration = Calibration(Calibration.Var18 == imagenumber,:)
%Calibration = Calibration(Calibration.Var3 < 8000,:)
FilteredID=  readtable([datafile1,'Trackinganalysis\Filtered.csv']) 
%Calibration(1,:)=[]
IDA=Calibration.Var3
IDB=FilteredID.ID
for i =1:size(IDA,1)
    a = IDA(i)
    record = 0
    for j=1:size(IDB,1)
      b=IDB(j)  
      if a==b
        record = record + 1      
      end        
    end
    if record ==0        
         Calibration.Var1(i)=0       
    end
end
TT = 'Gaster'
Calibration=Calibration(Calibration.Var1>0,:)
abdomen=readPoints(image, size(Calibration,1),TT)




Newabdomen = array2table(abdomen.');
Newabdomen.Properties.VariableNames={'a' 'b'}
Precalib=[Calibration.Var1(1:end), Calibration.Var2(1:end), Calibration.Var3(1:end)]
Precalib=array2table(Precalib)
Precalib.Properties.VariableNames={'c' 'd' 'e'}
Calibration=[Calibration,Newabdomen,Precalib]
for iii = 1:size(Calibration,1)
    
    box=[Calibration.Var17(iii),Calibration.Var16(iii)] % the orders are only valid for 1,2,3,4 or 2,3,4,1 or 3,4,1,2 or 4,1,2,3
        if any(box == 1) & any(box == 4)
            x1 = Calibration.Var7(iii)
            y1 = Calibration.Var6(iii)
        end
    
        if any(box == 3) & any(box == 4)
            x1 = Calibration.Var13(iii)
            y1 = Calibration.Var12(iii)
        end
        if any(box == 1) & any(box == 2)
            x1 = Calibration.Var9(iii)
            y1 = Calibration.Var8(iii)
        end
        if any(box == 2) & any(box == 3)
            x1 = Calibration.Var11(iii)
            y1 = Calibration.Var10(iii)
        end
    
%     if Calibration.Var17(iii) == 1 | Calibration.Var17(iii) == 1
%         
%             x1 = Calibration.Var7(iii)
%             y1 = Calibration.Var6(iii)
%    end
%     
%     if Calibration.Var17(iii) == 2
%     x1 = Calibration.Var9(iii)
%     y1 = Calibration.Var8(iii)
%     end
%     
%     if Calibration.Var17(iii) == 3
%     x1 = Calibration.Var11(iii)
%     y1 = Calibration.Var10(iii)
%     end
%     
%     if Calibration.Var17(iii) == 4
%     x1 = Calibration.Var13(iii)
%     y1 = Calibration.Var12(iii)
%     end
    
    
    x2 = Calibration.Var4(iii)
    y2 = Calibration.Var5(iii)
    
%     if Calibration.Var17(iii) == 1
%     x2 = Calibration.Var7(iii)
%     y2 = Calibration.Var6(iii)
%     end
%     
%     if Calibration.Var17(iii) == 2
%     x2 = Calibration.Var9(iii)
%     y2 = Calibration.Var8(iii)
%     end
%     
%     if Calibration.Var17(iii) == 3
%     x2 = Calibration.Var11(iii)
%     y2 = Calibration.Var10(iii)
%     end
%     
%     if Calibration.Var17(iii) == 4
%     x2 = Calibration.Var13(iii)
%     y2 = Calibration.Var12(iii)
%     end
    
    points=[Calibration.Var1(iii) Calibration.Var2(iii);Calibration.a(iii) Calibration.b(iii)] % Distance 1 for centroid, distance 2 for front point, and distance 3 for the lower left point.
    Calibration.c(iii)=pdist(points,'euclidean')
    
    points=[x2 y2;Calibration.a(iii) Calibration.b(iii)]
    Calibration.d(iii)=pdist(points,'euclidean')
    
    points=[x1 y1;Calibration.a(iii) Calibration.b(iii)]
    Calibration.e(iii)=pdist(points,'euclidean')
end

%Calibration.Properties.VariableNames = {'x_cor' 'y_cor' 'number' 'frontX' 'frontY' 'corners1' 'corners2' 'corners3' 'corners4' 'corners5' 'corners6' 'corners7' 'corners8' 'order1' 'order2' 'order3' 'order4' 'abdx_cor' 'adby_cor' 'distance1' 'distance2' 'distance3'}


TT = 'Head'


head=readPoints(image, size(Calibration,1),TT)




Newhead = array2table(head.');
Newhead.Properties.VariableNames={'aa' 'bb'}
Precalib=[Calibration.Var1(1:end), Calibration.Var2(1:end), Calibration.Var3(1:end)]
Precalib=array2table(Precalib)
Precalib.Properties.VariableNames={'cc' 'dd' 'ee'}
Calibration=[Calibration,Newhead,Precalib]
for iii = 1:size(Calibration,1)
    
    box=[Calibration.Var17(iii),Calibration.Var16(iii)] % the orders are only valid for 1,2,3,4 or 2,3,4,1 or 3,4,1,2 or 4,1,2,3
        if any(box == 1) & any(box == 4)
            x1 = Calibration.Var7(iii)
            y1 = Calibration.Var6(iii)
        end
    
        if any(box == 3) & any(box == 4)
            x1 = Calibration.Var13(iii)
            y1 = Calibration.Var12(iii)
        end
        if any(box == 1) & any(box == 2)
            x1 = Calibration.Var9(iii)
            y1 = Calibration.Var8(iii)
        end
        if any(box == 2) & any(box == 3)
            x1 = Calibration.Var11(iii)
            y1 = Calibration.Var10(iii)
        end
    
%     if Calibration.Var17(iii) == 1 | Calibration.Var17(iii) == 1
%         
%             x1 = Calibration.Var7(iii)
%             y1 = Calibration.Var6(iii)
%    end
%     
%     if Calibration.Var17(iii) == 2
%     x1 = Calibration.Var9(iii)
%     y1 = Calibration.Var8(iii)
%     end
%     
%     if Calibration.Var17(iii) == 3
%     x1 = Calibration.Var11(iii)
%     y1 = Calibration.Var10(iii)
%     end
%     
%     if Calibration.Var17(iii) == 4
%     x1 = Calibration.Var13(iii)
%     y1 = Calibration.Var12(iii)
%     end
    
    
    x2 = Calibration.Var4(iii)
    y2 = Calibration.Var5(iii)
    
%     if Calibration.Var17(iii) == 1
%     x2 = Calibration.Var7(iii)
%     y2 = Calibration.Var6(iii)
%     end
%     
%     if Calibration.Var17(iii) == 2
%     x2 = Calibration.Var9(iii)
%     y2 = Calibration.Var8(iii)
%     end
%     
%     if Calibration.Var17(iii) == 3
%     x2 = Calibration.Var11(iii)
%     y2 = Calibration.Var10(iii)
%     end
%     
%     if Calibration.Var17(iii) == 4
%     x2 = Calibration.Var13(iii)
%     y2 = Calibration.Var12(iii)
%     end
    
    points=[Calibration.Var1(iii) Calibration.Var2(iii);Calibration.aa(iii) Calibration.bb(iii)] % Distance 1 for centroid, distance 2 for front point, and distance 3 for the lower left point.
    Calibration.cc(iii)=pdist(points,'euclidean')
    
    points=[x2 y2;Calibration.aa(iii) Calibration.bb(iii)]
    Calibration.dd(iii)=pdist(points,'euclidean')
    
    points=[x1 y1;Calibration.aa(iii) Calibration.bb(iii)]
    Calibration.ee(iii)=pdist(points,'euclidean')
end
    
Calibration.Properties.VariableNames = {'x_cor' 'y_cor' 'number' 'frontX' 'frontY' 'corners1' 'corners2' 'corners3' 'corners4' 'corners5' 'corners6' 'corners7' 'corners8' 'order1' 'order2' 'order3' 'order4' 'frame' 'abdx_cor' 'adby_cor' 'distance1' 'distance2' 'distance3' 'headx_cor' 'heady_cor' 'distance4' 'distance5' 'distance6'}
writetable(Calibration,[datafile1,'Trackinganalysis\Calibration',num2str(imagenumber),'.csv']) 




