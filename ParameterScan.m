% Ce script Matlab automatise la production de resultats
% lorsqu'on doit faire une serie de simulations en
% variant un des parametres d'entree.
%
% Il utilise les arguments du programme (voir ConfigFile.h)
% pour remplacer la valeur d'un parametre du fichier d'inputName
% par la valeur scannee.
%

%% Parametres %%
%%%%%%%%%%%%%%%%

sizeX = 6;%input('Size X: ');
sizeY = 6;%input('Siye Y: ');

colors = [166,206,227; %light blue
31,120,180; % dark blue
178,223,138; % light green
51,160,44; % dark green
251,154,153; % light red
227,26,28; %dark red
253,191,111; %light orange
255,127,0; % dark orange
202,178,214; %light purple
106,61,154; %dark purple
]/255;

Colors = { colors(1,:), colors(2,:),colors(3,:), colors(4,:), colors(5,:), colors(6,:), colors(7,:), colors(8,:) ,colors(9,:),colors(10,:)};

key = {'light blue' 'dark blue' 'light green' 'dark green' 'light red' 'dark red' 'light orange' 'dark orange' 'light purple' 'dark purple'};
M = containers.Map(key,Colors);

set(groot, 'DefaultFigureResize',               'on'               );
set(groot, 'DefaultFigurePaperUnits',           'centimeters'       );
set(groot, 'DefaultFigureUnits',                'centimeters'       );
set(groot, 'DefaultFigurePaperSize',            [sizeX, sizeY]      );
set(groot, 'DefaultFigureInvertHardcopy',       'on'                );
set(groot, 'DefaultFigurePaperPosition',        [0, 0, sizeX, sizeY]);
set(groot, 'DefaultFigurePosition',             [10,10,sizeX,sizeY] );

set(groot, 'DefaultAxesColorOrder',             colors          );
set(groot, 'DefaultLineMarkerSize',                 2           );

set(groot, 'DefaultTextInterpreter',            'LaTeX' );
set(groot, 'DefaultAxesTickLabelInterpreter',   'LaTeX' );
set(groot, 'DefaultAxesFontName',               'LaTeX' );
set(groot, 'DefaultAxesFontSize',               9     );
set(groot, 'DefaultLegendFontSize',               9      );
set(groot, 'DefaultAxesBox',                    'off'   );
set(groot, 'DefaultAxesXGrid',                  'on'    );
set(groot, 'DefaultAxesYGrid',                  'on'    );
set(groot, 'DefaultAxesGridLineStyle',          ':'     );
set(groot, 'DefaultAxesLayer',                  'bottom'   );
set(groot, 'DefaultLegendInterpreter',          'LaTeX' );


repertoire = './'; % Chemin d'acces au code compile (NB: enlever le ./ sous Windows)
executable = 'Exercice4_Huber_Berdyev'; % Nom de l'executable (NB: ajouter .exe sous Windows)
inputName = 'configuration.in'; % Nom du fichier d'entree de base


%Exercice:
promptEx = 'Exercise : ';
Ex = input(promptEx,'s');%'PTest';%
deleteAfter = 'n';
Resimulate = input('Do you want to resimulate [1/0]: ');


%%% --- Global parameters   --- %%%
G         = 6.674e-11; %m^3kg^-1s^-2
%Earth:
mE = 5.972e24; %kg
rE = 6378.1e3;%m

%Moon
mM = 7.3477e22;%kg
rM = 3474e3/2.0;%m

%Apollo 13:
mA = 5809;%kg
rA = 3.9/2.0;%m

%dist moon earth:
dTL = 384748e3;%m


%dist earth apollo
dAT = 314159e3;%m


scale = 1000;%km
timeScale = 60 * 60 * 24;


switch Ex

case {'1a','1b','1c','1d','1'}

    Ex42;

case {'2a','2b'}

    E43;

case '3a'
    Ex44;
    
    
