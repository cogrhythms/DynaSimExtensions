t = 0:.1:100; %ms
f = 25;
duty = 0.2;
proportionUptimeForWin = 0.25;

dt = t(2)-t(1);
uptime = 1000/f*duty;
win = hamming(uptime*proportionUptimeForWin/dt);
win = win/max(win);

wave = (square(2*pi*t*f/1000, duty*100)+1)/2;

subplot(211)
plot(t, wave)

subplot(212)
smoothWave = conv(wave, win, 'same');
smoothWave = smoothWave / max(smoothWave);
plot(t, smoothWave)