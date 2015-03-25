function CleanDisaggregation()
%CLEANDISAGGREGATION A Live Disaggregation Method
%   A real-time event detection and classification method for appliances
%   obtaining data fed in from a python script.

[~, fullOnSet] = loadOnFiles();

[~, fullOffSet] = loadOffFiles();

%trainKNNClassifier

knnClassifierOn = prtClassKnn;
knnClassifierOn.k = 5;
knnClassifierOn = knnClassifierOn.train(fullOnSet);

knnClassifierOff = prtClassKnn;
knnClassifierOff.k = 5;
knnClassifierOff = knnClassifierOff.train(fullOffSet);

% Loading and Manipulating Data

liveData = importdata('../dataCollectors/shData.csv');
aggregatePower = sum(liveData(:,2:3),2);

if(size(aggregatePower, 1) == 1 && size(aggregatePower, 2) ~= 1) % Making sure data is in right format
    aggregatePower = aggregatePower';
end

myOn = zeros(size(aggregatePower));
myOff = zeros(size(aggregatePower));
myEvents = zeros(size(aggregatePower));

% Indicator of 1st loop:
myIndicator = 0;

% Create a stop loop:
FS = stoploop({'Click me to:', 'Exit out of the Loop'});

%% Main Loop:
while (~FS.Stop())
    liveData = importdata('../dataCollectors/shData.csv');
    
    aggregatePower = sum(liveData(:,2:3),2);
    dataLength = length(aggregatePower);
    
    if (length(myOn) < dataLength)
        myOn(dataLength) = 0; % Matlab code automatically fills in zeros in between
        myOff(dataLength) = 0;
        myEvents(dataLength) = 0;
    elseif (length(myOn) > dataLength)
        delta = length(myOn) - dataLength;
        myOn(1:delta) = []; % Truncates data based on python
        myOff(1:delta) = [];
        myEvents(1:delta) = [];
    end
    
    % Event Detection
    
    % Max-Min Manipulations
    
    maxOn = find(myOn == 1, 1, 'last' );
    maxOff = find(myOff == 1, 1, 'last');
    
    myMax = max([maxOn maxOff]);
    
    if(isempty(myMax))
        myMax = 0;
    end
    
    if(myIndicator == 0)
        [onDummy, offDummy, eventsDummy] = GLR_EventDetection(aggregatePower,20,15,10,-20,1,0,4);
        on = onDummy;
        off = offDummy;
        events = eventsDummy;
        myIndicator = 1;
    else
        dataSampleLength = dataLength - myMax;
        prev_On = myOn(1:myMax);
        prev_Off = myOff(1:myMax);
        prev_Events = myEvents(1:myMax);
        
        [onDummy, offDummy, eventsDummy] = GLR_EventDetection(aggregatePower((myMax+1):dataLength),20,15,10,-20,1,0,4);
        
        on = [prev_On' onDummy];
        off = [prev_Off' offDummy];
        events = [prev_Events' eventsDummy];
        
        onDummy = [zeros(1, myMax) onDummy];
        offDummy = [zeros(1, myMax) offDummy];
        eventsDummy = [zeros(1, myMax) eventsDummy];
    end
    trainingWindow = 10;
    
    GLRMax = find(events == 1, 1, 'last');
    
    if(isempty(GLRMax))
        GLRMax = 0;
    end
    
    % This section refreshes the event detection properly, ignoring
    % irrelevant points:
    if(GLRMax > myMax)
        on(1:maxOn) = 0;
        off(1:maxOff) = 0;
        
        myOn = myOn + on';
        myOff = myOff + off';
    end
    
    % Plotting
    PlotGraphs(myOn, myOff, aggregatePower);
    
    % Disaggregation
    for i = (1 + trainingWindow):(dataLength-trainingWindow)
        
        if onDummy(i) == 1
            knnClassOut = DisagClassifier(aggregatePower, knnClassifierOn, i, trainingWindow);
            
            [~, dcsID] = max(knnClassOut.data);
            
            % Printing Out Appliance Classification
            fprintf('%1.0f is the appliance ON at time %5.3f \n', dcsID, i);
            
            % Labeling of Graph
            % text(i,aggregatePower(i),num2str(dcsID),'Color','red','FontSize',20,'FontSmoothing','on','Margin',8);
        elseif offDummy(i) == 1
            knnClassOut = DisagClassifier(aggregatePower, knnClassifierOff, i, trainingWindow);
            
            [~, dcsID] = max(knnClassOut.data);
            
            % Printing Out Appliance Classification
            fprintf('%1.0f is the appliance OFF at time %5.3f \n', dcsID, i);
            
            % Labeling of Graph
            % text(i,aggregatePower(i),num2str(dcsID),'Color','green','FontSize',20,'FontSmoothing','on','Margin',8);
        end
    end
    
    % 1 second pause
    pause(1)
end

% Clear the Button
FS.Clear();
clear FS;
end

%% Functions

function [onFiles, fullOnSet] = loadOnFiles()
onFiles = prtUtilSubDir('OnFeatures','*.mat');
fullOnSet = prtDataSetClass();

for iFile = 1:length(onFiles)
    %cFile = onFiles{iFile};
    load(onFiles{iFile});
    fullOnSet = catObservations(fullOnSet, onFeatureSet);
end

end

function [offFiles, fullOffSet] = loadOffFiles()
offFiles = prtUtilSubDir('OffFeatures','*.mat');
fullOffSet = prtDataSetClass();

for iFile = 1:length(offFiles)
    %cFile = offFiles{iFile};
    load(offFiles{iFile});
    fullOffSet = catObservations(fullOffSet, offFeatureSet);
end

end

function PlotGraphs(myOn, myOff, aggregatePower)
clf; % Clear Relevant Figures

figure(1);
hold on;
plot(aggregatePower);
plotMyOn = myOn;
plotMyOff = myOff;
plotMyOn(plotMyOn == 0) = NaN;
plotMyOff(plotMyOff == 0) = NaN;
plot(plotMyOn.*aggregatePower, 'ro', 'linewidth', 2);
plot(plotMyOff.*aggregatePower, 'go', 'linewidth', 2);
hold off;
title('Events detected');
xlabel('Time Series Values (s)');
ylabel('Power Values (W)');
legend('Data', 'On Events', 'Off Events');
end

function [knnClassOut] = DisagClassifier(aggregatePower, knnClassifier, n, trainingWindow)
eventWindow = aggregatePower(n-trainingWindow:n+trainingWindow)';
eventSlope = polyfit(1:length(eventWindow),eventWindow,1);
eventDelta = max(eventWindow) - min(eventWindow);
eventFeatures = prtDataSetClass([eventSlope(1) eventDelta]);
%eventFeatures = prtDataSetClass(eventWindow);

knnClassOut = knnClassifier.run(eventFeatures);
end