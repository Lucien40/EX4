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
set(groot, 'DefaultAxesLayer',                  'top'   );
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
mT = 5.972e24; %kg
rT = 6378.1e3;%m

%Moon
mL = 7.3477e22;%kg
rL = 3474e3/2.0;%m

%Apollo 13:
mA = 5809;%kg
rA = 3.9/2.0;%m

%dist moon earth:
dTL = 384748e3;%m

%dist earth apollo
dAT = 314159e3;%m


scale = 1000;%km


switch Ex

case {'1a','1b','1c','1d','1'}

    % Parametres physiques :

    N        = 2;
    d        = 2;

    %Initial velocity
    v0 = 1.2e3; %m/s

    %Energy
    E = 0.5 * mA * v0^2  - G*mA*mT/dAT;

    %Theoretical approach distance
    rMin = 10000+rT;

    %Tangential velocity
    vTan0 = rMin/dAT*sqrt(v0*v0+G*2*mT*(1.0/rMin-1.0/dAT));
    %Radial velocity
    vRad0 = -v0 * cos (asin (vTan0/v0));

    L = mA * vTan0 * dAT;

    vMax = L / (mA * rMin);

    sT = input_Body([0  ,0],[0    ,0    ], 1, mT, rT);
    sA = input_Body([dAT,0],[vRad0,vTan0], 2, mA, rA);

    % Parametres numeriques :
    tFin     = 2*24*60*60;
    sampling = 1;

    config = sprintf(  ['%s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s %s'] , ...
                    'N'         ,N                  ,...
                    'd'         ,d                  ,...
                    'tFin'      ,tFin               ,...
                    'G'         ,G                  ,...
                    'sampling'  ,sampling           ,...
                    sT          ,sA                 );

    switch Ex
        case '1a'

            %Trajectoir apollo 13 pas de temps fixe
            f  = figure();
            ax = axes(f);
            hold on;
            name = [Ex,'.out'];

            nSteps   = input('Number of time steps?');


            %%%%%  --- SIMULATION ---   %%%%%
            if (Resimulate) %test if the file exists
                %if not:
                cmd = sprintf('%s%s %s %s output=%s schema=%s nSteps=%.15g' , repertoire, executable, inputName,config ,name,'F',nSteps);
                system(strcat("wsl ",cmd)); % Wsl to compile using gcc on the wsl (windows subsystem for linux)
            end

            data = load(name); % Load generated file

            %%%%%   --- Load data   --- %%%%%

            t       = data(:,1);
            x1_1    = data(:,2);
            x2_1    = data(:,3);
            x1_2    = data(:,4);
            x2_2    = data(:,5);
            v1_1    = data(:,6);
            v2_1    = data(:,7);
            v1_2    = data(:,8);
            v2_2    = data(:,9);
            %dt = data(:,10);
            %d = data(:,11);
            pHal = plot(ax,(x1_2-x1_1)/scale,(x2_2-x2_1)/scale,...
            '.:',...
            'LineWidth',1,...
            'Color',colors(1,:),...
            'MarkerEdgeColor',colors(2,:),...
            'MarkerSize', 2);
            hold on
            eP = viscircles(ax,[0,0],rT/scale,'Color',colors(4,:));

            legend(ax,[pHal, eP],{'Apollo 13', 'Earth'})

            index = 1:length(t);

            v = sqrt((v1_1-v1_2).^2+(v2_1-v2_2).^2);
            velocityMax = max(v);

            h = sqrt((x1_2-x1_1).^2+(x2_2-x2_1).^2);
            distanceMin = min(h);

            iMin = index(distanceMin>=h);
            iMax = index(velocityMax<=v);


            hinter = h(iMin-2:iMin+2)
            hfit = fit(t(iMin-2:iMin+2),hinter,'poly2');
            x=-hfit.p2/(2*hfit.p1);

                %plot(x1_2(iMin),x2_2(iMin),'bx','MarkerSize',10);

            distanceMin=abs(x^2*hfit.p1 + x*hfit.p2 + hfit.p3 -rMin)

            vinter = v(iMax-2:iMax+2);
                %plot(x1_2(iMax),x2_2(iMax),'rx','MarkerSize',10);
            vfit = fit(t(iMax-2:iMax+2),vinter,'poly2');
            x=-vfit.p2/(2*vfit.p1);

            velocityMax=abs(x^2*vfit.p1 + x*vfit.p2 + vfit.p3-vMax);


            ax.XLabel.String = 'x [km]';
            ax.YLabel.String = 'y [km]';
            %plotVelExp.DisplayName = 'Model';
            %plotVelTh.DisplayName   = 'Theory';

            legend;

        case '1b'
            f  = figure();
            ax = axes(f);
            hold on;

            fInter = figure();
            axInter =axes(fInter);
            hold on;

            %Convergence of fixed time step rungge

            nSimul = 50;

            distanceMin = ones(1,nSimul);
            velocityMax = ones(1,nSimul);

            nStepsd = ones(1,nSimul);
            nStepsv = ones(1,nSimul);

            nSteps = logspace(2,4,nSimul);


            for i = 1:nSimul
                name = [Ex,'nSteps=',num2str(nSteps(i)),'.out'];


                %%%%%  --- SIMULATION ---   %%%%%
                if (Resimulate) %test if the file exists
                    %if not:
                    cmd = sprintf('%s%s %s %s output=%s schema=%s nSteps=%.15g' ,...
                     repertoire, executable, inputName,...
                     config ,name,'F',nSteps(i));
                    system(strcat("wsl ",cmd)); % Wsl to compile using gcc on the wsl (windows subsystem for linux)
                end

                data = load(name); % Load generated file

                %%%%%   --- Load data   --- %%%%%

                t       = data(:,1);
                x1_1    = data(:,2);
                x2_1    = data(:,3);
                x1_2    = data(:,4);
                x2_2    = data(:,5);
                v1_1    = data(:,6);
                v2_1    = data(:,7);
                v1_2    = data(:,8);
                v2_2    = data(:,9);

                %pHal = plot(ax,x1_2,x2_2,'.--');
                %pT   = plot(ax,x1_1,x2_1,'o','MarkerSize',20);

                index = 1:length(t);

                %Norm of veloctiy:

                v = sqrt((v1_1-v1_2).^2+(v2_1-v2_2).^2);
                velocityMax(i) = max(v);

                %Norm of distance

                h = sqrt((x1_2-x1_1).^2+(x2_2-x2_1).^2);
                distanceMin(i) = min(h);

                iMin = index(distanceMin(i)>=h);
                iMax = index(velocityMax(i)<=v);

                nStepsd(i) = iMin;
                nStepsv(i) = iMax; 

                hinter = h(iMin-2:iMin+2);
                hfit = fit(t(iMin-2:iMin+2),hinter,'poly2');

                %plot(axInter,t(iMin-2:iMin+2),hinter);
                %figure(fInter);
                %plot(hfit);
                x=-hfit.p2/(2*hfit.p1);

                %plot(x1_2(iMin),x2_2(iMin),'bx','MarkerSize',10);

                distanceMin(i)=abs(x^2*hfit.p1 + x*hfit.p2 + hfit.p3 -rMin);

                vinter = v(iMax-2:iMax+2);
                %plot(x1_2(iMax),x2_2(iMax),'rx','MarkerSize',10);
                vfit = fit(t(iMax-2:iMax+2),vinter,'poly2');
                x=-vfit.p2/(2*vfit.p1);

                velocityMax(i)=abs(x^2*vfit.p1 + x*vfit.p2 + vfit.p3-vMax);

                %ax.XLabel.String = 'x [m]';
                %ax.YLabel.String = 'y [m]';

                legend;
            end
            fd= figure();
            axd = axes(fd);


            loglog(ax,nStepsd,distanceMin,...
            '+',...
            'LineWidth',1,...
            'MarkerEdgeColor',colors(6,:),...
            'MarkerSize', 5);
            ax.XScale = 'log';
            ax.YScale = 'log';

            fv= figure();
            axv = axes(fv);

            loglog(ax,nStepsv,velocityMax,...
            '+',...
            'LineWidth',1,...
            'MarkerEdgeColor',colors(6,:),...
            'MarkerSize', 5);
            axv.XScale = 'log';
            axv.YScale = 'log';

        case '1c'
            %Trajectoir apollo 13 pas de temps fixe
            f  = figure();
            ax = axes(f);
            hold on;
            name = [Ex,'.out'];

            e = 1;


            %%%%%  --- SIMULATION ---   %%%%%
            if (Resimulate) %test if the file exists
                %if not:
                cmd = sprintf('%s%s %s %s output=%s schema=%s nSteps=%.15g e=%.15g' , repertoire, executable, inputName,config ,name,'A',20,e);
                system(strcat("wsl ",cmd)); % Wsl to compile using gcc on the wsl (windows subsystem for linux)
            end

            data = load(name); % Load generated file

            %%%%%   --- Load data   --- %%%%%

            t       = data(:,1);
            x1_1    = data(:,2);
            x2_1    = data(:,3);
            x1_2    = data(:,4);
            x2_2    = data(:,5);
            v1_1    = data(:,6);
            v2_1    = data(:,7);
            v1_2    = data(:,8);
            v2_2    = data(:,9);
            dt=data(:,end);
            %dt = data(:,10);
            %d = data(:,11);
            pHal = plot(ax,x1_2,x2_2,'.--');
            hold on
            pT = plot(ax,x1_1,x2_1,'o','MarkerSize',20);


            ax.XLabel.String = 'x [m]';
            ax.YLabel.String = 'y [m]';
            %plotVelExp.DisplayName = 'Model';
            %plotVelTh.DisplayName   = 'Theory';

            legend;
        case '1d'

            %f=figure();
            %ax = axes(f);
            %hold on;

            nSimul = 50;

            distanceMin = ones(1,nSimul);
            velocityMax = ones(1,nSimul);
            e = logspace(3,-3,nSimul);
            nStepsd = ones(1,nSimul);
            nStepsv = ones(1,nSimul);
            for i = 1:nSimul
                name = [Ex,'e=',num2str(e(i)),'.out'];


                %%%%%  --- SIMULATION ---   %%%%%
                if (Resimulate) %test if the file exists
                    %if not:
                    cmd = sprintf('%s%s %s %s output=%s schema=%s nSteps=%.15g e=%.15g' ,...
                        repertoire, executable, inputName,...
                        config ,name,'A',5,e(i));
                    system(strcat("wsl ",cmd)); % Wsl to compile using gcc on the wsl (windows subsystem for linux)
                end

                data = load(name); % Load generated file

                %%%%%   --- Load data   --- %%%%%

                t       = data(:,1);
                x1_1    = data(:,2);
                x2_1    = data(:,3);
                x1_2    = data(:,4);
                x2_2    = data(:,5);
                v1_1    = data(:,6);
                v2_1    = data(:,7);
                v1_2    = data(:,8);
                v2_2    = data(:,9);


                %pHal = plot(ax,x1_2,x2_2,'.--');
                %pT   = plot(ax,x1_1,x2_1,'o','MarkerSize',20);

                index = 1:length(t);

                v = sqrt((v1_1-v1_2).^2+(v2_1-v2_2).^2);
                velocityMax(i) = max(v);

                h = sqrt((x1_2-x1_1).^2+(x2_2-x2_1).^2);
                distanceMin(i) = min(h);

                iMin = index(distanceMin(i)>=h);
                iMax = index(velocityMax(i)<=v);

                nStepsd(i)= iMin;
                nStepsv(i)= iMax;


                hinter = h(iMin-2:iMin+2);
                hfit = fit(t(iMin-2:iMin+2),hinter,'poly2');
                x=-hfit.p2/(2*hfit.p1);
                
                %plot(x1_2(iMin),x2_2(iMin),'bx','MarkerSize',10);

                distanceMin(i)=abs(x^2*hfit.p1 + x*hfit.p2 + hfit.p3 -rMin);

                vinter = v(iMax-2:iMax+2);
                %plot(x1_2(iMax),x2_2(iMax),'rx','MarkerSize',10);
                vfit = fit(t(iMax-2:iMax+2),vinter,'poly2');
                x=-vfit.p2/(2*vfit.p1);

                velocityMax(i)=abs(x^2*vfit.p1 + x*vfit.p2 + vfit.p3-vMax);
                

                %ax.XLabel.String = 'x [m]';
                %ax.YLabel.String = 'y [m]';

            end

            fd= figure();
            axd = axes(fd);


            plot(axd,nStepsd,distanceMin,...
            '+',...
            'LineWidth',1,...
            'MarkerEdgeColor',colors(2,:),...
            'MarkerSize', 5);
            axd.XScale = 'log';
            axd.YScale = 'log';

            fv= figure();
            axv = axes(fv);

            plot(axv,nStepsv,velocityMax,...
                '+',...
                'LineWidth',1,...
                'MarkerEdgeColor',colors(2,:),'MarkerSize', 5);
            axv.XScale = 'log';
            axv.YScale = 'log';

        case '1'

            %f=figure();
            %ax = axes(f);
            %hold on;

            nSimul = 50;

            distanceMin = ones(1,nSimul);
            velocityMax = ones(1,nSimul);
            e = logspace(3,-3,nSimul);
            nStepsd = ones(1,nSimul);
            nStepsv = ones(1,nSimul);
            nSteps = ones(1,nSimul);
            for i = 1:nSimul
                name = ['1d','e=',num2str(e(i)),'.out'];


                %%%%%  --- SIMULATION ---   %%%%%
                if (Resimulate) %test if the file exists
                    %if not:
                    cmd = sprintf('%s%s %s %s output=%s schema=%s nSteps=%.15g e=%.15g' ,...
                        repertoire, executable, inputName,...
                        config ,name,'A',5,e(i));
                    system(strcat("wsl ",cmd)); % Wsl to compile using gcc on the wsl (windows subsystem for linux)
                end

                data = load(name); % Load generated file

                %%%%%   --- Load data   --- %%%%%

                t       = data(:,1);
                x1_1    = data(:,2);
                x2_1    = data(:,3);
                x1_2    = data(:,4);
                x2_2    = data(:,5);
                v1_1    = data(:,6);
                v2_1    = data(:,7);
                v1_2    = data(:,8);
                v2_2    = data(:,9);


                %pHal = plot(ax,x1_2,x2_2,'.--');
                %pT   = plot(ax,x1_1,x2_1,'o','MarkerSize',20);

                nSteps(i) = length(t);

                index = 1:nSteps(i);



                v = sqrt((v1_1-v1_2).^2+(v2_1-v2_2).^2);
                velocityMax(i) = max(v);

                h = sqrt((x1_2-x1_1).^2+(x2_2-x2_1).^2);
                distanceMin(i) = min(h);

                iMin = index(distanceMin(i)>=h);
                iMax = index(velocityMax(i)<=v);

                nStepsd(i)= iMin;
                nStepsv(i)= iMax;


                hinter = h(iMin-2:iMin+2);
                hfit = fit(t(iMin-2:iMin+2),hinter,'poly2');
                x=-hfit.p2/(2*hfit.p1);
                
                %plot(x1_2(iMin),x2_2(iMin),'bx','MarkerSize',10);

                distanceMin(i)=abs(x^2*hfit.p1 + x*hfit.p2 + hfit.p3 -rMin);

                vinter = v(iMax-2:iMax+2);
                %plot(x1_2(iMax),x2_2(iMax),'rx','MarkerSize',10);
                vfit = fit(t(iMax-2:iMax+2),vinter,'poly2');
                x=-vfit.p2/(2*vfit.p1);

                velocityMax(i)=abs(x^2*vfit.p1 + x*vfit.p2 + vfit.p3-vMax);
                

                %ax.XLabel.String = 'x [m]';
                %ax.YLabel.String = 'y [m]';

            end

            fd= figure();
            axd = axes(fd);


            pAD = plot(axd,nStepsd,distanceMin,...
            '+',...
            'LineWidth',1,...
            'MarkerEdgeColor',colors(2,:),...
            'MarkerSize', 5);
            axd.XScale = 'log';
            axd.YScale = 'log';
            hold on;

            pTAD = plot(axd,nStepsd,nStepsd.^(-4) * exp((25)),'color',colors(1,:))

            fv= figure();
            axv = axes(fv);

            pAV = plot(axv,nStepsv,velocityMax,...
                '+',...
                'LineWidth',1,...
                'MarkerEdgeColor',colors(2,:),'MarkerSize', 5);
            axv.XScale = 'log';
            axv.YScale = 'log';
            hold on;

            pTAV=plot(axv,nStepsv,nStepsv.^(-4) * exp((18)),'color',colors(1,:))


            %Convergence of fixed time step rungge

            distanceMin = ones(1,nSimul);
            velocityMax = ones(1,nSimul);

            nStepsd = ones(1,nSimul);
            nStepsv = ones(1,nSimul);

            nSteps = logspace(2,4,nSimul);


            for i = 1:nSimul
                name = ['1b','nSteps=',num2str(nSteps(i)),'.out'];


                %%%%%  --- SIMULATION ---   %%%%%
                if (Resimulate) %test if the file exists
                    %if not:
                    cmd = sprintf('%s%s %s %s output=%s schema=%s nSteps=%.15g' ,...
                     repertoire, executable, inputName,...
                     config ,name,'F',nSteps(i));
                    system(strcat("wsl ",cmd)); % Wsl to compile using gcc on the wsl (windows subsystem for linux)
                end

                data = load(name); % Load generated file

                %%%%%   --- Load data   --- %%%%%

                t       = data(:,1);
                x1_1    = data(:,2);
                x2_1    = data(:,3);
                x1_2    = data(:,4);
                x2_2    = data(:,5);
                v1_1    = data(:,6);
                v2_1    = data(:,7);
                v1_2    = data(:,8);
                v2_2    = data(:,9);

                %pHal = plot(ax,x1_2,x2_2,'.--');
                %pT   = plot(ax,x1_1,x2_1,'o','MarkerSize',20);

                index = 1:length(t);

                %Norm of veloctiy:

                v = sqrt((v1_1-v1_2).^2+(v2_1-v2_2).^2);
                velocityMax(i) = max(v);

                %Norm of distance

                h = sqrt((x1_2-x1_1).^2+(x2_2-x2_1).^2);
                distanceMin(i) = min(h);

                iMin = index(distanceMin(i)>=h);
                iMax = index(velocityMax(i)<=v);

                nStepsd(i) = iMin;
                nStepsv(i) = iMax; 

                hinter = h(iMin-2:iMin+2);
                hfit = fit(t(iMin-2:iMin+2),hinter,'poly2');

                %plot(axInter,t(iMin-2:iMin+2),hinter);
                %figure(fInter);
                %plot(hfit);
                x=-hfit.p2/(2*hfit.p1);

                %plot(x1_2(iMin),x2_2(iMin),'bx','MarkerSize',10);

                distanceMin(i)=abs(x^2*hfit.p1 + x*hfit.p2 + hfit.p3 -rMin);

                vinter = v(iMax-2:iMax+2);
                %plot(x1_2(iMax),x2_2(iMax),'rx','MarkerSize',10);
                vfit = fit(t(iMax-2:iMax+2),vinter,'poly2');
                x=-vfit.p2/(2*vfit.p1);

                velocityMax(i)=abs(x^2*vfit.p1 + x*vfit.p2 + vfit.p3-vMax);

            end



            pFD = loglog(axd,nStepsd,distanceMin,...
            '+',...
            'LineWidth',1,...
            'MarkerEdgeColor',colors(6,:),...
            'MarkerSize', 5);
            axd.XScale = 'log';
            axd.YScale = 'log';

            pTFD = plot(axd,nStepsd,nStepsd.^(-4) * exp((37)),'color',colors(5,:))



            pFV = loglog(axv,nStepsv,velocityMax,...
            '+',...
            'LineWidth',1,...
            'MarkerEdgeColor',colors(6,:),...
            'MarkerSize', 5);
            axv.XScale = 'log';
            axv.YScale = 'log';

            pTFV = plot(axv,nStepsv,nStepsv.^(-4) * exp((31)),'color',colors(5,:))


            legend(axv,[pAV,pFV,pTAD,pTFD],{'Adaptive','Fixed','$\frac{1}{N^4}$ trend','$\frac{1}{N^4}$ trend'},'Interpreter','latex')
            axv.XLabel.String = 'N steps';
            axv.YLabel.String = 'Error on $v_{max}$';
            axv.Box = 'off';
            legend(axd,[pAD,pFD,pTAV,pTFV],{'Adaptive','Fixed','$\frac{1}{N^4}$ trend','$\frac{1}{N^4}$ trend'},'Interpreter','latex')
            axd.XLabel.String = 'N steps';
            axd.YLabel.String = 'Error on $h_{min}$';
            axd.Box = 'off';

    end

