% Particle Swarm Optimization (PSO) Algorithm

% Clear the workspace
clear;
close all;
clc;

% Define the problem parameters
numVariables = 2;  % Number of variables to be optimized
numParticles = 50;  % Number of particles in the swarm
maxIter = 100;  % Maximum number of iterations

% Define the bounds for the variables
lb = [-5 -5];  % Lower bounds
ub = [5 5];  % Upper bounds

% Define the objective function to be optimized
fitnessFunc = @(x) sum(x.^2);  % Sphere function: f(x) = x1^2 + x2^2

% Initialize the swarm
particlePos = zeros(numParticles, numVariables);
particleVel = zeros(numParticles, numVariables);
particleBestPos = zeros(numParticles, numVariables);
particleBestFitness = zeros(numParticles, 1);
globalBestPos = zeros(1, numVariables);
globalBestFitness = Inf;

% Initialize the particles
for i = 1:numParticles
    particlePos(i, :) = lb + rand(1, numVariables).*(ub - lb);
    particleVel(i, :) = rand(1, numVariables);
    particleBestPos(i, :) = particlePos(i, :);
    particleBestFitness(i) = fitnessFunc(particleBestPos(i, :));
    
    % Update the global best
    if particleBestFitness(i) < globalBestFitness
        globalBestFitness = particleBestFitness(i);
        globalBestPos = particleBestPos(i, :);
    end
end

% Perform the optimization
iter = 1;
while iter <= maxIter
    for i = 1:numParticles
        % Update the particle velocity
        particleVel(i, :) = particleVel(i, :) + rand(1, numVariables).*(particleBestPos(i, :) - particlePos(i, :)) ...
            + rand(1, numVariables).*(globalBestPos - particlePos(i, :));
        
        % Update the particle position
        particlePos(i, :) = particlePos(i, :) + particleVel(i, :);
        
        % Update the particle's best position and fitness
        fitness = fitnessFunc(particlePos(i, :));
        if fitness < particleBestFitness(i)
            particleBestPos(i, :) = particlePos(i, :);
            particleBestFitness(i) = fitness;
        end
        
        % Update the global best
        if fitness < globalBestFitness
            globalBestFitness = fitness;
            globalBestPos = particlePos(i, :);
        end
    end
    
    % Display the best fitness value at each iteration
    disp(['Iteration ', num2str(iter), ', Best Fitness: ', num2str(globalBestFitness)]);
    
    % Increment the iteration counter
    iter = iter + 1;
end

% Display the optimal solution
disp('Optimal Solution:');
disp(globalBestPos);
