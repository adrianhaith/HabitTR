function presponse = getResponseProbs(RT,params,Nprocesses)
% returns response probabilities (correct, habit, error) given RTs and
% parameters. Which model is simulated (habit model or no-habit model) is
% determined by the length of the 'params' input vector.
%
% no-habit model:
%   params = [mu;  (mean time response is prepared)
%             sigma; (variance)
%             q; (probability correct response is selected)
%             qI]; (initial error rate at low RT)
%
% habit model:
%   params = [muA; (mean time habitual response is prepared)
%             sigmaA; (variance)
%             muB;  (mean time goal-directed response is prepared)
%             sigmaB; (variance)
%             qB; (probability goal-directed response is selected correctly)
%             qI; (initial error rate at low RT)
%             rho] (probability that goal-directed response does not replace habitual response)

if(Nprocesses == 1) % no-habit model
    mu = params(3);
    sigma = params(4);
    q = params(5)*[1 1];
    q_I = params(6);
    for i=1:2
        Phi(i,:) = normcdf(RT,mu,sigma); % probability that A has been planned by RT
    end
else % habit model
    mu(1:2) = [params(1) params(3)];
    sigma(1:2) = [params(2) params(4)];
    q(1) = .95; % asymptotic error for first process
    q(2) = params(5); % asymptotic error for second process
    q_I = params(6); % initial error rates for habitual and goal-directed responses
    rho = 1-params(8); % lapse rate for habit and goal-directed response selection
    for i=1:Nprocesses
        Phi(i,:) = normcdf(RT,mu(i),sigma(i)); % probability that A has been planned by RT
    end
end

for i=1:Nprocesses
    Phi(i,:) = normcdf(RT,mu(i),sigma(i)); % probability that A has been planned by RT
end
% build Alpha
            % distribution of responses (rows: rA, rB, other) given
            % different events (columns) (!A!B, A!B, !AB, AB)
            Alpha(1,:) = [q_I (1-q(1))/3 q(2) q(2)]; % [p(r=B|!A!B) p(r=B|A!B) p(r=B|!AB) p(r=B|AB)] 
            Alpha(2,:) = [q_I q(1) (1-q(2))/3 (1-q(2))/3]; % [p(r=A|!A!B) p(r=A|A!B) p(r=A|!AB) p(r=A|AB)]
            Alpha(3,:) = [1-2*q_I 2*(1-q(1))/3 2*(1-q(2))/3 2*(1-q(2))/3]; % [p(r=C|!A!B) p(r=C|A!B) p(r=C|!AB) p(r=C|AB)]
            Alpha(4,:) = [q_I q(1) q_I q(1)]; % no-conflict p(r=A), i.e. probability of selecting A if there were no conflict from B
            Alpha(5,:) = [q_I q_I q(2) q(2)]; % no-conflict p(r=B), i.e. probability of selecting B if there were no conflict from A
            
            PhiAll = [(1-Phi(1,:)).*(1-Phi(2,:)); Phi(1,:).*(1-Phi(2,:)); (1-Phi(1,:)).*Phi(2,:); Phi(1,:).*Phi(2,:)];
           
            % probability of each event occurring (rows) given different timing 
            %   columns: [t<tA,t<tB; t>tA,t<tB; t<tA,t>tB; t>tA,t>tB]
            % NB - this matrix differentiates between the two models
            
            if(Nprocesses==1)
                %rho(1)=0
                R = [1 1 0 0; % p(!A!B)
                    0 0 0 0; % p(A!B)
                    0 0 1 1; % p(!AB)
                    0 0 0 0]; % p(AB)
            else
                %R = [1 rho(1) rho(2) rho(1)*rho(2); % p(!A!B)
                %    0 1-rho(1) 0 (1-rho(1))*rho(2); % p(A!B)
                %    0 0 (1-rho(2)) rho(1)*(1-rho(2)); % p(!AB)
                %    0 0 0 (1-rho(1))*(1-rho(2))]; % p(AB)
                
                R = [1 0    rho     0; % p(!A!B)
                     0 1    0     rho; % p(A!B)
                     0 0  (1-rho)  0; % p(!AB)
                     0 0    0    1-rho]; % p(AB)
            end
presponse = Alpha*R*PhiAll;