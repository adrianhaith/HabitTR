% make fig 3 for Hardwick et al. AVMA habit paper
clear all
load HabitModelFits_U
load model_pooled

fhandle = figure(3); clf; hold on
    set(fhandle, 'Position', [200, 100, 1200, 350]); % set size and loction on screen
    set(fhandle, 'Color','w') % set background color to white

%% Iterate through conditions
i_model = [1 2 2];
for c=1:3
    subplot(1,3,c); hold on
    
    p_corr_consistent{c} = [];
    p_corr_remapped{c} = [];
    p_habit{c} = [];
    
    pm_corr_consistent{c} = [];
    pm_corr_remapped{c} = [];
    pm_habit{c} = [];    
    
    for i=1:24
        if(~isempty(data(i,c).RT))
            p_corr_consistent{c} = [p_corr_consistent{c}; data(i,c).sliding_window(4,:)];
            p_corr_remapped{c} = [p_corr_remapped{c}; data(i,c).sliding_window(1,:)];
            p_habit{c} = [p_habit{c}; data(i,c).sliding_window(2,:)];
            
            pm_corr_remapped{c} = [pm_corr_remapped{c}; model{i_model(c),i,c}.presponse(1,:)];
            pm_habit{c} = [pm_habit{c}; model{i_model(c),i,c}.presponse(2,:)];
            pm_corr_consistent{c} = [pm_corr_consistent{c}; model{i_model(c),i,c}.presponse(4,:)];
        end
    end
    
    
    xplot = [1:1200];
    shadedErrorBar(xplot,mean(p_corr_consistent{c}),seNaN(p_corr_consistent{c}),'m')
    shadedErrorBar(xplot,mean(p_corr_remapped{c}),seNaN(p_corr_consistent{c}),'b')
    shadedErrorBar(xplot,mean(p_habit{c}),seNaN(p_corr_consistent{c}),'r')
    
    %plot(xplot,data_all(c).sw(1,:),'k','linewidth',2)
    %plot(xplot,data_all(c).sw(2,:),'r','linewidth',2)
    %plot(xplot,data_all(c).sw(4,:),'b','linewidth',2)
    xlim([0 1200])
    ylim([0 1])
    
    %plot(xplot,model_pooled(1,1).presponse(4,:),'k','linewidth',2)
    %plot(xplot,model_pooled(i_model(c),c).presponse(1,:),'b:','linewidth',3)
    %plot(xplot,model_pooled(i_model(c),c).presponse(2,:),'r:','linewidth',3)
    
    plot(xplot,nanmean(pm_corr_remapped{c}),'b','linewidth',3)
    plot(xplot,nanmean(pm_habit{c}),'r','linewidth',3)
    plot(xplot,nanmean(pm_corr_consistent{c}),'m','linewidth',3)
    
end

%% direct comparison of habit height across conditions
fhandle = figure(4); clf; hold on
    set(fhandle, 'Position', [200, 100, 700, 300]); % set size and loction on screen
    set(fhandle, 'Color','w') % set background color to white

   
colsc = linspace(0.2,1,3)';
z = 0*colsc;
col_b = [z z colsc];  
col_r = [colsc z z];
cols = {'r','g','b'}
subplot(1,2,1); hold on
for c=1:3
    shadedErrorBar(xplot,nanmean(p_corr_remapped{c}),seNaN(p_corr_remapped{c}),'b')
end
for c=1:3
    shadedErrorBar(xplot,nanmean(p_habit{c}),seNaN(p_habit{c}),'r')
end

%plot(xplot,nanmean(p_habit{1}),'k')

subplot(1,2,2); hold on
for c=1:3
    plot(xplot,nanmean(pm_corr_remapped{c}),'b','linewidth',2)
end
for c=1:3
    plot(xplot,nanmean(pm_habit{c}),'r','linewidth',2) 
end


