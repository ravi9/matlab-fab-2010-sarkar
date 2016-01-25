function y = LayoutAffinityMatch(Affinity, threshold, minNodes)
% Assumes that it is passed an affinity matrix
% Find connected components, based on "threshold" percentile of the Affinity
% distribution and then find out the layout for each component. 
% The output "y" is an array of structures with the layout of each
% component,i.e. y(i).X and y(i).Y, the indices of the original features
% that participate in the component, y(i).indices, and y(i).affinity -- the
% submatrix of the full affinity corresponding to the original component.

y = [];

%% Find Connected Components
N = size(Affinity, 1);
val = sort(reshape(Affinity, 1, N*N));
val = val(round(threshold*N*N))
UAffinity = Affinity > val;

%Components = ones(1, size(Affinity, 1)); Nc = N;
[Components Nc] = FindConnectedComponents (UAffinity);
fprintf(1, '\n Affinity thresholded at %f (fraction) has %d components', threshold, Nc);

%% For each connected component greater than minNodes, find the MDS layout.
for (k=1:Nc)
    nodes = find(Components == k);
    if (length(nodes) > minNodes) % atleast minNodes in a component to be processed further
        kAffinity = Affinity(nodes, nodes);
        %imagesc(kAffinity);   pause;
        kDistances = ChangeToDistances(kAffinity);
        kDistances = RestoreMetricProperty (kDistances);
        [X Y] = MDS (kDistances);
        kk = length(y)+1;
        y(kk).X = X; y(kk).Y = Y; y(kk).indices = nodes; y(kk).affinity = kAffinity;
    end;
end;

%% Perform MDS on and return first two coordinates
function [X Y] = MDS (D);
 opts = statset('display', 'iter');
% [Y,stress] = mdscale(D,2, 'criterion','stress', 'Options', opts );
Y = cmdscale(D);
X = Y(:,1); Y  = Y(:, 2); 

subplot(2,2,1); plot(X, Y, 'o'); pause;

%% Restore metric property, i.e. d(x, z) <= d(X, y) + d(y, z)
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
fprintf(1, '\n Restoring metrix property by adding %f', c);
y = D+c;
for i=1:N, y(i,i) = 0; end;

return;
%% Change Affinities to Distances. Affinities could be larger than one.

function D = ChangeToDistances (A)

D = (-log(A+eps));
D = (D > 0).*D; %% to remove very small negative created values due to numerical issues
N = size(D, 1);
for (i=1:N) D(i, i) = 0.0; end; %% Restore diagonal to zero distances
D = 0.5*(D+D'); % make the matrix symmetric.


%% The following two function taken together finds the connected component
%% of a graph (undirected) by depth-first searching. It returns the number
%% of labels and the components as a vector.
function [Y label] = FindConnectedComponents (A)
% A is the adjacency matrix of an undirected graph
N = size(A, 1);
Y = zeros(1, N);
label = 1;
for i=1:N
    if Y(i) == 0
        Y = FindRecur (A, i, Y, label);
        label = label+1;
    end;
end;
label = label-1;

function Y = FindRecur (A, node, X, label)

N = size(A, 1);
X(node) = label;
for i = 1:N
    if ((A(node, i) > 0)&&(X(i) == 0))
       X = FindRecur (A, i, X, label);
    end;
end;

Y = X;

