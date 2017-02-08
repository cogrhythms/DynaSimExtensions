function spikes = GeneratePoissonSpikeTrain(rate, t, dt, nSources)
%% GeneratePoissonSpikeTrain
% Author: Erik Roberts
%
% Creates point process with poisson probabilities (exp distributed intervals).
%
% Usage: spikes = GeneratePoissonSpikeTrain(rate, t, dt)
%        spikes = GeneratePoissonSpikeTrain(rate, t, dt, nSources)
%
% Units: rate in Hz
%        Time vars in ms
%
% spikes dim = t x nSources
%
% Note: derived from Ben Poletta's "multi_Poisson.m"

if nargin < 4
  nSources = 1;
end

t = t(:); % col vector

%make poisson spikes
% use threshold on uniform distribution to get bernoulli for each point which
% gives poisson overall
spikes = rand(length(t), nSources); %random dist
spikes = single(bsxfun(@lt, spikes, rate*dt));