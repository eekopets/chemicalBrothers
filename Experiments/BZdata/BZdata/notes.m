close all
t = linspace(0,4*pi);
x = cos(t); 
y = -sin(t);
figure(1)
subplot(2,1,1);
plot (t,x)
title('x =cost'), ylabel('x');
subplot(2,1,2);
plot(t,y);
title('-y =-sin');
xlabel('t'), ylabel('y');
figure(2)
plot(x,y);
axis equal;
xlabel('x'), ylabel('y');
1/