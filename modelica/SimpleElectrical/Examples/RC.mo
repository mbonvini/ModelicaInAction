within SimpleElectrical.Examples;

model RC
  "Model of a Resistive-Capacitive (RC) circuit."
  import SimpleElectrical.Components.*;
  Ground G "Ground reference";
  Source S(E=10) "Constant voltage source";
  Resistor R(R=0.1) "Resistor";
  Capacitor C(C=0.1) "Capacitor";
equation
  connect(S.a, R.a);
  connect(R.b, C.a);
  connect(C.b, S.b);
  connect(S.b, G.a);
end RC;
