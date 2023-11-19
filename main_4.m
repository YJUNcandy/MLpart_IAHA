%% 实验四：服务器数量的成本影响 %%
clear;clc;close all
addpath(genpath(pwd))
Function_name = 'F0'; 
fobj= Fit(Function_name);
lb=0;
m = 5;% 服务器数量
n = 250;% 任务数量
% 卸载参数初始化
var.flag=0;
[new_var,var] = init(m,n,var);
% 算法参数设置
Max_iter = 500;       % 最大迭代次数
Alg_num = 6;          % 算法数量6
numave = 0;           % 统计均值
Repeat_Num = 50;      % 程序重复执行次数，结果取平均值
Pop_num = 100;        % 种群数量
Alg_Index = 1;        % 算法的索引号
% 程序重复执行参数设置
Repeat_BestZ = zeros(Alg_num+2,5);           % 记录每种算法重复执行时的最优适应度
%% 算法执行
for o=1:Repeat_Num % 重复执行Repeat_Num次
    m=5;
    n=250;
    for i=1:5          % 5次改变
        if i>1
            [new_var,var] = init(5*i,n,var);% 每次增加5个服务器
        else
            [new_var,var] = init(m,n,var);
        end
        for j=1:Alg_num    % 第j个算法
            [BestF,BestX,Curve,Time,name]=Alg_Choose(j,Pop_num,Max_iter,lb,fobj,new_var);
            Repeat_BestZ(j,i)=Repeat_BestZ(j,i)+BestF;
        end
        numave = sum(Repeat_BestZ(1:6,i))/6/o;  % 六种算法均值
        x1 = zeros(1,new_var.N);                % 本地计算策略
        while 1
            x2 = round(rand(1,new_var.N)*(new_var.M)).*randi(0:1,[1,new_var.N]);  % 随机卸载策略
            if fobj(x2,new_var)>5*numave             % 排除随机策略中过于大的值
              continue;
            else
                break;
            end
        end
        Repeat_BestZ(7,i)=Repeat_BestZ(7,i)+fobj(x1,new_var);                 % 本地计算成本
        Repeat_BestZ(8,i)=Repeat_BestZ(8,i)+fobj(x2,new_var);                 % 随机卸载成本
    end
end
Repeat_BestZ = Repeat_BestZ./Repeat_Num;
% 实验结果绘图
figure
name_all_B={'IAHA','AHA','SO','GWO','PSO','GA','LC','RO'};% 6种算法+2种策略
SH3=shadowHist(Repeat_BestZ','ShadowType',{'g','x','_','/','.','\','+','|'});
SH3=SH3.draw();
SH3=SH3.legend(name_all_B,'FontName','Arial','FontSize',8);
ax=gca;
set(gca,'XTick',1:5,'XTickLabel',{'5','10','15','20','25'},"FontSize",12,"LineWidth",2);
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
xlabel("服务器数量",'FontName','simsun');
ylabel("平均系统成本(含惩罚项)",'FontName','simsun');