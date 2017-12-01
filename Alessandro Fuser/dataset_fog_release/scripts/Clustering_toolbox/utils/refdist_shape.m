function Z=refdist_shape(X)

%Reference:
%Tibshirani R, Walther G, and Hastie T. Estimating the number of clusters in a data set via the
%gap statistic. Journal of the Royal Statistical Society: Series B (Statistical Methodology), 63:
%411–23, 2001. doi: 10.1111/1467-9868.00293.


[n,p]=size(X);

[U,S,V]=svd(X);
Xt=X*V;

minvec=min(Xt);
maxvec=max(Xt);

for cidx=1:p,
   
   a=minvec(1,cidx);
   b=maxvec(1,cidx);
   Zt(:,cidx)= a+(b-a).*rand(n,1);
    
end

Z=Zt*V';

end