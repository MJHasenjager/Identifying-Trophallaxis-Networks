%Randomly choose N (N=10 here) frames between frame-1 and frame-2000 and click the
%head of each ant who is doing trophallaxis, and then estimate the distance between
%their head
ContactFramenumber=fix([rand(1,10)]*2000)
ContactFramenumber=ContactFramenumber([ContactFramenumber>21])
Contact=[0, 0, 0, 0]
Contact=array2table(Contact)
Contact.Properties.VariableNames={'x' 'y' 'Distance' 'Frame'}
for i = 1:size(ContactFramenumber,2)
    a=ContactFramenumber(i)    
    im = imread([datafile1,'AntTrack',num2str(a),'.tif']);
    imshow(im)
    reply = input('Is there trophallaxis event? Yes: 1; No: 2');
   if reply == 1
    close all    
    Contactbolb = readPoints(im,2,'ContactApproximationEstimation')
    Contactbolb = array2table(Contactbolb.');
    Contactbolb.Properties.VariableNames={'x' 'y'}
    Contactcol=[0;0]
    Contactcol = array2table(Contactcol)
    Contactcol.Properties.VariableNames = {'Distance'} 
    %imshow(maskedImage, []);
    points=[table2array(Contactbolb(1,1)) table2array(Contactbolb(1,2));table2array(Contactbolb(2,1)) table2array(Contactbolb(2,2))]
    Contactbolb.Distance(1)=pdist(points,'euclidean')
    Contactbolb.Distance(2)=pdist(points,'euclidean')
    Contactbolb.Frame(1)=a;
    Contactbolb.Frame(2)=a;
    Contact = [Contact;Contactbolb]     
   end     
end
close all
Contact(1,:)=[]
writetable(Contact,[datafile1,'Trackinganalysis\TrophallaxisApproximation.csv']) 

