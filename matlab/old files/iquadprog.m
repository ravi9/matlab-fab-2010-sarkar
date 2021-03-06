function [sbest ebest] = iquadprog (A, kmax)
% Maximizes x'*A*x/(x'x) where x is a vector of 0 and 1
% patterned after pseudo code for simulated annealing on wikipedia

close all;

% Initialize based on thresholding of the dominant eigenvector
[V, D] = eigs(A);
N = size(A, 1);
s = single(abs(V(:,1)) >= (1/(N))); 
e = (s'*A*s)./(s'*s); %Initial state, energy.

sbest = s; ebest = e; % Initial "best" solution
T0 = e/100; %Temperature
k = 0; kupdate = 0;
while k < kmax % time since last best value found.
    snew = s; i = ceil(N.*rand); snew(i) = 1 - snew(i); 
    %Pick some edge, flip the state of the components
    enew = (snew'*A*snew)./(snew'*snew);
    if (enew > ebest) 
        sbest = snew; ebest = enew; kupdate = k; % Is this a new best?
    end;
    T = T0*k/kmax;
    if (exp((enew - ebest)/T) > rand) % Should we move to it? compare with best so far...
        s = snew; e = enew;  % Yes, change state.
    end;
    if (rem(k, 100) == 1) plot(k, e, 'o'); plot(k, ebest, 'gx');hold on; pause (0.0001); end;
    k = k + 1;
end;




