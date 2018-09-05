% fit habit model to consistently mapped stimuli
clear all
load HabitData

for s=1:24
    for c=1:3
        if(~isempty(data(s,c).RT))
            model_unchanged(s,c) = fit_model(data(s,c).RT_unchanged,(data(s,c).response_unchanged>1)+1,1);
            
            % constrain initAE
            %model_unchanged_constrained(s,c) = fit_model(data(s,c).RT_unchanged,(data(s,c).response_unchanged>1)+1,1,[NaN NaN 1 .25])
        end
    end
end

%{
figure(2); clf; hold on
plot(model_unchanged(s,c).xplot,data(s,c).sliding_window(4,:),'b')
plot(model_unchanged(s,c).xplot,data(s,c).sliding_window(2,:)+2*data(s,c).sliding_window(3,:),'r')

plot(model_unchanged(s,c).xplot,model_unchanged(s,c).presponse(1,:))
plot(model_unchanged(s,c).xplot,model_unchanged(s,c).presponse(2,:))

plot(model_unchanged_constrained(s,c).xplot,model_unchanged_constrained(s,c).presponse(1,:),'--');
plot(model_unchanged_constrained(s,c).xplot,model_unchanged_constrained(s,c).presponse(2,:),'--');
%}
%% fit two-process model

for s=1:24
    for c=1:3
        if(~isempty(data(s,c).RT))
            constrained_params = NaN*ones(1,6);
            %constrained_params(1:2) = model_unchanged(s,c).paramsOpt(1:2);
            
            model(s,c) = fit_model(data(s,c).RT,data(s,c).response,2,NaN*ones(1,8),0);
            %model_constrained(s,c) = fit_model(data(s,c).RT,data(s,c).response,2,[constrained_params 1]);
            model_constrained_simp(s,c) = fit_model(data(s,c).RT,data(s,c).response,2,[constrained_params 1 NaN],1);
            model_constrained_simp_flex(s,c) = fit_model(data(s,c).RT,data(s,c).response,2,[constrained_params NaN NaN],1);
        end
    end
end

save Habit_data_constrained_fits

%%
for c=1:3
    for s=1:24
        if(~isempty(data(s,c).RT))
            rho_unconstrained(s,c) = model_constrained_simp_flex(s,c).paramsOpt(end-1);
            rho_constrained(s,c) = model_constrained_simp(s,c).paramsOpt(end-1);
        else
            rho_constrained(s,c) = NaN;
            rho_unconstrained(s,c) = NaN;
        end
    end
end

%%

%{
figure(1); clf; hold on
c=2;
for s=1:24
    if(~isempty(data(s,c).RT))
        subplot(4,6,s); hold on
        plot(xplot,data(s,c).sliding_window(1,:),'b')
        plot(xplot,data(s,c).sliding_window(2,:),'r')
        plot(xplot,data(s,c).sliding_window(3,:),'m')
        
        plot(xplot,model_constrained(s,c).presponse(1,:),'b')
        plot(xplot,model_constrained(s,c).presponse(2,:),'r')
        plot(xplot,model_constrained(s,c).presponse(3,:)/2,'m')
        
        plot(xplot,model(s,c).presponse(1,:),'b--')
        plot(xplot,model(s,c).presponse(2,:),'r--')
        plot(xplot,model(s,c).presponse(3,:)/2,'m--')
        
        plot(xplot,data(s,c).sliding_window(4,:),'color',[1 .5 .5])
    end
end
%plot(model(2).xplot,model(2).presponse(1,:),'b')
%plot(model(2).xplot,model(2).presponse(2,:),'r')
%plot(model(2).xplot,model(2).presponse(3,:)/2,'m')
%}
%% plot average fits
%
for c=1:3
    for s=1:24
        for i=1:5
            if(~isempty(data(s,c).RT))
                %presponse_all(s,:,c,i) = model(s,c).presponse(i,:);
                %presponse_constr_all(s,:,c,i) = model_constrained(s,c).presponse(i,:);
                presponse_constr_simp_all(s,:,c,i) = model_constrained_simp(s,c).presponse(i,:);
                presponse_constr_simp_flex_all(s,:,c,i) = model_constrained_simp_flex(s,c).presponse(i,:);
                if(i<5)
                    sw_all(s,:,c,i) = data(s,c).sliding_window(i,:);
                end
            else
                %presponse_all(s,:,c,i) = NaN;
                %presponse_constr_all(s,:,c,i) = NaN;
                presponse_constr_simp_all(s,:,c,i) = NaN;
                presponse_constr_simp_flex_all(s,:,c,i) = NaN;
                sw_all(s,:,c,i) = NaN;
            end
        end
    end
