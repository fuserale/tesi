function [signals,PC,V]=pca(data,dim)
% PCA: Perform PCA using covariance
% data - MxN matrix of input data
%       (M dimensions, N trials)
% signals - MxN matrix of projected data
% PC - each column is a PC
% V - Mx1 matrix of variances

[M,N]=size(data);

% subtract off the mean for each dimension

mn=mean(data,2);
data=data-repmat(mn,1,N);

% calculate the covariance matrix
covariance=1/(N-1)*(data*data');

% find the eigenvectors and eigenvalues
[PC,V]=eig(covariance);

% extract diagonal of matrix as vector
V=diag(V);

% sort the variances in decreasing order
[junk,rindices]=sort(V,1,'descend');
V=V(rindices);
PC=PC(:,rindices);

% finding number of PCs accounting for 99 % variance

%dim=0;
%while (sum(V(1:dim,1))/sum(V(:,1)))<0.95
    
%  dim=dim+1;
        
%end
%dim=dim-1;

PC=PC(:,1:dim);
V=V(1:dim,1);

% project the original dataset
signals=PC'*data;