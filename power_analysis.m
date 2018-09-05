clear all
close all
load HabitData

% habit index
% plot habit / other
col = {'r','g','b'};

%figure(111); clf; hold on
for c=1:3

    for s=1:24
        if(~isempty(data(s,c).RT))
            data(s,c).habit_index = data(s,c).sliding_window(2,:)-data(s,c).sliding_window(3,:);
            %subplot(3,3,c); hold on
            %plot(data(s,c).habit_index,'k')
            
            habit_index(s,:,c) = data(s,c).habit_index;
            habit_err(s,:,c) = data(s,c).sliding_window(2,:);
            other_err(s,:,c) = data(s,c).sliding_window(3,:);
            
            %subplot(3,3,c+3); hold on
            %plot(data(s,c).sliding_window(2,:),'b')
            %plot(data(s,c).sliding_window(3,:),'y')
            
        else
            habit_index(s,:,c) = NaN;
            habit_err(s,:,c) = NaN;
            other_err(s,:,c) = NaN;
        end
    end
    
    % tidy up zeros
    %subplot(3,3,c+6); hold on
    %shadedErrorBar([],nanmean(habit_err(:,:,c)),seNaN(habit_err(:,:,c)),col{c})
    %shadedErrorBar([],nanmean(other_err(:,:,c)),seNaN(other_err(:,:,c)),'k')
    %axis([0 1200 -.1 1])
end

figure(112); clf; hold on
subplot(1,3,1); hold on
title('habit index')
shadedErrorBar([],nanmean(habit_index(:,:,1)),seNaN(habit_index(:,:,1)),'r')
shadedErrorBar([],nanmean(habit_index(:,:,2)),seNaN(habit_index(:,:,2)),'g')
shadedErrorBar([],nanmean(habit_index(:,:,3)),seNaN(habit_index(:,:,3)),'b')
axis([0 1200 -.1 1])

subplot(1,3,2); hold on
title('habit error')
shadedErrorBar([],nanmean(habit_err(:,:,1)),seNaN(habit_err(:,:,1)),'r')
shadedErrorBar([],nanmean(habit_err(:,:,2)),seNaN(habit_err(:,:,2)),'g')
shadedErrorBar([],nanmean(habit_err(:,:,3)),seNaN(habit_err(:,:,3)),'b')
axis([0 1200 -.1 1])

subplot(1,3,3); hold on
title('other error')
shadedErrorBar([],nanmean(other_err(:,:,1)),seNaN(other_err(:,:,1)),'r')
shadedErrorBar([],nanmean(other_err(:,:,2)),seNaN(other_err(:,:,2)),'g')
shadedErrorBar([],nanmean(other_err(:,:,3)),seNaN(other_err(:,:,3)),'b')
axis([0 1200 -.1 1])


figure()


