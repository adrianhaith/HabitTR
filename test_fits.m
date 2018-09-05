% test fitting with flex asymptote

dat = data(1,2);
model1 = fit_model(dat.RT,dat.response,2,[constrained_params NaN NaN],1);
pp = getResponseProbs_U(xplot,model1.paramsOpt,2,1);

%%
figure(1); clf; hold on
%subplot(3,1,1); hold on
plot(xplot,pp(2,:),'r')
plot(xplot,pp(1,:),'b')
plot(xplot,pp(3,:)/2,'m')
plot(xplot,pp(4,:),'k')
plot(xplot,pp(5,:),'c')

plot(xplot,dat.sliding_window(1,:),'b')
plot(xplot,dat.sliding_window(2,:),'r')
plot(xplot,dat.sliding_window(3,:),'m')

xlim([0 1.200])

%subplot(3,1,2); hold on
%plot(dat.RT,model1.Lv,'.','markersize',15)
%xlim([0 1.2])
