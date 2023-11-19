%% 算法选择与执行函数 %%
function[BestF,BestX,Curve,Time,name]=Alg_Choose(Alg_Index,Pop_num,Max_iter,lb,fobj,var)
    switch Alg_Index
        case 1          % 改进的人工蜂鸟算法
            t1=clock;
            [BestF,BestX,Curve]=IAHA(Pop_num,Max_iter,lb,var.M,var.N,fobj,var);     
            t2=clock;
            Time=(t2(end)+t2(end-1)*60+t2(end-2)*3600-t1(end)-t1(end-1)*60-t1(end-2)*3600);
            name='IAHA';
        case 2          % 人工蜂鸟算法  
            t1=clock;
            [BestF,BestX,Curve]=AHA(Pop_num,Max_iter,lb,var.M,var.N,fobj,var);     
            t2=clock;
            Time=(t2(end)+t2(end-1)*60+t2(end-2)*3600-t1(end)-t1(end-1)*60-t1(end-2)*3600);
            name='AHA';
        case 3            
            t1=clock;
            [BestF,BestX,Curve]=SO(Pop_num,Max_iter,lb,var.M,var.N,fobj,var);  % 蛇优化算法
            t2=clock;
            Time=(t2(end)+t2(end-1)*60+t2(end-2)*3600-t1(end)-t1(end-1)*60-t1(end-2)*3600);
            name='SO';
        case 4                         
            t1=clock;
            [BestF,BestX,Curve]=GWO(Pop_num,Max_iter,lb,var.M,var.N,fobj,var); % 灰狼优化算法 
            t2=clock;
            Time=(t2(end)+t2(end-1)*60+t2(end-2)*3600-t1(end)-t1(end-1)*60-t1(end-2)*3600);
            name='GWO';
        case 5                       
            t1=clock;
            [BestF,BestX,Curve]=PSO(Pop_num,Max_iter,lb,var.M,var.N,fobj,var);% 粒子群优化算法 
            t2=clock;
            Time=(t2(end)+t2(end-1)*60+t2(end-2)*3600-t1(end)-t1(end-1)*60-t1(end-2)*3600);
            name='PSO';
        case 6                       
            t1=clock;
            [BestF,BestX,Curve]=GA(Pop_num,Max_iter,lb,var.M,var.N,fobj,var); % 遗传优化算法 
            t2=clock;
            Time=(t2(end)+t2(end-1)*60+t2(end-2)*3600-t1(end)-t1(end-1)*60-t1(end-2)*3600);
            name='GA';        
    end
end