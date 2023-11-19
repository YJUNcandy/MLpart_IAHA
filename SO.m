%% 蛇优化算法 %%
function [fval,Xfood,gbest_t] = SO(N,T, lb,ub,dim,fobj,var)
% 初始化 
vec_flag=[1,-1];
Threshold=0.25;
Thresold2= 0.6;
C1=0.55;
C2=.05;
C3=2;
if length(lb)<2
    X=lb+rand(N,dim)*(ub-lb);
else 
    X=repmat(lb,N,1)+rand(N,dim).*repmat((ub-lb),N,1);
end
for i=1:N
	fitness(i)=fobj(X(i,:),var);   
end
[GYbest, gbest] = min(fitness);
gbest_t(1) = GYbest;
Xfood = X(gbest,:);
Nm=round(N/2);
Nf=N-Nm;
Xm=X(1:Nm,:);
Xf=X(Nm+1:N,:);
fitness_m=fitness(1:Nm);
fitness_f=fitness(Nm+1:N);
[fitnessBest_m, gbest1] = min(fitness_m);
Xbest_m = Xm(gbest1,:);
[fitnessBest_f, gbest2] = min(fitness_f);
Xbest_f = Xf(gbest2,:);
for t = 1:T
    Temp=exp(-((t)/T));
    Q=C1*exp(((t-T)/(T)));
    if Q>1
        Q=1;
    end
    % 全局搜索（无食物）
if Q<Threshold
    for i=1:Nm
        for j=1:1:dim
            rand_leader_index = floor(Nm*rand()+1);
            X_randm = Xm(rand_leader_index, :);
            flag_index = floor(2*rand()+1);
            Flag=vec_flag(flag_index);
            Am=exp(-fitness_m(rand_leader_index)/(fitness_m(i)+eps));
            Xnewm(i,j)=X_randm(j)+Flag*C2*Am*((ub(1)-lb(1))*rand+lb(1));
        end
    end
    for i=1:Nf
        for j=1:1:dim
            rand_leader_index = floor(Nf*rand()+1);
            X_randf = Xf(rand_leader_index, :);
            flag_index = floor(2*rand()+1);
            Flag=vec_flag(flag_index);
            Af=exp(-fitness_f(rand_leader_index)/(fitness_f(i)+eps));
            Xnewf(i,j)=X_randf(j)+Flag*C2*Af*((ub(1)-lb(1))*rand+lb(1));
        end
    end
else % 局部搜索（有食物）
    if Temp>Thresold2  % 温度高
        for i=1:Nm
            flag_index = floor(2*rand()+1);
            Flag=vec_flag(flag_index);
            for j=1:1:dim
                Xnewm(i,j)=Xfood(j)+C3*Flag*Temp*rand*(Xfood(j)-Xm(i,j));
            end
        end
        for i=1:Nf
            flag_index = floor(2*rand()+1);
            Flag=vec_flag(flag_index);
            for j=1:1:dim
                Xnewf(i,j)=Xfood(j)+Flag*C3*Temp*rand*(Xfood(j)-Xf(i,j));
            end
        end
    else % 寒冷
        if rand>0.6 % 战斗
            for i=1:Nm
                for j=1:1:dim
                    FM=exp(-(fitnessBest_f)/(fitness_m(i)+eps));
                    Xnewm(i,j)=Xm(i,j) +C3*FM*rand*(Q*Xbest_f(j)-Xm(i,j));
                    
                end
            end
            for i=1:Nf
                for j=1:1:dim
                    FF=exp(-(fitnessBest_m)/(fitness_f(i)+eps));
                    Xnewf(i,j)=Xf(i,j)+C3*FF*rand*(Q*Xbest_m(j)-Xf(i,j));
                end
            end
        else % 交配
            for i=1:Nm
                for j=1:1:dim
                    Mm=exp(-fitness_f(i)/(fitness_m(i)+eps));
                    Xnewm(i,j)=Xm(i,j) +C3*rand*Mm*(Q*Xf(i,j)-Xm(i,j));
                end
            end
            for i=1:Nf
                for j=1:1:dim
                    Mf=exp(-fitness_m(i)/(fitness_f(i)+eps));
                    Xnewf(i,j)=Xf(i,j) +C3*rand*Mf*(Q*Xm(i,j)-Xf(i,j));
                end
            end
            flag_index = floor(2*rand()+1);
            egg=vec_flag(flag_index);
            if egg==1;
                [GYworst, gworst] = max(fitness_m);
                Xnewm(gworst,:)=lb+rand*(ub-lb);
                [GYworst, gworst] = max(fitness_f);
                Xnewf(gworst,:)=lb+rand*(ub-lb);
            end
        end
    end
end
    for j=1:Nm
         Flag4ub=Xnewm(j,:)>ub;
         Flag4lb=Xnewm(j,:)<lb;
        Xnewm(j,:)=(Xnewm(j,:).*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;
        y = fobj(Xnewm(j,:),var);
        if y<fitness_m(j)
            fitness_m(j)=y;
            Xm(j,:)= Xnewm(j,:);
        end
    end
    [Ybest1,gbest1] = min(fitness_m);
    for j=1:Nf
         Flag4ub=Xnewf(j,:)>ub;
         Flag4lb=Xnewf(j,:)<lb;
        Xnewf(j,:)=(Xnewf(j,:).*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;
        y = fobj(Xnewf(j,:),var);
        if y<fitness_f(j)
            fitness_f(j)=y;
            Xf(j,:)= Xnewf(j,:);
        end
    end
    [Ybest2,gbest2] = min(fitness_f);
    if Ybest1<fitnessBest_m
        Xbest_m = Xm(gbest1,:);
        fitnessBest_m=Ybest1;
    end
    if Ybest2<fitnessBest_f
        Xbest_f = Xf(gbest2,:);
        fitnessBest_f=Ybest2;   
    end
    if Ybest1<Ybest2
        gbest_t(t+1)=min(Ybest1);
    else
        gbest_t(t+1)=min(Ybest2);   
    end
    if fitnessBest_m<fitnessBest_f
        GYbest=fitnessBest_m;
        Xfood=Xbest_m;
    else
        GYbest=fitnessBest_f;
        Xfood=Xbest_f;
    end
end
fval = GYbest;
end