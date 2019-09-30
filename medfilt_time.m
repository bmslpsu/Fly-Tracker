function [VID] = medfilt_time(vid,n)
%% medfilt_time: applies median filter to greayscale video in time
%   INPUT:
%       vid         : video data
%       n           : # frames to filter
%   OUTPUT:
%       VID         : filtered video data
%---------------------------------------------------------------------------------------------------------------------------------
A = squeeze(vid);
dim = size(A);
B = reshape(A,[dim(1)*dim(2) dim(3)]);
C = medfilt1(single(B),n,[],2);
D = C/max(C(:));
VID = uint8(reshape(D,dim));
end