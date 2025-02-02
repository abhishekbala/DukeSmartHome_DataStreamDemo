function [l] = simplifiedGLREventDetection(data)
% DETECT EVENTS USING GENERALIZED LIKELIHOOD RATIO

wa = 100;
wb = 100;
current = wb;
startIndex = current;
wl = 50;
vt = 35;
dataLength = length(data);
l = zeros(1, dataLength);
s = zeros(1, dataLength);
v = zeros(1, dataLength);


for time = 150:(length(data) - 150)
    current = time;
    meana = mean(awgn(data(current : current + wa - 1), 0.1));
    sigmaa = std(awgn(data(current : current + wa - 1), 0.1));
    meanb = mean(awgn(data(current - wb + 1: current), 0.1));
    sigmab = std(awgn(data(current - wb + 1 : current), 0.1));
    xn = data(current);
    
    l(current) = - (xn - meana)^2 / (2*sigmaa) + (xn - meanb)^2 / (2*sigmab);
end

% while startIndex + wl - 1 + wa < length(data)
%     startIndex = startIndex + 1;
%     endIndex = startIndex + wl - 1;
%     for wi = 1 : wl
%         current = startIndex + wi;
%         meana = mean(awgn(data(current : current + wa - 1), 0.1));
%         sigmaa = std(awgn(data(current : current + wa - 1), 0.1));
%         meanb = mean(awgn(data(current - wb + 1: current), 0.1));
%         sigmab = std(awgn(data(current - wb + 1 : current), 0.1));
%         xn = data(current);
%         
%         l(current) = - (xn - meana)^2 / (2*sigmaa) + (xn - meanb)^2 / (2*sigmab);
%     end
%     
%     for wi = 1 : wl
%         current = startIndex + wi;
%         s(current) = sum(l(current : endIndex));
%     end
%     
%     smaxi = find(s(startIndex : endIndex) == max(s(startIndex : endIndex)));
%     smaxi = startIndex - 1 + smaxi;
%     v(smaxi) = v(smaxi) + 1;
% end
% 
% 
% sum(v);
% v(v < vt) = 0;
% v(v >= vt) = 1;
% v = v.*(data');
% 
% clf;
% figure(1);
% plot(v);
% title('Vote Counts');
% 
% figure(2);
% hold on;
% plot(data);
% plot(v, 'ro', 'linewidth', 2);
% hold off;
% title('Data Plot');
figure(1);
plot(data);

figure(2);
plot(l);
title('Likelihood Ratio');

end