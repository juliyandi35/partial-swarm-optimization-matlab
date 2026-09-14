function bustype_str = bustype2str(bustype)
% BUSTYPE2STR converts the bus type code to a string
% Inputs:
%   bustype: Bus type code (1, 2, 3, 4)
% Output:
%   bustype_str: Bus type string ('PQ', 'PV', 'Slack', 'Isolated')

for i=1:length(bustype)
    if bustype(i) == 1
        bustype_str(i) = "PQ";
    elseif bustype(i) == 2
        bustype_str(i) = "PV";
    elseif bustype(i) == 3
        bustype_str(i) = "Slack";
    elseif bustype(i) == 4
        bustype_str(i) = "Isolated";
    else
        bustype_str(i) = "Unknown";
    end
end
end