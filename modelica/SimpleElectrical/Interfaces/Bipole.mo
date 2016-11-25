within SimpleElectrical.Interfaces;
partial model Bipole
  "Electrical model with two Terminal connectors"
  SimpleElectrical.Connectors.Terminal a, b;
  Modelica.SIunits.Voltage V
    "Voltage drop between a and b";
  Modelica.SIunits.Current i
    "Current entering terminal a";
equation
  // Constraint between connector variables
  // i.e. the same amount of current that enters from
  // connector a leaves from connector b
  a.i + b.i = 0;

  // Definition of utility variables
  V = a.v - b.v;
  i = a.i;
end Bipole;
