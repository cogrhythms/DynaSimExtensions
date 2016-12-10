function zapTS = GenerateZap(Tstart, T, nCells)
%% GenerateZap
% Author: Erik Roberts
%
% Makes a zap function for num of cells = nCells.
%
% Usage: zapTS = GenerateZap(Tstart, T, nCells)
%
% Units: ms
%
% zapTS dim = T x nCells

zapTS(length(T),1) = 0;

[~,startInd] = min(abs(T-Tstart));

zapTS(startInd:end) = sin(2*pi*40*((T(startInd:end) - T(startInd))/1000).^2.2);
zapTS = repmat(zapTS, 1, nCells); % T x cells