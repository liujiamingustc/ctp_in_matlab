function signal = find_kestner(daydata, inpara)
%%% n连发
%%% INPUT
%% daydata : data in a day [开盘价 最高价 最低价 收盘价]
%% inpara{1} = [采样频率 移动平均周期]; %% 前两个是进场需要 后三个是出场使用
%% inpara{2} = sec_points e.g. [1 75 135 175 215] 
%%
%%% OUTPUT
%% signal.name    =   models{i}.name 
%% signal.inplace =   [ ]         (where to get in) 
%% signal.direct  =   [+1 or -1]   (+1  Buy; -1 Sell)  
%% signal.inprice =   [ ]  

%%% Step 0: INPUT check 
%%% 
p = inpara{1}(2); 
freq = inpara{1}(1); 
ave = 0;
%%% Step 1: Sampling by 采样频率
sec_points = inpara{2}; %% [1 75 135 175 215];  
n_sample = 0; 
for j = 1 : length(sec_points) - 1
    %% 1.1 sampling from the daydata
    if j == 1
        section{j} = daydata(sec_points(j):sec_points(j+1),:); 
    else
        section{j} = daydata(sec_points(j)+1:sec_points(j+1),:);  
    end
    %% n_sec(i,1) = sec_points(j) - sec_points(j+1);
    [sec{j} sec_num{j}]= sample_k(section{j},freq);
    %% 1.2 collect the sampled data 
    sampled_day_data(n_sample+1 : n_sample+length(sec_num{j}),:) = sec{j};
    sampled_day_data_size(n_sample+1 : n_sample+length(sec_num{j}),1) = sec_num{j}; 
    n_sample = n_sample + length(sec_num{j});
end

%%% Step 2: Find Pattern by 连发次数
ct = inpara{1}(1);  %% 连发次数
%% 2.1 预先判断
if n_sample <= p 
    signal = {};
    return; 
end
%% 2.2 寻找 ct 连发
k = 0; %% number of the tcd or tci patterns

if freq ~= 1
for i = p+1 : n_sample-1 
    if sampled_day_data(i,4) >  sum(sampled_day_data(i-p+1:i,2))/p && sampled_day_data(i-1,4) < sum(sampled_day_data(i-p:i-1,2))/p %% 收盘价在上轨之上

%         for j = i:i+ct-2
%             if sampled_day_data(j,3) >= sampled_day_data(j+1,3)|| sampled_day_data(j,2) >= sampled_day_data(j+1,2)  %% 存在反趋势，则此ct连增不成立
%                 l1 = 0; break;
%             end
%         end
%         if l1 && sampled_day_data(i+ct-1,2) == max(sampled_day_data(1:i+ct-1,2)) && sampled_day_data(i+ct-1,1) < sampled_day_data(i+ct-1,4) && sampled_day_data(i+ct,1) > sampled_day_data(i+ct,4)...
%               &&  (max(sampled_day_data(i+ct,1),sampled_day_data(i+ct,4)) ==sampled_day_data(i+ct,2) || min(sampled_day_data(i+ct,1),sampled_day_data(i+ct,4)) ==sampled_day_data(i+ct,3))...
%                  && sum(daydata(max(1,sum(sampled_day_data_size(1:i+ct,1))-vol_num+1):sum(sampled_day_data_size(1:i+ct,1)),5))/vol_num*vol_multiple > daydata(sum(sampled_day_data_size(1:i+ct,1)),5)...
%                 && sampled_day_data(i+ct,2) - min(sampled_day_data(i:i+ct-1,3)) <= amp_down              %% 如果l1 == 1说明找到了一个
          k = k + 1; 
          signal_in_sec(k) = i;  %% ct连减的最后一个sec的序号
          tmp(k) = 1;                 %% 连增买入 +1
%         end
    elseif sampled_day_data(i,4) <  sum(sampled_day_data(i-p+1:i,3))/p  && sampled_day_data(i-1,4) >  sum(sampled_day_data(i-p:i-1,3))/p  %% 收盘价在下轨之下

%         for j = i:i+ct-2
%             if sampled_day_data(j,2) <= sampled_day_data(j+1,2) || sampled_day_data(j,3) <= sampled_day_data(j+1,3)%% 存在反趋势，则此ct连减不成立
%                 l1 =0; break;
%             end
%         end   
%         if l1 && sampled_day_data(i+ct-1,3) == min(sampled_day_data(1:i+ct-1,3)) && sampled_day_data(i+ct-1,1)>sampled_day_data(i+ct-1,4) && sampled_day_data(i+ct,1)<sampled_day_data(i+ct,4)...
%                && (max(sampled_day_data(i+ct,1),sampled_day_data(i+ct,4)) ==sampled_day_data(i+ct,2) || min(sampled_day_data(i+ct,1),sampled_day_data(i+ct,4)) ==sampled_day_data(i+ct,3))...
%                  && sum(daydata(max(1,sum(sampled_day_data_size(1:i+ct,1))-vol_num+1):sum(sampled_day_data_size(1:i+ct,1)),5))/vol_num*vol_multiple > daydata(sum(sampled_day_data_size(1:i+ct,1)),5)...
%                 &&   max(sampled_day_data(i:i+ct-1,2))-sampled_day_data(i+ct,3) <= amp_down               %% 如果l1 == 1说明找到了一个
          k = k + 1;
          signal_in_sec(k) = i; %% ct连增的后一个sec的序号
          tmp(k) = -1;               %% 连减卖出 -1
