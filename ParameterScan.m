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
mT = 5.972e24; %kg
rT = 6378.1e3;%m

%Moon
mL = 7.3477e22;%kg

%dist moon earth:
dTL = 384748e3;%m





switch Ex

case {'1a','1b','1c'}

    % Parametres physiques :

    N        = 2;
    d        = 2;

    mA = 5809;%kg
    rA = 3.9/2.0;%m

    distAT = 314159e3;%km

    v0 = 1.2e3; %m/s


    E = 0.5 * mA * v0^2;
    E = E - G*mA*mT/distAT;

    rMin = 10000+rT;

    vT = rMin/distAT*sqrt(v0*v0+G*2*mT*(1.0/rMin-1.0/distAT));
    vR = -v0 * cos (asin (vT/v0));

    L = mA *vT * distAT;

    vMax = L/(mA*rMin);

    sT = input_Body([0,0],[0,0],1,mT,rT);
    sA = input_Body([distAT,0],[vR,vT],2,mA,rA);

    % Parametres numeriques :
    tFin     = 10*24*60*60;
    nSteps   = 100;
    sampling = 1;

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
                    sT          ,sA                 );

    switch Ex
        case '1a'

            %Trajectoir apollo 13 pas de temps fixe
            f  = figure();
            ax = axes(f);
            hold on;
            name = [Ex,'.out'];

            nSteps   = 1000;


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
            pHal = plot(ax,x1_2,x2_2,'.--');
            hold on
            pT = plot(ax,x1_1,x2_1,'o','MarkerSize',20);


            ax.XLabel.String = 'x [m]';
            ax.YLabel.String = 'y [m]';
            %plotVelExp.DisplayName = 'Model';
            %plotVelTh.DisplayName   = 'Theory';

            legend;

        case '1b'
            f  = figure();
            ax = axes(f);
            hold on;

            %Convergence of fixed time step rungge

            nSimul = 50;

            distanceMin = ones(1,nSimul);
            velocityMax = ones(1,nSimul);
            nSteps = logspace(4,5,nSimul);
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

                pHal = plot(ax,x1_2,x2_2,'.--');
                pT   = plot(ax,x1_1,x2_1,'o','MarkerSize',20);

                index = 1:length(t);

                v = sqrt((v1_1-v1_2).^2+(v2_1-v2_2).^2);
                velocityMax(i) = max(v);

                h = sqrt((x1_2-x1_1).^2+(x2_2-x2_1).^2);
                distanceMin(i) = min(h);

                iMin = index(distanceMin(i)>=h);
                iMax = index(velocityMax(i)<=v);


                hinter = h(iMin-2:iMin+2)
                hfit = fit(t(iMin-2:iMin+2),hinter,'poly2');
                x=-hfit.p2/(2*hfit.p1);

                %plot(x1_2(iMin),x2_2(iMin),'bx','MarkerSize',10);

                distanceMin(i)=x^2*hfit.p1 + x*hfit.p2 + hfit.p3 -rMin;

                vinter = v(iMax-2:iMax+2);
                %plot(x1_2(iMax),x2_2(iMax),'rx','MarkerSize',10);
                vfit = fit(t(iMax-2:iMax+2),vinter,'poly2');
                x=-vfit.p2/(2*vfit.p1);

                velocityMax(i)=abs(x^2*vfit.p1 + x*vfit.p2 + vfit.p3-vMax);

                ax.XLabel.String = 'x [m]';
                ax.YLabel.String = 'y [m]';

                legend;
            end
            f= figure();
            ax = axes(f);


            plot(ax,nSteps,distanceMin,'+');
            ax.XScale = 'log';
            ax.YScale = 'log';

            f= figure();
            ax = axes(f);

            plot(ax,nSteps,velocityMax,'+');
            ax.XScale = 'log';
            ax.YScale = 'log';

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
                cmd = sprintf('%s%s %s %s output=%s schema=%s nSteps=%.15g e=%.15g' , repertoire, executable, inputName,config ,name,'A',1000,e);
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


            ax.XLabel.String = 'x [m]';
            ax.YLabel.String = 'y [m]';
            %plotVelExp.DisplayName = 'Model';
            %plotVelTh.DisplayName   = 'Theory';

            legend;
        case '1d'

            f=figure();
            ax = axes(f);
            hold on;

            nSimul = 100;

            distanceMin = ones(1,nSimul);
            velocityMax = ones(1,nSimul);
            e = logspace(-3,-6,nSimul);
            nSteps = ones(1,nSimul);
            for i = 1:nSimul
                name = [Ex,'e=',num2str(e(i)),'.out'];


                %%%%%  --- SIMULATION ---   %%%%%
                if (Resimulate) %test if the file exists
                    %if not:
                    cmd = sprintf('%s%s %s %s output=%s schema=%s nSteps=%.15g e=%.15g' ,...
                        repertoire, executable, inputName,...
                        config ,name,'A',1000,e(i));
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
                pT   = plot(ax,x1_1,x2_1,'o','MarkerSize',20);

                index = 1:length(t);

                v = sqrt((v1_1-v1_2).^2+(v2_1-v2_2).^2);
                velocityMax(i) = max(v);

                h = sqrt((x1_2-x1_1).^2+(x2_2-x2_1).^2);
                distanceMin(i) = min(h);

                iMin = index(distanceMin(i)>=h);
                iMax = index(velocityMax(i)<=v);


                hinter = h(iMin-2:iMin+2);
                hfit = fit(t(iMin-2:iMin+2),hinter,'poly2');
                x=-hfit.p2/(2*hfit.p1);
                
                %plot(x1_2(iMin),x2_2(iMin),'bx','MarkerSize',10);

                distanceMin(i)=x^2*hfit.p1 + x*hfit.p2 + hfit.p3- rMin;

                vinter = v(iMax-2:iMax+2);
                %plot(x1_2(iMax),x2_2(iMax),'rx','MarkerSize',10);
                vfit = fit(t(iMax-2:iMax+2),vinter,'poly2');
                x=-vfit.p2/(2*vfit.p1);

                velocityMax(i)=abs(x^2*vfit.p1 + x*vfit.p2 + vfit.p3-vMax);

                ax.XLabel.String = 'x [m]';
                ax.YLabel.String = 'y [m]';

            end

            f= figure();
            ax = axes(f);


            plot(ax,nSteps,distanceMin,'+');
            ax.XScale = 'log';
            ax.YScale = 'log';

            f= figure();
            ax = axes(f);

            plot(ax,nSteps,velocityMax,'+');
            ax.XScale = 'log';
            ax.YScale = 'log';



            %plotVelExp.DisplayName = 'Model';
            %plotVelTh.DisplayName   = 'Theory';

            legend;
    end

