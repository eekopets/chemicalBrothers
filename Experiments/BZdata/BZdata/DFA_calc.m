function [windows, F_L_DFA, F_L_DFA_mod] = DFA_calc(order , q, config_num, data)

% DFA_calc processes all inputs and accordingly performs unmodified DFA and 
% r-DFA if required.
%
% Input arguments: order -> the maximum DFA order to be computed.
%                  config_num -> number of configurations of shuffled
%                  series to compute correction factor. If config_num > 1,
%                  then modified DFA will be performed.(refer to Jan W.
%                  Kantelhardt, Physics A 295 (2001) 441-454).
%                  data -> data column vector to be analysed
%                  dt -> time interval
% Output arguments: windows -> a cell-array of windows starting from a
%                   window size of order+2 to N/10 with each cell
%                   corresponding to a DFA order
%                   F2_L -> cell-array of variance estimate in each window.
%                   Each cell corresponds to a DFA order, rows are
%                   different windows for a given window size and columns
%                   are different window sizes.
%                   F_L_DFA -> cell-array of average variance. Each cell
%                   corresponds to results of a different DFA order.
%                   K_av ->modification factor.
%
%--------------------------------------------------------------------------


%----------------------------------------------------------------------O
% Initial Checks

if floor(order) ~= order | order < 1 | order > 6
    error('ERROR: The DFA order should be an integer between 1 and 6')
end

if floor(config_num) ~= config_num | config_num < 1
    error('ERROR: config_num should be and integer greater or equal to 1')
end

[row, col] = size(data);
if col ~= 1
    error('ERROR: Input data is not a column vector')
end

%----------------------------------------------------------------------O

% Preparing variables
N = length(data);
t = (1:N)';
avg_data = mean(data);
cum_data = cumsum(data - avg_data);

% Generate 'windows' cell-array
for ww = 1:order
    windows{ww,1}(1,:) = unique(round(logspace(log10(ww+2),log10(floor(N/10))...
        ,50)));
end

% Compute un-modified DFA
F_L_DFA = DFA_computation(windows, order, q, cum_data, N, t);

% Compute modified DFA (if required)
if config_num > 1
    for e = 1:config_num                    % Loop of shuffled time series
        d_shuf = data(randperm(N)); % randomly shuffled data to compute K_av
        cum_d_shuf = cumsum(d_shuf - avg_data);
        F_L_DFA_shuff_raw = DFA_computation(windows, order, q, cum_d_shuf, N, t);
        for b = 1:order
            F_L_DFA_shuff{b,1}(:,e) = F_L_DFA_shuff_raw{b,1};
        end
    end
    for i = 1:order
        s_dash = find(windows{i,:} > N/20); s_dash(2:end) = []; % index of where window ~ N/20
        K_av{i,:} = sqrt(mean(((F_L_DFA_shuff{i,1})').^2))*sqrt((windows{i,1}(s_dash))')./...
            (sqrt(mean((F_L_DFA_shuff{i,1}(s_dash,:)).^2))*sqrt(windows{i,1}));
        F_L_DFA_mod{i,:} = F_L_DFA{i,1}./K_av{i,:};
    end
else F_L_DFA_mod = [];
end
end

