fileID = '28_04.TXT';
L = 9;
T = readtable(fileID);
Data = table2array(T);
time = Data(:,1);
figure(1); hold on
for i = [8,9]
    %figure;
    plot(time,Data(:,i),'-','Linewidth',1);
    ylim([1.7, 2.45])
end
legend('1','2','3','4','5','6','7','8');