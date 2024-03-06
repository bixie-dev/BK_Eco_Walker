class LanguageData {
  final String flag;
  final String name;
  final String languageCode;
  final String countryCode;

  LanguageData(this.flag, this.name, this.languageCode, this.countryCode);

  static List<LanguageData> languageList() {
    /*return <LanguageData>[
      LanguageData("🇸🇦", "عربى", 'ar'),
      LanguageData("🇨🇳", "中国人", 'zh'),
      LanguageData("🇺🇸", "English", 'en'),
      LanguageData("🇫🇷", "français", 'fr'),
      LanguageData("🇩🇪", "Deutsche", 'de'),
      LanguageData("🇮🇳", "हिंदी", 'hi'),
      LanguageData("🇯🇵", "日本", 'ja'),
      LanguageData("🇵🇹", "português", 'pt'),
      LanguageData("🇷🇺", "русский", 'ru'),
      LanguageData("🇪🇸", "Español", 'es'),
      LanguageData("🇵🇰", "اردو", "ur"),
      LanguageData("🇻🇳", "Tiếng Việt", 'vi'),
      LanguageData("🇮🇩", "bahasa indo", 'id'),
      LanguageData("🇮🇳", "বাংলা", 'bn'),
      LanguageData("🇮🇳", "தமிழ்", 'ta'),
      LanguageData("🇮🇳", "తెలుగు", 'te'),
      LanguageData("🇹🇷", "Türk", 'tr'),
      LanguageData("🇰🇵", "한국인", 'ko'),
      LanguageData("🇮🇳", "ਪੰਜਾਬੀ", 'pa'),
      LanguageData("🇮🇹", "italiana", 'it'),
    ];*/

    return <LanguageData>[
      LanguageData("🇦🇱", "Albanian (shqiptare)", 'sq', 'AL'),
      LanguageData("🇸🇦", "(عربى) Arabic", 'ar', 'SA'),
      LanguageData("🇦🇿", "Azerbaijani (Azərbaycan)", 'az', 'AF'),
      LanguageData("🇮🇳", "Bengali (বাংলা)", 'bn', 'IN'),
      LanguageData("🇲🇲", "Burmese (မြန်မာ)", 'my', 'MM'),
      //LanguageData("🇨🇳", "Chinese Simplified (中国人)", 'zh', 'CN'),
      LanguageData("🇹🇼", "Traditional Chinese 繁體字", 'zh', 'CN'),
      LanguageData("🇭🇷", "Croatian (Hrvatski)", 'hr', 'HR'),
      LanguageData("🇨🇿", "Czech (čeština)", 'cs', 'CZ'),
      LanguageData("🇳🇱", "Dutch (Nederlands)", 'nl', 'NL'),
      LanguageData("🇺🇸", "English (English)", 'en', 'US'),
      LanguageData("🇫🇷", "French (français)", 'fr', 'FR'),
      LanguageData("🇩🇪", "German (Deutsche)", 'de', 'DE'),
      LanguageData("🇬🇷", "Greek (Ελληνικά)", 'el', 'GR'),
      LanguageData("🇮🇳", "Gujarati (ગુજરાતી)", 'gu', 'IN'),
      LanguageData("🇮🇳", "Hindi (हिंदी)", 'hi', 'IN'),
      LanguageData("🇭🇺", "Hungarian (Magyar)", 'hu', 'HU'),
      LanguageData("🇮🇩", "Indonesian (bahasa indo)", 'id', 'ID'),
      LanguageData("🇮🇹", "Italian (italiana)", 'it', 'IT'),
      LanguageData("🇯🇵", "Japanese (日本)", 'ja', 'JP'),
      LanguageData("🇮🇳", "Kannada (ಕನ್ನಡ)", 'kn', 'IN'),
      LanguageData("🇰🇵", "Korean (한국인)", 'ko', 'KR'),
      LanguageData("🇮🇳", "Malayalam (മലയാളം)", 'ml', 'IN'),
      LanguageData("🇮🇳", "Marathi (मराठी)", 'mr', 'IN'),
      LanguageData("🇳🇴", "Norwegian (norsk)", 'nb', 'NO'),
      LanguageData("🇮🇳", "Odia (ଓଡିଆ)", 'or', 'IN'),
      LanguageData("🇮🇷", "Persian (فارسی)", 'fa', 'IR'),
      LanguageData("🇵🇱", "Polish (Polski)", 'pl', 'PL'),
      LanguageData("🇵🇹", "Portuguese (português)", 'pt', 'PT'),
      LanguageData("🇮🇳", "Punjabi (ਪੰਜਾਬੀ)", 'pa', 'IN'),
      LanguageData("🇷🇴", "Romanian (Română)", 'ro', 'RO'),
      LanguageData("🇷🇺", "Russian (русский)", 'ru', 'RU'),
      LanguageData("🇪🇸", "Spanish (Español)", 'es', 'ES'),
      LanguageData("🇸🇪", "Swedish (svenska)", 'sv', 'SE'),
      LanguageData("🇮🇳", "Tamil (தமிழ்)", 'ta', 'IN'),
      LanguageData("🇮🇳", "Telugu (తెలుగు)", 'te', 'IN'),
      LanguageData("🇹🇭", "Thai (แบบไทย)", 'th', 'TH'),
      LanguageData("🇹🇷", "Turkish (Türk)", 'tr', 'TR'),
      LanguageData("🇺🇦", "Ukrainian (українська)", 'uk', 'UA'),
      LanguageData("🇵🇰", "(اردو) Urdu", 'ur', 'PK'),
      LanguageData("🇻🇳", "Vietnamese (Tiếng Việt)", 'vi', 'VN'),
    ];
  }
}
