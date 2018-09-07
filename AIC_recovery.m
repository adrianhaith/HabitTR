% AIC false-positive analysis
%  bootstrap data from borderline participants, comparing different models
clear all
load HabitModelFits_U
optimizer = 'fmincon'; % 'bads' or 'fmincon'
%%
Nsamps = 100;

s = 8; % subject
c = 2; % condition
%model_type = 'flex-habit';

% generate data
% allow RTs to follow typical distribution
RT = data(s,c).RT;
%figure(1); clf;
%hist(RT);

% set parameters
params_original = model{3,s,c}.paramsOpt;
params_original(7) = 0.5; % force to be a flex-habit participant
% get parameter fits for this participant:
%like_fun = @(params) habit_lik(data(s,c).RT,data(s,c).response,params,model_type);
%habit_lik(data(s,c).RT,data(s,c).response,paramsInit,model_type);
%params_original = fmincon(like_fun,paramsInit,A,B,Aeq,Beq,LB,UB);

% generate predictions for these parameters
xplot = [0.001:.001:1.2];
%pr_original = model{3,s,c}.presponse;
pr_original = getResponseProbs_U(xplot,params_original,2);

pr = getResponseProbs_U(RT,params_original,2);
pr = pr(1:3,:);
%pr(3,:) = 2*pr(3,:);

for j=1:Nsamps % sample
    response_mat(:,:,j) = mnrnd(1,pr(1:3,:)'); % matrix - position of 1 in each row indicates which response occurred
    response(:,j) = sum(response_mat(:,:,j).*repmat([1 2 3],length(RT),1),2); % translate into a numerical 1, 2 or 3
    
    % sliding window on synthetic data
    for i=1:3
        ihit = response_mat(:,i,j); % logical indexing for trials in which response i occurred
        data_resamp_sw(i,:,j) = sliding_window(RT,ihit,xplot,.050);
    end
    %
    
    % now try to recover the parameters
    % refit under different models
    model_refit(1,j) = fit_model(RT,response(:,j),NaN*ones(1,8),optimizer); % no-habit model
    model_refit(2,j) = fit_model(RT,response(:,j),[NaN*ones(1,6) 1 NaN],optimizer); % habit model
    model_refit(3,j) = fit_model(RT,response(:,j),[NaN*ones(1,6) 0 NaN],optimizer); % flex model
    
    for i=1:3
        params_fit(j,:,i) = model_refit(i,j).paramsOpt;
        presponse_recov(:,:,j,i) = model_refit(i,j).presponse;
        AIC(j,i) = model_refit(i,j).AIC;
    end
    %like_fun = @(params) habit_lik(RT,response(:,j),params,model_type);
    % equality constraints
   
    
    % do optimization
    %params_fit(j,:) = fmincon(like_fun,paramsInit,A,B,Aeq,Beq,LB,UB);
    %presponse_recov(:,:,j) = getResponseProbs(xplot,params_fit(j,:),model_type)
    
end

%% plot fits
figure(51); clf; hold on
plot(xplot,pr_original(1:3,:)')



%% plot scatter of AICS
figure(52); clf; hold on
plot(AIC(:,1)-AIC(:,3),AIC(:,2)-AIC(:,3),'.');
axh = gca;
color = 'k'; % black, or [0 0 0]
linestyle = '-'; % dotted
line(get(axh,'XLim'), [0 0], 'Color', color, 'LineStyle', linestyle);
line([0 0], get(axh,'YLim'), 'Color', color, 'LineStyle', linestyle);
xlabel('favors flex-habit model over no-habit model ->')
ylabel('favors flex-habit model over habit model ->')

figure(52); hold on
subplot(1,2,1);
hist(AIC(:,1)-AIC(:,3))
xlabel('favors flex model ->')

subplot(1,2,2);
hist(AIC(:,2)-AIC(:,3))
xlabel('favors flex model ->')

