% Parametres physiques :

N        = 2;
d        = 2;

v0 = 1.2e3; %m/s

rMin = 10000+rE;

vTan0 = rMin/dAT*sqrt(v0*v0+G*2*mE*(1.0/rMin-1.0/dAT));
vRad0 = -v0 * cos (asin (vTan0/v0));

L = mA *vTan0 * dAT;

vMax = L/(mA*rMin);

% Parametres numeriques :
tFin     = 2*24*60*60;
nSteps   = 5;
sampling = 1;


switch Ex
case '2a'

    E2a;

case '2b'

    fOrbit=figure();
    axOrbit = axes(fOrbit);
        hold(axOrbit,'on');
        daspect(axOrbit,[1 1 1])

    fMinAcc=figure();
        axMinAcc = axes(fMinAcc);
        hold(axMinAcc,'on');

    fAcc=figure();
        axAcc = axes(fAcc);
        hold(axAcc,'on');

    fOrbitZ  = figure();
        axOrbitZ = axes(fOrbitZ);
        hold(axOrbitZ,'on')
        daspect(axOrbitZ,[1 1 1])

    zSquare = [-8e6,0,4e6,4e6];
    zBound  = [zSquare(1),zSquare(2),zSquare(3)+zSquare(1),zSquare(4)+zSquare(2)];
    zLim = [zBound(1) zBound(3) zBound(2) zBound(4)];

    %% a) (i)   ====   Comparer solution analytique et numerique:

    % Name of output file to generate

    nSimul = 100;
    theta = 0.19;%asin (vT/v0);
    epsilon = 0.001;
    voisinage = linspace ( theta -epsilon,theta + epsilon,nSimul);
    maxEng      = ones(1,nSimul);
        maxAcc      = ones(1,nSimul);
        reachSurface = ones(1,nSimul);
    minPosition = ones(1,nSimul);
    for i = 1:nSimul
        thetaNow = voisinage(i);
        name = [Ex,'thetaN=',num2str(thetaNow),'.out'];

        sT = input_Body([0,0],[0,0],1,mE,rE,1.2,7238.2,0,0);
        sA = input_Body([dAT,0],[-v0 * cos(thetaNow) ,v0 * sin(thetaNow)],2,mA,rA,0,0,0.3,2*pi*rA);


        %%%%%  --- SIMULATION ---   %%%%%
        if (Resimulate) %test if the file exists
            %if not:
            cmd = sprintf('%s%s %s %s output=%s schema=%s nSteps=%.15g %s %s' , repertoire, executable, inputName,config ,name,'A',nSteps, sT, sA);
            system(strcat("wsl ",cmd)); % Wsl to compile using gcc on the wsl (windows subsystem for linux)
        end

        data = load(name); % Load generated file

        %%%%%   --- Load data   --- %%%%%

        t    = data(:,1);
        posEarth  = data(:,2:3);
        posApollo   = data(:,4:5);
        velEarth  = data(:,6:7);
        velApollo   = data(:,8:9);
        eng  = data(:,10);
        accEarth  = data(:,11);
        accApollo   = data(:,12);
        pncEarth  = data(:,13);
        pncApollo   = data(:,14);
        dt        = data(:,15);

        posApollo = posApollo -posEarth;

        h = sqrt(sum((posApollo.^2),2));

        Range = h>rE+rA;

        pA = plot(axOrbit,posApollo(Range,1)/scale,posApollo(Range,2)/scale,...
            '.:'                                ,...
            'Color',            M('light blue') ,...
            'MarkerEdgeColor',  M('dark blue') ,...
            'MarkerSize',       2               ,...
            'LineWidth',        1   );
        pAZ = plot(axOrbitZ,posApollo(Range,1)/scale,posApollo(Range,2)/scale,...
            '.:'                                ,...
            'Color',            M('light blue') ,...
            'MarkerEdgeColor',  M('dark blue') ,...
            'MarkerSize',       2               ,...
            'LineWidth',        1   );



        plot(axAcc,t(Range),accApollo(Range));

        reachSurface(i) = min(h) <= rE + rA;

        if(reachSurface(i))
                maxAcc(i) = max(accApollo(Range));
        else
                maxAcc(i) = nan;
        end

    end
    %%% ---  Markers:

    % Orbit plot:


    initA = plot(axOrbit, posApollo(1,1)/scale, posApollo(1,2)/scale,...
        'x'                             ,...
        'MarkerSize',   3               ,...
        'Color',        M('dark red')   );


    Earth = viscircles(axOrbit,[0,0]    ,...
        rE/scale                        ,...
        'LineWidth',    1               ,...
        'Color',        M('dark green') );

    rectangle(axOrbit,'Position',zSquare/scale);

    r           = plot(axOrbit,nan,nan,...
        'ks'                ,....
        'MarkerSize',   5   ,...
        'LineWidth',    1   );

    earthMarker = plot(axOrbit,nan,nan,...
        'o'                                 ,...
        'MarkerEdgeColor',M('dark green')   ,...
        'MarkerSize'    ,5                  ,...
        'LineWidth'     ,1);

    % Zoom plot:
    EarthZ = viscircles(axOrbitZ,[0,0],...
        rE/scale                        ,...
        'LineWidth',    1               ,...
        'Color',        M('dark green') );

    axis(axOrbitZ,zLim/scale)

    % Labels and legends:

    % Orbit:

    figure(fOrbit);
    l = legend (axOrbit,[earthMarker,initA,r],...
            {'Earth' 'Apollo start' 'Zoom'},...
            'Location'  ,'best' ,...
            'FontSize'  ,8      );
        set(legend,'FontSize',6)
        grid off;
        axOrbit.XLabel.String = 'x [km]';
        axOrbit.YLabel.String = 'y [km]';
        axis(axOrbit,'tight');
        a = axis(axOrbit);
        dx = abs(a(1)-a(2));
        dy = abs(a(3)-a(4));
        axis(axOrbit,[(a(1) - dx/50) (a(2) + dx/50) (a(3) -dy/50) (a(4) + dy/50)]);

    % Zoom:
    figure(fOrbitZ);
        axOrbitZ.XLabel.String = 'x [km]';
        axOrbitZ.YLabel.String = 'y [km]';


    % Max of acceleration
    reachSurface = logical(reachSurface)
    plot(axMinAcc,voisinage(reachSurface),maxAcc(reachSurface),...
        '-'                             ,...
        'Color'     ,M('light blue')    ,...
        'LineWidth' ,1                  );

    axMinAcc.XLabel.String = ('Angle $^\circ$');
    axMinAcc.YLabel.String =('Maximum acceleration [m/s$^2$]');
end