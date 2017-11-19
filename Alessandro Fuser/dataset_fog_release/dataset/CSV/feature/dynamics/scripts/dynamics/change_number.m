clear; clc

pcol = {[1 1 1],[0 .75 0],'r', 'b'};

for isubject = 1:3
    most_long = [];
        for p = 1:6
            datadir = ['../../'];
            
            datadir2 = ['../../clustering/'];
            
            %lista di tutti i file del paziente isubject con label 3
            %modificate in 1
            fileruns = dir([datadir '2cl_dynamics_3cl_S' num2str(isubject,'%02d') '*.csv']);
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
            fileruns2 = dir([datadir2 alg '_2cl_dynamics_3cl_S' num2str(isubject,'%02d') '*.csv']);
            
            %lista di tutti i file dell'algoritmo del paziente isubject con le 3 etichette (1 = No, 2 = Fog, 3 = Pre)
            fileruns3 = dir([datadir '3cl_dynamics_3cl_S' num2str(isubject,'%02d') '*.csv']);
            
            %while there's file of patient $isubject
            for r = 1:length(fileruns)
                
                %name of the file
                filename = [datadir fileruns(r).name];
                %read table given in input (contiene freeze effettivo)
                T1 = readtable(filename);
                [m1,n1] = size(T1);
                A1 = table2array(T1(:,131));
                
                %name of the file
                filename2 = [datadir2 fileruns2(r).name];
                %read table given in input (contiene etichetta cluster)
                T2 = readtable(filename2);
                [m2,n2] = size(T2);
                A2 = table2array(T2(:,1));
                
                %tabella con 3 etichette
                filename3 = [datadir fileruns3(r).name];
                T3 = readtable(filename3);
                A3 = table2array(T3(:,131));
                
                %la prima colonna è il cluster, la seconda è il reale
                D = [A2 A1];                
                
                %cambia etichette per i casi sbagliati (3 = AB, 4 = BA)
                for i=1:m1
                    if D(i,1) ~= D(i,2)
                        if D(i,1) == 1
                            D(i,1) = 3;
                        end
                        if D(i,1) == 2
                            D(i,1) = 4;
                        end
                    end
                end
                
                %tabella con etichette cambiate e con file da 3 etichette
                F = [D(:,1) A3];
                numb = 0;
                tot = 0;
                %per tutta la tabella
                for i = 1:m1
                    %se ho etichetta sbagliata
                    if ((F(i,1) == 3 || F(i,1) == 4))
                        %aggiorno il totale di etichette sbagliate,
                        tot = tot + 1;
                        %se è un Prefog
                        if F(i,2) == 3
                            %aggiorna numero match esatti
                            numb = numb + 1;
                        end
                    end
                end
                %salva il numero di match, la frazione rispetto al totale
                %di etichette sbagliate, l'algoritmo scelto e l'overlap
                most_long = [most_long; [numb tot numb/tot p]];
                

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                figure
                x = 1:m1;
                x1 = 2:m1+1;
                subplot(2,1,1)
                type = F(:,1);
                y1 = 1;
                y2 = 4;
                %y1(end) = NaN;
                c1 = y1;
                patch([x,x1,x1,x],[y1,y1,y2,y2],pcol{1+type}, 'EdgeColor','flat','Marker','x','MarkerFaceColor','flat');
                colorbar;
                xlabel('SAMPLE');
                ylabel(alg);
                title('2KMEANS DYNAMICS');

                subplot(2,1,2)
                y2 = F(:,2);
                %y2(end) = NaN;
                c2 = y2;
                patch(x,y2,c2, 'EdgeColor','flat','Marker','x','MarkerFaceColor','flat');
                colorbar;
                xlabel('SAMPLE');
                ylabel(alg);
                title('REAL 3 LABEL DYNAMICS');
                print([datadir 'plot/' alg '.jpg'], '-dpng');
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                F = array2table(F);
                F.Properties.VariableNames = {'CLUSTER' 'REAL'};
                writetable(F, [datadir 'rate/versus_' fileruns2(r).name]);
                disp([datadir 'rate/versus_' fileruns2(r).name]);
                
            end
        end
    M = array2table(most_long);
    M.Properties.VariableNames = {'nMATCH' 'nETICHETTE_SBAGLIATE' 'RATE' 'nALGO'};
    writetable(M, ['../../rate/versus_S' num2str(isubject,'%02d') '.csv']);
end

