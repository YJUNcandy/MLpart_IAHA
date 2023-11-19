%% 人工蜂鸟算法 %%
function [BestF,BestX,HisBestFit,VisitTable]=AHA(nPop,MaxIt,Low,Up,Dim,BenFunctions,var)
    % 种群初始化
    PopPos=zeros(nPop,Dim); 
    PopFit=zeros(1,nPop);   % 种群适应度值
    HisBestFit=zeros(1,MaxIt+1);  % 迭代中每一代的历史最佳适应度值
    for i=1:nPop
        PopPos(i,:)=rand(1,Dim).*(Up-Low)+Low;  % 随机初始化
        PopFit(i)=BenFunctions(PopPos(i,:),var);% 初始适应度值
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
    VisitTable(logical(eye(nPop)))=NaN;   % 对角线设置为NAN  
    for It=1:MaxIt
        DirectVector=zeros(nPop,Dim);% 方向矢量/矩阵
        for i=1:nPop
            r=rand;
            if r<1/3     % 对角线飞行
                RandDim=randperm(Dim);
                if Dim>=3
                    RandNum=ceil(rand*(Dim-2)+1);
                else
                    RandNum=ceil(rand*(Dim-1)+1);
                end
                DirectVector(i,RandDim(1:RandNum))=1;
            else
                if r>2/3  % 全向飞行
                    DirectVector(i,:)=1;
                else  % 轴向飞行
                    RandNum=ceil(rand*Dim);
                    DirectVector(i,RandNum)=1;
                end
            end
            if rand<0.5   % 引导觅食
                [MaxUnvisitedTime,TargetFoodIndex]=max(VisitTable(i,:));
                MUT_Index=find(VisitTable(i,:)==MaxUnvisitedTime);
                if length(MUT_Index)>1
                    [~,Ind]= min(PopFit(MUT_Index));
                    TargetFoodIndex=MUT_Index(Ind);
                end
                newPopPos=PopPos(TargetFoodIndex,:)+randn*DirectVector(i,:).*...
                    (PopPos(i,:)-PopPos(TargetFoodIndex,:));
                newPopPos=SpaceBound(newPopPos,Up,Low);
                newPopFit=BenFunctions(newPopPos,var);
                if newPopFit<PopFit(i)
                    PopFit(i)=newPopFit;
                    PopPos(i,:)=newPopPos;
                    VisitTable(i,:)=VisitTable(i,:)+1;
                    VisitTable(i,TargetFoodIndex)=0;
                    VisitTable(:,i)=max(VisitTable,[],2)+1;
                    VisitTable(i,i)=NaN;
                else
                    VisitTable(i,:)=VisitTable(i,:)+1;
                    VisitTable(i,TargetFoodIndex)=0;
                end
            else    % 领地觅食
                newPopPos= PopPos(i,:)+randn*DirectVector(i,:).*PopPos(i,:);
                newPopPos=SpaceBound(newPopPos,Up,Low);
                newPopFit=BenFunctions(newPopPos,var);
                if newPopFit<PopFit(i)
                    PopFit(i)=newPopFit;
                    PopPos(i,:)=newPopPos;
                    VisitTable(i,:)=VisitTable(i,:)+1;
                    VisitTable(:,i)=max(VisitTable,[],2)+1;
                    VisitTable(i,i)=NaN;
                else
                    VisitTable(i,:)=VisitTable(i,:)+1;
                end
            end
        end
        if mod(It,2*nPop)==0 % 迁徙觅食
            [~, MigrationIndex]=max(PopFit);
            PopPos(MigrationIndex,:) =rand(1,Dim).*(Up-Low)+Low;
            PopFit(MigrationIndex)=BenFunctions(PopPos(MigrationIndex,:),var);
            VisitTable(MigrationIndex,:)=VisitTable(MigrationIndex,:)+1;
            VisitTable(:,MigrationIndex)=max(VisitTable,[],2)+1;
            VisitTable(MigrationIndex,MigrationIndex)=NaN;            
        end
        for i=1:nPop
            if PopFit(i)<BestF
                BestF=PopFit(i);
                BestX=PopPos(i,:);
            end
        end
        HisBestFit(It+1)=BestF;
    end
end
%% 边界处理
function  X=SpaceBound(X,Up,Low)
    Dim=length(X);
    S=(X>Up)+(X<Low);    
    X=(rand(1,Dim).*(Up-Low)+Low).*S+X.*(~S);
end