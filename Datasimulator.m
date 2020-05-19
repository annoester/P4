clear
clc
close all

load demo_files_all.mat
Fs = 500;
chosen_signal = no54;
number_of_signals = int16((length(chosen_signal))/(2.4*Fs));
signal=zeros(2.4*2*Fs,number_of_signals);
k = 1;


for i = 1:1200:length(chosen_signal)-2.4*Fs
    signal(1:1200,k) = chosen_signal(i:i+1199,1);
    signal(1201:2400,k) = chosen_signal(i:i+1199,2);
    
    signal_adjusted(1:1200,k) = int16((signal(1:1200,k)).*10000);
    signal_adjusted(1201:2400,k) = int16((signal(1201:2400,k)).*100000);
    k = k + 1;
end

L_output = length(signal_adjusted)*2;
L_input = 375*4;

s = serial('COM3');        % create Serial port object
s.baudrate = 115200;       % set baudrate 
s.InputBufferSize = L_input;     % set InputBufferSize to length of data
s.OutputBufferSize = L_output;    % set OutputBufferSize to length of data
try
    % Try to connect serial port object to device
    fopen(s)
catch
    % Display error message if connection fails and return
    disp(lasterr)
    return
end

t = 0;                                          % t is used as a counter of how many signals have a corr above 0.7
for i = 1:number_of_signals
    fprintf('Sending data...');
    fwrite(s,signal_adjusted(:,i),'int16');
    fprintf(' done.\n');
    pause(3);
    data_available = s.BytesAvailable
    fprintf('Reading processed data...');
    data(:,i) = fread(s,L_input/2,'int16');
    fprintf(' done.\n');
    
    signal_decoded(1:(L_input/4),i) = (data(1:L_input/4,i)/10000);
    signal_decoded((L_input/4)+1:L_input/2,i) = (data((L_input/4)+1:L_input/2,i)/100000);
    
    % data = int16(data);
    
    figure();
    subplot(2,1,1)
    plot(signal(:,i))
    subplot(2,1,2)
    plot(signal_decoded(:,i))
    
    sum_data = sum(data(:,i));
    if sum_data == 750*2
        
    else
       t = t + 1;
       if t == 15
           break;
       end
    end
    disp(i)
end
while s.BytesAvailable == 0
end
AC_amp_ESP = fread(s,1,'int16');
AC_amp = AC_amp_ESP/100000
fclose(s);