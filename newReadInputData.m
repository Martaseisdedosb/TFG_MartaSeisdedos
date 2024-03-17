    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   newReadInputData
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Site.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Latitude of the location, positive in the Northern Hemisphere and negative
    %in the Southern Hemisphere.
    Latitude=evalin("base","Latitude");
    
    %Latitude, radians. Internal calculation.
    lat=Latitude*pi/180;
    
    %Longitude of the location, negative towards West and positive towards Est.
    Longitude=evalin("base","Longitude");
    
    %Altitude of the location over sea level.
    Altitude=evalin("base","Altitude");
    
    %Standard longitude of the local meridian (multiple of 15), negative towards 
    %West and positive towards East.
    StandardLongitude=evalin("base","StandardLongitude");
    TimeZone=StandardLongitude/15;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %End Site
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Meteorological data.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Input data
    % 1-Monthly averages from the excel sheet
    % 2-Monthly averages obtained from PVGIS TMY
    % 3-Hourly values from PVGIS TMY
    InputData=evalin("base","InputData");
    if(InputData==1)
        months_Data=evalin("base","months_Data");
        %Read monthly averages from the excel sheet
        %Mean daily global horizonal irradiation, monthly average, Wh/m2.
        Gdm0=(months_Data(1:12,1)');
        %Minimum daily temperature, monthly average, ºC.
        Tmm=(months_Data(1:12,2)');
        %Maximum daily temperature, monthly average, ºC.
        TMm=(months_Data(1:12,3)');
    elseif (InputData==2 || InputData==3)
        %Read TMY PGIS *.csv file
        ReadTMYPVGIS;
    elseif (InputData==4 || InputData==5)
        %Read USA TMY3 *.csv file
        ReadTMY3;
    end
    
    %Generation of time series 
    TimeSeries=evalin("base","TimeSeries");
    %1.	Mean days
    %2.	...
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % End Meteo.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PV generator
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Nominal PV power
    PVnom=evalin("base","PVnom");
    %Coefficient of Variation of module Power with Temperature (absolute value), %
    CVPT=evalin("base","CVPT");
    %Nominal Operation Cell Temperature, ºC
    NOCT=evalin("base","NOCT");
    %Thermal resistance, ºC·m^2/W
    Rth=evalin("base","Rth");
    %Inclination
    InclinationGround=evalin("base","InclinationGround");
    InclinationDelta=evalin("base","InclinationDelta");
    InclinationTracking=evalin("base","InclinationTracking");
    %Orientation of the modules towards the Equator. 
    %Zero towards the South in the Northern Hemisphere (North in the Southern Hemisphere), 
    %negative towards the East, and positive towards the West.
    Orientation=evalin("base","Orientation");
    %Mounting structure
    Mounting=evalin("base","Mounting");
    if(Mounting==1)
        %Static ground or roof
        %Inclination of the modules regarding the horizontal, from 0º to 90º.
        Inclination=InclinationGround;
    elseif(Mounting==2)
        %Static delta
        %Inclination of the modules regarding the horizontal, from 0º to 90º.
        %The same for East and West structrures.
        Inclination=InclinationDelta;
    elseif (Mounting==4)
        %Azimutal tracker
        %Inclination of the modules regarding the horizontal, from 0º to
        %90º.
        Inclination=InclinationTracking;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %End PVgen
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Inverter
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Nominal output power, kW
    PInom=evalin("base","PInom");
    %Maximum output power, kW
    PImax=evalin("base","PImax");
    %Power efficiency curve
    InverterCurve=evalin("base","InverterCurve");
    
    %points: matrix composed of pac and efficiency
    points=evalin("base","points");
    pac=points(1:6,1);
    Efficiency=points(1:6,2);
 
    if(InverterCurve==1)
        %Power efficiency curve parameters
        k0=evalin("base","k0");
        k1=evalin("base","k1");
        k2=evalin("base","k2");
    else
        %Calculation of the previous parameters starting power efficiency
        %points
        [k0, k1, k2]=InverterParameters(pac, Efficiency);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %End Inverter
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Wiring.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %DC losses, %
    WDC=evalin("base","WDC");
    %LV losses, %
    WAC=evalin("base","WAC");
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %End Wiring.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Battery
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Battery. For stand-alone PV systems
    %Battery capacity, kWh
    CBAT=evalin("base","CBAT");
    %Maximum SOC
    SOCmax=evalin("base","SOCmax");
    %Minimum SOC
    SOCmin=evalin("base","SOCmin"); 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %End Battery
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load profiles
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Monthly average of daily energy consumption, kWh/day
    Ldm_Data=evalin("base","Ldm_Data");
    Ldm=(Ldm_Data');
    %Yearly energy demand, kWh
    Edemanda=evalin("base","Edemanda");
    %Normalised daily load profiles
    F_Data=evalin("base","F_Data");
    F=(F_Data');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %End Load
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Options
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %PV application
    Application=evalin("base","Application");
    if(Application==4 && InputData~=3 && InputData~=5)
        error('This simulation requires hourly wind data. Select InputData = Monthly averages obtained from USA TMY3')
    end
    
    %Degree of dust/soiling
    DustDegree=evalin("base","DustDegree");
    %Model of diffuse radiation
    Diffuse_model=evalin("base","Diffuse_model");
    %Monthly correlation between the fraction of diffuse and clearness index
    Diffuse_fraction=evalin("base","Diffuse_fraction");
    %Ground reflectance
    GroundReflectance=evalin("base","GroundReflectance");
    
    %Other parameters
    %Minimum irradiance required to injecting power in the grid, W/m2
    Gth=0;
    %Number of simulated days.
    Ndays=365;
    %Simulation step, seconds. Up to one hour maximum.
    SimulationStep=evalin("base","SimulationStep");
    %Fot TMY data the simulation step must be one hour
    if(InputData==3 || InputData==5 )
        SimulationStep=3600;
    end
    %Number of simulation points per day
    Nsteps=floor((24*60*60)/SimulationStep);
    %Number of simulation points per hour
    Stepph=3600/SimulationStep;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %End Options
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %PUMPING DATA
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Well/borehole
    %Static head, m
    Hs=evalin("base","Hs");
    %Constant test flow, m3/h
    Qtest=evalin("base","Qtest");
    %Drawdown at constant test flow
    Hdr=evalin("base","Hdr");
    %Aquifer loss
    kw1=evalin("base","kw1");
    %Well loss
    kw2=evalin("base","kw2");
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Water tank
    %Water tank capacity
    WTC=evalin("base","WTC");
    %Discharge level
    Hr=evalin("base","Hr");
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Pump
    %Rated flow, m3/h
    Qrated=evalin("base","Qrated");
    %Rated head, m
    Hrated=evalin("base","Hrated");
    %Liquid density, kg/m3
    Density=evalin("base","Density");
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %System curve
    %Friction losses, m
    Hf=evalin("base","Hf");
    %Pump curve
    PumpCurve=evalin("base","PumpCurve");
    %Powers
    PowerCurves=evalin("base","PowerCurves");
    %Motor
    %Rated shaft power, kW
    P2rated=evalin("base","P2rated");
    %Rated speed
    RPMnom=evalin("base","RPMnom");
    % Minimum speed
    RPMcoolM=evalin("base","RPMcoolM");
    RPMcool=RPMnom*RPMcoolM/100;
    % Maximum speed
    RPMmaxM=evalin("base","RPMmaxM");
    RPMmax=RPMnom*RPMmaxM/100;
    %Motor power efficiency
    PowerEffic=evalin("base","PowerEffic");
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %End Pumping
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Generator set
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Nominal power of the genset
    PGENnom=evalin("base","PGENnom");
    %State of charge for connecting the genset
    SOCstart=evalin("base","SOCstart");
    %State of charge for disconnecting the genset
    SOCstop=evalin("base","SOCstop");
    %Fuel consumption model
    %Intercept coefficient 0
    b0i=evalin("base","b0i");
    %Intercept coefficient 1
    b1i=evalin("base","b1i");
    %Slope coefficient 0
    b0s=evalin("base","b0s");
    %Slope coefficient 1
    b1s=evalin("base","b1s");
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %End Genset
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Wind generator
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Rated electrical power
    PWnom=evalin("base","PWnom");
    %Rated wind speed
    Vnom=evalin("base","Vnom");
    %Cut-in wind speed
    Vci=evalin("base","Vci");
    %Cut-out wind speed
    Vco=evalin("base","Vco");
    %Equivalent power coefficient (Cpeq=0,5·r·A·Cp), kW/(m/s)3    
    Cpeq=PWnom/(Vnom^3-Vci^3);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %End Wind
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Save data in the same or a different project
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    saveDataApp=evalin("base","saveDataApp");
    name=evalin("base","name");
    
    
    
    