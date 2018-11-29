package SimpleBuilding

    model Room
        parameter Modelica.SIunits.Volume V = 30 "Volume of the room";
        parameter Modelica.SIunits.Area A = 9 "Area of the exterior wall";
        parameter Modelica.SIunits.Temperature Tair_start = 273.15 + 20
            "Initial temperature of the air in the room";
        parameter Modelica.SIunits.Temperature Twall_start = 273.15 + 20
            "Initial temperature of the wall layers";
        parameter Integer n=4 "Number of wall layers";
        parameter Modelica.SIunits.Length l[n] = {0.01, 0.05, 0.02, 0.005}
            "Thickness of the wall layers";
        parameter Modelica.SIunits.Density d[n] = {900, 500, 800, 1200}
            "Density of the wall layers";
        parameter Modelica.SIunits.SpecificHeatCapacity cp[n] = {1760, 800, 1000, 2000}
            "Specific heat capacity of the wall layers";
        parameter Modelica.SIunits.ThermalResistance r[n] = {15, 20, 10, 0.5}
            "Thermal resistance of the wall layers";
        parameter Real absorptivity(unit="1") = 0.4
            "Absorptivity of the external wall surface";
        parameter Modelica.SIunits.Angle wall_azimuth(unit="deg") = 0
            "Wall azimuth angle (0: South, -90: East, 90: West, 180: North)";
        constant Modelica.SIunits.Angle lat(unit="deg") = 37.773972
            "Latitude of the location";
        constant Modelica.SIunits.Angle lon(unit="deg") = -122.431297
            "Longitude of the location";
        parameter Modelica.SIunits.Time TimeDay(unit="hour") = 8
            "Start time of the day-time set point schedule";
        parameter Modelica.SIunits.Time TimeNight(unit="hour") = 18
            "End time of the day-time set point schedule";
        parameter Modelica.SIunits.Time RiseTime(unit="minute") = 30
            "Time to for set point change";
        parameter Modelica.SIunits.Temp_C Tnight = 18
            "Temperature set point of the room during the night-time";
        parameter Modelica.SIunits.Temp_C Tday = 22
            "Temperature set point of the room during the day-time";
        parameter Modelica.SIunits.Time tau(unit="minute") = 10
            "Time constant for set point filter";
        parameter Real ACH(unit="m3/hour") = 2.5 "Air changes per hour";

        parameter Modelica.SIunits.Area Aw = 2
            "Area of the window";
        parameter Real SHGC(unit="1") = 0.5
            "Glass solar heat gain coefficient";

        input Real T_dry_bulb(unit="degC");
        input Real dir_rad(unit="W/m2");
        input Real diff_hor_rad(unit="W/m2");
        input Real timeOfYear(unit="s");

        output Modelica.SIunits.Temp_C Troom
            "Temperature of the air in the room";
        output Modelica.SIunits.Temp_C Twall[n]
            "Temperature of the wall layers";
        output Modelica.SIunits.Temp_C Tsp
            "Temperature Set POint for the room";
        output Modelica.SIunits.Power Qheat
            "Heating power to control the room temperature";
        output Modelica.SIunits.Power Qcool
            "Cooling power to control the room temperature";
        output Modelica.SIunits.Power SolRadWall
            "Solar radiation incident on the exterior wall";
        output Modelica.SIunits.Power SolRadWindow
            "Solar radiation incident on the window";
    protected
        parameter Modelica.SIunits.SpecificHeatCapacity cpAir = 1000
            "Specific heat capacity of dry air";
        parameter Modelica.SIunits.Density rhoAir = 1.2
            "Density of dry air";
        Modelica.Thermal.HeatTransfer.Components.ThermalConductor gACH(
            G=ACH*V/3600*cpAir*rhoAir
        );
        Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature Text;
        Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature TRoomControl;
        Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow solGainWal;
        Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow solGainWin;
        Modelica.Blocks.Continuous.FirstOrder spFilter(y_start=Tnight, T=tau*60);
        Modelica.Blocks.Sources.CombiTimeTable TSetPoint(
            tableOnFile=false,
            table=[
                0, 273.15 + Tnight;
                TimeDay*3600, 273.15 + Tnight;
                TimeDay*3600 + RiseTime*60, 273.15 + Tday;
                TimeNight*3600, 273.15 + Tday;
                TimeNight*3600 + RiseTime*60, 273.15 + Tnight;
                24*3600, 273.15 + Tnight],
            extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic
        );
        Wall wall(
            A=A, n=n, l=l,
            d=d, cp=cp, r=r,
            T_start=Twall_start
        );
        Window window(
            A = Aw
        );
        IncidenceAngle inc(
            lat = lat,
            long = lon,
            wall_azimuth = 0,
            wall_tilt = wall_azimuth*Modelica.Constants.pi / 180
        );
        Modelica.Thermal.HeatTransfer.Components.HeatCapacitor air(
            C=V*rhoAir*cpAir,
            T(start=Tair_start)
        );
    equation
        // Inputs
        inc.timeOfYear = timeOfYear;
        Text.T = T_dry_bulb + 273.15;
        solGainWal.Q_flow = (dir_rad)*A*inc.cosTheta*absorptivity + diff_hor_rad*A*absorptivity;
        solGainWin.Q_flow = (dir_rad)*Aw*inc.cosTheta*SHGC + diff_hor_rad*Aw*SHGC;

        // Set point and idealized control
        connect(TSetPoint.y[1], spFilter.u);
        TRoomControl.T = spFilter.y;
        connect(TRoomControl.port, air.port);

        // Air change - infiltration
        connect(Text.port, gACH.port_a);
        connect(air.port, gACH.port_b);

        // Wall
        connect(wall.solar, solGainWal.port);
        connect(wall.exterior, Text.port);
        connect(wall.interior, air.port);

        // Window
        connect(window.solar, solGainWin.port);
        connect(window.exterior, Text.port);
        connect(window.interior, air.port);

        // Outputs
        Troom = air.port.T - 273.15;
        for i in 1:n loop
            Twall[i] = wall.C[i].T - 273.25;
        end for;
        Tsp = spFilter.u - 273.15;
        Qheat = -min(TRoomControl.port.Q_flow, 0);
        Qcool = max(TRoomControl.port.Q_flow, 0);
        SolRadWall = solGainWal.Q_flow;
        SolRadWindow = solGainWin.Q_flow;
    end Room;

    model IncidenceAngle
        // http://holbert.faculty.asu.edu/eee463/SolarCalcs.pdf
        parameter Real lat = 37.773972 "Latitude";
        parameter Real long = -122.431297 "Latitude";
        parameter Real wall_azimuth = 0*degToRad "wall azimuth";
        parameter Real wall_tilt = 90*degToRad "wall tilt angle";

        input Real timeOfYear "Time of the day in seconds measured from Jan 1st";
        output Real cosTheta "Incident angle";
    protected
        parameter Real PI = Modelica.Constants.pi;
        parameter Real degToRad = PI/180;
        parameter Real LSTM = floor(long / 15) * 15;
        Real delta "Declination sun angle";
        Real et "Equation of time";
        Real dt "Daylight savings time";
        Real ast "Apparent solar time";
        Real D;
        Real h "Solar time angle";
        Real theta_z "zenith angle";
        Real beta_1 "altitude angle";
        Real alpha_1 "solar azimuth";
    equation
        delta = 23.45*degToRad*sin(2*PI*(timeOfYear/86400 + 284)/365);
        D = 360*(timeOfYear/86400 - 81)/365 * degToRad;
        et = (9.87*sin(2*D) - 7.53*cos(D) - 1.5*sin(D))*60;
        dt = if (timeOfYear > (31+28+12)*24*3600.0 and timeOfYear < (365-31-25)*24*3600) then 3600.0 else 0.0;
        ast = timeOfYear + 4*60*(LSTM - long) + et + dt;
        h = (noEvent(mod(ast, 86400)) - 720*60)/(4*60)*degToRad;

        theta_z = Modelica.Math.acos(cos(lat*degToRad)*cos(delta)*cos(h) + sin(lat*degToRad)*sin(delta));
        beta_1 = Modelica.Math.asin(cos(lat*degToRad)*cos(delta)*cos(h) + sin(lat*degToRad)*sin(delta));
        alpha_1 = Modelica.Math.acos((sin(beta_1)*sin(lat*degToRad) - sin(delta))/(cos(beta_1)*cos(lat*degToRad)));
        cosTheta = max(0, sin(beta_1)*cos(wall_tilt)+ cos(beta_1)*sin(wall_tilt)*cos(alpha_1 - wall_azimuth));
    end IncidenceAngle;

    model Window
        Modelica.Thermal.HeatTransfer.Interfaces.HeatPort exterior;
        Modelica.Thermal.HeatTransfer.Interfaces.HeatPort solar;
        Modelica.Thermal.HeatTransfer.Interfaces.HeatPort interior;
        parameter Modelica.SIunits.CoefficientOfHeatTransfer cExt = 25
            "Convective heat transfer coefficient for the exterior surface";
        parameter Modelica.SIunits.CoefficientOfHeatTransfer cInt = 10
            "Convective heat transfer coefficient for the interior surface";
        parameter Modelica.SIunits.Area A = 1
            "Area of the window";
        parameter Modelica.SIunits.Length l = 0.0025
            "Thickness of the glass";
        parameter Modelica.SIunits.ThermalResistance r = 1.0/1.05
            "Thermal resistance of the glass";
        Modelica.Thermal.HeatTransfer.Components.ThermalResistor R(
            R = 1.0/(A*cExt) + (1.0/A)*r*l + 1.0/(A*cInt) 
        );
    equation
        connect(exterior, R.port_a);
        connect(interior, R.port_b);
        connect(interior, solar);
    end Window;

    model Wall
        Modelica.Thermal.HeatTransfer.Interfaces.HeatPort exterior;
        Modelica.Thermal.HeatTransfer.Interfaces.HeatPort solar;
        Modelica.Thermal.HeatTransfer.Interfaces.HeatPort interior;
        parameter Integer n=4
            "Number fo layers";
        parameter Modelica.SIunits.Temperature T_start = 273.15 + 20
            "Initial temperature of the layers";
        parameter Modelica.SIunits.Area A = 1
            "Area of the wall";
        parameter Modelica.SIunits.Length l[n] = 0.05*ones(n)
            "Thickness of the layers";
        parameter Modelica.SIunits.Density d[n] = 900*ones(n)
            "Density of each layer";
        parameter Modelica.SIunits.SpecificHeatCapacity cp[n] = 1760*ones(n)
            "Specific heat capacity of each layer";
        parameter Modelica.SIunits.ThermalResistance r[n] = 15*ones(n)
            "Thermal resistance of each layer";
        parameter Modelica.SIunits.CoefficientOfHeatTransfer cExt = 25
            "Convective heat transfer coefficient for the exterior surface";
        parameter Modelica.SIunits.CoefficientOfHeatTransfer cInt = 10
            "Convective heat transfer coefficient for the interior surface";
        Modelica.Thermal.HeatTransfer.Components.HeatCapacitor C[n](
            C = {A*d[i]*l[i]*cp[i] for i in 1:n},
            each T(start = T_start)
        );
        Modelica.Thermal.HeatTransfer.Components.ThermalResistor R[n+1](
            R = (1.0/A)*cat(1, {r[1]*l[1]/2}, {r[i]*l[i]/2 + r[i+1]*l[i+1]/2 for i in 1:n-1}, {r[n]*l[n]/2})
        );
        Modelica.Thermal.HeatTransfer.Components.Convection convExt;
        Modelica.Thermal.HeatTransfer.Components.Convection convInt;
    equation
        connect(exterior, convExt.fluid);
        connect(interior, convInt.fluid);
        connect(solar, R[1].port_a);

        connect(convExt.solid, R[1].port_a);
        connect(convInt.solid, R[n+1].port_b);

        convExt.Gc = cExt*A;
        convInt.Gc = cInt*A;

        for i in 1:n loop
            connect(C[i].port, R[i].port_b);
            connect(C[i].port, R[i+1].port_a);
        end for;

    end Wall;

end SimpleBuilding;