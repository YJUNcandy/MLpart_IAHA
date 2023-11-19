%% 实验二：算法执行时间对比 %%
clear;clc;close all
addpath(genpath(pwd))
Function_name = 'F0'; 
fobj= Fit(Function_name);
lb=0;
m = 25;% 服务器数量
n = 50;% 任务数量
% 卸载参数初始化
var.flag=0;
[new_var,var] = init(m,n,var);
% 算法参数设置
Max_iter = 500;       % 最大迭代次数
Alg_num = 6;          % 算法数量6
Repeat_Num = 50;      % 程序重复执行次数，结果取平均值
Pop_num = 100;        % 种群数量
Alg_Index = 1;        % 算法的索引号
% 程序重复执行参数设置
Repeat_Time = zeros(Alg_num,5); % 记录每种算法重复执行时的总耗时(结果受电脑软硬件资源及仿真环境影响)
%% 算法执行
for o=1:Repeat_Num % 重复执行Repeat_Num次
    m=25;
    n=50;
    for i=1:5          % 5次改变
        if i>1
            [new_var,var] = init(m,i*50,var);% 每次增加50个任务
        else
            [new_var,var] = init(m,n,var);
        end
        for j=1:Alg_num    % 第j个算法
            [BestF,BestX,Curve,Time,name]=Alg_Choose(j,Pop_num,Max_iter,lb,fobj,new_var);
            Repeat_Time(j,i)=Repeat_Time(j,i)+Time;% 累计执行时间
        end
    end
end
Repeat_Time = Repeat_Time./Repeat_Num;% 取平均值
% 绘实验结果图
figure
name_all_A={'IAHA','AHA','SO','GWO','PSO','GA'};% 6种算法名
SH1=shadowHist(Repeat_Time','ShadowType',{'g','x','_','/','.','\'});
SH1=SH1.draw();
SH1=SH1.legend(name_all_A,'FontName','Arial','FontSize',8);
ax=gca;
set(gca,'XTick',1:5,'XTickLabel',{'50','100','150','200','250'},"FontSize",12,"LineWidth",2);
ax.FontName='Cambria';
ax.LineWidth=1.1;
ax.XColor=[1,1,1].*.3;
ax.YColor=[1,1,1].*.3;
ax.XMinorTick='on';
ax.YMinorTick='on';
ax.XGrid='on';
ax.YGrid='on';
ax.Box='on';
ax.GridLineStyle='-.';
ax.GridAlpha=.1;
xlabel("任务数量",'FontName','simsun');
ylabel("算法执行时间/s",'FontName','simsun');