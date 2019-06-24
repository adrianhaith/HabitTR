% test alternative model of response preparation with non-independent times
% for habit and g-d response

addpath ../

load HabitData

xplot = [0:.001:1.2];
params = [.3 .05 .4 .05 .95 .25 1 1]; % mu_A sigma_A mu_B sigma_B AE q_I rho_A rho_B

pr = getResponseProbs_non_independent(xplot,params,2);

figure(1); clf; hold on
plot(xplot,pr(1,:),'b')
plot(xplot,pr(2,:),'r')
plot(xplot,pr(3,:)/2,'m')

s = 13;
c = 2;
model_fit_nonind = fit_model_non_independent(data(s,c).RT,data(s,c).response,[NaN NaN NaN .6 NaN NaN 1 NaN],'fmincon');
model_fit_ind = fit_model(data(s,c).RT,data(s,c).response,[NaN NaN NaN NaN NaN NaN 1 NaN],'fmincon');

figure(2); clf; hold on
plot(data(s,c).sliding_window(1,:),'b')
plot(data(s,c).sliding_window(2,:),'r')
plot(data(s,c).sliding_window(3,:),'m')

plot(model_fit_ind.presponse(1,:),'b','linewidth',2)
plot(model_fit_ind.presponse(2,:),'r','linewidth',2)
plot(model_fit_ind.presponse(3,:)/2,'m','linewidth',2)

plot(model_fit_nonind.presponse(1,:),'b:','linewidth',2)
plot(model_fit_nonind.presponse(2,:),'r:','linewidth',2)
plot(model_fit_nonind.presponse(3,:)/2,'m:','linewidth',2)