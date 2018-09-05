% make habit fig for supplemental material

clear all
load HabitModelFits_U

cols(:,:,1) = [ 0 210 255; 255 210 0; 0 0 0; 210 0 255]/256;
cols(:,:,2) = [ 0 155 255; 255 100 0; 0 0 0; 155 0 255]/256;
cols(:,:,3) = [0 100 255; 255 0 0; 0 0 0; 100 0 255]/256;

% compute AICs
for subject = 1:24
    for c = 1:3
        for m=1:3
            AIC(c,subject,m) = model{m,subject,c}.AIC;
        end
    end
end


mod = [1 3 3];
for c=1:3 % condition
    
    fhandle = figure(c); clf; hold on
    set(fhandle, 'Position', [600, 100, 1200, 900]); % set size and loction on screen
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
            %plot([1:1200],data(subject,c).sliding_window(4,:),'m','linewidth',.5);
            %plotting model fit data...
            %plot([1:1200],data(subject,c).pfit_unchanged,'color',cols(4,:,c),'linewidth',2);
            
            if(c>1)
                % plot habit and flex-habit models
                plot([1:1200],model{2,subject,c}.presponse(1,:),'color',cols(1,:,c),'linewidth',1.5)
                plot([1:1200],model{2,subject,c}.presponse(2,:),'color',cols(2,:,c),'linewidth',1.5)
                plot([1:1200],model{2,subject,c}.presponse(3,:)/2,'color',cols(4,:,c),'linewidth',1.5)
                
                plot([1:1200],model{3,subject,c}.presponse(1,:),'color',cols(1,:,c),'linewidth',2,'linestyle','--')
                plot([1:1200],model{3,subject,c}.presponse(2,:),'color',cols(2,:,c),'linewidth',2,'linestyle','--')
                plot([1:1200],model{3,subject,c}.presponse(3,:)/2,'color',cols(4,:,c),'linewidth',2,'linestyle','--')
                
                text(650,.5,['habit AIC = ',num2str(AIC(c,subject,2))],'fontsize',8);
                text(650,.4,['flex-habit AIC = ',num2str(AIC(c,subject,3))],'fontsize',8);
                text(650,.3,['\rho = ',num2str(model{3,subject,c}.paramsOpt(7))],'fontsize',8)
            else
                % plot no-habit model
                plot([1:1200],model{1,subject,c}.presponse(1,:),'color',cols(1,:,c),'linewidth',1.5)
                plot([1:1200],model{1,subject,c}.presponse(2,:),'color',cols(2,:,c),'linewidth',1.5)
                plot([1:1200],model{1,subject,c}.presponse(3,:)/2,'color',cols(4,:,c),'linewidth',1.5)
                
                % plot flex-habit model
                plot([1:1200],model{3,subject,c}.presponse(1,:),'color',cols(1,:,c),'linewidth',2,'linestyle','--')
                plot([1:1200],model{3,subject,c}.presponse(2,:),'color',cols(2,:,c),'linewidth',2,'linestyle','--')
                plot([1:1200],model{3,subject,c}.presponse(3,:)/2,'color',cols(4,:,c),'linewidth',2,'linestyle','--')
                
                text(650,.5,['no-habit AIC = ',num2str(AIC(c,subject,1))],'fontsize',8)
                text(650,.4,['habit AIC = ',num2str(AIC(c,subject,2))],'fontsize',8);
                text(650,.3,['flex-habit AIC = ',num2str(AIC(c,subject,3))],'fontsize',8);
                
            end
            
            
            %text(650,.5,['AIC = ',num2str(model(m).AIC(c,subject))],'fontsize',8);
        end
    end
end

%% plot AICs

figure(11); clf; hold on
for c=1:3
    title('habit model vs no-habit model')
    subplot(1,2,1); hold on
    
    plot(c+[1:24]/(2*24)-.25,AIC(c,:,2)-AIC(c,:,1),'.')
    plot(c+[0 1/2]-.25,nanmean(AIC(c,:,2)-AIC(c,:,1))*[1 1],'k--','linewidth',2)
    plot([0.5 3.5],[0 0],'k')
    ylabel('\Delta AIC')
    
    title('habit model vs flex-habit model')
    subplot(1,2,2); hold on
    plot(c+[1:24]/(2*24)-.25,AIC(c,:,2)-AIC(c,:,3),'.')
    plot(c+[0 1/2]-.25,nanmean(AIC(c,:,2)-AIC(c,:,3))*[1 1],'k--','linewidth',2)
    plot([0.5 3.5],[0 0],'k')
    ylabel('\Delta AIC')
end

%% extract parameters
for m=1:3
    for subject = 1:24
        for c = 1:3
            if(~isempty(data(subject,c).RT))
                params_all(:,subject,c,m) = model{m,subject,c}.paramsOpt;
            else
                params_all(:,subject,c,m) = NaN;
            end
        end
        
    end
end

figure(12); clf; hold on
for c=2:3
    plot(c+[1:24]/(2*24)-.25,params_all(7,:,c,3),'.','markersize',15)
    ylim([0 1])
end
xlabel('condition / participant')
ylabel('rho (habit strength')
