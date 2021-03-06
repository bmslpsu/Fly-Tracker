function [Vid_edit] = ImageProcess1(IMG)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
thresh.low = 20;    % below this is 1
thresh.high = 100; 
thresh.Idx = (IMG >= thresh.low) & (IMG <= thresh.high); % find pixels in range
IMG(thresh.Idx) = 1; % convert to bianary above threshold
IMG(~thresh.Idx) = 0;  % convert to bianary below threshold
IMG = logical(IMG);

IMG= medfilt2(IMG); % median filter

IMG = imfill(IMG,'holes'); % fill in small holes

IMG= bwareaopen(IMG, 50); % get rid of disconnected objects

SE.erode =  strel('disk',2,8); % shape to use for erode and dilate functions
%Vid_edit= imerode(IMG,SE.erode); % erode

Vid_edit = IMG;
end

imbinarize
bwareopen
erode
