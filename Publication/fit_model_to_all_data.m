% fit models to data from all participants
%

clear all
tic

% load data
load HabitData;

for c = 1:3 % 1=minimal, 2=4day, 3=20day
    for subject = 1:size(data,1)
        if (~isempty(data(subject,c).RT)) % if data exist for this subject
            for m=1:2
                % set up and fit each model. Each model is defined by
                % constraining particular parameters in a generic model
                
                % parameters:
                % [mu1 sigma1 mu2 sigma2 initAE finalAE rho1 rho2]
                %  NaN implies that this parameter is unconstrained
                switch(m)
                    case 1;
                        Nprocesses = 1;
                    case 2;
                        Nprocesses = 2;

                end
                % fit this model to data for this subject and condition
                model{m,subject,c} = fit_model(data(subject,c).RT,data(subject,c).response,Nprocesses);    
            end
        end
    end
end

save HabitModelFits model data

toc