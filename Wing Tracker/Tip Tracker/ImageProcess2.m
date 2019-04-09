function [Vid_edit] = ImageProcess2(IMG)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% thresh.low = 20;    % below this is 1
% thresh.high = 100; 
% thresh.Idx = (IMG >= thresh.low) & (IMG <= thresh.high); % find pixels in range
% IMG(thresh.Idx) = 1; % convert to bianary above threshold
% IMG(~thresh.Idx) = 0;  % convert to bianary below threshold
% IMG = logical(IMG);

% IMG= medfilt2(IMG); % median filter

IMG = imbinarize(IMG,.25);
IMG = imcomplement(IMG);
IMG = bwareaopen(IMG, 1500); % get rid of disconnected objects

% SEerode =  strel('disk',2,8); % shape to use for erode and dilate functions
% IMG = imerode(IMG,SEerode); % erode

Vid_edit = IMG;
end
