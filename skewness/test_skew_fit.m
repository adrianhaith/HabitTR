% test skewed fits
addpath ../
clear all
load HabitData

for s=1:24
    c=1;
    if(~isempty(data(s,c).RT))
        model_unskew(s,c) = fit_model_1proc_skew(data(s,c).RT,(data(s,c).response>1)+1,[NaN NaN NaN NaN 10000],'fmincon');
        model_skew(s,c) = fit_model_1proc_skew(data(s,c).RT,(data(s,c).response>1)+1,[NaN NaN NaN NaN NaN],'fmincon');
        % constrain initAE
        %model_unchanged_constrained(s,c) = fit_model(data(s,c).RT_unchanged,(data(s,c).response_unchanged>1)+1,1,[NaN NaN 1 .25])
        AIC_unskew(s) = model_unskew(s,c).AIC;
        AIC_skew(s) = model_skew(s,c).AIC;
    else
        AIC_unskew(s) = NaN;
        AIC_skew(s) = NaN;
    end
end
%%

figure(1); clf; hold on
for s=1:24
    if(~isempty(data(s,c).RT))
        subplot(6,4,s); hold on
        plot(data(s,c).sliding_window(1,:),'b')
        plot(data(s,c).sliding_window(2,:),'r')
        
        plot(model_unskew(s,c).presponse(1,:),'b:')
        plot(model_unskew(s,c).presponse(2,:)/3,'r:')
        
        plot(model_skew(s,c).presponse(1,:),'b--')
        plot(model_skew(s,c).presponse(2,:)/3,'r--')
        
        text(750,0.5,['\lambda = ',num2str(model_skew(s,c).paramsOpt(5))])
        
        if(AIC_skew(s)<AIC_unskew(s))
            text(50,.9,'*','fontsize',20)
        end
        
    end
end

%%
figure(2); clf; hold on

%subplot(1,2,1); clf; hold on

dAIC = AIC_skew-AIC_unskew;
plot(.25+.5*[0:23]/24,dAIC,'.','markersize',15)
plot([0 1],[0 0],'k')
xlim([0 1])

%subplot(1,2,2)

%plot(AIC_skew,AIC_unskew,'.','markersize',15)
%plot([50 450],[50 450],'k')
%axis equal


%% test ex-Gaussian cdf
xplot = [0:.001:1.2];
mu = .4;
var = .06;
lambda = 1000000;
u = lambda*(xplot-mu);
v = lambda*var;
ycdf = normcdf(u,0,v) - exp(-u+v.^2/2+log(normcdf(u,v.^2,v)))

figure(3); clf; hold on
plot(xplot,ycdf)

%% test getResponseProbs_U_skew
presponse_skew = getResponseProbs_U_skew(xplot,[mu var .9 .25 1],1);
figure(4); clf; hold on
plot(presponse_skew(1,:),'b')
plot(presponse_skew(2,:)/3,'r')