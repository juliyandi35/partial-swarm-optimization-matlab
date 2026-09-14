clear all;clc;
% PSO
% Bus data
% busData = [busID, loadDemand, generationCapacity]
BusDataFilePath = 'C:\Users\JULI YANDI RAHMAN\Downloads\Kerjaan\Project 2336\BusData.xlsx';
bus_data = readtable(BusDataFilePath);
bus_data = table2array(bus_data);

% Line data
% lineData = [busIndexFrom, busIndexTo, resistance, reactance]
LineDataFilePath = 'C:\Users\JULI YANDI RAHMAN\Downloads\Kerjaan\Project 2336\LineData.xlsx';
LineData = readtable(LineDataFilePath);
line_data = table2array(LineData);

%Atur Parameter
np=50; %Jumlah partikel
itmax=100; %Iterasi Maksimal
ba=max(max(line_data)); %Batas Atas
bb=min(min(line_data)); %Batas Bawah
t=cputime;

%Hitung Matriks biayanya
L=length(line_data);
for i=1:L
    for j=1:L
        dx(i,j)=sqrt((line_data(i,1)-line_data(j,1)).^2+(line_data(i,2)-line_data(j,2)).^2);
    end
end
[r,c]=size(dx);
nk=c;
x=rand(np,nk)*(ba-bb)+bb;
v=rand(np,nk);
[min1 perm]=sort(x,2);
perm_tsp=[];
for p=1:size(perm,1)
    temp_perm=perm(p,:);
    temp_perm(temp_perm==1)=[];
    temp_perm=[1,temp_perm,1];
    perm_tsp=[perm_tsp;temp_perm];
end
%evaluasi nilai fungsi tujuan biaya total tiap rute
biaya=zeros(np,1);
for i=1:np
    x1=perm_tsp(i,:);
    biaya(i)=jartsp(x1,dx);
    %memanggil fungsi perhitungan biaya rute tsp
end
f=biaya;
%perbarui nilai Pbest dan Gbest partikel awal
Pbest=x; %local best
fbest=f; %fungsi tujuan terbaik
[minf,idk]=min(fbest);
Gbest=x(idk,:); %Global Best
minftot=[];
minfk=[];

%perbarui posisi dan kecepatan
it=1; %iterasinya
rhomax=0.9;
rhomin=0.4; %rentang inersia yang dipakai
while it<itmax
    r1=rand;
    r2=rand;
    rho=rhomax-((rhomax-rhomin)/itmax)*it; %bobot inersia
    for j=1:np
        v(j,:)=rho.*v(j,:)+r1.*(Pbest(j,:)-x(j,:))+r2.*(Gbest-x(j,:));
        x(j,:)=x(j,:)+v(j,:);
    end
    %penyesuaian agar x tidak melanggar interval
    for i=1:np
        for j=1:nk
           if x(i,j)>ba
               x(i,j)=ba;
           end
           if x(i,j)<bb
               x(i,j)=bb;
           end
        end
    end
    %urutkan nilai random biar dapat rute dari yang terkecil
    [min1 perm]=sort(x,2);
    
    perm_tsp=[];
    for p=1:size(perm,1)
        temp_perm=perm(p,:);
        temp_perm(temp_perm==1)=[];
        temp_perm=[1,temp_perm,1];
        perm_tsp=[perm_tsp;temp_perm];
    end
    %perm_tsp adalah permutasi rute tsp
    %evaluasi nilai fungsi tujuan permutasi tsp
    biaya=zeros(np,1);
    for i=1:np
        x1=perm_tsp(i,:);
        biaya(i)=jartsp(x1,dx);
    end
    f=biaya;
    %perbarui fbest, Pbest, Gbest
    changerow=f<fbest;
    fbest=fbest.*(1-changerow)+f.*changerow;
    Pbest(find(changerow),:)=x(find(changerow),:);
    [minf,idk]=min(fbest);
    Gbest=Pbest(idk,:);
    minftot=[minftot;minf];
    
    best(it)=minf;
    avrfit(it)=mean(fbest);
    
    it=it+1; %penambahan jumlah iterasi
end
%output solution
lastbest=Pbest; %nilai random partikel terbaik di iter terakhir
[min1 perm]=sort(lastbest,2);

perm_tsp=[];
for p=1:size(perm,1)
    temp_perm=perm(p,:);
    temp_perm(temp_perm==1)=[];
    temp_perm=[1,temp_perm,1];
    perm_tsp=[perm_tsp;temp_perm];
end
biaya=zeros(np,1);
for i=1:np
    x1=perm_tsp(i,:);
    biaya(i)=jartsp(x1,dx);
end
f=biaya;

[biaya_minimum,idk]=min(f);
biaya_minimum
rute_optimum=perm_tsp(idk,:)
t=cputime-t%total waktu komputasinya

% Extract the optimal solution
bus_optimal= Gbest(end-2:end);

% Find the corresponding row in the busData table
busIndex = bus_optimal;
rowIndex = zeros(3,1);
for i=1:length(busIndex)
    rowIndex(i,1) = find(bus_data(:,1)== busIndex(i));
end

% Retrieve the generator capacity for the best bus
bestGeneratorCapacity = zeros(3,1);
for i=1:length(rowIndex)
    bestGeneratorCapacity(i,1) = bus_data(rowIndex(i),3);
end

disp('Optimal Bus:')
disp(bus_optimal)
disp('Best Generator Capacity:')
disp(bestGeneratorCapacity)


%buat grafik
fh=figure(1)
avrfit(end)=avrfit(end-1)
best(end)=best(end-1)
plot(avrfit,'--r','LineWidth',1)%plot rata-rata
hold on
plot(best,'k','LineWidth',1)%plot best
hold off
title('Fungsi Tujuan Terbaik Vs. Rata-rata Fungsi Tujuan Terbaik')
xlabel('Iteration')
ylabel('Fitness')
Xvalues=get(gca,'XTick');
Yvalues=get(gca,'YTick');
set(gca,'XTickLabel',Xvalues);
set(gca,'YTickLabel',Yvalues);
legend('Rata-rata Fungsi Tujuan','Fungsi Tujuan Terbaik')
function biaya=jartsp(x1,dx)
[r,c]=size(x1);
k=c-1; %Jumlah busnya
s=0; %biaya awal di bus pertama
for j=1:k
    s=s+dx(x1(j),x1(j+1)); %akumulasi biaya rute
end
biaya=s;
end