case {'2a','2b'}
 % Parametres physiques :

    N        = 2;
    d        = 2;

    mA = 5809;%kg
    rA = 3.9/2.0;%m

    distAT = 314159e3;%km

    v0 = 1.2e3; %m/s


    E = 0.5 * mA * v0^2;
    E = E - G*mA*mT/distAT;

    rMin = 10000+rT;

    vT = rMin/distAT*sqrt(v0*v0+G*2*mT*(1.0/rMin-1.0/distAT));
    vR = -v0 * cos (asin (vT/v0));

    L = mA *vT * distAT;

    vMax = L/(mA*rMin);

    

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
        case '2a'
            fOrbit=figure();
            hold on;
            
            fAcc=figure();
            hold on;
            
            fEff=figure();
            hold on;

            %% a) (i)   ====   Comparer solution analytique et numerique:

            % Name of output file to generate

            nSimul = 100;
            theta = asin (vT/v0);
            epsilon = 0.01
            voisinage = linspace ( theta -epsilon,theta + epsilon,nSimul)
            maxEng = ones(1,nSimul);
            minPosition = ones(1,nSimul);
            for i = 1:nSimul
                thetaNow = voisinage(i);
                name = [Ex,'thetaN=',num2str(thetaNow),'.out'];
                
            sT = input_Body([0,0],[0,0],1,mT,rT,1.2,7238.2,0,0);
            sA = input_Body([distAT,0],[-v0 * cos(thetaNow) ,v0 * sin(thetaNow)],2,mA,rA,0,0,0.3,2*pi*rA);
            

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
            dt   = data(:,13);

            h = sqrt((x1_2-x1_1).^2+(x2_2-x2_1).^2);
            index = 1:length(t);
            if(min(h) <= rT + rA)
                Range = index(h>rT+rA);

                figure(fOrbit)
                pHal = plot(x1_2(Range),x2_2(Range),'.:');
                hold on;
                pT = plot(x1_1(Range),x2_1(Range),'o','MarkerSize',3);

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
        case '2b'
    end


case {'3b','3a'}

    N        = 2
    d        = 2

    mL = 7.3477e22%kg
    rL = 3474e3/2.0%m

    distTL0 = 384748e3%m

    Alpha = mL/(mT+mL);
    Beta = mT/(mT+mL);

    vT = sqrt(G*Alpha*mL/distTL0);
    vL = sqrt(G*Beta*mT/distTL0);

    dT = Alpha*distTL0;
    dL = Beta*distTL0;
    % Parametres numeriques :
    tFin     = 200*24*60*60;
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
    switch Ex

        case '3a'

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

                  figure();
            plot(t,sqrt((x1_1-x1_2).^2 + (x2_1-x2_2).^2));

            legend;

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
