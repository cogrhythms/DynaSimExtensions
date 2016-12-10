function psps = GeneratePoissonSpikeTrain(nSources, rate, tau_1, tau_d, tau_r, t, dt, Tstart)
%% GeneratePoissonSpikeTrain
% Author: Erik Roberts
%
% Creates normalized (amp=1) psps at poisson distributed intervals starting at Tstart
% (default = t(1)). Each source gets different spike train. To get consistent
% train across sources, repmat one source in outer fxn.
%
% Usage:psps = GeneratePoissonSpikeTrain(nSources, rate, tau_1, tau_d, tau_r, t, dt)
%       psps = GeneratePoissonSpikeTrain(nSources, rate, tau_1, tau_d, tau_r, t, dt, Tstart)
%
% Units: rate in Hz
%        Time vars in ms
%
% psps dim = t x nSources
%
% Note: derived from Ben Poletta's "multi_Poisson.m"

t = t(:);

if ~exist('Tstart', 'var')
  Tstart = t(1);
end

[~,startInd] = min(abs(t-Tstart));

% PSP convolution time series
tPeak = tau_1+(tau_d*tau_r)/(tau_d-tau_r)*log(tau_d/tau_r);
normFactor = 1/( (exp(-(tPeak-tau_1)/tau_d) - (exp(-(tPeak-tau_1)/tau_r)) ) );
psp = normFactor*(exp(-max(t - tau_1,0)/tau_d) - exp(-max(t - tau_1,0)/tau_r));
%psp = psp(psp > eps); %removes time points less than matlab precision, but not good for low dt
psp = [zeros(1,length(psp)); psp]; %pad with 0s

%make poisson spikes
% use threshold on uniform distribution to get bernoulli for each point which
% gives poisson overall
spikes = rand(length(t), nSources); %random dist
spikes = spikes < rate*dt/1000;
spikes(1:startInd, :) = 0; %enforce start ind

% PSP from each source
psps = zeros(length(t), size(spikes));
for iSource = 1:nSources
    psps(:, iSource) = conv(spikes(:, iSource), psp, 'same');
end