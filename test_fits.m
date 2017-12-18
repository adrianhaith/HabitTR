% test fitting with flex asymptote

dat = data(1,2);
model1 = fit_model(dat.RT,dat.response,2,[constrained_params 1],1);
pp = getResponseProbs_U(xplot,model1.paramsOpt,2,1);

%%
figure(1); clf; hold on
subplot(3,1,1); hold on
plot(xplot,pp(2,:),'r')
plot(xplot,dat.sliding_window(2,:),'r')

xlim([0 1.200])

subplot(3,1,2); hold on
plot(dat.RT,model1.Lv,'.','markersize',15)
xlim([0 1.2])
