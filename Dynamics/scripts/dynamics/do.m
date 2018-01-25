size_prefog = 2; % in secondi
size_sovrapposition = 1; % in secondi
num_clusters = 3; % numero di cluster

% 2:4 = shank, 5:7 = thigh, 8:10 = trunk

cancel_prefog;
extract_prefog(size_prefog);
featureDynamics_2cl(size_prefog,size_sovrapposition);
% Copy_of_featureDynamics_2cl(size_prefog,size_sovraposition);
%find_nan;
clustering_corporate_bonds_2cl(num_clusters);
versus_rate(num_clusters);