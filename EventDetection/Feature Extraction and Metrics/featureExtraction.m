%% Extract ON and OFF features
load 'smartHomeData.mat'

%% Power data for the different appliances
refrigerator = [fridgeData1; fridgeData2; fridgeData3; fridgeData4; fridgeData5; fridgeData6];
clear fridgeData1 fridgeData2 fridgeData3 fridgeData4 fridgeData5 fridgeData6
hotbox = [hotBoxData1; hotBoxData2; hotBoxData3; hotBoxData4];
clear hotBoxData1 hotBoxData2 hotBoxData3 hotBoxData4
HVAC1 = [HVAC1Data1; HVAC1Data2; HVAC1Data3; HVAC1Data4];
clear HVAC1Data1 HVAC1Data2 HVAC1Data3 HVAC1Data4
HVAC2 = [HVAC2Data1; HVAC2Data2; HVAC2Data3; HVAC2Data4; HVAC2Data5; HVAC2Data6; HVAC2Data7; HVAC2Data8];
clear HVAC2Data1 HVAC2Data2 HVAC2Data3 HVAC2Data4 HVAC2Data5 HVAC2Data6 HVAC2Data7 HVAC2Data8
clear h10pData1 h10pData2 h10pData3 h10pData4

%% Event detection (Run ONCE)
% [onEventsRef, offEventsRef, allEventsRef] = GLR_EventDetection(refrigerator, 40, 30, 25, -10, 3, 0, 6);
% onEventsRef(1,59831) = 0; onEventsRef(1,64444) = 0; onEventsRef(1,139059) = 0; onEventsRef(1,142925) = 0;
% offEventsRef(1,56310) = 0; offEventsRef(1,60039) = 0; offEventsRef(1,64657) = 0; offEventsRef(1,75364) = 0; offEventsRef(1,139260) = 0;
% offEventsRef(1,143129) = 0;
load '..\Two Features\refEvents.mat'

%[onEventsHot, offEventsHot, allEventsHot] = GLR_EventDetection(hotbox, 40,30,25,-30,3,0,4);
load '..\Two Features\hotEvents.mat'

%[onEventsHVAC1, offEventsHVAC1, allEventsHVAC1] = GLR_EventDetection(HVAC1, 40,30,25,-40,3,0,4);
load '..\Two Features\hvac1Events.mat'

%[onEventsHVAC2, offEventsHVAC2, allEventsHVAC2] = GLR_EventDetection(HVAC2, 40,20,15,-50,3,0,4);
%offEventsHVAC2(1,27631) = 0; 
load '..\Two Features\hvac2Events.mat'

clear allEventsRef allEventsHot allEventsHVAC1 allEventsHVAC2

%% Refrigerator Features
[onMatrix, offMatrix] = matForTraining(refrigerator,onEventsRef,offEventsRef);
onFeaturesMatrix = [];
offFeaturesMatrix = [];
onFeaturesMatrix = [onFeaturesMatrix; onMatrix];
offFeaturesMatrix = [offFeaturesMatrix; offMatrix];
[n,m] = size(onMatrix);
[p,q] = size(offMatrix);
onTargets = [];
offTargets = [];
onTargets = [onTargets; ones(n,1)];
offTargets = [offTargets; ones(p,1)];
onSlope = [];
offSlope = [];
onDelta = [];
offDelta = [];
onPreSlope = [];
onPostSlope = [];
offPreSlope = [];
offPostSlope = [];
for i = 1:n
    c = median(find(onMatrix(i,:)));
    eventWindow = onMatrix(i,c-10:c+10);
    eventSlope = polyfit(1:length(eventWindow),eventWindow,1);
    eventDelta = (max(eventWindow) - min(eventWindow));
    [onSlope] = [onSlope; eventSlope(1)];
    [onDelta] = [onDelta; eventDelta];
    eventWindow = onMatrix(i,1:c);
    eventSlope = polyfit(1:length(eventWindow),eventWindow,1);
    [onPreSlope] = [onPreSlope; eventSlope(1)];
    eventWindow = onMatrix(i,c:length(eventWindow))
end
for i = 1:p
    c = median(find(offMatrix(i,:)));
    eventWindow = offMatrix(i,c-10:c+10);
    eventSlope = polyfit(1:length(eventWindow),eventWindow,1);
    eventDelta = (max(eventWindow) - min(eventWindow));
    [offSlope] = [offSlope; eventSlope(1)];
    [offDelta] = [offDelta; eventDelta];
end

%% HotBox Features
[onMatrix, offMatrix] = matForTraining(hotbox,onEventsHot,offEventsHot);
onFeaturesMatrix = [onFeaturesMatrix; onMatrix];
offFeaturesMatrix = [offFeaturesMatrix; offMatrix];
[n,m] = size(onMatrix);
[p,q] = size(offMatrix);
onTargets = [onTargets; 2*ones(n,1)];
offTargets = [offTargets; 2*ones(p,1)];
for i = 1:n
    c = median(find(onMatrix(i,:)));
    eventWindow = onMatrix(i,c-10:c+10);
    eventSlope = polyfit(1:length(eventWindow),eventWindow,1);
    eventDelta = (max(eventWindow) - min(eventWindow));
    [onSlope] = [onSlope; eventSlope(1)];
    [onDelta] = [onDelta; eventDelta];