end
%}
%%
xplot = model_constrained_simp(1,1).xplot;
figure(2); clf; hold on
for c=1:3
    subplot(2,3,c); hold on
    %plot(xplot,nanmean(presponse_all(:,:,c,1)),'b')
    %plot(xplot,nanmean(presponse_all(:,:,c,2)),'r')
    %plot(xplot,nanmean(presponse_all(:,:,c,3))/2,'m')
    
    plot(xplot,nanmean(presponse_constr_simp_flex_all(:,:,c,1)),'b')
    plot(xplot,nanmean(presponse_constr_simp_flex_all(:,:,c,2)),'r')
    plot(xplot,nanmean(presponse_constr_simp_flex_all(:,:,c,3))/2,'m')
    plot(xplot,nanmean(presponse_constr_simp_flex_all(:,:,c,4)),'k')
    plot(xplot,nanmean(presponse_constr_simp_flex_all(:,:,c,5)),'c')
    
    plot(xplot,nanmean(presponse_constr_simp_all(:,:,c,1)),'b--')
    plot(xplot,nanmean(presponse_constr_simp_all(:,:,c,2)),'r--')
    plot(xplot,nanmean(presponse_constr_simp_all(:,:,c,3))/2,'m--')
    plot(xplot,nanmean(presponse_constr_simp_all(:,:,c,4)),'k--')
    plot(xplot,nanmean(presponse_constr_simp_all(:,:,c,5)),'c--')
    
    plot(xplot,nanmean(sw_all(:,:,c,1)),'b')
    plot(xplot,nanmean(sw_all(:,:,c,2)),'r')
    plot(xplot,nanmean(sw_all(:,:,c,3)),'m')
    
    subplot(2,3,c+3); hold on
    %plot(xplot,nanmean(presponse_all(:,:,c,1)+presponse_all(:,:,c,3)),'b')
    %plot(xplot,nanmean(presponse_all(:,:,c,2)),'r')
    %plot(xplot,nanmean(presponse_all(:,:,c,3))/2,'m')

    plot(xplot,nanmean(presponse_constr_simp_flex_all(:,:,c,1)+presponse_constr_simp_flex_all(:,:,c,3)),'b')
    plot(xplot,nanmean(presponse_constr_simp_flex_all(:,:,c,2)),'r')    
    
    plot(xplot,nanmean(presponse_constr_simp_all(:,:,c,1)+presponse_constr_simp_all(:,:,c,3)),'b--')
    plot(xplot,nanmean(presponse_constr_simp_all(:,:,c,2)),'r--')  
    
    plot(xplot,nanmean(sw_all(:,:,c,1)+2*sw_all(:,:,c,3)),'b')
    plot(xplot,nanmean(sw_all(:,:,c,2)),'r')
    %plot(xplot,nanmean(sw_all(:,:,c,3)),'m') 
end

%{
figure(3); clf; hold on
for c=1:3
    subplot(2,3,c); hold on
    plot(xplot,nanmean(presponse_constr_simp_all(:,:,c,1)),'b')
    plot(xplot,nanmean(presponse_constr_simp_all(:,:,c,2)),'r')
    plot(xplot,nanmean(presponse_constr_simp_all(:,:,c,3))/2,'m')
    
    plot(xplot,nanmean(sw_all(:,:,c,1)),'b')
    plot(xplot,nanmean(sw_all(:,:,c,2)),'r')
    plot(xplot,nanmean(sw_all(:,:,c,3)),'m')
    
    subplot(2,3,c+3); hold on
    plot(xplot,nanmean(presponse_constr_simp_all(:,:,c,1)+presponse_constr_all(:,:,c,3)),'b')
    plot(xplot,nanmean(presponse_constr_all(:,:,c,2)),'r')
    %plot(xplot,nanmean(presponse_all(:,:,c,3))/2,'m')
    
    plot(xplot,nanmean(sw_all(:,:,c,1)+2*sw_all(:,:,c,3)),'b')
    plot(xplot,nanmean(sw_all(:,:,c,2)),'r')
    %plot(xplot,nanmean(sw_all(:,:,c,3)),'m') 
end
%}

%% extract likelihoods/AICs

