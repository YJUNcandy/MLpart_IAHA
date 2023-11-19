%% 适应度值计算函数 %%
function y = Fit(F)
    switch F
        case 'F0'   
            y = @F0;
    end
end
function [o,m1,m2 ]= F0(x,var)
% 参数设置
wn0 = 1*10^-9;                 % w*n0,单位:W
W = 40;                        % 系统总带宽，单位:MHz
wt = 0.5;                      % 时延权重
at = 2;                        % 时延成本调节因子
ae = 1.45;                     % 能耗成本因子
gt = 4;                        % 超时延惩罚系数2~8
ge = 24;                       % 超能耗惩罚系数12~36
E_Max = 25;                    % 最大卸载能耗10~25J
T_Max = 14;                    % 最大卸载时延5~14s
% 参数获取
f_x = round(x);                % 卸载策略
f_K = size(x,2);               % 任务数量
f_M = var.M;                   % 服务器数量
f_d = var.d;                   % 任务总计算量,单位:kb ,1kb==2^13bit
f_c = var.c;                   % 每b数据量的计算资源需求量,单位:cycle/bit
f_fs = var.fs;                 % 服务器CPU计算频率,单位:GHZ ,1GHz=10^9Hz
f_pi = var.pi;                 % 设备发射功率,单位: mW ,1mW=10^-3W
f_Hij = var.Hij;               % 信道增益矩阵
T_local = var.T_local;
E_local = var.E_local;
X_channel = var.channel;
nm = zeros(1,f_M);             % 卸载到服务器的数量
f_r = zeros(f_K,1);            % 任务上传速率
T_server_transfer = zeros(f_K,1); % 传输时延
T_server_calculate = zeros(f_K,1);% 计算时延
E_server_transfer = zeros(f_K,1); % 传输能耗
cost = zeros(f_K,1);           % 任务成本
P_T = 0;                       % 超时延惩罚
P_E = 0;                       % 超能耗惩罚

% 统计卸载到各服务器的任务数量
for i = 1:f_M
    nm(i)=sum(f_x==i);% nm(i)为卸载到服务器i的任务个数
end  
% 计算任务成本
for i=1:f_K         % 当前任务
    noise = 0;      % 噪声
    if f_x(i) > 0   % 任务卸载时才计算噪声、传输时延、服务器计算时延       
        for j=1:f_K % 其它任务
            if( (f_x(j)>0) && (f_x(j) ~= f_x(i)) && (X_channel(j)==X_channel(i)) )  % 与当前任务不一样、信道一样的卸载任务
             	noise = noise+f_pi(j)*f_Hij(j,f_x(j));
            end
        end
        if nm(f_x(i))>40 % 均分带宽
            tep = nm(f_x(i));
        else
            tep = 40;    % 固定带宽
        end
        f_r(i) = W*10^6/tep*log2(1+f_pi(i)*f_Hij(i,f_x(i))/(wn0+noise));        % 传输速率
        T_server_transfer(i) = f_d(i)*2^13./f_r(i);                             % 传输时延
        T_server_calculate(i) =f_d(i).*f_c(i).*2^13./( f_fs(f_x(i))./tep*10^9 );% 计算时延
        E_server_transfer(i) = f_pi(i).*T_server_transfer(i);                   % 传输能耗
        cost_t = T_server_transfer(i) + T_server_calculate(i);
        if cost_t > T_Max
            P_T = P_T+ (cost_t - T_Max)*gt*wt;
        end
        if E_server_transfer(i) > E_Max
            P_E = P_E+ (E_server_transfer(i) - E_Max)*ge*(1-wt);
        end        
        cost(i) = cost_t*wt*at + E_server_transfer(i)*(1-wt)*ae; % 卸载成本
    else
        if T_local(i) > T_Max
            P_T = P_T+ (T_local(i) - T_Max)*gt*wt;
        end
        if E_local(i) > E_Max
            P_E = P_E+ (E_local(i) - E_Max)*ge*(1-wt);
        end 
        cost(i) =(T_local(i)*wt*at + E_local(i)*ae*(1-wt));
    end
end
    P = P_T+P_E;
    cost = ((sum(cost)+P)/f_K);    % 平均系统成本
    o = cost;
    [m1,m2]= max(nm);
end
