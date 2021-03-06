% script to plot model fits
clear all
load HabitModelFits

makepdf = 0; % flag for exporting to pdf. Set to 1 if you want to generate a pdf.

%% plot data and fits
cols(:,:,1) = [ 0 210 255; 255 210 0; 0 0 0; 210 0 255]/256;
cols(:,:,2) = [ 0 155 255; 255 100 0; 0 0 0; 155 0 255]/256;
cols(:,:,3) = [0 100 255; 255 0 0; 0 0 0; 100 0 255]/256;

% open figures and pre-format (I've found this helps when later exporting
% to pdf)
for f=1:24
    fhandle = figure(f); clf; hold on
    set(fhandle, 'Position', [600, 100, 1200, 600]); % set size and loction on screen
    set(fhandle, 'Color','w') % set background color to white
    
    % pre-plot blank data in corner subplots to avoid cropping when exporting to pdf
    subplot(3,5,1);
    plot(0,0,'w.')    
    subplot(3,5,12);
    plot(0,0,'w.')
end

for c = 1:3 % 1=minimal, 2=4day, 3=4week
    for subject = 1:size(data,1)
        if (~isempty(data(subject,c).RT))  %only run on subjects that completed the study
            % plotting raw data...
            figure(subject);
            for m=1:3
                subplot(3,5,m+5*(c-1));  hold on;  axis([0 1200 0 1.05]);
                title([data(subject,c).condition_name,' condition; ',model(m).name,' model'],'fontsize',8);
                plot(0,0,'w.')
                plot([1:1200],data(subject,c).sliding_window(3,:),'color',cols(4,:,c),'linewidth',.5);
                plot([1:1200],data(subject,c).sliding_window(1,:),'color',cols(1,:,c),'linewidth',.5);
                plot([1:1200],data(subject,c).sliding_window(2,:),'color',cols(2,:,c),'linewidth',.5);
                plot([1:1200],data(subject,c).sliding_window(4,:),'m','linewidth',.5);
                %plotting model fit data...
                %plot([1:1200],data(subject,c).pfit_unchanged,'color',cols(4,:,c),'linewidth',2);
                
                plot([1:1200],model(m).presponse(1,:,c,subject),'color',cols(1,:,c),'linewidth',1.5)
                plot([1:1200],model(m).presponse(2,:,c,subject),'color',cols(2,:,c),'linewidth',1.5)
                plot([1:1200],model(m).presponse(3,:,c,subject),'color',cols(4,:,c),'linewidth',1.5)
                if(m~=1)
                    plot([1:1200],model(m).presponse(4,:,c,subject),':','color',cols(4,:,c),'linewidth',2)
                end
                text(650,.5,['AIC = ',num2str(model(m).AIC(c,subject))],'fontsize',8);
            end
            
            subplot(3,5,5*(c-1)+4); cla; hold on
            plot(model(1).AIC(c,:)-model(2).AIC(c,:),'bo')
            plot(subject,model(1).AIC(c,subject)-model(2).AIC(c,subject),'b.','markersize',20)
            plot([0 25],[0 0],'k')
            xlim([0 25])
            ylim([-70 70])
            title('\Delta AIC habit/no-habit','fontsize',8)
            
            
            subplot(3,5,5*(c-1)+5); cla; hold on
            plot(model(3).AIC(c,:)-model(2).AIC(c,:),'bo')
            plot(subject,model(3).AIC(c,subject)-model(2).AIC(c,subject),'b.','markersize',20)
            plot([0 25],[0 0],'k')
            xlim([0 25])
            ylim([-15 15])
            title('\Delta AIC habit/flex-habit','fontsize',8)

%             if(c==2) % plot learning curve
%                 subplot(3,5,5*(c-1)+5); cla; hold on
%                 plot(data(subject,c).trainingRT,'b','linewidth',2)
%                 plot([data(:,c).trainingRT],'color',.7*[1 1 1])
%                 ylim([350 750])
%             end

        end
    end
end

%% make AIC figure for habit model
figure(101); clf; hold on
for i=1:3
    
    plot(i+.2*(-.5+[1:24]/24),model(1).AIC(i,:)-model(2).AIC(i,:),'b.','markersize',10);
    dAICav(i) = nanmean(model(1).AIC(i,:)-model(2).AIC(i,:));
    dAICse(i) = nanstd(model(1).AIC(i,:)'-model(2).AIC(i,:)');
    plot(i,dAICav(i),'k.','markersize',12);
    plot([i i],dAICav(i)+[-dAICse(i)/2 dAICse(i)/2],'k','linewidth',2)
end
ylim([-20 70])
xlim([0.5 3.5])
plot([0 4],[0 0],'k')

% figure out overall stats
dAIC_habitual = model(1).AIC-model(2).AIC;
nsubjs = sum(~isnan(dAIC_habitual(2,:)))
habitual = (dAIC_habitual(2,:)<0) & (~isnan(dAIC_habitual(2,:)))

disp([num2str(nsubjs - sum(habitual)) '/' num2str(nsubjs) ' were habitual'])
%% make AIC figure for continuous model
figure(102); clf; hold on
for i=1:3
    
    plot(i+.2*(-.5+[1:24]/24),model(3).AIC(i,:)-model(2).AIC(i,:),'b.','markersize',10);
    dAICav = nanmean(model(3).AIC(i,:)-model(2).AIC(i,:));
    dAICse = nanstd(model(3).AIC(i,:)'-model(2).AIC(i,:)');
    plot(i,dAICav,'k.','markersize',12);
    plot([i i],dAICav+[-dAICse/2 dAICse/2],'k','linewidth',2)
    %keyboard
end
plot([0 4],[0 0],'k')



%% generate pdfs
%makepdf=1;
if(makepdf)
    for subject=1:24
        figure(subject)
        % save pdf for this participant
        eval(['export_fig data_pdfs/Habit_Subj',num2str(subject),' -pdf']);
    end
    
    % collate all subjs into 1 pdf
    delete data_pdfs/AllSubjs.pdf
    evalstr = ['append_pdfs data_pdfs/AllSubjs.pdf'];
    for i=1:24
        evalstr = [evalstr,' data_pdfs/Habit_Subj',num2str(i),'.pdf'];
    end
    eval(evalstr);
end

