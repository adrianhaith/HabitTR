% test parameter recovery - focus on showing that rho can be accurately
% estimated
addpath ../
clear all
load HabitModelFits_U
optimizer = 'fmincon'; % 'bads' or 'fmincon'
tic
%%
Nsamps = 10;
mod = 2;
linesty = {'b.','r.','g.'};
for c = 2:3; % condition
    for s = 1:24; % subject
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
            params_original(s,:,c) = model{mod,s,c}.paramsOpt;
            %params_original(s,7) = 1;
            % get parameter fits for this participant:
            %like_fun = @(params) habit_lik(data(s,c).RT,data(s,c).response,params,model_type);
            %habit_lik(data(s,c).RT,data(s,c).response,paramsInit,model_type);
            %params_original = fmincon(like_fun,paramsInit,A,B,Aeq,Beq,LB,UB);
            
            % generate predictions for these parameters
            xplot = [0.001:.001:1.2];
            pr_original(:,:,s) = model{mod,s,c}.presponse;
            
            pr = getResponseProbs_U(RT,params_original(s,:,c),2);
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
                pConstr = NaN*ones(1,8); % parameter to constrain
                if (mod==2)
                    pConstr(7) = 1; % assume habit model, not flex-habit
                else
                    pContr = [0 0 NaN NaN NaN NaN 0 1];
                end
                model_refit(j) = fit_model(RT,response(:,j),pConstr,optimizer); % 'flex' model
                params_fit(j,:) = model_refit(j).paramsOpt;
                presponse_recov(:,:,j,s) = model_refit(j).presponse;
                
                %like_fun = @(params) habit_lik(RT,response(:,j),params,model_type);
                % equality constraints
                
                
                % do optimization
                %params_fit(j,:) = fmincon(like_fun,paramsInit,A,B,Aeq,Beq,LB,UB);
                %presponse_recov(:,:,j) = getResponseProbs(xplot,params_fit(j,:),model_type)
            end
            params_recov(:,:,s,c) = params_fit;
        else
            params_recov(:,:,s,c) = NaN;
            params_original(s,:,c) = NaN;
        end
    end
end

%% plot results
fhandle = figure(31); clf; hold on
set(fhandle, 'Position', [300, 200, 900, 400]); % set size and loction on screen
set(fhandle, 'Color','w') % set background color to white
param_names = {'\mu_1','\sigma_1','\mu_2','\sigma_2','q_B','q_I','rho1','\rho'};
ticks ={[.2 .3 .4 .5 .6 .7 .8], [0 .05 .1 .15], [.2 .3 .4 .5 .6 .7 .8], [0 .05 .1 .15],[0.5 .6 .7 .8 .9 1], [0 .1 .2 .3 .4],[0 1],[.6 .7 .8 .9 1]};
            
for pp=1:8
    subplot(2,4,pp); hold on
    title(param_names{pp},'fontsize',12)
    axmin = min(ticks{pp});
    axmax = max(ticks{pp});
    for c=2:3
        %
        
        
        
        plot([axmin axmax ], [axmin axmax],'k')
        for s=1:24
            plot(params_original(s,pp,c),params_recov(:,pp,s,c),linesty{c},'markersize',8)
        end
        
        pV_recov{c} = reshape(squeeze(params_recov(:,pp,:,c))',[240 1]);
        pV_orig{c} = repmat(params_original(:,pp,c),10,1);
        
        
        %param_corr(pp) = corr(pV_recov(~isnan(pV_recov)),pV_orig(~isnan(pV_recov)));
        %text(axmin,axmax,['\rho = ',num2str(param_corr(pp))])
        
        
        
        %axis square
        
    end
    xticks(ticks{pp})
    yticks(ticks{pp})
    axis equal
    
    pV_recov_all = [pV_recov{2}; pV_recov{3}];
    pV_orig_all = [pV_orig{2}; pV_orig{3}];
    param_corr(pp) = corr(pV_recov_all(~isnan(pV_recov_all)),pV_orig_all(~isnan(pV_recov_all)));
    text(axmin,axmax,['\rho = ',num2str(param_corr(pp))])
end

%%
figure(21); clf; hold on
for s=1:24
    subplot(6,4,s); hold on
    if(~isempty(data(s,c).RT))
        plot(xplot,squeeze(presponse_recov(1,:,:,s)),'b');
        plot(xplot,squeeze(presponse_recov(2,:,:,s)),'r');
        plot(xplot,squeeze(presponse_recov(3,:,:,s)),'m');
        plot(xplot,squeeze(presponse_recov(4,:,:,s)),'b:');
        plot(xplot,data(s,c).sliding_window(1,:,:),'b');
        
        plot(xplot,pr_original(1,:,s),'k','linewidth',1)
        plot(xplot,pr_original(2,:,s),'k','linewidth',1)
        plot(xplot,pr_original(3,:,s),'k','linewidth',1)
    end
end
%plot(xplot,data_recov.sw')
%}
%%



toc