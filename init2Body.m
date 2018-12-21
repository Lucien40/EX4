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

e = 0.01

name = [Ex,'.out'];

sBody = [sT,' ',sL]

runSim;