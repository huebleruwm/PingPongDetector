% Read in audiofile, getting signal and sample rate
[sig,Fs] = audioread( 'Wav Files/PingAndNoises.wav' );

dur_short = 0.003;      % In seconds 
dur_long = 0.08;

f_short = [ 500 2500 ]; % In Hertz
f_long = [ 0 5000 ];

step = 36;              % Number of samples to jump when sliding window

% ---------- Begin Code ---------- %

% filter bank for small window
fb_short = cwtfilterbank( 'SignalLength', dur_short*Fs, 'SamplingFrequency', Fs, ...
                    'FrequencyLimits', f_short, 'VoicesPerOctave', 10, ...
                    'Wavelet', 'morse');
           
% filter bank for large window           
fb_long = cwtfilterbank( 'SignalLength', dur_long*Fs, 'SamplingFrequency', Fs, ...
                    'FrequencyLimits', f_long, 'VoicesPerOctave', 10, ...
                    'Wavelet', 'morse');

% test code, shows full wavelet viewer centered at time
% used to visualize the windows to compare, only one useable at a time
%time = 1.46;
%s = time * Fs;
%get_energy( sig, Fs, dur_short, f_short, s ) % view small window
%get_energy( sig, Fs, dur_long, f_long, s )  % view large window
%return

% create arrays to store times and energy ratios
energy_ratio = zeros( ceil( ( length(sig) - 2 * dur_long * Fs ) / step ), 1 );
t = zeros( length(energy_ratio), 1 );

% now we slide the window along the signal
% parallel loop because this is kinda slow
parfor i = 1 : length(t)
    
    % we want the windows to be centered around a sample from the audio
    s_center = dur_long*Fs + (i-1)*step;
    
    % find start and end samples for small window and the energy in that range
    s_start = s_center - round(dur_short*Fs/2);
    s_end   = s_center + round(dur_short*Fs/2)-1;
    e_short = mean( abs( cwt( sig(s_start:s_end), 'FilterBank', fb_short).^2 ), [1 2]);
    
    % find start and end samples for large window and the energy in that range
    s_start = s_center - round(dur_long*Fs/2);
    s_end   = s_center + round(dur_long*Fs/2)-1;
    e_long  = mean( abs( cwt( sig(s_start:s_end), 'FilterBank', fb_long).^2 ), [1 2]);
   
    % find energy ratio and save the time in terms of seconds
    energy_ratio(i) = e_short / e_long ;
    t(i) = s_center / Fs;
    
end

% lets filter the energy ratio
energy_ratio_new = zeros( length(energy_ratio), 1 );
sample_range = 5;
d = floor( sample_range/2 );

for i = sample_range : length( energy_ratio_new )-sample_range
                        
    % standard deviation seems best
    energy_ratio_new(i) = std( energy_ratio(i-d:i+d) )^2;
                        
    % moving average help a little
    %energy_ratio_new(i) = movmean( abs( energy_ratio(i) )^2, 3);
end 
    
% plot the original energy ratio followed by the filtered one
figure
subplot(2,1,1)
plot( t, energy_ratio )
subplot(2,1,2)
plot( t, energy_ratio_new )


% function to get energy in a range 
%  sig     - signal to analyze
%  Fs      - sample rate of signal
%  dur_ms  - time duration to analyze
%  f_range - frequency range to analyze
%  t_cen   - what time to analyze the energy at, center point 
function energy = get_energy( sig, Fs, dur_ms, f_range, t_cen ) 

    sig_len = dur_ms * Fs;
    
    % create filter bank
    fb = cwtfilterbank( 'SignalLength', sig_len, 'SamplingFrequency', Fs, ...
                        'FrequencyLimits', f_range, 'VoicesPerOctave', 10, ...
                        'Wavelet', 'amor');

    % find start and end samples, and get the wavelet coefficients
    s_start = t_cen - round(sig_len/2);
    s_end = t_cen + round(sig_len/2);
    wt = cwt( sig(s_start:s_end-1), 'FilterBank', fb);
    
    % find the average energy by taking the average of the square of the
    % wavelet coefficients
    energy = mean( abs(wt.^2), [1 2]);
    
    % plot it for funsies
    cwt( sig(s_start:s_end-1), 'FilterBank', fb)

end