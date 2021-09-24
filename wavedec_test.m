% scratch  work to test wavedec (whatever that is, I forgot)

[y,Fs] = audioread( 'Wav Files/PingAndNoises.wav' );

level = 8;
range = 1:level

[c,l] = wavedec(y,level,'db2');
approx = appcoef(c,l,'db2');
[cd] = detcoef(c,l,range);

figure;
hold on
subplot(level+1,1,1)
plot(y)

for i = 1 : level
    subplot(level+1,1,i+1);
    plot( cd{i} )
end