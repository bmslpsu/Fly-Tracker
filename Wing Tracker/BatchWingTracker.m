
%% Select File(s) %%
%---------------------------------------------------------------------------------------------------------------------------------
clear;close all;clc

root = 'C:\Users\boc5244\Documents\Vid\';

[files, dirpath] = uigetfile({'*.mat', 'DAQ-files'}, ... % select video files
    'Select fly trials', root, 'MultiSelect','on');

if ischar(files)
    FILES{1} = files;
else
    FILES = files;
end
clear files

nTrial = length(FILES); % total # of trials

%% Load video data & run tracking software %%
%---------------------------------------------------------------------------------------------------------------------------------
for jj = 1:nTrial
    % Load video data
    load([dirpath FILES{jj}]); % load video data
    disp('Load File: Done')
    
    % Set tracking parametrs
    debug = 0;
    
    % Run tracking
    Wing = WingTracker(vidData,debug);
    Wing.Time = t_v;
    
    % Save data
    disp('Save Data...')
    save([dirpath 'WingAngles\' FILES{jj} ],'-v7.3','Wing');
    
%     close all
%     clc

    pause

end