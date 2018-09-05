% make habit fig for supplemental material

clear all
load HabitModelFits_U

cols(:,:,1) = [ 0 210 255; 255 210 0; 0 0 0; 210 0 255]/256;
cols(:,:,2) = [ 0 155 255; 255 100 0; 0 0 0; 155 0 255]/256;
cols(:,:,3) = [0 100 255; 255 0 0; 0 0 0; 100 0 255]/256;


mod = [1 3 3];
for c=1:3 % condition
    
    fhandle = figure(c); clf; hold on
    set(fhandle, 'Position', [600, 100, 1200, 900]); % set size and loction on screen
    set(fhandle, 'Color','w') % set background color to white
    
    for subject=1:24 % iterate through participants
        subplot(6,4,subject); hold on
        
        if (~isempty(data(subject,c).RT))
            
            axis([0 1200 0 1.05]);
            title([data(subject,c).condition_name,' condition; '],'fontsize',8); %,model(m).name,' model'
            plot(0,0,'w.')
            plot([1:1200],data(subject,c).sliding_window(3,:),'color',cols(4,:,c),'linewidth',.5);
            plot([1:1200],data(subject,c).sliding_window(1,:),'color',cols(1,:,c),'linewidth',.5);
            plot([1:1200],data(subject,c).sliding_window(2,:),'color',cols(2,:,c),'linewidth',.5);
            %plot([1:1200],data(subject,c).sliding_window(4,:),'m','linewidth',.5);
            %plotting model fit data...
            %plot([1:1200],data(subject,c).pfit_unchanged,'color',cols(4,:,c),'linewidth',2);
            
            if(c>1)
                % plot habit and flex-habit models
                plot([1:1200],model(2).presponse(1,:,c,subject),'color',cols(1,:,c),'linewidth',1.5)
                plot([1:1200],model(2).presponse(2,:,c,subject),'color',cols(2,:,c),'linewidth',1.5)
                plot([1:1200],model(2).presponse(3,:,c,subject),'color',cols(4,:,c),'linewidth',1.5)
                
                plot([1:1200],model(3).presponse(1,:,c,subject),'color',cols(1,:,c),'linewidth',1.5,'linestyle','--')
                plot([1:1200],model(3).presponse(2,:,c,subject),'color',cols(2,:,c),'linewidth',1.5,'linestyle','--')
                plot([1:1200],model(3).presponse(3,:,c,subject),'color',cols(4,:,c),'linewidth',1.5,'linestyle','--')
                
                text(650,.5,['habit AIC = ',num2str(model(2).AIC(c,subject))],'fontsize',8);
                text(650,.4,['flex-habit AIC = ',num2str(model(3).AIC(c,subject))],'fontsize',8);
            else
                % plot no-habit model
                plot([1:1200],model(1).presponse(1,:,c,subject),'color',cols(1,:,c),'linewidth',1.5)
                plot([1:1200],model(1).presponse(2,:,c,subject),'color',cols(2,:,c),'linewidth',1.5)
                plot([1:1200],model(1).presponse(3,:,c,subject),'color',cols(4,:,c),'linewidth',1.5)
                
            end
            
            
            %text(650,.5,['AIC = ',num2str(model(m).AIC(c,subject))],'fontsize',8);
        end
    end
end

%% plot AICs
figure(11); clf; hold on
for c=1:3
    subplot(1,2,1); hold on
    
    plot(c+[1:24]/(2*24)-.25,model(2).AIC(c,:)-model(1).AIC(c,:),'.')
    plot(c+[0 1/2]-.25,nanmean(model(2).AIC(c,:)-model(1).AIC(c,:))*[1 1],'k')
    
    subplot(1,2,2); hold on
    plot(c+[1:24]/(2*24)-.25,model(2).AIC(c,:)-model(3).AIC(c,:),'.')
    plot(c+[0 1/2]-.25,nanmean(model(2).AIC(c,:)-model(3).AIC(c,:))*[1 1],'k')
end