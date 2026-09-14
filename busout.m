function busout(busdata)
% BUSOUT displays the bus data in a formatted table
% Inputs:
%   busdata: Bus data matrix [busnum, bustype, Pd, Qd, Gs, Bs, Vm, Va, baseKV, zone]

% Define column headers
headers = {'Bus', 'Type', 'Pd (MW)', 'Qd (MVar)', 'Gs (MW)', 'Bs (MVar)', 'Vm (p.u.)', 'Va (degrees)', 'Base kV', 'Zone'};

% Convert busdata to cell array if needed
table_data = {num2cell(busdata(:, 1)), num2cell(bustype2str(busdata(:, 2)))',num2cell(busdata(:,3)),...
    num2cell(busdata(:,4)),num2cell(busdata(:,5)),num2cell(busdata(:,6)),num2cell(busdata(:,7)),...
    num2cell(busdata(:,8)),num2cell(busdata(:,9)),num2cell(busdata(:,10))};
table_widths = cellfun(@(cols) max(cellfun(@(x) numel(x), cols)), table_data);
table_format = ['%-', num2str(max(table_widths)), 's'];
end
