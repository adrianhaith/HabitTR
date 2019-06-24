% compare parameters across models
addpath ../
clear all
load HabitModelFits_U

for c=1:3
    for s=1:24
        for m=1:3
            if(~isempty(data(s,c).RT))
                params_fit(:,s,c,m) = model{m,s,c}.paramsOpt;
            else
                params_fit(:,s,c,m) = NaN*ones(1,8);
            end
        end
    end
end
%%
param_names = {'\mu_1','\sigma_1','\mu_2','\sigma_2','AE','init AE','\rho_1','\rho_2'};
for c=1:3
    figure(c); clf; hold on
    
    for pp=1:8
        subplot(2,4,pp); hold on
        title(param_names{pp})
        plot(params_fit(pp,:,c,2),params_fit(pp,:,c,3),'.','markersize',14)
        plot([min(params_fit(pp,:,c,2)) max(params_fit(pp,:,c,2))],[min(params_fit(pp,:,c,2)) max(params_fit(pp,:,c,2))],'k')
        axis equal
        xlabel('habit model')
        ylabel('flex-habit model')
    end
end
         