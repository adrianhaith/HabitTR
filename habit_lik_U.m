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

% get probabilites of each response at each RT
presponse = getResponseProbs_U(RT,params,Nprocesses);

% build vector of likelihoods for observed responses
RR = zeros(size(presponse)); % binary 3 x N matrix 
for i=1:Nprocesses+1
    RR(i,response==i)=1;
end
Lv = sum(RR.*presponse);

% convert to vector of log-likelihoods
LLv = log(Lv); % log-likelihood vector

% penalty terms
aa =500; % cost weight on slope
slope0 = .1; % prior on slope

% compute total, penalized, negative log-likelihood
switch Nprocesses
    case 1
        nLL = -sum(LLv) + aa*(params(2)-slope0)^2;
    case 2
        nLL = -sum(LLv) + aa*(params(2)-slope0)^2 + aa*(params(4)-slope0)^2;
    case 3
        nLL = -sum(LLv) + aa*(params(2)-slope0)^2 + aa*(params(4)-slope0)^2 + aa*(params(6)-slope0)^2;
end
LL= sum(LLv); % true log-likelihood (without penalty)

%keyboard
%% debugging
%{
% sliding window on each response
xplot = [0:.001:1.2];
w = .075;
for i=1:length(xplot)
    igood = find(RT>xplot(i)-w/2 & RT<xplot(i)+w/2);
    if(~isempty(igood))
        pcorrect(i) = sum(response(igood)==1)/length(igood);
        phabit(i) = sum(response(igood)==2)/length(igood);
        perror(i) = sum(response(igood)==3)/length(igood);
    else
        pcorrect(i) = NaN;
        phabit(i) = NaN;
        perror(i) = NaN;
    end
end
figure(6); clf; hold on
plot(xplot,pcorrect,'b--')
plot(xplot,phabit,'r--')
plot(xplot,perror/2,'k--')


PhiAplot = normcdf(xplot,paramsA(1),paramsA(2)); % probability that A has been planned by RT
PhiBplot = normcdf(xplot,paramsB(1),paramsB(2));

PhiA2plot = normcdf(xplot,paramsA(1),paramsA(2));       
lstyle = {'b','r','k'};
for i=1:3
    phit(i,:) = alpha(i,1)*(1-PhiAplot).*(1-PhiBplot) + alpha(i,2)*PhiAplot.*(1-PhiBplot) + alpha(i,3)*PhiBplot;
    plot(xplot,phit(i,:),lstyle{i});
    
end
phitA(i,:) = .25*(1-PhiA2plot)+qA*PhiA2plot;
plot(xplot,phitA,'c')
%keyboard
%}
end

