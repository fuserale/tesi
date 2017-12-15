clear; clc

pcol = {[1 1 1],[0 .75 0],'r','b',[0 0 1], [0 0 1]};

for isubject = [1 2 3 4 8]
    most_long = [];
    for p = 1:6
        datadir_dataset = '../../dataset/';
        datadir_clustering = '../../clustering/';
        datadir_plot = '../../plot/';
        datadir_rate = '../../rate/';
        
        %lista di tutti i file del paziente isubject con label 3
        fileruns = dir([datadir_dataset '2cl_dynamics_3cl_S' num2str(isubject,'%02d') '*.csv']);
        if p == 1
            alg = 'kmeans_cosine';
        end
        if p == 2
            alg = 'kmeans_correlation';
        end
        if p == 3
            alg = 'kmeans_cityblock';
        end
        if p == 4
            alg = 'kmeans_sqeuclidean';
        end
        if p == 5
            alg = 'net';
        end
        if p == 6
            alg = 'cmeans';
        end
        %lista di tutti i file dell'algoritmo del paziente isubject del
        %2kmeans
        fileruns2 = dir([datadir_clustering alg '_2cl_dynamics_3cl_S' num2str(isubject,'%02d') '*.csv']);
        
        %while there's file of patient $isubject
        for r = 1:length(fileruns)
            
            %name of the file
            filename = [datadir_dataset fileruns(r).name];
            %read table given in input (contiene freeze effettivo)
            T1 = readtable(filename);
            [m1,n1] = size(T1);
            A1 = table2array(T1(:,n1));
            TEMP1 = table2array(T1(:,1));
            
            %name of the file
            filename2 = [datadir_clustering fileruns2(r).name];
            %read table given in input (contiene etichetta cluster)
            T2 = readtable(filename2);
            [m2,n2] = size(T2);
            A2 = table2array(T2(:,1));
            
            %la prima colonna è il cluster, la seconda è il reale
            D = [A2 A1];
            
            %cambia etichette per i casi sbagliati (3 = AB, 4 = BA)
%             for i=1:m1
%                 if D(i,1) ~= D(i,2)
%                     if D(i,1) == 1
%                         D(i,1) = 3;
%                     end
%                     if D(i,1) == 2
%                         D(i,1) = 4;
%                     end
%                 end
%             end
            
            %tabella con etichette cambiate e con file da 3 etichette
            F = [A2 D(:,1) A1];
            numb = 0;
            tot = 0;
            num31 = 0;
            num32 = 0;
            num33 = 0;
            num41 = 0;
            num42 = 0;
            num43 = 0;
            %per tutta la tabella
            for i = 1:m1
                %se ho etichetta sbagliata
                if ((F(i,2) == 3 || F(i,2) == 4))
                    %aggiorno il totale di etichette sbagliate,
                    tot = tot + 1;
                    %se è un Prefog
                    if F(i,3) == 3
                        %aggiorna numero quante volte 3 o 4 appartiene
                        %a preFOG
                        numb = numb + 1;
                    end
                    if ((F(i,2) == 3) && (F(i,3) == 1))
                        %aggiorna numero di 3 che sono 1
                        num31 = num31 + 1;
                    end
                    if ((F(i,2) == 3) && (F(i,3) == 2))
                        %aggiorna numero di 3 che sono 2
                        num32 = num32 + 1;
                    end
                    if ((F(i,2) == 3) && (F(i,3) == 3))
                        num33 = num33 + 1;
                    end
                    if ((F(i,2) == 4) && (F(i,3) == 1))
                        %aggiorna numero di 4 che sono 1
                        num41 = num41 + 1;
                    end
                    if ((F(i,2) == 4) && (F(i,3) == 2))
                        %aggiorna numero di 4 che sono 2
                        num42 = num42 + 1;
                    end
                    if ((F(i,2) == 4) && (F(i,3) == 3))
                        %aggiorna numero di 4 che sono 2
                        num43 = num43 + 1;
                    end
                end
            end
            tot3 = num31 + num32 + num33;
            tot4 = num41 + num42 + num43;
            %salva il numero di match, la frazione rispetto al totale
            %di etichette sbagliate, l'algoritmo scelto e l'algoritmo
            most_long = [most_long; [numb tot round(num31/tot3*100,2) round(num32/tot3*100,2) round(num33/tot3*100,2) round(num41/tot4*100,2) round(num42/tot4*100,2) round(num43/tot4*100,2) p]];
            
            real_12 = [A1];
            for i=1:m1
                if (real_12(i,1) == 3)
                    real_12(i,1) = 1;
                end
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %                 f = find(F(2:end,[1 2])-F(1:end-1,[1 2]));
            %                 f = [0;f;size(F,1)];
            %                 for i=1:size(f,1)-1
            %                    x1 = TEMP1(f(i)+1,1)/1000;
            %                    x2 = TEMP1(f(i+1),1)/1000;
            %                    type = F(f(i)+1,1);
            %                    y1 = 4;
            %                   ylabel(alg);
            %                 y2 = 1;
            %                 end
            %                 patch([x1,x2,x2,x1],[y1 y1 y2 y2],pcol{1+type});
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            figure('visible','off');
            x = 1:m1;
            
            subplot(4,1,1)
            y2 = real_12;
            c2 = y2;
            patch(x,y2,c2, 'EdgeColor','flat','Marker','x','MarkerFaceColor','flat');
            colorbar;
            xlabel('SAMPLE');
            %ylabel(alg);
            title('REAL 2 LABEL DYNAMICS');
            
            subplot(4,1,2)
            y2 = F(:,3);
            c2 = y2;
            patch(x,y2,c2, 'EdgeColor','flat','Marker','x','MarkerFaceColor','flat');
            colorbar;
            xlabel('SAMPLE');
            %ylabel(alg);
            title('REAL 3 LABEL DYNAMICS');
            
            
            subplot(4,1,3)
            y1 = A2;
            c1 = y1;
            patch(x,y1,c1, 'EdgeColor','flat','Marker','x','MarkerFaceColor','flat');
            colorbar;
            xlabel('SAMPLE');
            %ylabel(alg);
            title(['DYNAMICS 12 S' num2str(isubject,'%2d')]);
            
            subplot(4,1,4)
            y1 = F(:,2);
            c1 = y1;
            patch(x,y1,c1, 'EdgeColor','flat','Marker','x','MarkerFaceColor','flat');
            colorbar;
            xlabel('SAMPLE');
            %ylabel(alg);
            title(['DYNAMICS 1234 S' num2str(isubject,'%2d')]);
            
            print([datadir_plot alg '_S' num2str(isubject,'%2d') '.jpg'], '-dpng');
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            F = array2table(F);
            F.Properties.VariableNames = {'CLUSTER' 'CLUSTER_MOD' 'REAL'};
            writetable(F, [datadir_rate 'versus_' fileruns2(r).name]);
            disp([datadir_rate 'versus_' fileruns2(r).name]);
            
        end
    end
    M = array2table(most_long);
    M.Properties.VariableNames = {'nMATCH' 'nETICHETTE_SBAGLIATE' 'NUM31' 'NUM32' 'NUM33' 'NUM41' 'NUM42' 'NUM43' 'nALGO'};
    writetable(M, [datadir_rate 'versus_S' num2str(isubject,'%02d') '.csv']);
end

