% test pooled fit

for s=1:24
    for c=1:3
        if(~isempty(data(s,c).RT))
            model_simp(s,c) = fit_model(data(s,c).RT,data(s,c).response,2,[NaN*ones(1,6) 1],1);
        end
    end
end

%%
for c=1:3
    figure(c); clf; hold on
    for s=1:24
        if(~isempty(data(s,c).RT))
        subplot(4,6,s); hold on
        xplot = model_simp(s,c).xplot;
        %subplot(1,2,1); hold on
        plot(xplot,model_simp(s,c).presponse(1,:),'b')
        plot(xplot,model_simp(s,c).presponse(2,:),'r')
        plot(xplot,model_simp(s,c).presponse(3,:)/2,'m')
        
        plot(xplot,data(s,c).sliding_window(1,:),'b')
        plot(xplot,data(s,c).sliding_window(2,:),'r')
        plot(xplot,data(s,c).sliding_window(3,:),'m')
        
        %subplot(1,2,2); hold on
        %plot(xplot,model_simp.presponse(1,:)+model_simp.presponse(3,:),'b')
        %plot(xplot,model_simp.presponse(2,:),'r')
        
        %plot(xplot,data(s,c).sliding_window(1,:)+2*data(s,c).sliding_window(3,:),'b')
        %plot(xplot,data(s,c).sliding_window(2,:),'r')
        end
    end
end
%%
for c=1:3
    figure(10+c); clf; hold on
    for s=1:24
        if(~isempty(data(s,c).RT))
        subplot(4,6,s); hold on
        xplot = model_simp(s,c).xplot;
        %subplot(1,2,1); hold on
        plot(xplot,model_simp(s,c).presponse(1,:)+model_simp(s,c).presponse(3,:),'b')
        plot(xplot,model_simp(s,c).presponse(2,:),'r')
        %plot(xplot,model_simp(s,c).presponse(3,:)/2,'m')
        
        plot(xplot,data(s,c).sliding_window(1,:)+2*data(s,c).sliding_window(3,:),'b')
        plot(xplot,data(s,c).sliding_window(2,:),'r')
        %plot(xplot,data(s,c).sliding_window(3,:),'m')
        
        %subplot(1,2,2); hold on
        %plot(xplot,model_simp.presponse(1,:)+model_simp.presponse(3,:),'b')
        %plot(xplot,model_simp.presponse(2,:),'r')
        
        %plot(xplot,data(s,c).sliding_window(1,:)+2*data(s,c).sliding_window(3,:),'b')
        %plot(xplot,data(s,c).sliding_window(2,:),'r')
        end
    end
end


%% extract rhos
for c=1:3
    for s=1:24
        if(~isempty(data(s,c).RT))
            rho(s,c) = model_simp(s,c).paramsOpt(7)
        else
            rho(s,c) = NaN;
        end
    end
end