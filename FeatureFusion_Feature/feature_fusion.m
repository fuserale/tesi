function feature_fusion

%% introduzione tabelle
fileruns = dir('2cl_*.csv');
for r = 1:length(fileruns)
    T = readtable(fileruns(r).name);
    T = table2array(T);
    %% scelta dei parametri da visualizzare
    for i = 2:46
        for j = i+1:46
            
            feat1 = i;
            feat2 = j;
            x = T(:,feat1);
            y = T(:,feat2);
            species = T(:,47);
            
            %% scelta se classificatore lineare (1) oppure quadratico (2)
            alg = 2;
            
            %% grafico con etichette reali
            figure('visible','off');
            h1 = gscatter(x,y,species,'krb','ov^',[],'off');
            %     h1(1).LineWidth = 2;
            %     h1(2).LineWidth = 2;
            %     h1(3).LineWidth = 2;
            legend('NoFog','PreFog','Fog','Location','best')
            hold on
            
            %% alleno il classificatore lineare e grafico
            X = [x,y];
            if (alg == 1)
                MdlLinear = fitcdiscr(X,species);
                MdlLinear.ClassNames([2 3])
                K = MdlLinear.Coeffs(2,3).Const;
                L = MdlLinear.Coeffs(2,3).Linear;
                
                f = @(x1,x2) K + L(1)*x1 + L(2)*x2;
                h2 = ezplot(f,[min(x) max(x) min(y) max(y)]);
                h2.Color = 'r';
                h2.LineWidth = 2;
                
                MdlLinear.ClassNames([1 2])
                K = MdlLinear.Coeffs(1,2).Const;
                L = MdlLinear.Coeffs(1,2).Linear;
                
                f = @(x1,x2) K + L(1)*x1 + L(2)*x2;
                h3 = ezplot(f,[min(x) max(x) min(y) max(y)]);
                h3.Color = 'k';
                h3.LineWidth = 2;
                
                MdlLinear.ClassNames([1 3])
                K = MdlLinear.Coeffs(1,3).Const;
                L = MdlLinear.Coeffs(1,3).Linear;
                
                f = @(x1,x2) K + L(1)*x1 + L(2)*x2;
                h4 = ezplot(f,[min(x) max(x) min(y) max(y)]);
                h4.Color = 'g';
                h4.LineWidth = 2;
                axis([min(x) max(x) min(y) max(y)]);
                xlabel(i);
                ylabel(j);
                print(['Grafici_Lineari/Feat' num2str(i, '%02d') '&Feat' num2str(j,'%02d') '.jpg'], '-dpng');
                disp(['Grafici_Lineari/Feat' num2str(i, '%02d') '&Feat' num2str(j,'%02d') '.jpg']);
                hold off
            end
            
            %% alleno il classificatore quadratico e grafico
            if (alg == 2)
                MdlQuadratic = fitcdiscr(X,species,'DiscrimType','quadratic');
                
                %     delete(h2);
                %     delete(h3);
                
                MdlQuadratic.ClassNames([2 3])
                K = MdlQuadratic.Coeffs(2,3).Const;
                L = MdlQuadratic.Coeffs(2,3).Linear;
                Q = MdlQuadratic.Coeffs(2,3).Quadratic;
                f = @(x1,x2) K + L(1)*x1 + L(2)*x2 + Q(1,1)*x1.^2 + ...
                    (Q(1,2)+Q(2,1))*x1.*x2 + Q(2,2)*x2.^2;
                h2 = ezplot(f,[min(x) max(x) min(y) max(y)]);
                h2.Color = 'r';
                h2.LineWidth = 2;
                
                MdlQuadratic.ClassNames([1 2])
                K = MdlQuadratic.Coeffs(1,2).Const;
                L = MdlQuadratic.Coeffs(1,2).Linear;
                Q = MdlQuadratic.Coeffs(1,2).Quadratic;
                
                f = @(x1,x2) K + L(1)*x1 + L(2)*x2 + Q(1,1)*x1.^2 + ...
                    (Q(1,2)+Q(2,1))*x1.*x2 + Q(2,2)*x2.^2;
                h3 = ezplot(f,[min(x) max(x) min(y) max(y)]); % Plot the relevant portion of the curve.
                h3.Color = 'k';
                h3.LineWidth = 2;
                
                MdlQuadratic.ClassNames([1 3])
                K = MdlQuadratic.Coeffs(1,3).Const;
                L = MdlQuadratic.Coeffs(1,3).Linear;
                Q = MdlQuadratic.Coeffs(1,3).Quadratic;
                
                f = @(x1,x2) K + L(1)*x1 + L(2)*x2 + Q(1,1)*x1.^2 + ...
                    (Q(1,2)+Q(2,1))*x1.*x2 + Q(2,2)*x2.^2;
                h4 = ezplot(f,[min(x) max(x) min(y) max(y)]); % Plot the relevant portion of the curve.
                h4.Color = 'g';
                h4.LineWidth = 2;
                axis([min(x) max(x) min(y) max(y)]);
                xlabel(i);
                ylabel(j);
                print(['Grafici_Quadratici/Feat' num2str(i, '%02d') '&Feat' num2str(j,'%02d') '.jpg'], '-dpng');
                disp(['Grafici_Quadratici/Feat' num2str(i, '%02d') '&Feat' num2str(j,'%02d') '.jpg']);
                hold off
            end
            
        end
    end
end
end