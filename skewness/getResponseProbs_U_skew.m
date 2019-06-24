function presponse = getResponseProbs(RT,params,Nresponses)
% returns response probabilities (correct, habit, error) given RTs and
% parameters
%
% params = [mu1; 
%           sigma1; 
%           mu2; 
%           sigma2;
%           ...;
%           asymptotic error;
%           default habit rate;
%           default no-habit rate;
%           habit strength (rho); - probability of habitual expression
%           lapse rate (rho2)] - probability of not retrieving correct response
if(nargin<3)
    Nresponses = 2; % always assume two responses unless otherwise specified
end

if(Nresponses==2)
    mu(1:2) = [params(1) params(3)];
    var(1:2) = [params(2) params(4)];
    
    q(1) = .95; % asymptotic error for first process
    q(2) = params(5); % asymptotic error for second process
    init_err = params(6); % initial error rates for habitual and goal-directed responses
    rho(1:2) = 1-params(7:8); % lapse rate for habit and goal-directed response selection
else
    mu = params(1);
    var = params(2);
    q(1) = .95;
    q(2) = params(3);
    init_err = params(4);
    lambda = params(5);
end

for i=1:Nresponses
    Phi(i,:) = normcdf(RT,mu(i),var(i)); % probability that A has been planned by RT
    
    % ex-Gaussian distribution
    u = lambda*(RT-mu);
    v = lambda*var;
    Phi(i,:) = normcdf(u,0,v) - exp(-u+v.^2/2+log(normcdf(u,v.^2,v)));
end

% build Alpha
switch(Nresponses)
    % set up parameters:
    %     p(r) = alpha(.,1)*(1-PhiA)*(1-PhiB) + alpha(.,2)*PhiA*(1-PhiB) +
    %     alpha(.,3)*(1-PhiA)*PhiB + alpha(.,4)*PhiA*PhiB

    case 1
        Alpha(1,:) = [init_err q(1)]; % [p(r=A|!A) p(r=A|A)]
        Alpha(2,:) = [1-init_err (1-q(1))]; % [p(r=B|!A) p(r=B|A)]
        %Alpha(3,:) = [.5-initAE (1-qA)/3 (1-qB)/3 (1-qB)/3]; % other responses
        %Alpha(4,:) = [initAE qA initAE qA]; % mapping A, no-conflict
        %Alpha(5,:) = [initAE initAE qB qB]; % mapping B, no-conflict
        
        PhiAll = [1-Phi(1,:); Phi(1,:)];
        P = eye(2);
    case 2

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
            
            %keyboard
%{
            Alpha(1,:) = [.25 q(1) .25 .25]; % [p(r=A|!A!B) p(r=A|A!B) p(r=A|!AB) p(r=A|AB)]
            Alpha(2,:) = [.25 .25 q(2) q(2)]; % [p(r=B|!A!B) p(r=B|A!B) p(r=B|!AB) p(r=B|AB)]
            Alpha(3,:) = [.25 .25 .25 .25]; % [p(r=C|!A!B) p(r=C|A!B) p(r=C|!AB) p(r=C|AB)]
            Alpha(4,:) = [initAE q(1) initAE q(1)]; % p(r=A), no-conflict
            Alpha(5,:) = [initAE initAE q(2) q(2)]; % p(r=B), no-conflict
            
            PhiAll = [(1-Phi(1,:)).*(1-Phi(2,:)); Phi(1,:).*(1-Phi(2,:)); (1-Phi(1,:)).*Phi(2,:); Phi(1,:).*Phi(2,:)];
        end
            %}
        
    otherwise disp('No such case - 1 or 2')
end
        
%for i=1:5
%    presponse(i,:) = alpha(i,1)*(1-PhiA).*(1-PhiB) + alpha(i,2)*PhiA.*(1-PhiB) + alpha(i,3)*(1-PhiA).*PhiB + alpha(i,4)*PhiA.*PhiB;
%end


%Phi = [(1-PhiA).*(1-PhiB); PhiA.*(1-PhiB); (1-PhiA).*PhiB; PhiA.*PhiB];
presponse = Alpha*P*PhiAll;