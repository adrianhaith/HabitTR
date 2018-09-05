function presponse = getResponseProbs(RT,params)
% returns response probabilities (correct, habit, error) given RTs and
% parameters
%
% params = [mu1; 
%           sigma1; 
%           mu2; 
%           sigma2;
%           ...;
%           asymptotic error;
%           init error;
%           habit strength (rho); - probability of habitual expression
%           lapse rate (rho2)] - probability of not retrieving correct response

Nresponses = 2; % always assume two responses
mu(1:2) = [params(1) params(3)];
var(1:2) = [params(2) params(4)];

q(1) = .95; % asymptotic error for first process
q(2) = params(5); % asymptotic error for second process
init_err(1:2) = params(6:7); % initial error rates for habitual and goal-directed responses
rho(1:2) = params(8:9); % lapse rate for habit and goal-directed response selection

for i=1:Nresponses
    Phi(i,:) = rho(i)*normcdf(RT,mu(i),var(i)); % probability that A has been planned by RT
end
%PhiB = normcdf(RT,paramsB(1),paramsB(2));

% build Alpha
switch(Nresponses)
    % set up parameters:
    %     p(r) = alpha(.,1)*(1-PhiA)*(1-PhiB) + alpha(.,2)*PhiA*(1-PhiB) +
    %     alpha(.,3)*(1-PhiA)*PhiB + alpha(.,4)*PhiA*PhiB

    case 1
        Alpha(1,:) = [initAE q(1)]; % [p(r=A|!A) p(r=A|A)]
        Alpha(2,:) = [1-initAE (1-q(1))]; % [p(r=B|!A) p(r=B|A)]
        %Alpha(3,:) = [.5-initAE (1-qA)/3 (1-qB)/3 (1-qB)/3]; % other responses
        %Alpha(4,:) = [initAE qA initAE qA]; % mapping A, no-conflict
        %Alpha(5,:) = [initAE initAE qB qB]; % mapping B, no-conflict
        
        PhiAll = [1-Phi(1,:); Phi(1,:)];
        
    case 2
        if(incongruent)
            Alpha(1,:) = [initAE(1) (1-q(1))/3 q(2) q(2)]; % [p(r=B|!A!B) p(r=B|A!B) p(r=B|!AB) p(r=B|AB)] 
            Alpha(2,:) = [initAE(2) q(1) (1-q(2))/3 (1-q(2))/3]; % [p(r=A|!A!B) p(r=A|A!B) p(r=A|!AB) p(r=A|AB)]
            Alpha(3,:) = [1-initAE(1)-initAE(2) (1-q(1))/3 2*(1-q(2))/3 2*(1-q(2))/3]; % [p(r=C|!A!B) p(r=C|A!B) p(r=C|!AB) p(r=C|AB)]
            Alpha(4,:) = [initAE q(1) initAE q(1)]; % p(r=A), no-conflict
            Alpha(5,:) = [initAE initAE q(2) q(2)]; % p(r=B), no-conflict
            
            PhiAll = [(1-Phi(1,:)).*(1-Phi(2,:)); Phi(1,:).*(1-Phi(2,:)); (1-Phi(1,:)).*Phi(2,:); Phi(1,:).*Phi(2,:)];
           
            %keyboard
        else
            Alpha(1,:) = [.25 q(1) .25 .25]; % [p(r=A|!A!B) p(r=A|A!B) p(r=A|!AB) p(r=A|AB)]
            Alpha(2,:) = [.25 .25 q(2) q(2)]; % [p(r=B|!A!B) p(r=B|A!B) p(r=B|!AB) p(r=B|AB)]
            Alpha(3,:) = [.25 .25 .25 .25]; % [p(r=C|!A!B) p(r=C|A!B) p(r=C|!AB) p(r=C|AB)]
            Alpha(4,:) = [initAE q(1) initAE q(1)]; % p(r=A), no-conflict
            Alpha(5,:) = [initAE initAE q(2) q(2)]; % p(r=B), no-conflict
            
            PhiAll = [(1-Phi(1,:)).*(1-Phi(2,:)); Phi(1,:).*(1-Phi(2,:)); (1-Phi(1,:)).*Phi(2,:); Phi(1,:).*Phi(2,:)];
        end
        
    otherwise disp('No such case - 1 or 2')
end
        
%for i=1:5
%    presponse(i,:) = alpha(i,1)*(1-PhiA).*(1-PhiB) + alpha(i,2)*PhiA.*(1-PhiB) + alpha(i,3)*(1-PhiA).*PhiB + alpha(i,4)*PhiA.*PhiB;
%end


%Phi = [(1-PhiA).*(1-PhiB); PhiA.*(1-PhiB); (1-PhiA).*PhiB; PhiA.*PhiB];
presponse = Alpha*PhiAll;