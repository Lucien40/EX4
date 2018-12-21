e = 0.001
schema = 'F'

name = [Ex,'.out'];

nSteps   = input('Number of time steps?');


%%%%%  --- SIMULATION ---   %%%%%
runSim;

data = load(name); % Load generated file

%%%%%   --- Load data   --- %%%%%

t    = data(:,1);
posEarth  = data(:,2:3);
posApollo = data(:,4:5);
velEarth  = data(:,6:7);
velApollo = data(:,8:9);
eng       = data(:,10);
accEarth  = data(:,11);
accApollo = data(:,12);
pncEarth  = data(:,13);
pncApollo = data(:,14);

index = 1:length(t);

v = sqrt(sum((velApollo-velEarth).^2,2));
velocityMax = max(v);

%Norm of distance

h = sqrt(sum((posApollo-posEarth).^2,2));
distanceMin = min(h);

iMin = index(distanceMin>=h);
iMax = index(velocityMax<=v);

hinter = h(iMin-2:iMin+2)
hfit = fit(t(iMin-2:iMin+2),hinter,'poly2');
x=-hfit.p2/(2*hfit.p1);

distanceMin=abs(x^2*hfit.p1 + x*hfit.p2 + hfit.p3 -rMin)

vinter = v(iMax-2:iMax+2);
vfit = fit(t(iMax-2:iMax+2),vinter,'poly2');
x=-vfit.p2/(2*vfit.p1);

velocityMax=abs(x^2*vfit.p1 + x*vfit.p2 + vfit.p3-vMax);

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

zSquare = [-8e6,0,4e6,4e6];
zBound  = [zSquare(1),zSquare(2),zSquare(3)+zSquare(1),zSquare(4)+zSquare(2)];
zLim = [zBound(1) zBound(3) zBound(2) zBound(4)];

%%% ---  Markers:

% Orbit plot:

pA = plot(axOrbit,posApollo(:,1)/scale,posApollo(:,2)/scale,...
    '.:'                                ,...
    'Color',            M('light red') ,...
    'MarkerEdgeColor',  M('light red') ,...
    'MarkerSize',       2               ,...
    'LineWidth',        1   );
pAZ = plot(axOrbitZ,posApollo(:,1)/scale,posApollo(:,2)/scale,...
    '.:'                                ,...
    'Color',            M('light red') ,...
    'MarkerEdgeColor',  M('light red') ,...
    'MarkerSize',       2               ,...
    'LineWidth',        1   );



initA = plot(axOrbit, posApollo(1,1)/scale, posApollo(1,2)/scale,...
    'x'                             ,...
    'MarkerSize',   3               ,...
    'Color',        M('dark red')   );


Earth = viscircles(axOrbit,[0,0]    ,...
    rE/scale                        ,...
    'LineWidth',    1               ,...
    'Color',        M('dark green') );

rectangle(axOrbit,'Position',zSquare/scale);

r = plot(axOrbit,nan,nan,...
    'ks'                ,...
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
    set(legend,'FontSize',6)
    grid off;
    axOrbit.XLabel.String = 'x [km]';
    axOrbit.YLabel.String = 'y [km]';
    axis(axOrbit,'tight');
    a = axis(axOrbit);
    dx = abs(a(1)-a(2));
    dy = abs(a(3)-a(4));
    axis(axOrbit,[(a(1) - dx/50) (a(2) + dx/50) (a(3) -dy/50) (a(4) + dy/50)]);


l = legend (axOrbit,[earthMarker,initA,pA,r],...
    {'Earth' 'Apollo start' 'Apollo traj.' 'Zoom'},...
    'Location'  ,'best' ,...
    'FontSize'  ,8      );

% Zoom:
figure(fOrbitZ);
    axOrbitZ.XLabel.String = 'x [km]';
    axOrbitZ.YLabel.String = 'y [km]';


