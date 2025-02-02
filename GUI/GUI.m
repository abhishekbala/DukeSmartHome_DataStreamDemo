function GUI
%% Initialize Data:
clear; clc;

%% Global Variables
option = 'Refrigerator';

%% GUI setup
%  Create and then hide the GUI as it is being constructed.
f = figure('Visible','off','Position',[270,1000,1200,700]);


%  Construct the components.
hstart = uicontrol('Style','togglebutton','String','Start',...
    'Position',[200,330,200,50],...
    'Callback',{@start_Callback},'FontSize',20);
htitle1 = uicontrol('Style','text','String','Smart Home Aggregate Power Data','FontWeight','Bold',...
    'Position',[250,650,400,30],'FontSize',20,'FontName','Helvetica','BackgroundColor','w');

htitle2 = uicontrol('Style','text','String','Predicted vs Actual Power Data of','FontWeight','Bold',...
    'Position',[185,250,400,25],'FontSize',20,'FontName','Helvetica','BackgroundColor','w');

ha = axes('Units','Pixels','Position',[150,450,600,200],'Visible','off','Box','on');
hb = axes('Units','Pixels','Position',[150, 50, 600, 200],'Visible','off','Box','on');
hpanel = uipanel('Units','Pixels','Title','Appliance Status','FontSize',20,'FontWeight','Bold',...
    'Position',[150,290,300,140],'BackgroundColor','w','FontName','Helvetica');
hrf = uicontrol('Parent',hpanel,'Style','text','String','Refrigerator',...
    'Position',[60,95,140,30],'FontSize',16,'FontName','Helvetica','BackgroundColor','w');
hhb = uicontrol('Parent',hpanel,'Style','text','String','Hot Box',...
    'Position',[60,65,140,30],'FontSize',16,'FontName','Helvetica','BackgroundColor','w');
hhv1 = uicontrol('Parent',hpanel,'Style','text','String','HVAC Mode 1',...
    'Position',[60,35,140,30],'FontSize',16,'FontName','Helvetica','BackgroundColor','w');
hhv2 = uicontrol('Parent',hpanel,'Style','text','String','HVAC Mode 2',...
    'Position',[60,5,140,30],'FontSize',16,'FontName','Helvetica','BackgroundColor','w');
hpopup = uicontrol('Style','popupmenu',...
    'String',{'Refrigerator','Hot Box','HVAC System'},...
    'Position',[200,230,200,50],...
    'Callback',{@popup_menu_Callback},...
    'FontSize',20);
hanomaly = uicontrol('Style','text','String','Anomaly Log','FontSize',20,'FontWeight','Bold',...
    'Position',[800,600,300,50],'BackgroundColor','w','FontName','Helvetica');
hlist = uicontrol('Style','List','Position',[800,50,300,570]);



% Initialize the GUI.
% Change units to normalized so components resize automatically.
set([f,hstart,ha,hb,hpanel,hpopup,hanomaly,hlist,htitle1,htitle2],...
    'Units','normalized');
% Assign the GUI a name to appear in the window title.
set(f,'Name','Test GUI')
% Move the GUI to the center of the screen.
movegui(f,'center')
% Make the GUI visible.
set(f,'Visible','on' ,'Color','w');
align([ha,hpanel,hpopup,hstart],'distribute','none');

a = 'OFF'; b ='OFF'; c ='OFF'; d = 'OFF';

%% Dropdown menu
    function popup_menu_Callback(source,eventdata)
        % Determine the selected data set.
        str = get(source, 'String');
        val = get(source,'Value');
        switch str{val}
            case 'Refrigerator'
                option = 'Refrigerator';
            case 'Hot Box'
                option = 'Hot Box';
            case 'HVAC System'
                option = 'HVAC System';
        end
    end

%% initial plot
shData = importdata('..\dataCollectors\shData.csv');
aggregData = shData(:,2)+shData(:,3)-shData(:,4)-shData(:,5);
current_data = aggregData(end-299:end,1);  %% latest 300 seconds data
current_time = shData(end-299:end,1); %% latest 300 seconds time

event = importdata('..\EventDetection\eventData.csv');

if find(event(:,1)==current_time(1))
    greenEvent = NaN(300,1);
    redEvent = NaN(300,1);
    if find(event(:,1)==current_time(end))
    current_event=event(find(event(:,1)==current_time(1)):(find(event(:,1)==current_time(end))),:);
    greenIndex = find(current_event(:,3)~=0&current_event(:,4)==1);
    greenEvent(greenIndex) = current_data(greenIndex);
    redIndex = find(current_event(:,3)~=0&current_event(:,4)==0);
    redEvent(redIndex) = current_data(redIndex);
    end
end

axes(ha);
hold on
plot_Aggreg = plot(linspace(numel(current_data),1,numel(current_data)), current_data,'w');
set(gca, 'Xdir', 'reverse');
plot_greenEvent = plot(linspace(numel(current_data),1,numel(current_data)),greenEvent,...
    'go','LineWidth',2,'MarkerSize',8);
plot_redEvent = plot(linspace(numel(current_data),1,numel(current_data)),redEvent,...
    'ro','LineWidth',2,'MarkerSize',8);
lg1=legend([plot_Aggreg,plot_greenEvent,plot_redEvent],'Aggregate Power');%,'ON Event','OFF Event');
set(lg1,'Location','NorthOutside','Orientation','horizontal')
ylabel('Power (W)','FontSize',14);
hold off


