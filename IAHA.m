%% 改进人工蜂鸟算法 %%
%% 采用混沌映射，通过增加初始种群多样性，提升全局搜索能力，避免陷入局部最优，有助于提升收敛速度
%% 在引导觅食中引入莱维飞行，增加目标位置与当前位置间的随机搜索能力，加入自适应权重函数，提高算法的收敛速度和精确度
%% 在领地觅食中加入引入莱维飞行，提升局部收敛速度，但在一定程度上有加大陷入局部最优的可能
%% 优化原算法结构，迁徙觅食触发方式
function [BestF,BestX,HisBestFit]=IAHA(nPop,MaxIt,Low,Up,Dim,BenFunctions,var)
    % 种群初始化
    PopFit=zeros(1,nPop);         % 种群适应度值
    m1 = zeros(1,nPop);
    m2 = zeros(1,nPop);
    M1 = zeros(1,nPop);
    M2 = zeros(1,nPop);
    HisBestFit=zeros(1,MaxIt+1);  % 迭代中每一代的历史最佳适应度值
    PopPos = repmat(Low,nPop,1)+chaos(2,nPop,var).* repmat((Up-Low),nPop,1); % 混沌映射
    PopPos=round(PopPos);
    for i=1:nPop
        [PopFit(i),m1(i),m2(i)]=BenFunctions(PopPos(i,:),var);    % 初始适应度值
        M1(i)=m1(i);% 环境信号
        M2(i)=m2(i);% 环境信号
    end
    HisBestFit(1) = min(PopFit);
    BestF=inf;  % 最优值
    BestX=[];   % 最优解
    for i=1:nPop
        if PopFit(i)<=BestF
            BestF=PopFit(i);
            BestX=PopPos(i,:);
        end
    end
% 初始化访问表
    VisitTable=zeros(nPop) ;    % 访问表
    VisitTable(logical(eye(nPop)))=NaN;     % 对角线设置为NAN 
