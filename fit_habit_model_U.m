% fit models to habit data
%
% model 1 = habit model - assume
%
clear all

optimizer= 'bads'; % 'bads' or 'fmincon'

% load data
load HabitData;

for c = 1:3 % 1=minimal, 2=4day, 3=4week
    for subject = 1:size(data,1)
        if (~isempty(data(subject,c).RT)) % if this subject is not already excluded
            for m=1:3
                % set up and fit each model
                switch(m)
                    case 1;
                        Nprocesses = 2;
                        constrained_params = [NaN*ones(1,6) 0];
                    case 2;
                        Nprocesses = 2;
                        constrained_params = [NaN*ones(1,6) 1];
                    case 3;
                        Nprocesses = 2;
                        constrained_params = NaN*ones(1,7);
                end
                %habit_lik(data(subject,c).RT,data(subject,c).response,params,model(m).name);
                model{m,subject,c} = fit_model(data(subject,c).RT,data(subject,c).response,Nprocesses,constrained_params,0,optimizer);
                
                %[model(m).paramsOpt(subject,:,c), model(m).LLopt(c,subject)] = fmincon(like_fun,paramsInit,A,B,Aeq,Beq,LB,UB);
                
                
                
                % get full likelihood vector
                %[~, model(m).Lv{subject,c}, model(m).LL] = like_fun(model(m).paramsOpt(subject,:,c));
            end
            
            % generate continuous model predictions
            %for m=1:3
            %    model(m).presponse(:,:,c,subject) = getResponseProbs(model(m).RTplot,model(m).paramsOpt(subject,:,c),model(m).name);
            %end
            
            % fit no-habit model to non-remapped symbols
            %model(4).name = 'non-remapped';
            %like_fun = @(params) habit_lik(data(subject,c).RT_unchanged,data(subject,c).response_unchanged,params,'no-habit');
            %[model(4).paramsOpt(subject,:,c), model(4).LLopt(c,subject)] = fmincon(like_fun,paramsInit,A,B,[],[],LB,UB);
            %[~, model(4).Lv{subject,c}] = like_fun(model(4).paramsOpt(subject,:,c));
            %model(4).presponse(:,:,c,subject) = getResponseProbs(model(4).RTplot,model(4).paramsOpt(subject,:,c),'no-habit');
        end
    end
end



%% model comparison
% set likelihood to NaN's for missing data
for c=1:3
    for subject=1:24
        if(~isempty(data(subject,c).RT))
            nParams = [4,6,7]; % 4 params for no-habit model(muB,sigmaB,q_init,q_B)
            % + 2 for habit (muA,sigmaA)
            % + 1 for flex-habit (rho)
            for m=1:3
                %model{m,s,c}.LLactual(c,subject) = sum(log(model(m).Lv{subject,c})); % compute actual (unpenalized) log-likelihood
                model{m,subject,c}.AIC = 2*nParams(m) - 2*model{m,subject,c}.LL;
            end
            %AIC(c,subject,2) = 2*4 - 2*sum(model(2).LLv{c,subject};
            %AIC(c,subject,3) = 2*8 - 2*sum(model(3).LLv{c,subject};
        else
            for m=1:3
                model{m,subject,c}.AIC = NaN;
                model{m,subject,c}.LLopt=NaN;
                model{m,subject,c}.LLactual=NaN;
            end
        end
    end
end

%{
% compare likelihoods
figure(100); clf; hold on
for c=1:3
    subplot(1,3,c); hold on
    plot(model(2).LLactual(c,:)-model(1).LLactual(c,:),'.','markersize',20)
    axis([0 25 -10 40])
end

% compare AIC
figure(101); clf;
for c=1:3
    subplot(1,3,c); hold on
    title(cond_str{c})
    plot(model(2).AIC(c,:)-model(1).AIC(c,:),'.','markersize',20)
    
    plot([0 25],[0 0],'k')
    axis([0 25 -20 70])
    ylabel('\Delta AIC')
    xlabel('Subject #')
    
end
%}
%{
dAIC12 = model(2).AIC-model(1).AIC;

figure(102); clf; hold on
plot(nanmean(dAIC12'),'.','markersize',20)
plot([1 1; 2 2; 3 3]',[nanmean(dAIC12')+seNaN(dAIC12');nanmean(dAIC12')-seNaN(dAIC12')],'b-')
plot([0 4],[0 0],'k')
xlim([.5 3.5])
ylabel('Average \Delta AIC')
xlabel('condition')
%}
%%
% change saved filename depending on which optimization procedure was used
switch (optimizer)
    case 'bads'
        save HabitModelFits_bads_U model data
    case 'fmincon'
        save HabitModelFits_U model data
end