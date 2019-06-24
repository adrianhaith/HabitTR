% model recovery analysis

addpath ../
clear all
load HabitModelFits_U
optimizer = 'fmincon'; % 'bads' or 'fmincon'
tic
%%
Nsamps = 10;
nModel = 2; % # of models to consider
for s = 1:24; % subject
    for c = 1:3; % condition
        if(~isempty(data(s,c).RT))
            
            for m_gen=1:nModel
                clear pr
                clear response_mat
                clear response
                
                
                
                % resample subject data from fitted model
                RT = data(s,c).RT;
                params_original = model{m_gen,s,c}.paramsOpt;
                %params_original(7) = 1;
                
                %if(m==1)
                
                
                xplot = [0.001:.001:1.2];
                pr_original = model{m_gen,s,c}.presponse;
                
                
                pr = getResponseProbs_U(RT,params_original,2);
                pr = pr(1:3,:);
                
                for j=1:Nsamps % sample
                    
                    response_mat(:,:,j) = mnrnd(1,pr(1:3,:)'); % matrix - position of 1 in each row indicates which response occurred
                    response(:,j) = sum(response_mat(:,:,j).*repmat([1 2 3],length(RT),1),2); % translate into a numerical 1, 2 or 3
                    
                    % sliding window on synthetic data
                    for i=1:3
                        ihit = response_mat(:,i,j); % logical indexing for trials in which response i occurred
                        data_resamp_sw(i,:,j) = sliding_window(RT,ihit,xplot,.1);
                    end
                    
                    % parameter constraints for each model. NaN = unconstrained
                    pConstr = [0 0 NaN NaN NaN NaN 0 1;
                        NaN NaN NaN NaN NaN NaN 1 NaN;
                        NaN NaN NaN NaN NaN NaN NaN NaN];
                    
                    for m=1:nModel
                        % no-habit model
                        
                        model_refit{m}(j) = fit_model(RT,response(:,j),pConstr(m,:),optimizer); % 'flex' model
                        params_fit(j,:,m) = model_refit{m}(j).paramsOpt;
                        presponse_recov(:,:,j,m) = model_refit{m}(j).presponse;
                        AIC(m,j,m_gen,c,s) = model_refit{m}(j).AIC;
                    end
                    
                    %like_fun = @(params) habit_lik(RT,response(:,j),params,model_type);
                    % equality constraints
                    
                    
                    % do optimization
                    %params_fit(j,:) = fmincon(like_fun,paramsInit,A,B,Aeq,Beq,LB,UB);
                    %presponse_recov(:,:,j) = getResponseProbs(xplot,params_fit(j,:),model_type)
                    
                end
                
            end
        else
            AIC(:,:,:,c,s) = NaN;
        end
    end
end
    toc
    %% compare AICs
    %{
figure(1); clf; hold on
subplot(2,3,[1 2 4 5]); hold on
plot([model_refit{1}.AIC],[model_refit{2}.AIC],'.','markersize',12)
plot([min([model_refit{1}.AIC]) max([model_refit{1}.AIC])],[min([model_refit{1}.AIC]) max([model_refit{1}.AIC])],'k--')
xlabel('no habit AIC')
ylabel('habit AIC')
axis equal

subplot(2,3,[3 6]); hold on
plot([1:Nsamps]/Nsamps,[model_refit{1}.AIC]-[model_refit{2}.AIC],'.','markersize',12)
plot([0 1],[0 0],'k','linewidth',2)
ylabel('\Delta AIC in favor of habit')

% plot example SATs and fits
figure(2); clf; hold on
plot(squeeze(data_resamp_sw(1,:,:)),'b')
plot(squeeze(data_resamp_sw(2,:,:)),'r')
plot(.5*squeeze(data_resamp_sw(3,:,:)),'m')
plot(data(s,c).sliding_window(1,:),'b','linewidth',2)
plot(data(s,c).sliding_window(2,:),'r','linewidth',2)
plot(.5*data(s,c).sliding_window(3,:),'m','linewidth',2)

figure(3); clf; hold on
plot(squeeze(presponse_recov(1,:,:,1)),'b')
plot(squeeze(presponse_recov(2,:,:,1)),'r')
plot(.5*squeeze(presponse_recov(3,:,:,1)),'m')
plot(pr_original(1,:),'b','linewidth',2)
plot(pr_original(2,:),'r','linewidth',2)
plot(.5*pr_original(3,:),'m','linewidth',2)
    %}
    
% compute winning model for each sample
for s=1:24
    
    for c=1:3
        if(~isempty(data(s,c).RT))
        for m_gen = 1:2
            [xx m_best(m_gen,:,c,s)] = min(AIC(:,:,m_gen,c,s));
        end
        
        for m_gen=1:2
            for m=1:2
                mConfusion(m_gen,m,c,s) = sum(m_best(m_gen,:,c,s)==m)/Nsamps;
            end
        end
        else
            mConfusion(:,:,c,s) = NaN;
        end
    end
end
    
for c=1:3
    figure(3+c); clf; hold on
    for s=1:24
        if(~isempty(data(s,c).RT))
            subplot(6,4,s); hold on
            mCflip = flipud(mConfusion(:,:,c,s));
            imagesc(flipud(mConfusion(:,:,c,s)))
            for i=1:2
                for j=1:2
                    text(i,j,num2str(mCflip(j,i)))
                end
            end
            axis equal
            
        end
    end
end

%% averaged across all participants
figure(7); clf; hold on
colormap('parula')
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

%% compare AICs to real data
ff = figure(8); clf; hold on
set(ff,'Position',[200 200 800 200])
set(ff,'Color','w')
% min prac condition
subplot(1,3,1); hold on
m=1; c=1;
for s=1:24
    if(~isempty(model{m,s,c}))
        rAIC(s,:) = AIC(m,:,m,c,s);
        dataAIC(s) = model{m,s,c}.AIC;
        rLL(s,:) = (2*4 - rAIC(s,:))/2;
        dataLL(s) = (2*4 - dataAIC(s))/2;
        plot(dataLL,rLL,'b.')
        %plot(model{m,s,c}.AIC,AIC(m,:,m,c,s),'b.'); % model{m,s,c}   AIC(m,j,m_gen,c,s) 
    end
end
axis equal
plot([-350 0],[-350 0],'k')

   
%4-day prac condition
subplot(1,3,2); hold on
m=2; c=2;
for s=1:24
    if(~isempty(model{m,s,c}))
        rAIC(s,:) = AIC(m,:,m,c,s);
        dataAIC(s) = model{m,s,c}.AIC;
        rLL(s,:) = (2*4 - rAIC(s,:))/2;
        dataLL(s) = (2*4 - dataAIC(s))/2;
        plot(dataLL,rLL,'b.')
        %plot(model{m,s,c}.AIC,AIC(m,:,m,c,s),'b.'); % model{m,s,c}   AIC(m,j,m_gen,c,s) 
    end
end
axis equal
plot([-350 0],[-350 0],'k')
 
%4-day prac condition
subplot(1,3,3); hold on
m=2; c=3;
for s=1:24
    if(~isempty(model{m,s,c}))
        rAIC(s,:) = AIC(m,:,m,c,s);
        dataAIC(s) = model{m,s,c}.AIC;
        rLL(s,:) = (2*4 - rAIC(s,:))/2;
        dataLL(s) = (2*4 - dataAIC(s))/2;
        plot(dataLL,rLL,'b.')
        %plot(model{m,s,c}.AIC,AIC(m,:,m,c,s),'b.'); % model{m,s,c}   AIC(m,j,m_gen,c,s) 
    end
end
axis equal
plot([-350 0],[-350 0],'k')
    