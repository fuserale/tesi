function D = distfun(X, C, dist, iter)

% References:
%
%   [1] Seber, G.A.F. (1984) Multivariate Observations, Wiley, New York.
%   [2] Spath, H. (1985) Cluster Dissection and Analysis: Theory, FORTRAN
%       Programs, Examples, translated by J. Goldschmidt, Halsted Press,
%       New York.

%   Copyright 1993-2008 The MathWorks, Inc.
%   $Revision: 1.4.4.10 $  $Date: 2008/06/20 09:05:10 $

%DISTFUN Calculate point to cluster centroid distances.
[n,p] = size(X);
D = zeros(n,size(C,1));
nclusts = size(C,1);

switch dist
case 'sqeuclidean'
    for i = 1:nclusts
        D(:,i) = (X(:,1) - C(i,1)).^2;
        for j = 2:p
            D(:,i) = D(:,i) + (X(:,j) - C(i,j)).^2;
        end
        % D(:,i) = sum((X - C(repmat(i,n,1),:)).^2, 2);
    end
case 'cityblock'
    for i = 1:nclusts
        D(:,i) = abs(X(:,1) - C(i,1));
        for j = 2:p
            D(:,i) = D(:,i) + abs(X(:,j) - C(i,j));
        end
        % D(:,i) = sum(abs(X - C(repmat(i,n,1),:)), 2);
    end
case {'cosine','correlation'}
    % The points are normalized, centroids are not, so normalize them
    normC = sqrt(sum(C.^2, 2));
    if any(normC < eps(class(normC))) % small relative to unit-length data points
        error('stats:kmeans:ZeroCentroid', ...
              'Zero cluster centroid created at iteration %d.',iter);
    end
    
    for i = 1:nclusts
        D(:,i) = max(1 - X * (C(i,:)./normC(i))', 0);
    end
    
case 'hamming'
    for i = 1:nclusts
        D(:,i) = abs(X(:,1) - C(i,1));
        for j = 2:p
            D(:,i) = D(:,i) + abs(X(:,j) - C(i,j));
        end
        D(:,i) = D(:,i) / p;
        % D(:,i) = sum(abs(X - C(repmat(i,n,1),:)), 2) / p;
    end
end
end % function