function [HeadAngle] = HeadCMTrack(vid)
vid = squeeze(vid);         % get rid of singleton dimension
[~,~,nFrame] = size(vid);
% Make Mask
[Mask] = HeadMask(vid,debug);
Poly = impoly(gca, Mask.R.points);
HMask = createMask(Poly);
% Pick thresholds
thresh = 50; % above = 1
% Run CM tracking
Angle = zeros(nFrame,1);
for kk = 1:nFrame   
    IMG{1} = vid(:,:,kk); % get frame
    IMG{2} = medfilt2(IMG{1}); % median filter
    IMG{3} = IMG{2};
    thresh.Idx = (IMG{3} >= thresh); % find pixels in range
    
    IMG{3}(thresh.Idx) = 1;                 % convert to bianary above threshold
    IMG{3}(~thresh.Idx) = 0;                % convert to bianary below threshold
    IMG{3} = logical(IMG{3});
    Frame = IMG{3};
    Angle(kk) = calculateAngle(Frame, HMask, Mask.R.center);
    if debug
     figure (1)
     imshow(IMG{3})
     hold on
     h.R = animatedline('Color','r','LineWidth',2);
     addpoints(h.R , Mask.R.center(1),Mask.R.center(2));
     addpoints(h.R , Mask.R.center(1)+100,Mask.R.center(2)+tand(Wing.Angle.R(kk))*100);
    end
end
end
%% Internal Function Definitions %%
%---------------------------------------------------------------------------------------------------------------------------------
function angle = calculateAngle(frame, mask, center)
val = frame(mask);
tot_mass = sum(val(:));
[ii,jj] = ndgrid(1:size(val,1),1:size(val,2));
R = sum(ii(:).*val(:))/tot_mass;
C = sum(jj(:).*val(:))/tot_mass;



