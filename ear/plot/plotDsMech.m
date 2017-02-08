function plotDsMech(mechFiles, voltages, overlayBool)
%% plotDsMech
% Author: Erik Roberts
%
% Purpose: plots the kinetics of dynasim mechanism(s). Will convert alpha
%   and beta to inf and tau.
%
% Usage: plotDsMech(paths2mechanismFiles)
%        plotDsMech(paths2mechanismFiles, voltages)
%        plotDsMech(paths2mechanismFiles, voltages, overlayBool)
%
% Input:
%   paths2mechanismFiles: a string or cell of strings containing the path(s) to
%     mechanism files
%   voltages: optional array of the voltages to plot. default is -100:.1:40
%   overlayBool: optional logical for if gates should be overlaid for inf and
%     tau. default is true.
%
% Conventions:
%   in regular expression form, must use [ab]\w+ or (tau\w+ and \w+inf) for
%   kinetic equations. Must use X as voltage term.

if ~exist('voltages', 'var') || isempty(voltages)
  X = -100:.1:40;
else
  X = voltages;
end

if ~exist('overlayBool', 'var') || isempty(overlayBool)
  overlayBool = true;
end

legendLoc = 'west';

%convert single string input to cell
if ischar(mechFiles)
  mechFiles = {mechFiles};
end
nFiles = length(mechFiles);

for iFile = 1:nFiles
  mechFile = mechFiles{iFile};
  
  %open file
  fileText = fileread(mechFile);
  textCells = strsplit(fileText, '\n');
  
  %look for regexp
  % a\w+ and b\w+ then (X)\s*=\s*(equation)
  % or
  % tau\w+ and \w+inf then (X)\s*=\s*(equation)
  reCells = regexp(textCells, '([ab]\w+|tau\w+|\w+inf)\(X\)\s*=\s*(.+)','tokens');
  reCells = reCells(~cellfun('isempty',reCells)); %remove empty cells
  reCells = cellfun(@(x) x{1}, reCells, 'UniformOutput', false); %get array of 1x2 cells
  reCells = vertcat(reCells{:}); % cat cells into 1 array
  
  reCellsType = regexp(reCells(:,1), '[ab](\w+)|tau(\w+)|(\w+)inf','tokens');
  reCellsType = cellfun(@(x) x{1}{1}, reCellsType, 'UniformOutput', false); %get cells of strings
  
  equationCells = [reCellsType reCells];
  numEquations = size(equationCells,1);
  equationTypes = unique(reCellsType);
  numEquationTypes = size(equationTypes,1);
  
  % check for v_shift
  v_shift_cell = regexp(textCells, '(v_shift\s*=\s*\d+;)','tokens');
  v_shift_cell = v_shift_cell(~cellfun('isempty',v_shift_cell)); %remove empty cells
  if ~isempty(v_shift_cell)
    eval(v_shift_cell{1}{1}{1})
  end
  
  %check if ab format, then convert to inf and tau
  for k = 1:numEquationTypes
    theseCellInd = strcmp(reCellsType, equationTypes{k});
    theseEqCells = equationCells(theseCellInd, :);
    if any(cell2mat(regexp(theseEqCells(:,2), '[ab]\w+')))
      %check if tau/inf with a/b
      if sum(logical(cell2mat(regexp(theseEqCells(:,2), 'tau|inf'))))==2
        %remove a and b
        inds2remove = cellfun('isempty',regexp(equationCells(:,2), 'tau|inf')) & theseCellInd;
        equationCells( inds2remove, : ) = [];
        reCells( inds2remove, : ) = [];
        reCellsType( inds2remove, : ) = [];
        numEquations = size(equationCells,1);
        continue
      end
      thisA = regexp(theseEqCells(:,2), 'a\w+');
      thisA = ~cellfun('isempty',thisA);
      aEq = theseEqCells(thisA, 3); aEq = aEq{1};
      bEq = theseEqCells(~thisA, 3); bEq = bEq{1};
      
      infEq = [aEq './(' aEq '+' bEq ')'];
      tauEq = ['1./(' aEq '+' bEq ')'];
      
      nameCells = {[equationTypes{k} 'inf']; ['tau' equationTypes{k}]};
      
      cellSquare = [nameCells, {infEq; tauEq}];
      
      equationCells(theseCellInd, 2:3) = cellSquare;
    end
  end
  
  % subplots for each
  figure
  
  if ~overlayBool
    for sInd = 1:numEquations
      [~, vertInd] = vsubplot(2, numEquationTypes, sInd);
      
      thisEquationCells = equationCells(sInd, :);
      
      y = eval(thisEquationCells{3});
      plot(X,y)
      title(thisEquationCells{2})
      
      if vertInd == 2
        xlabel('Voltage [mV]')
      end
    end
  else
    legendInfCells = {};
    legendTauCells = {};
    colors = distinguishable_colors(numEquationTypes);
    for eqInd = 1:numEquationTypes
      theseCellInd = strcmp(reCellsType, equationTypes{eqInd});
      theseEqCells = equationCells(theseCellInd, :);
      
      infInd = ~cellfun('isempty',regexp(theseEqCells(:,2), 'inf'));
      tauInd = cellfun('isempty',regexp(theseEqCells(:,2), 'inf'));
      
      subplot(1, 2, 1);
      hold on
      y = eval(theseEqCells{infInd,3});
      plot(X,y, 'Color', colors(eqInd,:))
      
      subplot(1, 2, 2);
      hold on
      y = eval(theseEqCells{tauInd,3});
      plot(X,y, 'Color', colors(eqInd,:))
      
      legendInfCells = [legendInfCells, theseEqCells{infInd,2}];
      legendTauCells = [legendTauCells, theseEqCells{tauInd,2}];
    end
    subplot(121);
    legend(legendInfCells,'Location',legendLoc)
    xlabel('Voltage [mV]')
    subplot(122);
    legend(legendTauCells,'Location',legendLoc)
    xlabel('Voltage [mV]')
  end
  
  % main title
  [~,name] = fileparts(mechFile);
  suptitle(name)
  
end

end