function live_stream_gui_test
%% Initialize Data:

%% Main Code
% Select a data set from the pop-up menu, then
% click the toggle button. Clicking the button
% plots the selected data in the axes.

%  Create and then hide the GUI as it is being constructed.

columnChoice = 2;
colorValues = [0 0 1];
f = figure('Visible','off','Position',[270,1000,900,570]);
shdata = zeros(200,2);

%  Construct the components.
hstart = uicontrol('Style','togglebutton','String','Start',...
    'Position',[630,460,140,50],...
    'Callback',{@start_Callback});

htext = uicontrol('Style','text','String','Select Data',...
    'Position',[650,380,120,30]);

hpopup = uicontrol('Style','popupmenu',...
    'String',{'Total Power Phase A','Total Power Phase B'},...
    'Position',[600,300,200,50],...
    'Callback',{@popup_menu_Callback});
ha = axes('Units','Pixels','Position',[100,120,400,370]);
%hb = axes('Units', 'Pixels', 'Position', [600, 100, 200, 185]);
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
[conn, mySQLquery] = setupDatabaseConnection;


    function popup_menu_Callback(source,eventdata)
        % Determine the selected data set.
        str = get(source, 'String');
        val = get(source,'Value');
        % Set current data to the selected data set.
        switch str{val};
            case 'Total Power Phase A' % User selects Peaks.
                columnChoice = 2;
            case 'Total Power Phase B' % User selects Membrane.
                columnChoice = 3;
        end
    end

% Push button callbacks. Each callback plots current_data in
% the specified plot type.
    
    function start_Callback(hObject,eventdata,handles)
        if get(hObject,'Value')
            set(hObject,'String','Streaming');
        else set(hObject,'String','Start');
        end
        
            a1 = annotation('textbox', [.675, .400, .200, .050],...
                'String', 'Maximum Power: ', 'Color', colorValues, ...
                'FontWeight', 'bold');
            a2 = annotation('textbox', [.675, .300, .200, .050],...
                'String', 'Average Power: ', 'Color', colorValues, ...
                'FontWeight', 'bold');
        
            axes(ha);
            mplot(1) = plot((1:200)', shdata(:,columnChoice));
            while(get(hObject, 'Value'))
                shdata = getshdata(conn, mySQLquery);
                set(mplot(1), 'YData', shdata(:,columnChoice));
                pause(0.01);
                drawnow;
                
                colChoice = shdata(:,columnChoice);
                maxPower = max(colChoice);
                maxPowerRecent = max(colChoice(180:200));
                minPowerRecent = min(colChoice(180:200));
                maxPowerString = ['Maximum Power: ' num2str(maxPower)];
                averagePower = mean(colChoice);
                averagePowerString = ['Average Power: ' num2str(averagePower)];
                
                if maxPower > 5000
                    colorValues = [1 0 0];
                else if maxPowerRecent - minPowerRecent > 30
                    colorValues = [1 .5 0];
                    else
                      colorValues = [0 0 1];
                    end
                end
                
                delete(a1);
                delete(a2);
                a1 = annotation('textbox', [.675, .400, .200, .050],...
                'String', maxPowerString, 'Color', colorValues, ...
                'FontWeight', 'bold');
                a2 = annotation('textbox', [.675, .300, .200, .050],...
                'String', averagePowerString, 'Color', colorValues, ...
                'FontWeight', 'bold');
            end
    end
end