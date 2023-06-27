function F_L_DFA = DFA_computation(windows, order, q, cum_data, N, t)

% DFA_computation computes the average variance for DFA from 1 to 'order'
%
% Input arguments:  windows -> a cell array of scales at which DFA will be
%                   computed. Each cell contains the scales for one DFA 
%                   order.
%                   order -> the maximum DFA order to be computed. Possible 
%                   values are integers from 1 to 6.
%                   q -> order of fluctuation. Use q = 2 for regular DFA.
%                   cum_data -> the accumulation of the data column after 
%                   subtracting its mean values. This should contain data
%                   in a single column
%                   N -> Length of data
%                   t -> abcissa (if data is a time series then t is time)
%                   cum_data is for a time series, then t will contain the
%                   time values
% Output arguments: F_L_DFA -> cell-array of average variance. Each cell
%                   corresponds to results of a different DFA order.


%----------------------------------------------------------------------O
% Start DFA computation

F2_L = [];
for b = 1:order
    n=[];
    count1 = 1;
    for L = windows{b,1}
        a=floor(single(N/L)); %last part of data will be ignored to get whole windows
        E2=[];
        warning('off','all'); % to suppress warnings from polyfit
        for i=1:L-1:(a-1)*L
            cum_data_w=cum_data(i:i+L-1);
            t_w=t(i:i+L-1);
            p=polyfit(t_w,cum_data_w,b);
            y=cum_data_w - polyval(p,t_w);
            E2=[E2; sum((y).^2).*1/L];
        end
        warning('on','all');
        if L == b+2;
            F2_L{b,1}(:,count1) = E2; n = length(E2);
        else F2_L{b,1}(:,count1) = [E2; nan*ones(n-length(E2),1)];
        end
        tempF2 = F2_L{b,1}(~isnan(F2_L{b,1}(:,count1)),count1);
        F_L_DFA{b,1}(1,count1)=(1/a*sum(tempF2))^(1/q);
        count1 = count1+1;
    end
    
end
end
