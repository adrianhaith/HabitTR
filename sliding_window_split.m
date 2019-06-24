% compute sliding window on first half versus second half of the data
clear all
load HabitData

for c=1:3
    for subject=1:24
        if(~isempty(data(subject,c).RT))
            for r=1:3
                
                ihalf = ceil(length(data(subject,c).RT)/2);
                
                data(subject,c).sw_split(r,:,1) = sliding_window(data(subject,c).RT(1:ihalf),(data(subject,c).response(1:ihalf)==r),.001*[1:1200],.1)
                data(subject,c).sw_split(r,:,2) = sliding_window(data(subject,c).RT(ihalf+1:end),(data(subject,c).response(ihalf+1:end)==r),.001*[1:1200],.1)
            end
        end
    end
end
col = {'b','r','m'};
for c=1:3
    figure(c); clf; hold on
    for subject = 1:24
        subplot(4,6,subject); hold on
        if(~isempty(data(subject,c).RT))
            for r=2
                plot(data(subject,c).sw_split(r,:,1),'r','linewidth',2)
                plot(data(subject,c).sw_split(r,:,2),'b','linewidth',2)
            end
        end
    end
end

%%
% average sliding_window
figure(4); clf; hold on
for c = 1:3
    subplot(1,3,c); hold on
    for subject = 1:24
        for r=1:3
            if(~isempty(data(subject,c).RT))
                sw_split_all(subject,:,r,1) = data(subject,c).sw_split(r,:,1);
                sw_split_all(subject,:,r,2) = data(subject,c).sw_split(r,:,2);
            else
                sw_split_all(subject,:,r,1) = NaN;
                sw_split_all(subject,:,r,2) = NaN;
            end
        end
    end
    
    % exclude subject 5
    sw_split_all(5,:,2,1) = NaN;
    sw_split_all(5,:,2,2) = NaN;
    
    plot(nanmean(sw_split_all(:,:,1,1)),'r','linewidth',1)
    plot(nanmean(sw_split_all(:,:,2,1)),'r','linewidth',2)
    plot(nanmean(sw_split_all(:,:,3,1))/2,'r','linewidth',3)
    
    plot(nanmean(sw_split_all(:,:,1,2)),'b','linewidth',1)
    plot(nanmean(sw_split_all(:,:,2,2)),'b','linewidth',2)
    plot(nanmean(sw_split_all(:,:,3,2))/2,'b','linewidth',3)
end