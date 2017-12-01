function [L]=knee(qvec)

% Reference:
% Salvador S and Chan P. Determining the number of clusters/segments in hierarchical clustering/
% segmentation algorithms. November 2004.

% estimating b
b=length(qvec);

% find range for c
pt1=2;
pt2=b-2;

for c=pt1:1:pt2,
    
[B1,BINT1,R1]=regress(qvec(1:c,1),[[1:c]',[ones((c-1)+1,1)]]);    
[B2,BINT2,R2]=regress(qvec(c+1:b,1),[[c+1:b]',[ones((b-(c+1))+1,1)]]);    

RMSE_L=sqrt(mean(R1.^2));
RMSE_R=sqrt(mean(R2.^2));

L(c,1)=(((c-1)/(b-1))*RMSE_L+((b-c)/(b-1))*RMSE_R);

end

end