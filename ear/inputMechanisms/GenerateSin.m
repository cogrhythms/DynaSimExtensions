function wave = GenerateSin(Tstart, T, sinFreq)
  [~,startInd] = min(abs(T-Tstart));
  wave = (sin(2*pi*sinFreq*(T-Tstart)/1000 - pi/2) + 1)/2; % start at trough
  wave(1:startInd) = 0;
