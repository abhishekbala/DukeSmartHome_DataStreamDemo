function simple_gui_test
%% Initialize Data:
clear; clc;
load('phaseData.mat', 'r' );
load('fridgedata.mat', 'fridgedata');
load('timevec.mat', 'timevec');
load('solarData.mat', 'solarData');

%% Global Variables
option = 'Phase A Power';
counter = 0;

%% Modifying Solar Data and Phase A data:
% Column 1: Phase A Power Data (modified by taking out solar data)
% Column 2: Phase B Power Data
% Column 3: Solar Power Data
% Column 4: Refrigerator Power Data
% Column 5: Total Power Data
myData = r;
solarData = -1*(solarData(:,1) + solarData(:,2));
myData = [myData solarData fridgedata];
myData(:,1) = myData(:,1) + solarData;
totalData = myData(:,1) + myData(:,2);
myData = [myData totalData];

%% Main Code
% Select a data set from the pop-up menu, then
% click the toggle button. Clicking the button
% plots the selected data in the axes.

%  Create and then hide the GUI as it is being constructed.
f = figure('Visible','off','Position',[270,1000,900,570]);
current_data = [myData(:,1)];

%  Construct the components.
hstart = uicontrol('Style','togglebutton','String','Start',...
    'Position',[630,460,140,50],...
    'Callback',{@start_Callback});

htext = uicontrol('Style','text','String','Select Data',...
    'Position',[650,380,120,30]);

hpopup = uicontrol('Style','popupmenu',...
    'String',{'Phase A Power', 'Phase B Power', 'Solar Power',...
    'Refrigerator Power', 'Total Power'},...
    'Position',[600,300,200,50],...
    'Callback',{@popup_menu_Callback});
ha = axes('Units','Pixels','Position',[100,120,400,370]);
hb = axes('Units', 'Pixels', 'Position', [600, 100, 200, 185]);
align([hstart,htext,hpopup],'Center','None');

% Initialize the GUI.
% Change units to normalized so components resize automatically.
set([f,ha,hstart,htext,hpopup],...
    'Units','normalized');
% Assign the GUI a name to appear in the window title.
set(f,'Name','Test GUI')
% Move the GUI to the center of the screen.
movegui(f,'center')
% Make the GUI visible.
set(f,'Visible','on');


    function popup_menu_Callback(source,eventdata)
        % Determine the selected data set.
        str = get(source, 'String');
        val = get(source,'Value');
        % Set current data to the selected data set.
        switch str{val};
            case 'Phase A Power'
                current_data = myData(:,1);
                option = 'Phase A Power';
                counter = 20;
            case 'Phase B Power'
                current_data = myData(:,2);
                option = 'Phase B Power';
                counter = 20;
            case 'Solar Power'
                current_data = myData(:,3);
                option = 'Solar Power';
                counter = 20;
            case 'Refrigerator Power'
                current_data = myData(:,4);
                option = 'Refrigerator Power';
                counter = 20;
            case 'Total Power'
                option = 'Total Power';
                current_data = myData(:,5);
                counter = 20;
        end
    end

% Push button callbacks. Each callback plots current_data in
% the specified plot type.

axes(hb);
pie(1);
    function start_Callback(hObject,eventdata,handles)
        if get(hObject,'Value')
            set(hObject,'String','Streaming');
        else set(hObject,'String','Start');
        end
        
        %axes(hb);
        %pie(1:10);
        
        axes(ha);
        latest_data = current_data(1:200);
        mplot(1) = plot(linspace(numel(latest_data),1,numel(latest_data)), latest_data);
        
        %counter = 0;
        while(get(hObject, 'Value'))
            axes(ha);
            current_data = circshift(current_data, [1,0]);
            myData(:,1) = circshift(myData(:,1), [1,0]);
            myData(:,2) = circshift(myData(:,2), [1,0]);
            myData(:,3) = circshift(myData(:,3), [1,0]);
            myData(:,4) = circshift(myData(:,4), [1,0]);
            myData(:,5) = circshift(myData(:,5), [1,0]);
            latest_data = current_data(1:200);
            %latest_data = circshift(lastest_data, [1, 0]);
            %latest_data(1) = current_data(numel(current_data));
            set(mplot(1), 'YData', latest_data);
            axis([0, 200, 0 , 4000]);
            counter = counter + 1;
            if counter == 20
                pause(0.01);
            else
                pause(0.5);
            end
            drawnow;
            
            if counter == 20
                counter = 0;
                axes(hb);
                
                switch option
                    case 'Phase A Power'
                        phaseAData = myData(:,1);
                        phaseBData = myData(:,2);
                        
                        phaseA_average = mean(phaseAData(1:200));
                        phaseB_average = mean(phaseBData(1:200));
                        
                        pie([phaseA_average, phaseB_average]);
                        legend('A','B', [525, 60,0.25,0.1]);
                    case 'Phase B Power'
                        phaseAData = myData(:,1);
                        phaseBData = myData(:,2);
                        
                        phaseA_average = mean(phaseAData(1:200));
                        phaseB_average = mean(phaseBData(1:200));
                        
                        pie([phaseA_average, phaseB_average]);
                        legend('Phase A','Phase B', [525, 60,0.25,0.1]);
                    case 'Solar Power'
                        solarPowerData = myData(:,3);
                        totalPowerData = myData(:,5);
                        
                        solarPower_average = mean(solarPowerData(1:200));
                        totalPower_average = mean(totalPowerData(1:200));
                        
                        pie([solarPower_average,...
                            totalPower_average - solarPower_average]);
                        legend('Solar Output','Other Appliances',...
                            [525, 60,0.25,0.1]);
                    case 'Refrigerator Power'
                        refrigeratorData = myData(:,4);
                        totalPowerData = myData(:,5);
                        
                        refrigerator_average = mean(refrigeratorData(1:200));
                        totalPower_average = mean(totalPowerData(1:200));
                        
                        pie([refrigerator_average,...
                            totalPower_average - refrigerator_average]);
                        legend('Refrigerator','Other Appliances',...
                            [525, 60,0.25,0.1]);
                    case 'Total Power'
                        phaseAData = myData(:,1);
                        phaseBData = myData(:,2);
                        
                        phaseA_average = mean(phaseAData(1:200));
                        phaseB_average = mean(phaseBData(1:200));
                        
                        pie([phaseA_average, phaseB_average]);
                        legend('Phase A','Phase B', [525, 60,0.25,0.1]);
                end
                
%                 phaseAData = myData(:,1);
%                 phaseBData = myData(:,2);
%                 solarPowerData = myData(:,3);
%                 refrigeratorData = myData(:,4);
%                 totalPowerData = myData(:,5);
%                 
%                 phaseA_average = mean(phaseAData(1:200));
%                 phaseB_average = mean(phaseBData(1:200));
%                 solarPower_average = mean(solarPowerData(1:200));
%                 refrigerator_average = mean(refrigeratorData(1:200));
%                 totalPower_average = mean(totalPowerData(1:200));
%                 
%                 pie([PhaseA_average, PhaseB_average]);
%                 legend('A','B', [525, 60,0.25,0.1]);
            end
        end
        
    end
end