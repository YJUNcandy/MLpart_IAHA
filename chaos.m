%% 混沌映射函数 %%
function result = chaos(index, N, var)
m=var.M;
dim = var.N;
switch index
    case 1    
        %没有任何映射时的随机数
        result =rand(N,dim);
    case 2
        % Logistic 映射
        % 混沌系数模糊规则
        if dim <=100
            miu=3.4;
        end
        if dim==150
            miu=3.6;
        end
        if ((dim==200) && (m<=15))
            miu=3.7;
        end
        if ((dim==200) && (m>=20))
            miu=3.9;
        end
        if ((dim==250) && (m<=10))
            miu=3.8;
        end
        if ((dim==250) && (m==20))
            miu=3.9;
        end
        if ((dim==250) && (m>=15) && (m~=20))
            miu=3.8;
        end
        Logistic=rand(N,dim);
        for i=1:N
            for j=2:dim
                Logistic(i,j)=miu.* Logistic(i,j-1).*(1-Logistic(i,j-1));
            end
        end
        result = Logistic; 
end
end