% 迭代寻优    
    r = rand;
    for It=1:MaxIt        
        lambda = 0.15*exp(-(3.5*It/MaxIt)^2);            
        DirectVector=zeros(nPop,Dim);       % 方向向量矩阵        
        for i=1:nPop
            % 方向向量更新
            if M1(i)<40 || (M1(i)>=40 && r>0.2)
                r=rand;
                if r<=1/3                   % 对角线飞行=dim-1次不同方向的轴向飞行
                    RandDim=randperm(Dim);  % 打乱维度序列
                    if Dim>=3
                        RandNum=ceil(rand*(Dim-2)+1);% 三维及以上时，对角线飞行需要确保方向向量至少有一个维度为0，索引号取值[2,30]，
                    else
                        RandNum=ceil(rand*(Dim-1)+1);% 一维和二维时，对角线飞行和全向飞行一样，索引号全取，既取1或2
                    end
                    DirectVector(i,RandDim(1:RandNum))=1;
                else
                    if r<=2/3  % 全向飞行=dim次不同方向的轴向飞行
                        DirectVector(i,:)=1; % 所有向量维度全取1
                    else  % 轴向飞行
                        RandNum=ceil(rand*Dim);
                        DirectVector(i,RandNum)=1;% 只有代表一个方向的轴向量所在维度取1                 
                    end
                end
            else
                T=(round(PopPos(i,:))==M2(i));
                DirectVector(i,:)=T+round(rand(1,Dim)).*~T;                
            end
                beta=1.5;    % 通常取值为1.5
                sigma_u=(gamma(1+beta)*sin(pi*beta/2)/(beta*gamma((1+beta)/2)*2^((beta-1)/2)))^(1/beta);
                u = normrnd(0, sigma_u);
                v = normrnd(0, 1);
                levi= u/abs(v)^(1/beta);   
                r=rand;          
                % 引导觅食
                if r<0.45
                    [MaxUnvisitedTime,TargetFoodIndex]=max(VisitTable(i,:));% 最大未访问时间
                    MUT_Index=find(VisitTable(i,:)==MaxUnvisitedTime);% 最大未访问时间对应的个体位置索引
                    if length(MUT_Index)>1                            % 不止一个时，找到最优适应度个体索引作为目标位置
                        [~,Ind]= min(PopFit(MUT_Index));              
                        TargetFoodIndex=MUT_Index(Ind);
                    end
                    newPopPos=(PopPos(TargetFoodIndex,:)+lambda*levi*DirectVector(i,:).*(PopPos(i,:)-PopPos(TargetFoodIndex,:)));% 更新当前位置到目标位置引导方向上的新位置
                    newPopPos=SpaceBound(newPopPos,Up,Low);           % 边界处理
                    [newPopFit,m1(i),m2(i)]=BenFunctions(newPopPos,var);% 新位置的食物补充率(适应度值)
                    % 新位置更优
                    if newPopFit<PopFit(i)
                        PopFit(i)=newPopFit;                    % 更新适应度
                        PopPos(i,:)=newPopPos;                  % 更新位置(解)
                        VisitTable(i,:)=VisitTable(i,:)+1;      % 新位置下附近的未访问时间加一
                        VisitTable(i,TargetFoodIndex)=0;        % 旧位置附近的未访问时间置0，表示刚刚访问过
                        VisitTable(:,i)=max(VisitTable,[],2)+1; % 其它鸟的最优位置到该新位置的未访问时间加一(max函数表示每行最大值组成列)
                        VisitTable(i,i)=NaN;
                        % 更新环境信号
                        M1(i)=m1(i);
                        M2(i)=m2(i);
                    % 原位置更优
                    else
                        VisitTable(i,:)=VisitTable(i,:)+1;      % 原位置下附近的未访问时间加一 (目标位置除外)
                        VisitTable(i,TargetFoodIndex)=0;        % 目标位置刚刚访问，时间置0
                    end
                % 领地觅食    
                else
                    if r>0.55
                        newPopPos= PopPos(i,:)+4*levi*DirectVector(i,:).*PopPos(i,:);% 更新当前位置附近的新位置
                        newPopPos=SpaceBound(newPopPos,Up,Low);% 边界处理，边界外的随机处理到边界内
                        [newPopFit,m1(i),m2(i)]=BenFunctions(newPopPos,var); % 新位置的食物补充率(适应度值)
                        % 找到更好的领地
                        if newPopFit<PopFit(i)% 如果适应度更优（这里表现为食物补充率更低）
                            PopFit(i)=newPopFit;% 更新食物补充率
                            PopPos(i,:)=newPopPos;% 更新位置
                            VisitTable(i,:)=VisitTable(i,:)+1;% 新位置下附近的未访问时间加一
                            VisitTable(:,i)=max(VisitTable,[],2)+1;% 其它鸟的最优位置到该新位置的未访问时间加一
                            VisitTable(i,i)=NaN;

                             M1(i)=m1(i);
                             M2(i)=m2(i);
                        % 没有找到更好的领地
                        else
                            VisitTable(i,:)=VisitTable(i,:)+1;% 原位置附近的未访问时间加一
                        end
                    else
                        % 迁徙觅食
                        newPopPos=rand(1,Dim).*(Up-Low)+Low;
                        [newPopFit,m1(i),m2(i)]=BenFunctions(newPopPos,var); % 新位置的食物补充率(适应度值)                   
                        df=newPopFit-PopFit(i);
                        % 如果df<0则接受该解，如果大于0 则利用Metropolis准则进行判断是否接受       
                        if (df<0||rand < exp(-(It/MaxIt)*df/(abs(PopFit(i))+eps)/(3E-4)))==1
                            PopPos(i,:)=newPopPos;
                            PopFit(i)=newPopFit;
                            VisitTable(i,:)=VisitTable(i,:)+1;% 新位置下附近的未访问时间加一
                            VisitTable(:,i)=max(VisitTable,[],2)+1;% 其它鸟的最优位置到该新位置的未访问时间加一
                            VisitTable(i,i)=NaN; 

                            M1(i)=m1(i);
                            M2(i)=m2(i);
                        end   
                    end
                end
            if PopFit(i)<BestF
                BestF=PopFit(i);
                BestX=PopPos(i,:);
            end 
        end
        HisBestFit(It+1)=BestF;
    end
end
%% 边界处理函数
function  X=SpaceBound(X,Up,Low)
    Dim=size(X,2);
    S=(X>Up)+(X<Low);    
    X=(rand(1,Dim).*(Up-Low)+Low).*S+X.*(~S);
end