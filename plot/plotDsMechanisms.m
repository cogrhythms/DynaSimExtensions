function plotDsMechanisms(data, s, populationNumber)
  popName = s.populations(1).name;
  simDatafields = fieldnames(data);
  mechs = s.populations(populationNumber).mechanism_list;
  
  for mechInd = 1:length(mechs)
    mech = mechs{mechInd};
    mechInField = ~cellfun(@isempty,regexpi(simDatafields, mech,'start'));
    mechFields = sort(simDatafields(mechInField));
    if ~isempty(mechFields)
      for fieldInd = 1:length(mechFields)
        mechField = mechFields{fieldInd};
        h(fieldInd) = PlotData(data,'variable', mechField,'visible','off');
    %       ti{fieldInd} = strrep(mechField,'_','-');
        lastInd = regexpi(mechField,mech,'end');
        ti{fieldInd} = mechField(lastInd+2:end);
      end
      
      axisLinkType = 'x';
      figHandle = combineFigures(h, ti, [], [], axisLinkType);
      
      earSuptitle([popName ' - ' mech], figHandle)
    end
    clear mechFields mechField mech mechInField fieldInd h ti
  end
end