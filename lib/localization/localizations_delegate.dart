import 'package:flutter/material.dart';

import 'language/language_ar.dart';
import 'language/language_az.dart';
import 'language/language_bn.dart';
import 'language/language_cs.dart';
import 'language/language_de.dart';
import 'language/language_el.dart';
import 'language/language_en.dart';
import 'language/language_es.dart';
import 'language/language_fa.dart';
import 'language/language_fr.dart';
import 'language/language_gu.dart';
import 'language/language_hi.dart';
import 'language/language_hr.dart';
import 'language/language_hu.dart';
import 'language/language_id.dart';
import 'language/language_it.dart';
import 'language/language_ja.dart';
import 'language/language_kn.dart';
import 'language/language_ko.dart';
import 'language/language_ml.dart';
import 'language/language_mr.dart';
import 'language/language_my.dart';
import 'language/language_nb.dart';
import 'language/language_nl.dart';
import 'language/language_or.dart';
import 'language/language_pa.dart';
import 'language/language_pl.dart';
import 'language/language_pt.dart';
import 'language/language_ro.dart';
import 'language/language_ru.dart';
import 'language/language_sq.dart';
import 'language/language_sv.dart';
import 'language/language_ta.dart';
import 'language/language_te.dart';
import 'language/language_th.dart';
import 'language/language_tr.dart';
import 'language/language_uk.dart';
import 'language/language_ur.dart';
import 'language/language_vi.dart';
import 'language/language_zh.dart';
import 'language/languages.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<Languages> {
  const AppLocalizationsDelegate();


  @override
  bool isSupported(Locale locale) => [
        'sq',
        'ar',
        'az',
        'bn',
        'my',
        'zh',
        'hr',
        'cs',
        'nl',
        'en',
        'fr',
        'de',
        'el',
        'gu',
        'hi',
        'hu',
        'id',
        'it',
        'ja',
        'kn',
        'ko',
        'ml',
        'mr',
        'nb',
        'or',
        'fa',
        'pl',
        'pt',
        'pa',
        'ro',
        'ru',
        'es',
        'sv',
        'ta',
        'te',
        'th',
        'tr',
        'uk',
        'ur',
        'vi',
      ].contains(locale.languageCode);







  @override
  Future<Languages> load(Locale locale) => _load(locale);




  static Future<Languages> _load(Locale locale) async {
    switch (locale.languageCode) {
      case 'ar':
        return LanguageAr();
      case 'bn':
        return LanguageBn();
      case 'zh':
        return LanguageZh();
      case 'en':
        return LanguageEn();
      case 'fr':
        return LanguageFr();
      case 'de':
        return LanguageDe();
      case 'hi':
        return LanguageHi();
      case 'id':
        return LanguageId();
      case 'it':
        return LanguageIt();
      case 'ja':
        return LanguageJa();
      case 'ko':
        return LanguageKo();
      case 'pt':
        return LanguagePt();
      case 'pa':
        return LanguagePa();
      case 'ru':
        return LanguageRu();
      case 'es':
        return LanguageEs();
      case 'ta':
        return LanguageTa();
      case 'te':
        return LanguageTe();
      case 'tr':
        return LanguageTr();
      case 'ur':
        return LanguageUr();
      case 'vi':
        return LanguageVi();
      case 'sq':
        return LanguageSq();
      case 'az':
        return LanguageAz();
      case 'my':
        return LanguageMy();
      case 'hr':
        return LanguageHr();
      case 'cs':
        return LanguageCs();
      case 'nl':
        return LanguageNl();
      case 'el':
        return LanguageEl();
      case 'gu':
        return LanguageGu();
      case 'hu':
        return LanguageHu();
      case 'kn':
        return LanguageKn();
      case 'ml':
        return LanguageMl();
      case 'mr':
        return LanguageMr();
      case 'nb':
        return LanguageNb();
      case 'or':
        return LanguageOr();
      case 'fa':
        return LanguageFa();
      case 'pl':
        return LanguagePl();
      case 'ro':
        return LanguageRo();
      case 'sv':
        return LanguageSv();
      case 'th':
        return LanguageTh();
      case 'uk':
        return LanguageUk();
      default:
        return LanguageZh();
    }
  }



  @override
  bool shouldReload(LocalizationsDelegate<Languages> old) => false;
}
