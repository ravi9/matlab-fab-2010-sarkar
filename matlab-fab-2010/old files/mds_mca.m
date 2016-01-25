function [X Y] = mds_mca (Affinity)
% This function performs MDS to arrive possible locations
% of the magnets such that their magnetic coupling matches
% the given affinities.
% We are assuming that the maximum possible affinity is 1
% and the minimum is 0. If it is not than its needs to be normalized into
% the range 0 and 1 
N = size(Affinity, 1);
% MaxAffinity = max(max(Affinity));
% if (MaxAffinity > 1)
%     fprintf(1, '\n Maximum affinity is greater than 1');
%     X = []; Y = [];
%     return;
% end
fprintf(1, '\n Symmetry measure for the affinity matrix: %f. It should be nearly zero.', norm(Affinity - Affinity'));
%% 
% Transform the affinities to Distances. Different transformations are
% possible. 

%fprintf(1, '\n Optimal solution vectors based on the given affinity matrix.');
%FindGlobalOptimum (Affinity);
%D = -(log(Affinity+eps));
% MaxAffinity = max(max(Affinity));
% D = 1 - Affinity/MaxAffinity;


D = (-log(Affinity+eps));
%D = (Affinity+eps).^-5;
D = (D > 0).*D;

% D = zeros(size(Affinity));
% for (i=1:N)
%     for (j=1:N)
%         if (i ~= j)
%             r = roots([1000*Affinity(i,j)/0.5 -3 0 1]);
%             D(i,j) = r(1);
%         end;
%     end;
% end;
% Set diagonal to zero (distance to itself is zero) and make it symmetrix
for (i=1:N) D(i, i) = 0.0; end;
D = 0.5*(D+D');

% set the weight matrix so as to ignore fraction of the "large distance values"
% [SD IX] = sort(reshape(D, 1, N*N), 'descend'); % sort the columns of D
% W = 0.8*(D < SD(round(N*N/8))) + 0.2;
% imagesc(W);
% pause;
% imagesc(W.*D);
% pause;
D = RestoreMetricProperty (D);
 opts = statset('display', 'iter');
 [Y,stress] = mdscale(D,2, 'criterion','stress', 'Options', opts );
%Y = cmdscale(D);
X = Y(:,1)'; Y  = Y(:, 2)';
plot(X, Y, 'o');
return;


% imagesc(D); pause;

% options.dims = 1:20; options.display = 1; options.verbose = 1; options.overlay = 0;
% [YY, R, E] = Isomap(D, 'k', 10, options); 
% X = YY.coords{2}(1,:); 
% Y = YY.coords{2}(2,:);
% return;
% % transform the distance to compress large distances.
% Dm = max(max(D))/3;
% c = 0.1;
% Mask = D.*(D > Dm);
% Mask = c*Mask + (1-c)*Dm;
% D = Mask.*(D > Dm) + D.*(D <= Dm);


%Weights = Affinity > 0.2;
%[Y,stress] = mdscale(D,2,'weights', Weights, 'start', Y, 'criterion','sammon' );
%Y = cmdscale(D);

% Computing the top 10 optimal solutions based MDS distances
% and magnetic coupling dependence.
%D2 = dist(Y(:,1:2)') + eps;
%D2 = 3*D2.^(-1) - D2.^(-3);
%for (i=1:N) D2(i, i) = 0.0; end;

%fprintf (1, '\n Projected optimal solution based on the distances computed and magnetic coupling.')
%FindGlobalOptimum(D2);




return;

function y = RestoreMetricProperty (D)
N = size(D, 1);

c = 0;
for i=1:N 
    for j=1:N
        for k=1:N
            c = max(c, max(0, D(i, j) - (D(i, k) + D(k, j))));
        end;
    end;
end;
y = D+c;
for i=1:N, y(i,i) = 0; end;

return;
%% - OLD CODE
N = size(Affinity, 1);
D = log(1 - Affinity);
% transformation (1/D or -D) is needed to change the affinities into distances...
%D = -log(D+eps)/10; D = D - min(min(D)); % use for images
%D = log(-log(Affinity+eps)); %D = D - min(min(D)); % use for example arrangement of lines
%D = D.^(-1); %D = D - min(min(D));
%D = log((max(max(D)) - D)+1)

% for (i=1:N) Affinity(i, i) = 0.0; end;
% %Affinity = Affinity - min(min(Affinity)) + 2.1;
% Affinity = 2.0*Affinity/max(max(Affinity));
% %Set the diagonal entried to zero
% D = size(Affinity);
% for (i=1:N)
%     for (j=1:N)
%         r = roots([Affinity(i,j) -3 0 1])
%         D(i,j) = r(2);
%         fprintf(1, '\n %d %d %f %f', i, j, Affinity(i, j), D(i,j));
%     end;
% end;
%Set the diagonal entried to zero
for (i=1:N) D(i, i) = 0.0; end;
%bar3(D); pause;

flag = 1;
while (flag == 1) 
   A = -0.5*D.^2;   
   OneMat = ones(N);
   I = eye(N);
   fprintf(1, '\n Computing Centering (H) matrix.......');
   H = I -  OneMat./N;
   fprintf(1,'\n Centering Distances: Computing B matrix.......');
   B = H * A * H;
   [EigenVectors, EigenValues] = eig(B, 'nobalance');
   EigenValues = diag (EigenValues);
   %plot(EigenValues); pause;

   if ~((isreal(EigenValues)) & (isreal(EigenVectors))) 
      fprintf(1, '\n ERROR: Something might be wrong with the distance matrix, possibly non-symmetric.');
      fprintf(1, '\n ERROR: It results in imaginary eigenvalues. Sum of imaginary part %f', sum(abs(imag(EigenValues))));
      fprintf(1, '\n Taking Real Part and continuing');
      EigenValues = real(EigenValues);
      EigenVectors = real(EigenVectors);
   end;
   MinEigenValue = min(EigenValues);
   if (MinEigenValue > -0.00001) flag = 0;
   else
      fprintf(1,'\n Minmum Eigenvalue: %f', MinEigenValue);
      c = -2 * MinEigenValue;
      %c = -MinEigenValue;
      [row, col] = size(B);
      fprintf(1,'Creating a positive definite B matrix by adding %f.......', c)
      D = (D+ c.*(ones(row, col) - diag(ones(1, row))));
      %D = sqrt(D.^2+ c.*(ones(row, col) - diag(ones(1, row))));
   end;
   %flag = 0;
end;
   
% Compute MDS coords

A = -0.5*D.^2;
B = H * A * H;
[V_MDS, Lambda_MDS] = eig(B, 'nobalance');
%plot(diag(Lambda_MDS)); pause;

if ~((isreal(Lambda_MDS)) & (isreal(V_MDS))) 
   fprintf(1, '\n ERROR: Something might be wrong with the distance matrix, possibly non-symmetric.');
   fprintf(1, '\n ERROR: It results in imaginary eigenvalues. Sum of imaginary part %f', sum(abs(imag(diag(Lambda_MDS)))));
   fprintf(1, '\n Taking Real Part and continuing');
   Lambda_MDS = real(Lambda_MDS);
   V_MDS = real(V_MDS);
end;
[Y,I] = sort(diag(-Lambda_MDS));
Lambda_MDS = diag(-Y(1:2));
Y = [];
% Next keep the top two eigenvectors
for (i=1:2) %consider only the top N-1 eigenvectors
   Y = [Y V_MDS(:,I(i))];
end;
V_MDS = Y;
Y_MDS = transpose(V_MDS * (Lambda_MDS.^0.5));

%Y_MDS = ([0, 0; Y_MDS']'); 
% an extra to serve as Cell at the center to serve as the input


X = (Y_MDS(1, :));
Y = (Y_MDS(2, :));



