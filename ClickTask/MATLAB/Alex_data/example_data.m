close all;
clear all;

% load the data for one rat
load block_switching_data.mat

% data is a struct array, with each array element the data for one trial
% T             length of each trial's evidence period in seconds
% leftbups      left click times on that trial 
% rightbups     left click times on that trial 
% Delta         total difference in L/R clicks
% hit           0 = rat made an error, 1 = rat got rewarded
% gamma         generative click rates for this trial, gamma = log(larger-rate/smaller-rate)
% pokedR        0 = rat went left, 1 = rat went right
% Hazard        generative hazard rate for this trial in 1/sec
% sessiondate   date of this session

% do simple analysis. This plot shows the changing hazard rate in blocks, and that gamma is changing with the blocks
H = [data(:).Hazard];
G = abs([data(:).gamma]);
figure; plot(H,'r'); hold on; plot(G, 'b')



