function [hAngles,centerPoint] = HeadTracker(vidData,t_v,nPoints,playBack,debug)
%% HeadTracker: tracks feature on fly head (ususally antenna) & calculates the angle with respect to a specififed 
% center point. Kanade–Lucas–Tomasi feature tracker.
% Sign Convention for angle outputs:    CW = + and CCW = -
    % INPUTS:
        % vidData: 4D video matrix
        % t_v: time vector
        % nPoints: # of points for tracker
        % playBack: 0 = none , 1 = all frames, else = playback factor (must be integer less than nFrames)
        % debug: logical >>> 1 = debug mode
   	% OUTPUTS:
        % hAngles: head angles
        
% playBack = 5.2;
% nPoints = 3;
vidData = squeeze(vidData);
[~,~,nFrame] = size(vidData); % get dimensions  of video data

if ~rem(playBack,1)==0
    warning('Warning: "playBack" roundeds to nearest integer')
end

if playBack>nFrame
    error(['Error: playBack rate must be less than # of frames: ' num2str(nFrame)])
end

%% Define Feature Detection Area & Centerline %%
%---------------------------------------------------------------------------------------------------------------------------------
% Define area of interest & define head midline
objectFrame = vidData(:,:,1); % get frame to start tracker
displayFrame = vidData(:,:,1); % get frame for display
figure (1); clf ; imshow(displayFrame); title('Pick area of interest & draw head midline') % show frame
objectRegion = round(getPosition(imrect)); % draw box around tracking point (antenna)
centerLine = round(getPosition(imline)); % draw line through head rotation point and head midline
close(1)
%% Extract Coodiantes & Calculate Initial Head Angle %%
%---------------------------------------------------------------------------------------------------------------------------------
% Coordinates for head rotation point
centerPoint.Y = max(centerLine(:,2)); % lower y-coordinate is the neck joint
centerPoint.X = centerLine((centerLine(:,2) == centerPoint.Y)); % get corrsponding x-coordinate

% Coordinates for initial angle of head midline
midPoint.Y = min(centerLine(:,2)); % higher y-coordinate is the midline point
midPoint.X = centerLine((centerLine(:,2) == midPoint.Y)); % get corrsponding x-coordinate

% Calculate initial angle of head midline
initAngle.head = rad2deg(atan2(midPoint.X - centerPoint.X , -(midPoint.Y - centerPoint.Y) ));

% Setup tracking
points	= detectMinEigenFeatures(objectFrame,'ROI',objectRegion); % detect features
points = points.selectStrongest(nPoints); % get strongest points
tracker = vision.PointTracker('MaxBidirectionalError',5,'NumPyramidLevels',7,...
    'BlockSize',[31 31],'MaxIterations',40); % create tracker object
initialize(tracker,points.Location,objectFrame); % start tracker

% Calculate initial angle to feature (antenna)
[points,validity] = tracker(objectFrame);
pointFrame_disp = insertMarker(displayFrame,points(validity, :),'+');

initFeat.Y = round(mean(points(:,2)));
initFeat.X = round(mean(points(:,1)));

initAngle.feature = rad2deg(atan2(initFeat.X - centerPoint.X , -(initFeat.Y - centerPoint.Y) ));

% Calculate offset angle from feature to head midline
offsetAngle = initAngle.feature - initAngle.head;

% Show points and lines
figure (2); clf ; imshow(pointFrame_disp); title('Detected Interest Points: Click to continue');
line([centerPoint.X , midPoint.X ],[centerPoint.Y , midPoint.Y],'Color','r','Linewidth',2)
line([centerPoint.X , initFeat.X ],[centerPoint.Y , initFeat.Y],'Color','cy','Linewidth',2)

pause % wait for click to continue
close(2) % close figure
%% Track features & calculate head angle for every frame %%
%---------------------------------------------------------------------------------------------------------------------------------
Pos.X = zeros(nFrame,1); Pos.Y = zeros(nFrame,1); hAngles = zeros(nFrame,1); % preallocate vectors to store data
POINTS = cell(nFrame,1);

tic
for kk = 1:nFrame
    currentFrame = vidData(:,:,kk); % get frame
    [points,~] = tracker(currentFrame); % detect features
%     disp(validity)
    POINTS{kk} = points; % store points in array
    
	Pos.Y(kk) = mean(points(:,2)); Pos.X(kk) = mean(points(:,1)); % calculate average (x.y) position of features
    
	hAngles(kk) = rad2deg( atan2( Pos.X(kk) - centerPoint.X , ... % calculate head midline angle
            -(Pos.Y(kk) - centerPoint.Y) ) ) - offsetAngle;
end

disp('Angle Calculations: Done')
toc
%% Replay Video %%
%---------------------------------------------------------------------------------------------------------------------------------
if playBack    
    % Setup Figures
    h1 = figure (1); clf ; title('Tracking') ; movegui(h1,[200 -100]) % tracking figure
    h2 = figure (2); clf ; title('Head Angle') ; ylabel('deg') ; xlabel('time') ; movegui(h2,[-100 200]) % head angle vs time figure
    hWait = waitbar(0,'Finding Angles'); movegui(hWait,[-200 -200]) % wait bar handle
    hAnglePlot  = animatedline('Color','b','LineWidth',2); % angles handle

    % Display frames at higher rate
    disp('Replay Video at Higher Frame Rate:')
    for kk = 1:round(playBack):nFrame
        currentFrame = vidData(:,:,kk); % get frame
        pointFrame = insertMarker(currentFrame,POINTS{kk},'+'); % add points to image
           
        figure (1)
        if debug
            imshow(pointFrame) ; waitbar(kk/nFrame,hWait); % show tracking
            line([centerPoint.X , Pos.X(kk) ],[centerPoint.Y , Pos.Y(kk)],...  % update line drawn to feature
                'Color','cy','LineWidth',2)
        else
            imshow(currentFrame) ; waitbar(kk/nFrame,hWait); % show tracking
        end

            line([centerPoint.X ,  Pos.X(kk) - (initFeat.X - midPoint.X)],...  % update line drawn to head mideline
                 [centerPoint.Y ,  Pos.Y(kk) - (initFeat.Y - midPoint.Y)],...
                 'Color','r','LineWidth',2,'Marker','o')
             
        figure (2)
            addpoints(hAnglePlot,t_v(kk),hAngles(kk)) % update line
            box on
    end
end

% pause
if playBack
    close (hWait) ; 
%     close (h1) ; close (h2) % close waitbar & figure window
end
end