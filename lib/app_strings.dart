import 'package:shared_preferences/shared_preferences.dart';

class AppStrings {
  static String currentLang = 'ru'; // 'ru' или 'en'

  // Загружаем сохранённый язык при старте игры
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    currentLang = prefs.getString('game_language') ?? 'ru';
  }

  // Переключаем и сохраняем язык на диск
  static Future<void> setLanguage(String langCode) async {
    currentLang = langCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('game_language', langCode);
  }

  // Главный метод получения текста по ключу
  static String get(String key) {
    return _localizedValues[key]?[currentLang] ?? _localizedValues[key]?['ru'] ?? key;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    // =========================================================================
    // ГЛАВНОЕ МЕНЮ И НАСТРОЙКИ
    // =========================================================================
    'menu_levels': {'ru': 'УРОВНИ', 'en': 'LEVELS'},
    'menu_achievements': {'ru': 'ДОСТИЖЕНИЯ', 'en': 'ACHIEVEMENTS'},
    'menu_extra': {'ru': 'ДОПОЛНИТЕЛЬНО', 'en': 'EXTRAS'},
    'menu_settings': {'ru': 'НАСТРОЙКИ', 'en': 'SETTINGS'},
    
    'settings_volume': {'ru': 'ГРОМКОСТЬ ЗВУКА', 'en': 'SOUND VOLUME'},
    'settings_language': {'ru': 'ЯЗЫК ИГРЫ', 'en': 'LANGUAGE'},
    'settings_controls': {'ru': 'УПРАВЛЕНИЕ (6 УРОВЕНЬ)', 'en': 'CONTROLS (LEVEL 6)'},
    'btn_back': {'ru': 'НАЗАД', 'en': 'BACK'},

    // =========================================================================
    // КОМИКС 1 УРОВНЯ (SHERIFF COMIC SCREEN)
    // =========================================================================
    'c1_title_p1': {
      'ru': 'ИСТОРИЯ ШЕРИФА БАННИХОПА',
      'en': 'THE STORY OF SHERIFF BUNNYHOP',
    },
    'c1_title_p2': {
      'ru': 'ИСТОРИЯ ШЕРИФА: НА ЛУГУ',
      'en': 'SHERIFF\'S STORY: IN THE MEADOW',
    },
    'btn_forward': {
      'ru': 'ВПЕРЁД',
      'en': 'NEXT',
    },
    'btn_lets_go': {
      'ru': 'ПОГНАЛИ!',
      'en': 'LET\'S GO!',
    },
    'c1_p1_f1': {
      'ru': 'Обычное мирное дежурство в округе... Кофе отличный.',
      'en': 'Just another peaceful patrol in the county... Great coffee.',
    },
    'c1_p1_f2': {
      'ru': 'Шериф, беда! На лугах птиц завелись зелёные свиньи под предводительством Дона Молюска! Они грабят наши склады с виагрой!',
      'en': 'Sheriff, trouble! Green pigs led by Don Mollusk invaded the bird meadows! They are looting our Viagra warehouses!',
    },
    'c1_p1_f3': {
      'ru': 'Пора расхлебать это дерьмо и проучить этих свиней!',
      'en': 'Time to clean up this mess and teach those pigs a lesson!',
    },
    'c1_p2_f1': {
      'ru': 'Так... Следы ведут сюда. Ошмётки упаковок повсюду. Свиньи где-то рядом...',
      'en': 'So... The tracks lead here. Torn wrappers everywhere. The pigs must be close...',
    },
    'c1_p2_f2_vanya1': {
      'ru': 'Я нашёл вас!',
      'en': 'Found you!',
    },
    'c1_p2_f2_pigs': {
      'ru': 'О, Шериф припёрся! Ну что, таблеточки-то тю-тю! Наш босс станет бессмертным, и ты нас ни за что не достанешь - мы построили неприступную крепость!',
      'en': 'Oh, the Sheriff showed up! Well, your pills are gone! Our boss will become immortal, and you\'ll never reach us — we built an impregnable fortress!',
    },
    'c1_p2_f2_vanya2': {
      'ru': 'Вы совершили главную ошибку в жизни, зайдя на луг птиц и начав воровать мои таблетки!',
      'en': 'You made the biggest mistake of your life stepping onto the bird meadow and stealing my pills!',
    },
    'c1_p2_f3': {
      'ru': 'Посмотрим, какую крепость вы построили!',
      'en': 'Let\'s see what kind of fortress you built!',
    },
        // =========================================================================
    // ЭКРАН УРОВНЕЙ И ДОПОЛНИТЕЛЬНО
    // =========================================================================
    'levels_title': {'ru': 'УРОВНИ', 'en': 'LEVELS'},
    'btn_play_offline': {'ru': 'ИГРАТЬ В ОФФЛАЙНЕ', 'en': 'PLAY OFFLINE'},

    // =========================================================================
    // ЭКРАН ДОСТИЖЕНИЙ (ACHIEVEMENTS)
    // =========================================================================
    'ach_title': {'ru': 'МЕНЮ ДОСТИЖЕНИЙ', 'en': 'ACHIEVEMENTS'},
    'ach_1_title': {'ru': 'Первая Кровь', 'en': 'First Blood'},
    'ach_1_desc': {
      'ru': 'Убей самую первую\nсвинью на 1 уровне',
      'en': 'Defeat the very first\npig on Level 1',
    },
    'ach_2_title': {'ru': 'Снайпер', 'en': 'Sniper'},
    'ach_2_desc': {
      'ru': 'Пройди любой уровень,\nпотратив всего 1 птицу',
      'en': 'Beat any level\nusing only 1 bird',
    },
    'ach_3_title': {'ru': 'Триумф', 'en': 'Triumph'},
    'ach_3_desc': {
      'ru': 'Пройди все 5 уровней\nна максимальные 3 звезды',
      'en': 'Complete all 5 levels\nwith 3 stars',
    },
    'ach_4_title': {'ru': 'Кровожадная месть', 'en': 'Bloodthirsty Revenge'},
    'ach_4_desc': {
      'ru': 'Ты раскрыл тайну\nскрытого сундука!',
      'en': 'You uncovered the secret\nof the hidden chest!',
    },
    'ach_5_title': {'ru': 'Новый опыт', 'en': 'New Experience'},
    'ach_5_desc': {
      'ru': 'Во вкладке дополнительно\nоткройте игру ivandrop',
      'en': 'Open the ivandrop game\nin the Extras tab',
    },
  'victory_title': {
      'ru': 'Ты победил, красавчик!',
      'en': 'You won, handsome!',
    },
    'final_score': {
      'ru': 'ИТОГОВЫЙ СЧЁТ',
      'en': 'FINAL SCORE',
    },
    'ach_unlocked_title': {
      'ru': 'ДОСТИЖЕНИЕ РАЗБЛОКИРОВАНО!',
      'en': 'ACHIEVEMENT UNLOCKED!',
    },
    'ach_unlocked_desc': {
      'ru': 'Загляни в меню достижений на главном экране!',
      'en': 'Check the achievements menu on the main screen!',
    },
    'pause_title': {
      'ru': 'ПАУЗА',
      'en': 'PAUSED',
    },
    'btn_resume': {
      'ru': 'ПРОДОЛЖИТЬ',
      'en': 'RESUME',
    },
    'btn_restart': {
      'ru': 'ЗАНОВО',
      'en': 'RESTART',
    },
    'btn_to_menu': {
      'ru': 'В МЕНЮ',
      'en': 'MAIN MENU',
    },
    'game_over_text': {
      'ru': 'ПТИЦЫ КОНЧИЛИСЬ!\nМАКСИМ ПОБЕДИЛ!',
      'en': 'OUT OF BIRDS!\nMAKSIM WINS!',
    },
    'poster_wanted': {
      'ru': 'РАЗЫСКИВАЕТСЯ',
      'en': 'WANTED',
    },
    'poster_name': {
      'ru': 'ДОН МОЛЛЮСК',
      'en': 'DON MOLLUSK',
    },
    'poster_reward': {
      'ru': 'НАГРАДА',
      'en': 'REWARD',
    },
  };
}
