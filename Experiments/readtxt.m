fileID = 'TEST8.TXT';
L = 9;
T = readtable(fileID);
Data = table2array(T);
time = Data(:,1);
repiods =[0, 50000, 100000, 150000, 200000, 250000, 300000, 350000];
figure(1); hold on
for i =2:2
    %figure;
    plot(time,Data(:,i),'-','Linewidth',1);
    ylim([1.7, 2.45])
end
legend('1','2','3','4','5','6','7','8');