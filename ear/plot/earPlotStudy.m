function earPlotStudy(path, s)
% s.plot_functions
% s.plot_options
% s.plot_prefix

assert(logical(exist('path','var')), 'Error: Specify Path')

%% main
data = ImportData(path);

%figDir
figDir = fullfile(path, 'figs');
mkdir(figDir)
fprintf('\nSaving figs to: %s\n', figDir)

for simID = 1:length(data)
  thisData = data(simID);
  
  % defaults
  if ~exist('s', 'var')
    s = struct();
  end
  if ~isfield(s, 'plot_functions')
    s.plot_functions = {@PlotData,@PlotData};
  end
  if ~isfield(s, 'plot_options')
    time_end = thisData.time(end);
    s.plot_options = {{'visible','off'},{'plot_type','rastergram','xlim',[100 time_end],'visible','off'}};
  end
  if ~isfield(s, 'plot_prefix')
    s.plot_prefix = {'trace_', 'raster_'};
  end
  
%   plotStr='';
  filename= sprintf('id%i', simID);
  for iVary=1:length(thisData.varied)
    fld=thisData.varied{iVary};
%     plotStr=[plotStr fld '=' num2str(thisData.(fld)) ', '];
    filename=[filename '__' fld '_' num2str(thisData.(fld))];
  end
  
  for iPlot=1:length(s.plot_functions)
    if isfield(s, 'plot_prefix')
      prefix = s.plot_prefix{iPlot}; %need to add underscore in prefix
      filenameFinal = [prefix filename];
    end
    
    filePath = fullfile(figDir, filenameFinal);
    
    if exist([filePath, '.png'], 'file')
      fprintf('\t\tSkipping: %s\n', filenameFinal)
      continue
    end
    
    feval(s.plot_functions{iPlot},thisData,s.plot_options{iPlot}{:});
    export_fig(filePath, '-png', gcf)
    close(gcf)
    fprintf('\tSaved: %s\n', filenameFinal)
  end
end


end