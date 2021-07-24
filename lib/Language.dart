class Language {
  final int id;
  final String name;
  final String languageCode;
  final String countryCode;
  Language(this.id, this.name, this.languageCode, this.countryCode);

  static List<Language> languageList() {
    return <Language>[
      Language(1, "English", "en", "ET"),
      Language(2, "አማርኛ", "am", "ET"),
      Language(3, "Oromiffaa", "om", "ET")
    ];
  }
}