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

set(groot, 'DefaultFigureResize',               'on'               );
set(groot, 'DefaultFigurePaperUnits',           'centimeters'       );
set(groot, 'DefaultFigureUnits',                'centimeters'       );
set(groot, 'DefaultFigurePaperSize',            [sizeX, sizeY]      );
set(groot, 'DefaultFigureInvertHardcopy',       'on'                );
set(groot, 'DefaultFigurePaperPosition',        [0, 0, sizeX, sizeY]);
set(groot, 'DefaultFigurePosition',             [10,10,sizeX,sizeY] );

set(groot, 'DefaultAxesColorOrder',             colors          );
set(groot, 'DefaultLineMarkerSize',                 3           );

set(groot, 'DefaultTextInterpreter',            'LaTeX' );
set(groot, 'DefaultAxesTickLabelInterpreter',   'LaTeX' );
set(groot, 'DefaultAxesFontName',               'LaTeX' );
set(groot, 'DefaultAxesFontSize',               10     );
set(groot, 'DefaultLegendFontSize',               8      );
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
mT = 5.972e24 %kg
rT = 6378.1e3%m

%Moon
mL = 7.3477e22%kg

%dist moon earth:
dTL = 384748e3%m





switch Ex

case {'1a','1b','1c'}

    % Parametres physiques :

    N        = 2
    d        = 2

    mA = 5809%kg
    rA = 3.9/2.0%m

    distA0 = 314159e3%km

    v0 = 1.2e3 %m/s


    E = 0.5 * mA * v0^2;
    E = E - G*mA*mT/distA0;
    rMin = 10000+rT;

    vT = rMin/distA0*sqrt(v0*v0+G*2*mT*(1.0/rMin-1.0/distA0));
    vR = -v0 * cos (asin (vT/v0));

    % Parametres numeriques :
    tFin     = 2*24*60*60;
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
    ' %s=%.15g'] , ...
                    'N'         ,N                  ,...
                    'd'         ,d                  ,...
                    'tFin'      ,tFin               ,...
                    'x1_1'      ,0                  ,...
                    'x2_1'      ,0                  ,...
                    'x1_2'      ,distA0             ,...
                    'x2_2'      ,0                  ,...
                    'v1_1'      ,0                  ,...
                    'v2_1'      ,0                  ,...
                    'v1_2'      ,vR                 ,...
                    'v2_2'      ,vT                 ,...
                    'm_1'       ,mT                 ,...
                    'r_1'       ,rT                 ,...
                    'm_2'       ,mA                 ,...
                    'r_2'       ,rA                 ,...
                    'G'         ,G                  ,...
                    'rho'       ,0                  ,...
                    'S'         ,0                  ,...
                    'Cx'        ,0                  ,...
                    'sampling'  ,sampling);

    switch Ex
        case '1a'
            f=figure();
            ax = axes(f);
            hold on;
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
            pHal = plot(ax,x1_2,x2_2,'.--');
            hold on
            pT = plot(ax,x1_1,x2_1,'o','MarkerSize',20);


            ax.XLabel.String = 'x [m]'
            ax.YLabel.String = 'y [m]'
            %plotVelExp.DisplayName = 'Model';
            %plotVelTh.DisplayName   = 'Theory';

            legend;

        case '1b'
            f=figure();
            ax = axes(f);
            hold on;

            distanceMin = ones(1,20);
            nSteps = logspace(4,6,20)
            for i = 1:20;
                name = [Ex,'nSteps=',num2str(nSteps(i)),'.out'];


                %%%%%  --- SIMULATION ---   %%%%%
                if (Resimulate) %test if the file exists
                    %if not:
                    cmd = sprintf('%s%s %s %s output=%s schema=%s nSteps=%.15g' , repertoire, executable, inputName,config ,name,'F',nSteps(i));
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

                pHal = plot(ax,x1_2,x2_2,'.--');
                pT = plot(ax,x1_1,x2_1,'o','MarkerSize',20);

                distanceMin(i)= min(sqrt((x1_2-x1_1).^2+(x2_2-x2_1).^2)-rT);

            ax.XLabel.String = 'x [m]'
            ax.YLabel.String = 'y [m]'

            end

            f= figure()
            ax = axes(f)

            plot(ax,nSteps,distanceMin,'+');



            %plotVelExp.DisplayName = 'Model';
            %plotVelTh.DisplayName   = 'Theory';

            legend;

        case '1c'

            f=figure();
            ax = axes(f);
            hold on;

            distanceMin = ones(1,20);
            e = logspace(-1,-4,20);
            nSteps = ones(1,20);
            for i = 1:20;
                name = [Ex,'e=',num2str(e(i)),'.out'];


                %%%%%  --- SIMULATION ---   %%%%%
                if (Resimulate) %test if the file exists
                    %if not:
                    cmd = sprintf('%s%s %s %s output=%s schema=%s nSteps=%.15g e=%.15g' , repertoire, executable, inputName,config ,name,'A',1000,e(i));
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
                nSteps(i)= length(t);

                pHal = plot(ax,x1_2,x2_2,'.--');
                pT = plot(ax,x1_1,x2_1,'o','MarkerSize',20);

                distanceMin(i)= min(sqrt((x1_2-x1_1).^2+(x2_2-x2_1).^2)-rT);


            ax.XLabel.String = 'x [m]'
            ax.YLabel.String = 'y [m]'

            end

            f= figure()
            ax = axes(f)

            plot(ax,nSteps,distanceMin,'+');



            %plotVelExp.DisplayName = 'Model';
            %plotVelTh.DisplayName   = 'Theory';

            legend;
    end

