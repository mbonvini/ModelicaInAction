within SimpleElectrical.Connectors;

connector Terminal "Connector/Interface for electrical systems"
  Modelica.SIunits.Voltage v
    "Voltage at the terminal";
  flow Modelica.SIunits.Current i
    "Current flowing through the terminal (positive entering the model)";
end Terminal;
