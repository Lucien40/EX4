nSimul = 50;
    nSteps = 3;
    schema = 'A'

    distanceMin = ones(1,nSimul);
    velocityMax = ones(1,nSimul);
    eps = logspace(3,-5,nSimul);
    nStepsd = ones(1,nSimul);
    nStepsv = ones(1,nSimul);
    for i = 1:nSimul
        name = [Ex,'e=',num2str(eps(i)),'.out'];;

        e = eps(i);

        runSim;

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

        distanceMin(i)=abs(x^2*hfit.p1 + x*hfit.p2 + hfit.p3 -rMin);

        vinter = v(iMax-2:iMax+2);
        vfit = fit(t(iMax-2:iMax+2),vinter,'poly2');
        x=-vfit.p2/(2*vfit.p1);

        velocityMax(i)=abs(x^2*vfit.p1 + x*vfit.p2 + vfit.p3-vMax);

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