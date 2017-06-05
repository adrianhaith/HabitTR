close all; clear all;

load tmp;

% fit model on a subject by subject basis...
p = [];
p.condition1.unchanged = []; p.condition1.revised = []; 
p.condition2.unchanged = []; p.condition2.revised = []; 
p.condition3.unchanged = []; p.condition3.revised = [];

for c = 1:3 % 1=minimal, 2=4day, 3=4week
    if c < 2
       maxSub = 24; exclude = d.e1.exclude; 
    elseif c == 3
       maxSub = 15; exclude = d.e2.exclude;
    end
    
    for subject = 1:maxSub
        if ismember(subject,exclude) == 0,  %only run on subjects that completed the study
            subStr = ['s' num2str(subject)];
            if c==1
                unchanged = d.e1.(subStr).untrained.tr.sw.unchanged;	revised = d.e1.(subStr).untrained.tr.sw.revised; habit = d.e1.(subStr).untrained.tr.sw.habit;
                unchangedX= d.e1.(subStr).untrained.tr.bin.unchanged.x; unchangedY= d.e1.(subStr).untrained.tr.bin.unchanged.y;
                revisedX =  d.e1.(subStr).untrained.tr.bin.revised.x;   revisedY =  d.e1.(subStr).untrained.tr.bin.revised.y;   
                recodedX =  d.e1.(subStr).untrained.tr.modelCoded.x;    recodedY =  d.e1.(subStr).untrained.tr.modelCoded.y; 
            elseif c==2
                unchanged = d.e1.(subStr).trained.tr.sw.unchanged; revised = d.e1.(subStr).trained.tr.sw.revised; habit = d.e1.(subStr).trained.tr.sw.habit;
                unchangedX= d.e1.(subStr).trained.tr.bin.unchanged.x; unchangedY= d.e1.(subStr).trained.tr.bin.unchanged.y;
                revisedX =  d.e1.(subStr).trained.tr.bin.revised.x;   revisedY =  d.e1.(subStr).trained.tr.bin.revised.y;  
                recodedX =  d.e1.(subStr).trained.tr.modelCoded.x;    recodedY =  d.e1.(subStr).trained.tr.modelCoded.y; 
            elseif c==3
                unchanged = d.e2.(subStr).tr.sw6.unchanged;     revised = d.e2.(subStr).tr.sw6.revised;         habit = d.e2.(subStr).tr.sw6.habit;
                unchangedX= d.e2.(subStr).tr.bin.unchanged.x;   unchangedY= d.e2.(subStr).tr.bin.unchanged.y;
                revisedX =  d.e2.(subStr).tr.bin.revised.x;     revisedY =  d.e2.(subStr).tr.bin.revised.y; 
                recodedX =  d.e2.(subStr).tr.modelCoded.x;      recodedY =  d.e2.(subStr).tr.modelCoded.y; 
            end
            
            paramsU = fit_speed_accuracy_AE2(unchangedX,unchangedY);
            p1 = paramsU(4)+(paramsU(3)-paramsU(4))*normcdf([(1:1200)/1000],paramsU(1),paramsU(2));
            p.(['condition' num2str(c)]).unchanged = [p.(['condition' num2str(c)]).unchanged; paramsU]; 
            
            params = fit_speed_accuracy_AE2(revisedX,revisedY);
            p2 = params(4)+(params(3)-params(4))*normcdf([(1:1200)/1000],params(1),params(2));
            p.(['condition' num2str(c)]).revised = [p.(['condition' num2str(c)]).revised; params]; 
            
            %%ADRIAN: here's the place to try out the new fitting.
            %you can use inputs recodedX and recodedY
            %	recodedX is the response time (aka preparation time)
            %   for recodedY...
            %       0 = non-habitual error
            %       1 = correct response
            %       2 = habitual error
            
            % revise errors to 3, not 0 (for indexing)
            i0 = find(recodedY==0);
            recodedY(i0) = 3;
            
            % get rid of any trials that had unchanged x - fitting to
            % changed symbols only
            revised_trials = ismember(recodedX,revisedX);
            recodedX = recodedX(revised_trials);
            recodedY = recodedY(revised_trials);
            
            % initialize parameters
            paramsA = paramsU;
            paramsB = paramsU;
            % transform asymptote paramters to keep true parameters within [0,1];
            sigg = @(xx) (1/(1+exp(-xx))); % sigmoidal transformation [-inf,inf] -> [-1,1]
            sigg_inv = @(yy) -log(1./yy - 1); % inverse sigmoidal transformation [-1,1] -> [-inf,inf]
            paramsA(3) = sigg_inv(paramsA(3));
            paramsB(3) = sigg_inv(paramsB(3));
           
            % lower/upper bounds for fitting (with BADS)
            % params: [mu_A sigma_A AE_A mu_B sigma_B AE_B init_AE];
            LB = [0 0 0 0 0 -9 -9];
            UB = [.75 100 9 10 10 9 -.04];
            PLB = [.2 .02 .5 .2 .02 0 -2];
            PUB = [.7 .5 9 .7 .5 9 -.5];
            
            % -----fit two-process model-----
            habit_lik_constr = @(params) habit_lik(recodedX,recodedY,params(1:3),params(4:6),params(7)); % constrained function
            % find optimal parameters
            paramsInit = [paramsA(1:3) paramsB(1:3) sigg_inv(paramsA(4))];
            paramsInit = max(paramsInit,LB);
            paramsInit = min(paramsInit,UB);
            
            %[paramsOpt LLopt_2process(c,subject)] = fminsearch(habit_lik_constr,paramsInit);
            [paramsOpt{c,subject} LLopt_2process(c,subject)] = bads(habit_lik_constr,paramsInit,LB,UB,PLB,PUB);
            [xx Lv2{c,subject}] = habit_lik_constr(paramsOpt{c,subject});
            
            paramsAOpt = paramsOpt{c,subject}(1:3);
            paramsBOpt = paramsOpt{c,subject}(4:6);
            paramsBOpt(3) = sigg(paramsBOpt(3));
            paramsAOpt(3) = sigg(paramsAOpt(3));
            % plot model predictions
            xplot=[.001:.001:1.2];
            presponse_2 = getResponseProbs(xplot,paramsAOpt,paramsBOpt,sigg(paramsOpt{c,subject}(7)));
            
            % ------fit one-process model------
            habit_lik_constr1 = @(params) habit_lik_1process(recodedX,recodedY,params(1:3),params(4:6),params(7)); % constrained function
            % find optimal parameters
            paramsInit = [paramsA(1:3) paramsB(1:3) sigg_inv(paramsA(4))];
            paramsInit = max(paramsInit,LB);
            paramsInit = min(paramsInit,UB);
            
            %[paramsOpt1 LLopt_1process(c,subject)] = fminsearch(habit_lik_constr,paramsInit);
            [paramsOpt1{c,subject} LLopt_1process(c,subject)] = bads(habit_lik_constr1,paramsInit,LB,UB,PLB,PUB);
            [xx Lv1{c,subject}] = habit_lik_constr1(paramsOpt1{c,subject});
            
            paramsAOpt = paramsOpt1{c,subject}(1:3);
            paramsBOpt = paramsOpt1{c,subject}(4:6);
            paramsBOpt(3) = sigg(paramsBOpt(3));
            paramsAOpt(3) = sigg(paramsAOpt(3));
            % plot model predictions
            xplot=[.001:.001:1.2];
            presponse_1 = getResponseProbs_1process(xplot,paramsAOpt,paramsBOpt,sigg(paramsOpt1{c,subject}(7)));
            
            % -----fit flexi-habit model-----
            % add constraints for extra parameter
            LB(8) = 0;% = [0 0 0 0 0 -9 -9 0];
            UB(8) = 1;% = [10 100 9 10 10 9 -.04 1];
            PLB(8) = 0;% = [.2 .02 .5 .2 .02 0 -2 0];
            PUB(8) = 1;% = [.7 .5 9 .7 .5 9 -.5 1];

            habit_lik_constr_rho = @(params) habit_lik_rho(recodedX,recodedY,params(1:3),params(4:6),params(7),params(8)); % constrained function
            % find optimal parameters
            paramsInit = [paramsA(1:3) paramsB(1:3) sigg_inv(paramsA(4)) 0.5];
            paramsInit = max(paramsInit,LB);
            paramsInit = min(paramsInit,UB);
            
            %[paramsOpt LLopt_2process(c,subject)] = fminsearch(habit_lik_constr,paramsInit);
            [paramsOpt_rho{c,subject} LLopt_rho(c,subject)] = bads(habit_lik_constr_rho,paramsInit,LB,UB,PLB,PUB);
            [xx Lv2{c,subject}] = habit_lik_constr_rho(paramsOpt_rho{c,subject});
            
            paramsAOpt = paramsOpt_rho{c,subject}(1:3);
            paramsBOpt = paramsOpt_rho{c,subject}(4:6);
            paramsBOpt(3) = sigg(paramsBOpt(3));
            paramsAOpt(3) = sigg(paramsAOpt(3));
            % plot model predictions
            xplot=[.001:.001:1.2];
            presponse_rho = getResponseProbs_rho(xplot,paramsAOpt,paramsBOpt,sigg(paramsOpt_rho{c,subject}(7)),paramsOpt_rho{c,subject}(8));

            %-----plot data and fits------
            % plotting raw data...
            figure(subject); subplot(2,2,c);  hold on;  axis([0 1200 0 1.05]);
            plot([1:1200],unchanged,'--c','linewidth',1);
            plot([1:1200],revised,'--b','linewidth',1);
            plot([1:1200],habit,'--r','linewidth',1);
            %plotting model fit data...
            %plot([1:1200],p2,'b','linewidth',2);            
            plot([1:1200],p1,'c','linewidth',2);
            
            plot([1:1200],presponse_2(1,:),'b','linewidth',2)
            plot([1:1200],presponse_2(2,:),'r','linewidth',2)
            plot([1:1200],presponse_2(4,:),'r-.','linewidth',2)
            plot([1:1200],presponse_1(1,:),'b:','linewidth',2)
            plot([1:1200],presponse_1(2,:),'r:','linewidth',2)

            plot([1:1200],presponse_rho(1,:),'g:','linewidth',2)
            plot([1:1200],presponse_rho(2,:),'m:','linewidth',2) 

        end
    end