anomalyMatrix = importdata('..\ARIMAANN\anomalyMatrix.csv');
current_actual = anomalyMatrix(:, 2);
current_predict = anomalyMatrix(:, 3);
axes(hb);
hold on
plot_predict=plot(anomalyMatrix(:,1),current_predict,'w-');
plot_actual=plot(anomalyMatrix(:,1), current_actual,'w-');
lg2=legend([plot_predict,plot_actual],'Predicted','Actual');
set(lg2,'Location','NorthOutside','Orientation','horizontal')
ylabel('Power (W)','FontSize',14);
hold off


%% WHILE LOOP
    function start_Callback(hObject,eventdata,handles)

        if get(hObject,'Value')
            set(hObject,'String','Streaming');
        else set(hObject,'String','Start');
        end
        
        while(get(hObject, 'Value'))         
            %% Input Data
            shData = importdata('..\dataCollectors\shData.csv');
            aggregData = shData(:,2)+shData(:,3)-shData(:,4)-shData(:,5);
            current_data = aggregData(end-299:end,1);  %% latest 300 seconds data
            current_time = shData(end-299:end,1); %% latest 300 seconds time
            
            event = importdata('..\EventDetection\eventData.csv');
            
            greenEventTime = event(find(event(:,3)~=0&event(:,4)==1),1);
            greenIndex = find(event(:,3)~=0&event(:,4)==1);
            greenEventValue = NaN;
            redEventValue = NaN;
            
            if current_time(1,1) < greenEventTime(1,1);
                greenEventValue = zeros(length(greenEventTime),1);
                for i = 1:length(greenEventTime)
                    greenEventValue(i,1)=current_data(find(current_time==greenEventTime(i,1)));
                end
            end
            redEventTime = event(find(event(:,3)~=0&event(:,4)==0),1);
            redIndex = find(event(:,3)~=0&event(:,4)==0);
            if current_time(1,1) < redEventTime(1,1);
                redEventValue = zeros(length(greenEventTime),1);
                for i = 1:length(redEventTime)
                    redEventValue(i,1)=current_data(find(current_time==redEventTime(i,1)));
                end
            end
            
            
            disagData = importdata('..\EventDetection\DisaggregatedPower.csv');
            
            if disagData(end, 2) <= 0 %Refrigerator
                a = 'OFF'; rfcolor = 'r';
            else
                a = 'ON'; rfcolor = 'g';
            end
            
            if disagData(end, 3) <= 0 %hotbox
                b = 'OFF'; hbcolor = 'r';
            else
                b = 'ON'; hbcolor = 'g';
            end
            
            if disagData(end, 4) <= 0 %hvac1
                c = 'OFF'; hv1color = 'r';
            else
                c = 'ON'; hv1color = 'g';
            end
            
            if disagData(end, 5) <= 0 %hvac2
                d = 'OFF'; hv2color = 'r';
            else
                d = 'ON'; hv2color = 'g';
            end
            
            
            appStatus={a,b,c,d};  % data input
            hrfs = uicontrol('Parent',hpanel,'Style','text','String',appStatus(1),...
                'Position',[210,95,60,25],'FontSize',16,'FontName','Helvetica','BackgroundColor',rfcolor);
            hhbs = uicontrol('Parent',hpanel,'Style','text','String',appStatus(2),...
                'Position',[210,65,60,25],'FontSize',16,'FontName','Helvetica','BackgroundColor',hbcolor);
            hhv1s = uicontrol('Parent',hpanel,'Style','text','String',appStatus(3),...
                'Position',[210,35,60,25],'FontSize',16,'FontName','Helvetica','BackgroundColor',hv1color);
            hhv2s = uicontrol('Parent',hpanel,'Style','text','String',appStatus(4),...
                'Position',[210,5,60,25],'FontSize',16,'FontName','Helvetica','BackgroundColor',hv2color);

            
            %% Live plot
            axes(ha);
            set(ha,'Visible','on','xlim',[1 300])
            hold on
            set(plot_Aggreg, 'YData', current_data,'Color','b');
            set(plot_greenEvent, 'YData', greenEvent,'Color','g','Marker','o','LineWidth',2,'MarkerSize',8);
            set(plot_redEvent, 'YData', redEvent,'Color','r','Marker','o','LineWidth',2,'MarkerSize',8);
            set(ha,'FontSize',12,'XTick',[0,100,200,300],...
                'XTickLabel',{datestr(current_time(300,1)/86400+719529 - 4/24,13),...
                datestr(current_time(200,1)/86400+719529 - 4/24,13),...
                datestr(current_time(100,1)/86400+719529 - 4/24,13),...
                datestr(current_time(1,1)/86400+719529 - 4/24,13)});
            drawnow
            hold off

            
            %% Prediction Plot
            anomalyMatrix = importdata('..\ARIMAANN\anomalyMatrix.csv');
            axes(hb);
            hold on
            set(hb,'Visible','on','FontSize',12,'XTick',[anomalyMatrix(1,1),anomalyMatrix(end,1)],...
                'XTickLabel',{datestr(anomalyMatrix(1,1)/1440+719529 - 4/24,15),...
                datestr(anomalyMatrix(end,1)/1440+719529 - 4/24,15)});
            % Set current data to the selected data set.
            switch option
                case 'Refrigerator'
                    current_actual = anomalyMatrix(:, 2);
                    current_predict = anomalyMatrix(:, 3);
                case 'Hot Box'
                    current_actual = anomalyMatrix(:, 5);
                    current_predict = anomalyMatrix(:, 6);
                case 'HVAC System'
                    current_actual = anomalyMatrix(:, 8);
                    current_predict = anomalyMatrix(:, 9);
            end
            set(plot_predict,'YData',current_predict,'Color','r');
            set(plot_actual,'YData',current_actual,'Color','k');
            drawnow
            hold off
            
%% Anomaly Log
            
        end
    end
end