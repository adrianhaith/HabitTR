% LR test on constrained fits

%LLall_2 = nansum([model(2).LLactual(2,rng)]); % likelihood of full habit model
%LLall_3 = nansum([model(3).LLactual(2,rng)]); % likelihood of flex-habit model

for c=1:3
    LLall{c} = [model_constrained_simp(:,c).LLactual];
    LLall_flex{c} = [model_constrained_simp_flex(:,c).LLactual];


Lambda_all(c) = max(2*(sum(LLall_flex{c})-sum(LLall{c})),0); % likelihood ratio statistic

% compute p-value
%[h,pValue] = lratiotest(Lall_3,Lall_2,1)
p_all(c) = 1-chi2cdf(Lambda_all(c),length(LLall{c}))
end
%disp(['p-value for flex-habit model, 4-day practice condition = ',num2str(p_all(c))])