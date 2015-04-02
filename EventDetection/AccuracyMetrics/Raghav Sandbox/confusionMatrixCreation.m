load test1Day.mat

[onEventsAgg, offEventsAgg, allEventsAgg] = GLR_EventDetection(agg, 80,15,10,-20,1,0,4);

[onEventsRef, offEventsRef, allEventsRef] = GLR_EventDetection(refrigerator, 80,15,10,-20,1,0,4);
[onEventsHot, offEventsHot, allEventsHot] = GLR_EventDetection(hotbox, 80,15,10,-20,1,0,4);
[onEventsH10P, offEventsH10P, allEventsH10P] = GLR_EventDetection(h10p, 80,15,10,-20,1,0,4);
[onEventsHVAC1, offEventsHVAC1, allEventsHVAC1] = GLR_EventDetection(HVAC1, 80,15,10,-20,1,0,4);
[onEventsHVAC2, offEventsHVAC2, allEventsHVAC2] = GLR_EventDetection(HVAC2, 80,15,10,-20,1,0,4);

figure(3)
hold on
subplot(2,1,1)
plot(onEventsAgg,'b')
title('All Aggregate ON events detected')
xlabel('Time of day (s)')
subplot(2,1,2)
plot(onEventsRef,'r')
title('Submetered Refrigerator ON events detected')
xlabel('Time of day (s)')
hold off

figure(4)
hold on
subplot(2,1,1)
plot(onEventsAgg,'b')
title('Aggregate ON events detected')
xlabel('Time of day (s)')
subplot(2,1,2)
plot(onEventsHot,'r')
xlabel('Time of day (s)')
title('Submetered Hot Box ON events detected')
hold off

figure(5)
hold on
subplot(2,1,1)
plot(onEventsAgg,'b')
title('Aggregate ON events detected')
xlabel('Time of day (s)')
subplot(2,1,2)
plot(onEventsH10P,'r')
xlabel('Time of day (s)')
title('Submetered H10P ON events detected')
hold off


figure(6)
hold on
subplot(2,1,1)
plot(onEventsAgg,'b')
title('Aggregate ON events detected')
xlabel('Time of day (s)')
subplot(2,1,2)
plot(onEventsHVAC1,'r')
xlabel('Time of day (s)')
title('Submetered HVAC1 ON events detected')
hold off

figure(7)
hold on
subplot(2,1,1)
plot(onEventsAgg,'b')
title('Aggregate ON events detected')
xlabel('Time of day (s)')
subplot(2,1,2)
plot(onEventsHVAC2,'r')
xlabel('Time of day (s)')
title('Submetered HVAC2 ON events detected')
hold off

onEventsAgg1 = onEventsAgg;
for i = 31:length(onEventsAgg1)-30;
    if and(onEventsRef(1,i) == 1,onEventsAgg1(1,i) == 1);
        onEventsAgg1(1,i) = 2;
    elseif and(onEventsRef(1,i) == 1, not(isempty(find(onEventsAgg1(1,i-30:i+30),1))))
        onEventsAgg1(1,i-30 + find(onEventsAgg1(1,i-30:i+30),1)) = 2;
    end
end

figure(3)
subplot(2,1,1)
hold on
plot(onEventsAgg1,'b')
hold off

onEventsAgg2 = onEventsAgg1;
for i = 31:length(onEventsAgg2)-30;
    if and(onEventsHot(1,i) == 1,onEventsAgg2(1,i) == 1);
        onEventsAgg2(1,i) = 3;
    elseif and(onEventsHot(1,i) == 1, not(isempty(find(onEventsAgg2(1,i-30:i+30),1))))
        onEventsAgg2(1,i-30 + find(onEventsAgg2(1,i-30:i+30),1)) = 3;
    end
end

figure(4)
subplot(2,1,1)
hold on
plot(onEventsAgg2,'b')

onEventsAgg3 = onEventsAgg2;
for i = 31:length(onEventsAgg3)-30;
    if and(onEventsH10P(1,i) == 1,onEventsAgg3(1,i) == 1);
        onEventsAgg3(1,i) = 4;
    elseif and(onEventsH10P(1,i) == 1, not(isempty(find(onEventsAgg3(1,i-30:i+30),1))))
        onEventsAgg3(1,i-30 + find(onEventsAgg3(1,i-30:i+30),1)) = 4;
    end
end

figure(5)
subplot(2,1,1)
hold on
plot(onEventsAgg3,'b')

onEventsAgg4 = onEventsAgg3;
for i = 31:length(onEventsAgg4)-30;
    if and(onEventsHVAC1(1,i) == 1,onEventsAgg4(1,i) == 1);
        onEventsAgg4(1,i) = 5;
    elseif and(onEventsHVAC1(1,i) == 1, not(isempty(find(onEventsAgg4(1,i-30:i+30),1))))
        onEventsAgg4(1,i-30 + find(onEventsAgg4(1,i-30:i+30),1)) = 5;
    end
end

figure(6)
subplot(2,1,1)
hold on
plot(onEventsAgg4,'b')

onEventsAgg5 = onEventsAgg4;
for i = 31:length(onEventsAgg5)-30;
    if and(onEventsHVAC2(1,i) == 1,onEventsAgg5(1,i) == 1);
        onEventsAgg5(1,i) = 6;
    elseif and(onEventsHVAC2(1,i) == 1, not(isempty(find(onEventsAgg5(1,i-30:i+30),1))))
        onEventsAgg5(1,i-30 + find(onEventsAgg5(1,i-30:i+30),1)) = 6;
    end
end

figure(7)
subplot(2,1,1)
hold on
plot(onEventsAgg5,'b')

truthOnDCSID = onEventsAgg5;
% Remove non-events
truthOnDCSID(truthOnDCSID == 0) = [];
% Make DCSID of "Others" 0, and "Ref" to "HVAC2" be 1 to 5
truthOnDCSID = truthOnDCSID - 1;

figure(8)
hold on
subplot(3,1,1)
plot(truthOnDCSID,'b')
title('True ON Appliance')
xlabel('ON event index')
ylabel('Appliance Class No.')
hold off

[ONdcsID,OFFdcsID,TOTdcsID] = FullDisaggregation( agg, onEventsAgg, offEventsAgg, allEventsAgg );

guessOnDCSID = ONdcsID;
% Remove non-events
guessOnDCSID(onEventsAgg5 == 0) = [];

figure(8)
hold on
subplot(3,1,2)
plot(guessOnDCSID,'b')
title('ON Appliance Classification')
xlabel('ON event index')
hold off

difference = guessOnDCSID - truthOnDCSID;
figure(8)
hold on
subplot(3,1,3)
plot(difference,'o')
plot(1:length(difference),zeros(length(difference)),'r')
title('Error in Classification (POINTS SHOULD BE AT ZERO)')
xlabel('ON event index')
hold off

truthOn = prtDataSetClass;
truthOn.targets = truthOnDCSID';
truthOn.data = truthOnDCSID';
guessOn = prtDataSetClass;
guessOn.targets = truthOnDCSID';
guessOn.data = guessOnDCSID';
figure(9)
prtScoreConfusionMatrix(guessOn,truthOn)
