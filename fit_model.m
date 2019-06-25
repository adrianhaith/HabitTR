function model = fit_model(RT,response,fixed_params,optimizer)
% fits selection model to forced RT data by max. likelihood
%
% Inputs:
%       RT - vector of reaction times for each trial (in s)
%       response - vector of response IDs (1 = spatial, 2 = symbolic, 3 =
%       other)
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
%       params = mu_1         - mean and variance of time at which habitual
%                sigma_1            response becomes prepared (in seconds)
%                mu_2         - mean and variance of time at which
%                sigma_2            goal-directed response becomes prepared (in seconds)
%                qN            - asymptotic error for last process (in [0,1])
%                qInit         - lower asymptotic error (in [0,1])
%                rho1          - habit strength (in [0,1])
%                rho2]         - lapse rate for goal-directed response (in [0,1]
%
if(length(fixed_params)==8)
else
    error('incorrect number of parameters - must 8')
end
    
if(nargin < 3) % leave all parameters open unless specified
    fixed_params = NaN*ones(1,8);
end

% set up bounds for model (best to avoid hard bound of 0 or 1 since these can lead to likelihood of 0, and ruins optimization)
LB_soft = .0001; % lower bound close to 0
UB_soft = .9999; % upper bound close to 1

% set up bounds and constraints
paramsInit = [.4 .05 .5 .05 .95 .2 .2 1]; % nominal initial parameters
LB = [0 .01 0 .01 .5 LB_soft 0 .5]; % lower bound on parameters
UB = [.75 100 .75 100 UB_soft .5 1 1]; % upper bound on parameters

A = [1 0 -1 0 0 0 0 0]; B = [0]; % inequality constraints (mu1 < mu2)
        
% fix parameters
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



% lock in initial parameter estimates
paramsInit(i_fix) = fixed_params(i_fix);


%keyboard

% weed out bad trials
good_trials = ~isnan(RT);
RT = RT(good_trials);
response = response(good_trials);


like_fun = @(params) habit_lik_U(RT,response,params,Nprocesses);



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

model.presponse = getResponseProbs_U(model.xplot,model.paramsOpt,Nprocesses)
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
