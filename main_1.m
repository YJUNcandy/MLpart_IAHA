%% 实验一：六种算法的收敛曲线对比 %%
clear;clc;close all
addpath(genpath(pwd))
Function_name = 'F0'; 
fobj= Fit(Function_name);
lb=0;
m = 10; % 服务器数量
n = 100;% 任务数量
% 卸载参数初始化
var.flag=0;
[new_var,var] = init(m,n,var);
% 算法参数设置
Max_iter = 500;       % 最大迭代次数
Alg_num = 6;          % 算法数量
Repeat_Num = 50;      % 程序重复执行次数，结果取平均值
Pop_num = 100;        % 种群数量
Alg_Index = 1;        % 算法的索引号
name_all=strings(1,Alg_num); % 算法的名称记录
% 程序重复执行参数设置
Repeat_Curve = zeros(Alg_num,Max_iter+1);      % 每重复一次时，累加适应度值变化收敛曲线
Repeat_BestY = zeros(Alg_num,Repeat_Num);      % 每重复一次时，统计最优适应度值
%% 算法执行
for o=1:Repeat_Num  % 重复执行Repeat_Num次
    for j=1:Alg_num % 六种算法依次执行
        [BestF,BestX,Curve,Time,name]=Alg_Choose(j,Pop_num,Max_iter,lb,fobj,new_var);
        Repeat_Curve(j,:)=Repeat_Curve(j,:)+Curve;% 累加适应度变化曲线
        Repeat_BestY(j,o) = BestF;% 统计最优适应度值
        name_all(j) = replace(name_all(j),name_all(j),name);
        BestX = round(BestX);
    end
end
for i=1:6
    res(i,1) = min(Repeat_BestY(i,:));% 最小适应度值 
    res(i,2) = sum(Repeat_BestY(i,:))/Repeat_Num;% 平均适应度值
    res(i,3) = std(Repeat_BestY(i,:),1);% 标准差
end
%% 实验结果
res % 打印实验结果数据(表2)
% 绘制收敛曲线图
figure;
mark = ['h' '>' '<' 'v' 'o' 's'];
for N=1:Alg_num
    plot(0:Max_iter,Repeat_Curve(N,:)./Repeat_Num,'LineWidth',2,'Marker',mark(N),'color','k','MarkerSize',4,'MarkerIndices',1:(Max_iter/10):Max_iter)
    hold on
end
xlabel('迭代次数');
ylabel('平均系统成本(含惩罚项)');
grid on
box on
legend(name_all)