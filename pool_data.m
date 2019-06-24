%% pool data across all subjects
clear all
load HabitData
habitual_only = 0;
if(habitual_only)
    load i_habitual
    subjects = i_habitual;
else
    subjects = 1:24;
end

xplot = .001*[1:1:1200];

for c=1:3
    
    data_all(c).RT = [];
    data_all(c).response = [];
    for s=subjects
        if(~isempty(data(s,c).RT))
            data_all(c).RT = [data_all(c).RT data(s,c).RT];
            data_all(c).response = [data_all(c).response data(s,c).response];
        end
    end
    %data_all(c).RT = [data(:,c).RT];
    %data_all(c).response = [data(:,c).response];
    for r=1:3
        data_all(c).sw(r,:) = sliding_window(data_all(c).RT,data_all(c).response==r,xplot,.05);
    end
   
    data_all(c).RT_unchanged = [data(:,c).RT_unchanged];
    data_all(c).response_unchanged = [data(:,c).response_unchanged];
    
    data_all(c).sw(4,:) = sliding_window(data_all(c).RT_unchanged,data_all(c).response_unchanged==1,xplot,.05);
    data_all(c).sw(5,:) = sliding_window(data_all(c).RT_unchanged,data_all(c).response_unchanged==2,xplot,.05);
    data_all(c).sw(6,:) = sliding_window(data_all(c).RT_unchanged,data_all(c).response_unchanged==3,xplot,.05);
end
if(habitual_only)
    save PooledData_HabitualOnly
else
    save PooledData
end

