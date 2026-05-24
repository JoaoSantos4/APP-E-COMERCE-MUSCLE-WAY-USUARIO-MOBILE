class PrecoUtils {
  static String formatar(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  static double valorPix(double valor) {
    return valor * 0.93;
  }
}
