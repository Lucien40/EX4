e = 0.001
schema = 'F'

%Convergence of fixed time step rungge

nSimul = 50;

distanceMin = ones(1,nSimul);
velocityMax = ones(1,nSimul);

nStepsd = ones(1,nSimul);
nStepsv = ones(1,nSimul);

nStepsA = logspace(3,5,nSimul);


for i = 1:nSimul
    name = [Ex,'nSteps=',num2str(nStepsA(i)),'.out'];

    nSteps = nStepsA(i);

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

    %Norm of veloctiy:

    v = sqrt(sum((velApollo-velEarth).^2,2));
    velocityMax(i) = max(v);

    %Norm of distance

    h = sqrt(sum((posApollo-posEarth).^2,2));
    distanceMin(i) = min(h);

    iMin = index(distanceMin(i)>=h);
    iMax = index(velocityMax(i)<=v);

    nStepsd(i) = iMin;
    nStepsv(i) = iMax; 

    hinter = h(iMin-2:iMin+2);
    hfit = fit(t(iMin-2:iMin+2),hinter,'poly2');
    x=-hfit.p2/(2*hfit.p1);

    distanceMin(i)=abs(x^2*hfit.p1 + x*hfit.p2 + hfit.p3 -rMin);

    vinter = v(iMax-2:iMax+2);
    vfit = fit(t(iMax-2:iMax+2),vinter,'poly2');
    x=-vfit.p2/(2*vfit.p1);

    velocityMax(i)=abs(x^2*vfit.p1 + x*vfit.p2 + vfit.p3-vMax);

    legend;
end

fv  = figure();
axv = axes(fv);
hold(axv,'on');

fd= figure();
axd = axes(fd);
hold(axd,'on');


loglog(axd,nStepsd,distanceMin,...
    '+',...
    'LineWidth',1,...
    'MarkerEdgeColor',colors(6,:),...
    'MarkerSize', 5);
axd.XScale = 'log';
axd.YScale = 'log';


loglog(axv,nStepsv,velocityMax,...
    '+',...
    'LineWidth',1,...
    'MarkerEdgeColor',colors(6,:),...
    'MarkerSize', 5);
axv.XScale = 'log';
axv.YScale = 'log';
