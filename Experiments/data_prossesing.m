close all
fileID = '06_06_60sec.TXT';
%fileID = 'period50_1.TXT';
%fileID = 'period50_2.TXT';
L = 9;

%%%  Read DATA  %%%%%%
T = readtable(fileID);
Data = table2array(T);
time = Data(:,1);
%%%%%%%%% SETTINGS %%%%%%%%%%%

LeTime = length(time);
Period_time = 60000;
periods =[1, 2, 3, 4, 5, 6, 7];
LePeriod = length(periods);
ArrLine = zeros(1,LePeriod);
for k =1:LePeriod
    ArrLine(1,k)= fix(time(LeTime)/(Period_time*periods(k)));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i =2:L
    if i==2
        figure(i-1);
        plot(time,Data(:,i),'-','Linewidth',1);
    else
        figure(i-1);
        plot(time,Data(:,i),'-','Linewidth',1);
        for j = 1:ArrLine(i-2)
            if mod(j,2)==0
                xl = xline(Period_time*j*(i-2));
                xl.LabelHorizontalAlignment = 'left';
            else
                xl = xline(Period_time*j*(i-2),'r','On');
                xl.LabelHorizontalAlignment = 'left';
            end
        end
    end

    ylim([1.7, 2.45])
    legend(['Cell'  num2str(i-1)]);
end
