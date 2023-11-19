%% �Ŵ��㷨 %%
function [Best_score,Best_pos,curve]=GA(pop,Max_iter,lb,ub,dim,fobj,var)
%% ������ʼ��
popsize=pop;              % ��Ⱥ��ģ
lenchrom=dim;             % �����ִ�����
pc=0.6;                   % �������
pm=0.05;                  % �������
if(max(size(ub)) == 1)
   ub = ub.*ones(dim,1);
   lb = lb.*ones(dim,1);  
end
maxgen=Max_iter;   % ��������  
% ��Ⱥ
bound=[lb,ub];     % ������Χ
%% ������ʼ���Ӻ��ٶ�
for i=1:popsize
    % �������һ����Ⱥ
    GApop(i,:)=Code(lenchrom,bound);       % �����������
    % ������Ӧ��
    [fitness(i)]=fobj(GApop(i,:),var);     % Ⱦɫ�����Ӧ��
end
curve(1)=min(fitness);
% Ѱ����õ�Ⱦɫ��
[bestfitness bestindex]=min(fitness);
zbest=GApop(bestindex,:);   % ȫ������
gbest=GApop;                % ��������
fitnessgbest=fitness;       % ����������Ӧ��ֵ
fitnesszbest=bestfitness;   % ȫ��������Ӧ��ֵ
%% ����Ѱ��
for i=1:maxgen
        %��Ⱥ���� GAѡ�����
        GApop=Select2(GApop,fitness,popsize);
        % ������� GA
        GApop=Cross(pc,lenchrom,GApop,popsize,bound);
        % ������� GA����
        GApop=Mutation(pm,lenchrom,GApop,popsize,[i maxgen],bound);
        pop=GApop;      
      for j=1:popsize
        % ��Ӧ��ֵ
        [fitness(j)]=fobj(pop(j,:),var);
        % �������Ÿ���
        if fitness(j) < fitnessgbest(j)
            gbest(j,:) = pop(j,:);
            fitnessgbest(j) = fitness(j);
        end    
        % Ⱥ�����Ÿ���
        if fitness(j) < fitnesszbest
            zbest = pop(j,:);
            fitnesszbest = fitness(j);
        end   
      end
    curve(i+1)=fitnesszbest;     
end
Best_score = fitnesszbest;
Best_pos = zbest;
end
%% ѡ����
function ret=Select2(individuals,fitness,sizepop)
fitness= 1./(fitness);
sumfitness=sum(fitness);
sumf=fitness./sumfitness;
index=[];
for i=1:sizepop   % ���̶�
    pick=rand;
    while pick==0
        pick=rand;
    end
    for j=1:sizepop
        pick=pick-sumf(j);
        if pick<0
            index=[index j];
            break;  % Ѱ����������䣬�˴�ת����ѡ����Ⱦɫ��i��ע�⣺��תsizepop�����̵Ĺ����У��п��ܻ��ظ�ѡ��ĳЩȾɫ��
        end
    end
end
individualsTemp=individuals(index,:);
fitnessTemp=fitness(index);
if(size(individualsTemp,1) == 0)
    ret=individuals;
else
    ret=individualsTemp;
end
end
%% ���溯��
function ret=Mutation(pmutation,lenchrom,chrom,sizepop,pop,bound)
for i=1:sizepop  
    % ���ѡ��һ��Ⱦɫ����б���
    pick=rand;
    while pick==0
        pick=rand;
    end
    index=ceil(pick*sizepop);
    % ������ʾ�������ѭ���Ƿ���б���
    pick=rand;
    if pick>pmutation
        continue;
    end
    flag=0;
    while flag==0
        % ����λ��
        pick=rand;
        while pick==0
            pick=rand;
        end
        pos=ceil(pick*sum(lenchrom));  % ���ѡ����Ⱦɫ������λ�ã���ѡ���˵�pos���������б���
        if pos<=0 
            pos = 1;
        end
        if pos>size(bound,1)
            pos = size(bound,1);
        end
        v=chrom(i,pos);
        v1=v-bound(pos,1);
        v2=bound(pos,2)-v;
        pick=rand; % ����
        if pick>0.5
            delta=v2*(1-pick^((1-pop(1)/pop(2))^2));
            chrom(i,pos)=v+delta;
        else
            delta=v1*(1-pick^((1-pop(1)/pop(2))^2));
            chrom(i,pos)=v-delta;
        end
        flag=test(lenchrom,bound,chrom(i,:));     % ����Ⱦɫ��Ŀ�����
    end
end
ret=chrom;
end
%% ���캯��
function ret=Cross(pcross,lenchrom,chrom,sizepop,bound)
for i=1:sizepop 
    % ���ѡ������Ⱦɫ����н���
    pick=rand(1,2);
    while prod(pick)==0
        pick=rand(1,2);
    end
    index=ceil(pick.*sizepop);
    % ������ʾ����Ƿ���н���
    pick=rand;
    while pick==0
        pick=rand;
    end
    if pick>pcross
        continue;
    end
    flag=0;
    while flag==0
        % ���ѡ�񽻲�λ��
        pick=rand;
        while pick==0
            pick=rand;
        end
        pos=ceil(pick.*sum(lenchrom)); % ���ѡ����н����λ��
        pick=rand; % ����
        v1=chrom(index(1),pos);
        v2=chrom(index(2),pos);
        chrom(index(1),pos)=pick*v2+(1-pick)*v1;
        chrom(index(2),pos)=pick*v1+(1-pick)*v2;
        flag1=test(lenchrom,bound,chrom(index(1),:));  % ����Ⱦɫ��1�Ŀ�����
        flag2=test(lenchrom,bound,chrom(index(2),:));  % ����Ⱦɫ��2�Ŀ�����
        if   flag1*flag2==0
            flag=0;
        else flag=1;
        end    % �������Ⱦɫ�岻�Ƕ����У������½���
    end
end
ret=chrom;
end
%% �ж��Ƿ��ڷ�Χ��
function flag=test(lenchrom,bound,code)
flag=1;
[n,m]=size(code);
for i=1:n
    if code(i)<bound(i,1) || code(i)>bound(i,2)
        flag=0;
    end
end
end
%% ���뺯��
function ret=Code(lenchrom,bound)
flag=0;
while flag==0
    pick=rand(1,lenchrom);
    ret=bound(:,1)'+(bound(:,2)-bound(:,1))'.*pick; % ���Բ�ֵ
    flag=test(lenchrom,bound,ret);             % ����Ⱦɫ��Ŀ�����
end
end