case {'2a','2b'}
 % Parametres physiques :

    N        = 2;
    d        = 2;

    mA = 5809;%kg
    rA = 3.9/2.0;%m

    dAT = 314159e3;%km

    v0 = 1.2e3; %m/s


    E = 0.5 * mA * v0^2;
    E = E - G*mA*mT/dAT;

    rMin = 10000+rT;

    vTan0 = rMin/dAT*sqrt(v0*v0+G*2*mT*(1.0/rMin-1.0/dAT));
    vRad0 = -v0 * cos (asin (vTan0/v0));

    L = mA *vTan0 * dAT;

    vMax = L/(mA*rMin);

    

    % Parametres numeriques :
    tFin     = 2*24*60*60;
    nSteps   = 5;
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
    case '2a'
        fOrbit = figure();
        fAcc = figure();

        theta = asin (vTan0/v0);
        name = [Ex,'.out'];

        sT = input_Body([0,0],[0,0],1,mT,rT,1.2,7238.2,0,0);
        sA = input_Body([dAT,0],[-v0 * cos(theta) ,v0 * sin(theta)],2,mA,rA,0,0,0.3,2*pi*rA);

        %%%%%  --- SIMULATION ---   %%%%%
        if (Resimulate) %test if the file exists
            %if not:
            cmd = sprintf('%s%s %s %s output=%s schema=%s nSteps=%.15g %s %s' , repertoire, executable, inputName,config ,name,'A',nSteps, sT, sA);
            system(strcat("wsl ",cmd)); % Wsl to compile using gcc on the wsl (windows subsystem for linux)
        end

        data = load(name); % Load generated file

        %%%%%   --- Load data   --- %%%%%

        t    = data(:,1);
        x1_1 = data(:,2);
        x2_1 = data(:,3);
        x1_2 = data(:,4);
        x2_2 = data(:,5);
        v1_1 = data(:,6);
        v2_1 = data(:,7);
        v1_2 = data(:,8);
        v2_2 = data(:,9);
        eng  = data(:,10);
        a1   = data(:,11);
        a2   = data(:,12);
        pnc1 = data(:,13);
        pnc2 = data(:,14);
        dt   = data(:,15);

        
        figure(fOrbit)
        pHal = plot(x1_2,x2_2,'.:');
        hold on;
        pT = plot(x1_1,x2_1,'o','MarkerSize',3);

        figure(fAcc)
        plot(t,a2)

        figure();
        plot(t,sqrt((x1_1-x1_2).^2 + (x2_1-x2_2).^2));

        figure();
        plot(t,pnc2);

        nSimul = 50;

        pMax = ones(1,nSimul);
        aMax = ones(1,nSimul);
        e = logspace(1,-3,nSimul);
        nStepsP = ones(1,nSimul);
        nStepsA = ones(1,nSimul);
        for i = 1:nSimul
            name = [Ex,'e=',num2str(e(i)),'.out'];


            if (Resimulate) %test if the file exists
                %if not:
                cmd = sprintf('%s%s %s %s output=%s schema=%s nSteps=%.15g %s %s e=%.15g' , repertoire, executable, inputName,config ,name,'A',5, sT, sA,e(i));
                system(strcat("wsl ",cmd)); % Wsl to compile using gcc on the wsl (windows subsystem for linux)
            end

            data = load(name); % Load generated file

            %%%%%   --- Load data   --- %%%%%

            t    = data(:,1);
            x1_1 = data(:,2);
            x2_1 = data(:,3);
            x1_2 = data(:,4);
            x2_2 = data(:,5);
            v1_1 = data(:,6);
            v2_1 = data(:,7);
            v1_2 = data(:,8);
            v2_2 = data(:,9);
            eng  = data(:,10);
            a1   = data(:,11);
            a2   = data(:,12);
            pnc1 = data(:,13);
            pnc2 = data(:,14);
            dt   = data(:,15);


            %pHal = plot(ax,x1_2,x2_2,'.--');
            %pT   = plot(ax,x1_1,x2_1,'o','MarkerSize',20);

            index = 1:length(t);

            aMax(i) = max(a2);

            pMax(i) = max(pnc2);

            iMaxP = index(pMax(i)<=pnc2);
            iMaxA = index(aMax(i)<=a2);

            nStepsP(i)= iMaxP(1);
            nStepsA(i)= iMaxA(1);


            ainter = a2(nStepsA(i)-2:nStepsA(i)+2);
            afit = fit(t(nStepsA(i)-2:nStepsA(i)+2),ainter,'poly2');
            x=-afit.p2/(2*afit.p1);


            aMax(i)=x^2*afit.p1 + x*afit.p2 + afit.p3;

            pinter = pnc2(nStepsP(i)-2:nStepsP(i)+2);
            %plot(x1_2(nStepsP(i)),x2_2(nStepsP(i)),'rx','MarkerSize',10);
            pfit = fit(t(nStepsP(i)-2:nStepsP(i)+2),pinter,'poly2');
            x=-pfit.p2/(2*pfit.p1);

            pMax(i)=(x^2*pfit.p1 + x*pfit.p2 + pfit.p3);
            

            %ax.XLabel.String = 'x [m]';
            %ax.YLabel.String = 'y [m]';

        end

        fa= figure();
        axa = axes(fa);


        plot(axa,nStepsA,abs(aMax-aMax(end)),...
        '+',...
        'LineWidth',1,...
        'MarkerEdgeColor',colors(2,:),...
        'MarkerSize', 5);
        axa.XScale = 'log';
        axa.YScale = 'log';

        fp= figure();
        axp = axes(fp);

        plot(axp,nStepsP,abs(pMax-pMax(end)),...
            '+',...
            'LineWidth',1,...
            'MarkerEdgeColor',colors(2,:),'MarkerSize', 5);
        axp.XScale = 'log';
        axp.YScale = 'log';

    case '2b'

        fOrbit=figure();
        hold on;

        fAcc=figure();
        hold on;

        fEff=figure();
        hold on;

        %% a) (i)   ====   Comparer solution analytique et numerique:

        % Name of output file to generate

        nSimul = 100;
        theta = 0.19;%asin (vT/v0);
        epsilon = 0.001;
        voisinage = linspace ( theta -epsilon,theta + epsilon,nSimul);
        maxEng = ones(1,nSimul);
        minPosition = ones(1,nSimul);
        for i = 1:nSimul
            thetaNow = voisinage(i);
            name = [Ex,'thetaN=',num2str(thetaNow),'.out'];

            sT = input_Body([0,0],[0,0],1,mT,rT,1.2,7238.2,0,0);
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
            x1_1 = data(:,2);
            x2_1 = data(:,3);
            x1_2 = data(:,4);
            x2_2 = data(:,5);
            v1_1 = data(:,6);
            v2_1 = data(:,7);
            v1_2 = data(:,8);
            v2_2 = data(:,9);
            eng  = data(:,10);
            a1   = data(:,11);
            a2   = data(:,12);
            dt   = data(:,15);

            h = sqrt((x1_2-x1_1).^2+(x2_2-x2_1).^2);
            index = 1:length(t);
            if(min(h) <= rT + rA)
                Range = index(h>rT+rA);

                figure(fOrbit)
                pHal = plot((x1_2(Range)-x1_1(Range))/scale,(x2_2(Range)-x2_1(Range))/scale,...
                    ':',...
                    'LineWidth',1);

                pHal = plot((x1_2(Range)-x1_1(Range))/scale,(x2_2(Range)-x2_1(Range))/scale,...
                    '.',...
                    'MarkerSize', 2);
                    hold on
                    eP = viscircles([0,0],rT/scale,'Color',colors(4,:));

                legend([pHal, eP],{'Apollo 13', 'Earth'})
                axis image;

                figure(fAcc)
                plot(t(Range),a2(Range))
                hold on;

                figure(fEff)
                plot(thetaNow,max(a2(Range)));
                hold on;


            end

        end
        figure();
        plot(t,sqrt((x1_1-x1_2).^2 + (x2_1-x2_2).^2));
            %plotVelExp.DisplayName = 'Model';
            %plotVelTh.DisplayName   = 'Theory';

        legend;
    end


