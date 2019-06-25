function model = fit_model(RT,response,fixed_params,optimizer)
% fits selection model to forced RT data by max. likelihood
%
% Inputs:
%       RT - vector of reaction times for each trial (in s)
%       response - vector of response IDs (1 = spatial, 2 = symbolic, 3 =
%       other)
%       Nprocesses - (1-3) number of processes (and, accordingly, response types)
%       fixed_params - parameters to be fixed. Vector of parameters,
%                      containing fixed values. Use NaN to keep a parameter open.
%       simplified   - flag to fit simplified model that doesn't
%                      distinguish between correct responses and non-habitual errors
%       
% Outputs:
%       params - optimized parameters
%       presponse - time-varying response probabilities
%
%
% Model parametrization:
%       params = [ [mu_i sigma_i] - mean and variability of RT
%                                   distribution for each process
%                   qN            - asymptotic error for last process
%                   qInit         - lower asymptotic error
%                   rho1          - habit strength
%                   rho2]         - lapse rate for goal-directed response
%
if(length(fixed_params)==8)
    Nprocesses=2;
elseif(length(fixed_params)==4)
    Nprocesses=1;
else
    error('incorrect number of parameters - must be 4 (1-process) or 8 (2-process)')
end
    
if(nargin < 3) % leave all parameters open unless specified
    fixed_params = NaN*ones(1,8);
end

%optimizer='fmincon'; % 'bads' or 'fmincon'. 'bads' is more exhaustive, but much slower
if(nargin<4)
    optimizer = 'fmincon';
end

% set up bounds for model
LB_soft = .0001; % lower bound close to 0
UB_soft = .9999; % upper bound close to 1

% set up bounds and constraints
paramsInit = [.4 .05 .5 .05 .95 .2 .2 1];
LB = [0 .01 0 .01 .5 LB_soft 0 .5];
%PLB = [.2 .02 .2 .02 .6 .1 LB_soft];
UB = [.75 100 .75 100 UB_soft .5 1 1];
%PUB = [.7 .1 .7 .1 UB_soft .4 UB_soft];

A = [1 0 -1 0 0 0 0 0]; B = [0]; % inequality constraints (mu1 < mu2)
        

% fix parameters
switch(optimizer)
    case 'fmincon'
        Aeq = []; Beq = [];
        i_fix = find(~isnan(fixed_params));
        if(length(i_fix>0))
            for i=1:length(i_fix)
                Ai = zeros(size(paramsInit));
                Ai(i_fix(i)) = 1;
                Aeq = [Aeq; Ai];
                Beq = [Beq; fixed_params(i_fix(i))];
            end
        end
    case 'bads'
        i_fix = find(~isnan(fixed_params));
        LB(i_fix) = fixed_params(i_fix);
        UB(i_fix) = fixed_params(i_fix);
end


% lock in initial parameter estimates
paramsInit(i_fix) = fixed_params(i_fix);


%keyboard

% weed out bad trials
good_trials = ~isnan(RT);
RT = RT(good_trials);
response = response(good_trials);


like_fun = @(params) habit_lik_non_independent(RT,response,params,Nprocesses);



model.xplot = [.001:.001:1.2];
model.nLL_init = like_fun(paramsInit);
%keyboard
switch(optimizer)
    case 'bads'
        [model.paramsOpt, model.LLopt] = bads(like_fun,paramsInit,LB,UB);
        
    case 'fmincon'
        % increase maximum number of function evaluations
        options = optimset('MaxFunEvals',1000);
        %[model(m).paramsOpt(subject,:,c), model(m).LLopt(c,subject)] = fmincon(like_fun,paramsInit,A,B,Aeq,Beq,LB,UB);
        [model.paramsOpt, model.LLopt] = fmincon(like_fun,paramsInit,A,B,Aeq,Beq,LB,UB);
end

model.presponse = getResponseProbs_non_independent(model.xplot,model.paramsOpt,Nprocesses)
[model.nLL model.Lv model.LL] = like_fun(model.paramsOpt);
                
model.nParams = sum(isnan(fixed_params)); % number of free parameters
model.AIC = 2*model.nParams - 2*model.LL; % AIC

%keyboard
%{
% plot fit
data_sw = sliding_window(RT,2-response,model.xplot,.05)
figure(1); clf; hold on
plot(model.xplot,data_sw)
plot(model.xplot,model.presponse(1,:))
%}