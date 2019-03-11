function [Head] = HeadTest(vidData,Threslow,debug)
vidData = squeeze(vidData);
[~,~,nFrame] = size(vidData); % get dimensions  of video data
objectFrame = vidData(:,:,1); % get frame to start tracker
displayFrame = vidData(:,:,1); % get frame for display
figure (1); clf ; imshow(displayFrame); title('Pick area of interest & draw head midline') % show frame
objectRegion = round(getPosition(imrect)); % draw box around tracking point (antenna)
centerpoint = round(getPosition(impoint));
vid = imshow(objectFrame);
rec = imrect(gca,objectRegion);
Mask = createMask(rec,vid);
Head = zeros(nFrame,1);
Rel_center = centerpoint - [objectRegion(1),objectRegion(2)];
for kk = 1:nFrame   
    IMG{1} = vid(:,:,kk);
    thresh.Idx = (IMG{1} >=Threslow);
    IMG{1}(thresh.Idx) = 1;                 
    IMG{1}(~thresh.Idx) = 0;
    IMG{1} = logical(IMG{1}); 
    Frame = IMG{1};
    Head(kk) = calculateAngle(Frame, Mask, Rel_center);
    if debug
     figure (1)
     imshow(IMG{3})
     hold on
     h.R = animatedline('Color','r','LineWidth',2);
     addpoints(h.R , centerpoint(1),centerpoint(2));
     addpoints(h.R , centerpoint(1)+100,centerpoint(2)+tand(Head(kk))*100);
    end
end
end
%%
function angle = calculateAngle(frame, mask, center)
val = frame(mask);
tot_mass = sum(val(:));
[ii,jj] = ndgrid(1:size(val,1),1:size(val,2));
R = sum(ii(:).*val(:))/tot_mass;
C = sum(jj(:).*val(:))/tot_mass;
angle = atan((R-center(1))/(C-center(2)));
end