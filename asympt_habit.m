% check asymptotic habit
clear all
load HabitModelFits

rng = [.9 1.2];

for s=1:24
    for c=1:2
        if(~isempty(data(s,c).RT))
            irng = find(data(s,c).RT>rng(1) & data(s,c).RT<rng(2));
            resp = data(s,c).response(irng);
            Nrng(s,c) = length(irng);
            p_habit(s,c) = sum(resp==2)/length(resp);
            
        else
            p_habit(s,c) = NaN;
            Nrng(s,c) = NaN;
        end
        
    end
end

%%
figure(1); clf; hold on
%plot(p_habit(:,1),p_habit(:,2),'bo')
%axis equal
plot([0 1],p_habit,'b-o')

figure(2); clf;
subplot(2,1,1); hold on
hist(p_habit(:,1),[0:.01:1]);

%subplot(2,1,2); hold on
hist(p_habit(:,2),[0:.01:1],'r');

%%
[h p] = kstest2(p_habit(:,1),p_habit(:,2))

[ht pt] = ttest(p_habit(:,1),p_habit(:,2),2,'independent')

p = ranksum(p_habit(:,1),p_habit(:,2))