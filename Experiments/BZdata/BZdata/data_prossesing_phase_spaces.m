close all
fileID = '06_06_60sec.TXT';
filename = 'testdata.xlsx';
%fileID = 'period50_1.TXT';
%fileID = 'period50_2.TXT';
L = 9;
C = cell(1,8);
nsamples = 101627; %first n samples to process
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
h = zeros(1,LePeriod);
for k =1:LePeriod
    %ArrLine(1,k)= fix(time(LeTime)/(Period_time*periods(k)));
    ArrLine(1,k)= fix(time(nsamples)/(Period_time*periods(k))); % количество переключений
    h(1,k) = fix(nsamples/ArrLine(1,k));% шаг переключения
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%FIR
%b = [0.000293162489138550	0.000442356348263515	0.000756055458570033	0.00119542664515095	0.00178533758187394	0.00255013620535108	0.00351188449600975	0.00468893138786697	0.00609425248653930	0.00773411478422784	0.00960680985433102	0.0117015115407750	0.0139974644327942	0.0164641277975763	0.0190613165480000	0.0217399464912184	0.0244432996793163	0.0271091188579524	0.0296714334145505	0.0320630307332575	0.0342184841990609	0.0360767715893329	0.0375833640188232	0.0386935528270539	0.0393736064618997	0.0396025758380217	0.0393736064618997	0.0386935528270539	0.0375833640188232	0.0360767715893329	0.0342184841990609	0.0320630307332575	0.0296714334145505	0.0271091188579524	0.0244432996793163	0.0217399464912184	0.0190613165480000	0.0164641277975763	0.0139974644327942	0.0117015115407750	0.00960680985433102	0.00773411478422784	0.00609425248653930	0.00468893138786697	0.00351188449600975	0.00255013620535108	0.00178533758187394	0.00119542664515095	0.000756055458570033	0.000442356348263515	0.000293162489138550];
%a=  1;
%IIR
g = 0.000000379696120;
b = g*[1.000000000000000 7.999999999999996 27.999999999999968 55.999999999999936 69.999999999999943 56.000000000000000 27.999999999999982 8.000000000000000 1.000000000000001];
a = [1.000000000000000 -6.211691381483218 17.042970307597223 -26.950123172796534 26.842856973570790 -17.233085015277751 6.960202463578208 -1.616142442388830 0.165109469406813];

for i = 2:L
        Xd = detrend(Data(1:nsamples,i),2);
        X = filter(b,a,Xd);
        dX = diff4(X); %derivative, 4 order
        ddX = diff4(dX);
    if i==2

        % show detrend and filtered data
        figure(i-1);
        plot(time(1:nsamples),X(1:nsamples),'-','Linewidth',1);
        ylim([-0.25, 0.25]);
        writematrix([time(1:nsamples) X(1:nsamples) zeros(length(X),1)],[num2str(i-1),'.txt']);
        %phase space
        figure(10 + i - 1);
        %ddX = integrate_trapz(X,0,0.056);
        plot3(X,dX,ddX,'-','Linewidth',1);
    else
 
        %phase space%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        figure(10 + i - 1);
        hold on
        %ddX = integrate_trapz(X,0,0.056);
        for j = 1:ArrLine(i-2)
            if mod(j,2)==0
               plot3(X(h(1,i-2)*(j-1):h(1,i-2)+h(1,i-2)*(j-1)),dX(h(1,i-2)*(j-1):h(1,i-2)+h(1,i-2)*(j-1)),ddX(h(1,i-2)*(j-1):h(1,i-2)+h(1,i-2)*(j-1)),'-','Color','k','Linewidth',1); % black - off
            else
               plot3(X(1+h(1,i-2)*(j-1):h(1,i-2)+h(1,i-2)*(j-1)),dX(1+h(1,i-2)*(j-1):h(1,i-2)+h(1,i-2)*(j-1)),ddX(1+h(1,i-2)*(j-1):h(1,i-2)+h(1,i-2)*(j-1)),'-','Color','r','Linewidth',1); % red - on
                
            end
        end       
        xlabel('X')
        ylabel('dX')
        zlabel('ddX')
        view(3)
        hold off
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % show detrend and filtered data
        figure(i-1);
        hold on
        for j = 1:ArrLine(i-2)
            if mod(j,2)==0
                plot(time(h(1,i-2)*(j-1):h(1,i-2)+h(1,i-2)*(j-1)),X(h(1,i-2)*(j-1):h(1,i-2)+h(1,i-2)*(j-1)),'-','Color','k','Linewidth',1); % black - off
                xl = xline(Period_time*j*(i-2)+time(1));
                xl.LabelHorizontalAlignment = 'left';
                numb_state_0 = length(time(h(1,i-2)*(j-1):h(1,i-2)+h(1,i-2)*(j-1)));
                writematrix([time(h(1,i-2)*(j-1):h(1,i-2)+h(1,i-2)*(j-1)) X(h(1,i-2)*(j-1):h(1,i-2)+h(1,i-2)*(j-1)) zeros(numb_state_0,1)],[num2str(i-1),'.txt'],'WriteMode', 'append');
            else
                plot(time(1+h(1,i-2)*(j-1):h(1,i-2)+h(1,i-2)*(j-1)),X(1+h(1,i-2)*(j-1):h(1,i-2)+h(1,i-2)*(j-1)),'-','Color','r','Linewidth',1); % red - on
                xl = xline(Period_time*j*(i-2)+time(1),'r','On');
                xl.LabelHorizontalAlignment = 'left';
                numb_state_1 = length(time(1+h(1,i-2)*(j-1):h(1,i-2)+h(1,i-2)*(j-1)));
                writematrix([time(1+h(1,i-2)*(j-1):h(1,i-2)+h(1,i-2)*(j-1)) X(1+h(1,i-2)*(j-1):h(1,i-2)+h(1,i-2)*(j-1)) ones(numb_state_1,1)],[num2str(i-1),'.txt'],'WriteMode', 'append');
            end
        end               
        legend(['Cell'  num2str(i-1)]);
    end

    
end