case '3a'

    N        = 2;
    d        = 2;

    Alpha = mL/(mT+mL);
    Beta = mT/(mT+mL);

    vT = sqrt(G*Alpha*mL/dTL);
    vL = sqrt(G*Beta*mT/dTL);

    dT = Alpha*dTL;
    dL = Beta*dTL;
    % Parametres numeriques :
    tFin     = 10 * 2 * pi * Alpha * dTL / vT;
    nSteps   = 100;
    sampling = 1;

    sT = input_Body([-dT,0],[0,-vT],1,mT,rT);
    sL = input_Body([dL,0],[0,vL],2,mL,rL);

    config = sprintf(  ['%s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s %s'] , ...
                    'N'         ,N                  ,...
                    'd'         ,d                  ,...
                    'tFin'      ,tFin               ,...
                    'G'         ,G                  ,...
                    'sampling'  ,sampling           ,...
                    'e'         ,0.01               ,...
                    sT          ,sL                 );

    f=figure();
    ax = axes(f);
    %% a) (i)   ====   Comparer solution analytique et numerique:

    % Name of output file to generate
    name = [Ex,'.out'];


    %%%%%  --- SIMULATION ---   %%%%%
    if (Resimulate) %test if the file exists
        %if not:
        cmd = sprintf('%s%s %s %s output=%s schema=%s nSteps=%.15g' , repertoire, executable, inputName,config ,name,'A',nSteps);
            system(strcat("wsl ",cmd)); % Wsl to compile using gcc on the wsl (windows subsystem for linux)
    end

    data = load(name); % Load generated file

    %%%%%   --- Load data   --- %%%%%

    t       = data(:,1);
    x1_1    = data(:,2);
    x2_1    = data(:,3);
    x1_2    = data(:,4);
    x2_2    = data(:,5);
    v1_1    = data(:,6);
    v2_1    = data(:,7);
    v1_2    = data(:,8);
    v2_2    = data(:,9);
    engTot  = data(:,10);
    d = data(:,end);

    %dt = data(:,10);
    %d = data(:,11);



    pHal = plot(ax,x1_2,x2_2,'.--');
    hold on
    pT = plot(ax,x1_1,x2_1,'o','MarkerSize',3);

    ax.XLabel.String = 'x [m]'
    ax.YLabel.String = 'y [m]'

    %plotVelExp.DisplayName = 'Model';
    %plotVelTh.DisplayName   = 'Theory';
    distTL = sqrt((x1_1-x1_2).^2 + (x2_1-x2_2).^2);
    grid on;

    figure();
    plot(t,distTL-distTL(1),'-',...
            'LineWidth',1,...
            'Color',colors(2,:));
    figure();
    VT =  sqrt((v1_1).^2 + (v2_1).^2)
    KT = mT * VT.^2*0.5;
    VL = sqrt((v1_2).^2 + (v2_2).^2);
    KL = mL * VL.^2*0.5;
    P = - G * mL * mT ./ distTL;

    plot(t,engTot-engTot(1),'-',...
            'LineWidth',1,...
            'Color',colors(2,:));
    
    figure();
    pTot=sqrt((mL * x1_2 + mT * x1_1).^2 + (mL * x2_2 + mT * x2_1).^2)
    plot(t,pTot - pTot(1),'-',...
            'LineWidth',1,...
            'Color',colors(2,:));

    legend;
    
    
    
    
    
    
    