case {'2a','2b'}
 % Parametres physiques :

    N        = 2
    d        = 2

    mL = 7.3477e22%kg
    rL = 3474e3/2.0%m

    distTL0 = 384748e3%m

    Alpha = mL/(mT+mL)
    Beta = mT/(mT+mL)

    vT = sqrt(G*Alpha*mL/distTL0);
    vL = sqrt(G*Beta*mT/distTL0);

    dT = Alpha*distTL0;
    dL = Beta*distTL0;
    % Parametres numeriques :
    tFin     = 200*24*60*60;
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
                    'rho'       ,0                  ,...
                    'S'         ,0                  ,...
                    'Cx'        ,0                  ,...
                    'sampling'  ,sampling           ,...
                    'e'         ,0.01            );
    switch Ex
        case '2a'
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
            %dt = data(:,10);
            %d = data(:,11);



            pHal = plot(ax,x1_2,x2_2,'.--');
            hold on
            pT = plot(ax,x1_1,x2_1,'o','MarkerSize',3);

            ax.XLabel.String = 'x [m]'
            ax.YLabel.String = 'y [m]'

            %plotVelExp.DisplayName = 'Model';
            %plotVelTh.DisplayName   = 'Theory';

            legend;
        end


case {'3b','3a'}

    f=figure();
            ax = axes(f);
            hold on;

    % Parametres physiques :

    N        = 2
    d        = 2

    mA = 5809%kg
    rA = 3.9/2.0%m

    distA0 = 314159e3%km

    v0 = 1.2e3 %m/s


    E = 0.5 * mA * v0^2;
    E = E - G*mA*mT/distA0;

    vT = sqrt(2*mA*mA*mT*G*(10000+rT)*(1+E/(mA*mA*mA*mT*mT*G*G)))/(mA*distA0);
    vR = -v0 * cos (asin (vT/v0));

    % Parametres numeriques :
    tFin     = 100*24*60*60;
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
    ' %s=%s'] , ...
                    'N'         ,N                  ,...
                    'd'         ,d                  ,...
                    'tFin'      ,tFin               ,...
                    'nSteps'    ,nSteps             ,...
                    'x1_1'      ,0                  ,...
                    'x2_1'      ,0                  ,...
                    'x1_2'      ,distA0             ,...
                    'x2_2'      ,0                  ,...
                    'v1_1'      ,0                  ,...
                    'v2_1'      ,0                  ,...
                    'v1_2'      ,vR                 ,...
                    'v2_2'      ,vT                 ,...
                    'm_1'       ,mT                 ,...
                    'r_1'       ,rT                 ,...
                    'm_2'       ,mA                 ,...
                    'r_2'       ,rA                 ,...
                    'G'         ,G                  ,...
                    'rho'       ,0                  ,...
                    'S'         ,0                  ,...
                    'Cx'        ,0                  ,...
                    'sampling'  ,sampling           ,...
                    'e'         ,0.1                ,...
                    'schema','A');

        name = [Ex,'.out'];


            %%%%%  --- SIMULATION ---   %%%%%
            if (Resimulate) %test if the file exists
                %if not:
                cmd = sprintf('%s%s %s %s output=%s', repertoire, executable, inputName,config ,name);
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



            pHal = plot(ax,x1_2,x2_2,'.--');
            hold on
            pT = plot(ax,x1_1,x2_1,'o','MarkerSize',20);

            ax.XLabel.String = 'x [m]'
            ax.YLabel.String = 'y [m]'

    switch Ex
        case '3a'

        case '3b'

    end

case {'4a','4b'}

    switch Ex
        case '4a'
        case '4b'
    end
case {'5a','5b'}

    switch Ex
        case '5a'
        case '5b'
        case '5c'
    end

case {'6a','6b'}

    switch Ex
        case '6a'
        case '6b'
    end
end
