
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
        s = strcat(s,['x' i  '_' n '=' num2str(x(index),32)]);
        s= strcat(s," ");
        s = strcat(s, ['v' i  '_' n '=' num2str(v(index),32)]);
        s= strcat(s," ");
    end

    s = strcat(s, ['m_' n '=' num2str(m)]);
    s= strcat(s," ");
    s = strcat(s, ['r_' n '=' num2str(r)]);
    s= strcat(s," ");

    if not(length(varargin)==4)
        s = strcat(s, ['rho_' n '=' num2str(0,32)]);
        s= strcat(s," ");
        s = strcat(s, ['Cx_' n '=' num2str(0,32)]);
        s= strcat(s," ");
    else
        s = strcat(s, ['rho_' n '=' num2str(varargin{1},32)]);
        s= strcat(s," ");
        s = strcat(s, ['lambda_' n '=' num2str(varargin{2},32)]);
        s= strcat(s," ");
        s = strcat(s, ['Cx_' n '=' num2str(varargin{3},32)]);
        s= strcat(s," ");
        s = strcat(s, ['S_' n '=' num2str(varargin{4},32)]);
        s= strcat(s," ");
    end
    inputS = s;
end