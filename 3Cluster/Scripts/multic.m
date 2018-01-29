function [C,varargout]=multic(known,predicted,varargin)
% Using results of multiclass classification the function builds a confusion
% matrix and tables of confusion and calculates derivations from
% a confusion matrix for each class and for all population. Derivations are
% metrics of classifier's performance. Each derivation serves different
% purposes. Cosideration of derivations allows a comprehensive study of
% classifier's performance.
% C = multic(A,B) returns the nXn confusion matrix C determined by 
% the known and predicted groups in A and B, respectively. A and B are
% input vectors with the same number of observations. n is the total number  
% of distinct elements in A and B. Input vectors must be of the same type
% and can be numeric arrays or cell arrays of strings. By default missing 
% classification (observation) is not counted. Missing  classification 
% must be denoted as NaN for numeric type and be empty string for cell 
% array of strings. Calculations are case insensitive. All strings will be 
% transformed to lower case.
% C = multic(A,B,MODE), where MODE = 1 calculate missing classification 
% as "false negative" for class corresponding missing classification and
% "true negative" for other classes. MODE = 0 is default.
% C = multic(A,B,1) returns nX(n+2) augmented confusion matrix. Column n+1
% contains NaN in a row corresponding a class with missing classification
% and column n+2 contains a number of missing classifications for each
% class. 
% C = multic(A,B,MODE,BETA), BETA is a value for F-score. Default value is
% BETA = 1.
% [C,T]=multic(A,...) returns C and T, where T is 2X2 confusion table:
% T = [TP,FN; FP,TN], where TP is true positive (aka hit), FP is false
% positive (aka false alarm, Type I error), FN is false negative (aka 
% miss, Type II error) and TN is true negative (aka correct rejection).
% [C,T,D]=multic(A,...) returns as above and D, where D is a 18-vector of
% derivations from a confusion matrix. They are:
% - accuracy,
% - precision (positive predictive value),
% - false discovery rate,
% - false omission rate,
% - negative predictive value,
% - prevalence,
% - recall (hit rate, sensitivity, true positive rate),
% - false positive rate (fall-out),
% - positive likelihood ratio,
% - false negative rate (miss rate),
% - true negative rate, specificity,
% - negative likelihood ratio,
% - diagnostic odds ratio,
% - informedness,
% - markedness,
% - F-score,
% - G-measure,
% - Matthews correlation coefficient.
%
% [C,T,D,M] = multic(A,...) returns as above and M, where M is a 2nX2 matrix,
% which contains confusion tables for each class (one versus all). 
% Rows 2i-1 and 2i correspond to class number i, i = 1, 2, ..., n.
%
% [C,T,D,M,N] = multic(A,...) returns as above and N, where N is a 18Xn 
% matrix of derivations from confusion tables, which are contained in M. 
% Column i corresponds to class number i, i = 1, 2, ..., n.
%
% Example
% Calculation of the confusion matrix for data with one misclassification
% and one missing classification. 
% A = [1 1 1 2 2 2 2 2 3  3 ];
% B = [1 1 1 2 2 2 3 4 4 NaN];
% disp('Missing classification is not counted.')
% C = multic(A,B)   % MODE=0
% disp('Missing classificftion is counted')
% C = multic(A,B,1) % MODE=1
%
% Missing classification is not counted.
% C =
%      3     0     0     0
%      0     3     1     1
%      0     0     0     1
%      0     0     0     0
% Missing classification is counted
% C =
%      3     0     0     0     0     0
%      0     3     1     1     0     0
%      0     0     0     1   NaN     1
%      0     0     0     0     0     0
% 
% Calculation of the confusion matrix, confusion table, derivations of it
% and confusion tables and derivations for each class for data with three 
% misclassifications and two missing classifications. 
% Missing classifications are counted. 
% A=[1 3 1 1 1 2 2 2 2 2  2  2   3 1 3 3];  
% B=[1 1 1 1 1 2 2 2 2 1 NaN NaN 2 1 3 3];
% [C,T,D,M,N] = multic(A,B,1)
% C =
%      5     0     0     0     0
%      1     4     0   NaN     2
%      1     1     2     0     0
% T =
%     11     5
%      3    29
% D =
%       0.83333
%       0.78571
%       0.21429
%       0.14706
%       0.85294
%       0.33333
%        0.6875
%       0.09375
%        7.3333
%        0.3125
%       0.90625
%       0.34483
%        21.267
%       0.59375
%       0.63866
%       0.73333
%       0.73497
%       0.61579
% M =
%      5     0
%      2     9
%      4     3
%      1     8
%      2     2
%      0    12
% N =
%         0.875         0.75        0.875
%       0.71429          0.8            1
%       0.28571          0.2            0
%             0      0.27273      0.14286
%             1      0.72727      0.85714
%        0.3125       0.4375         0.25
%        0.3125         0.25        0.125
%       0.18182      0.11111            0
%        1.7188         2.25          Inf
%             0       0.1875        0.125
%       0.81818      0.88889            1
%             0      0.21094        0.125
%           Inf       10.667          Inf
%       0.13068      0.13889        0.125
%       0.71429      0.52727      0.85714
%       0.43478      0.38095      0.22222
%       0.47246      0.44721      0.35355
%       0.76447      0.49266      0.65465
% Calculation of the confusion matrix for data with two misclassifications
% and one missing classification. 
% A = {'Cats','Cats','Rats','Rats','Rats','Rabbits','Rabbits'}; % Known groups
% B = {'Cats','Cats','Rats','Rats','Rabbits','Rats',''}; % Predicted groups
% [C,~,~,~,~,order] = multic(A,B,1)
% C =
%      2     0     0     0     0
%      0     0     1   NaN     1
%      0     1     2     0     0
% order = 
%     'cats'    'rabbits'    'rats'     
      
