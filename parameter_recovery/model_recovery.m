% model recovery analysis

addpath ../
clear all
load HabitModelFits_U
optimizer = 'fmincon'; % 'bads' or 'fmincon'
tic
%%
Nsamps = 100;
for c = 1:3; % condition
    s = 3; % subject
    
    for m_gen=1:3
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
            
            for m=1:3
                % no-habit model
                
                model_refit{m}(j) = fit_model(RT,response(:,j),pConstr(m,:),optimizer); % 'flex' model
                params_fit(j,:,m) = model_refit{m}(j).paramsOpt;
                presponse_recov(:,:,j,m) = model_refit{m}(j).presponse;
                AIC(m,j,m_gen,c) = model_refit{m}(j).AIC;
            end
            
            %like_fun = @(params) habit_lik(RT,response(:,j),params,model_type);
            % equality constraints
            
            
            % do optimization
            %params_fit(j,:) = fmincon(like_fun,paramsInit,A,B,Aeq,Beq,LB,UB);
            %presponse_recov(:,:,j) = getResponseProbs(xplot,params_fit(j,:),model_type)
            
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
    for c=1:3
        for m_gen = 1:3
            [xx m_best(m_gen,:,c)] = min(AIC(:,:,m_gen,c));
        end
        
        for m_gen=1:3
            for m=1:3
                mConfusion(m_gen,m,c) = sum(m_best(m_gen,:,c)==m)/Nsamps;
            end
        end
    end
    figure(4); clf; hold on
    for c=1:3
        subplot(1,3,c); hold on
        mCflip = flipud(mConfusion(:,:,c));
        imagesc(flipud(mConfusion(:,:,c)))
        for i=1:3
            for j=1:3
                text(i,j,num2str(mCflip(j,i)))
            end
        end
        axis equal
    end
