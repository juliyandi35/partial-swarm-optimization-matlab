% Copyright (c) 2016, Yarpiz (www.yarpiz.com)
% All rights reserved. Please read the "license.txt" for license terms.
%
% Project Code: YTEA101
% Project Title: Particle Swarm Optimization Video Tutorial
% Publisher: Yarpiz (www.yarpiz.com)
%
% Developer and Instructor: S. Mostapha Kalami Heris (Member of Yarpiz Team)
%
% Contact Info: sm.kalami@gmail.com, info@yarpiz.com
%
clc;
tic
busdata=dataloadflowetapS1
busdata(1,:)=[];
busdatabar5=table2array(busdata(:,5))
linedata=dataloadflowetapS2
%% Problem Definiton
runno=1;
for run=1:runno
    basemva=100;
    Pdt= sum (busdatabar5);
    problem.foj = @(x)fj(x); % Cost Function
    problem.nVar = 3; % Number of Unknown (Decision) Variables
    problem.VarMin = [2 0.25 0.95];
    problem.VarMax = [50 1 1.05]; % Lower Bound of Decision Variables
    %problem.Cap_Min = [0.5];
    %problem.Cap_Max = [2];
    %% Parameters of PSO
    params.MaxIt =100; % Maximum Number of Iterations
    params.nPop = 50; % Population Size (Swarm Size)
    params.w = 1; % Intertia Coefficient
    params.wdamp = 0.9; % Damping Ratio of Inertia Coefficient
    params.c1 = 2; % Personal Acceleration Coefficient
    params.c2 = 2; % Social Acceleration Coefficient
    params.ShowIterInfo = true; % Flag for Showing Iteration Informatin
    %% Calling PSO
    out = pso(problem, params);
    BestSol = out.BestSol;
    pop = out.pop;
    BestCosts = out.BestCosts;
    %% Results
    [Ploss, Place, Size] = fj(BestSol.Position);
    fprintf ('Losses = %g MW \n',Ploss)
    fprintf ('Lokasi = %g \n',Place)
    fprintf ('Ukuran = %g MVAR \n',Size)
end

function [Ploss, Place, Size] = fj(x)
basemva = 100; accuracy = 0.01; accel = 0.08; maxiter = 100;
printWarning=0;
busdata=dataloadflowetapS1
busdata(1,:)=[];
busdatabar5=table2array(busdata(:,5))
linedata=dataloadflowetapS2
Loc=
vmax=VarSize/3;
for i=1:vmax
    %Posisi dan Ukuran Kapasitor
    busdata(Loc(1,(uint8(x(1,i)))),11)=x(1,i+vmax);
    Place = Loc(1,(uint8(x(1,i))));
    Size = x(1,i+vmax);
end
lfybus % form the bus admittance matrix
lfnewton % Load flow solution by Gauss-Seidel method
%%busout % Prints the power flow solution on the screen
lineflow % Computes and displays the line flow and losses
Ploss=real(SLT);
%PP=abs(Pgg)';
end

function out = pso(problem, params)
%% Problem Definiton
disp('PSO is optimizing your problem');
foj = problem.foj; % Cost Function
nVar = problem.nVar; % Number of Unknown (Decision) Variables
VarSize = [1 nVar]; % Matrix Size of Decision Variables
VarMin = problem.VarMin; % Lower Bound of Decision Variables
VarMax = problem.VarMax; % Upper Bound of Decision Variables
%CapMin = problem.Cap_Min;
%CapMax = problem.Cap_Max;
%% Parameters of PSO
MaxIt = params.MaxIt; % Maximum Number of Iterations
nPop = params.nPop; % Population Size (Swarm Size)
w = params.w; % Intertia Coefficient
wdamp = params.wdamp; % Damping Ratio of Inertia Coefficient
c1 = params.c1; % Personal Acceleration Coefficient
c2 = params.c2; % Social Acceleration Coefficient
% The Flag for Showing Iteration Information
ShowIterInfo = params.ShowIterInfo;
MaxVelocity = 0.1*(VarMax-VarMin);
MinVelocity = -MaxVelocity;
%% Initialization
% The Particle Template
empty_particle.Position = [];
empty_particle.Velocity = [];
empty_particle.Cost = [];
empty_particle.Best.Position = [];
empty_particle.Best.Cost = [];
% Create Population Array
particle = repmat(empty_particle, nPop, 1);
% Initialize Global Best
GlobalBest.Cost = inf;
% Initialize Population Members
for i=1:nPop
     % Generate Random Solution
     particle(i).Position = unifrnd(VarMin, VarMax, VarSize);
     particle(i).Position;
     % Initialize Velocity
     particle(i).Velocity = zeros(VarSize);
     % Evaluation
     particle(i).Cost = foj(particle(i).Position);
     % Update the Personal Best
     particle(i).Best.Position = particle(i).Position;
     particle(i).Best.Cost = particle(i).Cost;
     % Update Global Best
     if particle(i).Best.Cost < GlobalBest.Cost
         GlobalBest = particle(i).Best;
     end
 end
 
 % Array to Hold Best Cost Value on Each Iteration
 BestCosts = ones(MaxIt, 1);
 %% Main Loop of PSO
 for it=1:MaxIt
     for i=1:nPop
         % Update Velocity
         particle(i).Velocity = 0.75*particle(i).Velocity ...
             + c1*rand(VarSize).*(particle(i).Best.Position - particle(i).Position) ...
             + c2*rand(VarSize).*(GlobalBest.Position - particle(i).Position);
         % Apply Velocity Limits
         particle(i).Velocity = max(particle(i).Velocity, MinVelocity);
         particle(i).Velocity = min(particle(i).Velocity, MaxVelocity);
         % Update Position
         particle(i).Position = particle(i).Position + particle(i).Velocity;
         % Apply Lower and Upper Bound Limits
         particle(i).Position = max(particle(i).Position, VarMin);
         particle(i).Position = min(particle(i).Position, VarMax);
         % Evaluation
         particle(i).Cost = foj(particle(i).Position);
         % Update Personal Best
         if particle(i).Cost < particle(i).Best.Cost;
             particle(i).Best.Position = particle(i).Position;
             particle(i).Best.Cost = particle(i).Cost;
             % Update Global Best
             if particle(i).Best.Cost < GlobalBest.Cost;
                 GlobalBest = particle(i).Best;
             end
         end
     end
     % Store the Best Cost Value
     BestCosts(it) = GlobalBest.Cost;
     % Display Iteration Information
     if ShowIterInfo
         disp(['Iteration ' num2str(it) ': Best Cost = '
             num2str(BestCosts(it))]);
     end
     % Damping Inertia Coefficient
     w = w * wdamp;
 end
 out.pop = particle;
 % out=[BestCosts;GlobalBest'] ;
     out.BestSol = GlobalBest;
     out.BestCosts = BestCosts;
end