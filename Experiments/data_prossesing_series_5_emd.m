close all
fileID = '06_06_60sec.TXT';
%data processing for 5-th series

nsamples = 5e4; %first n samples to process
%%%  Read DATA  %%%%%%
T = readtable(fileID);
Data = table2array(T);
time = Data(:,1);
hT = diff(time); %time steps
%%%%%%%%% SETTINGS %%%%%%%%%%%

Period_time = 60000;
period = 4;
ArrLine = fix(time(nsamples)/(Period_time*period));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%IIR filter coefficients
g = 0.000000379696120;
b = g*[1.000000000000000 7.999999999999996 27.999999999999968 55.999999999999936 69.999999999999943 56.000000000000000 27.999999999999982 8.000000000000000 1.000000000000001];
a = [1.000000000000000 -6.211691381483218 17.042970307597223 -26.950123172796534 26.842856973570790 -17.233085015277751 6.960202463578208 -1.616142442388830 0.165109469406813];

i = 6; % 5-th series

Xd = detrend(Data(1:nsamples,i),2);
X = filter(b,a,Xd);
%X = Xd;
t = time(1:nsamples);

figure(1);
plot(t,X);
imf = emd(X); 
hold on

imfns = [2 3 4 5 6]; %numbers of intrinsic modes
thr =   0.05;

for i = 2
    f1 = imf(:,i);
    %apply nonlinear damping
    f1 = f1.*erf(abs(f1)/thr);
    imf(:,i) = f1;
end

figure(1);
f = sum(imf(:,imfns),2);
plot(t,f);

X = f;

% show vertical lines for on/off states
ylim([-0.25, 0.25]);
for j = 1:ArrLine
    if mod(j,2)==0
        xl = xline(Period_time*j*period);
        xl.LabelHorizontalAlignment = 'left';
    else
        xl = xline(Period_time*j*period,'r','On');
        xl.LabelHorizontalAlignment = 'left';

    end
end

X = filter(b,a,X);

dX = diff4(X); %derivative, 4 order
ddX = diff4ord2(X); % 2 derivative, 4 order
d3X = diff4ord3(X); % 3 derivative, 4 order
d4X = diff4ord3(dX); % 4 derivative, 4 order
d5X = diff4ord3(ddX); % 5 derivative, 4 order

IX = integrate_trapz(X,0,time); IX = IX';
imfI = emd(IX);
IX = detrend(IX,2);
IX = imfI(:,2);
figure(10); hold on
plot3(X,dX,IX);
xlabel('x');
ylabel('y');
zlabel('Ix');


%return;

% 
% d4X = IX;
% d5X = X;

%ddX = integrate_trapz(dX,0,h(i));

%set period time stamps
ks = 1;
TH = Period_time*period;
tsw = time(1) + TH;
for k = 2:nsamples
    if time(k - 1) <= tsw && time(k) >= tsw
        ks = [ks, k];
        tsw = tsw + TH;
    end
end

id0 = 1;

%state variables for on state
yon = [];
won = [];
ton = [];

for j = 1:length(ks)-1
    ids = ks(j):ks(j+1);
    if mod(j,2)==0
        col = 'k';
    else
        col = 'r';
        %yon = [yon; X(ids), dX(ids), ddX(ids), d3X(ids), d4X(ids)];
        %won = [won; dX(ids), ddX(ids), d3X(ids), d4X(ids), d5X(ids)];
%         yon = [yon; X(ids), dX(ids), ddX(ids), d3X(ids)];
%         won = [won; dX(ids), ddX(ids), d3X(ids), d4X(ids)];
       yon = [yon; IX(ids), X(ids), dX(ids), ddX(ids)];
       won = [won; X(ids), dX(ids), ddX(ids), d3X(ids)];
        ton = [ton; time(ids)];
    end

    figure(15);
    hold on
    plot3(X(ids),dX(ids),IX(ids),'-','Color',col,'Linewidth',1); % red - on, black - off
    xlabel('X')
    ylabel('dX')
    zlabel('IX')
    view(3)

    figure(5);
    hold on
    plot(time(ids),X(ids),'-','Color',col,'Linewidth',1);
end

%plot embedded dimensions
% tao = 20;
% figure(100);
% plot3(X(1:end - 2*tao),X(tao:end - tao - 1),X(2*tao + 1:end));
% 
% %fnn Algorithm
% rtol = 1e-0;
% abstol = 1e-1;
% mmax = 10;
% knn_deneme(X(1:5000),tao,mmax,rtol,abstol);

%return;

dim = 4;
%get uniformly distributed points from the simulated attractor

rng(8);

N = 300; %data points
M = dim; %dim
[Ns, ~] = size(yon);
W = zeros(N,M);
Y = zeros(N,M);
T = zeros(N,1);

for i = 1:N %take random points from attractor
    id = ceil(rand*Ns);  %number of data point
    W(i,:) = won(id,:); %X
    Y(i,:) = yon(id,:); %Y
    T(i) = ton(id); %time
end

W = won;
Y = yon;
T = ton;

%visualize

for i = 1:4
    figure(10 + i);
    plot3(Y(:,i),Y(:,1),W(:,4),'.');
    xlabel('x_2');
    ylabel('x_3');
    zlabel(['dx_',num2str(i)]);
end

return; 

%plot sample points
figure(5);
scatter(T,Y(:,1),23,'MarkerEdgeColor','g','MarkerFaceColor','y','LineWidth',1.5);

figure(15);
scatter3(Y(:,1),Y(:,2),Y(:,3),23,'MarkerEdgeColor','g','MarkerFaceColor','y','LineWidth',1.5);

%reconstruct order ideal

eps = 1e-6;

sigma = deglexord(4,dim);
[~, O] = ApproxBM(Y, eps, sigma) %use approximate Buchberger-Moller algorithm

%Use LSM for fitting the equations with the proper coefficients
eta = 1e-9;
H = cell(1,dim);
T = cell(1,dim);

warning off
%reconstruct each equation
for i = 1:dim
    V = W(:,i);
    [hi,tau] = delMinorTerms(Y,V,O,eta); %get equation and basis
    V0 = EvalPoly(hi,Y,tau); 
    norm(V - V0) %check if norm is appropriate
    
    H{1,i} = hi;
    T{1,i} = tau;
end

%display equations
prettyABM(H,T)

h = mean(hT);
Tmax = 2e5;

warning on
%simulate results
[t,y] = ode45(@(t,x)oderecon(H,T,t,x),[time(1):h:Tmax],yon(1,:)); %solve ODE
figure(2);
plot3(y(:,1),y(:,2),y(:,3),'.-');
figure(1);
plot(t,y(:,1),'.-');


