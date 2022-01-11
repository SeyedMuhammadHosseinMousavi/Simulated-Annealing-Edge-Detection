%% Simulated Annealing Edge Detection - % Created in (11 Jan 2022).
%----------------------------------------------------------------------------
% This code uses, provided filters as input and selects best combinations
% of these filters to fit them into better filters and apply them on input
% image. You can play with parameters or use your own image. 
% Feel free to contact me if you find any problem using the code: 
% mosavi.a.i.buali@gmail.com 
% SeyedMuhammadHosseinMousavi 
% My Google Scholar: https://scholar.google.com/citations?user=PtvQvAQAAAAJ&hl=en 
% My GitHub: https://github.com/SeyedMuhammadHosseinMousavi?tab=repositories 
% My ORCID: https://orcid.org/0000-0001-6906-2152 
% My Scopus: https://www.scopus.com/authid/detail.uri?authorId=57193122985 
% My MathWorks: https://www.mathworks.com/matlabcentral/profile/authors/9763916# 

%% Cleaning...
clc;
clear;
pic=imread('man.jpg');
pic=rgb2gray(pic);
%-------------------------------------------------------
% Filters (You Can Change Them)
polished1=[-2.2 -0.8 -0.6 ;0 0 0 ;2.2 0.8 0.6 ];
polished11=[2.2 0.8 0.6 ;0 0 0 ;-2.2 -0.8 -0.6 ];
polished111=[-0.1 -0.8 -0.6 ;0 0 0;0.1 0.8 0.6 ];
polished1111=[0.1 0.8 0.6 ;0 0 0 ;-0.1 -0.8 -0.6 ];
polished2=polished1';
polished22=polished11';
polished222=polished111';
polished2222=polished1111';
%--------------------------------------------------------
% Combining Filteres
Pol1=[polished1 polished11 polished111 polished1111];
Pol1(:,end+1)=1;
Pol2=[polished2 polished22 polished222 polished2222];
Pol2(:,end+1)=2;
PolFil=[Pol1; Pol2];
% Swap Filter Matrix Row Randomly Each Run for Productivity
PolFil_Swap = PolFil(randperm(size(PolFil, 1)), :);

%% Data Preparation
fordet=PolFil_Swap;
sizdet=size(fordet);
x=PolFil_Swap(:,1:sizdet(1,2)-1)';
t=PolFil_Swap(:,sizdet(1,2))';
nx=sizdet(1,2)-1;
nt=1;
nSample=sizdet(1,1);
% Converting Table to Struct
data.x=x;
data.t=t;
data.nx=nx;
data.nt=nt;
data.nSample=nSample;
nf=6;
% Cost Function
CostFunction=@(q) FSC(q,nf,data);

%% Simulated Annealing Parameters
MaxIt=40;      % Max Number of Iterations
MaxSubIt=5;    % Max Number of Sub-iterations
T0=5;          % Initial Temp
alpha=0.99;    % Temp Reduction Rate
% Create and Evaluate Initial Solution
sol.Position=CRS(data);
[sol.Cost, sol.Out]=CostFunction(sol.Position);
% Initialize Best Solution Ever Found
BestSol=sol;
% Array to Hold Best Cost Values
BestCost=zeros(MaxIt,1);
% Intialize Temp.
T=T0;

%% Simulated Annealing Run
for it=1:MaxIt
for subit=1:MaxSubIt
% Create and Evaluate New Solution
newsol.Position=NeighborCreation(sol.Position);
[newsol.Cost, newsol.Out]=CostFunction(newsol.Position);
% If NEWSOL is better than SOL
if newsol.Cost<=sol.Cost 
sol=newsol;
else % If NEWSOL is NOT better than SOL
DELTA=(newsol.Cost-sol.Cost)/sol.Cost;
P=exp(-DELTA/T);
if rand<=P
sol=newsol;
end
end
% Update Best Solution Ever Found
if sol.Cost<=BestSol.Cost
BestSol=sol;
end
end
% Store Best Cost Ever Found
BestCost(it)=BestSol.Cost;
% Display Iteration
disp(['In Iteration Number ' num2str(it) ': Best Cost Res = ' num2str(BestCost(it))]);
% Update Temp
T=alpha*T;
end

%% Plot SA Train
figure;
set(gcf, 'Position',  [450, 250, 600, 250])
plot(BestCost,'-.',...
'LineWidth',2,...
'MarkerSize',10,...
'MarkerEdgeColor','g',...
'Color',[0.9,0,0]);
title('Simulated Annealing')
xlabel('SA Iteration Number','FontSize',12,...
'FontWeight','bold','Color','g');
ylabel('SA Best Cost Result','FontSize',12,...
'FontWeight','bold','Color','g');
legend({'SA Train'});

%% Data Post Processing
% Extracting Data
RealData=PolFil_Swap;
% Extracting Labels
RealLbl=RealData(:,end);
FinalFeaturesInd=BestSol.Out.S;
% Sort Features
FFI=sort(FinalFeaturesInd);
% Select Final Features
SA_Features=RealData(:,FFI);
% Adding Labels
SA_Features(:,end+1)=RealLbl;

%% Applay SA Filters on Image
FinalFilt=SA_Features(:,1:end-1);
p1=imfilter(pic,FinalFilt(1:3,1:3));
p2=imfilter(pic,FinalFilt(4:6,1:3));
p3=imfilter(pic,FinalFilt(1:3,4:6));
p4=imfilter(pic,FinalFilt(4:6,4:6));
SA_Edge=rangefilt(abs(p1)+abs(p2)+abs(p3)+abs(p4));
%Canny Edge for Comparison
BW1 = edge(pic,'Canny');
canny=double(BW1);
% Log Edge for Comparison
BW2 = edge(pic,'log');
log=double(BW2);
% Plot Res
figure('units','normalized','outerposition',[0 0 1 1])
subplot(1,4,1)
subimage(pic);title('Original');
subplot(1,4,2)
subimage(log);title('Log Edges');
subplot(1,4,3)
subimage(canny);title('Canny Edges');
subplot(1,4,4)
subimage(SA_Edge);title('SA Edges');