function feature_fusion

%% introduzione tabelle
fileruns = dir('3cl_*.csv');
for r = 1:length(fileruns)
    T = readtable(fileruns(r).name);
    T = table2array(T);
    %% scelta dei parametri da visualizzare
    x = T(:,9);
    y = T(:,10);
    species = T(:,11);
    
    %% grafico con etichette reali
    h1 = gscatter(x,y,species,'krb','ov^',[],'off');
    %     h1(1).LineWidth = 2;
    %     h1(2).LineWidth = 2;
    %     h1(3).LineWidth = 2;
    legend('NoFog','PreFog','Fog','Location','best')
    hold on
    
    %% alleno il classificatore lineare e grafico
    X = [x,y];
    %     MdlLinear = fitcdiscr(X,species);
    %     MdlLinear.ClassNames([2 3])
    %     K = MdlLinear.Coeffs(2,3).Const;
    %     L = MdlLinear.Coeffs(2,3).Linear;
    %
    %     f = @(x1,x2) K + L(1)*x1 + L(2)*x2;
    %     h2 = ezplot(f,[-6000 6000 -5000 5000]);
    %     h2.Color = 'r';
    %     h2.LineWidth = 2;
    %
    %     MdlLinear.ClassNames([1 2])
    %     K = MdlLinear.Coeffs(1,2).Const;
    %     L = MdlLinear.Coeffs(1,2).Linear;
    %
    %     f = @(x1,x2) K + L(1)*x1 + L(2)*x2;
    %     h3 = ezplot(f,[-6000 6000 -5000 5000]);
    %     h3.Color = 'k';
    %     h3.LineWidth = 2;
    
    %     MdlLinear.ClassNames([1 3])
    %     K = MdlLinear.Coeffs(1,3).Const;
    %     L = MdlLinear.Coeffs(1,3).Linear;
    %
    %     f = @(x1,x2) K + L(1)*x1 + L(2)*x2;
    %     h4 = ezplot(f,[-6000 6000 -5000 5000]);
    %     h4.Color = 'g';
    %     h4.LineWidth = 2;
    %     axis([-6000 6000 -5000 5000]);
    
    %% alleno il classificatore quadratico e grafico
    MdlQuadratic = fitcdiscr(X,species,'DiscrimType','quadratic');
    
    %     delete(h2);
    %     delete(h3);
    
    MdlQuadratic.ClassNames([2 3])
    K = MdlQuadratic.Coeffs(2,3).Const;
    L = MdlQuadratic.Coeffs(2,3).Linear;
    Q = MdlQuadratic.Coeffs(2,3).Quadratic;
    f = @(x1,x2) K + L(1)*x1 + L(2)*x2 + Q(1,1)*x1.^2 + ...
        (Q(1,2)+Q(2,1))*x1.*x2 + Q(2,2)*x2.^2;
    h2 = ezplot(f,[-6000 6000 -5000 5000]);
    h2.Color = 'r';
    h2.LineWidth = 2;
    
    MdlQuadratic.ClassNames([1 2])
    K = MdlQuadratic.Coeffs(1,2).Const;
    L = MdlQuadratic.Coeffs(1,2).Linear;
    Q = MdlQuadratic.Coeffs(1,2).Quadratic;
    
    f = @(x1,x2) K + L(1)*x1 + L(2)*x2 + Q(1,1)*x1.^2 + ...
        (Q(1,2)+Q(2,1))*x1.*x2 + Q(2,2)*x2.^2;
    h3 = ezplot(f,[-6000 6000 -5000 5000]); % Plot the relevant portion of the curve.
    h3.Color = 'k';
    h3.LineWidth = 2;
    
    MdlQuadratic.ClassNames([1 3])
    K = MdlQuadratic.Coeffs(1,3).Const;
    L = MdlQuadratic.Coeffs(1,3).Linear;
    Q = MdlQuadratic.Coeffs(1,3).Quadratic;
    
    f = @(x1,x2) K + L(1)*x1 + L(2)*x2 + Q(1,1)*x1.^2 + ...
        (Q(1,2)+Q(2,1))*x1.*x2 + Q(2,2)*x2.^2;
    h4 = ezplot(f,[-6000 6000 -5000 5000]); % Plot the relevant portion of the curve.
    h4.Color = 'g';
    h4.LineWidth = 2;
    axis([-6000 6000 -5000 5000]);
    
    hold off
end
end