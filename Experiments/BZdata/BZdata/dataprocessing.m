close all
fileID = '5.txt';
%fileID = 'period50_1.TXT';
%fileID = 'period50_2.TXT';

nsamples = 50000; %first n samples to process 431 623 804
Data = readmatrix(fileID);
time = Data(1:nsamples,1);
signal = Data(1:nsamples,2);
state = Data(1:nsamples,3);
off = 0;
on = 0;
figure(1);
plot(time,signal);
for i =1:nsamples-1
    if state(i) == 1 && state(i+1)== 0
        
        off = off+1;
        sampleSwOff(off) = i; 
        
    elseif state(i) == 0 && state(i+1)== 1
        on = on+1;
        sampleSwOn(on) = i; 
    end
    
    
end

%reduce sample rate
sampleSwOff_new = fix(sampleSwOff/62);
sampleSwOn_new = fix(sampleSwOn/62);
S = downsample(signal, 62);
T = downsample(time, 62);
hold on
plot(T,S);

ID_mix = 1:sampleSwOff_new(1);
ID_idle = sampleSwOff_new(1)+1:sampleSwOn_new(1);
S1 = S(ID_mix); T1 = T(ID_mix);
S2 = S(ID_idle); T2 = T(ID_idle);
%apply NVG
[VG] = fast_NVG(S1,T1,'u',0);
% figure(2);
% spy(VG);
G = graph(VG,'upper');
%figure(3); plot(G,'Layout','force');
%figure(3); plot(G,'Layout','subspace');
figure(3);
plot(G,'Layout','subspace');
hold on
[VG2] = fast_NVG(S2,T2,'w',0);
G2 = graph(VG2,'upper');
plot(G2,'Layout','subspace');

figure(222);
plot(T1,S1);
hold on
plot(T2,S2);