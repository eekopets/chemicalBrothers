% x =[0 120 160 266 249 305 354 507];
% x1 =[0 116 156 234 256 309 365 518];
% x2 = [0 115 157 230 262 315 364 539];
% x3 = [0 117 157 212 261 315 375 545];
% x4 = [0 124 165 227 254 313 369 533];
% x5 = [0 116 164 227 254 303 368 525];
% x6 = [0 116 155 299 246 298 356 519];

x =[0 107 158 222 256 301 356 501 ];
x1 =[0 108 160 210 263 317 372 528];
x2 = [0	114	154	211	257	310	363	549];
x3 = [0	116	156	214	269	307	368	546];
x4 = [0	115	154	217	266	309	382	556];
x5 = [0	110	157	216	269	307	378	548];
x6 = [0	112	155	220	265	314	375	546];
x7 = [0	113	159	222	265	308	374	543];
y = [0 18 36 54 72 90 108 126];
figure(1);
hold on
plot(y,x,'.-');
plot(y,x1,'.-');
plot(y,x2,'.-');
plot(y,x3,'.-');
plot(y,x4,'.-');
plot(y,x5,'.-');
plot(y,x6,'.-');
plot(y,x7,'.-');
hold off

z =[0 118 151 201 244 298 358 509 ];
z1 =[0 116 158 191 257 300 364 549];
%z2 =[0 116 375 200 256 304 368 533];
figure(2); %% поменяли 3 и 4 местами
hold on
plot(y,z,'.-');
plot(y,z1,'.-');
%plot(y,z2,'.-');
hold off