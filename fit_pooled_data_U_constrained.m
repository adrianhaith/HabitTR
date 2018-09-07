%% fit global model to pooled data across all subjects
clear all
load PooledData

for c=1:3
    % fit unchanged data
    constrained_params = [NaN NaN NaN NaN];%NaN*ones(1,6);
    model_unchanged(c) = fit_model(data_all(c).RT_unchanged,(data_all(c).response_unchanged>1)+1,constrained_params);
    mu = model_unchanged(c).paramsOpt(1);
    sig = model_unchanged(c).paramsOpt(2);
    
    % fit different models to the data
    % no-habit model
    constrained_params = [0 0 mu sig NaN NaN 0 1];%NaN*ones(1,6);
    model(1,c) = fit_model(data_all(c).RT,data_all(c).response,constrained_params);
    %model_habit{c}.nParams = 6; % 6 parameters for habit model
    
    % habit model
    constrained_params = [mu sig NaN NaN NaN NaN 1 NaN];
    model(2,c) = fit_model(data_all(c).RT,data_all(c).response,constrained_params);
    %model_nohabit{c}.nParams = 4;
    
    %flex-habit model
    constrained_params = [mu sig NaN NaN NaN NaN NaN NaN];
    model(3,c) = fit_model(data_all(c).RT,data_all(c).response,constrained_params);
    %model_flexhabit{c}.nParams = 7;   
    
end


%% plot results
figure(1); clf; hold on
col = {'b','r','m'};
scaling = [1 1 .5]; % scaling for plotting 'other' error so that all curves start at 0.25 (but don't sum to 1)
condition = {'Min. Practice','4-day Practice','20-day Practice'};
modelname = {'No-Habit','Habit','Flex-Habit'};
for c=1:3
    % habit model
    for m=1:3
        subplot(3,3,c+(m-1)*3); hold on
        title([condition{c},' - ',modelname{m}])
        for r=1:3
            plot(xplot,data_all(c).sw(r,:)*scaling(r),col{r})
            %plot(xplot,model_all_flex(c).presponse(r,:),col{r})
            plot(xplot,model(m,c).presponse(r,:)*scaling(r),col{r},'linewidth',2)
            
        end
        plot(xplot,model(m,c).presponse(4,:),'c','linewidth',2)
        plot(xplot,model_unchanged(c).presponse(1,:),'k-','linewidth',2)
        plot(xplot,data_all(c).sw(4,:),'k')
    end
    %{
    % no-habit model
    subplot(3,3,c+3); hold on
    title([condition{c},' No-Habit Model'])
    for r=1:3
        plot(xplot,data_all(c).sw(r,:)*scaling(r),col{r})
        %plot(xplot,model_all_flex(c).presponse(r,:),col{r})
        plot(xplot,model_nohabit{c}.presponse(r,:)*scaling(r),col{r},'linestyle','--')
    end
    
    plot(xplot,model_unchanged(c).presponse(1,:),'k--')
    plot(xplot,data_all(c).sw(4,:),'k')
    
    % flex-habit model
    subplot(3,3,c+6); hold on
    title([condition{c},' Flex-Habit Model'])
    for r=1:3
        plot(xplot,data_all(c).sw(r,:)*scaling(r),col{r})
        %plot(xplot,model_all_flex(c).presponse(r,:),col{r})
        plot(xplot,model_flexhabit{c}.presponse(r,:)*scaling(r),col{r},'linestyle','--')
        
    end
    plot(xplot,model_flexhabit{c}.presponse(4,:),'c','linestyle','--')
    plot(xplot,model_unchanged(c).presponse(1,:),'k--')
    plot(xplot,data_all(c).sw(4,:),'k')
    %}
end

%% predict 20-day data by just increasing SAT for final day
%{
model_predicted = model_habit{2};
model_predicted.paramsOpt(1:2) = model_unchanged(3).paramsOpt(1:2); % set to 'unchanged' parameters

model_predicted.presponse = getResponseProbs_U(model_predicted.xplot,model_predicted.paramsOpt,2)

figure(3); clf; hold on
for r=1:3
    plot(xplot,data_all(c).sw(r,:)*scaling(r),col{r})
    %plot(xplot,model_all_flex(c).presponse(r,:),col{r})
    plot(xplot,model_flexhabit{c}.presponse(r,:)*scaling(r),col{r},'linestyle','--')
    plot(xplot,model_predicted.presponse(r,:)*scaling(r),col{r},'linewidth',2)
end
plot(xplot,model_flexhabit{c}.presponse(4,:),'c','linestyle','--')
plot(xplot,model_unchanged(c).presponse(1,:),'k--')
plot(xplot,data_all(c).sw(4,:),'k')

%% predict 20-day data by just increasing SAT for final day
model_predicted = model_flexhabit{2};
model_predicted.paramsOpt(1:2) = model_unchanged(3).paramsOpt(1:2); % set to 'unchanged' parameters

model_predicted.presponse = getResponseProbs_U(model_predicted.xplot,model_predicted.paramsOpt,2)

figure(4); clf; hold on
for r=1:3
    plot(xplot,data_all(c).sw(r,:)*scaling(r),col{r})
    %plot(xplot,model_all_flex(c).presponse(r,:),col{r})
    plot(xplot,model_flexhabit{2}.presponse(r,:)*scaling(r),col{r},'linestyle','--')
    plot(xplot,model_predicted.presponse(r,:)*scaling(r),col{r},'linewidth',2)
    plot(xplot,model_flexhabit{3}.presponse(r,:)*scaling(r),col{r},'linestyle',':')
end
plot(xplot,model_flexhabit{c}.presponse(4,:),'c','linestyle','--')
plot(xplot,model_unchanged(c).presponse(1,:),'k--')
plot(xplot,data_all(c).sw(4,:),'k')
%}