within SimpleElectrical.Components;

model Resistor
  extends SimpleElectrical.Interfaces.Bipole;
  parameter Modelica.SIunits.Resistance R = 1e3
    "Resistance";
equation
  // Ohm's law
  V = R*i;
end Resistor;
