function addActivityLegend(mode)
% addActivityLegend adds a relevant legend to plots displaying signals or
% analyses by activity type

if(isempty(mode))
    return
end

actlabels = getActivityNames();

if(ischar(mode) && strcmp(mode,'all'))
    legend(actlabels);
elseif(isvalidactid(mode))
    legend(actlabels(mode));
end

end

function isit = isvalidactid(mode)

isit = all(round(mode)==mode) && all(mode > 0) && all(mode <= 6);
    
end


