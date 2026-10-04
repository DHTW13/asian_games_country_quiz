class Country {
  final String code;
  final String nameEn;
  final String nameZh;
  final String iso3;

  const Country({
    required this.code,
    required this.nameEn,
    required this.nameZh,
    required this.iso3,
  });

  String get bilingualName => '$nameZh · $nameEn';
}
