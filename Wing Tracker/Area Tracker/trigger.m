function [Wing] = trigger(filter,Threslow,vid,debug)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
close wing_tracker_gui
[Wing] = WingTracker_Area(vid,debug,Threslow,filter);
end

