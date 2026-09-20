import 'package:flutter/widgets.dart'
    show CrossAxisAlignment, MainAxisAlignment;

// Um `Alignment` vai de -1 a 1. Dentro dessa faixa, a região central
// (-1/3 a 1/3) vira "center"; as pontas viram "start" e "end".
const double _threshold = 1 / 3;

/// Converte a coordenada de um `Alignment` no eixo principal.
MainAxisAlignment mainAxisFromAlignment(double value) {
  if (value < -_threshold) return MainAxisAlignment.start;
  if (value > _threshold) return MainAxisAlignment.end;
  return MainAxisAlignment.center;
}

/// Converte a coordenada de um `Alignment` no eixo cruzado.
CrossAxisAlignment crossAxisFromAlignment(double value) {
  if (value < -_threshold) return CrossAxisAlignment.start;
  if (value > _threshold) return CrossAxisAlignment.end;
  return CrossAxisAlignment.center;
}
