function [busdata, converged] = lfnewton(busdata, linedata, tol, max_iter)
% LFNEWTON performs Newton-Raphson power flow analysis
% Inputs:
%   busdata: Bus data matrix [busnum, bustype, Pd, Qd, Gs, Bs, Vm, Va, baseKV, zone]
%   linedata: Line data matrix [from_bus, to_bus, r, x, b, tap_ratio]
%   tol: Tolerance for convergence
%   max_iter: Maximum number of iterations
% Outputs:
%   busdata: Updated bus data matrix with calculated values [busnum, bustype, Pd, Qd, Gs, Bs, Vm, Va, baseKV, zone]
%   converged: Flag indicating convergence (1: converged, 0: not converged)

nbus = size(busdata, 1); % Number of buses
nline = size(linedata, 1); % Number of lines

converged = 0; % Initialize convergence flag
iter = 0; % Initialize iteration counter

while iter < max_iter
    iter = iter + 1; % Increment iteration counter
    
    % Initialize variables for power flow calculation
    P_calc = zeros(nbus, 1);
    Q_calc = zeros(nbus, 1);
    V_calc = busdata(:, 7);
    V_ang_calc = busdata(:, 8);
    
    % Calculate power injections
    for i = 1:nbus
        bus_type = busdata(i, 2);
        Pd = busdata(i, 3);
        Qd = busdata(i, 4);
        Gs = busdata(i, 5);
        Bs = busdata(i, 6);
        Vm = busdata(i, 7);
        Va = busdata(i, 8);
        baseKV = busdata(i, 9);
        
        V = Vm * exp(1i * deg2rad(Va));
        S = Pd + 1i * Qd;
        
        if bus_type ~= 1 % Exclude slack bus
            for j = 1:nbus
                Y_ij = ybus(i, j, linedata); % Get line admittance
                V_j = V_calc(j) * exp(1i * deg2rad(V_ang_calc(j)));
                S = S + V * conj(Y_ij) * V_j;
            end
        end
        
        P_calc(i) = real(S);
        Q_calc(i) = imag(S);
    end
    
    % Update bus voltages and angles using Newton-Raphson method
    for i = 1:nbus
        bus_type = busdata(i, 2);
        Pd = busdata(i, 3);
        Qd = busdata(i, 4);
        Gs = busdata(i, 5);
        Bs = busdata(i, 6);
        Vm = busdata(i, 7);
        Va = busdata(i, 8);
        baseKV = busdata(i, 9);
        
        V = Vm * exp(1i * deg2rad(Va));
        S = Pd + 1i * Qd;
        
        if bus_type ~= 1 % Exclude slack bus
            for j = 1:nbus
                Y_ij = ybus(i, j, linedata); % Get line admittance
                V_j = V_calc(j) * exp(1i * deg2rad(V_ang_calc(j)));
                S = S + V * conj(Y_ij) * V_j;
            end
            
            dP = real(S) - P_calc(i);
            dQ = imag(S) - Q_calc(i);
            
            % Update voltage magnitude and angle
            Vm = Vm - (1 / baseKV) * (Gs * Vm^2 + P_calc(i)) / Vm;
            Va = Va - (1 / baseKV) * (Bs * Vm^2 - Q_calc(i)) / Vm;
            
            % Store updated values
            busdata(i, 7) = Vm;
            busdata(i, 8) = Va;
        end
    end
    
    % Check convergence
    max_error = max(abs([dP; dQ]));
    if max_error < tol
        converged = 1; % Power flow converged
        break;
    end
end

end

function Y_ij = ybus(from_bus, to_bus, linedata)
% YBUS returns the line admittance between from_bus and to_bus
% Inputs:
%   from_bus: "From" bus number
%   to_bus: "To" bus number
%   linedata: Line data matrix [from_bus, to_bus, r, x, b, tap_ratio]
% Output:
%   Y_ij: Admittance between from_bus and to_bus

nline = size(linedata, 1); % Number of lines

for k = 1:nline
    if linedata(k, 1) == from_bus && linedata(k, 2) == to_bus
        r = linedata(k, 3);
        x = linedata(k, 4);
        b = linedata(k, 5);
        tap_ratio = linedata(k, 6);
        
        z = r + 1i * x; % Line impedance
        y = 1 / z; % Line admittance
        Y_ij = y / tap_ratio;
        return;
    end
end

Y_ij = 0; % Default admittance if line not found
end