%         end
    end
end
else
 for i = p+1 : n_sample-1
    if sampled_day_data(i,4) >  sum(sampled_day_data(i-p+1:i,2))/p &&sampled_day_data(i-1,4) <  sum(sampled_day_data(i-p:i-1,2))/p %% 收盘价在上轨之上

%         for j = i:i+ct-2
%             if sampled_day_data(j,3) >= sampled_day_data(j+1,3)|| sampled_day_data(j,2) >= sampled_day_data(j+1,2)  %% 存在反趋势，则此ct连增不成立
%                 l1 = 0; break;
%             end
%         end
%         if l1 && sampled_day_data(i+ct-1,2) == max(sampled_day_data(1:i+ct-1,2)) && sampled_day_data(i+ct-1,1) < sampled_day_data(i+ct-1,4) && sampled_day_data(i+ct,1) > sampled_day_data(i+ct,4)...
%               &&  (max(sampled_day_data(i+ct,1),sampled_day_data(i+ct,4)) ==sampled_day_data(i+ct,2) || min(sampled_day_data(i+ct,1),sampled_day_data(i+ct,4)) ==sampled_day_data(i+ct,3))...
%                  && sum(daydata(max(1,sum(sampled_day_data_size(1:i+ct,1))-vol_num+1):sum(sampled_day_data_size(1:i+ct,1)),5))/vol_num*vol_multiple > daydata(sum(sampled_day_data_size(1:i+ct,1)),5)...
%                 && sampled_day_data(i+ct,2) - min(sampled_day_data(i:i+ct-1,3)) <= amp_down              %% 如果l1 == 1说明找到了一个
          k = k + 1; 
          signal_in_sec(k) = i;  %% ct连减的最后一个sec的序号
          tmp(k) = 1;                 %% 连增买入 +1
%         end
    elseif sampled_day_data(i,4) <  sum(sampled_day_data(i-p+1:i,3))/p && sampled_day_data(i-1,4) >  sum(sampled_day_data(i-p:i-1,3))/p %% 收盘价在下轨之下

%         for j = i:i+ct-2
%             if sampled_day_data(j,2) <= sampled_day_data(j+1,2) || sampled_day_data(j,3) <= sampled_day_data(j+1,3)%% 存在反趋势，则此ct连减不成立
%                 l1 =0; break;
%             end
%         end   
%         if l1 && sampled_day_data(i+ct-1,3) == min(sampled_day_data(1:i+ct-1,3)) && sampled_day_data(i+ct-1,1)>sampled_day_data(i+ct-1,4) && sampled_day_data(i+ct,1)<sampled_day_data(i+ct,4)...
%                && (max(sampled_day_data(i+ct,1),sampled_day_data(i+ct,4)) ==sampled_day_data(i+ct,2) || min(sampled_day_data(i+ct,1),sampled_day_data(i+ct,4)) ==sampled_day_data(i+ct,3))...
%                  && sum(daydata(max(1,sum(sampled_day_data_size(1:i+ct,1))-vol_num+1):sum(sampled_day_data_size(1:i+ct,1)),5))/vol_num*vol_multiple > daydata(sum(sampled_day_data_size(1:i+ct,1)),5)...
%                 &&   max(sampled_day_data(i:i+ct-1,2))-sampled_day_data(i+ct,3) <= amp_down               %% 如果l1 == 1说明找到了一个
          k = k + 1;
          signal_in_sec(k) = i; %% ct连增的后一个sec的序号
          tmp(k) = -1;               %% 连减卖出 -1
%         end
    end
end   
end

%%% Step 3: 判断是否存在进场点，计算进场点在抽样前数据中的位置(inplace)和方向(direct)
if k > 0
t = 0; 
  for i = 1:k 
    if signal_in_sec(i) < n_sample && sum(sampled_day_data_size(1:signal_in_sec(i))) + 1 ~= inpara{2}(5)
        t = t+1;
        signal.inplace(t) = sum(sampled_day_data_size(1:signal_in_sec(i))) + 1;  %% OUTPUT 2
        signal.direct(t) = tmp(t);    %% OUTPUT 3
    end
  end %%  for i = 1:k 
  
  if t > 0
          signal.name = 'kestner'; %% OUTPUT 1 
          signal.inprice = daydata(signal.inplace,1);  %% OUTPUT 4
          return;
  end
end %% k > 0 

    signal = {}; 