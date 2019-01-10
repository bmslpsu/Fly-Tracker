function [] = WingTracker(vidData,debug)
% WingTracker: tracks wings in rigid teher
    % Inputs:
        % vidData: 4D video matrix
        % debug: 
    % Outputs:
        % WingAngles: structure containing L & R wing angles and mask points
        % debug:
    %%
    [lCenterPos, rCenterPos, lMaskPts, rMaskPts,rtop,rbot,ltop,lbot] = MakeWingMask(vidData);
    threshold = 20;
    rPoly = impoly(gca, rMaskPts);
    lPoly = impoly(gca, lMaskPts);
    rMask = createMask(rPoly);                      
    lMask = createMask(lPoly);                      % making the mask

    rlow = atan2d(rbot(2)-rCenterPos(2),rbot(1)-rCenterPos(1));
    llow = atan2d_adv(lbot(2)-lCenterPos(2),lbot(1)-lCenterPos(1));
    rhigh = atan2d(rtop(2)-rCenterPos(2),rtop(1)-rCenterPos(1));
    lhigh = atan2d_adv(ltop(2)-lCenterPos(2),ltop(1)-lCenterPos(1)); 
    rrange = rhigh-rlow;
    lrange = lhigh-llow;                % find the angle ranges

    Vid = squeeze(vidData);
    thresh.low  = 15;
    thresh.high = 100;
    SE.erode =  strel('disk',3,8); % shape to use for erode and dilate functions
    SE.dilate = strel('disk',3,8); % shape to use for erode and dilate functions
    tic
    for kk = 1:2000
        clear Frame
        DISP = Vid(:,:,kk); % get frame
        IMG{1} = DISP;
        IMG{2} = medfilt2(IMG{1}); % median filter
        IMG{3} = IMG{2};
        thresh.Idx = (IMG{3} >= thresh.low) & (IMG{3} <= thresh.high); % find pixels in range
        IMG{3}(thresh.Idx) = 1; % convert to bianary above threshold
        IMG{3}(~thresh.Idx) = 0;  % convert to bianary below threshold
        IMG{3} = logical(IMG{3});
        IMG{4} = medfilt2(IMG{3}); % median filter
        IMG{5} = imfill(IMG{4},'holes'); % fill in small holes
        IMG{6} = imerode(IMG{5},SE.erode); % dilate
        IMG{7} = imdilate(IMG{6},SE.dilate); % erode
        IMG{8} = bwareaopen(IMG{7}, 5000); % get rid of disconnected objects
        Frame = IMG{8};

        f = Frame;
        rAngles(kk) = calculateAngle(f, rMask, rrange, rlow);     
        lAngles(kk)= calculateAngle(f, lMask, lrange, llow);   % Calculate the actual angle for the left and right wings

        if debug
         figure (2)
         imshow(IMG{1})
         hold on
         hLeft  = animatedline('Color','g','LineWidth',2);
         hRight = animatedline('Color','r','LineWidth',2);
         addpoints(hLeft, lCenterPos(1),lCenterPos(2));
         addpoints(hRight, rCenterPos(1),rCenterPos(2));
         addpoints(hLeft, lCenterPos(1)-100,lCenterPos(2)-tand(lAngles(kk))*100);
         addpoints(hRight,rCenterPos(1)+100,rCenterPos(2)+tand(rAngles(kk))*100); % plot the angles and see if that is correct
        end
    end
    toc

end
%% Internal Function Definitions %%
%---------------------------------------------------------------------------------------------------------------------------------
 function angle = calculateAngle(frame, mask, range, low)
    val = frame(mask);
    val_up = val(val==1);
    angle = low+range*length(val_up)/length(val);
 end
 
 function angle = atan2d_adv(y,x)
    angle = atan2d(y,x);
    if angle < 0
        angle = angle+360;
    end
 end