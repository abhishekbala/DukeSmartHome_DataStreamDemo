function liveDisaggregation()

onFiles = prtUtilSubDir('OnFeatures','*.mat');
fullOnSet = prtDataSetClass();
for iFile = 1:length(onFiles)
    %cFile = onFiles{iFile};
    load(onFiles{iFile});
    fullOnSet = catObservations(fullOnSet, onFeatureSet);
    plot(onFeatureSet)
end
%
offFiles = prtUtilSubDir('OffFeatures','*.mat');
fullOffSet = prtDataSetClass();
for iFile = 1:length(offFiles)
    %cFile = offFiles{iFile};
    load(offFiles{iFile});
    fullOffSet = catObservations(fullOffSet, offFeatureSet);
end

%
knnClassifierOn = prtClassKnn;
knnClassifierOn.k = 5;
knnClassifierOn = knnClassifierOn.train(fullOnSet);

knnClassifierOff = prtClassKnn;
knnClassifierOff.k = 5;
knnClassifierOff = knnClassifierOff.train(fullOffSet);
Pmax = 2;
dcsID = 0;


% Creating fixed variables: myOn, myOff, myEvents
liveData = importdata('../dataCollectors/shData.csv');
aggregatePower = sum(liveData(:,2:3),2);

if(size(aggregatePower, 1) == 1 && size(aggregatePower, 2) ~= 1) % Making sure data is in right format
    aggregatePower = aggregatePower';
end

myOn = zeros(size(aggregatePower));
myOff = zeros(size(aggregatePower));


while 1
    liveData = importdata('../dataCollectors/shData.csv');
    
    aggregatePower = sum(liveData(:,2:3),2);
    dataLength = length(aggregatePower);
    
    if (length(myOn) < dataLength)
        myOn(dataLength) = 0; % Matlab code automatically fills in zeros in between
        myOff(dataLength) = 0;
    elseif (length(myOn) > dataLength)
        delta = length(myOn) - dataLength;
        myOn(1:delta) = []; % Truncates data based on python
        myOff(1:delta) = [];
    end
    
    % Event Detection
    
    % Max-Min Manipulations
    
    maxOn = find(myOn == 1, 1, 'last' );
    maxOff = find(myOff == 1, 1, 'last');
    
    myMax = max([maxOn maxOff]);
    
    if(isempty(myMax))
        myMax = 0;
    end
    
    [on, off, events] = GLR_EventDetection(aggregatePower,20,15,10,-20,1,0,4);
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
    clf; % Clear Relevant Figures
   
    
    figure(1);
    hold on;
    plot(aggregatePower);
    plot(myOn.*aggregatePower, 'ro', 'linewidth', 2);
    plot(myOff.*aggregatePower, 'go', 'linewidth', 2);
    hold off;
    title('Events detected');
    xlabel('Time Series Values (s)');
    ylabel('Power Values (W)');
    legend('Data', 'Events');
    
    % Disaggregation
    for i = (1 + trainingWindow):(dataLength-trainingWindow)
        
        if on(i) == 1
            eventWindow = aggregatePower(i-trainingWindow:i+trainingWindow)';
            eventSlope = polyfit(1:length(eventWindow),eventWindow,1);
            eventDelta = max(eventWindow) - min(eventWindow);
            eventFeatures = prtDataSetClass([eventSlope(1) eventDelta]);
            %eventFeatures = prtDataSetClass(eventWindow);
            
            knnClassOut = knnClassifierOn.run(eventFeatures);
            
            [~, dcsID] = max(knnClassOut.data);
            
            fprintf('%1.0f is the appliance ON at time %5.3f \n', dcsID, i);
            
            % The below code works while live
            % text(i,aggregatePower(i),num2str(dcsID),'Color','red','FontSize',20,'FontSmoothing','on','Margin',8);
        end
        if off(i) == 1
            eventWindow = aggregatePower(i-trainingWindow:i+trainingWindow)';
            %eventFeatures = prtDataSetClass(eventWindow);
            eventSlope = polyfit(1:length(eventWindow),eventWindow,1);
            eventDelta = max(eventWindow) - min(eventWindow);
            eventFeatures = prtDataSetClass([eventSlope(1) eventDelta]);
            knnClassOut = knnClassifierOff.run(eventFeatures);
            
            [~, dcsID] = max(knnClassOut.data);
            
            fprintf('%1.0f is the appliance OFF at time %5.3f \n', dcsID, i);
            
            % The below code works while live
            % text(i,aggregatePower(i),num2str(dcsID),'Color','green','FontSize',20,'FontSmoothing','on','Margin',8);
        end
    end
    %dcsID
    %Pmax = max(max(find(on)),max(find(off)));
    % 1 second pause
    pause(1)
end
end