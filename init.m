%% 卸载参数初始化函数 %%
function [new_var,original_var]=init(m,dim,var0)
M_Max=25;                      % 最大服务器数量
N_Max=250;                     % 最大任务数量
M=m;                           % 服务器个数
k=50;                          % 信道数量
N=dim;                         % 任务数量
Ku = 5*10^-28;                 % 芯片功耗系数
d_limit = [250,1800];          % 任务的数据量取值范围,单位:kb ,1kb=2^10b=2^13bit
c_limit = [400,1200];          % 任务的每bit数据量所需计算时钟资源取值范围,单位:cycle/bit
fl_limit = [1,3];              % 设备计算能力，单位:GHZ ,1GHz=10^9Hz
fs_limit = [30,50];            % 服务器计算能力，单位:GHZ
pi_limit = [0.1,0.5];          % 设备发送功率，单位: W 
Hij_limit = [1*10^-9,1*10^-6]; % 设备与服务器间的信道增益
if var0.flag==0
    % 信道分配
    channel = zeros(N_Max,1);
    for p=1:N_Max
        channel(p)=mod(p,k);
        if(channel(p)==0)
            channel(p)=k;
        end
    end
    c = c_limit(1) + (c_limit(2) - c_limit(1)).*rand(N_Max,1);              % 每bit数据量的计算资源需求量
    d = d_limit(1) + (d_limit(2) - d_limit(1)).*rand(N_Max,1);              % 任务总计算量
    fl = fl_limit(1) + (fl_limit(2) - fl_limit(1)).*rand(N_Max,1);          % 设备CPU计算频率 
    fs = fs_limit(1) + (fs_limit(2) - fs_limit(1)).*rand(M_Max,1);          % 服务器CPU计算频率
    pi = pi_limit(1) + (pi_limit(2) - pi_limit(1)).*rand(N_Max,1);          % 设备发射功率
    Hij = Hij_limit(1) + (Hij_limit(2) - Hij_limit(1)).*rand(N_Max,M_Max);  % 信道增益矩阵
    T_local_calculate = d.*c*2^13./(fl*10^9);                               % 本地计算时延    
    E_local_calculate = Ku*(fl*10^9).^2.*d.*c*2^13;                         % 本地计算能耗
%     cost_local= (T_local_calculate*wt*at + E_local_calculate*(1-wt)*ae);% 本地成本
    original_var.M = M_Max; 
    original_var.N = N_Max;
    original_var.c = c;
    original_var.d = d;
    original_var.fs = fs;
    original_var.pi = pi;
    original_var.fl = fl;
    original_var.Hij = Hij;
    original_var.channel = channel;
%     original_var.cost_local = cost_local;
    original_var.T_local = T_local_calculate;
    original_var.E_local = E_local_calculate;
    original_var.flag=1;
else
    original_var = var0;
end
    new_var.M = M;
    new_var.N = N;
    new_var.c = original_var.c(1:N);
    new_var.d= original_var.d(1:N);
    new_var.fs = original_var.fs(1:M);
    new_var.pi = original_var.pi(1:N);
    new_var.fl = original_var.fl(1:N);
    new_var.Hij = original_var.Hij(1:N,1:M);
    new_var.channel = original_var.channel(1:N);
%     new_var.cost_local = original_var.cost_local(1:N);
    new_var.T_local = original_var.T_local(1:N);
    new_var.E_local = original_var.E_local(1:N);
end