na = numel(known);
A(na) = 0;
B(na) = 0;
if na ~= numel(predicted)
  error(' Input vectors must be of the same size.')
end
L = all([isnumeric(known),isnumeric(predicted)]);
L1 = all([iscell(known),iscell(predicted)]);
if ~xor(L,L1)
  error([' Input vectors must be of the same type',...
    ' and can be numeric arrays or cell arrays of strings.'])
end
if L
  u = unique([known,predicted]);
  u = u(~isnan(u));
  for i = 1:na
    for j = 1:numel(u)
      if known(i)==u(j)
        A(i) = j;
      end
      if predicted(i)==u(j)
        B(i) = j;
      end
    end
  end
  B(isnan(predicted)) = NaN;
end

if L1
  knwn = lower(known);
  prdctd = lower(predicted);  
  u = unique([knwn,prdctd]);
  if isempty(u{1})
    u = u(2:end);
  end
  for i = 1:na
    for j = 1:numel(u)
      if numel(knwn{i})==numel(u{j})
        if knwn{i}==u{j}
          A(i) = j;        
        end
      end
      if numel(prdctd{i})==numel(u{j})
        if prdctd{i}==u{j}
          B(i) = j;        
        end
      end
      if isempty(prdctd{i})
        B(i) = NaN;
      end  
    end
  end
end

mode = 0; bt = 1; % default
D = zeros(2);     % memory allocation
if nargin > 2
  mode = varargin{1};
  if nargin > 3
    bt = varargin{2};
  end
end
  
B1 = isnan(B);
if ~mode
  k = ~B1;
  A = A(k);
  B = B(k);
end

nu = max(max([A;B]));
na = numel(A);
P = na*nu; % total population
B1 = isnan(B);
% memory allocation
C = zeros([nu,nu + 2*any(B1)]); % confusion matrix
A11 = zeros([2*nu,2]);  % confusion tables
A12 = zeros(18,nu);     % derivations
% Calculation of confusion matrix
for i = 1:nu
  for j = 1:nu
    C(i,j) = sum((A==i)&(B==j));
  end
  if mode
    C(i,nu + 2) = sum((A==i)&(B1==1));
  end
end
if mode
  C(A(B1==1),nu + 1) = NaN;
