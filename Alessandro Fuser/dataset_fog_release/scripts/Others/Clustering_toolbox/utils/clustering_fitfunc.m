function y  = clustering_fitfunc(vec,X,k)

% Reference:
% Maulik U and Bandyopadhyay S. Genetic algorithm-based clustering technique. Pattern Recognition,
% 33:1455–1465, 2000. doi: 10.1016/S0031-3203(99)00137-5.

% this function calculates the total within-cluster sum of squares for a
% given set of cluster centroids

s=length(vec)/k;
C1=zeros(k,s);

for index=1:1:k,
   C1(index,:)=vec(1,(s*(index-1))+1:s*index);   
end

n=size(X,1);
X=X-repmat(mean(X,2),1,s);
Xnorm=sqrt(sum(X.^2, 2));
X=X./Xnorm(:,ones(1,s));

D1=distfun(X,C1,'correlation');
[d1,idx1]=min(D1,[],2);
m = accumarray(idx1,1,[k,1]);

% Calculate cluster-wise sums of distances
ne = find(m>0);

%if length(ne)<k,
%    warning('Warning!!!');
%end

for fidx=1:1:k,
    C2(fidx,:)= mean(X(find(idx1(:,1)==fidx),:),1);
end

D2(:,ne)=distfun(X,C2(ne,:),'correlation');
[d2,idx2]=min(D2(:,ne),[],2);
y=sum(d2);

end

function D = distfun(X,C,dist)

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
        error('Distfun - error');
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

end 