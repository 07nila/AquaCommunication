%% Step 1: Setup Parameters 
% Define the system parameters for the simulation. 
fs = 10000;             % Sampling frequency (Hz) 
symbol_duration = 0.01; % Duration of each symbol (seconds) 
f0 = 1000;              % Frequency for binary '0' (Hz) 
f1 = 2000;              % Frequency for binary '1' (Hz) 
data_length = 10000;    % Number of bits to transmit 
snr_values = -20:5:30;  % SNR values for analysis 
 
%% Step 2: Generate Random Binary Data 
% Generate a random sequence of binary data for transmission. 
data = randi([0 1], 1, data_length); % Generate random binary data 
 
%% Step 3: Modulate Data Using Frequency Shift Keying (FSK) 
% Modulate the binary data using Frequency Shift Keying (FSK) technique. 
 
% Create a time vector for one symbol duration. 
t = 0:1/fs:symbol_duration-1/fs;  
 
% Initialize the modulated signal. 
modulated_signal = [];  
 
% Modulate each bit of the data sequence. 
for bit = data 
    if bit == 0 
        modulated_signal = [modulated_signal, cos(2*pi*f0*t)]; % FSK for '0' 
    else 
        modulated_signal = [modulated_signal, cos(2*pi*f1*t)]; % FSK for '1' 
    end 
end 
 
% Plot the modulated signal (Transmitted Signal). 
figure; 
plot(modulated_signal(1:1000)); % Plot first 1000 samples 
title('Transmitted Signal (FSK Modulated)'); 
6 
 
xlabel('Sample Number'); 
ylabel('Amplitude'); 
saveas(gcf, 'Transmitted_Signal.png'); 
 
%% Step 4: Analyze System Performance with Different SNR Levels 
% Analyze the system performance by adding noise and evaluating the Bit Error Rate (BER) for various SNR levels. 
 
% Initialize arrays to store BER values and received signals. 
ber_values = [];       % Store BER for each SNR level 
received_signals = {}; % Store received signals for each SNR level 
 
% Loop over each SNR value to analyze performance. 
for snr = snr_values 
    % Add noise to the modulated signal with the current SNR. 
    noisy_signal = awgn(modulated_signal, snr, 'measured'); % Ensure 'measured' is used 
    received_signals{end+1} = noisy_signal; % Store the noisy signal 
 
    % Demodulate the noisy signal. 
    demodulated_data_snr = []; 
    for i = 1:symbol_duration*fs:length(noisy_signal) - symbol_duration*fs 
        segment = noisy_signal(i:i+symbol_duration*fs-1); % Extract one symbol duration 
 
        % Calculate the energy in each frequency band. 
        energy_f0 = sum(segment .* cos(2*pi*f0*t)) / length(segment); 
        energy_f1 = sum(segment .* cos(2*pi*f1*t)) / length(segment); 
 
        % Decide based on which frequency has more energy. 
        if energy_f1 > energy_f0 
            demodulated_data_snr = [demodulated_data_snr, 1]; 
        else 
            demodulated_data_snr = [demodulated_data_snr, 0]; 
        end 
    end 
 
    % Ensure demodulated_data_snr is the same length as data. 
7 
 
    if length(demodulated_data_snr) > data_length 
        demodulated_data_snr = demodulated_data_snr(1:data_length); 
    elseif length(demodulated_data_snr) < data_length 
        demodulated_data_snr = [demodulated_data_snr, zeros(1, data_length - length(demodulated_data_snr))]; 
    end 
 
    % Calculate BER for the current SNR level. 
    errors_snr = sum(data ~= demodulated_data_snr); 
    ber_snr = errors_snr / length(data); 
    ber_values = [ber_values, ber_snr]; 
end 
 
% Plot a representative received signal (e.g., for the middle SNR value). 
middle_snr_index = ceil(length(snr_values) / 2); 
figure; 
plot(received_signals{middle_snr_index}(1:1000)); % Plot first 1000 samples of the received signal 
title(['Received Signal After Channel (SNR = ', num2str(snr_values(middle_snr_index)), ' dB)']); 
xlabel('Sample Number'); 
ylabel('Amplitude'); 
saveas(gcf, 'Received_Signal.png'); 
 
% Plot BER vs SNR. 
figure; 
plot(snr_values, ber_values, '-o'); 
title('BER vs SNR'); 
xlabel('SNR (dB)'); 
ylabel('Bit Error Rate'); 
grid on; 
saveas(gcf, 'BER_vs_SNR.png'); 
 
% Save BER vs SNR results to Excel. 
results_table = table(snr_values', ber_values', 'VariableNames', {'SNR (dB)', 'BER'}); 
writetable(results_table, 'BER_vs_SNR_results.xlsx'); 
disp('BER vs SNR results logged to BER_vs_SNR_results.xlsx'); 