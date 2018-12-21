% Parametres physiques :

N        = 2;
d        = 2;

%Initial velocity
v0 = 1.2e3; %m/s

%Theoretical approach distance
rMin = 10000+rE;

%Tangential velocity
vTan0 = rMin/dAT*sqrt(v0*v0+G*2*mE*(1.0/rMin-1.0/dAT));
%Radial velocity
vRad0 = -v0 * cos (asin (vTan0/v0));

L = mA * vTan0 * dAT;

vMax = L / (mA * rMin);

sT = input_Body([0  ,0],[0    ,0    ], 1, mE, rE);
sA = input_Body([dAT,0],[vRad0,vTan0], 2, mA, rA);

% Parametres numeriques :
tFin     = 2*24*60*60;
sampling = 1;

sBody = strcat(sT,sA);

switch Ex
case '1a'

    E1a;

case '1b'

    E1b;

case '1c'

    E1c;

case '1d'

    E1d;

case '1'

    E1d;

    fdB= figure();
    axdB = axes(fdB);


    pAD = plot(axdB,nStepsd,distanceMin,...
    '+',...
    'LineWidth',1,...
    'MarkerEdgeColor',colors(2,:),...
    'MarkerSize', 5);
    axdB.XScale = 'log';
    axdB.YScale = 'log';
    hold on;

    pTAD = plot(axdB,nStepsd,nStepsd.^(-4) * exp((23.5)),...
    '-'                                ,...
    'Color',            M('light orange') ,...
    'MarkerSize',       2               ,...
    'LineWidth',        1   );
    fvB= figure();
    axvB = axes(fvB);

    pAV = plot(axvB,nStepsv,velocityMax,...
        '+',...
        'LineWidth',1,...
        'MarkerEdgeColor',colors(2,:),'MarkerSize', 5);
    axvB.XScale = 'log';
    axvB.YScale = 'log';
    hold on;

    pTAV=plot(axvB,nStepsv,nStepsv.^(-4) * exp((17)),...
    '-'                                ,...
    'Color',            M('light orange') ,...
    'MarkerSize',       2               ,...
    'LineWidth',        1   );


    %Convergence of fixed time step rungge

    E1b;


    pFD = loglog(axdB,nStepsd,distanceMin,...
    '+',...
    'LineWidth',1,...
    'MarkerEdgeColor',colors(6,:),...
    'MarkerSize', 5);
    axdB.XScale = 'log';
    axdB.YScale = 'log';

    pTFD = plot(axdB,nStepsd,nStepsd.^(-4) * exp((36)),...
    '-'                                ,...
    'Color',            M('light purple') ,...
    'MarkerSize',       2               ,...
    'LineWidth',        1   );



    pFV = loglog(axvB,nStepsv,velocityMax,...
    '+',...
    'LineWidth',1,...
    'MarkerEdgeColor',colors(6,:),...
    'MarkerSize', 5);
    axvB.XScale = 'log';
    axvB.YScale = 'log';

    pTFV = plot(axvB,nStepsv,nStepsv.^(-4) * exp((30)),...
    '-'                                ,...
    'Color',            M('light purple') ,...
    'MarkerSize',       2               ,...
    'LineWidth',        1   );


    legend(axvB,[pAV,pFV,pTAD,pTFD],{'Adaptive','Fixed','$\frac{1}{N^4}$ trend','$\frac{1}{N^4}$ trend'},'Interpreter','latex')
    axvB.XLabel.String = 'N steps';
    axvB.YLabel.String = 'Error on $v_{max} [m/s]$';
    axvB.Box = 'off';
    legend(axdB,[pAD,pFD,pTAV,pTFV],{'Adaptive','Fixed','$\frac{1}{N^4}$ trend','$\frac{1}{N^4}$ trend'},'Interpreter','latex')
    axdB.XLabel.String = 'N steps';
    axdB.YLabel.String = 'Error on $h_{min} [m]$';
    axdB.Box = 'off';
end