%{
figure(113); clf; hold on
for c=1:3
subplot(1,3,c); hold on
shadedErrorBar([],nanmean(habit_err(:,:,c)),seNaN(habit_err(:,:,c)),col{c})
shadedErrorBar([],nanmean(other_err(:,:,c)),seNaN(other_err(:,:,c)),col{c})
axis([0 1200 0 .5])
end
%}
%%
%figure(114); clf; hold on
%plot(habit_index(:,:,2)')

%% normalize and plot
rng = 1:200; % range to calculate baseline selection probability
for c=1:3
    for s=1:24
        if(~isempty(data(s,c).RT))
            bsl_prob_habit(s,c) = nanmean(data(s,c).sliding_window(2,rng));
            bsl_prob_other(s,c) = nanmean(data(s,c).sliding_window(3,rng));
        end
    end
end
%{
figure(116); clf; hold on
for s=1:24
    subplot(4,6,s); hold on
    if(~isempty(data(s,1).RT))
        plot(.25*data(s,1).sliding_window(2,:)/bsl_prob_habit(s,1),'r')
        plot(.25*data(s,1).sliding_window(3,:)/bsl_prob_other(s,1),'k')
        plot([0 1200],[.25 .25],'k:')
        axis([0 1200 0 1])
    end
end
%}
%{
figure(117); clf; hold on
for s=1:24
    subplot(4,6,s); hold on
    if(~isempty(data(s,2).RT))
        plot(.25*data(s,2).sliding_window(2,:)/bsl_prob_habit(s,2),'r')
        plot(.25*data(s,2).sliding_window(3,:)/bsl_prob_other(s,2),'k')
        plot([0 1200],[.25 .25],'k:')
        axis([0 1200 0 1])
    end
end
%}
%{
figure(118); clf; hold on
for s=1:24
    subplot(4,6,s); hold on
    if(~isempty(data(s,3).RT))
        plot(.25*data(s,3).sliding_window(2,:)/bsl_prob_habit(s,3),'r')
        plot(.25*data(s,3).sliding_window(3,:)/bsl_prob_other(s,3),'k')
        plot([0 1200],[.25 .25],'k:')
        axis([0 1200 0 1])
    end
end
%}
%% compute plot normalized habit index
%figure(119); clf; hold on
HI_rng = [300:600];
for c=1:3
    for s=1:24
        if(~isempty(data(s,c).RT))
            data(s,c).habit_index_norm = .25*(habit_err(s,:,c)/bsl_prob_habit(s,c) - other_err(s,:,c)/bsl_prob_other(s,c));
            habit_index_norm(s,:,c) = data(s,c).habit_index_norm;
            habit_index_norm_av(s,c) = nanmean(habit_index_norm(s,HI_rng,c));
            habit_index_av(s,c) = nanmean(habit_index(s,HI_rng,c));
        else
            habit_index_norm(s,:,c) = NaN;
            habit_index_norm_av(s,c) = NaN;
            habit_index_av(s,c) = NaN; 
        end
    end
    %subplot(1,3,c); hold on
    %plot(habit_index_norm(:,:,c)');
    
end
%%
figure(120); clf; hold on
subplot(1,2,1); hold on
title('non-normalized habit index (300-600ms)')
plot(1+.5*rand(1,24)-.25,habit_index_av(:,1),'r.','markersize',15)
plot(2+.5*rand(1,24)-.25,habit_index_av(:,2),'g.','markersize',15)
plot(3+.5*rand(1,24)-.25,habit_index_av(:,3),'b.','markersize',15)

plot([1 1],nanmean(habit_index_av(:,1))*[1 1]+seNaN(habit_index_av(:,1))*[-1 1],'r','linewidth',3)
plot(2*[1 1],nanmean(habit_index_av(:,2))*[1 1]+seNaN(habit_index_av(:,2))*[-1 1],'g','linewidth',3)
plot(3*[1 1],nanmean(habit_index_av(:,3))*[1 1]+seNaN(habit_index_av(:,3))*[-1 1],'b','linewidth',3)

igood = find(~isnan(habit_index_av(:,1)));
plot([0.5 3.5],(nanmean(habit_index_av(:,1))+2*std(habit_index_av(igood,1)))*[1 1],'r:')

% same but for index normalized to baseline selection probability
subplot(1,2,2); hold on
title('normalized habit index (norm. to 0-200ms)')
plot(1+.5*rand(1,24)-.25,habit_index_norm_av(:,1),'r.','markersize',15)
plot(2+.5*rand(1,24)-.25,habit_index_norm_av(:,2),'g.','markersize',15)
plot(3+.5*rand(1,24)-.25,habit_index_norm_av(:,3),'b.','markersize',15)

plot([1 1],nanmean(habit_index_norm_av(:,1))*[1 1]+seNaN(habit_index_norm_av(:,1))*[-1 1],'r','linewidth',3)
plot(2*[1 1],nanmean(habit_index_norm_av(:,2))*[1 1]+seNaN(habit_index_norm_av(:,2))*[-1 1],'g','linewidth',3)
plot(3*[1 1],nanmean(habit_index_norm_av(:,3))*[1 1]+seNaN(habit_index_norm_av(:,3))*[-1 1],'b','linewidth',3)

igood = find(~isnan(habit_index_norm_av(:,1)));
plot([0.5 3.5],(nanmean(habit_index_norm_av(:,1))+2*std(habit_index_norm_av(igood,1)))*[1 1],'r:')

%% Pretty figure
figure(104); hold on

d.color.habit.untrained                = [255   175   0]/255;
d.color.habit.trained                  = [255   100   0]/255;
d.color.habit.extendedTrained          = [255    0    0]/255;

% title('normalized habit index (norm. to 0-200ms)')



plot(1+.5*rand(1,24)-.25,habit_index_norm_av(:,1),'.','color',d.color.habit.untrained       ,'markersize',15)
plot(2+.5*rand(1,24)-.25,habit_index_norm_av(:,2),'.','color',d.color.habit.trained         ,'markersize',15)
plot(3+.5*rand(1,24)-.25,habit_index_norm_av(:,3),'.','color',d.color.habit.extendedTrained ,'markersize',15)

% plot([1 1],nanmean(habit_index_norm_av(:,1))*[1 1]+seNaN(habit_index_norm_av(:,1))*[-1 1],'color','k','linewidth',3)
% plot(2*[1 1],nanmean(habit_index_norm_av(:,2))*[1 1]+seNaN(habit_index_norm_av(:,2))*[-1 1],'color','k','linewidth',3)
% plot(3*[1 1],nanmean(habit_index_norm_av(:,3))*[1 1]+seNaN(habit_index_norm_av(:,3))*[-1 1],'color','k','linewidth',3)

errorbar(1:3,nanmean(habit_index_norm_av),seNaN(habit_index_norm_av),'.k','markersize',1);

igood = find(~isnan(habit_index_norm_av(:,1)));
plot([0.5 3.5],(nanmean(habit_index_norm_av(:,1))+2*std(habit_index_norm_av(igood,1)))*[1 1],'k--')
set(gca,'tickdir','out');
ylabel('Normalized habit index');
xlabel('Condition')
%xticks(1:3)
%xticklabels({'Minimal','4 Days','20 Days'})

axis([0.5 3.5 -.25 1.5])
%yticks(-0.25:.25:1.5)
%yticklabels({'','0','','0.5','','1.0','','1.5'});


%% split data into habit/no-habit - norm

%{
HI_thr = nanmean(habit_index_norm_av(:,1))+2*std(habit_index_norm_av(igood,1));
i_habit2 = find(habit_index_norm_av(:,2)>=HI_thr);
i_nohabit2 = find(habit_index_norm_av(:,2)<HI_thr);
i_habit3 = find(habit_index_norm_av(:,3)>=HI_thr);
i_nohabit3 = find(habit_index_norm_av(:,3)<HI_thr);

figure(121); clf; hold on
subplot(2,2,1); hold on
plot([0 1200],[0 0],'k:')
plot(habit_err(i_habit2,:,2)','g')
plot(habit_err(i_nohabit2,:,2)','k')

subplot(2,2,3); hold on
plot([0 1200],[0 0],'k:')
plot(habit_err(i_habit3,:,3)','g')
plot(habit_err(i_nohabit3,:,3)','k')
%}
%% no norm
%{
HI_thr = nanmean(habit_index_av(:,1))+2*std(habit_index_av(igood,1));
i_habit2 = find(habit_index_av(:,2)>=HI_thr);
i_nohabit2 = find(habit_index_av(:,2)<HI_thr);
i_habit3 = find(habit_index_av(:,3)>=HI_thr);
i_nohabit3 = find(habit_index_av(:,3)<HI_thr);

%figure(122); clf; hold on
subplot(2,2,2); hold on
plot([0 1200],[0 0],'k:')
plot(habit_err(i_habit2,:,2)','g')
plot(habit_err(i_nohabit2,:,2)','k')


subplot(2,2,4); hold on
plot([0 1200],[0 0],'k:')
plot(habit_err(i_habit3,:,3)','g')
plot(habit_err(i_nohabit3,:,3)','k')
%}
%%

% power analysis for grant
habit_index_mean = nanmean(habit_index_av);
habit_index_std = nanstd(habit_index_av);

habit_index_mean_norm = nanmean(habit_index_norm_av);
habit_index_std_norm = nanstd(habit_index_norm_av);


N = sampsizepwr('t2',[0 habit_index_std(2)],habit_index_mean(2)/2,0.8)
N_norm = sampsizepwr('t2',[0 habit_index_std_norm(2)],habit_index_mean_norm(2)/2,0.8)