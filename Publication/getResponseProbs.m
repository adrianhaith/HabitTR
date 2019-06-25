function presponse = getResponseProbs(RT,params)
% returns response probabilities (correct, habit, error) given RTs and
% parameters
%
% params = [mu1; 
%           sigma1; 
%           mu2; 
%           sigma2;
%           asymptotic error;
%           initial error;
%           habit strength (rho); - probability of habitual expression
%           lapse rate (rho2)] - probability of not retrieving correct response
mu(1:2) = [params(1) params(3)];
var(1:2) = [params(2) params(4)];

q(1) = .95; % asymptotic error for first process
q(2) = params(5); % asymptotic error for second process
init_err = params(6); % initial error rates for habitual and goal-directed responses
rho(1:2) = 1-params(7:8); % lapse rate for habit and goal-directed response selection

for i=1:2
    Phi(i,:) = normcdf(RT,mu(i),var(i)); % probability that A has been planned by RT
end

% build Alpha
            % distribution of responses (rows: rA, rB, other) given
            % different events (columns) (!A!B, A!B, !AB, AB)
            Alpha(1,:) = [init_err (1-q(1))/3 q(2) q(2)]; % [p(r=B|!A!B) p(r=B|A!B) p(r=B|!AB) p(r=B|AB)] 
            Alpha(2,:) = [init_err q(1) (1-q(2))/3 (1-q(2))/3]; % [p(r=A|!A!B) p(r=A|A!B) p(r=A|!AB) p(r=A|AB)]
            Alpha(3,:) = [1-2*init_err 2*(1-q(1))/3 2*(1-q(2))/3 2*(1-q(2))/3]; % [p(r=C|!A!B) p(r=C|A!B) p(r=C|!AB) p(r=C|AB)]
            Alpha(4,:) = [init_err q(1) init_err q(1)]; % p(r=A), no-conflict
            Alpha(5,:) = [init_err init_err q(2) q(2)]; % p(r=B), no-conflict
            
            PhiAll = [(1-Phi(1,:)).*(1-Phi(2,:)); Phi(1,:).*(1-Phi(2,:)); (1-Phi(1,:)).*Phi(2,:); Phi(1,:).*Phi(2,:)];
           
            % probability of each event occurring (rows) given different
            % (1 = certain to occu)
            % timing events (columns) [t<tA,t<tB; t>tA,t<tB; t<tA,t>tB; t>tA,t>tB
            P = [1 rho(1) rho(2) rho(1)*rho(2); % p(!A!B) given different timing events
                0 1-rho(1) 0 (1-rho(1))*rho(2); % p(A!B) 
                0 0 (1-rho(2)) rho(1)*(1-rho(2)); % p(!AB)
                0 0 0 (1-rho(1))*(1-rho(2))]; % p(AB)
        
        
presponse = Alpha*P*PhiAll;