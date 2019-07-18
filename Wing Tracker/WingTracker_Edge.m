function [Wing] = WingTracker_Edge(vid, Mask, thresh, debug)
%% WingTracker: tracks wings in rigid teher
%   INPUTS:
%       vid     : grey-scale video matrix
%       Mask    : optional predefined mask
%       debug   : playback all frames if on
%   OUTPUTS:
%       Wing    : structure containing L & R wing angles and mask points
%---------------------------------------------------------------------------------------------------------------------------------
q = squeeze(vid);
dim = size(q);
if length(dim)==3
    q = reshape(vid,[dim(1)*dim(2) dim(3)]);
    q = medfilt1(single(q),10,[],2);
    q = q/max(q(:));
    q = reshape(q,dim);
else
    dim(3) = 1;
    q = reshape(vid,[dim(1)*dim(2) dim(3)]);
    q = medfilt1(single(q),1,[],2);
    q = q/max(q(:));
    q = reshape(q,dim);
end
vid = flipud(q);

if debug
    FIG = figure (500); clf
    FIG.Color = [0.3 0.3 0.3];
end

Wing.R = zeros(dim(3),1);
Wing.L = zeros(dim(3),1);
h = waitbar(0,'Finding Angles');
for jj = 1:dim(3)
    frame = vid(:,:,jj);
    Wing.R(jj) = calculateAngle(frame, Mask.R.mask, Mask.R.sub, [.1 .06  45 -10], Mask.R.ang, thresh, debug);
    Wing.L(jj) = calculateAngle(frame, Mask.L.mask, Mask.L.sub, [.1 .06 135  10], Mask.L.ang, thresh, debug);

    if debug
        figure (500) ; cla
        imagesc(frame);
        axis xy off equal;
        xlim([0 dim(2)])
        ylim([0 dim(1)])

        rM = tand(Wing.R(jj)); 
        line([Mask.R.center(1)+10 Mask.R.center(1)+75*cosd(Wing.R(jj))],...
            [rM*10+Mask.R.center(2) Mask.R.center(2)+75*sind(Wing.R(jj))], 'Color', 'r', 'LineWidth', 2);

        lM = tand(Wing.L(jj));
        line([Mask.L.center(1)-10 Mask.L.center(1)+75*cosd(Wing.L(jj))],...
            [-10*lM+Mask.L.center(2) Mask.L.center(2)+75*sind(Wing.L(jj))], 'Color', 'g', 'LineWidth', 2);

    end
    % Angles relative to vertical
    Wing.R(jj) = 90-(90-Wing.R(jj)); 
    Wing.L(jj) = 90-(Wing.L(jj)-90);
    waitbar(jj/dim(3),h);
end
delete(h)
          
end

%% Calculates the angle of a wing
function angle = calculateAngle(frame, mask, sub, initialVals, th, threshold, debug)
% th = angles
% frame = current frame
% sub = only angles within certain range e.g. [-10 90]
val = frame(mask);
val = val(sub);
val = val(val<=threshold); % intensity
th  = th (val<=threshold); % angles
opt = lsqcurvefit(@myfit,initialVals,th,double(val), [], [], optimset('Display', 'off'));
angle = opt(3);

% check results
if debug
    figure(10); cla; hold on
    scatter(th, val)
    scatter(th, opt(1) + opt(2)*tanh((th-opt(3))./opt(4)))
    line([angle angle],[0 threshold])
end  
end

%% The sinusoidal fit function used on the data to calculate the angle of a wing
function y = myfit(x,xdata)
A = x(1);
B = x(2);
C = x(3);
D = x(4);

y = A + B * tanh( (xdata - C) / D );
end
