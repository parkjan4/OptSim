clear all; clc;
%load('saved_data/OUTPUT_baselineVNS_no_reservation.mat')
%load('saved_data/Arrangement_baselineVNS_no_reservation.mat')
load('saved_data/OUTPUT_goldenVNS_no_reservation.mat')
load('saved_data/Arrangement_goldenVNS_no_reservation.mat')
OUTPUT_baseline = OUTPUT;
ARR_baseline = Arrangement;

load('saved_data/OUTPUT_goldenVNS_reservation.mat')
load('saved_data/Arrangement_goldenVNS_reservation.mat')
OUTPUT_gVNS = OUTPUT;
ARR_gVNS = Arrangement;

clear OUTPUT
clear Arrangement

%% Find the optimal table arrangement
X = []; Y = [];
for i=1:11
    X = [X [1 2 3 4 5]*ARR_baseline.(['arrangement' char(string(i))])];
    Y = [Y mean(OUTPUT_baseline.(['arrangement' char(string(i))]).profit_all)];
end
[~,b1] = max(Y) %b=11

X = []; Y = [];
for i=1:12
    X = [X [1 2 3 4 5]*ARR_gVNS.(['arrangement' char(string(i))])];
    Y = [Y mean(OUTPUT_gVNS.(['arrangement' char(string(i))]).profit_all)];
end
[~,b2] = max(Y) %b=9
%%
close all
data_b = OUTPUT_baseline.arrangement9.profit_all;
data_g = OUTPUT_gVNS.arrangement10.profit_all;
figure;
h1=histogram(data_b,10,'FaceColor','r','FaceAlpha',0.4);
hold on;
h2=histogram(data_g,10,'FaceColor','b','FaceAlpha',0.3);
ylim=get(gca,'ylim');
l1=line([mean(data_b) mean(data_b)], ylim,'Color','r','LineStyle','--','LineWidth',2.0); 
l2=line([mean(data_g) mean(data_g)], ylim,'Color','b','LineStyle','--','LineWidth',2.0); 
%legend([h1 h2 l1 l2],'Seating Policy 1','Seating Policy 2','Mean of Seating Policy 1)','Mean of Seating Policy 2')
legend([h1 h2 l1 l2],'Baseline','Golden Section','Mean of baseline solution','Mean of golden section solution')
ylabel('Frequency')
xlabel('Profit [$]')
title('Comparison of profit distribution using baseline vs. golden section VNS')

%% Scatter points (4)
close all

X = [100-98.76 100-91.17 100-95.06 100-95.33];
Y = [6.5 1.1 1.11 1.3];
Y_ = [11419 12238 mean(OUTPUT_baseline.arrangement9.profit_all) mean(OUTPUT_gVNS.arrangement10.profit_all)]; 
scatter(X,Y,'filled')
%text(X(1)-1.7,Y(1),"Naive Solution")
%text(X(2)+0.1,Y(2),"Greedy Solution")
%text(X(3)+0.00075,Y(3)-50,"Golden Section VNS (policy 1)")
%text(X(4)+0.00125,Y(4)+50,"Golden Section VNS (policy 2)")
ylabel('Avg. # customers who share tables')
xlabel('Avg. % abandonments')
title('Number of Shared Occasions vs. % Abandonments')
%text(X(1:end-1),Y,{"Naive Solution","Greedy Solution","Golden Section VNS (policy 1)","Golden Section VNS (policy 2)"})