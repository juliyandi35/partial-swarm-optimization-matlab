function [Sf, St] = lineflow(busdata, linedata, V)
% LINEFLOW calculates the line flows in a power system
% Inputs:
%   busdata: Bus data matrix [busnum, bustype, Pd, Qd, Gs, Bs, Vm, Va, baseKV, zone]
%   linedata: Line data matrix [from, to, r, x, b, rateA, rateB, rateC, ratio, angle, status]
%   V: Bus voltage vector in per unit
% Outputs:
%   Sf: Complex power flows at the "from" end of each line
%   St: Complex power flows at the "to" end of each line

% Extract relevant columns from busdata
busnum = busdata(:, 1);
Vm = busdata(:, 7);
Va = busdata(:, 8);
baseKV = busdata(:, 9);

% Extract relevant columns from linedata
from_bus = linedata(:, 1);
to_bus = linedata(:, 2);
r = linedata(:, 3);
x = linedata(:, 4);
b = linedata(:, 5);
ratio = linedata(:, 9);
angle = linedata(:, 10);
status = linedata(:, 11);

% Convert angle to radians
angle_rad = deg2rad(angle);

% Initialize line flows
Sf = zeros(size(linedata, 1), 1);
St = zeros(size(linedata, 1), 1);

for i = 1:size(linedata, 1)
    if status(i) == 1  % Only consider active lines
        
        % Calculate complex voltage at "from" and "to" ends
        Vf = V(from_bus(i)) * exp(1i * Va(from_bus(i)));
        Vt = V(to_bus(i)) * exp(1i * Va(to_bus(i)));
        
        % Calculate line impedance
        Z = (r(i) + 1i * x(i)) / (ratio(i)^2);
        
        % Calculate line admittance
        Y = 1 / Z;
        
        % Calculate line charging susceptance
        Bc = 1i * b(i) / 2;
        
        % Calculate complex power flow
        If = (Vf - Vt * ratio(i) * exp(1i * angle_rad(i))) / Z;
        Sf(i) = Vf * conj(If);
        St(i) = Vt * conj(If * ratio(i) * exp(1i * angle_rad(i)));
        
        % Include line charging susceptance in power flow
        Sf(i) = Sf(i) + Vf * conj(Vf) * Bc;
        St(i) = St(i) + Vt * conj(Vt) * Bc;
    end
end

end
