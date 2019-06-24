% habit model fitting example
clear all

%---- load some example data
load example_data
% data.RT = vector of reaction times
% data.response = vector of responses: 
%                   1 = correct response,
%                   2 = habitual error,
%                   3 = other error

%---- calculate and plot sliding windows
w = .075; % sliding window width
xplot = [.001:.001:1.2]; % x values to compute the sliding window over
for i=1:3
    data.sw(i,:) = sliding_window(data.RT,data.response==i,xplot,w);
end
figure(1); clf; hold on
plot(data.sw(1,:),'b')
plot(data.sw(2,:),'r')
plot(data.sw(3,:)/2,'m') % NB divide by two since this covers two possible responses

%---- fit model
% 1. Determine which parameters to constrain
% params =  mu_A
%           sigma_A
%           mu_B
%           sigma_B
%           q_B - asymptotic error for goal-directed response
%           q_I - lower asymptotic error (for 'guesses')
%           rho_A - probability that habitual response is prepared
%           rho_B - probability that goal-directed response is prepared

% determine which parameters to constrain (NaN = unconstrained)
params_constrain = [NaN NaN NaN NaN NaN NaN 1 NaN]; % in this case, assume rho_A = 1 (recommended version of 'habit' model)

% fit the model
model = fit_model(data.RT,data.response,params_constrain,'fmincon')% NB - last argument here is the optimizer to use - either 'fmincon', or 'bads'. 'fmincon' recommended as it is much faster, but 'bads' more thorough

% plot results
figure(1)
plot(model.presponse(1,:),'b','linewidth',2)
plot(model.presponse(2,:),'r','linewidth',2)
plot(model.presponse(3,:)/2,'m','linewidth',2) % NB divide by two since this covers two possible responses