function [Head] = HeadTest(vidData,Threslow,debug)
%%
vidData = squeeze(vidData);
[~,~,nFrame] = size(vidData); % get dimensions  of video data
objectFrame = vidData(:,:,1); % get frame to start tracker
displayFrame = vidData(:,:,1); % get frame for display
figure (1); clf ; 
imshow(displayFrame); title('Pick area of interest & draw head midline') % show frame
objectRegion = round(getPosition(imrect)); % draw box around tracking point (antenna)
centerpoint = round(getPosition(impoint));
vid = imshow(objectFrame);
rec = imrect(gca,objectRegion);
Mask = createMask(rec,vid);
Head = zeros(nFrame,1);
Rel_center = centerpoint - [objectRegion(1),objectRegion(2)];
column = objectRegion(4);
kk = 1;
IMG{1} = vidData(:,:,kk);
    thresh.Idx = (IMG{1} >=Threslow);
    IMG{1}(thresh.Idx) = 1;                 
    IMG{1}(~thresh.Idx) = 0;
    IMG{1} = logical(IMG{1}); 
    Frame = IMG{1};
    Head(kk) = calculateAngle(Frame, Mask, Rel_center,column);
     figure (1)
     imshow(IMG{1})
     hold on
     h.R = animatedline('Color','r','LineWidth',2);
     addpoints(h.R , centerpoint(1),centerpoint(2));
     addpoints(h.R , centerpoint(1)+100*cos(Head(kk)),centerpoint(2)+sin(Head(kk))*100);
    correct = round(getPosition(impoint));
    correct_angle = atan2((correct(2)-centerpoint(2)),(correct(1)-centerpoint(1)));
    correction = Head(kk)-correct_angle;

for kk = 1:nFrame   
    IMG{1} = vidData(:,:,kk);
    thresh.Idx = (IMG{1} >=Threslow);
    IMG{1}(thresh.Idx) = 1;                 
    IMG{1}(~thresh.Idx) = 0;
    IMG{1} = logical(IMG{1}); 
    Frame = IMG{1};
    Head(kk) = calculateAngle2(Frame, Mask, Rel_center,column,correction);
    if debug
     figure (1)
     imshow(IMG{1})
     hold on
     h.R = animatedline('Color','r','LineWidth',2);
     addpoints(h.R , centerpoint(1),centerpoint(2));
     addpoints(h.R , centerpoint(1)+100*cos(Head(kk)),centerpoint(2)+sin(Head(kk))*100);
    % addpoints(h.R , centerpoint(1)-100,centerpoint(2)-tan(Head(kk))*100);
    end
end
end
%%
function angle = calculateAngle(frame, mask, center,column)
val = frame(mask);
val2 = vec2mat(val,column);
val3 = transpose(val2);
tot_mass = sum(val3(:));
[ii,jj] = ndgrid(1:size(val3,1),1:size(val3,2));
R = sum(ii(:).*val3(:))/tot_mass;
C = sum(jj(:).*val3(:))/tot_mass;
angle = atan2((R-center(1)),(C-center(2)));
end
%%
function angle = calculateAngle2(frame, mask, center,column,correction)
val = frame(mask);
val2 = vec2mat(val,column);
val3 = transpose(val2);
tot_mass = sum(val3(:));
[ii,jj] = ndgrid(1:size(val3,1),1:size(val3,2));
R = sum(ii(:).*val3(:))/tot_mass;
C = sum(jj(:).*val3(:))/tot_mass;
angle = atan2((R-center(1)),(C-center(2)))-correction;
end