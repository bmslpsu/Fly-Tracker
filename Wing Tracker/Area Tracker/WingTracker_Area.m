function [Wing] = WingTracker_Area(vid,debug,Threslow,filter,varargin)
% WingTracker: tracks wings in rigid teher
    % INPUTS:
        % (1) vid   : 4D video matrix
        % (2) debug : playback all frames if on
        % (3) Mask  : optional predefined mask
    % OUTPUTS:
        % (1) Wing: structure containing time, L & R wing angles and mask points
        
%% Area Tracking %% yyyyyxxxx
%---------------------------------------------------------------------------------------------------------------------------------
% Make Mask
Vid = squeeze(vid);         % get rid of singleton dimension
[~,~,nFrame] = size(Vid);   % get relevant video dimensions

if nargin==4
    Mask = MakeWingMask(vid); % make mask for wings
elseif (nargin>=6) || (nargin<=1)
    error('Too many input arguments')
else
   Mask = varargin{1};
end
Mask = MakeWingMask(vid); % make mask for wings

Wing.Mask  = Mask; % store mask

close
figure (1) ; clf ; imshow(Vid(:,:,1))
rPoly = impoly(gca, Mask.R.points);
lPoly = impoly(gca, Mask.L.points);
rMask = createMask(rPoly);
lMask = createMask(lPoly);
pause
close

% Find angular range
rlow  = atan2d      ( Mask.R.bot(2) - Mask.R.center(2) , Mask.R.bot(1) - Mask.R.center(1) );
llow  = atan2d_adv  ( Mask.L.bot(2) - Mask.L.center(2) , Mask.L.bot(1) - Mask.L.center(1) );
rhigh = atan2d      ( Mask.R.top(2) - Mask.R.center(2) , Mask.R.top(1) - Mask.R.center(1) );
lhigh = atan2d_adv  ( Mask.L.top(2) - Mask.L.center(2) , Mask.L.top(1) - Mask.L.center(1) ); 

rrange = rhigh - rlow;
lrange = lhigh - llow;

% Pick thresholds
% thresh.low  = 15;  % below = 0
% thresh.high = 100; % above = 1
% SE.erode =  strel('disk',3,8); % erode function shape
% SE.dilate = strel('disk',3,8); % dilate function shape

% Run area tracking
Wing.Angle.R = zeros(nFrame,1);
Wing.Angle.L = zeros(nFrame,1);
tic
for kk = 1:nFrame   
     IMG{1} = Vid(:,:,kk); % get frame
%     IMG{2} = medfilt2(IMG{1}); % median filter
%     IMG{3} = IMG{2};
%     thresh.Idx = (IMG{3} >= thresh.low) & (IMG{3} <= thresh.high); % find pixels in range
%     
%     IMG{3}(thresh.Idx) = 1;                 % convert to bianary above threshold
%     IMG{3}(~thresh.Idx) = 0;                % convert to bianary below threshold
%     IMG{3} = logical(IMG{3});               % convert to logical
% %     IMG{4} = medfilt2(IMG{3});              % median filter
%     IMG{5} = imfill(IMG{3},'holes');        % fill in small holes
% %     IMG{6} = imerode(IMG{5},SE.erode);      % dilate
% %     IMG{7} = imdilate(IMG{6},SE.dilate);    % erode
%     IMG{8} = bwareaopen(IMG{5}, 5000);      % get rid of disconnected objects
%     Frame = IMG{8};
    IMG{1} = vid(:,:,frame);
    thresh.Idx = (IMG{1} >=Threslow);
    IMG{1}(thresh.Idx) = 1;                 
    IMG{1}(~thresh.Idx) = 0;
    IMG{1} = logical(IMG{1});    
    if filter(1)>0
        for a = 1:filter(1)
            IMG{1} = medfilt2(IMG{1});
        end
    end
    if filter(2)>0
        for a = 1:filter(2)
            IMG{1} = imfill(IMG{1},'holes');
        end
    end
    if filter(3)>0
        for a = 1:filter(3)
            IMG{1} = bwareaopen(IMG{1}, 5000);
        end
    end

    Wing.Angle.R(kk) = calculateAngle(Frame, rMask, rrange, rlow);     
    Wing.Angle.L(kk) = calculateAngle(Frame, lMask, lrange, llow);
    
    if debug
     figure (1)
     imshow(IMG{8})
     hold on
     h.L = animatedline('Color','g','LineWidth',2);
     h.R = animatedline('Color','r','LineWidth',2);
     addpoints(h.L , Mask.L.center(1),Mask.L.center(2));
     addpoints(h.R , Mask.R.center(1),Mask.R.center(2));
     addpoints(h.L , Mask.L.center(1)-100,Mask.L.center(2)-tand(Wing.Angle.L(kk))*100);
     addpoints(h.R , Mask.R.center(1)+100,Mask.R.center(2)+tand(Wing.Angle.R(kk))*100);
    end
end
toc

end
%% Internal Function Definitions %%
%---------------------------------------------------------------------------------------------------------------------------------
 function angle = calculateAngle(frame, mask, range, low)
    val    = frame(mask);
    val_up = val(val==1);
    angle  = low + range*length(val_up)/length(val);
 end
 
 function angle = atan2d_adv(y,x)
    angle = atan2d(y,x);
    if angle < 0
        angle = angle + 360;
    end
 end