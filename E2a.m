
theta = asin (vTan0/v0);
name = [Ex,'.out'];

sT = input_Body([0,0],[0,0],1,mE,rE,1.2,7238.2,0,0);
sA = input_Body([dAT,0],[-v0 * cos(theta) ,v0 * sin(theta)],2,mA,rA,0,0,0.3,2*pi*rA);

sBody = strcat(sT,sA);

nSimul = 50;
nSteps = 3;
schema = 'A';

pMax = ones(1,nSimul);
aMax = ones(1,nSimul);
eps = logspace(-2,-6,nSimul);
nStepsP = ones(1,nSimul);
nStepsA = ones(1,nSimul);
for i = 1:nSimul
    name = [Ex,'e=',num2str(eps(i)),'.out'];


    e = eps(i);

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
    dt        = data(:,15);

    pncApollo = abs(pncApollo);

    index = 1:length(t);

    aMax(i) = max(accApollo);

    pMax(i) = max(pncApollo);

    iMaxP = index(pMax(i)<=pncApollo);
    iMaxA = index(aMax(i)<=accApollo);

    nStepsP(i)= iMaxP(1);
    nStepsA(i)= iMaxA(1);


    ainter = accApollo(nStepsA(i)-2:nStepsA(i)+2);
    afit = fit(t(nStepsA(i)-2:nStepsA(i)+2),ainter,'poly2');
    x=-afit.p2/(2*afit.p1);

    aMax(i)=x^2*afit.p1 + x*afit.p2 + afit.p3;

    pinter = pncApollo(nStepsP(i)-2:nStepsP(i)+2);
    pfit = fit(t(nStepsP(i)-2:nStepsP(i)+2),pinter,'poly2');
    x=-pfit.p2/(2*pfit.p1);

    pMax(i)=(x^2*pfit.p1 + x*pfit.p2 + pfit.p3);

end

fa= figure();
axa = axes(fa);


plot(axa,1./(nStepsA).^4,abs(aMax-aMax(end)),...
'+',...
'LineWidth',1,...
'MarkerEdgeColor',colors(2,:),...
'MarkerSize', 5);

fp= figure();
axp = axes(fp);

plot(axp,1./(nStepsA).^4,abs(pMax-pMax(end)),...
    '+',...
    'LineWidth',1,...
    'MarkerEdgeColor',colors(2,:),'MarkerSize', 5);


fOrbit=figure();
axOrbit = axes(fOrbit);
hold(axOrbit,'on');
daspect(axOrbit,[1 1 1])

fOrbitZ  = figure();
axOrbitZ = axes(fOrbitZ);
hold(axOrbitZ,'on')
daspect(axOrbitZ,[1 1 1])

zSquare = [-8e6,0,4e6,4e6];
zBound  = [zSquare(1),zSquare(2),zSquare(3)+zSquare(1),zSquare(4)+zSquare(2)];
zLim = [zBound(1) zBound(3) zBound(2) zBound(4)];

posApollo = posApollo -posEarth;

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

l = legend (axOrbit,[earthMarker,initA,pA,r],...
    {'Earth' 'Apollo start' 'Apollo traj.' 'Zoom'},...
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
