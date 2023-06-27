baseLya= 27.5;% либо 25.9375 либо 27
countOctave = 15;
countnote = 12;
noteNatural = zeros(countOctave,countnote);
noteequal = zeros(countOctave,countnote);
basedo = zeros(countOctave,1);

%Генерация нот в равномерном соотношении
% Можно заранее высчитать соотношения, ведь они одинаковые
tone_up = 1.0594630943592953;
tone_down = 0.9438743126816934;
basedo(1,1) = baseLya*0.9438743126816934^9;

%Основной цикл
for i =1:countOctave
    for j=1:countnote
        if j == 10 
            noteNatural(i,j) = baseLya*2^(i-1);
        
        else
            noteNatural(i,j) = basedo(i,1)*tone_up^(j-1);

        end

    end
    basedo(i+1,1) = noteNatural(i,j)*tone_up;
    %noteNatural(i+1,10) = noteNatural(i,j);

end
for j=1:12
    plot(noteNatural(:,j))
    hold on
end
hold off
for m=1:15
    for k=1:countnote
        figure (2);

        Fs=80000;%частота дискретизации
        dt=1/Fs;
        t =0:dt:0.1;
        f=noteNatural(m,k);
        y=cos(2*pi*f*t);
        dy=diff(y);
        
        %plot(t,y);
        %axis equal;
        plot(y(2:length(y)),dy);
        hold on

    end   
end
legend('do','do#','re','re#','mi','fa','fa#','sol','sol#','la','la#','si')
% Генерация нот в натуральном соотношении, уже интереснее

% 
% для "октава" в количестве "колтчество_октав":


%     noteequal(1,1) = baseLya;
%     noteequal(1,2) =  noteequal(1,1)*(16/15);
%     noteequal(1,3) =  noteequal(1,2)*1.0546875;
%     noteequal(1,4) =  noteequal(1,1)*0.96;
%     noteequal(1,5) =  noteequal(1,4)*0.9375;
%     noteequal(1,6) =  noteequal(1,5)*0.9375;
%     noteequal(1,7) =  noteequal(1,6)*(128/135);
%     noteequal(1,8) =  noteequal(1,7)*0.9375;
%     noteequal(1,9) =  noteequal(1,8)*0.96;
%     noteequal(1,10) = noteequal(1,9)*0.9375;
%     noteequal(1,11) = noteequal(1,10)*(128/135);
%     noteequal(1,12) = noteequal(1,11)*0.9375;
% 
%     for j=1:12
%         plot(noteequal(1,:))
%         hold on
%     end
%     hold off
%     for m=1:1
%         for k=1:countnote
%             figure (2);
% 
%             Fs=80000;%частота дискретизации
%             dt=1/Fs;
%             t =0:dt:0.1;
%             f=noteequal(m,k);
%             y=cos(2*pi*f*t);
%             dy=diff(y);
% 
%             %plot(t,y);
%             %axis equal;
%             plot3(y(2:length(y)),dy,t(2:length(y)));
%             hold on
% 
%         end
%     end
%     legend('do','do#','re','re#','mi','fa','fa#','sol','sol#','la','la#','si')


