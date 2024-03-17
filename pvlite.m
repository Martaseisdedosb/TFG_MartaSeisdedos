%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PVlite: A simulator of PV systems applications.
% Derechos de autor/Copyright: Federico Javier Muñoz Cano.
% Instituto de Energía Solar. Universidad Politécnica de Madrid.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   pvlite
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Clear workspace
clear;

%Input data
disp('Reading inputs ...');
newReadInputData;
disp('Inputs Ok');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Simulating ...');
%Start
%Generation of irradiance time series.
Irradiances;
%Generation of temperature time series.
Temperatures;
%PV power
if(Mounting==2)
    PVpower_delta;
else
    PVpower;
end

%Applications
if (Application==1)
    %Grid-connected PV system
    mainGrid;
elseif (Application==2)
    %Stand-alone PV system
    mainSA;
elseif (Application==3 || Application==4)
    %Stand-alone hybrid PV system
    mainHybrid;
elseif (Application==5)
    %PV pumping
    mainPump;
end

%save project
if(saveDataApp==1)
    save([name,'.mat']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
