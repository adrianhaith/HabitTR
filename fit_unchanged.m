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
            constrained_params(1:2) = model_unchanged(s,c).paramsOpt(1:2);
            
            model(s,c) = fit_model(data(s,c).RT,data(s,c).response,2);
            model_constrained(s,c) = fit_model(data(s,c).RT,data(s,c).response,2,constrained_params);
        end
    end
end

%%
for c=1:3
    for s=1:24
        if(~isempty(data(s,c).RT))
            rho_constrained(s,c) = model_constrained(s,c).paramsOpt(end);
            rho_unconstrained(s,c) = model(s,c).paramsOpt(end);
        else
            rho_constrained(s,c) = NaN;
            rho_unconstrained(s,c) = NaN;
        end
    end
end

%%
xplot = model(1,1).xplot;
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

