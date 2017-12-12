%% make average model fit figures
for s=1:24
    for c=1:3
        for i=1:4
            if(~isempty(data(s,c).sliding_window))
                d.sliding_window(i,:,c,s) = data(s,c).sliding_window(i,:);
            else
                d.sliding_window(i,:,c,s) = NaN;
            end
        end
    end
end

for m=1:2
    for c=1:3
        for i=1:4
            sgood = sum(squeeze(model(m).presponse(i,:,c,:)))>0;
            model_mean(:,c,i,m) = nanmean(squeeze(model(m).presponse(i,:,c,sgood))');
            model_se(:,c,i,m) = seNaN(squeeze(model(m).presponse(i,:,c,sgood))');
            
            data_mean(:,c,i) = nanmean(squeeze(d.sliding_window(i,:,c,sgood))');
            data_se(:,c,i) = seNaN(squeeze(d.sliding_window(i,:,c,sgood))');
        end
    end
end
%%
figure(105); clf; hold on
for c=1:3
    subplot(1,3,c); hold on
    %shadedErrorBar([1:1200],model_mean(:,c,1,1),model_se(:,c,1),'b')
    %shadedErrorBar([1:1200],model_mean(:,c,2,1),model_se(:,c,2),'r')
    shadedErrorBar([1:1200],data_mean(:,c,1),data_se(:,c,1),'b')
    shadedErrorBar([1:1200],data_mean(:,c,2),data_se(:,c,2),'r')
    plot(model_mean(:,c,1,1),'b','linewidth',2)
    plot(model_mean(:,c,2,1),'r','linewidth',2)
    
end

figure(106); clf; hold on
for c=1:3
    subplot(1,3,c); hold on
    %shadedErrorBar([1:1200],model_mean(:,c,1,2),model_se(:,c,1),'b')
    %shadedErrorBar([1:1200],model_mean(:,c,2,2),model_se(:,c,2),'r')
    shadedErrorBar([1:1200],data_mean(:,c,1),data_se(:,c,1),'b')
    shadedErrorBar([1:1200],data_mean(:,c,2),data_se(:,c,2),'r')
    shadedErrorBar([1:1200],data_mean(:,c,4),data_se(:,c,4),'m')
    plot(model_mean(:,c,1,2),'b','linewidth',2)
    plot(model_mean(:,c,2,2),'r','linewidth',2)
    plot(model_mean(:,c,4,2),'m:','linewidth',2)
end

%% same but for only habitual participants
figure(107); clf; hold on
for c=1:3
    dAIC = model(1).AIC-model(2).AIC;
    s_habitual = ~isnan(dAIC(c,:)) & dAIC(c,:)>0;
    s_nonhabitual = ~isnan(dAIC(c,:)) & dAIC(c,:)<0;
    
    for m=1:2
        for i=1:4
            sgood = sum(squeeze(model(m).presponse(i,:,c,:)))>0 & s_habitual;
            model_mean(:,c,i,m) = nanmean(squeeze(model(m).presponse(i,:,c,sgood))');
            model_se(:,c,i,m) = seNaN(squeeze(model(m).presponse(i,:,c,sgood))');
            
            data_mean(:,c,i) = nanmean(squeeze(d.sliding_window(i,:,c,sgood))');
            data_se(:,c,i) = seNaN(squeeze(d.sliding_window(i,:,c,sgood))');
        end
    end
    
    subplot(1,3,c); hold on
    %shadedErrorBar([1:1200],model_mean(:,c,1,2),model_se(:,c,1),'b')
    %shadedErrorBar([1:1200],model_mean(:,c,2,2),model_se(:,c,2),'r')
    shadedErrorBar([1:1200],data_mean(:,c,1),data_se(:,c,1),'b');
    shadedErrorBar([1:1200],data_mean(:,c,2),data_se(:,c,2),'r');
    shadedErrorBar([1:1200],data_mean(:,c,4),data_se(:,c,4),'m');
    plot(model_mean(:,c,1,2),'b','linewidth',2)
    plot(model_mean(:,c,2,2),'r','linewidth',2)
    %plot(model_mean(:,c,4,2),'m:','linewidth',2)
end