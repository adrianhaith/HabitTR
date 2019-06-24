% test parameter recovery - focus on showing that rho can be accurately
% estimated
clear all
load HabitModelFits_U
optimizer = 'fmincon'; % 'bads' or 'fmincon'
tic
%%
Nsamps = 100;

s = 14; % subject
c = 2; % condition
%model_type = 'flex-habit';

% generate data
% allow RTs to follow typical distribution
RT = data(s,c).RT;
%figure(1); clf;
%hist(RT);

% set parameters
params_original = model{3,s,c}.paramsOpt;
params_original(7) = 1;
% get parameter fits for this participant:
%like_fun = @(params) habit_lik(data(s,c).RT,data(s,c).response,params,model_type);
%habit_lik(data(s,c).RT,data(s,c).response,paramsInit,model_type);
%params_original = fmincon(like_fun,paramsInit,A,B,Aeq,Beq,LB,UB);

% generate predictions for these parameters
xplot = [0.001:.001:1.2];
pr_original = model{3,s,c}.presponse;

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
    model_refit(j) = fit_model(RT,response(:,j),NaN*ones(1,8),optimizer); % 'flex' model
    params_fit(j,:) = model_refit(j).paramsOpt;
    presponse_recov(:,:,j) = model_refit(j).presponse;
    %like_fun = @(params) habit_lik(RT,response(:,j),params,model_type);
    % equality constraints
    
    
    % do optimization
    %params_fit(j,:) = fmincon(like_fun,paramsInit,A,B,Aeq,Beq,LB,UB);
    %presponse_recov(:,:,j) = getResponseProbs(xplot,params_fit(j,:),model_type)
    
end
%%
figure(21); clf; hold on
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

%%
scaling = [1 1 .5];
figure(22); clf; hold on
plot(xplot,pr_original')
%plot(xplot,model(3).presponse(1:3,:,2,1)','o')
plot(xplot,data(s,c).sliding_window','linewidth',2)
%plot(xplot,pr_original(1,:)+prplot(2,:)+2*prplot(3,:),'k','linewidth',2);
for j=1:Nsamps
    for ii = 1:3
        plot(xplot,data_resamp_sw(ii,:,j)*scaling(ii),'-')
    end
end
%% plot parameter distributions
param_names = {'\mu_1','\sigma_1','\mu_2','\sigma_2','AE','init AE','rho1','rho2'};
figure(23); clf; hold on
for i=1:8
    subplot(2,4,i); hold on
    title(param_names{i})
    plot([1:Nsamps]/Nsamps,params_fit(:,i),'.')
    plot([0 1],params_original(i)*[1 1],'k')
end
%%
figure(24); clf; hold on
for i=1:8
    subplot(2,4,i); hold on
    title(param_names{i})
    %w = .05; % bin width
    %bins = [w:w:1]-w/2;
    hist(params_fit(:,i),20);
    plot(params_original(i)*[1 1],[0 Nsamps/10],'r','linewidth',3)
end

%%
toc