end

%% compare likelihoods
figure(100); clf; hold on
subplot(1,3,1); hold on
plot(log(LLopt_1process(1,:))-log(LLopt_2process(1,:)))
axis([0 25 -.15 .15])

subplot(1,3,2); hold on
plot(log(LLopt_1process(2,:))-log(LLopt_2process(2,:)))
axis([0 25 -.15 .15])

subplot(1,3,3); hold on
plot(log(LLopt_1process(3,:))-log(LLopt_2process(3,:)))
axis([0 25 -.15 .15])
%Lv_1proc = 

for c=1:3
    for subject=1:24
        if(~isempty(Lv1{c,subject}))
            BIC1(c,subject) = 2*4 + 2*LLopt_1process(c,subject);
            BIC2(c,subject) = 2*7 + 2*LLopt_2process(c,subject);
        else
            BIC1(c,subject) = NaN;
            BIC2(c,subject) = NaN;
        end
    end
end

figure(101); clf;
for c=1:3
    subplot(1,3,c); hold on
    plot(BIC1(c,:)-BIC2(c,:),'o')
    plot([0 25],[0 0],'k')
    axis([0 25 -20 60])
end
dBIC = BIC1-BIC2;

figure(102); clf; hold on
plot(nanmean(dBIC'),'o')
plot([1 1; 2 2; 3 3]',[nanmean(dBIC')+seNaN(dBIC');nanmean(dBIC')-seNaN(dBIC')],'b-')
plot([0 4],[0 0],'k')
xlim([.5 3.5])
