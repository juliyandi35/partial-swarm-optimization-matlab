clear all; clc;
% Power Flow Model Parameters
nVariables = 3;  % Number of decision variables (e.g., location, size, type)

% Bus data
% busData = [busIndex, loadDemand, generationCapacity]
BusDataFilePath = 'C:\Users\JULI YANDI RAHMAN\Downloads\Kerjaan\Project 2336\BusData.xlsx';
busData = readtable(BusDataFilePath);

% Line data
% lineData = [busIndexFrom, busIndexTo, resistance, reactance]
LineDataFilePath = 'C:\Users\JULI YANDI RAHMAN\Downloads\Kerjaan\Project 2336\LineData.xlsx';
LineData = readtable(LineDataFilePath);
% Calculate Power Loss Function

% PSO Parameters
swarmSize = 50;             % Number of particles in the swarm
maxIterations = 100;        % Maximum number of iterations
c1 = 2;                     % Cognitive coefficient
c2 = 2;                     % Social coefficient
w = 0.7;                    % Inertia weight
VarMin = 2;
VarMax = 50;
MaxVelocity = 0.1*(VarMax-VarMin);
MinVelocity = -MaxVelocity;
% Random Initialization of Particle Positions
particlePositions = randi([1, size(busData, 1)], swarmSize, nVariables);  % Randomly select bus indices

% Initialize the best personal positions and fitness values
particleBestPositions = particlePositions;
particleBestFitness = inf(swarmSize, 1);

% Initialize the best global position and fitness value
globalBestPosition = zeros(1, nVariables);
globalBestFitness = inf;
bestBusIndex = 0;  % Variable to store the best bus index

% PSO Optimization Loop
for iteration = 1:maxIterations
    % Evaluate fitness for each particle
    for particle = 1:swarmSize
         % Update particle velocities and positions
         particlePositions(particle, :) = particlePositions(particle, :) + ...
            w * (particleBestPositions(particle, :) - particlePositions(particle, :)) + ...
            c1 * rand(1, nVariables) .* (particleBestPositions(particle, :) - particlePositions(particle, :)) + ...
            c2 * rand(1, nVariables) .* (globalBestPosition- particlePositions(particle, :));
         % Apply Velocity and Position Limits
         [r,c]=size(busData);
         nk=c;
         for i=1:swarmSize
             for j=1:nk
                 if particlePositions(i,j)>MaxVelocity;
                     particlePositions(i,j)=MaxVelocity;
                 end
                 if particlePositions(i,j)<MinVelocity;
                     particlePositions(i,j)=MinVelocity;
                 end
             end
         end
         
         fitness = calculatePowerLoss(particlePositions(particle, :));            
        
        % Update personal best if fitness improves
        if fitness < particleBestFitness(particle)
            particleBestFitness(particle) = fitness;
            particleBestPositions(particle, :) = particlePositions(particle, :);
        end
        
        % Update global best if fitness improves
        if fitness < globalBestFitness
            globalBestFitness = fitness;
            globalBestPosition(iteration,:) = particleBestPositions(particle, :);
            bestBusIndex = particlePositions(iteration);
        end
    end
end

% Extract the optimal solution
optimalSolution = ceil(abs(globalBestPosition));

% Find the corresponding row in the busData table
busIndex = globalBestPosition(1);
busIndex = round(busIndex);
rowIndex = find(busData.BusID == abs(ceil(bestBusIndex)));

% Retrieve the generator capacity for the best bus
bestGeneratorCapacity = busData.generationCapacity(rowIndex);

% Plot the convergence curve
Length = length(particleBestPositions(:,1));
figure;
plot(1:Length, particleBestPositions(:,1))
hold on
plot(1:Length, particleBestPositions(:,2))
hold on
plot(1:Length, particleBestPositions(:,3))
legend('Bus 1','Bus 2','Bus 3');
xlabel('Iteration');
ylabel('Best Position');
title('PSO Process Curve');

disp('Best Generator Capacity:')
disp(bestGeneratorCapacity)

% Display results or further analysis
disp('Optimal Solution:')
disp(optimalSolution)

