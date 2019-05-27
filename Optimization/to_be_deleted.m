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
data_b = OUTPUT_baseline.arrangement9.odds_abandon;
data_g = OUTPUT_gVNS.arrangement10.num_admitted_all;
figure;
h1=histogram(data_b,15,'FaceColor','r','FaceAlpha',0.4);
hold on;
h2=histogram(data_g,16,'FaceColor','b','FaceAlpha',0.3);
ylim=get(gca,'ylim');
l1=line([mean(data_b) mean(data_b)], ylim,'Color','r','LineStyle','--','LineWidth',2.0); 
l2=line([mean(data_g) mean(data_g)], ylim,'Color','b','LineStyle','--','LineWidth',2.0); 
legend([h1 h2 l1 l2],'Seating Policy 1','Seating Policy 2','Mean of Seating Policy 1)','Mean of Seating Policy 2')
ylabel('Frequency')
xlabel('Profit [$]')
title('Comparison of profit distribution using Golden Section VNS under two Seating Policies')