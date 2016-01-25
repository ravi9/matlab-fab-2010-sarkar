function y = SpectralKMeans (Affinity, Lines)
% Performs a spectral K-means.
% Affinity is the adjacency matrix of the pairwise affinity graph
% First, embed the nodes in an Euclidean space and then perform K means.
close all;

A = 0.5*(Affinity + Affinity'); %Turn into symmetric matrix
[Y E] = cmdscale (-log(A)); 
% compute coordinates, Y % Y is an n-by-p configuration matrix. 
% Rows of Y are theq coordinates of n points in p-dimensional space for some p < n.

for NumClusters = 2:10
    [IDX C sumd] = kmeans(Y,NumClusters);
    sum(sumd)
    % cluster the points in the n-by-p data matrix Y into NumClusters cluster

    for i=1:length(IDX)
        for (j=1:Lines(i).length)
            OutputImage(Lines(i).y(j), Lines(i).x(j)) = IDX(i)*255/NumClusters;
        end;
    end;
    figure; imagesc(OutputImage);
end;