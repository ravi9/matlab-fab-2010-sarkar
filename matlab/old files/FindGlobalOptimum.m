function [x val] = FindGlobalOptimum (A)
%% finds the binary vector x that optimizes x'Ax/x'x
n = size(A, 1);
N = 2^n;
fprintf(1, '\n Search space size %d', N);
maxK_val = -99999.0 * ones(1, 10);
max_x = zeros(1, 10);
hold off;
for i=1:N
    x = bitget(i, [1:n]');
    if sum(x) ~= 0
        val = (x'*A*x)/(x'*x);
        plot(i, val, '*'); hold on;
        for j = 1:10
            if maxK_val(j) < val
                maxK_val(j) = val;
                max_x(j) = i;
                break;
            end;
        end;
    end;
end;
hold off;
fprintf(1, '\n Top 10 solutions');
for j = 1:10
    fprintf(1, '\n Val = %f vector: ', maxK_val(j));
    fprintf(1, '%d ', bitget(max_x(j), [1:n]'));
end;

x = bitget(max_x(1), [1:n]);
val = maxK_val(1);