for c=1:3
    for s=1:24
        if(~isempty(data(s,c).RT))
            likelihood_flex(s,c) = model_constrained_simp_flex(s,c).LL;
            likelihood(s,c) = model_constrained_simp(s,c).LL;
        else
            likelihood_flex(s,c) = NaN;
            likelihood(s,c) = NaN;
        end
    end
end

figure(4); clf; hold on
for c=1:3
    subplot(1,3,c); hold on
    plot(likelihood(:,c),likelihood_flex(:,c),'.','markersize',15)
    plot([-150 -40],[-150 -40],'k')
    axis equal
    
end

%% inspect flex fits versus constrained fits
%
figure(3); clf; hold on
c=3;
for s=1:24
    if(~isempty(data(s,c).RT))
        subplot(2,1,1);
        cla; hold on
        plot(xplot,data(s,c).sliding_window(1,:),'b')
        plot(xplot,data(s,c).sliding_window(2,:),'r')
        plot(xplot,data(s,c).sliding_window(3,:),'m')
        %plot(
        
        plot(xplot,model_constrained_simp(s,c).presponse(1,:),'b--')
        plot(xplot,model_constrained_simp(s,c).presponse(2,:),'r--')
        plot(xplot,model_constrained_simp(s,c).presponse(3,:)/2,'m--')
        plot(xplot,model_constrained_simp(s,c).presponse(4,:),'k--')
        plot(xplot,model_constrained_simp(s,c).presponse(5,:),'c--')
        
        plot(xplot,model_constrained_simp_flex(s,c).presponse(1,:),'b')
        plot(xplot,model_constrained_simp_flex(s,c).presponse(2,:),'r')
        plot(xplot,model_constrained_simp_flex(s,c).presponse(3,:)/2,'m')
        plot(xplot,model_constrained_simp_flex(s,c).presponse(5,:),'c')
        
        disp(['subject ',num2str(s)])
        
        subplot(2,1,2); cla; hold on
        plot(xplot,data(s,c).sliding_window(1,:)+2*data(s,c).sliding_window(3,:),'b')
        plot(xplot,data(s,c).sliding_window(2,:),'r')
        %plot(xplot,data(s,c).sliding_window(3,:),'m')
        %plot(
        
        plot(xplot,model_constrained_simp(s,c).presponse(1,:)+model_constrained_simp(s,c).presponse(3,:),'b--')
        plot(xplot,model_constrained_simp(s,c).presponse(2,:),'r--')
        %plot(xplot,model_constrained_simp(s,c).presponse(3,:)/2,'m--')
        plot(xplot,model_constrained_simp(s,c).presponse(4,:),'k--')
        plot(xplot,model_constrained_simp(s,c).presponse(5,:),'c--')
        
        plot(xplot,model_constrained_simp_flex(s,c).presponse(1,:)+model_constrained_simp_flex(s,c).presponse(3,:),'b')
        plot(xplot,model_constrained_simp_flex(s,c).presponse(2,:),'r')
        %plot(xplot,model_constrained_simp_flex(s,c).presponse(3,:)/2,'m')
        
        
        pause
    end
end
%}
%%
% sliding window on model liklihoood
for c=1:3
    for s=1:24
        [model_constrained_simp(s,c).likelihood_sw model_constrained_simp_flex(s,c).N] = sliding_window(data(s,c).RT,model_constrained_simp(s,c).Lv,xplot,.025);
        [model_constrained_simp_flex(s,c).likelihood_sw model_constrained_simp_flex(s,c).N] = sliding_window(data(s,c).RT,model_constrained_simp_flex(s,c).Lv,xplot,.025);
        
    end
end
        
%%
figure(4); clf; hold on
c=3;
for s=1:24
    if(~isempty(data(s,c).RT))
        subplot(3,1,1);
        cla; hold on
        plot(xplot,data(s,c).sliding_window(1,:)+2*data(s,c).sliding_window(3,:),'b')
        plot(xplot,data(s,c).sliding_window(2,:),'r')
        plot(xplot,model_constrained_simp(s,c).presponse(1,:)+model_constrained_simp(s,c).presponse(3,:),'b--')
        plot(xplot,model_constrained_simp(s,c).presponse(2,:),'r--')
        plot(xplot,model_constrained_simp_flex(s,c).presponse(1,:)+model_constrained_simp_flex(s,c).presponse(3,:),'b')
        plot(xplot,model_constrained_simp_flex(s,c).presponse(2,:),'r')
        disp(['s = ',num2str(s)]);
        disp(['Delta LL = ',num2str(model_constrained_simp(s,c).LL - model_constrained_simp_flex(s,c).LL)])
        
        subplot(3,1,2);
        cla; hold on
        plot(data(s,c).RT,model_constrained_simp_flex(s,c).Lv,'.')
        plot(data(s,c).RT,model_constrained_simp(s,c).Lv,'r.')
        xlim([0 1.2])
        
        subplot(3,1,3);
        cla; hold on
        plot(xplot,model_constrained_simp_flex(s,c).likelihood_sw,'b')
        plot(xplot,model_constrained_simp(s,c).likelihood_sw,'r')
        plot(xplot,model_constrained_simp_flex(s,c).N/100,'color',.5*[1 1 1])
        %pause
    end
end

%% compute AIC
nParams = 4;
nParams_flex = 5;
for c=1:3
    for s=1:24
        if(~isempty(data(s,c).RT))
            model_constrained_simp(s,c).LLactual = sum(log(model_constrained_simp(s,c).Lv)); % compute actual (unpenalized) log-likelihood
            AIC(s,c) = 2*nParams - 2*model_constrained_simp(s,c).LLactual;
            
            model_constrained_simp_flex(s,c).LLactual = sum(log(model_constrained_simp_flex(s,c).Lv)); % compute actual (unpenalized) log-likelihood
            AIC_flex(s,c) = 2*nParams_flex - 2*model_constrained_simp_flex(s,c).LLactual;
        else
            AIC(s,c) = NaN;
            AIC_flex(s,c) = NaN;
        end
    end
end
dAIC = AIC-AIC_flex;
%%
figure(11); clf; hold on
col = {'r.','g.','b.'};
for c=1:3
    plot(c-.25+.5*[1:24]/24,dAIC(:,c),col{c},'markersize',16)
    plot([0 4],[0 0],'k')
end

%% correlate rho parameter with skill
figure(12); clf; hold on
for c=1:3
    for s=1:24
        if(~isempty(data(s,c).RT))
            plot(dAIC(s,c),model_unchanged(s,c).paramsOpt(1),col{c})
        end
    end
end
            
%% plot skill/habit figure
for c=1:3
    for s=1:24
        if(~isempty(data(s,c).RT))
            skill(s,c) = model_unchanged(s,c).paramsOpt(1);
            skill2(s,c) = model_unchanged(s,c).paramsOpt(2);
        else
            skill(s,c) = NaN;
            skill2(s,c) = NaN;
        end
    end
end

figure(13); clf; hold on
subplot(1,2,1); hold on
plot(nanmean(rho_unconstrained),nanmean(skill),'.-','markersize',20)
plot(rho_unconstrained,skill,'.','markersize',20)
xlabel('habit')
ylabel('skill')

subplot(1,2,2); hold on
plot(nanmean(rho_unconstrained),nanmean(skill2),'.-','markersize',20)
plot(rho_unconstrained,skill2,'.','markersize',20)
xlabel('habit')
ylabel('skill')

%
figure(14); clf; hold on
subplot(1,2,1); hold on
plot(nanmean(dAIC),nanmean(skill),'.-','markersize',20)
plot(dAIC,skill,'.','markersize',20)
xlabel('habit')
ylabel('skill')

subplot(1,2,2); hold on
plot(nanmean(dAIC),nanmean(skill2),'.-','markersize',20)
plot(dAIC,skill2,'.','markersize',20)
xlabel('habit')
ylabel('skill')

%%

% test free model
figure(1); clf; hold on
c=3;
for s=1:24
    if(~isempty(data(s,c).RT))
        clf; hold on
        plot(xplot,data(s,c).sliding_window(1,:),'b')
        plot(xplot,data(s,c).sliding_window(2,:),'r')
        plot(xplot,data(s,c).sliding_window(3,:),'m')
        
        plot(xplot,model(s,c).presponse(1,:),'b')
        plot(xplot,model(s,c).presponse(2,:),'r')
        plot(xplot,model(s,c).presponse(3,:)/2,'m')
        
        pause
    end
end

%%
for c=1:3
    for s=1:24
        if(~isempty(data(s,c).RT))
            rho_full(s,c) = model(s,c).paramsOpt(7);
        else
            rho_full(s,c) = NaN;
        end
    end
end    

figure(2); clf; hold on
for c=1:3
    plot(c-.25+.5*[1:24]/24,rho_full(:,c),'.','markersize',15)
end
