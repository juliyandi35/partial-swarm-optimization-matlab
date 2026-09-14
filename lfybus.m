function ybus = lfybus(busdata, linedata)
% LFYBUS calculates the bus admittance matrix YBUS
% Inputs:
%   busdata: Bus data matrix [busnum, bustype, Pd, Qd, Gs, Bs, area, Vm, Va, baseKV, zone]
%   linedata: Line data matrix [from_bus, to_bus, r, x, b, tap_ratio]
% Output:
%   ybus: Bus admittance matrix

nbus = max(max(linedata(:, 1)), max(linedata(:, 2))); % Number of buses
nline = size(linedata, 1); % Number of lines

ybus = zeros(nbus, nbus); % Initialize YBUS matrix

% Calculate line admittance
for k = 1:nline
    from_bus = linedata(k, 1);
    to_bus = linedata(k, 2);
    r = linedata(k, 3);
    x = linedata(k, 4);
    b = linedata(k, 5);
    tap_ratio = linedata(k, 6);
    
    z = r + 1i*x; % Line impedance
    y = 1 / z; % Line admittance
    
    % Off-diagonal elements of YBUS
    ybus(from_bus, to_bus) = -y / tap_ratio;
    ybus(to_bus, from_bus) = ybus(from_bus, to_bus);
    
    % Diagonal elements of YBUS
    ybus(from_bus, from_bus) = ybus(from_bus, from_bus) + y + 1i*b / 2;
    ybus(to_bus, to_bus) = ybus(to_bus, to_bus) + y + 1i*b / 2;
end

% Add shunt elements (G, B) to YBUS
for i = 1:nbus
    bus_type = busdata(i, 2);
    Gs = busdata(i, 5);
    Bs = busdata(i, 6);
    baseKV = busdata(i, 10);
    
    if bus_type ~= 1 % Exclude slack bus
        ybus(i, i) = ybus(i, i) + 1i*Bs / baseKV^2;
        ybus(i, i) = ybus(i, i) + Gs;
    end
end
end