end
for i = 1:p
    c = median(find(offMatrix(i,:)));
    eventWindow = offMatrix(i,c-10:c+10);
    eventSlope = polyfit(1:length(eventWindow),eventWindow,1);
    eventDelta = (max(eventWindow) - min(eventWindow));
    [offSlope] = [offSlope; eventSlope(1)];
    [offDelta] = [offDelta; eventDelta];
end

%% HVAC1 Features
[onMatrix, offMatrix] = matForTraining(HVAC1,onEventsHVAC1,offEventsHVAC1);
onFeaturesMatrix = [onFeaturesMatrix; onMatrix];
offFeaturesMatrix = [offFeaturesMatrix; offMatrix];
[n,m] = size(onMatrix);
[p,q] = size(offMatrix);
onTargets = [onTargets; 3*ones(n,1)];
offTargets = [offTargets; 3*ones(p,1)];
for i = 1:n
    c = median(find(onMatrix(i,:)));
    eventWindow = onMatrix(i,c-10:c+10);
    eventSlope = polyfit(1:length(eventWindow),eventWindow,1);
    eventDelta = (max(eventWindow) - min(eventWindow));
    [onSlope] = [onSlope; eventSlope(1)];
    [onDelta] = [onDelta; eventDelta];
end
for i = 1:p
    c = median(find(offMatrix(i,:)));
    eventWindow = offMatrix(i,c-10:c+10);
    eventSlope = polyfit(1:length(eventWindow),eventWindow,1);
    eventDelta = (max(eventWindow) - min(eventWindow));
    [offSlope] = [offSlope; eventSlope(1)];
    [offDelta] = [offDelta; eventDelta];
end


%% HVAC2 Features
[onMatrix, offMatrix] = matForTraining(HVAC2,onEventsHVAC2,offEventsHVAC2);
onFeaturesMatrix = [onFeaturesMatrix; onMatrix];
offFeaturesMatrix = [offFeaturesMatrix; offMatrix];
[n,m] = size(onMatrix);
[p,q] = size(offMatrix);
onTargets = [onTargets; 4*ones(n,1)];
offTargets = [offTargets; 4*ones(p,1)];
for i = 1:n
    c = median(find(onMatrix(i,:)));
    eventWindow = onMatrix(i,c-10:c+10);
    eventSlope = polyfit(1:length(eventWindow),eventWindow,1);
    eventDelta = (max(eventWindow) - min(eventWindow));
    [onSlope] = [onSlope; eventSlope(1)];
    [onDelta] = [onDelta; eventDelta];
end
for i = 1:p
    c = median(find(offMatrix(i,:)));
    eventWindow = offMatrix(i,c-10:c+10);
    eventSlope = polyfit(1:length(eventWindow),eventWindow,1);
    eventDelta = (max(eventWindow) - min(eventWindow));
    [offSlope] = [offSlope; eventSlope(1)];
    [offDelta] = [offDelta; eventDelta];
end

%% Not using PCA features
%onFeatureSetPCA = prtDataSetClass;
%offFeatureSetPCA = prtDataSetClass;

%onFeatureSetPCA.data = onFeaturesMatrix;
%onFeatureSetPCA.targets = onTargets;

%offFeatureSetPCA.data = offFeaturesMatrix;
%offFeatureSetPCA.targets = offTargets;
 
%pcaON = prtPreProcPca('nComponents',1);
%pcaON = pcaON.train(onFeatureSetPCA);
%pcaONFeatures = pcaON.run(onFeatureSetPCA);
%plot(pcaONFeatures)

%pcaOFF = prtPreProcPca('nComponents',1);
%pcaOFF = pcaOFF.train(offFeatureSetPCA);
%pcaOFFeatures = pcaOFF.run(offFeatureSetPCA);
%plot(pcaOFFeatures)

%% Collect all features together into prtDataClass
onFeatures = prtDataSetClass;
onFeatures.data = [onSlope onDelta];
onFeatures.targets = onTargets;
% Create HVAC Mode 1 and HVAC Mode 2 features by labelling all feature
% points above 1E4 for Feature 2 as 5 (HVAC Mode 2)
onFeatures.targets(onFeatures.data(:,2) > 1e4) = 5;
onFeatures.targets(onFeatures.targets(:,1) == 4) = 3;
onFeatures.targets(onFeatures.targets(:,1) == 5) = 4;
onFeatures.classNames = {'Refrigerator','Hotbox','HVACMode1','HVACMode2'};
figure(1)
plot(onFeatures)

offFeatures = prtDataSetClass;
offFeatures.data = [offSlope offDelta];
offFeatures.targets = offTargets;
% Create HVAC Mode 1 and HVAC Mode 2 features by labelling all feature
% points above 1E4 for Feature 2 as 5 (HVAC Mode 2)
offFeatures.targets(offFeatures.data(:,2) > 1e4) = 5;
offFeatures.targets(offFeatures.targets(:,1) == 4) = 3;
offFeatures.targets(offFeatures.targets(:,1) == 5) = 4;
offFeatures.classNames = {'Refrigerator','Hotbox','HVACMode1','HVACMode2'};
figure(2)
plot(offFeatures)
