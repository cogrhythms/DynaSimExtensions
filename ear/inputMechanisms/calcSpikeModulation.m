%% vars
dt = 0.1;
t = (0:dt:5000)';
Tstart = 0;

baseRate = 50; %Hz
maxRate = 300; %Hz
modulationType = 'square';
freq = 15; %Hz
rateNoiseAmp = 0;
freqNoiseAmp = 0;
upTime = [];

%% makes spikes
rate = calcInhomogRate(t, Tstart, baseRate, maxRate, modulationType, freq, rateNoiseAmp, freqNoiseAmp, upTime);
spikes = GeneratePoissonSpikeTrain(rate/1000, t, dt);

%% Define spline parameters 
lastknot = 100; knot_spacing = 5; %[hz] %knots are places where splines connect
c_pt_times = [0:knot_spacing:lastknot]; % control pts in domain of data
if c_pt_times(end) ~= 100
    c_pt_times = [c_pt_times 100];
end
c_pt_times_all = [-10  c_pt_times  lastknot+10]; % all control pts

T = .5;  % Define Tension Parameter %ranges from [0,1]
s=1-T;

%% Construct spline matrix
S = zeros(lastknot,length(c_pt_times_all));
for iKnot=1:lastknot
    pre_c_pt_index = max(find(c_pt_times_all<iKnot)); % find control point  to the left's time
    pre2_c_pt_time = c_pt_times_all(pre_c_pt_index-1); % find 2nd control point to the left's time
    pre_c_pt_time = c_pt_times_all(pre_c_pt_index); % find control point to the left's time
    post_c_pt_time = c_pt_times_all(pre_c_pt_index+1); % find control point to the right's time
    post2_c_pt_time = c_pt_times_all(pre_c_pt_index+2);% find 2nd control point to the right's time
    u = (iKnot-pre_c_pt_time)/(post_c_pt_time-pre_c_pt_time); % fraction of time between control pt before and after (alpha in slides)
    l0 = (post_c_pt_time-pre2_c_pt_time)/(post_c_pt_time-pre_c_pt_time); %l is related to calculating tangent
    l1 = (post2_c_pt_time-pre_c_pt_time)/(post_c_pt_time-pre_c_pt_time);
    p=[u^3 u^2 u 1]*[-s/l0 2-s/l1 s/l0-2 s/l1; 2*s/l0 s/l1-3 3-2*s/l0 -s/l1; -s/l0 0 s/l0 0; 0 1 0 0];
    S(iKnot,pre_c_pt_index-1:pre_c_pt_index+2) = p;
end

%% Build design matrix for multiplicative history model 
model = zeros(length(spikes), lastknot, 2);
for freqCos = 1:lastknot % make (# = lag of last knot) cols
    model(:,freqCos, 1) = cos(2*pi*freqCos/1000*t);
    model(:,freqCos, 2) = sin(2*pi*freqCos/1000*t);
end;

X = [model(:,:,1)*S, model(:,:,2)*S];
y = spikes;

%% Fit point process GLM 
[b dev stats] = glmfit(X,y,'poisson','constant','on');
[yhat,dylo,dyhi] = glmval(b,[S, S],'log',stats);

plot(1:lastknot, yhat,'k')
hold on
plot(1:lastknot, yhat+dyhi,'g--')
plot(1:lastknot, yhat-dylo,'r--')
xlabel('Freq [Hz]')
title(sprintf('Freq Content of Poisson Lambda, DC rate = %0.2f Hz', exp(b(1))/dt*1000))