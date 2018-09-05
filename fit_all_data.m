% fit global model to pooled data across all subjects
clear all
load HabitData
xplot = .001*[1:1:1200];

for c=1:3
    
    data_all(c).RT = [];
    data_all(c).response = [];
    for s=1:24
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
    
    % fit model to unchanged data
    model_all_unchanged(c) = fit_model(data_all(c).RT_unchanged,(data_all(c).response_unchanged>1)+1,1);
    
    % fit constrained model to rest of data
    constrained_params = NaN*ones(1,6);
    constrained_params(1:2) = model_all_unchanged(c).paramsOpt(1:2);
    
    
    model_all(c) = fit_model(data_all(c).RT,data_all(c).response,2,[constrained_params 1],0);
    model_all_flex(c) = fit_model(data_all(c).RT,data_all(c).response,2,[constrained_params NaN],0);

end

%% plot results
figure(1); clf; hold on
col = {'b','r','m'};
for c=1:3
    subplot(1,3,c); hold on
    for r=1:3
        plot(xplot,data_all(c).sw(r,:),col{r})
        plot(xplot,model_all_flex(c).presponse(r,:),col{r})
        plot(xplot,model_all(c).presponse(r,:),col{r},'linestyle','--')
    end
    plot(xplot,data_all(c).sw(4,:),'g')
    plot(xplot,model_all_unchanged(c).presponse(1,:),'g')
    plot(xplot,model_all(c).presponse(5,:),'c--')
    plot(xplot,model_all_flex(c).presponse(5,:),'c')
end

figure(2); clf; hold on
for c=1:3
    subplot(1,3,c); hold on
    plot(xplot,data_all(c).sw(1,:)+data_all(c).sw(3,:),'b')
    plot(xplot,data_all(c).sw(2,:),'r')
    
    plot(xplot,model_all_flex(c).presponse(1,:)+model_all_flex(c).presponse(3,:),'b')
    plot(xplot,model_all_flex(c).presponse(2,:),'r')
    
    plot(xplot,model_all(c).presponse(1,:)+model_all(c).presponse(3,:),'b--')
    plot(xplot,model_all(c).presponse(2,:),'r--')
    
    plot(xplot,data_all(c).sw(4,:),'g')
    plot(xplot,model_all_unchanged(c).presponse(1,:),'g')

    
    
end

%% try for single subject
dsw = sliding_window(data(2,1).RT,data(2,1).response==1,xplot,.05)
figure(3); clf; hold on
plot(dsw)