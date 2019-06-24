% explore effect of speed and habit strength

mu_4 = model_unchanged(2).paramsOpt(1);
sigma_4 = model_unchanged(2).paramsOpt(2);

rho_4 = model(3,2).paramsOpt(7);
rho_20 = model(3,3).paramsOpt(7);

mu_20 = model_unchanged(3).paramsOpt(1);
sigma_20 = model_unchanged(3).paramsOpt(2);

N = 10;
mu_all = linspace(mu_4,mu_20,N);
sigma_all = linspace(sigma_4,sigma_20,N);
rho_all = linspace(rho_4,rho_20,N);

params_test = model(2,2).paramsOpt;

cols = [linspace(0,1,N)' linspace(0,0,N)' linspace(1,0,N)'];

figure(3); clf; hold on
subplot(2,2,1); hold on
% test just varying mu and sigma, starting with habit model
params_test = model(2,2).paramsOpt;
for i=1:N
    params_test(1:2) = [mu_all(i) sigma_all(i)];
    pr_all(:,:,i) = getResponseProbs_U(xplot,params_test);
    
    plot(pr_all(2,:,i),'color',cols(i,:),'linewidth',2);
end
ylim([0 1])

%{
subplot(2,2,2); hold on
% test just varying mu and sigma, starting with flex model
params_test = model(3,2).paramsOpt;
for i=1:N
    params_test(1:2) = [mu_all(i) sigma_all(i)];
    pr_all(:,:,i) = getResponseProbs_U(xplot,params_test);
    
    plot(pr_all(2,:,i),'color',cols(i,:),'linewidth',2);
end
ylim([0 1])
%}
subplot(2,2,3); hold on
% test just varying rho, starting with flex model
params_test = model(3,2).paramsOpt;
for i=1:N
    params_test(7) = rho_all(i);
    pr_all(:,:,i) = getResponseProbs_U(xplot,params_test);
    
    plot(pr_all(2,:,i),'color',cols(i,:),'linewidth',2);
end
ylim([0 1])

subplot(2,2,4); hold on
% test just varying rho, mu and sigma, starting with flex model
params_test = model(3,2).paramsOpt;
for i=1:N
    params_test(7) = rho_all(i);
    params_test(1:2) = [mu_all(i) sigma_all(i)];
    pr_all(:,:,i) = getResponseProbs_U(xplot,params_test);
    
    plot(pr_all(2,:,i),'color',cols(i,:),'linewidth',2);
end
ylim([0 1])

subplot(2,2,2); hold on
% test just varying mu and sigma, starting with flex model, but forcing rho
% to 1
params_test = model(3,2).paramsOpt;
params_test(7) = 1;
for i=1:N
    %params_test(7) = rho_all(i);
    params_test(1:2) = [mu_all(i) sigma_all(i)];
    pr_all(:,:,i) = getResponseProbs_U(xplot,params_test);
    
    plot(pr_all(2,:,i),'color',cols(i,:),'linewidth',2);
end
ylim([0 1])