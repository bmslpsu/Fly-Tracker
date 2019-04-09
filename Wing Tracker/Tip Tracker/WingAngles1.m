%% Load Data

clc, clear, close all
% load('fly_6_trial_23_freq_2.mat');
Vid = squeeze(vidData);
%% Processing

figure (1) ; clf
imshow(Vid(:,:,1)); 
[xi,yi] = getpts;
close
tic
VidL = Vid(:, 1:min(xi),:);
VidR = Vid(:,max(xi):500,:);

overL = zeros(2000,1);
overR = zeros(2000,1);


for each = 1:2000
frameL = ImageProcess1(VidL(:,:,each));
frameR = ImageProcess1(VidR(:,:,each));


figure (11)
subplot(1,2,1)
imshow(frameL)
subplot(1,2,2)
imshow(frameR)


% Left Wing Angle
EdgeL = zeros(30,1);
counter = 1;
for section = (yi(1)-50):(yi(1)-20)
    [~,colL] = find(frameL(section,:),1,'last');
    if isempty(colL)
        colL = 0;
    end
    EdgeL(counter,1) = colL;
    counter = counter+1;
end

overLi= median(EdgeL);
overL(each, 1) = overLi;


% Right Wing Angle
EdgeR = zeros(30,1);
counter = 1;
for section = (yi(2)-50):(yi(2)-20)
    [~,colR] = find(frameR(section,:),1,'first');
    if isempty(colR)
        colR = 0;
    end
    EdgeR(counter,1) = colR;
    counter = counter+1;
end

overRi = median(EdgeR);
overR(each, 1) = overRi;


figure(11)
subplot(1,2,1)
hold on
plot(xi(1), yi(1),'.','MarkerSize', 20)
line([xi(1), overLi],[yi(1), yi(1)-20],'LineWidth',4)
hold off


subplot(1,2,2)
hold on
plot(1, yi(2),'.','MarkerSize',20)
line([1, overRi],[yi(2), yi(2)-20],'LineWidth',4)
hold off 
figVid(:,:,each) = getframe(gcf);


end
toc
%% Find Angles

anglesL  = atand((xi(1)-overL)/35);
anglesR = atand((overR)/35);

figure (4)
subplot(1,2,1)
plot(1:2000,anglesL,1:2000, anglesR)
legend('Left', 'Right')
title('WBA')
subplot(1,2,2)
plot(1:2000,anglesL-anglesR)
title('Delta WBA')

%figure(2)
%imshow(frameL)
%hold on
%plot(EdgeL,(yi(1)-30):(yi(1)-10), '.')
%plot(overL,heightL,'r*','Markersize',7)
%hold off

%figure(3)
%imshow(frameR)
%hold on
%figure(3)
%plot(EdgeR,(yi(2)-30):(yi(2)-10), '.')
%plot(overR,heightR,'r*','Markersize',7)
%hold off