function powerLoss = calculatePowerLoss(connectionConfig)
    % Calculate power losses based on the given connection configuration
    powerLoss = 0;
    busData = [1	0	20;
        2	0	19.826;3	0	19.512;
        4	0	19.509;
        5	0	19.488;
        6	0	19.469;
        7	0.013	19.439;
        8	0	19.423;
        9	0	19.396;
        10	0	19.376;
        11	0	19.331;
        12	0.026	19.327;
        13	0.072	19.312;
        14	0	19.257;
        15	0	19.233;
        16	0	19.203;
        17	0	19.156;
        18	0.017	19.14;
        19	0	19.115;
        20	0	19.095;
        21	0	19.065;
        22	0	19.048;
        23	0	19.012;
        24	0	18.95;
        25	0	18.886;
        26	0	18.847;
        27	0	18.839;
        28	0.035	18.839;
        29	0.043	18.838;
        30	0	18.835;
        31	0.024	18.802
        32	0	18.784;
        33	0	18.766;
        34	0	18.758;
        35	0.053	18.757;
        36	0	18.755;
        37	0	18.746;
        38	0	18.746;
        39	0.026	18.746;
        40	0.036	18.746;
        41	0.686	19.824;
        42	0	19.395;
        43	0.146	19.394;
        44	0.008	19.376;
        45	0.047	19.331;
        46	0.018	19.115;
        47	0.038	19.095;
        48	0.064	19.046;
        49	0.009	19.012;
        50	0.05	18.846;
        51	0	18.846;
        52	0.045	18.845;
        53	0	18.845;
        54	0.017	18.845;
        55	0.016	18.844;
        56	0.046	18.837;
        57	0.035	18.835;
        58	0.032	18.835;
        59	0.017	18.784;
        60	0.017	18.784;
        61	0.017	18.764;
        62	0.05	18.764;
        63	0	18.756;
        64	0.019	18.751;
        65	0	18.751;
        66	0.038	18.749;
        67	0.02	18.749;
        68	0.019	18.755;
        69	0	18.742;
        70	0.026	18.739;
        71	0.73	18.732;
        72	0.005	18.746;
        73	0.02	18.746;
        74	0.027	18.746;
        75	0.021	18.746;
        76	0.013	19.394;
        77	0.017	18.845;
        78	0.025	18.845;
        79	0.025	18.845;
        80	0.018	18.844;
        81	0.029	18.844;
        82	0.056	18.764;
        83	0.058	18.764;
        84	0.018	18.756;
        85	0.04	18.755;
        86	0.017	18.751;
        87	0.012	18.742];
lineData =[  1	2	15.64	23.87;
        2	3	43	65.61;
        3	4	0.45	0.5;
        4	5	2.85	4.35;
        5	6	2.17	2.42;
        6	7	2.59	3.94;
        7	8	1.37	2.09;
        8	9	3.05	3.41;
        9	10	1.84	2.81;
        10	11	4.3	6.56;
        11	12	0.36	0.56;
        12	13	1.43	2.19;
        13	14	5.59	8.53;
        14	15	3.19	3.58;
        15	16	3.03	4.63;
        16	17	6.05	6.77;
        17	18	1.61	2.46;
        18	19	2.51	3.83;
        19	20	2.12	3.23;
        20	21	3.07	4.68;
        21	22	2.33	2.61;
        22	23	3.91	5.96;
        23	24	6.71	10.23;
        24	25	8.96	10.04;
        25	26	4.21	6.42;
        26	27	0.95	1.45;
        27	28	0.03	0.05;
        28	29	0.13	0.19;
        29	30	0.34	0.52;
        30	31	4.65	7.1;
        31	32	2.58	3.94;
        32	33	2.7	4.13;
        33	34	1.31	2;
        34	35	0.3	0.46;
        35	36	0.3	0.45;
        36	37	1.89	2.88;
        37	38	0.28	0.43;
        38	39	0.34	0.52;
        39	40	0.27	0.41;
        2	41	0.48	0.73;
        9	42	1.72	2.63;
        42	43	0.09	0.14;
        10	44	0.82	1.26;
        11	45	0.04	0.07;
        19	46	1.48	2.26;
        20	47	0.28	0.43;
        22	48	4.52	6.89;
        23	49	1.08	1.64;
        26	50	0.43	0.66;
        50	51	0.5	0.77;
        51	52	0.81	1.24;
        52	53	1.02	1.55;
        53	54	0.35	0.53;
        54	55	0.81	1.24;
        27	56	6.29	9.6;
        30	57	0.54	0.83;
        57	58	0.6	0.91;
        32	59	0.35	0.53;
        59	60	1.18	1.79;
        33	61	1.53	2.34;
        61	62	0.3	0.45;
        34	63	2.5	3.81;
        63	64	9.7	14.8;
        64	65	0.48	0.74;
        65	66	8.72	13.3;
        66	67	0.89	1.36;
        36	68	1.38	2.11;
        37	69	1.16	1.78;
        69	70	0.8	1.22;
        70	71	1.67	2.54;
        38	72	0.7	1.08;
        72	73	2.08	3.18;
        39	74	1.12	1.71;
        40	75	0.54	0.83;
        42	76	0.24	0.36;
        51	77	0.72	1.09;
        77	78	0.23	0.36;
        78	79	0.3	0.45;
        53	80	2.55	3.9;
        80	81	2.33	3.55;
        61	82	0.52	0.8;
        82	83	0.83	1.27;
        63	84	1.9	2.9;
        84	85	1.9	2.9;
        65	86	1.07	1.63;
        69	87	0.49	0.75];
    for i = 1:size(lineData, 1)
        fromBus = lineData(i, 1);
        toBus = lineData(i, 2);
        resistance = lineData(i, 3);
        reactance = lineData(i, 4);
        
        % Check if the line is affected by the connection configuration
        if ismember(fromBus, connectionConfig) || ismember(toBus, connectionConfig)
            % Calculate the power flowing through the line
            % For simplicity, let's assume the power flowing through the line is equal to the load demand
            loadDemand = busData(toBus, 2);
            powerFlow = loadDemand;
            
            % Calculate the power loss based on the power flow and line parameters
            powerLoss = powerLoss + (resistance * powerFlow^2) + (reactance * powerFlow^2);
            
        end
    end
end      

   