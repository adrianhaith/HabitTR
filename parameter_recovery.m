% test parameter recovery
clear all
load HabitModelFits
%%
Nsamps = 10;
% optimization parameters
Aeq = [0 0 1 0 0 0 0 0];
Beq = .99;

% inequality constraints
A = [1 0 0 -1 0 0 0 0];
B = 0;

% set up bounds for model
LB_AE = .0001; UB_AE = .9999;
LB = [0 .01 .5 0 .01 .5 LB_AE LB_AE];
UB = [.75 100 UB_AE 10 100 UB_AE .499 UB_AE];
paramsInit = [.4 .05 .99 .5 .05 .95 .25 .95];

s = 4; % subject
c = 3; % condition
model_type = 'flex-habit';

% generate data
% allow RTs to follow typical distribution
RT = data(s,c).RT;
%figure(1); clf;
%hist(RT);

% set parameters
%params = model(3).paramsOpt(s,:,c);
% get parameter fits for this participant:
like_fun = @(params) habit_lik(data(s,c).RT,data(s,c).response,params,model_type);
habit_lik(data(s,c).RT,data(s,c).response,paramsInit,model_type);
params_original = fmincon(like_fun,paramsInit,A,B,Aeq,Beq,LB,UB);

% generate predictions for these parameters
xplot = [0.001:.001:1.2];
pr_original = getResponseProbs(xplot,params_original,model_type)

pr = getResponseProbs(RT,params_original,model_type);
pr = pr(1:3,:);
pr(3,:) = 2*pr(3,:);

for j=1:Nsamps % sample
    response_mat(:,:,j) = mnrnd(1,pr(1:3,:)'); % matrix - position of 1 in each row indicates which response occurred
    response(:,j) = sum(response_mat(:,:,j).*repmat([1 2 3],length(RT),1),2); % translate into a numerical 1, 2 or 3
    
    % sliding window on synthetic data
    for i=1:3
        ihit = response_mat(:,i,j); % logical indexing for trials in which response i occurred
        data_recov_sw(i,:,j) = sliding_window(RT,ihit,xplot,.050);
    end
    %
    %figure(2); clf; hold on
    %plot(xplot,pr_original')
    %plot(xplot,model(3).presponse(1:3,:,2,1)','o')
    %plot(xplot,data(s,c).sliding_window')
    %plot(xplot,prplot(1,:)+prplot(2,:)+2*prplot(3,:),'k','linewidth',2);
    
    % now try to recover the parameters
    like_fun = @(params) habit_lik(RT,response(:,j),params,model_type);
    % equality constraints
    
    
    % do optimization
    params_fit(j,:) = fmincon(like_fun,paramsInit,A,B,Aeq,Beq,LB,UB);
    presponse_recov(:,:,j) = getResponseProbs(xplot,params_fit(j,:),model_type)
    
end
%%
figure(1); clf; hold on
plot(xplot,squeeze(presponse_recov(1,:,:)),'b');
plot(xplot,squeeze(presponse_recov(2,:,:)),'r');
plot(xplot,squeeze(presponse_recov(3,:,:)),'m');
plot(xplot,squeeze(presponse_recov(4,:,:)),'b:');
plot(xplot,data(s,c).sliding_window(1,:,:),'b');

plot(xplot,pr_original(1,:),'k','linewidth',4)
plot(xplot,pr_original(2,:),'k','linewidth',4)
plot(xplot,pr_original(3,:),'k','linewidth',4)
%plot(xplot,data_recov.sw')
%}
%% plot parameter distributions
param_names = {'\mu_1','\sigma_1','q_1','\mu_2','sigma_2','q_2','init AE','rho'}
figure(2); clf; hold on
for i=1:8
    subplot(2,4,i); hold on
    title(param_names{i})
    plot([1:Nsamps]/Nsamps,params_fit(:,i),'.')
    plot([0 1],params_original(i)*[1 1],'k')
end