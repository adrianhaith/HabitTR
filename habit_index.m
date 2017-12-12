% habit index
% plot habit / other
col = {'r','g','b'};

figure(111); clf; hold on
for c=1:3

    for s=1:24
        if(~isempty(data(s,c).RT))
            data(s,c).habit_index = data(s,c).sliding_window(2,:)-data(s,c).sliding_window(3,:);
            subplot(3,3,c); hold on
            plot(data(s,c).habit_index,'k')
            
            habit_index(s,:,c) = data(s,c).habit_index;
            habit_err(s,:,c) = data(s,c).sliding_window(2,:);
            other_err(s,:,c) = data(s,c).sliding_window(3,:);
            
            subplot(3,3,c+3); hold on
            plot(data(s,c).sliding_window(2,:),'b')
            plot(data(s,c).sliding_window(3,:),'y')
            
        else
            habit_index(s,:,c) = NaN;
            habit_err(s,:,c) = NaN;
            other_err(s,:,c) = NaN;
        end
    end
    
    % tidy up zeros
    
    subplot(3,3,c+6); hold on
    shadedErrorBar([],nanmean(habit_err(:,:,c)),seNaN(habit_err(:,:,c)),col{c})
    shadedErrorBar([],nanmean(other_err(:,:,c)),seNaN(other_err(:,:,c)),'k')
    axis([0 1200 -.1 1])
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


figure(113); clf; hold on
for c=1:3
subplot(1,3,c); hold on
shadedErrorBar([],nanmean(habit_err(:,:,c)),seNaN(habit_err(:,:,c)),col{c})
shadedErrorBar([],nanmean(other_err(:,:,c)),seNaN(other_err(:,:,c)),col{c})
axis([0 1200 0 .5])
end

%%
figure(114); clf; hold on
plot(habit_index(:,:,2)')


figure(115); clf; hold on
plot(1,nanmean(nanmean(habit_index(:,:,1))),'.','markersize',20)
plot(2,nanmean(nanmean(habit_index(:,:,2))),'.','markersize',20)
plot(3,nanmean(nanmean(habit_index(:,:,3))),'.','markersize',20)

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