case {'4a','4b'}
    
    N        = 3;
    d        = 2;

    v0 = 1.2e3; %m/s

    rMin = 10000+rT;

    vTan = rMin/dAT*sqrt(v0*v0+G*2*mT*(1.0/rMin-1.0/dAT));
    vRad = -v0 * cos (asin (vTan/v0));

    Alpha = mL/(mT+mL);
    Beta = mT/(mT+mL);

    vT = sqrt(G*Alpha*mL/dTL);
    vL = sqrt(G*Beta*mT/dTL);

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

                sT = input_Body([-dT,0],[0,-vT],1,mT,rT);
                sL = input_Body([dL,0],[0,vL],2,mL,rL);
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
                rL/scale                        ,...
                'LineWidth',    1               ,...
                'Color',        M('light blue') );

            Earth = viscircles(axOrbit,[0,0]    ,...
                rT/scale                        ,...
                'LineWidth',    1               ,...
                'Color',        M('dark green') );

            EarthZ = viscircles(axOrbitZ,[0,0],...
                rT/scale                        ,...
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
                    mT, rT, 1.2, 7238.2, 0, 0       );
                sL = input_Body([dL,0], [0,vL], 2   ,...
                    mL, rL                          );
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

                Range = h>rT+rA;

                pA = plot(axOrbit,posApollo(Range,1)/scale,posApollo(Range,2)/scale,'.:');
                pAZ = plot(axOrbitZ,posApollo(Range,1)/scale,posApollo(Range,2)/scale,'.:');

                pL = plot(axOrbit,posMoon(Range,1)/scale,posMoon(Range,2)/scale,...
                    'o',...
                    'MarkerSize',1);


                plot(axAcc,t(Range),accApollo(Range));

                reachSurface(i) = min(h) <= rT + rA;

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
                rL/scale                        ,...
                'LineWidth',    1               ,...
                'Color',        M('light blue') );


            Earth = viscircles(axOrbit,[0,0]    ,...
                rT/scale                        ,...
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
                rT/scale                        ,...
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

    Alpha = mL/(mT+mL);
    Beta = mT/(mT+mL);

    vT = sqrt(G*Alpha*mL/dTL);
    vL = sqrt(G*Beta*mT/dTL);

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

            sT = input_Body([-dT,0],[0,-vT],1,mT,rT);
            sL = input_Body([dL,0],[0,vL],2,mL,rL);
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
                rL*ones(size(t))/scale,...
                'LineWidth',    1               ,...
                'Color',        M('light blue'));
            hold on;

            viscircles([posEarth(:,1) .* rotx(:,1) + posEarth(:,2) .* rotx(:,2),...
                posEarth(:,1) .* roty(:,1) + posEarth(:,2) .* roty(:,2)]/scale,...
                rT*ones(size(t))/scale,...
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

            name = [Ex,'.out'];
                %fAcc = figure();

            sT = input_Body([-dT,0],[0,-vT],1,mT,rT);
            sL = input_Body([dL,0],[0,vL],2,mL,rL);
            s3 = input_Body([d3x0,d3y0],[v3x0,v3y0],3,mA,rA);

            %%%%%  --- SIMULATION ---   %%%%%
            if (Resimulate) %test if the file exists
                %if not:
                cmd = sprintf('%s%s %s %s output=%s schema=%s nSteps=%.15g %s %s %s' , repertoire, executable, inputName,config ,name,'A',nSteps, sT, s3, sL);
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


            figure(fOrbit)
                pHal = plot(x1_3,x2_3,'.:');
                hold on;
                pT = plot(x1_1,x2_1,'o');

                pL = plot(x1_2,x2_2,'o','MarkerSize',3);
                axis equal;


            dT3 = sqrt((x1_3-x1_1).^2 + (x2_3-x2_1).^2);
            dL3 = sqrt((x1_3-x1_2).^2 + (x2_3-x2_2).^2);

            figure()
            plot(t,dT3-dT3(1));
            figure()
            plot(t,dL3-dL3(1));
            figure()
            viscircles([x1_2 .* x1_2/dL + x2_2/dL.*x2_2,x2_2 .* x1_2/dL - x2_2/dL.*x1_2],rL*ones(size(t)));
            hold on;

            viscircles([x1_1 .* x1_2/dL + x2_2/dL.*x2_1,x2_1 .* x1_2/dL - x2_2/dL.*x1_1],rT*ones(size(t)));

            plot(x1_3 .* x1_2/dL + x2_2/dL.*x2_3,x2_3 .* x1_2/dL - x2_2/dL.*x1_3);



            %plotVelExp.DisplayName = 'Model';
            %plotVelTh.DisplayName   = 'Theory';

        legend;
    end

case {'6a','6b','6c','6d'}


    N        = 2;
    d        = 2;
    
    mT = 5.972e24; %kg
    rT = 6378.1e3; %m

    mL = 7.3477e22; %kg
    rL = 3474e3/2.0; %m

    distTL0 = 384748e3; %m

    Alpha = mL/(mT+mL);
    Beta = mT/(mT+mL);

    vT = sqrt(G*Alpha*mL/distTL0);
    vL = sqrt(G*Beta*mT/distTL0);

    dT = Alpha*distTL0;
    dL = Beta*distTL0;
    % Parametres numeriques :
    tFin     = 10*2*pi*Alpha*distTL0/vT;
    nSteps   = 100;
    sampling = 1;

    config = sprintf(  ['%s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g' ...
    ' %s=%.15g'] , ...
                    'N'         ,N                  ,...
                    'd'         ,d                  ,...
                    'tFin'      ,tFin               ,...
                    'x1_1'      ,-dT                  ,...
                    'x2_1'      ,0                  ,...
                    'x1_2'      ,dL                 ,...
                    'x2_2'      ,0                  ,...
                    'v1_1'      ,0                  ,...
                    'v2_1'      ,-vT                ,...
                    'v1_2'      ,0                 ,...
                    'v2_2'      ,vL                 ,...
                    'm_1'       ,mT                 ,...
                    'r_1'       ,rT                 ,...
                    'm_2'       ,mL                 ,...
                    'r_2'       ,rL                 ,...
                    'G'         ,G                  ,...
                    'rho_1'       ,0                  ,...
                    'S_1'         ,0                  ,...
                    'Cx_1'        ,0                  ,...
                    'lambda_1'    ,1                  ,...
                    'rho_2'       ,0                  ,...
                    'S_2'         ,0                  ,...
                    'Cx_2'        ,0                  ,...
                    'lambda_2'    ,1                  ,...
                    'sampling'  ,sampling           ,...
                    'e'         ,0.01            );
                
            %% a) (i)   ====   Comparer solution analytique et numerique:

            % Name of output file to generate
            name = [Ex,'.out'];


            %%%%%  --- SIMULATION ---   %%%%%
            if (Resimulate) %test if the file exists
                %if not:
                cmd = sprintf('%s%s %s %s output=%s schema=%s nSteps=%.15g' , repertoire, executable, inputName,config ,name,'A',nSteps);
                    system(strcat("wsl ",cmd)); % Wsl to compile using gcc on the wsl (windows subsystem for linux)
            end

            data = load(name); % Load generated file

            %%%%%   --- Load data   --- %%%%%

            t       = data(:,1);
            x1_1    = data(:,2);
            x2_1    = data(:,3);
            x1_2    = data(:,4);
            x2_2    = data(:,5);
            v1_1    = data(:,6);
            v2_1    = data(:,7);
            v1_2    = data(:,8);
            v2_2    = data(:,9);
            %dt = data(:,10);
            %d = data(:,11);

    switch Ex
        case '6a'
            f=figure();
            ax = axes(f);
            grid on
            hold on
            pHal = plot(ax,x1_2/scale,x2_2/scale,'.');
            viscircles(ax,[x1_2(1)/scale x2_2(1)/scale],rL/scale,'Color',colors(2,:));
            pT = plot(ax,x1_1/scale,x2_1/scale,'.');
            viscircles(ax,[x1_1(1)/scale x2_1(1)/scale],rT/scale,'Color',colors(4,:));
            ax.XLabel.String = 'x [ua]';
            ax.YLabel.String = 'y [ua]';
            legend('Moon trajectory','Moon initial position',...
                   'Earth trajectory','Earth initial position');
            hold off
            
        case '6b'
            figure
            grid on
            KT = mT*(v1_1.*v1_1+v2_1.*v2_1)/2;
            KL = mL*(v1_2.*v1_2+v2_2.*v2_2)/2;
            distTL = sqrt((x1_1-x1_2).^2 + (x2_1-x2_2).^2);
            GP = G*mT*mL./distTL;
            plot(t,KT + KL - GP)
        case '6c'
            figure
            grid on
            plot(t,mT*sqrt(v1_1.*v1_1+v2_1.*v2_1)+mL*sqrt(v1_2.*v1_2+v2_2.*v2_2))
        case '6d'
            figure
            grid on
            dist = sqrt((x1_1-x1_2).^2+(x2_1-x2_2).^2);
            plot(t,dist)
            
            
            %{
            hold on
            grid on
            for e = 0.001:0.001:0.01
                cmd = sprintf('%s%s %s %s output=%s schema=%s nSteps=%.15g e=%.15g' , repertoire, executable, inputName,config ,name,'A',nSteps,e);
                    system(cmd); % Wsl to compile using gcc on the wsl (windows subsystem for linux)
                data = load(name); % Load generated file
            %%%%%   --- Load data   --- %%%%%
            t       = data(:,1);
            x1_1    = data(:,2);
            x2_1    = data(:,3);
            x1_2    = data(:,4);
            x2_2    = data(:,5);
            v1_1    = data(:,6);
            v2_1    = data(:,7);
            v1_2    = data(:,8);
            v2_2    = data(:,9);
                dist = sqrt((x1_1(end)-x1_2(end))^2+(x2_1(end)-x2_2(end))^2);
                plot(e, dist,'b+')
            end
            %}
    end

    
