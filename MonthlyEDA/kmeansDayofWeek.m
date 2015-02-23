load('label.mat')
label(:,3)=shData(1:length(label(:,1)),2);
kmeansGroups = kmeans(label(:,3),7);
data = [label(:,1), kmeansGroups, label(:,3)];

result = [];
group =[];
daySum = [];
for g=1:7
    n = 0;
    for i=1:length(data(:,1))
        if data(i,2)==g
            n = n+1;
            group(n,:)= [data(i,1) data(i,3)];
        end
        % result = [result group];
    end
    for k = 1:7
        daySum(g,k)= sum(group(:,1) == k-1);
    end
end

plot(daySum(1,:),'r'); hold on
plot(daySum(2,:),'b');
plot(daySum(3,:),'g');
plot(daySum(4,:),'m');
plot(daySum(5,:),'y');
plot(daySum(6,:),'c');
plot(daySum(7,:),'k');
xlabel('Day of the Week (1 = Sunday, 2 = Monday,...,7 = Saturday');
ylabel('Frequency in each group');
legend('Group 1','Group 2','Group 3','Group 4','Group 5','Group 6','Group 7');