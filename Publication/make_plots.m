% make habit fig for supplemental material

clear all
load HabitModelFits

cols(:,:,1) = [ 0 210 255; 255 210 0; 0 0 0; 210 0 255]/256;
cols(:,:,2) = [ 0 155 255; 255 100 0; 0 0 0; 155 0 255]/256;
cols(:,:,3) = [0 100 255; 255 0 0; 0 0 0; 100 0 255]/256;

% compute AICs
for subject = 1:24
    for c = 1:3
        for m=1:2
            if(~isempty(data(subject,c).RT))
                AIC(c,subject,m) = model{m,subject,c}.AIC;
            else
                AIC(c,subject,m) = NaN;
            end
            
        end
    end
end


mod = [1 3 3];
for c=1:3 % condition
    
    fhandle = figure(c); clf; hold on
    set(fhandle, 'Position', [200*c, 100, 900, 900]); % set size and loction on screen
    set(fhandle, 'Color','w') % set background color to white
    
    for subject=1:24 % iterate through participants
        subplot(6,4,subject); hold on
        if(c<3)
            title(['participant 1-',num2str(subject)],'fontsize',8); %,model(m).name,' model'
        else
            title(['participant 2-',num2str(subject)],'fontsize',8)
        end
        
        if (~isempty(data(subject,c).RT))
            
            axis([0 1200 0 1.05]);
            
            plot(0,0,'w.')
            plot([1:1200],data(subject,c).sliding_window(3,:),'color',cols(4,:,c),'linewidth',.5);
            plot([1:1200],data(subject,c).sliding_window(1,:),'color',cols(1,:,c),'linewidth',.5);
            plot([1:1200],data(subject,c).sliding_window(2,:),'color',cols(2,:,c),'linewidth',.5);
            
            if(c==1) % minimal practice condition
                
                % plot no-habit model
                plot([1:1200],model{1,subject,c}.presponse(1,:),'color',cols(1,:,c),'linewidth',1.5)
                plot([1:1200],model{1,subject,c}.presponse(2,:),'color',cols(2,:,c),'linewidth',1.5)
                plot([1:1200],model{1,subject,c}.presponse(3,:)/2,'color',cols(4,:,c),'linewidth',1.5)
         
                if(AIC(c,subject,2)<AIC(c,subject,1)) % if habit model beats no-habit model, plot it
                    % plot habit model
                    plot([1:1200],model{2,subject,c}.presponse(1,:),'color',cols(1,:,c),'linewidth',2,'linestyle','--')
                    plot([1:1200],model{2,subject,c}.presponse(2,:),'color',cols(2,:,c),'linewidth',2,'linestyle','--')
                    plot([1:1200],model{2,subject,c}.presponse(3,:)/2,'color',cols(4,:,c),'linewidth',2,'linestyle','--')
                    text(50,.9,'*','fontsize',16)
                end
                
                text(650,.5,['no-habit AIC = ',num2str(AIC(c,subject,1),4)],'fontsize',8)
                text(650,.4,['habit AIC = ',num2str(AIC(c,subject,2),4)],'fontsize',8);
                
            else % 4-day and 20-day practice conditions
                
                % plot habit model
                plot([1:1200],model{2,subject,c}.presponse(1,:),'color',cols(1,:,c),'linewidth',1.5)
                plot([1:1200],model{2,subject,c}.presponse(2,:),'color',cols(2,:,c),'linewidth',1.5)
                plot([1:1200],model{2,subject,c}.presponse(3,:)/2,'color',cols(4,:,c),'linewidth',1.5)
                
                if(AIC(c,subject,1)<AIC(c,subject,2)) % if no-habit model beats habit model, plot it
                    plot([1:1200],model{1,subject,c}.presponse(1,:),'color',cols(1,:,c),'linewidth',2,'linestyle',':')
                    plot([1:1200],model{1,subject,c}.presponse(2,:),'color',cols(2,:,c),'linewidth',2,'linestyle',':')
                    plot([1:1200],model{1,subject,c}.presponse(3,:)/2,'color',cols(4,:,c),'linewidth',2,'linestyle',':')
                    text(50,.9,'*','fontsize',16)
                end
                
                text(650,.5,['no-habit AIC = ',num2str(AIC(c,subject,1),4)],'fontsize',8);
                text(650,.4,['habit AIC = ',num2str(AIC(c,subject,2),4)],'fontsize',8);

            end
            
        end
    end
end

%% plot AICs

fhandle = figure(11); clf; hold on
set(fhandle, 'Position', [200, 200, 300, 300]); % set size and loction on screen
set(fhandle, 'Color','w') % set background color to white
    
for c=1:3
    title('habit vs no-habit model comparison')
    plot(c+[1:24]/(2*24)-.25,AIC(c,:,1)-AIC(c,:,2),'.','markersize',12)
    AICmean(c) = nanmean(AIC(c,:,1)-AIC(c,:,2));
    plot(c+[0 1/2]-.25,AICmean(c)*[1 1],'k-','linewidth',2)
    AICstd(c) = nanstd(AIC(c,:,1)-AIC(c,:,2))
    plot([c c],AICmean(c)*[1 1]+AICstd(c)*[1 -1],'k','linewidth',2)
    plot([0.5 3.5],[0 0],'k')
    ylabel('\Delta AIC')
    ylim([-30 90])
end
