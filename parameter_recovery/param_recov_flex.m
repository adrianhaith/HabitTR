% test parameter recovery - focus on showing that rho can be accurately
% estimated
addpath ../
clear all
load HabitModelFits_U
optimizer = 'fmincon'; % 'bads' or 'fmincon'
tic

%%
Nsamps = 10;
c = 2; % condition
for s = 1:15; % subject
    if(~isempty(data(s,c).RT))
        clear response_mat
        clear response
        clear ihit
        %model_type = 'flex-habit';
        
        % generate data
        % allow RTs to follow typical distribution
        RT = data(s,c).RT;
        %figure(1); clf;
        %hist(RT);
        
        % set parameters
        p_original(s,:) = model{2,s,c}.paramsOpt;
        %params_original(s,7) = rand(1);
        % get parameter fits for this participant:
        %like_fun = @(params) habit_lik(data(s,c).RT,data(s,c).response,params,model_type);
        %habit_lik(data(s,c).RT,data(s,c).response,paramsInit,model_type);
        %params_original = fmincon(like_fun,paramsInit,A,B,Aeq,Beq,LB,UB);
        
        % generate predictions for these parameters
        
        %pr(3,:) = 2*pr(3,:);
        
        for j=1:Nsamps % sample
            params_original(j,:,s) = p_original(s,:);
            params_original(j,7,s) = rand(1);
            
            % generate predictions for these parameters
            xplot = [0.001:.001:1.2];
            pr_original = getResponseProbs_U(xplot,params_original(j,:,s),2);
            
            pr = getResponseProbs_U(RT,params_original(j,:,s),2);
            pr = pr(1:3,:);
            
            
            response_mat(:,:,j) = mnrnd(1,pr(1:3,:)'); % matrix - position of 1 in each row indicates which response occurred
            response(:,j) = sum(response_mat(:,:,j).*repmat([1 2 3],length(RT),1),2); % translate into a numerical 1, 2 or 3
            
            % sliding window on synthetic data
            for i=1:3
                ihit = response_mat(:,i,j); % logical indexing for trials in which response i occurred
                data_resamp_sw(i,:,j) = sliding_window(RT,ihit,xplot,.050);
            end
            %
            
            % fit all 3 models to the data
            pConstr = [0 0 NaN NaN NaN NaN 0 1;
                        NaN NaN NaN NaN NaN NaN 1 NaN;
                        NaN NaN NaN NaN NaN NaN NaN NaN]; % parameter to constrain
            %pConstr(7) = 1; % assume habit model, not flex-habit
            for m = 1:3
                model_refit{m}(j) = fit_model(RT,response(:,j),pConstr(m,:),optimizer); % 'flex' model
                params_fit(j,:,m) = model_refit{m}(j).paramsOpt;
                presponse_recov(:,:,j,m) = model_refit{m}(j).presponse;
                AIC(m,j,s) = model_refit{m}(j).AIC;
            end
            %like_fun = @(params) habit_lik(RT,response(:,j),params,model_type);
            % equality constraints
            
            
            % do optimization
            %params_fit(j,:) = fmincon(like_fun,paramsInit,A,B,Aeq,Beq,LB,UB);
            %presponse_recov(:,:,j) = getResponseProbs(xplot,params_fit(j,:),model_type)
        end
        params_recov(:,:,:,s) = params_fit;
    end
end
%%
param_names = {'\mu_1','\sigma_1','\mu_2','\sigma_2','AE','init AE','rho1','rho2'};

figure(31); clf; hold on
for pp = 1:8
    subplot(2,4,pp); hold on
    title(param_names{pp})
    plot([0 max(max(params_recov(:,pp,3,:)))], [0 max(max(params_recov(:,pp,3,:)))],'k')
    for s=1:15
        plot(params_original(:,pp,s),params_recov(:,pp,3,s),'.')
    end
    axis equal
    
end
%% examine best model as a fun of rho
figure(33); clf; hold on
subplot(1,3,1); hold on
title('flex vs no-habit')
for s=1:15
    plot(params_original(:,7,s),AIC(1,:,s)-AIC(3,:,s),'b.','markersize',12)
end
plot([0 1],[0 0],'k')
xlabel('\rho')
ylabel('\Delta AIC in favor of flex over no-habit')

subplot(1,3,2); hold on
title('flex vs habit')
for s=1:15
    plot(params_original(:,7,s),AIC(2,:,s)-AIC(3,:,s),'r.','markersize',12)
end
plot([0 1],[0 0],'k')
xlabel('\rho')
ylabel('\Delta AIC in favor of flex over habit')

subplot(1,3,3); hold on
title('flex vs habit')
for s=1:15
    plot(params_original(:,7,s),min(AIC(2,:,s)-AIC(3,:,s),AIC(1,:,s)-AIC(3,:,s)),'r.','markersize',12)
end
plot([0 1],[0 0],'k')
xlabel('\rho')
ylabel('\Delta AIC in favor of flex over either')

%% compute winning model for each sample
for s=1:15
    
    if(~isempty(data(s,c).RT))
        [xx m_best(:,s)] = min(AIC(:,:,s));
        
        for m=1:3
            mConfusion(m,c,s) = sum(m_best(:,s)==m)/Nsamps;
        end
    else
        mConfusion(:,c,s) = NaN;
    end
end

figure(32); clf; hold on
for s=1:15
    if(~isempty(data(s,c).RT))
        subplot(4,4,s); hold on
        mCflip = flipud(mConfusion(:,c,s));
        imagesc(flipud(mConfusion(:,c,s)))
        for i=1:3
            
            text(i,j,num2str(mCflip(i)))
            
        end
        axis equal
        
    end
end


%% averaged across all participants
figure(7); clf; hold on
colormap('bone')
cond_str = {'Minimal Practice','4-Day Practice','20-Day Practice'};
for c=1:3
    subplot(1,3,c); hold on
    title(cond_str{c});
    mConfusionAv = mean(squeeze(mConfusion(:,:,c,:)),3,'omitnan');
    mCflip = flipud(mConfusionAv)
    image(64*mCflip)
    for i=1:2
        for j=1:2
            text(i,j,num2str(mCflip(j,i)))
        end
    end
    axis equal
    axis off
end
    

%%
%{
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
%

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
%}
%%
toc