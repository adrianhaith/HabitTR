% test whether underlying distribution of preparation time is Gaussian or heavy-tailed

clear all
% load data
load HabitData

for s=1:24
    for c=1:3
        if(~isempty(data(s,c).RT))
            model_unchanged(s,c) = fit_model_1proc(data(s,c).RT_unchanged,(data(s,c).response_unchanged>1)+1,1);
            
            % constrain initAE
            %model_unchanged_constrained(s,c) = fit_model(data(s,c).RT_unchanged,(data(s,c).response_unchanged>1)+1,1,[NaN NaN 1 .25])
        end
    end
end