case {'4a','4b'}

    N        = 3;
    d        = 2;

    v0 = 1.2e3; %m/s

    rMin = 10000+rE;

    vTan = rMin/dAT*sqrt(v0*v0+G*2*mE*(1.0/rMin-1.0/dAT));
    vRad = -v0 * cos (asin (vTan/v0));

    Alpha = mM/(mE+mM);
    Beta = mE/(mE+mM);

    vT = sqrt(G*Alpha*mM/dTL);
    vL = sqrt(G*Beta*mE/dTL);

    dT = Alpha*dTL;
    dL = Beta*dTL;

    % Parametres numeriques :
    tFin     = 2*24*60*60;
    nSteps   = 1000;
    sampling = 1;

    config = sprintf(  ['%s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g'] , ...
                    'N'         ,N                  ,...
                    'd'         ,d                  ,...
                    'tFin'      ,tFin               ,...
                    'G'         ,G                  ,...
                    'sampling'  ,sampling           ,...
                    'e'         ,0.01                );

    switch Ex

        case '4a'
            fOrbit  = figure();
            axOrbit = axes(fOrbit);
            hold on;
            fOrbitZ  = figure();
            axOrbitZ = axes(fOrbitZ);
            hold on;

            %Zoom:
            zSquare = [-25e6,-25e6,50e6,50e6];
            zBound  = [zSquare(1),zSquare(3),zSquare(2),zSquare(4)];

            nSimul = 10;

            distanceMin = ones(1,nSimul);
            velocityMax = ones(1,nSimul);
            timeMax     = ones(1,nSimul);

            theta       = 0.185631;%asin (vTan/v0);
            epsilon     = 0.05;
            voisinage   = linspace ( theta -epsilon,theta + epsilon,nSimul);
            maxEng      = ones(1,nSimul);
            minPosition = ones(1,nSimul);

            for i        = 1:nSimul
                thetaNow = voisinage(i);
                name     = [Ex,'thetaN=',num2str(thetaNow),'.out'];
                %fAcc    = figure();

                sT = input_Body([-dT,0],[0,-vT],1,mE,rE);
                sL = input_Body([dL,0],[0,vL],2,mM,rM);
                sA = input_Body([dAT-dT,0],[-v0 * cos(thetaNow) ,v0 * sin(thetaNow)-vT],3,mA,rA);

                %%%%%  --- SIMULATION ---   %%%%%
                if (Resimulate) %test if the file exists
                    %if not:
                    cmd = sprintf('%s%s %s %s output=%s schema=%s nSteps=%.15g %s %s %s' , repertoire, executable, inputName,config ,name,'A',nSteps, sT, sA, sL);
                    system(strcat("wsl ",cmd)); % Wsl to compile using gcc on the wsl (windows subsystem for linux)
                end

                data = load(name); % Load generated file

                %%%%%   --- Load data   --- %%%%%

                t    = data(:,1);
                x1_1 = data(:,2);
                x2_1 = data(:,3);
                x1_2 = data(:,4);
                x2_2 = data(:,5);
                x1_3 = data(:,6);
                x2_3 = data(:,7);
                v1_1 = data(:,8);
                v2_1 = data(:,9);
                v1_2 = data(:,10);
                v2_2 = data(:,11);
                v1_3 = data(:,12);
                v2_3 = data(:,13);
                eng  = data(:,14);
                a1   = data(:,15);
                a2   = data(:,16);
                a3   = data(:,17);
                pnc1 = data(:,18);
                pnc2 = data(:,19);
                pnc3 = data(:,20);
                dt   = data(:,21);

                %Center on earth:

                Ax = x1_3-x1_1;
                Ay = x2_3-x2_1;

                Lx = x1_2-x1_1;
                Ly = x2_2-x2_1;

                index = 1:length(t);

                h = sqrt((Ax).^2+(Ay).^2);
                distanceMin(i) = min(h);

                iMin = index(distanceMin(i)>=h);
                

                hinter = h(iMin-2:iMin+2);
                hfit = fit(t(iMin-2:iMin+2),hinter,'poly2');
                x=-hfit.p2/(2*hfit.p1);

                distanceMin(i)=x^2*hfit.p1 + x*hfit.p2 + hfit.p3- rMin;


                zoomP = excludedata(Ax,Ay,'box',zBound);
                zoomP = ~zoomP;

                Ax      = Ax/scale;
                Ay      = Ay/scale;
                Lx      = Lx/scale;
                Ly      = Ly/scale;
                zSquare = zSquare/scale;



                pHal = plot(axOrbit,(Ax),(Ay),'.:');
                hold on;
                pL = plot(axOrbit,(Lx),(Ly),'.:','MarkerSize',1,'Color',M('light blue'));

                pHalZ = plot(axOrbitZ,(Ax(zoomP)),(Ay(zoomP)),'.:');


                end

            initA = plot(axOrbit, Ax(1), Ay(1)  ,...
                'x'                             ,...
                'MarkerSize',   3               ,...
                'Color',        M('dark red')   );

            Moon0 = viscircles(axOrbit,[Lx(1),Ly(1)],...
                rM/scale                        ,...
                'LineWidth',    1               ,...
                'Color',        M('light blue') );

            Earth = viscircles(axOrbit,[0,0]    ,...
                rE/scale                        ,...
                'LineWidth',    1               ,...
                'Color',        M('dark green') );

            EarthZ = viscircles(axOrbitZ,[0,0],...
                rE/scale                        ,...
                'LineWidth',    1               ,...
                'Color',        M('dark green') );

            rectangle(axOrbit,'Position',zSquare);

            r           = plot(axOrbit,nan,nan,...
                'ks'                ,....
                'MarkerSize',   5   ,...
                'LineWidth',    1   );

            moonMarker  = plot(axOrbit,nan,nan,...
                'o'                                 ,...
                'MarkerEdgeColor',M('light blue')   ,...
                'MarkerSize'    ,4                  ,...
                'LineWidth'     ,1                  );
            earthMarker = plot(axOrbit,nan,nan,...
                'o'                                 ,...
                'MarkerEdgeColor',M('dark green')   ,...
                'MarkerSize'    ,5                  ,...
                'LineWidth'     ,1);

            figure(fOrbit);
                set(legend,'FontSize',6)
                grid off;
                axOrbit.XLabel.String = 'x [km]';
                axOrbit.YLabel.String = 'y [km]';
                axis image;

            figure(fOrbitZ);
                axOrbitZ.XLabel.String = 'x [km]';
                axOrbitZ.YLabel.String = 'y [km]';
                axis equal;

            l = legend (axOrbit,[pL,earthMarker,moonMarker,initA,r],...
                {'Moon' 'Earth' 'Moon start' 'Apollo start' 'Zoom'},...
                'Location'  ,'best' ,...
                'FontSize'  ,8      );

            figure();
            plot(voisinage,distanceMin,...
                '-'                             ,...
                'Color'     ,M('light blue')    ,...
                'LineWidth' ,1                  );

            hold on;

            plot(voisinage,distanceMin,...
                '+'                                 ,...
                'MarkerEdgeColor',  M('dark blue')  ,...
                'MarkerSize',       5               ,...
                'LineWidth',        1               );

            xlabel('Angle $^\circ$');
            ylabel('Distance - $r_{min}$ [m]');

                %plotVelExp.DisplayName = 'Model';
                %plotVelTh.DisplayName   = 'Theory';

            legend;
        case '4b'

            fOrbit=figure();
            axOrbit = axes(fOrbit);
            hold(axOrbit,'on');
            daspect(axOrbit,[1 1 1])

            fAcc=figure();
            axAcc = axes(fAcc);
            hold(axAcc,'on');

            fEff=figure();
            axEff = axes(fEff);
            hold(axEff,'on')

            fOrbitZ  = figure();
            axOrbitZ = axes(fOrbitZ);
            hold(axOrbitZ,'on')
            daspect(axOrbitZ,[1 1 1])

            %Zoom:
            
            zSquare = [-8e6,0,4e6,4e6];
            zBound  = [zSquare(1),zSquare(2),zSquare(3)+zSquare(1),zSquare(4)+zSquare(2)];
            zLim = [zBound(1) zBound(3) zBound(2) zBound(4)];


            nSimul = 10;

            maxEng      = ones(1,nSimul);
            maxAcc      = ones(1,nSimul);
            reachSurface = ones(1,nSimul);

            theta       = 0.185631;%asin (vTan/v0);
            epsilon     = 0.003;
            voisinage   = linspace ( theta -epsilon,theta + epsilon,nSimul);


            for i           = 1:nSimul
                thetaNow    = voisinage(i);
                name        = [Ex,'thetaN=',num2str(thetaNow),'.out'];
                %fAcc       = figure();

                sT = input_Body([-dT,0], [0,-vT], 1 ,...
                    mE, rE, 1.2, 7238.2, 0, 0       );
                sL = input_Body([dL,0], [0,vL], 2   ,...
                    mM, rM                          );
                sA = input_Body([dAT-dT,0], [-v0 * cos(thetaNow) ,v0 * sin(thetaNow)-vT],...
                    3, mA, rA, 0, 0, 0.3, 2*pi*rA);

                %%%%%  --- SIMULATION ---   %%%%%
                if (Resimulate) %test if the file exists
                    %if not:
                    cmd = sprintf('%s%s %s %s output=%s schema=%s nSteps=%.15g %s %s %s' ,...
                    repertoire, executable, inputName,config ,name,'A',nSteps, sT, sA, sL);
                    system(strcat("wsl ",cmd)); % Wsl to compile using gcc on the wsl (windows subsystem for linux)
                end

                data = load(name); % Load generated file

                %%%%%   --- Load data   --- %%%%%

                t    = data(:,1);
                posEarth  = data(:,2:3);
                posMoon   = data(:,4:5);
                posApollo = data(:,6:7);
                velEarth  = data(:,8:9);
                velMoon   = data(:,10:11);
                velApollo = data(:,12:13);
                eng  = data(:,14);
                accEarth  = data(:,15);
                accMoon   = data(:,16);
                accApollo = data(:,17);
                pncEarth  = data(:,18);
                pncMoon   = data(:,19);
                pncApollo = data(:,20);
                dt        = data(:,21);


                %Everything relative to earth:

                posApollo = posApollo -posEarth;
                posMoon = posMoon -posEarth;

                Ax = posApollo(:,1)/scale;
                Lx = posMoon  (:,1)/scale;
                Ay = posApollo(:,2)/scale;
                Ly = posMoon  (:,2)/scale;


                h = sqrt(sum((posApollo.^2),2));

                zoomP = excludedata(Ax,Ay,'box',zBound/scale);
                zoomP = ~zoomP;

                Range = h>rE+rA;

                pA = plot(axOrbit,posApollo(Range,1)/scale,posApollo(Range,2)/scale,'.:');
                pAZ = plot(axOrbitZ,posApollo(Range,1)/scale,posApollo(Range,2)/scale,'.:');

                pL = plot(axOrbit,posMoon(Range,1)/scale,posMoon(Range,2)/scale,...
                    'o',...
                    'MarkerSize',1);


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


            Moon0 = viscircles(axOrbit,[posMoon(1,:)/scale],...
                rM/scale                        ,...
                'LineWidth',    1               ,...
                'Color',        M('light blue') );


            Earth = viscircles(axOrbit,[0,0]    ,...
                rE/scale                        ,...
                'LineWidth',    1               ,...
                'Color',        M('dark green') );

            rectangle(axOrbit,'Position',zSquare/scale);

            r           = plot(axOrbit,nan,nan,...
                'ks'                ,....
                'MarkerSize',   5   ,...
                'LineWidth',    1   );

            moonMarker  = plot(axOrbit,nan,nan,...
                'o'                                 ,...
                'MarkerEdgeColor',M('light blue')   ,...
                'MarkerSize'    ,4                  ,...
                'LineWidth'     ,1                  );

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
                set(legend,'FontSize',6)
                grid off;
                axOrbit.XLabel.String = 'x [km]';
                axOrbit.YLabel.String = 'y [km]';
                axis(axOrbit,'tight');
                a = axis(axOrbit);
                dx = abs(a(1)-a(2));
                dy = abs(a(3)-a(4));
                axis(axOrbit,[(a(1) - dx/50) (a(2) + dx/50) (a(3) -dy/50) (a(4) + dy/50)]);


            l = legend (axOrbit,[pL,earthMarker,moonMarker,initA,r],...
                {'Moon' 'Earth' 'Moon start' 'Apollo start' 'Zoom'},...
                'Location'  ,'best' ,...
                'FontSize'  ,8      );

        % Zoom:
            figure(fOrbitZ);
                axOrbitZ.XLabel.String = 'x [km]';
                axOrbitZ.YLabel.String = 'y [km]';


        % Max of acceleration
            reachSurface = logical(reachSurface)
            plot(axEff,voisinage(reachSurface),maxAcc(reachSurface),...
                '-'                             ,...
                'Color'     ,M('light blue')    ,...
                'LineWidth' ,1                  );

            axEff.XLabel.String = ('Angle $^\circ$');
            axEff.YLabel.String =('Maximum acceleration [m/s$^2$]');
    end