end
% One versus all
for i = 1:nu
  tp = C(i,i);              % true positive
  nc = ~isnan(C(i,:));
  fn = sum(C(i,nc)) - tp;   % type II error, false negative, miss
  nc1 = ~isnan(C(:,i));
  fp = sum(C(nc1,i)) - tp;  % type I error, false alarm
  if tp + fn + fp == 0
    continue
  end
  tn = na - sum(C(i,nc)) - sum(C(nc1,i)) + tp; % true negative
  op = tp + fp;   % outcome positive
  on = tn + fn;   % outcome negative
  cp = tp + fn;   % condition positive
  cn = tn + fp;   % condition negative
  A1 = [tp fn;
        fp tn];   % Confusion table   
  D = D + A1; 
  A11(2*i-1:2*i,1:2) = A1; 
  acc = (tp + tn)/na; % accuracy
  ppv = tp/op;        % precision, positive prediction value 
  fdr = fp/op;        % false discovery rate
  For = fn/on;        % false omission rate
  npv = tn/on;        % negative predictive value
  prv = cp/na;        % prevalence  
  tpr = tp/na;        % recall, sensitivity, true positive rate, hit rate
  fpr = fp/cn;        % false positive rate
  plr = tpr/fpr;      % positive likelihood ratio
  fnr = fn/na;        % false negative rate, miss rate 
  tnr = tn/cn;        % specificity, true negative rate  
  nlr = fnr/tnr;      % negative likelihood ratio
  dor = plr/nlr;      % diagnostic odds ratio
  ifm = tpr + tnr - 1;   % informedness 
  mkd = ppv + npv - 1;   % markedness  
  fbeta = (1 + bt^2)*ppv*tpr/(bt^2*ppv + tpr); % F-score
  Gm = sqrt(ppv*tpr); % G-measure
  mcc = (tp*tn-fp*fn)/sqrt(op*cp*cn*on); % Matthews correlation coefficient 
  A12(:,i) = [acc,ppv,fdr,For,npv,prv,tpr,fpr,plr,fnr,tnr,...
    nlr,dor,ifm,mkd,fbeta,Gm,mcc];
end
% Total population
TP = D(1,1);        % True positive
FN = D(1,2);        % False negative
TN = D(2,2);        % True negative
FP = D(2,1);        % False positive
OP = TP + FP;       % Output positive 
ON = FN + TN;       % Output negative
CP = TP + FN;       % Condition positive
CN = FP + TN;       % Condition negative
ACC = (TP + TN)/P;  % Accuracy
PPV = TP/OP;        % Precision, positive predictive value
FDR = FP/OP;        % False discovery rate
FOR = FN/ON;        % False omission rate
NPV = TN/ON;        % Negative predictive value
PRV = CP/P;         % Prevalence
TPR = TP/CP;        % Recall, true positive rate, sensitivity, hit rate
FPR = FP/CN;        % False positive rate
PLR = TPR/FPR;      % Positive likelihood ratio
FNR = FN/CP;        % False negative rate
TNR = TN/CN;        % True negative rate, specificity
NLR = FNR/TNR;      % Negative likelihood ratio
DOR = PLR/NLR;      % Diagnostic odds ratio
IFM = TPR + TNR - 1;  % Informedness
MKD = PPV + NPV - 1;  % Markedness
Fbeta = (1 + bt^2)*PPV*TPR/(bt^2*PPV + TPR ); % F-score
G = sqrt(PPV*TPR); % G-measure
MCC = (TP*TN - FP*FN)/sqrt(OP*ON*CN*CP); % Matthews correlation coefficient
varargout(1) = {D}; %Confusion table for total population
varargout(2) = {[ACC,PPV,FDR,FOR,NPV,PRV,TPR,FPR,PLR,...
  FNR,TNR,NLR,DOR,IFM,MKD,Fbeta,G,MCC]'}; % Derivations (total population)
varargout(3) = {A11}; % Confusion tables (one versus all)
varargout(4) = {A12}; % Derivations (one versus all)
varargout{5} = u; % An order