end


function inputS =  input_Body(x,v,N,m,r,varargin)
%myFun - Description
%
% Syntax: string = myFun(pos,vel,number,mass,radius,rho,lambda,Cx,S)
%
% Long description
    s = '';
    for index = 1:length(x)
        i = num2str(index);
        n = num2str(N);
        s = strcat(s,['x' i  '_' n '=' num2str(x(index))]);
        s= strcat(s," ");
        s = strcat(s, ['v' i  '_' n '=' num2str(v(index))]);
        s= strcat(s," ");
    end

    s = strcat(s, ['m_' n '=' num2str(m)]);
    s= strcat(s," ");
    s = strcat(s, ['r_' n '=' num2str(r)]);
    s= strcat(s," ");

    if not(length(varargin)==4)
        s = strcat(s, ['rho_' n '=' num2str(0)]);
        s= strcat(s," ");
        s = strcat(s, ['Cx_' n '=' num2str(0)]);
        s= strcat(s," ");
    else
        s = strcat(s, ['rho_' n '=' num2str(varargin{1})]);
        s= strcat(s," ");
        s = strcat(s, ['lambda_' n '=' num2str(varargin{2})]);
        s= strcat(s," ");
        s = strcat(s, ['Cx_' n '=' num2str(varargin{3})]);
        s= strcat(s," ");
        s = strcat(s, ['S_' n '=' num2str(varargin{4})]);
        s= strcat(s," ");
    end
    inputS = s;
