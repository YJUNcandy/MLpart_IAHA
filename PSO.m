%% ����Ⱥ�Ż��㷨 %%
function [gBestScore,gBest,cg_curve]=PSO(N,Max_iteration,lb,ub,dim,fobj,var)
% �㷨Ѱ�Ų�������
    Vmax=2;     % ����ٶ�
    noP=N;      % ��Ⱥ
    wMax=0.9;   % ���Ȩֵ
    wMin=0.6;   % ��СȨֵ
    c1=2;       % ѧϰ����1
    c2=2;       % ѧϰ����2
% ��Ⱥ��ʼ��
    ub = ub.*ones(1,dim);       % �Ͻ�
    lb = lb.*ones(1,dim);       % �½�
    iter=Max_iteration;         % ��������
    pBestScore=zeros(noP,1);    % ��������Ŀ��ֵ
    pBest=zeros(noP,dim);       % �������Ž�
    gBest=zeros(1,dim);         % ȫ�����Ž�
    cg_curve=zeros(1,iter+1);   % ÿһ������ֵ
    vel=zeros(N,dim);           % ��ʼ�ٶ�
    pos=zeros(N,dim);           % ��ʼλ�ã���ʼ�⣩
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
	gBestScore = inf; % ȫ������ֵ    
% ����Ѱ��    
    for l=1:iter 
        for i=1:size(pos,1)  
            % ж�ز��Ա߽紦��
            Flag4ub=pos(i,:)>ub;
            Flag4lb=pos(i,:)<lb;
            pos(i,:)=(pos(i,:).*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;
            % ����ÿ�����ӵ�Ŀ�꺯��
            fitness=fobj(pos(i,:),var);
            % ���¸������Ž�
            if(pBestScore(i)>fitness)
                pBestScore(i)=fitness;
                pBest(i,:)=pos(i,:);
            end
            % ����ȫ�����Ž�
            if(gBestScore>fitness)
                gBestScore=fitness;
                gBest=pos(i,:);
            end
        end
        % Ȩֵ����
        w=wMax-l*((wMax-wMin)/iter);
        % �ٶȸ��º�λ�ø���
        for i=1:size(pos,1)
            for j=1:size(pos,2)      
                % �ٶȸ���
                vel(i,j)=w*vel(i,j)+c1*rand()*(pBest(i,j)-pos(i,j))+c2*rand()*(gBest(j)-pos(i,j));
                % �ٶȱ߽紦��
                if(vel(i,j)>Vmax)
                    vel(i,j)=Vmax;
                end
                if(vel(i,j)<-Vmax)
                    vel(i,j)=-Vmax;
                end  
                % λ�ø���
                pos(i,j)=pos(i,j)+vel(i,j);
            end
        end
        cg_curve(l+1)=gBestScore;
    end
end