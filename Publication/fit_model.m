function model = fit_model(RT,response,Nprocesses)
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
%                rho]         - lapse rate for goal-directed response (in [0,1]
%

% initialize parameters
paramsInit = [.4 .1 .6 .1 .95 .2 1];

% set up bounds and constraints

% set up soft bounds for model (needed to avoid breaking optimizer if
% likelihood == 0)
LB_soft = .0001; % lower bound close to 0
UB_soft = .9999; % upper bound close to 1


LB = [0 .01 0 .01 .5 LB_soft LB_soft];
UB = [.75 100 .75 100 UB_soft .5 UB_soft];

A = [1 0 -1 0 0 0 0]; B = [0]; % inequality constraint (mu1 < mu2)

% eliminate bad trials (denoted by RT=NaN)
good_trials = ~isnan(RT);
RT = RT(good_trials);
response = response(good_trials);

% create function handle for likelihood
like_fun = @(params) habit_lik(RT,response,params,Nprocesses);

%-- perform optimization --
% set optimization options
optcon = optimoptions('fmincon','display','iter','MaxFunEvals',30000);
[model.paramsOpt] = fmincon(like_fun,paramsInit,A,B,[],[],LB,UB);
if(Nprocesses==1)
    model.paramsOpt([1 2 7]) = NaN; % for clarity, blank out redundant parameters with NaNs
end

model.tplot = [.001:.001:1.2]; % time (useful for plotting
model.presponse = getResponseProbs(model.tplot,model.paramsOpt,Nprocesses) % time-varying response probabilities
[model.nLL model.Lv model.LL] = like_fun(model.paramsOpt);
                
if(Nprocesses==1)
    model.nParams = 4; % number of free parameters for no-habit model
else
    model.nParams = 7; % number of free parameters habit model
end
model.AIC = 2*model.nParams - 2*model.LL; % AIC