end


function [p z] = zoomPlot(x,y,xbounds,pos,varargin)
    % Please retain the following:
    % 
    % Original Author: 
    % Kelsey Bower, kelsey.bower@case.edu
    if nargin > 5
        printf('Too many arguments. zoomPlot(x,y,xbounds,pos,vertex)\n')
    elseif nargin < 5
        vertex = [1 4];
    elseif nargin == 5
        vertex = varargin{1};
    end
    % Get current axis position and limits
    p = gca;
    % Calculate x,y points of zoomPlot
    x1 = (pos(1)-p.Position(1))/p.Position(3)*diff(p.XLim)+p.XLim(1);
    x2 = (pos(1)+pos(3)-p.Position(1))/p.Position(3)*diff(p.XLim)+(p.XLim(1));
    y1 = (pos(2)-p.Position(2))/p.Position(4)*diff(p.YLim)+p.YLim(1);
    y2 = ((pos(2)+pos(4)-p.Position(2))/p.Position(4))*diff(p.YLim)+p.YLim(1);
    % Plot lines connecting zoomPlot to original plot points
    index = find(x>=xbounds(1) & x<=xbounds(2)); % Find indexes of points in zoomPlot
    rectangle('Position',[xbounds(1) min(y(index)) diff(xbounds) max(y(index))-min(y(index))]);
    hold on
    if any(vertex==1)
        plot([xbounds(1) x1], [max(y(index)) y2], 'k'); % Line to vertex 1
    end
    if any(vertex==2)
        plot([xbounds(2) x2], [max(y(index)) y2], 'k'); % Line to vertex 2
    end
    if any(vertex==3)
        plot([xbounds(2) x2], [min(y(index)) y1], 'k'); % Line to vertex 4
    end
    if any(vertex==4)
        plot([xbounds(1) x1], [min(y(index)) y1], 'k'); % Line to vertex 3
    end
    % Plot zoomPlot and change axis
    z = axes('position',pos);
    box on 
    plot(x,y)
    axis([xbounds(1) xbounds(2) min(y(index)) max(y(index))]);
end
