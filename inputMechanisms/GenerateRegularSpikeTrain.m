function psps = GenerateRegularSpikeTrain(nSources, rate, tau_1, tau_d, tau_r, t, dt, Tstart)
%% GenerateRegularSpikeTrain
% Author: Erik Roberts
%
% Creates normalized (amp=1) psps at regular intervals starting at Tstart
% (default = t(1)), plus uniformly distributed amount across ISI period for each
% source. To get consistent shift across sources, repmat one source in outer
% fxn.
%
% Usage: psps = GenerateRegularSpikeTrain(nSources, rate, tau_1, tau_d, tau_r, t, dt)
%        psps = GenerateRegularSpikeTrain(nSources, rate, tau_1, tau_d, tau_r, t, dt, Tstart)
%
% Units: rate in Hz
%        Time vars in ms
%
% psps dim = t x nSources

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

% ISI
ISIind = round((1/dt)*(1000/rate)); %isi in indicies

% PSP from each source
psps = nan(length(psp), nSources); 
for iSource = 1:nSources
    shift = randi([0,ISIind]);
    
    spikeInd = startInd+shift : ISIind : length(t);
    spikes = zeros(length(t), 1);
    spikes(spikeInd) = 1;
    
    psps(:, iSource) = conv(spikes, psp, 'same');
end
