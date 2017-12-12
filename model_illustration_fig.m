% make conceptual figure
clear all;
load HabitModelFits

fhandle = figure(102); clf; hold on
set(fhandle, 'Position', [300, 100, 1300, 600]); % set size and loction on screen
set(fhandle, 'Color','w') % set background color to white


paramsDemo = [.4 .06 .99 .5 .09 .9 .25 1];

N = 5;
mu = linspace(paramsDemo(4),paramsDemo(1),N);
sigma = linspace(paramsDemo(5),paramsDemo(2),N);
col_b = [linspace(.7,0,N)' linspace(.7,0,N)' ones(N,1)];
col_r = [ones(N,1) linspace(.7,0,N)' linspace(.7,0,N)'];

xplot = [0:.001:1];
xmax = 1;

%% increasing skill - pdf
subplot(2,3,1); hold on
for i=1:N
    plot(xplot,normpdf(xplot,mu(i),sigma(i)),'linewidth',2,'color',col_b(i,:))
end
%plot(xplot,normpdf(xplot,paramsDemo(4),paramsDemo(5)),'b','linewidth',2)
xlim([0 xmax])
ylim([0 10])

%% increasing skill - SAT
subplot(2,3,4); hold on
for i=1:N
    params = [mu(i) sigma(i) .99 .5 .09 .9 .25 1];
    presponse = getResponseProbs(xplot,params,'habit');
    plot([0 xmax],.25*[1 1],'k--')
    plot(xplot,presponse(4,:),'color',col_b(i,:),'linewidth',2)
end
%plot(xplot,presponse(1,:),'b','linewidth',2)
ylim([0 1])
xlim([0 xmax])

%% increasing skill - habit

subplot(2,3,2); hold on
for i=1:N
    params = [mu(i) sigma(i) .99 .5 .09 .9 .25 1];
    plot(xplot,normpdf(xplot,params(1),params(2)),'color',col_r(i,:),'linewidth',2)
end
plot(xplot,normpdf(xplot,paramsDemo(4),paramsDemo(5)),'b','linewidth',2)
xlim([0 xmax])
ylim([0 10])

subplot(2,3,5); hold on
plot([0 xmax],.25*[1 1],'k--')
for i=1:N
    params = [mu(i) sigma(i) .99 .5 .09 .9 .25 1];
    presponse = getResponseProbs(xplot,params,'habit');
    

    plot(xplot,presponse(2,:),'color',col_r(i,:),'linewidth',2)
    plot(xplot,presponse(1,:),'color',col_b(i,:),'linewidth',2)
    plot(xplot,presponse(4,:),'--','color',col_r(i,:),'linewidth',2)
end
ylim([0 1])
xlim([0 xmax])

%% increasing habitual responding

subplot(2,3,3); hold on
alpha = linspace(0,1,N);
for i=1:N
    params = [mu(N) sigma(N) .99 .5 .09 .9 .25 1];
    plot(xplot,alpha(i)*normpdf(xplot,params(1),params(2)),'color',col_r(i,:),'linewidth',2)
end
plot(xplot,normpdf(xplot,paramsDemo(4),paramsDemo(5)),'b','linewidth',2)
xlim([0 xmax])
ylim([0 10])

subplot(2,3,6); hold on
plot([0 xmax],.25*[1 1],'k--')
for i=1:N
    params = [mu(N) sigma(N) .99 .5 .09 .9 .25 alpha(i)];
    presponse = getResponseProbs(xplot,params,'flex-habit');
    
    plot(xplot,presponse(2,:),'color',col_r(i,:),'linewidth',2)
    plot(xplot,presponse(1,:),'color',col_b(i,:),'linewidth',2)
    plot(xplot,presponse(4,:),'--','color',col_r(i,:),'linewidth',2)
end
ylim([0 1])
xlim([0 xmax])
