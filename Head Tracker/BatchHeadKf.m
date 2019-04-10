%% Select File(s) %%
%---------------------------------------------------------------------------------------------------------------------------------
clear;close all;clc

root = 'W:\Research\Walking Chirp mat';
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

[D,~,~,~] = GetFileData(FILES);

%% Load video data & run tracking software %%
%---------------------------------------------------------------------------------------------------------------------------------
for jj = 1:nTrial
    % Load video data
    load([dirpath FILES{jj}]); % load video data
    disp('Load File: Done')
   
    Vid_edit = zeros(size(Vid));
    for x = 1:length(VidTime)
        Vid_edit(:,:,x) = ImageProcess2(Vid(:,:,x));
    end
    
    
    % Ret tracking parametrs
    nPoints = 3;
    playBack = 15;
    debug = 1;
    
    % Run tracking
    [hAngles] = HeadTracker(Vid_edit,VidTime,nPoints,playBack,debug);
    
    % Filter head angles
    Fs = 1/mean(diff(VidTime)); % sampling rate [Hz]
    Fc = 20; % cutoff frequency for head angles [Hz]
    [b, a] = butter(2, 15/(Fs/2),'low');  % filter design
    hAnglesFilt = filtfilt(b,a,hAngles);  % zero-phase filter for head angles [deg]
    
    % Display angles
    figure (1); clf ; hold on ; title('Head Angles: Press space to save')
        ylabel('deg') ; xlabel('time') ;
        plot(VidTime,hAngles,'b','LineWidth',2) % original data
        plot(VidTime,hAnglesFilt,'r','LineWidth',1) % filtered data
        grid on; grid minor ; box on
        xlim([0 max(VidTime)])
        
  	pause
t_v = VidTime;
    % Save data
    disp('Save Data...')
    save([ dirpath 'Angles\' 'fly_' num2str(D{jj,1}) '_trial_' num2str(D{jj,2}) '_amp_' num2str(D{jj,3}) '.mat' ],'-v7.3','hAngles','t_v');
    
    close all
    clc
end