case {'5a','5b'}

    N        = 3;
    d        = 2;

    Alpha = mM/(mE+mM);
    Beta = mE/(mE+mM);

    vT = sqrt(G*Alpha*mM/dTL);
    vL = sqrt(G*Beta*mE/dTL);

    dT = Alpha*dTL;
    dL = Beta*dTL;

    Omega = vT / dT;

    r = abs (dL + dT);
    d3x0 = r*0.5 - dT;
    d3y0 = sqrt(3) * 0.5 *r;

    d3G = sqrt(d3x0^2 + d3y0^2);
    v3th= d3G * Omega;
    v3x0 = -v3th * d3y0 / d3G;
    v3y0 = v3th * d3x0 / d3G;

    % Parametres numeriques :
    tFin     = 3650*24*60*60;
    nSteps   = 1000;
    sampling = 1;

    config = sprintf(  ['%s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g'] , ...
                    'N'         ,N                  ,...
                    'd'         ,d                  ,...
                    'tFin'      ,tFin               ,...
                    'G'         ,G                  ,...
                    'sampling'  ,sampling           ,...
                    'e'         ,1                );

    switch Ex
    case '5a'
        fOrbit=figure();
        hold on;

        

            name = [Ex,'.out'];
                %fAcc = figure();

            sT = input_Body([-dT,0],[0,-vT],1,mE,rE);
            sL = input_Body([dL,0],[0,vL],2,mM,rM);
            s3 = input_Body([d3x0,d3y0],[v3x0,v3y0],3,mA,rA);

            %%%%%  --- SIMULATION ---   %%%%%
            if (Resimulate) %test if the file exists
                %if not:
                cmd = sprintf('%s%s %s %s output=%s schema=%s nSteps=%.15g %s %s %s' , repertoire, executable, inputName,config ,name,'A',nSteps, sT, s3, sL);
                system(strcat("wsl ",cmd)); % Wsl to compile using gcc on the wsl (windows subsystem for linux)
            end

            data = load(name); % Load generated file

            %%%%%   --- Load data   --- %%%%%

            t        = data(:,1);
            posEarth = data(:,2:3);
            posMoon  = data(:,4:5);
            posSat   = data(:,6:7);
            velEarth = data(:,8:9);
            velMoon  = data(:,10:11);
            velSat   = data(:,12:13);
            eng      = data(:,14);
            accEarth = data(:,15);
            accMoon  = data(:,16);
            accSat   = data(:,17);
            pncEarth = data(:,18);
            pncMoon  = data(:,19);
            pncSat   = data(:,20);
            dt       = data(:,21);


            figure(fOrbit)
                pSat = plot(posSat(:,1),posSat(:,2),'.:');
                hold on;
                pT = plot(posEarth(:,1),posEarth(:,2),...
                    'o',...
                    'MarkerSize',3);

                pL = plot(posMoon(:,1),posMoon(:,2)',...
                    'o',...
                    'MarkerSize',3);
                axis equal;
                xlabel('x [km]');
            ylabel('y [km]');

            dT3 = sqrt(sum((posEarth-posSat).^2,2));
            dL3 = sqrt(sum((posMoon-posSat).^2,2));

            figure()
            plot(t,(dT3-dT3(1))/scale);
            ylabel('distance Earth-Satellite [km]');
            xlabel('t [s]');
            figure()
            plot(t,(dL3-dL3(1))/scale);
            ylabel('distance Moon-Satellite [km]');
            xlabel('t [s]');

            rotx = posMoon/dL;
            roty = [-posMoon(:,2) posMoon(:,1)]/dL;

            figure()
            viscircles([posMoon(:,1) .* rotx(:,1) + posMoon(:,2) .* rotx(:,2),...
                posMoon(:,1) .* roty(:,1) + posMoon(:,2) .* roty(:,2)]/scale,...
                rM*ones(size(t))/scale,...
                'LineWidth',    1               ,...
                'Color',        M('light blue'));
            hold on;

            viscircles([posEarth(:,1) .* rotx(:,1) + posEarth(:,2) .* rotx(:,2),...
                posEarth(:,1) .* roty(:,1) + posEarth(:,2) .* roty(:,2)]/scale,...
                rE*ones(size(t))/scale,...
                'LineWidth',    1               ,...
                'Color',        M('dark green'));

            moonMarker  = plot(nan,nan,...
                'o'                                 ,...
                'MarkerEdgeColor',M('light blue')   ,...
                'MarkerSize'    ,4                  ,...
                'LineWidth'     ,1                  );

            earthMarker = plot(nan,nan,...
                'o'                                 ,...
                'MarkerEdgeColor',M('dark green')   ,...
                'MarkerSize'    ,5                  ,...
                'LineWidth'     ,1);

            pSat = plot((posSat(:,1) .* rotx(:,1) + posSat(:,2) .* rotx(:,2))/scale,...
                (posSat(:,1) .* roty(:,1) + posSat(:,2) .* roty(:,2) )/scale,...
                'o',...
                'MarkerSize',1,...
                'MarkerEdgeColor',M('dark purple') );

            l = legend ([pSat,earthMarker,moonMarker],...
                {'Satellite traj.' 'Moon' 'Earth'},...
                'Location'  ,'best' ,...
                'FontSize'  ,8      );
                set(l,'FontSize',7)

            xlabel('x [km]');
            ylabel('y [km]');
            daspect([1 1 1]);
            axis('tight');
            a = axis;
            dx = abs(a(1)-a(2));
            dy = abs(a(3)-a(4));
            axis([(a(1) - dx/50) (a(2) + dx/50) (a(3) -dy/50) (a(4) + dy/50)]);

            %plotVelExp.DisplayName = 'Model';
            %plotVelTh.DisplayName   = 'Theory';

        legend;

    case '5b'
        fOrbit=figure();
        hold on;

        fOrbitZ  = figure();
        axOrbitZ = axes(fOrbitZ);
        hold(axOrbitZ,'on')
        daspect(axOrbitZ,[1 1 1])

        zSquare = [1.6e8,3.1e8,5.5e7,5.5e7];
        zBound  = [zSquare(1),zSquare(2),zSquare(3)+zSquare(1),zSquare(4)+zSquare(2)];
        zLim = [zBound(1) zBound(3) zBound(2) zBound(4)];



        name = [Ex,'.out'];
            %fAcc = figure();

        sT = input_Body([-dT,0],[0,-vT],1,mE,rE);
        sL = input_Body([dL,0],[0,vL],2,mM,rM);
        s3 = input_Body([d3x0-2341e3,d3y0+3000e3],[v3x0,v3y0],3,mA,rA);

        %%%%%  --- SIMULATION ---   %%%%%
        if (Resimulate) %test if the file exists
            %if not:
            cmd = sprintf('%s%s %s %s output=%s schema=%s nSteps=%.15g %s %s %s' , repertoire, executable, inputName,config ,name,'A',nSteps, sT, s3, sL);
            system(strcat("wsl ",cmd)); % Wsl to compile using gcc on the wsl (windows subsystem for linux)
        end

        data = load(name); % Load generated file

        %%%%%   --- Load data   --- %%%%%

        t        = data(:,1);
        posEarth = data(:,2:3);
        posMoon  = data(:,4:5);
        posSat   = data(:,6:7);
        velEarth = data(:,8:9);
        velMoon  = data(:,10:11);
        velSat   = data(:,12:13);
        eng      = data(:,14);
        accEarth = data(:,15);
        accMoon  = data(:,16);
        accSat   = data(:,17);
        pncEarth = data(:,18);
        pncMoon  = data(:,19);
        pncSat   = data(:,20);
        dt       = data(:,21);


        figure(fOrbit)
            pSat = plot(posSat(:,1),posSat(:,2),'.:');
            hold on;
            pT = plot(posEarth(:,1),posEarth(:,2),...
                'o',...
                'MarkerSize',3);

            pL = plot(posMoon(:,1),posMoon(:,2)',...
                'o',...
                'MarkerSize',3);
            axis equal;
            xlabel('x [km]');
        ylabel('y [km]');

        dT3 = sqrt(sum((posEarth-posSat).^2,2));
        dL3 = sqrt(sum((posMoon-posSat).^2,2));

        figure()
        plot(t,(dT3-dT3(1))/scale);
        ylabel('distance Earth-Satellite [km]');
        xlabel('t [s]');
        figure()
        plot(t,(dL3-dL3(1))/scale);
        ylabel('distance Moon-Satellite [km]');
        xlabel('t [s]');

        rotx = posMoon/dL;
        roty = [-posMoon(:,2) posMoon(:,1)]/dL;

        figure()
        viscircles([posMoon(:,1) .* rotx(:,1) + posMoon(:,2) .* rotx(:,2),...
            posMoon(:,1) .* roty(:,1) + posMoon(:,2) .* roty(:,2)]/scale,...
            rM*ones(size(t))/scale,...
            'LineWidth',    1               ,...
            'Color',        M('light blue'));
        hold on;

        viscircles([posEarth(:,1) .* rotx(:,1) + posEarth(:,2) .* rotx(:,2),...
            posEarth(:,1) .* roty(:,1) + posEarth(:,2) .* roty(:,2)]/scale,...
            rE*ones(size(t))/scale,...
            'LineWidth',    1               ,...
            'Color',        M('dark green'));

        rectangle('Position',zSquare/scale);

        r    = plot(nan,nan,...
            'ks'                ,....
            'MarkerSize',   5   ,...
            'LineWidth',    1   );

        moonMarker  = plot(nan,nan,...
            'o'                                 ,...
            'MarkerEdgeColor',M('light blue')   ,...
            'MarkerSize'    ,4                  ,...
            'LineWidth'     ,1                  );

        earthMarker = plot(nan,nan,...
            'o'                                 ,...
            'MarkerEdgeColor',M('dark green')   ,...
            'MarkerSize'    ,5                  ,...
            'LineWidth'     ,1);

        pSat = plot((posSat(:,1) .* rotx(:,1) + posSat(:,2) .* rotx(:,2))/scale,...
            (posSat(:,1) .* roty(:,1) + posSat(:,2) .* roty(:,2) )/scale,...
            'o',...
            'MarkerSize',1,...
            'MarkerEdgeColor',M('dark purple') );

        l = legend ([pSat,earthMarker,moonMarker,r],...
            {'Satellite traj.' 'Moon' 'Earth' 'Zoom'},...
            'Location'  ,'best' ,...
            'FontSize'  ,8      );
            set(l,'FontSize',7)

        xlabel('x [km]');
        ylabel('y [km]');
        daspect([1 1 1]);
        axis('tight');
        a = axis;
        dx = abs(a(1)-a(2));
        dy = abs(a(3)-a(4));
        axis([(a(1) - dx/30) (a(2) + dx/30) (a(3) -dy/30) (a(4) + dy/30)]);

        pSatZ = plot(axOrbitZ,(posSat(:,1) .* rotx(:,1) + posSat(:,2) .* rotx(:,2))/scale,...
            (posSat(:,1) .* roty(:,1) + posSat(:,2) .* roty(:,2) )/scale,...
            '.',...
            'MarkerSize',2,...
            'MarkerEdgeColor',M('dark purple') );

        axis(axOrbitZ,zLim/scale);
        axOrbitZ.XLabel.String = 'x [km]';
        axOrbitZ.YLabel.String = 'y [km]';
    end

case {'6a','6b','6c','6d'}


    Ex44Aman;

    
end





