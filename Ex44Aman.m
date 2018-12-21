init2Body;

data = load(name); % Load generated file

%%%%%   --- Load data   --- %%%%%

posEarth  = data(:,2:3);
posMoon   = data(:,4:5);

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
        viscircles(ax,[x1_2(1)/scale x2_2(1)/scale],rM/scale,'Color',colors(2,:));
        pT = plot(ax,x1_1/scale,x2_1/scale,'.');
        viscircles(ax,[x1_1(1)/scale x2_1(1)/scale],rE/scale,'Color',colors(4,:));
        ax.XLabel.String = 'x [ua]';
        ax.YLabel.String = 'y [ua]';
        legend('Moon trajectory','Moon initial position',...
                'Earth trajectory','Earth initial position');
        hold off
        
    case '6b'
        figure
        grid on
        KT = mE*(v1_1.*v1_1+v2_1.*v2_1)/2;
        KL = mM*(v1_2.*v1_2+v2_2.*v2_2)/2;
        distTL = sqrt((x1_1-x1_2).^2 + (x2_1-x2_2).^2);
        GP = G*mE*mM./distTL;
        plot(t,KT + KL - GP)
    case '6c'
        figure
        grid on
        plot(t,mE*sqrt(v1_1.*v1_1+v2_1.*v2_1)+mM*sqrt(v1_2.*v1_2+v2_2.*v2_2))
    case '6d'
        figure
        grid on
        dist = sqrt((x1_1-x1_2).^2+(x2_1-x2_2).^2);
        plot(t,dist-dist(1))
        dEM = sqrt(sum((posEarth-posMoon).^2,2));
        figure
        plot(t,dEM-dEM(1));
        
        
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