%% Select File(s) %%
%---------------------------------------------------------------------------------------------------------------------------------
clear;close all;clc

% root = 'H:\Experiment_HeadExcitation\Chirp\Normal\Vid\';
root = 'E:\Experiment_HeadExcitation\SOS\Vid\';
[files, dirpath] = uigetfile({'*.mat', 'DAQ-files'}, ... % select video files
    'Select fly trials', root, 'MultiSelect','on');

%% Parse File Name Data %%
%---------------------------------------------------------------------------------------------------------------------------------
% Check how many files are loaded
if ischar(files)
    FILES{1} = files;
else
    FILES = files;
end
clear files

% Preallocate arrays to store files name data
nTrial = length(FILES);     % total # of trials

%% Load video data & run tracking software %%
%---------------------------------------------------------------------------------------------------------------------------------
for jj = 1:nTrial
    % Load video data
    load([dirpath FILES{jj}]); % load video data
    disp('Load File: Done')
    
    % Ret tracking parametrs
    nPoints = 4;
    playBack = 10;
    debug = 1;
    
    % Run tracking
    [hAngles] = GetHeadAngle_V0(vidData,t_v,nPoints,playBack,debug);
    
    % Filter head angles
    Fs = 1/mean(diff(t_v)); % sampling rate [Hz]
    Fc = 20; % cutoff frequency for head angles [Hz]
    [b, a] = butter(2, 15/(Fs/2),'low');  % filter design
    hAnglesFilt = filtfilt(b,a,hAngles);  % zero-phase filter for head angles [deg]
    
    % Display angles
    figure (1); clf ; hold on ; title('Head Angles: Press space to save')
        ylabel('deg') ; xlabel('time') ;
        plot(t_v,hAngles,'b','LineWidth',2) % original data
        plot(t_v,hAnglesFilt,'r','LineWidth',1) % filtered data
        grid on; grid minor ; box on
        xlim([0 max(t_v)])
        
  	pause

    % Save data
    disp('Save Data...')
    save([ dirpath 'Angles\' FILES{jj} ],'-v7.3','hAngles','t_v');
    
    close all
    clc
end