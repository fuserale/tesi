clear; clc

T = readtable('../../dataset/CSV/2cl_S01R01.csv');
[m,n] = size(T);
A = table2array(T(:,2:10));
F = table2array(T(:,11));

correlation = corr(A);
% [L,S,D] = svd(correlation);
% V = S*L(:,1);

% [lambda,psi] = factoran(A,2);

% [V,D] = eig(correlation);

% [coeff,score,latent,tsquared,explained,mu] = pca(A(:,2:139));
% figure()
% pareto(explained);
% B = score*coeff';
opts = statset('display','iter');
fun = @(XT,yT,Xt,yt)...
      (sum(~strcmp(yt,classify(Xt,XT,yT,'quadratic'))));
  
[fs,history] = sequentialfs(fun,A,F,'options',opts);


