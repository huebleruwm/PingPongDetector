% this is some kind of attempt at analyzing ping pong noises with fourier
% transforms or something like that, looks like it plots the raw signal 
% too, I don't remember, basically scratch work

[y,Fs] = audioread( 'Wav Files/PingPongSong.wav' );
close all

u=4;
a=2;

dt = 1/Fs;
t = 0:dt:(length(y)*dt)-dt;

f1 = figure;
hold on;

subplot(u, a, 1);
plot(t,y); xlabel('Seconds'); ylabel('Amplitude');

subplot(u, a, 3);
pwelch(y,[],[],[],Fs);

subplot(u, a, 5);
spectrogram(y,[],[],[],Fs,'yaxis');


Num = designfilt( 'bandpassfir', 'FilterOrder', 100, 'CutoffFrequency1', 500, ...
                  'CutoffFrequency2', 3000, 'SampleRate', Fs);
yf = filter(Num.Coefficients,1,y);

subplot(u, a, 2);
plot(t,yf); xlabel('Seconds'); ylabel('Amplitude');

subplot(u, a, 4);
pwelch(yf,[],[],[],Fs);

subplot(u, a, 6);
spectrogram(yf,[],[],[],Fs,'yaxis');

subplot(u, a, 7);
plot(t,yf);


wname = 'db6';
level = 6;
range = 1:level;

wt = modwt( y, level);
wtrec = zeros(size(wt));
wtrec(4:5,:) = wt(4:5,:);
yfr = imodwt(wtrec,'db6');

soundsc(yfr,Fs)

figure;
subplot(2,1,1)
plot( y )

subplot(2,1,2)
plot(yfr)


%[cf,lf] = wavedec(yf,level,wname);

%tmp = cumsum(lf);

%cf(1:tmp(4)) = 0;
%cf(tmp(6):tmp(level)) = 0;

%yfr = waverec( cf, lf, wname );

%subplot(u, a, 8);
%plot(t,yfr);

%soundsc(yfr,Fs)

%summed = [];
%len = ceil( 0.006 * Fs );

%x = 1:len;
%f = exp( -(x - len/2).^2 / 100 );

%for i = 145: 10 : length(t)-145    
%    from = max(1, i-len/2 );
%    to = min( length(yf), i+len/2 );
%    tmp1 = summed;
%    summed = [ tmp1 sum( transpose(f) .* abs(yf(from:to-1)) ) ];
%end 

%figure;
%plot( summed(1,:) )

function pp = extractPingPong( data, level, stLevel, endLevel )
 wt = modwt( data, level );
 wtrec = zeros(size(wt));
 wtrec(stLevel,endLevel,:) = wt(stLevel,endLevel,:);
 pp = imodwt( wtrec, 'sym4' );
end



