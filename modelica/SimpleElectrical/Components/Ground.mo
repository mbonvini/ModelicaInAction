within SimpleElectrical.Components;

model Ground
  "Ground reference model that sets V=0."
  SimpleElectrical.Connectors.Terminal a;
equation
  a.v = 0.0;
end Ground;
