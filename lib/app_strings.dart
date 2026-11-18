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
        // =========================================================================
    // ПРЕДЫСТОРИЯ 4 УРОВНЯ (COMIC INTRO SCREEN)
    // =========================================================================
    'c4_title': {
      'ru': 'ПРЕДЫСТОРИЯ УРОВНЯ 4',
      'en': 'LEVEL 4 BACKSTORY',
    },
    'c4_f1_pigs': {
      'ru': 'Баннихоп уже близко к замку нашего босса. Надо что-то придумать! Сделаем крепость из бронированного стекла. Тогда он точно не сможет её сломать!',
      'en': 'Bunnyhop is getting close to our boss\'s castle. We need a plan! Let\'s build a fortress out of armored glass. He\'ll never break through it!',
    },
    'c4_f2_vanya': {
      'ru': 'Ах вот вы что задумали!',
      'en': 'Aha, so that\'s your plan!',
    },
    'c4_f3_vanya': {
      'ru': 'А у меня вот это есть',
      'en': 'Well, I\'ve got this!',
    },
    'c4_pill_label': {
      'ru': 'ВИАГРА',
      'en': 'VIAGRA',
    },

    // =========================================================================
    // КОМИКС 6 УРОВНЯ: ЛОГОВО ДОНА МОЛЛЮСКА (LEVEL 6 COMIC SCREEN)
    // =========================================================================
    'c6_title': {
      'ru': 'ГЛАВА VI: ЛОГОВО ДОНА МОЛЛЮСКА',
      'en': 'CHAPTER VI: DON MOLLUSK\'S LAIR',
    },
    'c6_f1_vanya': {
      'ru': 'Дон Молюск! Все твои свиньи убиты! Где же ты спрятался, выйди ко мне.',
      'en': 'Don Mollusk! All your pigs are defeated! Where are you hiding, come out and face me.',
    },
    'c6_f2_steps': {
      'ru': 'ШАГИ ИЗ ТЕМНОТЫ...',
      'en': 'FOOTSTEPS FROM THE DARKNESS...',
    },
    'c6_choice_1': {
      'ru': 'Вот ты где! Сдавайся чудовище! Твоё время пришло!',
      'en': 'There you are! Surrender, monster! Your time has come!',
    },
    'c6_choice_2': {
      'ru': 'Давай по-хорошему. отдай Древний Тотем Гнева, оставь склады с таблетками в покое и уйди слуга птиц навсегда.',
      'en': 'Let\'s do this the easy way. Hand over the Ancient Totem of Wrath, leave the pill warehouses alone, and leave the birds\' lands forever.',
    },
    'c6_don_reply_1': {
      'ru': 'Хрю-ха-ха! Сдаться тебе? Жалкая птица! Не на того напал!',
      'en': 'Oink-ha-ha! Surrender to you? Pathetic bird! You picked the wrong foe!',
    },
    'c6_don_reply_2': {
      'ru': 'По-хорошему? Ты слишком вежлив для птицы, потерявшей способность летать. Этим предметом мы лишили ваш род неба! И ты думаешь, я отдам его просто так?',
      'en': 'The easy way? You\'re too polite for a flightless bird. With this artifact we robbed your kind of the skies! And you think I\'ll just hand it over?',
    },
    'c6_select_prompt': {
      'ru': 'ВЫБЕРИТЕ ОТВЕТ ШЕРИФА ДЛЯ ПРОДОЛЖЕНИЯ СЮЖЕТА',
      'en': 'CHOOSE THE SHERIFF\'S REPLY TO CONTINUE',
    },
    'btn_next': {
      'ru': 'ДАЛЬШЕ',
      'en': 'NEXT',
    },
        // =========================================================================
    // КОМИКС 5 УРОВНЯ: ГЕНЕРАЛ СВИНОМАТКИН (SVINOMATKIN COMIC SCREEN)
    // =========================================================================
    'c5_title_p1': {
      'ru': 'ГЛАВА V: ПОДСТУПЫ К ЦИТАДЕЛИ',
      'en': 'CHAPTER V: APPROACH TO THE CITADEL',
    },
    'c5_title_p2': {
      'ru': 'ГЛАВА V: ПОСЛЕДНИЙ РУБЕЖ',
      'en': 'CHAPTER V: THE LAST STAND',
    },
    'btn_to_battle': {
      'ru': 'В БОЙ!',
      'en': 'TO BATTLE!',
    },
    'c5_p1_f1': {
      'ru': 'Вот я и дошёл до замка Дона Молюска!',
      'en': 'I\'ve finally reached Don Mollusk\'s castle!',
    },
    'c5_p1_f2_vanya': {
      'ru': 'Все твои братья разбиты! Ты остался один! Уйди с дороги, я иду к твоему боссу!',
      'en': 'All your brothers are defeated! You\'re the last one left! Step aside, I\'m coming for your boss!',
    },
    'c5_p1_f2_gen': {
      'ru': 'Хрю-ха-ха! Шериф-младший, ты слишком далеко зашёл, но здесь твой путь закончится! Дон Молюск доверил мне охранять подступы к его замку, и я не сделаю ни шагу назад!',
      'en': 'Oink-ha-ha! Sheriff Junior, you\'ve come too far, and your journey ends right here! Don Mollusk entrusted me to guard his castle gates, and I won\'t take a single step back!',
    },
    'c5_p1_f3_vanya': {
      'ru': 'Стоп, шериф-младший? Погоди-ка, кого-то ты мне напоминаешь... Ах, это ты Генерал Свиноматкин! Это ты, сорок лет назад обманул моего деда - великого шерифа-старшего! Ты ослепил его дымовой завесой и выкрал Древний Тотем Гнева, как же я мог забыть про это, ну ничего я сегодня заберу тотем у свиней и освобожу луг птиц!',
      'en': 'Wait, Sheriff Junior? Hold on, you look familiar... Ah, it\'s you, General Svinomatkin! Forty years ago you tricked my grandfather, the great Sheriff Senior! You blinded him with a smokescreen and stole the Ancient Totem of Wrath! Today I\'ll take it back and free the bird meadow!',
    },
    'c5_p1_f3_gen': {
      'ru': 'О да, я помню твоего деда! Он был силён, но слишком доверчив! Без Тотема Гнева ваш род навсегда потерял способность парить в небесах. Вы упали на землю и стали бессильными! А наш босс забрал тотем себе!',
      'en': 'Oh yes, I remember your grandfather! He was strong, yet far too trusting! Without the Totem of Wrath, your kind lost the skies forever. You fell to the earth, powerless! And our boss claimed the totem for himself!',
    },
    'c5_p2_f1_vanya': {
      'ru': 'Сегодня тотем вернётся обратно к птицам, и все свиньи в страхе сбегут с луга птиц!',
      'en': 'Today the totem returns to the birds, and all pigs will flee the meadow in terror!',
    },
    'c5_p2_f1_gen': {
      'ru': 'Вот это у тебя фантазии, постоянно повторяешь про луг и тотем! Что осталась детская травма? Хрю-ха-ха!',
      'en': 'What a wild imagination, always babbling about the meadow and the totem! Still got childhood trauma? Oink-ha-ha!',
    },
    'c5_p2_f2_vanya': {
      'ru': 'Свиноматкин, ты уже прожил своё, я сейчас разнесу твою крепость в щепки, и про травмы ты будешь говорить служа птицам!',
      'en': 'Svinomatkin, your time is up! I\'ll smash your fortress to splinters, and you\'ll be whining about trauma while serving the birds!',
    },
    'c5_p2_f2_gen': {
      'ru': 'Я построил крепость из двойного камня, ты ни за что её не сломаешь!',
      'en': 'I built this fortress out of double stone—you\'ll never break through it!',
    },
    'c5_p2_f3': {
      'ru': 'Настало время последнего боя!',
      'en': 'It\'s time for the final battle!',
    },
        // =========================================================================
    // ПЛОХАЯ ЛИНИЯ 6 УРОВНЯ И КОНЦОВКА «ДЕЛО №06» (LEVEL 6 BAD ROUTE)
    // =========================================================================
    'c6_bad_f1_vanya': {
      'ru': 'Все свиньи разбиты, ты остался один! Тебе не скрыться за стенами замка, чудовище!',
      'en': 'All your pigs are crushed, you\'re on your own! You can\'t hide behind these castle walls, monster!',
    },
    'c6_bad_f1_don': {
      'ru': 'Скрыться? Хрю-ха-ха! Глупая птица, я сам привёл тебя сюда. Я наблюдал за тобой каждую секунду! Я видел, как ты сидел в кабинете, как ты стрелял из рогатки, как ты общался со Свиноматкиным! Эх, славный был воин... Теперь ты понял, что я ждал тебя здесь и вот ты пришёл!',
      'en': 'Hide? Oink-ha-ha! Foolish bird, I led you here myself. I watched your every move! I saw you in your office, firing that slingshot, talking to Svinomatkin! Ah, what a fine warrior he was... Now you see I was waiting for you all along!',
    },
    'c6_bad_f2_vanya': {
      'ru': 'Вот это у тебя план! Ничего сейчас он будет разрушен, как и твой замок и тотем гнева вместе с лугом придёт обратно птицам!',
      'en': 'What a grand plan! Too bad it\'s about to crumble along with your castle, and the Totem of Wrath and the meadow will return to the birds!',
    },
    'c6_bad_f2_don': {
      'ru': 'Разрушишь замок? Маленькая птица разгневалась. Как и твой дед сорок лет назад!',
      'en': 'Destroy my castle? The little bird is angry. Just like your grandfather forty years ago!',
    },
    'c6_bad_f3_don': {
      'ru': 'Хрю-ха-ха! Я так и думал! Жалкая птица!',
      'en': 'Oink-ha-ha! Just as I thought! Pathetic bird!',
    },
    'btn_end': {
      'ru': 'КОНЕЦ',
      'en': 'THE END',
    },
    'bad_end_game_over': {
      'ru': 'КОНЕЦ ИГРЫ',
      'en': 'GAME OVER',
    },
    'bad_end_case_06': {
      'ru': 'Дело №06: Шериф объявлен пропавшим без вести на лугу свиней. Расследование прекращено.',
      'en': 'Case #06: The Sheriff has been declared missing in the pigs\' meadow. Investigation closed.',
    },
    'btn_levels_menu': {
      'ru': 'В МЕНЮ УРОВНЕЙ',
      'en': 'LEVEL SELECT',
    },
    'bad_end_case_07': {
      'ru': 'Дело №07: Шериф объявлен пропавшим без вести на лугу свиней. Расследование прекращено.',
      'en': 'Case #07: The Sheriff has been declared missing in the pigs\' meadow. Investigation closed.',
    },
  };
}
