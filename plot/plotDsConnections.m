function plotDsConnections(data, s, connectionNumber)
  simDatafields = fieldnames(data);
  cons = s.connections(connectionNumber).mechanism_list;
  
  for conInd = 1:length(cons)
    conName = cons{conInd};
    conInField = ~cellfun(@isempty,regexpi(simDatafields, conName,'start'));
    conFields = sort(simDatafields(conInField));
    if ~isempty(conFields)
      for fieldInd = 1:length(conFields)
        conField = conFields{fieldInd};
        h(fieldInd) = PlotData(data,'variable', conField,'visible','off');
    %       ti{fieldInd} = strrep(conField,'_','-');
        lastInd = regexpi(conField,conName,'end');
        ti{fieldInd} = conField(lastInd+2:end);
      end
      
      axisLinkType = 'x';
      figHandle = combineFigures(h, ti, [], [], axisLinkType);
      
      earSuptitle(conName, figHandle)
    end
    clear conFields conField conName conInField fieldInd h ti
  end
end