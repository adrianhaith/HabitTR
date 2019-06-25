function [nLL Lv LL] = habit_lik(RT,response,params,Nprocesses)
% computes likelihood of observed responses under automaticity model
% inputs:
%   RT - N x 1 reaction time for each trial
%   response - N x 1 response for each trial; 1 = correct, 
%                                             2 = habit,
%                                             3 = other error
%
%   params - parameters of the model
%            [sigmaA muA qA sigmaB muB qB]; (q = probability of error in
%                                            each process)
%   Nprocesses - Number of processes: 1 (no-habit model) or 2 (habit model)
%
% output:
%   nLL - negative log-likelihood (includes penalty term for slope)
%   Lv  - vector containing log-likelihood for each trial
%   LL  - log-likelihood (without penalty term for slope)
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

% get probabilites of each response at each RT
presponse = getResponseProbs(RT,params,Nprocesses);

% build vector of likelihoods for observed responses
RR = zeros(size(presponse)); % binary 3 x N matrix 
for i=1:3
    RR(i,response==i)=1;
end
Lv = sum(RR.*presponse);

% convert to vector of log-likelihoods
LLv = log(Lv); % log-likelihood vector

% penalty terms
lambda =500; % cost weight on slope
sigma0 = .1; % prior on slope

% compute total, penalized, negative log-likelihood
nLL = -sum(LLv) + lambda*(params(2)-sigma0)^2 + lambda*(params(4)-sigma0)^2;
LL= sum(LLv); % true log-likelihood (without penalty)


