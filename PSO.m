%% 粒子群优化算法 %%
function [gBestScore,gBest,cg_curve]=PSO(N,Max_iteration,lb,ub,dim,fobj,var)
% 算法寻优参数设置
    Vmax=2;     % 最大速度
    noP=N;      % 种群
    wMax=0.9;   % 最大权值
    wMin=0.6;   % 最小权值
    c1=2;       % 学习因子1
    c2=2;       % 学习因子2
% 种群初始化
    ub = ub.*ones(1,dim);       % 上界
    lb = lb.*ones(1,dim);       % 下界
    iter=Max_iteration;         % 迭代次数
    pBestScore=zeros(noP,1);    % 个体最优目标值
    pBest=zeros(noP,dim);       % 个体最优解
    gBest=zeros(1,dim);         % 全局最优解
    cg_curve=zeros(1,iter+1);   % 每一代最优值
    vel=zeros(N,dim);           % 初始速度
    pos=zeros(N,dim);           % 初始位置（初始解）
    for i=1:size(pos,1) 
        for j=1:size(pos,2) 
            pos(i,j)=round((ub(j)-lb(j))*rand()+lb(j));
            vel(i,j)=0.3*rand();
        end
        fitness(i)=fobj(pos(i,:),var);
    end
    cg_curve(1) = min(fitness);
    for i=1:noP
        pBestScore(i)=inf; 
    end
	gBestScore = inf; % 全局最优值    
% 迭代寻优    
    for l=1:iter 
        for i=1:size(pos,1)  
            % 卸载策略边界处理
            Flag4ub=pos(i,:)>ub;
            Flag4lb=pos(i,:)<lb;
            pos(i,:)=(pos(i,:).*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;
            % 计算每个粒子的目标函数
            fitness=fobj(pos(i,:),var);
            % 更新个体最优解
            if(pBestScore(i)>fitness)
                pBestScore(i)=fitness;
                pBest(i,:)=pos(i,:);
            end
            % 更新全局最优解
            if(gBestScore>fitness)
                gBestScore=fitness;
                gBest=pos(i,:);
            end
        end
        % 权值更新
        w=wMax-l*((wMax-wMin)/iter);
        % 速度更新和位置更新
        for i=1:size(pos,1)
            for j=1:size(pos,2)      
                % 速度更新
                vel(i,j)=w*vel(i,j)+c1*rand()*(pBest(i,j)-pos(i,j))+c2*rand()*(gBest(j)-pos(i,j));
                % 速度边界处理
                if(vel(i,j)>Vmax)
                    vel(i,j)=Vmax;
                end
                if(vel(i,j)<-Vmax)
                    vel(i,j)=-Vmax;
                end  
                % 位置更新
                pos(i,j)=pos(i,j)+vel(i,j);
            end
        end
        cg_curve(l+1)=gBestScore;
    end
end