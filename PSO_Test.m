% Distributed Generator Analysis using Particle Swarm Optimization (PSO)

% Clear the workspace
clear;
close all;
clc;

% Define the problem parameters
numDGs = 4;  % Number of distributed generators
maxIter = 100;  % Maximum number of iterations
numParticles = 50;  % Number of particles in the swarm
w = 0.8;  % Inertia weight
c1 = 2;  % Cognitive coefficient
c2 = 2;  % Social coefficient

% Define the power limits for each distributed generator
Pmin = [10; 20; 30; 40];  % Minimum power output
Pmax = [50; 60; 70; 80];  % Maximum power output

% Define the objective function
fitnessFunc = @(P) -sum(P);  % Negative sum of power output

% Initialize the swarm
particlePos = zeros(numParticles, numDGs);
particleVel = zeros(numParticles, numDGs);
particleBestPos = zeros(numParticles, numDGs);
particleBestFitness = zeros(numParticles, 1);
globalBestPos = zeros(1, numDGs);
globalBestFitness = -Inf;

% Initialize the particles
for i = 1:numParticles
    particlePos(i, :) = Pmin + rand(size(Pmin)).*(Pmax - Pmin);
    particleVel(i, :) = rand(size(Pmin)).*(Pmax - Pmin)/10;
    particleBestPos(i, :) = particlePos(i, :);
    particleBestFitness(i) = fitnessFunc(particleBestPos(i, :));
    
    % Update the global best
    if particleBestFitness(i) > globalBestFitness
        globalBestFitness = particleBestFitness(i);
        globalBestPos = particleBestPos(i, :);
    end
end

% Perform the optimization
iter = 1;
while iter <= maxIter
    for i = 1:numParticles
        % Update the particle velocity
        particleVel(i, :) = w*particleVel(i, :) ...
            + c1*rand(1, numDGs).*(particleBestPos(i, :) - particlePos(i, :)) ...
            + c2*rand(1, numDGs).*(globalBestPos - particlePos(i, :));
        
        % Apply velocity limits
        particleVel(i, :) = min(max(particleVel(i, :), Pmin - particlePos(i, :)), Pmax - particlePos(i, :));
        
        % Update the particle position
        particlePos(i, :) = particlePos(i, :) + particleVel(i, :);
        
        % Apply position limits
        particlePos(i, :) = min(max(particlePos(i, :), Pmin), Pmax);
        
        % Update the particle's best position and fitness
        fitness = fitnessFunc(particlePos(i, :));
        if fitness > particleBestFitness(i)
            particleBestPos(i, :) = particlePos(i, :);
            particleBestFitness(i) = fitness;
        end
        
        % Update the global best
        if fitness > globalBestFitness
            globalBestFitness = fitness;
            globalBestPos = particlePos(i, :);
        end
    end
    
    % Display the best fitness value at each iteration
    disp(['Iteration ', num2str(iter), ', Best Fitness: ', num2str(globalBestFitness)]);
    
    % Increment the iteration counter
    iter = iter + 1;
end

% Display the optimal power output for each distributed generator
disp('Optimal Power Output:');
disp(globalBestPos);
