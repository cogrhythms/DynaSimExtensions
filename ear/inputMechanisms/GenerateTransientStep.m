function stepTS = GenerateTransientStep(tStart, tEnd, t, nCells, stepCells)
%% GenerateTransientStep
% Author: Erik Roberts
%
% Makes a transient step. nCells is total num of cells. By default, fxn will
% make step for all cells. If pass cell indicies to stepCells, it will only make
% step for those cell indicies.
%
% Usage: stepTS = GenerateTransientStep(tStart, tEnd, T, nCells)
%        stepTS = GenerateTransientStep(tStart, tEnd, T, nCells, stepCells)
%
% Units: ms
%
% stepTS dim = T x nCells

if ~exist('stepCells', 'var')
  stepCells = 1:nCells;
end

stepTS = zeros(length(t), nCells);
stepTS((t >= tStart) & (t <= tEnd), stepCells) = 1; % T x cells
