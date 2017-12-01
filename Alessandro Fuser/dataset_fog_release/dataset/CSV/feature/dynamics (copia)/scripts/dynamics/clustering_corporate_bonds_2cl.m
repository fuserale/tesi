clear; clc

datadir_dataset = '../../dataset/';
datadir_clustering = '../../clustering/';

%list of all files for patient number $isubject
fileruns = dir([datadir_dataset '2cl_dynamics*.csv']);

%while there's file of patient $isubject
for r = 1:length(fileruns)
    
    %name of the file
    filename = [datadir_dataset fileruns(r).name];
    %read table given in input
    T = readtable(filename);
    [m,n] = size(T);
    A = table2array(T(:,:));
    
    % feature selection
%     mdl = fscnca(A(:,2:10),A(:,11));
%     plot(mdl.FeatureWeights,'ro');
%     
%     Mdl = rica(A(:,2:136),10,'IterationLimit',100);
    
    % Set the random number seed to make the results repeatable in this script
    rng('default');
    
    % features to cluster
    bonds = A(:,2:10);
    %Number of cluster to create
    numClust = 2;
    
    
    %%% k-means %%%
    
    % choose of parameter
    means1 = 'sqeuclidean';
    means2 = 'correlation';
    means3 = 'cityblock';
    means4 = 'cosine';
    for q=1:4
        if q == 1
            dist_k = means1;
        end
        if q == 2
            dist_k = means2;
        end
        if q == 3
            dist_k = means3;
        end
        if q == 4
            dist_k = means4;
        end
        maxiter = 100000;
        % cluster
        kidx = kmeans(bonds, numClust, 'distance', dist_k, 'MaxIter', maxiter,'Replicates',5);
        
        P = array2table(kidx);
        writetable(P, [datadir_clustering 'kmeans_' dist_k '_' fileruns(r).name] );
        display([datadir_clustering 'kmeans_' dist_k '_' fileruns(r).name]);
    end
    
    %%% neural networks - Self organizing Maps %%%
    
    % Create a Self-Organizing Map
    dimension1 = 2;
    dimension2 = 1;
    net = selforgmap([dimension1 dimension2]);
    
    % Train the network
    net.trainParam.showWindow = 0;
    [net,tr] = train(net,bonds');
    
    % Test the network
    nidx = net(bonds');
    nidx = vec2ind(nidx)';
    
    P = array2table(nidx);
    writetable(P, [datadir_clustering 'net_' fileruns(r).name] );
    display([datadir_clustering 'net_' fileruns(r).name]);
    
    
    %     %%% FUZZY C-MEANS %%%
    options(1) = 2;
    options(2) = 10000;
    options(3) = 1e-5;
    options(4) = 0;
    % Hide iteration information by passing appropriate options to FCM
    [centres,U] = fcm(bonds,numClust,options);
    [~, fidx] = max(U);
    fidx = fidx';
    
    
    P = array2table(fidx);
    writetable(P, [datadir_clustering 'cmeans_' fileruns(r).name] );
    display([datadir_clustering 'cmeans_' fileruns(r).name]);
end