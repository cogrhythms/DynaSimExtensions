function lambda = calcInhomogRate(T, Tstart, baseRate, maxRate, modulationType, freq, rateNoiseAmp, freqNoiseAmp, upTime)
%% calcInhomogRate
% Author: Erik Roberts
%
% Calculates the lambda function over time for a given modulationType. Noise is
% gaussian distributed.
%
% Usage:lambda = calcInhomogRate(T, baseRate, maxRate, modulationType, freq)
%       lambda = calcInhomogRate(T, baseRate, maxRate, modulationType, freq, rateNoiseAmp, freqNoiseAmp)
%       lambda = calcInhomogRate(T, baseRate, maxRate, modulationType, freq, rateNoiseAmp, freqNoiseAmp, upTime)
%
% Input:
%   T is time vector
%   modulationType: 'von mises', 'square', 'sine', 'triangle'
%   noise vars: can enter mult factor for gaussian distr or a string for auto noise
%
% Defaults: Tstart is T(1), noise = 0, upTime = quarter period of freq
%
% Units: rate vars in Hz
%        Time vars in ms

% TODO fix freq shifts, add phase shifts, taper leading edge, VM kappa meaning

%% defaults
if ~exist('Tstart', 'var') || isempty(Tstart)
  Tstart = T(1);
end

if ~exist('rateNoiseAmp', 'var') || isempty(rateNoiseAmp)
  rateNoiseAmp = 0;
elseif ischar(rateNoiseAmp)
  rateNoiseAmp = (maxRate - baseRate)*.05;
end

if ~exist('freqNoiseAmp', 'var') || isempty(freqNoiseAmp)
  freqNoiseAmp = 0;
elseif ischar(freqNoiseAmp)
  freqNoiseAmp = freq*.1;
else
  
end
if ~exist('upTime', 'var') || isempty(upTime)
  upTime = 1000/freq/4; %quarter period in ms
end

%% set vars
nSamples = length(T);
dt = T(2)-T(1);
Tshift = T-Tstart;
Tshift(Tshift < 0) = 0;

baseLambda = baseRate/1000*dt;
maxLambda = maxRate/1000*dt;

%% calc noise
if freqNoiseAmp == 0
  freqWnoise = freq;
else
  freqWnoise = freq + freqNoiseAmp*randn(nSamples,1);
end

%% calc lambda shape
lambda = zeros(nSamples,1);
if strcmp(modulationType, 'von mises') % normed [0 1]
  kappa = 1/(upTime/1000); % von Misses width
  if freqNoiseAmp == 0
    lambda = exp(kappa * sin(2*pi*freq/1000 * Tshift - pi/2));
    lambda = lambda/max(lambda); %norm
  else
    periodDraw = 0; % ms
    lTime = Tstart;
    while (lTime + periodDraw) < T(end)
      freqDraw = freqWnoise(randi(nSamples,1));
      periodDraw = round(1000/(freqDraw)); % ms
      thisSamples = nearest(T, lTime):nearest(T, (lTime+periodDraw));
      lambda(thisSamples) = exp(kappa * sin(2*pi*freqDraw/1000 * T(thisSamples) - pi/2));
      lambda(thisSamples) = lambda(thisSamples)/max(lambda(thisSamples)); %norm
      lTime = lTime + periodDraw;
    end
    if lTime < T(end)
      freqDraw = freqWnoise(randi(nSamples,1));
      thisSamples = nearest(T,lTime):find(T(end));
      lambda(thisSamples) = exp(kappa * sin(2*pi*freqDraw/1000 * T(thisSamples) - pi/2));
      lambda(thisSamples) = lambda(thisSamples)/max(lambda(thisSamples)); %norm
    end
  end
  
elseif strcmp(modulationType, 'square')
  upEdge = Tstart;
  
  if freqNoiseAmp == 0
    period = round(1000/(freq)); % ms
    upEdge = (upEdge:period:T(end))';
    downEdge = upEdge + upTime;
    edges = [upEdge, downEdge];
  else %random ISIs based on rand draw from freqWnoise
    lTime = Tstart;
    %first draw
    freqDraw = freqWnoise(randi(nSamples,1));
    periodDraw = round(1000/(freqDraw)); % ms
    while (lTime + periodDraw) < T(end)
      upEdge = [upEdge; upEdge(end) + periodDraw];
      lTime = lTime + periodDraw;
      
      %next draw
      freqDraw = freqWnoise(randi(nSamples,1));
      periodDraw = round(1000/(freqDraw)); % ms
    end
    
    downEdge = upEdge + upTime;
    edges = [upEdge, downEdge];

    %finish end
    if lTime < T(end)
      edges = [edges; upEdge(end) + periodDraw, T(end)];
    end
  end
  
  %set lambda=1 inside edges
  for nEdge = 1:size(edges,1);
    lambda((T >= edges(nEdge,1)) & (T <= edges(nEdge,2))) = 1;
  end
  
elseif strcmp(modulationType, 'sine') %normed [0 1], phase shifted to start at 0
  if freqNoiseAmp == 0
    lambda = (sin(2*pi * freq/1000 .* Tshift - pi/2) + 1)/2;
  else
    lTime = Tstart;
    
    %first draw
    freqDraw = freqWnoise(randi(nSamples,1));
    periodDraw = round(1000/(freqDraw)); % ms
      
    while (lTime + periodDraw) < T(end)
      thisSamples = nearest(T, lTime):nearest(T, (lTime+periodDraw));
      lambda(thisSamples) = (sin(2*pi * freqDraw/1000 .* T(thisSamples) - pi/2) + 1)/2;
      lTime = lTime + periodDraw;
      
      %next draw
      freqDraw = freqWnoise(randi(nSamples,1));
      periodDraw = round(1000/(freqDraw)); % ms
    end
    
    %finish end
    if lTime < T(end)
      lambda(thisSamples) = (sin(2*pi * freqDraw/1000 .* T(thisSamples) - pi/2) + 1)/2;
    end
  end
  
elseif strcmp(modulationType, 'triangle') %normed [0 1], starts at 0
  if freqNoiseAmp == 0
    lambda = (sawtooth(2*pi * freq/1000 .* Tshift, 0.5) + 1)/2; %normed [0 1]
  else
    lTime = Tstart;
    
    %first draw
    freqDraw = freqWnoise(randi(nSamples,1));
    periodDraw = round(1000/(freqDraw)); % ms
    while (lTime + periodDraw) < T(end)
      thisSamples = nearest(T, lTime):nearest(T, (lTime+periodDraw));
      lambda(thisSamples) = (sawtooth(2*pi * freqDraw/1000 .* T(thisSamples)) + 1)/2;
      lTime = lTime + periodDraw;
      
      %next draw
      freqDraw = freqWnoise(randi(nSamples,1));
      periodDraw = round(1000/(freqDraw)); % ms
    end
    
    %finish end
    if lTime < T(end)
      thisSamples = nearest(T, lTime):find(T(end));
      lambda(thisSamples) = (sawtooth(2*pi * freqDraw/1000 .* T(thisSamples)) + 1)/2;
    end
  end
end

%% scale labmda
lambda = lambda*(maxRate - baseRate) + baseRate;

%% add rate noise
if rateNoiseAmp ~= 0
  lambda = lambda + rateNoiseAmp*randn(nSamples,1);
end

end