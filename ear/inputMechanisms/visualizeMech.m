%% vars
dt = 0.01;
T = (dt:dt:2000)';
N_pre = 2;
N_post = 2;
N_pop = 2;

%% paste any rate mech
gSyn = 1
Esyn = 1
tau_1 = 1
tau_d = 1
tau_r = .25
Nsources = 100 %n of sources of spikes
prob_cxn = 1

Tstart = 100
baseRate = 10 %Hz
maxRate = 300 %Hz
modulationType = 'square'
freq = 20 %Hz
rateNoiseAmp = 0 
freqNoiseAmp = 0 %or freq*.1
upTime = []

uniqueSourcesBool = false

% Connectivity
if ~uniqueSourcesBool
  netcon = rand(Nsources,N_post)<=prob_cxn;
  NsourcesTot = Nsources;
else
  netcon = repmat(eye(Nsources), N_post,1);
  NsourcesTot = Nsources * N_post;
end

% Functions
rate = calcInhomogRate(T, Tstart, baseRate, maxRate, modulationType, freq, rateNoiseAmp, freqNoiseAmp, upTime);
[Gspikes, spikes] = GeneratePoissonPSP(NsourcesTot, rate, tau_1, tau_d, tau_r, T, dt, Tstart);

%% plot
s(1) = subplot(221);
plot(T, rate)
title('Lambda')

s(2) = subplot(222);
if NsourcesTot > 1
  [xPoints, yPoints] = plotSpikeRaster(logical(spikes'));
  xPoints = xPoints/max(xPoints)*T(end);
  plot(xPoints, yPoints, '.', 'MarkerSize',5)
else
  plot(T, Gspikes)
end
title('Raster')

s(3) = subplot(223);
plot(T, Gspikes(:,1))
title('1 Ex Input Source')

s(4) = subplot(224);
plot(T, sum(Gspikes,2))
title('Summed Input')
linkaxes(s,'x')