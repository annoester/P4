clear
clc
close all

load demo_files_all.mat
Fs = 500;
chosen_signal = no54;                                                       % Chose desired test-person
number_of_signals = int16((length(chosen_signal))/(2.4*Fs));                % Calculates the number of 2.4 sec segments the signal has
k = 1;                                                                      % Counter


for i = 1:1200:length(chosen_signal)-2.4*Fs                                
    signal(1:1200,k) = chosen_signal(i:i+1199,1);                           % Split the signal into segments with 2.4 sec ECG followed by 2.4 sec SCG
    signal(1201:2400,k) = chosen_signal(i:i+1199,2);
    
    signal_adjusted(1:1200,k) = int16((signal(1:1200,k)).*10000);           % Typecast the signal to int16 and multiply ECG with 10,000
    signal_adjusted(1201:2400,k) = int16((signal(1201:2400,k)).*100000);    % Typecast the signal to int16 and multiply SCG with 100,000
    k = k + 1;
end

L_output = length(signal_adjusted)*2;                                       % The output data size is the length of the signal*2 because it is a 'double'
L_input = 375*2*2;                                                          % The input data size is 375*2*2, because ECG and SCG align are both 375 samples(0.75 sec) and is made a double

s = serial('COM3');                                                         % Create Serial port object
s.baudrate = 115200;                                                        % Set baudrate 
s.InputBufferSize = L_input;                                                % Set InputBufferSize to size of data
s.OutputBufferSize = L_output;                                              % Set OutputBufferSize to size of data
try
    fopen(s)                                                                % Try to connect serial port object to device
catch
    disp(lasterr)                                                           % Display error message if connection fails and return
    return
end

t = 0;                                                                      % t is used as a counter of how many signals have a corr above 0.7
for i = 1:number_of_signals                                                 % The for loop continues as long as there is segments in the signal
                                               
    fwrite(s,signal_adjusted(:,i),'int16');                                 % Sends the adjusted signal through the COM port
    
    fprintf('Number of signal sent: '); disp(i);                            % Prints in the command window
    
    while s.BytesAvailable == 0                                             % While loop to wait for available bytes
    end
    
    data(:,i) = fread(s,750,'int16');                                       % Reads 750 samples (2*0.75 sec) from the ESP32 through the COM port
    
    signal_readjusted(1:375,i) = (data(1:375,i)/10000);                     % Readjust the ECG signal
    signal_readjusted(376:750,i)=(data(376:750,i)/100000);                  % Readjust the SCG signal
    
    figure();                                                               % Plots the sent and the received signal
    subplot(2,1,1)
    plot(signal(:,i))
    subplot(2,1,2)
    plot(signal_readjusted(:,i))
    
    sum_data = sum(data(:,i));                                              % Saves 'sum_data' as the sum of the values in the received array
    if sum_data == 375*2*2                                                  % If 'sum_data' is '375*2*2' the signal sent do not have a correlation above 0.7
                                                                            % Notice t is not incremented
    else                                                                    % If 'sum_data' is not '1500' the signal sent have a correlation above 0.7
       t = t + 1;                                                           % t is incremented, to keep track of number of correlating signals
       fprintf('Correlating signals: '); disp(t);                           % Print number of correlating signals in command window
       if t == 15 
           break;                                                           % When 't==15', 15 signals, with corr > 0.7, have been sent to the peripheral unit and no more is needed
       end
    end

end

while s.BytesAvailable == 0                                                 % Waits for bytes available
end

AC_amp_ESP = fread(s,1,'int16');                                            % Reads the AC amplitude
AC_amp = AC_amp_ESP/100000;                                                 % Readjust the AC amplitude
fprintf('AC amplitude is: '); disp(AC_amp);                                 % Prints the AC amplitude in the command window
                                                  
fclose(s);                                                                  % Close COM port



