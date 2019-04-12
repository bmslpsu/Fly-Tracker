
%% Select File(s) %%
%---------------------------------------------------------------------------------------------------------------------------------
clear;close all;clc

root = 'H:\EXPERIMENTS\Experiment_Asymmetry_Control_Verification\HighContrast\0\Vid\';

[files, dirpath] = uigetfile({'*.mat', 'DAQ-files'}, ... % select video files
    'Select fly trials', root, 'MultiSelect','on');
FILES = cellstr(files)';
clear files

nTrial = length(FILES); % total # of trials

%% Load video data & run tracking software %%
%---------------------------------------------------------------------------------------------------------------------------------
close all
for jj = 1:nTrial
    % Load video data
    load([dirpath FILES{jj}]); % load video data
    disp('Load File: Done')
    
    % Set tracking parametrs
    debug = false;
    
    % Make Mask
%     [Wing.Mask] = MakeWingMask(vidData);
    close all
    
    % Run tracking
    tic
%     [lAngles, rAngles] = curvedWingEdgeAnalyzer_V3(vidData, Wing.Mask.R.points, Wing.Mask.L.points, ...
%         Wing.Mask.R.center, Wing.Mask.L.center, 0.25, debug);
    [lAngles, rAngles, lCenterPos, rCenterPos, lMask, rMask] = curvedWingEdge(vidData, 0.35, debug, '');
    toc
    
    Wing.Time = t_v;
    Wing.Ang.L = lAngles';
    Wing.Ang.R = rAngles';
    
    Mask.L.center = lCenterPos;
    Mask.R.center = rCenterPos;
	Mask.L.points = lMask;
	Mask.R.points = rMask;

    % Hampel filter
	Wing.Ang.hL = hampel(Wing.Time, Wing.Ang.L, 50, 4);
    Wing.Ang.hR = hampel(Wing.Time, Wing.Ang.R, 50, 4);
    
    % Plot angles
    figure (1) ; clf ; hold on
    plot(Wing.Time,Wing.Ang.L,'r')
    plot(Wing.Time,Wing.Ang.R,'g')
	plot(Wing.Time,Wing.Ang.hL,'m')
    plot(Wing.Time,Wing.Ang.hR,'c')

    beep on
    beep
    pause(1)
    beep
    
    
    pause
    
    % Save data
    disp('Save Data...')
    save([dirpath 'WingAngles\' FILES{jj} ],'-v7.3','Wing','Mask');  
end


