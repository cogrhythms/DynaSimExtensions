function wave = GenerateUniformSquare(Tstart, T, squareFreq, dutyCycle, smoothSquareBool)
  [~,startInd] = min(abs(T-Tstart));

  wave = (square(2.*pi.*squareFreq.*(T - Tstart)/1000, dutyCycle*100)+1)/2;
  wave(1:startInd) = 0;
  
  if smoothSquareBool
    dt = T(2)-T(1);
    uptime = 1000/squareFreq*dutyCycle;
    win = hamming(uptime*0.25/dt);
    win = win/max(win);
    smoothWave = conv(wave, win, 'same');
    smoothWave = smoothWave / max(smoothWave);
    wave = smoothWave
  end