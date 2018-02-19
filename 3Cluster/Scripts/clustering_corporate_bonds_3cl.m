clear; clc

for isubject = [1 2 3 4 5 6 7 8 9 10]
    i = 1;
    for q=5:5:45
        if q<10
            datadir = ['../interval_3cl/S' num2str(isubject,'%02d') 'R01/overlap_' num2str(q,'%01d') '/'];
        end
        if q>5
            datadir = ['../interval_3cl/S' num2str(isubject,'%02d') 'R01/overlap_' num2str(q,'%02d') '/'];
        end
        
        %list of all files for patient number $isubject
        fileruns = dir([datadir '3cl_feature_sec*.csv']);
        
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
            bonds = A(:,2:n-1);
            %Number of cluster to create
            numClust = 3;
            
            mdl = fscnca(bonds,A(:,n),'Solver','sgd','Verbose',1);
            figure()
            plot(mdl.FeatureWeights,'ro')
            grid on
            xlabel('Feature index')
            ylabel('Feature weight')
            %             c=flipud(unique(sort(mdl.FeatureWeights)));
            %             result1=c(1:10);         %top ten
            %             ind=find(mdl.FeatureWeights>=c(10));      %their indices
            %             resultat=flipud(sortrows([mdl.FeatureWeights(ind) ind],1));
            %             resultat1=resultat(1:10,:);
            %             resultat1 = resultat1';
            %             result(i,:) = resultat1(2,:); i = i + 1;
            % %             rng('default');  % For reproducibility
            % %             eva = evalclusters(bonds,'kmeans','silhouette','KList',[1:6]);
            % %             result(isubject,i) = eva.OptimalK; i = i + 1;
            %% k-means %%%
            
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
                
                P = array2table([A(:,n) kidx]);
                writetable(P, [datadir 'versus_kmeans_' dist_k '_' fileruns(r).name] );
                display([datadir 'versus_kmeans_' dist_k '_' fileruns(r).name]);
            end
            
            %%% neural networks - Self organizing Maps %%%
            
            % Create a Self-Organizing Map
            dimension1 = 3;
            dimension2 = 1;
            net = selforgmap([dimension1 dimension2]);
            
            % Train the network
            net.trainParam.showWindow = 0;
            [net,tr] = train(net,bonds');
            
            % Test the network
            nidx = net(bonds');
            nidx = vec2ind(nidx)';
            
            P = array2table([A(:,n) nidx]);
            writetable(P, [datadir 'versus_net_' fileruns(r).name] );
            display([datadir 'versus_net_' fileruns(r).name]);
            
            
            %     %%% FUZZY C-MEANS %%%
            options(1) = 2;
            options(2) = 10000;
            options(3) = 1e-5;
            options(4) = 0;
            % Hide iteration information by passing appropriate options to FCM
            [centres,U] = fcm(bonds,numClust,options);
            [~, fidx] = max(U);
            fidx = fidx';
            
            
            P = array2table([A(:,n) fidx]);
            writetable(P, [datadir 'versus_cmeans_' fileruns(r).name] );
            display([datadir 'versus_cmeans_' fileruns(r).name]);
            
            
            %             Z = linkage(bonds,'average','euclidean');
            %             P = clusterdata(Z,3);
            %             dendrogram(Z,0,'ColorThreshold',0.7*max(Z(:,3)));
            %             figure; gscatter(1:length(P),P);
            %             title(filename);
        end
    end
end