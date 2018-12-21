fOrbit=figure();
axOrbit = axes(fOrbit);
    hold(axOrbit,'on');
    daspect(axOrbit,[1 1 1])

fdEM=figure();
    axdEM = axes(fdEM);
    hold(axdEM,'on');

fP=figure();
    axP = axes(fP);
    hold(axP,'on');

fEng=figure();
    axEng = axes(fEng);
    hold(axEng,'on');

fOrbitZ  = figure();
    axOrbitZ = axes(fOrbitZ);
    hold(axOrbitZ,'on')
    daspect(axOrbitZ,[1 1 1])

N        = 2;
d        = 2;

Alpha = mM/(mE+mM);
Beta = mE/(mE+mM);

vT = sqrt(G*Alpha*mM/dTL);
vL = sqrt(G*Beta*mE/dTL);


dT = Alpha*dTL;
dL = Beta*dTL;
% Parametres numeriques :
tFin     = 10 * 2 * pi * Alpha * dTL / vT;
nSteps   = 100;
sampling = 1;

sT = input_Body([-dT,0],[0,-vT],1,mE,rE);
sL = input_Body([dL,0],[0,vL],2,mM,rM);

e = 0.001

name = [Ex,'.out'];

sBody = [sT,' ',sL]

runSim;

zSquare = [-1.5e7,-1.5e7,3e7,3e7];
zBound  = [zSquare(1),zSquare(2),zSquare(3)+zSquare(1),zSquare(4)+zSquare(2)];
zLim = [zBound(1) zBound(3) zBound(2) zBound(4)];

data = load(name); % Load generated file

%%%%%   --- Load data   --- %%%%%

t    = data(:,1);
posEarth  = data(:,2:3);
posMoon   = data(:,4:5);
velEarth  = data(:,6:7);
velMoon   = data(:,8:9);
eng  = data(:,10);
accEarth  = data(:,11);
accMoon   = data(:,12);
pncEarth  = data(:,13);
pncMoon   = data(:,14);
dt        = data(:,15);

% Orbits:

orbE = plot(axOrbit,posEarth(:,1)/scale,posEarth(:,2)/scale,...
    '.:'                                ,...
    'Color',            M('light green') ,...
    'MarkerEdgeColor',  M('light green') ,...
    'MarkerSize',       2               ,...
    'LineWidth',        1   );
hold(axOrbit,'on');
orbM = plot(axOrbit,posMoon(:,1)/scale,posMoon(:,2)/scale,...
    '.:'                                ,...
    'Color',            M('light blue') ,...
    'MarkerEdgeColor',  M('dark blue') ,...
    'MarkerSize',       2               ,...
    'LineWidth',        1   );

Earth0 = viscircles(axOrbit,posEarth(1,:)/scale   ,...
            rE/scale                        ,...
            'LineWidth',    1               ,...
            'Color',        M('dark green') );

Moon0 = viscircles(axOrbit,posMoon(1,:)/scale   ,...
            rM/scale                        ,...
            'LineWidth',    1               ,...
            'Color',        M('light blue') );

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

l = legend (axOrbit,[orbM,orbE,moonMarker,earthMarker, r],...
            {'Moon' 'Earth' 'Moon start' 'Earth start' 'zoom'},...
            'Location'  ,'best' ,...
            'FontSize'  ,8      );

set(legend,'FontSize',7)
grid off;
axOrbit.XLabel.String = 'x [km]';
axOrbit.YLabel.String = 'y [km]';
axis(axOrbit,'tight');
a = axis(axOrbit);
dx = abs(a(1)-a(2));
dy = abs(a(3)-a(4));
axis(axOrbit,[(a(1) - dx/50) (a(2) + dx/50) (a(3) -dy/50) (a(4) + dy/50)]);


% --- Zoom:

orbE = plot(axOrbitZ,posEarth(:,1)/scale,posEarth(:,2)/scale,...
    '.:'                                ,...
    'Color',            M('light green') ,...
    'MarkerEdgeColor',  M('light green') ,...
    'MarkerSize',       2               ,...
    'LineWidth',        1   );
hold(axOrbitZ,'on');

Earth0 = viscircles(axOrbitZ,posEarth(1,:)/scale   ,...
            rE/scale                        ,...
            'LineWidth',    1               ,...
            'Color',        M('dark green') );

axOrbitZ.XLabel.String = 'x [km]';
axOrbitZ.YLabel.String = 'y [km]';
axis(axOrbitZ,zLim/scale);


% --- Dist EM:

dEM = sqrt(sum((posEarth-posMoon).^2,2));

pdEM = plot(axdEM,t/timeScale,dEM-dEM(1),...
    '.:'                                ,...
    'Color',            M('light blue') ,...
    'MarkerEdgeColor',  M('dark blue') ,...
    'MarkerSize',       2               ,...
    'LineWidth',        1   );

axdEM.XLabel.String = 't [day]';
axdEM.YLabel.String = 'distance earth moon [m]';
axdEM.XLim = ([t(1)/timeScale t(end)/timeScale])

VE =  sqrt(sum(posEarth.^2,2));
KE = mE * VE.^2*0.5;
VM = sqrt(sum(posMoon.^2,2));
KM = mM * VM.^2*0.5;
P = - G * mM * mE ./ dEM;

pEng = plot(axEng,t/timeScale,eng-eng(1),...
    '.:'                                ,...
    'Color',            M('light blue') ,...
    'MarkerEdgeColor',  M('dark blue') ,...
    'MarkerSize',       2               ,...
    'LineWidth',        1   );

axEng.XLabel.String = 't [day]';
axEng.YLabel.String = 'Energy [J]';
axEng.XLim = ([t(1)/timeScale t(end)/timeScale])


pE = mE * velEarth;
pM = mM * velMoon;
pTot=(pE + pM);

pTotN=sqrt(sum((pE + pM).^2,2));


plot(axP,t/timeScale,pTotN(:,1) - pTotN(1,1),...
    '.:'                                ,...
    'Color',            M('light blue') ,...
    'MarkerEdgeColor',  M('dark blue') ,...
    'MarkerSize',       2               ,...
    'LineWidth',        1   );

axP.XLabel.String = 't [day]';
axP.YLabel.String = 'Momentum - initial momentum [kg m / s]';
axP.XLim = ([t(1)/timeScale t(end)/timeScale])
