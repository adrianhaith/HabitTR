% test fit_model

clear all
load HabitData;

subject = 1;
condition = 3;

model = fit_model(data(subject,condition).RT,data(subject,condition).response)
%%
figure(1); clf; hold on
colors = [1 0 0; 0 1 0; 0 0 1; 0 1 1];
scaling = [1 1 .5 1];
for i=1:4
    plot(model.xplot,data(subject,condition).sliding_window(i,:),'color',colors(i,:))
    plot(model.xplot,model.presponse(i,:)*scaling(i),'color',colors(i,:),'linewidth',2)
end

