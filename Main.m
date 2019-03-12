% Customer arrival table
arrival = [1, 8 ,3;
            2, 14, 20;
            3, 11, 15;
            4, 9, 13;
            5, 7 ,14];
%% 
arrivalinfo = [];
for T=1:3
    arrivalinfo = [arrivalinfo; HomogeneousPoissonProcess(T, arrival)];
end