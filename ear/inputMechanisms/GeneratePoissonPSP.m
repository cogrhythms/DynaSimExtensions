function [psps, spikes] = GeneratePoissonPSP(nSources, rate, tau_1, tau_d, tau_r, t, dt, Tstart)
%% GeneratePoissonPSP
% Author: Erik Roberts
%
% Creates normalized (amp=1) psps at poisson probabilities (exp distributed intervals)
% starting at Tstart (default = t(1)). Each source gets different spike train.
% To get consistent train across sources, repmat one source in outer fxn. Rate
% can be a row vector of lambdas for inhomog poisson.
%
% Usage:[psps, spikes] = GeneratePoissonPSP(nSources, rate, tau_1, tau_d, tau_r, t, dt)
%       [psps, spikes] = GeneratePoissonPSP(nSources, rate, tau_1, tau_d, tau_r, t, dt, Tstart)
%
% Units: rate in Hz
%        Time vars in ms
%
% psps dim = t x nSources
%
% Note: derived from Ben Poletta's "multi_Poisson.m"

t = t(:); % col vector

if ~exist('Tstart', 'var')
  Tstart = t(1);
end

startInd = nearest(t, Tstart);

%make poisson spikes
spikes = GeneratePoissonSpikeTrain(rate/1000, t, dt, nSources);

spikes(1:startInd, :) = 0; %enforce start ind

% PSP convolution time series
nTau = 10; %multiple of time constants to calc psp over
pspT = 0:dt:min((nTau*tau_d + nTau*tau_r), length(t));
pspT = pspT(:); % row vector
tPeak = tau_1+(tau_d*tau_r)/(tau_d-tau_r)*log(tau_d/tau_r);
normFactor = 1/( (exp(-(tPeak-tau_1)/tau_d) - (exp(-(tPeak-tau_1)/tau_r)) ) );
psp = normFactor*(exp(-max(pspT - tau_1,0)/tau_d) - exp(-max(pspT - tau_1,0)/tau_r));
%psp = psp(psp > eps); %removes time points less than matlab precision, but not good for low dt
% psp = [zeros(size(psp)); psp]; %pad with 0s

% PSP from each source
psps = zeros(length(t), nSources);
for iSource = 1:nSources
    psps(:, iSource) = conv(spikes(:, iSource), psp, 'same');
end