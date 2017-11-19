clear; clc

for isubject = [1 2 3]
    for q=5:5:45
        if q<10
            datadir = ['../../../dataset/CSV/feature/interval_2cl/S' num2str(isubject,'%02d') 'R01/overlap_' num2str(q,'%01d') '/'];
        end
        if q>5
            datadir = ['../../../dataset/CSV/feature/interval_2cl/S' num2str(isubject,'%02d') 'R01/overlap_' num2str(q,'%02d') '/'];
        end
        
        %list of all files for patient number $isubject
        fileruns = dir([datadir '2cl_feature_sec*.csv']);
        
        %while there's file of patient $isubject
        for r = 1:length(fileruns)
            
            %name of the file
            filename = [datadir fileruns(r).name];
            %read table given in input
            T = readtable(filename);
            [m,n] = size(T);
            A = table2array(T(:,:));
            
            % Set the random number seed to make the results repeatable in this script
            rng('default');
            
            % features to cluster
            bonds = A(:,2:131);
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
                options_km = statset('UseParallel', false);
                maxiter = 100000;
                % cluster
                kidx = kmeans(bonds, numClust, 'distance', dist_k, 'options', options_km, 'MaxIter', maxiter);
                
                P = array2table(kidx);
                writetable(P, [datadir 'kmeans_' dist_k '_' fileruns(r).name] );
                display([datadir 'kmeans_' dist_k '_' fileruns(r).name]);
            end
            
            %%% neural networks - Self organizing Maps %%%
            
            % Create a Self-Organizing Map
            dimension1 = numClust;
            dimension2 = 1;
            net = selforgmap([dimension1 dimension2]);
            
            % Train the network
            net.trainParam.showWindow = 0;
            [net,tr] = train(net,bonds');
            
            % Test the network
            nidx = net(bonds');
            nidx = vec2ind(nidx)';

            P = array2table(nidx);
            writetable(P, [datadir 'net_' fileruns(r).name] );
            display([datadir 'net_' fileruns(r).name]);
            
            
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
            writetable(P, [datadir 'cmeans_' fileruns(r).name] );
            display([datadir 'cmeans_' fileruns(r).name]);
        end
    end
end