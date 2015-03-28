function [ device_Qi_On device_Qi_Off ] = Class( data, times, parameters, deviceOnID, deviceOffID )
%CLASS Summary of this function goes here
%   Detailed explanation goes here

%% Steps needed: 

% Input: (data, times, parameters , deviceName)
% Output: [device_Qi_ON, device_Qi_OFF]

% Run event detection on aggregate data
% 1. Classify using existing trained data


% 2. Create a two 2 x N vectors of information corresponding to ON and OFF
% IDS
%       1st Row: Time stamps of events in Unix time
%       2nd Row: Corresponding Decision IDs
%   For example: myOnEvents = [ 9.3e9, 9.315e9, 9.316e9, 9.321e9; 1, 2, 1, 3]
%               myOffEvents = [9.31e9, 9.316e9, 9.317e9, 9.324e9; 1,2,1,3]
% 3. Given that there are M (On/Off) events for a particular device with a
% decision ID Qi: create two 1 x M vectors of information from step #2
% corresponding to the ON and OFF events for a single device with a
% decision ID Qi.
%   For example if we want to find the corresponding events for a single
%   device with decision ID Qi from step #2:
%       device_Qi_ON = [9.3e9, 9.316e9];
%       device_Qi_OFF = [9.31e9, 9.324e9];
%RETURN

%% Input check:

if nargin ~= 5
    error('Need 4 input arguments');
elseif size(data) ~= size(times)
    error('Data and time vectors need to be the same size');
end

%% This section performs Disaggregation & returns a 1 x length(Data): 




end

