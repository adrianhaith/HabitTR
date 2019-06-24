% compare rate of 'other' errors for remapped versus non-remapped stimuli
clear all
load PooledData


figure(11); clf; hold on

for c=1:3
    subplot(1,3,c); hold on
    plot(data_all(c).sw(1,:),'b','linewidth',2)
    plot(data_all(c).sw(2,:),'r','linewidth',2)
    plot(data_all(c).sw(3,:)/2,'m','linewidth',2)
    plot(data_all(c).sw(4,:),'k','linewidth',2)
    plot(data_all(c).sw(5,:),'y','linewidth',2)
    plot(data_all(c).sw(6,:)/3,'g','linewidth',2)
end