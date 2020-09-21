% This is a MATLAB Interface for real time data reading & recording on
% Agilent E4980A
% This program is tested on MATLAB 2015b 32bits (must be 32bits due to the IVI-COM driver restriction)
% If it doesn't work, check resourceDesc @ about line 25, use
% Keysight Connection Expert to determine the real address
% The address I am using is for connection via USB.

% 2 Drivers must be installed in order to run this program
% Install the latest IVI shared component; Link: https://www.ivifoundation.org/shared_components/Default.aspx
% Install the IVI-COM driver for MATLAB 32bit; Link: https://www.keysight.com/main/software.jspx?cc=CA&lc=eng&nid=-34124.536908436.02&id=1662169

% This file is written referencing to the official example.

% Author: Runze Zuo @ University of Toronto; ECE Undergrad
% Contact: desmondzuo@gmail.com

function AgilentE4980A_Monitor

global stop
stop = 1;

disp(blanks(1)');
disp('  ML_Example1');
try
    
    S.fh = figure( 'units','pixels','position',[200 200 2000 1000],'menubar','none','name','move_fig','numbertitle','off','resize','off','keypressfcn',@f_capturekeystroke,'CloseRequestFcn',@f_closecq);
    guidata(S.fh,S)
    
    % Create driver instance
    driver = instrument.driver.AgilentE4980A();
    
    % Edit resource and options as needed.  Resource is ignored if option Simulate=true
    resourceDesc = 'USB0::0x0957::0x0909::MY46310406::0::INSTR';
    % resourceDesc = 'TCPIP0::<host_name or IP addr>::INSTR';
    
    initOptions = 'QueryInstrStatus=true, Simulate=false, DriverSetup= Model=, Trace=false';
    idquery = true;
    reset   = true;
    
    driver.Initialize(resourceDesc, idquery, reset, initOptions);
    disp('Driver Initialized');
    
    % Print a few IIviDriver.Identity properties
    disp(['Identifier:      ', driver.Identity.Identifier]);
    disp(['Revision:        ', driver.Identity.Revision]);
    disp(['Vendor:          ', driver.Identity.Vendor]);
    disp(['Description:     ', driver.Identity.Description]);
    disp(['InstrumentModel: ', driver.Identity.InstrumentModel]);
    disp(['FirmwareRev:     ', driver.Identity.InstrumentFirmwareRevision]);
    disp(['Serial #:        ', driver.DeviceSpecific.System.SerialNumber]);
    simulate = driver.DriverOperation.Simulate;
    if simulate == true
        disp(blanks(1));
        disp('Simulate:        True');
    else
        disp('Simulate:        False');
    end
    disp(blanks(1));
    
    driver.DeviceSpecific.Function.ImpedanceType = 0; % AgilentE4980AFunctionTypeCPD
    driver.DeviceSpecific.Measurement.VoltageLevel = 1;
    driver.DeviceSpecific.Measurement.Frequency = 1e5;
    driver.DeviceSpecific.Measurement.Aperture = 1;
    
    num_data_point = 1000;
    loop_param = 0;
    array_ptr = 1;
    
    test_value_max = 0.1;
    test_value_min = 0.1;
    
    recorded_data = [0, 1, -1, 0];
    
    tic
    while stop
        [parameter1,~,~,~] = driver.DeviceSpecific.Result.FormattedImpedance(0,0,0,0);
        %disp(['The value of Cp is ', num2str(parameter1 * 1000000), ' & D is ', num2str(parameter2)]);
        
        test_value = parameter1 * 1000000000000;
        
        if test_value > test_value_max
            test_value_max = test_value;
        elseif test_value < test_value_min
            test_value_min = test_value;
        end
        
        
        xlim([0 num_data_point])
        ylim([0.9*test_value_min 1.5*test_value_max])
        
        plot(loop_param, test_value, 'ro', 'MarkerSize', 3);
        drawnow;
        hold on;
        
        if loop_param >= num_data_point
            loop_param = 0;
            clf
        end
        
        loop_param = loop_param + 1;
        
        recorded_data(array_ptr) = test_value;
        array_ptr = array_ptr + 1;
    end
    toc
    
    % Check instrument for errors
    errorNum = -1;
    errorMsg = ('');
    disp(blanks(1)');
    while (errorNum ~= 0)
        [errorNum, errorMsg] = driver.Utility.ErrorQuery();
        disp(['ErrorQuery: ', num2str(errorNum), ', ', errorMsg]);
    end
    
catch exception
    disp(getReport(exception));
end

if driver.Initialized
    driver.Close();
    disp('Driver Closed');
end

close all

plot(recorded_data);
recorded_data = recorded_data.';

record_filename = 'recorded_data';
record_fileindex = 0;

Files=dir('*.*');
for k=1:length(Files)
    FileNames = Files(k).name;
    find_filename = strfind(FileNames, record_filename);
    if isempty(find_filename)
    else
        record_fileindex = record_fileindex + 1;
    end
    
end

record_successful = true;

if record_fileindex < 10
    record_filename = strcat(record_filename, '000');
elseif record_fileindex < 100
    record_filename = strcat(record_filename, '00');
elseif record_fileindex < 1000
    record_filename = strcat(record_filename, '0');
elseif record_fileindex < 10000
else
    disp('Data NOT recorded! Number of files exceeded limit (9999), please empty the output folder')
    record_successful = false;
end

if record_successful
    record_filename = strcat(record_filename, num2str(record_fileindex));
    record_filename = strcat(record_filename, '.csv');
    
    csvwrite(record_filename,recorded_data);
    disp('Data recorded successful! Outputed as: ')
    disp(record_filename)
end

disp('Done');
disp(blanks(1)');

end


function  f_capturekeystroke(~,~)
    %capturing and logging keystrokes
    %S2 = guidata(H);
    %P = get(S2.fh,'position');
    %set(S2.tx,'string',E.Key)
    %assignin('base','a',E.Key)    % passing 1 keystroke to workspace variable
    %evalin('base','b=[b a]')  % accumulating to catch combinations like ctrl+S
end


function f_closecq(~,~)
global stop
selection = questdlg('Close This Figure?','Close Request Function','Yes','No','Yes');
switch selection
    case 'Yes'
        %S.fh.WindowSyle='normal';
        delete(gcf)
        stop = 0;
    case 'No'
        return
end
end


