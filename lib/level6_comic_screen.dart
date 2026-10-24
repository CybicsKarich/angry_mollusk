import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'audio_manager.dart';
import 'main.dart';
import 'level6_bad_route_screen.dart';
import 'level6_case07_screen.dart';

class Level6GoodRouteScreen extends StatefulWidget {
  const Level6GoodRouteScreen({super.key});

  @override
  State<Level6GoodRouteScreen> createState() => _Level6GoodRouteScreenState();
}

class _Level6GoodRouteScreenState extends State<Level6GoodRouteScreen> with TickerProviderStateMixin {
  int _currentFrame = 1; // Текущий видимый кадр (1, 2 или 3)
  bool _isGameplayActive = false; // Переключатель: комикс -> живая арена боссфайта
  late AnimationController _debrisController;
  late Animation<double> _fallAnimation;
  
  // =========================================================================
  // 🎮 ПЕРЕМЕННЫЕ СОСТОЯНИЯ ТЕСТОВОГО ГЕЙМПЛЕЯ 6 УРОВНЯ
  // =========================================================================
  late final Ticker _gameLoopTicker;
  
 final double _groundYPercent = 0.73;

  // Физика Шерифа
  double _vanyaX = 0.15; 
  // ИСПРАВЛЕНО: Птица теперь сидит чётко на полу, а не парит в воздухе! (радиус 0.05)
  double _vanyaY = 0.73 - 0.05; 
  double _vanyaVx = 0.0;
  double _vanyaVy = 0.0;
  bool _vanyaIsJumping = false;
  int _vanyaHearts = 1; 
  Duration _lastElapsed = Duration.zero;
  bool _isPhase2Active = false;
  bool _isLocalBattleMusicStarted = false;
  double _localMusicCheckTimer = 0.0;
  double _bloodPoolX = -1.0;
  double _bloodPoolTimer = 0.0;
  bool _isBloodPoolActive = false;
  double _bombPigX = -1.0;         // X правой свиньи
  double _leftPigX = -1.0;         // X левой свиньи (НОВАЯ)
  double _bombPigTimer = 0.0;      // Таймер отсчета 6 секунд для спавна
  bool _isBombPigActive = false;   // Активна ли правая свинья
  bool _isLeftPigActive = false;   // Активна ли левая свинья (НОВАЯ)
  double _explosionTimer = 0.0;    // Таймер для отрисовки анимации взрыва
  double _explosionX = -1.0;       // Координата X произошедшего взрыв

  
  bool _btnLeftPressed = false;
  bool _btnRightPressed = false;
  bool _btnJumpPressed = false;

  // ИСПРАВЛЕНО: Каменная баррикада смещена намного левее (на 0.45)
  bool _isBarricadeAlive = true; 
  final double _barricadeX = 0.45;

  // ИСПРАВЛЕНО: Дон Моллюск смещен на самый правый край зала (на 0.84)
  final double _bossX = 0.84;
  double _bossCurrentHp = 8.0; 
  final double _bossMaxHp = 8.0;

  // ТОЧЕЧНО ДОБАВИТЬ К ОСТАЛЬНЫМ ПЕРЕМЕННЫМ КЛАССА СОСТОЯНИЯ:
  // Переменные режима «Виагра-Тайм»
  bool _isAngryMode = false; // Флаг абсолютного бессмертия и ярости Шерифа
  double _angryTimer = 0.0; // Для циклической поп-арт анимации неба
  
  // Координаты и таймер спавна капсулы виагры
  double _pillX = -1.0; 
  double _pillY = -1.0;
  bool _isPillSpawned = false;
  double _pillSpawnTimer = 0.0; // Считает 5 секунд для тестового спавна
  
  // Анимация эффекта подбора таблетки
  double _plusOneUiTimer = 0.0; // Управляет вспышкой неонового крестика «+1»
  double _heartPulseTimer = 0.0; // Управляет пульсацией добавившегося сердечка

    
  BossState _bossState = BossState.idle;
  BossLimb _activeLimb = BossLimb.leftTentacle;
  double _bossStateTimer = 0.0;    // Универсальный таймер фаз босса
  int _bossStrikeCounter = 0;      // Счетчик нанесенных ударов подряд
  double _limbRotationAngle = 0.0; // Угол бешеного кручения рук при замахе
  double _staggerEffectTimer = 0.0; // Таймер для эффекта синусоиды (dizzy)

  // Вспомогательный генератор случайных точек для спавна
  final Random _gameRand = Random();

  @override
  void initState() {
    super.initState();
    AudioManager.startCastleDrops();
    _debrisController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), 
    );
    
    _fallAnimation = CurvedAnimation(
      parent: _debrisController,
      curve: Curves.bounceOut,
    );

        // Главный движковый тикер игрового процесса с расчетом честного Delta Time
    _gameLoopTicker = createTicker((elapsed) {
      if (_isGameplayActive && mounted) {
        // ИСПРАВЛЕНО: Чистая математика перевода микросекунд в секунды
        double dt = (elapsed.inMicroseconds - _lastElapsed.inMicroseconds) / 1000000.0;
        
        if (dt > 0.1) dt = 0.016; // Защита от гигантского скачка при лаге девайса
        _lastElapsed = elapsed;
        
        _updatePhysics(dt);
      }
    });
    _gameLoopTicker.start();
  }


  void _rescueCastleDropsOnInput() {
    // Если Шериф в обычном режиме (не орет под таблеткой) и босс жив
    if (!_isAngryMode && _bossCurrentHp > 0) {
      // И если системный плеер капель вдруг заглох — моментально воскрешаем его от тапа игрока
      if (!AudioManager.isCastleDropsPlaying) {
        print("Палец игрока спас атмосферу! Воскрешаем капли замка принудительно.");
        AudioManager.startCastleDrops();
      }
    }
  }

    // ПОЛНОСТЬЮ ЗАМЕНИТЬ МЕТОД _secureGameplayMusicStream В КЛАССЕ СОСТОЯНИЯ ЭКРАНА БОЯ:
  void _secureGameplayMusicStream(double dt) {
    // Жесткий принудительный перезапуск работает строго во время живого геймплея и пока босс жив
    if (_isGameplayActive && _bossCurrentHp > 0) {
      
      _localMusicCheckTimer += dt;
      if (_localMusicCheckTimer >= 1.0) { // Строго каждую 1 секунду геймплея!
        _localMusicCheckTimer = 0.0;
        
        // Если Ваня орет под таблеткой — не перебиваем его спецэффект
        if (_isAngryMode) return;

        // ПРИНУДИТЕЛЬНЫЙ ВЫЗОВ БЕЗ ПРОВЕРОК СТАТУСА:
        if (!_isPhase2Active) {
          // Каждую секунду жестко подтверждаем микшеру Android, что Фаза 1 обязана играть!
          AudioManager.startLevel6BattleMusic(); 
        } else {
          // Каждую секунду жестко подтверждаем микшеру Android, что Фаза 2 обязана играть!
          AudioManager.switchToBossPhase2Music(); 
        }
      }
    }
  }

   void _spawnBloodSplatter() {
    _bloodPoolX = _vanyaX;
    _bloodPoolTimer = 10.0; 
    _isBloodPoolActive = true;
  }

  
  void _updatePhysics(double dt) {
    _secureGameplayMusicStream(dt);
    setState(() {
      
      if (_vanyaHearts <= 0) {
      if (_gameLoopTicker.isActive) {
        _gameLoopTicker.stop(); 
        print("Движковый тикер успешно остановлен: Шериф повержен, экономим батарею.");
      }
      return;
    }

              
        


      const double realGroundY = 0.88;

      // Обновляем внутренние таймеры анимации ауры и эффектов подбора
      if (_isAngryMode) _angryTimer += dt;
      if (_plusOneUiTimer > 0) _plusOneUiTimer -= dt;
      if (_heartPulseTimer > 0) _heartPulseTimer -= dt;

       if (!_isPillSpawned && _bossCurrentHp > 0 && _vanyaHearts > 0) {
      _pillSpawnTimer += dt;
      if (_pillSpawnTimer >= 5.0) {
        _pillSpawnTimer = 0.0;
        if (_gameRand.nextInt(100) < 15) {
          _isPillSpawned = true;
          _pillX = 0.10 + _gameRand.nextDouble() * 0.50;
          _pillY = 0.16; // Фиксированная высота под потолком! Ване нужно прыгнуть в упор
          print("Синяя таблетка появилась под потолком.");
        }
      }
    }


   
    if (_explosionTimer > 0) _explosionTimer -= dt; 

    // Спавн камикадзе строго раз в 6 секунд с шансом 80%
    if (!_isBombPigActive && !_isLeftPigActive && _bossCurrentHp > 0 && _vanyaHearts > 0) {
      _bombPigTimer += dt;
      if (_bombPigTimer >= 6.0) {
        _bombPigTimer = 0.0;
        
        if (_gameRand.nextInt(100) < 80) {
          _isBombPigActive = true;
          _bombPigX = _bossX; // Правая всегда выезжает из-под Дона Моллюска (0.84)
          
          // НОВОЕ: Если включен кровавый режим (Фаза 2) — МГНОВЕННО спавним и левую свинью!
          if (_isPhase2Active) {
            _isLeftPigActive = true;
            _leftPigX = 0.02; // Левая выезжает с самого левого края экрана
            print("🩸 КРОВАТНЫЙ РЕЖИМ: Свиньи-камикадзе штурмуют Ваню С ДВУХ СТОРОН!");
          } else {
            print("🐖 Свинья-камикадзе выкатилась справа.");
          }
        }
      }
    }

    // 1. ДВИЖЕНИЕ И ХИТБОКС ПРАВОЙ СВИHЬИ (ЕДЕТ ВЛЕВО)
    if (_isBombPigActive) {
      _bombPigX -= 0.28 * dt; 

      if (!_vanyaIsJumping) {
        double pigDist = (_vanyaX - _bombPigX).abs();
        if (pigDist < 0.06) {
          _isBombPigActive = false;
          _explosionX = _bombPigX;
          _explosionTimer = 0.35;
          _bombPigX = -1.0;

          if (_vanyaHearts > 0) {
            _vanyaHearts--;
            _spawnBloodSplatter();
            if (_vanyaHearts > 0) {
              AudioManager.playMiss();
              _vanyaX = 0.15;
              _vanyaY = realGroundY - 0.05;
            } else {
              AudioManager.playGameOver();
            }
          }
        }
      }

      if (_bombPigX <= 0.02) {
        _isBombPigActive = false;
        _bombPigX = -1.0;
      }
    }

    // 2. НОВОЕ: ДВИЖЕНИЕ И ХИТБОКС ЛЕВОЙ СВИHЬИ (ЕДЕТ ВПРАВО)
    if (_isLeftPigActive) {
      _leftPigX += 0.28 * dt; // Скорость точно такая же, как у правой

      // Проверка взрыва с Ваней
      if (!_vanyaIsJumping) {
        double leftPigDist = (_vanyaX - _leftPigX).abs();
        if (leftPigDist < 0.06) {
          _isLeftPigActive = false;
          _explosionX = _leftPigX;
          _explosionTimer = 0.35;
          _leftPigX = -1.0;

          if (_vanyaHearts > 0) {
            _vanyaHearts--;
            _spawnBloodSplatter();
            if (_vanyaHearts > 0) {
              AudioManager.playMiss();
              _vanyaX = 0.15;
              _vanyaY = realGroundY - 0.05;
            } else {
              AudioManager.playGameOver();
            }
          }
        }
      }

      // ИСПРАВЛЕНО ТОЧЕЧНО: Левая свинья удаляется из памяти, как только врезается в Дона Моллюска (_bossX = 0.84)
      if (_leftPigX >= _bossX) {
        _isLeftPigActive = false;
        _leftPigX = -1.0;
        print("Левая свинья врезалась в панцирь босса и удалена.");
      }
    }

            // =========================================================================
      // 💎 КАЧЕСТВЕННАЯ ИСПРАВЛЕННАЯ ФИЗИКА СКОЛЬЖЕНИЯ И СБРОСА СКОРОСТИ
      // =========================================================================
      bool isOnBlood = false;
      
      // Честная проверка: Ваня наступил на лужу, только если она активна, и он СТРОГО на полу
      if (_isBloodPoolActive && _bloodPoolX > 0 && !_vanyaIsJumping) {
        // Вычисляем расстояние между центрами Вани и лужи
        double distToBlood = (_vanyaX - _bloodPoolX).abs();
        // Лужа широкая (0.09). Если Ваня зашел в эти границы — активируем скольжение
        if (distToBlood <= 0.09) {
          isOnBlood = true;
        }
      }

      if (isOnBlood) {
        // 🩸 РЕЖИМ СКОЛЬЖЕНИЯ (Гололед из крови):
        if (_btnLeftPressed) {
          _vanyaVx = _isAngryMode ? -0.52 : -0.36; // Плавный разгон влево
        } else if (_btnRightPressed) {
          _vanyaVx = _isAngryMode ? 0.52 : 0.36;  // Плавный разгон вправо
        } else {
          // Игрок ОТПУСТИЛ кнопки: Ваня эффектно скользит по инерции дальше!
          // Скорость плавно гасится на 8% за кадр, пока он не выедет с пятна
          _vanyaVx = _vanyaVx * 0.92; 
          if (_vanyaVx.abs() < 0.01) _vanyaVx = 0.0; // Гасим микро-тряску
        }
      } else {
        // 🧭 ОБЫЧНЫЙ СУХОЙ ПОЛ (Полный контроль):
        // Скорость жестко привязана к кнопкам. Нет кнопок — скорость МГНОВЕННО равна нулю!
        if (_btnLeftPressed) {
          _vanyaVx = _isAngryMode ? -0.42 : -0.26;
        } else if (_btnRightPressed) {
          _vanyaVx = _isAngryMode ? 0.42 : 0.26;
        } else {
          _vanyaVx = 0.0; // Жесткий стоп. Физика прыжка больше не ломается!
        }
      }

      // Применяем честно посчитанную горизонтальную скорость к Ване
      _vanyaX += _vanyaVx * dt;


      // 2. Вертикальная гравитация и прыжок
      if (_vanyaIsJumping) {
        _vanyaVy += 1.9 * dt; 
        _vanyaY += _vanyaVy * dt;

        if (_vanyaY < 0.08) {
          _vanyaY = 0.08;
          _vanyaVy = 0.0;
        }

        if (_vanyaY >= realGroundY - 0.05) {
          _vanyaY = realGroundY - 0.05;
          _vanyaVy = 0.0;
          _vanyaIsJumping = false;
        }
      } else {
        _vanyaY = realGroundY - 0.05;
      }

      if (_vanyaX < 0.02) _vanyaX = 0.02;
      if (_vanyaX > 0.94) _vanyaX = 0.94;

      // ПРОВЕРКА ПОДБОРА СИНЕЙ ТАБЛЕТКИ ШЕРИФОМ
      if (_isPillSpawned) {
        double pdx = _vanyaX - _pillX;
        double pdy = _vanyaY - _pillY;
        double pDist = sqrt(pdx * pdx + pdy * pdy);
        
        if (pDist < 0.06) {
          _isPillSpawned = false; // Капсула сразу исчезает
          _vanyaHearts += 1; // Дает +1 жизнь в верхний интерфейс
          _plusOneUiTimer = 0.6; // Запускаем вспышку синего крестика «+1»
          _heartPulseTimer = 0.8; // Запускаем плавную пульсацию сердечка
          
          _isAngryMode = true; // Активируем бессмертие и кислотное небо
          AudioManager.playRage(); // Громко включаем твой андеграундный трек ярости вторым потоком!
        }
      }

      // 3. Коллизия баррикады
      if (_isBarricadeAlive) {
        double barricadeW = 0.025; 
        double barricadeH = 0.16;  
        double bLeft = _barricadeX;
        double bRight = _barricadeX + 0.035;
        double bTop = realGroundY - barricadeH;

        if (_vanyaX >= bLeft - 0.02 && _vanyaX <= bRight && _vanyaY >= bTop - 0.04) {
          if (_vanyaVy > 0 && _vanyaY < bTop + 0.02) {
            _vanyaY = bTop - 0.05; 
            _vanyaVy = 0.0;
            _vanyaIsJumping = false;
          } 
          else if (_vanyaY > bTop - 0.02) {
            _vanyaX = _vanyaVx > 0 ? bLeft - 0.021 : bRight + 0.001;
          }
        }
      }

                 // =========================================================================
      // 🦀 МАШИНА СОСТОЯНИЙ ДОНА МОЛЛЮСКА С СИСТЕМОЙ УСТАЛОСТИ (ПО ТЗ)
      // =========================================================================
      if (_bossCurrentHp > 0) {
        _bossStateTimer += dt;

        // Модификаторы Второй Фазы берсерка на 4 HP и меньше
        double phase2SpeedMultiplier = _isPhase2Active ? 1.20 : 1.0; 
        double phase2CooldownReduction = _isPhase2Active ? 0.85 : 1.0; 

        // ИСПРАВЛЕНО: Явно используем значение пола для корректного сброса координат Вани
        const double localGroundY = 0.88;

        switch (_bossState) {
          case BossState.idle:
            _limbRotationAngle = 0.0;
            double requiredIdleTime = 3.0 * phase2CooldownReduction;
            if (_bossStateTimer >= requiredIdleTime) {
              _bossStateTimer = 0.0;
              _bossState = BossState.windingUp;
              _activeLimb = BossLimb.values[_gameRand.nextInt(BossLimb.values.length)];
              AudioManager.playBossWhip(); 
            }
            break;

          case BossState.windingUp:
            _limbRotationAngle += 18.0 * dt * phase2SpeedMultiplier;
            double requiredWindUpTime = 0.75 / phase2SpeedMultiplier; 
            if (_bossStateTimer >= requiredWindUpTime) {
              _bossStateTimer = 0.0;
              _bossState = BossState.attacking;
              AudioManager.playBossStrike(); 
            }
            break;

                   case BossState.attacking:
            _limbRotationAngle = 0.0;

            // Вычисляем текущую физическую позицию лапы на арене
            double attackProgress = 0.0;
            if (_bossStateTimer < 0.25) {
              attackProgress = _bossStateTimer / 0.25; // Выпад вперед
            } else {
              attackProgress = (1.0 - _bossStateTimer) / 0.75; // Возврат назад
            }
            
            double currentPunchX = _bossX - (attackProgress * 0.82);
            if (currentPunchX < 0.02) currentPunchX = 0.02;

            double distanceToLimb = (_vanyaX - currentPunchX).abs();
            
            if (distanceToLimb < 0.14) { 
              bool isHit = false;
              
              // 🐙 ЩУПАЛЬЦА (Низ): Сносят баррикаду ИЛИ бьют Ваню, если он не прыгнул
              if (_activeLimb == BossLimb.leftTentacle || _activeLimb == BossLimb.rightTentacle) {
                if (_isBarricadeAlive) {
                  _isBarricadeAlive = false;
                  AudioManager.playBlockBreak(true); // Баррикада рушится со звуком камня от щупальца!
                } else {
                  if (!_vanyaIsJumping) isHit = true;
                }
              } 
              // 🦀 КЛЕШНИ (Верх): Ловят Ваню строго в прыжке
              else {
                if (_vanyaIsJumping && _vanyaVy < 0) isHit = true;
              }

              // ИСПРАВЛЕНО: Теперь и щупальце, и клешня наносят честный урон в 1 сердце!
              if (isHit && _vanyaHearts > 0) {
                _vanyaHearts--;
                _spawnBloodSplatter(); // Спавн лужи крови
                

                if (_vanyaHearts > 0) {
                  AudioManager.playMiss();
                  _vanyaX = 0.15; // Отброс на спавн
                  _vanyaY = localGroundY - 0.05;
                  _vanyaIsJumping = false;
                  _vanyaVy = 0.0;
                } else {
                  AudioManager.playGameOver();
                }
              }
            }

            if (_bossStateTimer >= 1.0) {
              _bossStateTimer = 0.0;
              _bossStrikeCounter++;
              if (_bossStrikeCounter >= 3) {
                _bossStrikeCounter = 0;
                _bossState = BossState.dizzy;
                _staggerEffectTimer = 0.0;
              } else {
                _bossState = BossState.idle;
              }
            }
            break;

          // ИСПРАВЛЕНО И ДОБАВЛЕНО: Блок фазы отдыха босса, которого не хватало для компиляции!
          case BossState.dizzy:
            _staggerEffectTimer += dt; 
            _limbRotationAngle = 0.0; 
            if (_bossStateTimer >= 5.0) {
              _bossStateTimer = 0.0;
              _staggerEffectTimer = 0.0;
              _bossState = BossState.idle; // Проснулся через 5 секунд
            }
            break;
        } // switch
      } // if (_bossCurrentHp > 0)

            // 4. СТОЛКНОВЕНИЕ С ДОНОМ МОЛЛЮСКОМ (НАНЕСЕНИЕ УРОНА БОССУ)
      const double localGroundY2 = 0.88;
      double dx = _vanyaX - _bossX;
      double dy = _vanyaY - (localGroundY2 - 0.12);
      double distance = sqrt(dx * dx + dy * dy);

      if (distance < 0.12 && _bossCurrentHp > 0) {
        if (_bossState == BossState.dizzy || _isAngryMode) {
          _bossCurrentHp -= 1.0; 
          AudioManager.playPigHit(); 
          
          _vanyaVx = -0.48; 
          _vanyaVy = -0.58; 
          _vanyaIsJumping = true;
          _vanyaX -= 0.12;

          if (_bossState == BossState.dizzy) {
            _bossState = BossState.idle;
            _bossStateTimer = 0.0;
            _staggerEffectTimer = 0.0;
            _bossStrikeCounter = 0;
          }
          
          _isAngryMode = false; 
          AudioManager.stopRage(); 

          // ИСПРАВЛЕНО: Моментальный переход на Кровавый Рок без секундных ожиданий
          if (_bossCurrentHp <= 4.0 && !_isPhase2Active && _bossCurrentHp > 0) {
            _isPhase2Active = true; 
            // Жестко и мгновенно тушим старый плеер уровня, чтобы освободить аудио-канал под Рок!
            AudioManager.stopLevelAudioAndPlayMenu(); 
            AudioManager.switchToBossPhase2Music(); 
            print("ДОН МОЛЛЮСК В СЕКУНДЕ ЯРОСТИ! Рок Фазы 2 запущен мгновенно.");
          }
                } else {
          // ИСПРАВЛЕНО ТОЧЕЧНО: Таран защищенного панциря теперь забирает жизнь, льет лужу и пачкает экран!
          if (_vanyaHearts > 0) {
            _vanyaHearts--;
            _spawnBloodSplatter();    // Спавним лужу на полу
          }
          
          // Твой стандартный отскок Вани назад налево по дуге
          _vanyaVx = -0.35;
          _vanyaVy = -0.45;
          _vanyaIsJumping = true;
          _vanyaX -= 0.06;

          if (_vanyaHearts > 0) {
            AudioManager.playMiss();
          } else {
            AudioManager.playGameOver();
          }
        }
      }

    });
  }



  @override
  void dispose() {
    if (_gameLoopTicker.isActive) {
      _gameLoopTicker.stop();
    }
    _gameLoopTicker.dispose();
    _debrisController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // ЕCЛИ НАЖАТA КHОПКА ПОГНАЛИ — ВКЛЮЧАЕМ ЖИВУЮ БОЕВУЮ АРЕНУ
    if (_isGameplayActive) {
      return _buildLiveGameplayArena();
    }

    // ИНАЧЕ — ИГРОК ПРОСМАТРИВАЕТ ТРИ КАДРА ПРЕДЫСТОРИИ
    return Scaffold(
      backgroundColor: const Color(0xFF040407), 
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 4), 
            const Text(
              "ГЛАВА VI: ЛОГОВО ДОНА МОЛЛЮСКА",
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.w900,
                color: Color(0xFF455A64),
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 6),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    if (_currentFrame >= 1) _buildGoodFrame1(),
                    if (_currentFrame >= 2) const SizedBox(width: 12),
                    if (_currentFrame >= 2) _buildGoodFrame2(),
                    if (_currentFrame >= 3) const SizedBox(width: 12),
                    if (_currentFrame >= 3) _buildGoodFrame3(),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 4.0, top: 2.0),
              child: _buildNavigationButton(),
            ),
          ],
        ),
      ),
    );
  }

   // =========================================================================
  // ХОРОШАЯ ЛИНИЯ - КАДР 1: Спокойствие шерифа против ухмылки босса
  // =========================================================================
  Widget _buildGoodFrame1() {
    return Expanded(
      child: _buildAdvanced3DFrame(
        hasHole: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(bottom: 22, right: 10, child: Transform.scale(scale: 1.25, child: _buildThrone())),    
            Positioned(bottom: 22, right: 95, child: _buildGoldTotem(38)),
            Positioned(bottom: 22, left: 16, child: _buildCharacter('assets/images/bunnyhop.png', 56)),
            Positioned(bottom: 12, right: 8, child: _buildDonMollusk(68)),

            // Облачко слов Вани
            Positioned(
              top: 20, left: 6, width: 105,
              child: CustomPaint(
                painter: SpeechBubblePainter(tailXFactor: 0.25),
                child: const Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Text(
                    "Творя власть на лугу птиц окончена, Моллюск. Отдай тотем гнева, освободи луг и мы закончим это.",
                    style: TextStyle(fontSize: 7.2, fontWeight: FontWeight.bold, color: Colors.black, height: 1.15),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            // Ответ Дона Моллюска
            Positioned(
              top: 75, right: 6, width: 110,
              child: CustomPaint(
                painter: SpeechBubblePainter(tailXFactor: 0.8),
                child: const Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Text(
                    "Ты слишком самоуверен для того, кто ползает по земле! Жалкая птица. Я следил за тобой с самого первого дня твоего путешествия, видел все твои битвы, я думал ты прибежишь сюда в ярости!",
                    style: TextStyle(fontSize: 6.8, fontWeight: FontWeight.bold, color: Colors.black, height: 1.1),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // ХОРОШАЯ ЛИНИЯ - КАДР 2: Спокойное разоблачение планов босса
  // =========================================================================
  Widget _buildGoodFrame2() {
    return Expanded(
      child: _buildAdvanced3DFrame(
        hasHole: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(bottom: 22, left: 12, child: _buildCharacter('assets/images/bunnyhop.png', 48)),
            Positioned(bottom: 12, right: 8, child: _buildDonMollusk(68)),

            // Ваня парирует психологическое давление
            Positioned(
              top: 20, left: 4, width: 110,
              child: CustomPaint(
                painter: SpeechBubblePainter(tailXFactor: 0.25),
                child: const Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Text(
                    "Я видел все твои знаки и тени. Но они меня не напугали, а лишь привели к твоей двери. Твой план провалился.",
                    style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold, color: Colors.black, height: 1.15),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            // Взрыв эмоций Дона Моллюска
            Positioned(
              top: 72, right: 4, width: 110,
              child: CustomPaint(
                painter: SpeechBubblePainter(tailXFactor: 0.75),
                child: const Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Text(
                    "Ах ты наглая птица! Ты думаешь, раз выжил и разрушил все постройки, то сможешь одолеть меня?! Хрю-выкуси!",
                    style: TextStyle(fontSize: 7.2, fontWeight: FontWeight.bold, color: Colors.black, height: 1.1),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoodFrame3() {
    return Expanded(
      child: _buildAdvanced3DFrame(
        hasHole: true, // ВКЛЮЧАЕТ ТЕМНО-СИНЕЕ НЕБО И ДЫРУ В КРЫШЕ
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(bottom: 22, left: 12, child: _buildCharacter('assets/images/bunnyhop.png', 48)),
            Positioned(bottom: 12, right: 8, child: _buildDonMollusk(64)),

            // =================================================================
            // НОВЫЙ БЛОК: АНИМИРОВАННЫЕ ОБЛОМКИ С ФИЗИКОЙ ОТСКОКА
            // =================================================================
            AnimatedBuilder(
              animation: _fallAnimation,
              builder: (context, child) {
                // fallValue идет от 0.0 (наверху) до 1.0 (на полу) с эффектом отскока
                final fallValue = _fallAnimation.value;
                
                return Stack(
                  children: [
                    // 1. Главная каменная глыба-баррикада
                    Positioned(
                      // Падает с высоты 150 вниз и останавливается на координате 20 (на полу)
                      bottom: 150 - (fallValue * 130), 
                      left: 62,
                      child: Container(
                        width: 25, height: 45,
                        decoration: BoxDecoration(
                          color: const Color(0xFF37474F),
                          border: Border.all(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    
                    // 2. Мелкий осколок 1 (летит с вращением и отлетает влево)
                    Positioned(
                      bottom: 140 - (fallValue * 120), 
                      left: 68 - (fallValue * 12), // Смещается влево при падении
                      child: Transform.rotate(
                        angle: fallValue * pi * 4, // Реалистично крутится (нужен import 'dart:math'; - он у тебя есть)
                        child: _buildFallingDebris(6, 10),
                      ),
                    ),

                    // 3. Мелкий осколок 2 (летит с другой скоростью и отлетает вправо)
                    Positioned(
                      bottom: 160 - (fallValue * 140), 
                      left: 74 + (fallValue * 18), // Смещается вправо
                      child: Transform.rotate(
                        angle: -fallValue * pi * 3, // Крутится в обратную сторону
                        child: _buildFallingDebris(8, 8),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Облачко слов Вани (остается без изменений)
            Positioned(
              top: 25, left: 6, right: 6,
              child: CustomPaint(
                painter: SpeechBubblePainter(tailXFactor: 0.25),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Похоже твой замок разваливается сам, Моллюск! Ничего, сейчас я его доломаю и убью тебя!",
                    style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.black, height: 1.15),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

    // =========================================================================
  // ⚡ ЖИВАЯ ИНТЕРАКТИВНАЯ АРЕНА ХОРОШЕГО ПУТИ (КНОПКИ, СЕРДЦА, БОСС, ФИЗИКА)
  // =========================================================================
  Widget _buildLiveGameplayArena() {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF020204),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _EndingRoomBackgroundPainter(
                hasHole: true, 
                showLightning: false,
                // Если активен режим ярости — передаем таймер для переливания цвета неба в проёме крыши
                isAcidSky: _isAngryMode,
                acidTimer: _angryTimer,
                isBloodMode: _isPhase2Active,
              ),
              child: Stack(
                children: [
                  Positioned(top: 0, left: 0, right: 0, child: CustomPaint(size: const Size(double.infinity, 35), painter: _CeilingPainter(drawHole: true))),
                  Positioned(bottom: 0, left: 0, right: 0, child: CustomPaint(size: const Size(double.infinity, 24), painter: _FloorTilesPainter())),

                  if (_isBarricadeAlive)
                    Positioned(
                      bottom: 24, 
                      left: size.width * _barricadeX,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _isBarricadeAlive = false);
                          AudioManager.playBlockBreak(true);
                        },
                        child: Container(
                          width: size.width * 0.025, 
                          height: size.height * 0.16, 
                          decoration: BoxDecoration(
                            color: const Color(0xFF37474F),
                            border: Border.all(color: Colors.black, width: 1.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                                    // 💊 СИНЯЯ КАПСУЛА ВИАГРЫ (Отрисовка перенесена, координаты Y теперь потолочные)
                  if (_isPillSpawned)
                    Positioned(
                      left: _pillX * size.width,
                      top: _pillY * size.height,
                      child: Container(
                        width: 14, height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFF29B6F6),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: const Color(0xFF0288D1), width: 1.5),
                          boxShadow: const [BoxShadow(color: Colors.blueAccent, blurRadius: 6, spreadRadius: 1)],
                        ),
                        child: const Center(
                          child: Text("V", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white)),
                        ),
                      ),
                    ),

                                    // 🐖 НОВОЕ ТОЧЕЧНО: Отрисовка левой катящейся свиньи (выезжает слева в Фазе 2)
                  if (_isLeftPigActive && _leftPigX > 0)
                    Positioned(
                      bottom: 22,
                      left: size.width * _leftPigX - 18,
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            // Черная бомба на спине левой свиньи
                            Positioned(
                              top: -8, left: -2, // Отражаем зеркально на левый бок
                              child: Container(
                                width: 14, height: 14,
                                decoration: const BoxDecoration(color: Color(0xFF212121), shape: BoxShape.circle),
                                child: Center(
                                  child: Container(width: 3, height: 3, color: const Color(0xFFFF9800)),
                                ),
                              ),
                            ),
                            Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF2E7D32), width: 1.8),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/maksim.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF4CAF50)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  
                  // 🐖 ИСПРАВЛЕНО ТОЧЕЧНО: Отрисовка катящейся свиньи-камикадзе с лицом Максима и бомбой
                  if (_isBombPigActive && _bombPigX > 0)
                    Positioned(
                      bottom: 22, // Стоит чётко на плитке пола арены
                      left: size.width * _bombPigX - 18,
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            // Черная круглая бомба, привязанная на спине у свиньи
                            Positioned(
                              top: -8, right: -2,
                              child: Container(
                                width: 14, height: 14,
                                decoration: const BoxDecoration(color: Color(0xFF212121), shape: BoxShape.circle),
                                child: Center(
                                  child: Container(width: 3, height: 3, color: const Color(0xFFFF9800)), // Искрящийся фитиль
                                ),
                              ),
                            ),
                            // Тело свиньи каноничного зеленого цвета из game_screen.dart
                            Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50), // Тот самый цвет ушей и тела из оригинальной игры
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF2E7D32), width: 1.8),
                              ),
                              child: ClipOval(
                                // Накладываем лицо Максима Рыбалкина, взятое из твоего гейм-экрана!
                                child: Image.asset(
                                  'assets/images/maksim.png', // Твой оригинальный ассет лица свиней
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF4CAF50)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 💥 Векторная огненная вспышка подрыва бомбы камикадзе
                  if (_explosionTimer > 0 && _explosionX > 0)
                    Positioned(
                      bottom: 12,
                      left: size.width * _explosionX - 35,
                      child: AnimatedOpacity(
                        duration: Duration.zero,
                        opacity: (_explosionTimer / 0.35).clamp(0.0, 1.0),
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [Colors.white, Colors.yellow, Colors.orange, Colors.transparent],
                              stops: [0.1, 0.4, 0.8, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),


                                    // 🌟 ТОЧЕЧНО ВСТАВИТЬ В STACK ПРЕД ОТРИСОВКОЙ БОССА:
                  if (_bossState == BossState.dizzy && _bossCurrentHp > 0)
                    Positioned(
                      left: _bossX * size.width - 45,
                      top: size.height * 0.58, // Чётко над макушкой Дона
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          // Каждая звёздочка смещена по фазе синусоиды для эффекта хоровода
                          double waveY = sin((_staggerEffectTimer * 6.0) + (index * 2.0)) * 10.0;
                          return Transform.translate(
                            offset: Offset(index * 14.0 - 14.0, waveY),
                            child: const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFD54F), // Маленькие жёлтые звёздочки по ТЗ
                              size: 16,
                              shadows: [Shadow(color: Color(0xFFFF8F00), blurRadius: 4)],
                            ),
                          );
                        }),
                      ),
                    ),

                  if (_bossCurrentHp > 0)
                    Positioned(
                      bottom: 22, 
                      left: size.width * _bossX,
                      child: Transform.scale(
                        scale: 2.8, 
                        child: _buildDonMollusk(52),
                      ),
                    ),

                                      // 🩸 Лужа крови Шерифа при ранении или смерти (УВЕЛИЧЕНА)
                  if (_isBloodPoolActive && _bloodPoolX > 0)
                    Positioned(
                      bottom: 22,
                      left: size.width * _bloodPoolX - 25, // Сдвигаем левее, чтобы центр остался под Ваней
                      child: SizedBox(
                        width: 65, // Было 40
                        height: 18, // Было 12
                        child: CustomPaint(
                          painter: _SheriffBloodPoolPainter(),
                        ),
                      ),
                    ),


                  
                  // 🔴 КРУГЛЫЙ ШЕРИФ + ИСПРАВЛЕННАЯ СИНЯЯ КРУТЯЩАЯСЯ АУРА ЯРОСТИ И ЗВЁЗДЫ
                  Positioned(
                    left: _vanyaX * size.width,
                    top: _vanyaY * size.height,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Если активен Виагра-Тайм — рисуем под птицей неоновую ауру и звезды
                        if (_isAngryMode)
                          Positioned(
                            top: -12, left: -12,
                            child: Transform.rotate(
                              angle: _angryTimer * pi * 3, // Бешеное кручение ауры
                              child: CustomPaint(
                                size: const Size(70, 70),
                                painter: _ViagraAuraPainter(),
                              ),
                            ),
                          ),
                        _buildCharacter('assets/images/bunnyhop.png', 46),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),



          // 📜 Б) ВЕРХНЯЯ ПАНЕЛЬ: КНОПКА ПАУЗЫ, СЕРДЦА ЖИЗНЕЙ И КЛЁШНЫЙ HP-БАР БОССА
          Positioned(
            top: 14, left: 16, right: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          style: IconButton.styleFrom(backgroundColor: Colors.black45, padding: const EdgeInsets.all(6)),
                          icon: const Icon(Icons.pause_rounded, color: Colors.white, size: 22),
                          onPressed: () {
                        // ИСПРАВЛЕНО: Вместо вылета открываем оригинальное PauseMenu из game_screen.dart!
                        // Создаём временный контекст-заглушку, чтобы вызвать твоё оригинальное меню оверлеев
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            // Вызываем точно такое же по дизайну меню паузы, как в game_screen.dart!
                            return Center(
                              child: Container(
                                width: 280,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.orange, width: 4),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'ПАУЗА',
                                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2, decoration: TextDecoration.none),
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 44,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                        onPressed: () => Navigator.pop(context), // ПРОДОЛЖИТЬ
                                        child: const Text('ПРОДОЛЖИТЬ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 44,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                        onPressed: () {
                                      // ЗАНОВО: сбрасываем арену
                                      Navigator.pop(context);
                                      AudioManager.startLevel6BattleMusic();
                                      setState(() {
                                        _vanyaX = 0.15;
                                        _vanyaY = _groundYPercent - 0.05;
                                        _bossCurrentHp = 8.0;
                                        _isBarricadeAlive = true;
                                        _vanyaHearts = 1;
                                        _isPhase2Active = false;

                                        // ИСПРАВЛЕНО ТОЧЕЧНО: Полная очистка таблеток, свиней и эффектов крови при рестарте
                                        _isPillSpawned = false;
                                        _pillX = -1.0;
                                        _pillY = -1.0;
                                        _pillSpawnTimer = 0.0;
                                        _isAngryMode = false;
                                        _isBloodPoolActive = false;
                                        _bloodPoolX = -1.0;
                                        
                                        _isBombPigActive = false;
                                        _isLeftPigActive = false;
                                        _bombPigX = -1.0;
                                        _leftPigX = -1.0;
                                        _bombPigTimer = 0.0;
                                      });
                                    },
                                        child: const Text('ЗАНОВО', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 44,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                        onPressed: () {
                                          _isGameplayActive = false;
                                          Navigator.pop(context); // закрываем паузу
                                          AudioManager.stopLevelAudioAndPlayMenu();
                                          Navigator.pop(context); // выходим в меню уровней
                                        },
                                        child: const Text('В МЕНЮ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                        ),
                        // ВСПЫШКА КРЕСТИКА «+1» НА ДОЛЮ СЕКУНДЫ НАД СЕРДЦАМИ ПО ТЗ!
                        if (_plusOneUiTimer > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              "+1", 
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade300, shadows: const [Shadow(color: Colors.blue, blurRadius: 4)]),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Ряд маленьких сердечек с эффектом плавной пульсации последнего сердца при подборе!
                    Row(
                      children: List.generate(
                        _vanyaHearts > 0 ? _vanyaHearts : 1,
                        (index) {
                          // Последнее добавившееся сердечко плавно увеличивается, если таймер пульса запущен
                          bool isNewHeart = index == _vanyaHearts - 1 && _heartPulseTimer > 0;
                          double heartScale = isNewHeart ? 1.4 : 1.0;

                          return Padding(
                            padding: const EdgeInsets.only(right: 3.0),
                            child: Transform.scale(
                              scale: heartScale,
                              child: Icon(
                                Icons.favorite_rounded,
                                color: _vanyaHearts > 0 ? const Color(0xFFE53935) : Colors.grey,
                                size: 18,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),

                // Кислотно-зелёный ХП-бар Дона Моллюска (8 ХП) в векторных клешнях
                if (_bossCurrentHp > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Левая векторная клешня зажима шкалы
                      CustomPaint(size: const Size(20, 20), painter: _DetailedCrabClawPainter(isOpen: true)),
                      const SizedBox(width: 4),
                      // Сама кислотно-зелёная полоска здоровья босса
                      Container(
                        width: 140, height: 14,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                          // ИСПРАВЛЕНО: Белое неоновое мигание рамки ХП-бара по синусоиде во время dizzy!
                          border: Border.all(
                            color: _bossState == BossState.dizzy
                                ? Colors.white.withValues(alpha: (sin(_staggerEffectTimer * 20.0) + 1.0) / 2.0)
                                : const Color(0xFF1B5E20), 
                            width: _bossState == BossState.dizzy ? 2.5 : 1.5,
                          ),
                        ),
                        child: Stack(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 140 * (_bossCurrentHp / _bossMaxHp),
                              color: const Color(0xFF00E676), // Кислотно-зеленый неон
                            ),
                            Center(
                              child: Text(
                                "${_bossCurrentHp.toInt()} / 8 HP",
                                style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Правая векторная клешня зажима шкалы
                      CustomPaint(size: const Size(20, 20), painter: _DetailedCrabClawPainter(isOpen: false)),
                    ],
                  ),
              ],
            ),
          ),

          // 🕹️ В) ИНТЕРФЕЙС УПРАВЛЕНИЯ ПО НАШЕМУ УГОВОРУ
          // Левая рука: Две полупрозрачные серые стрелки движения в нижнем левом углу
          Positioned(
            bottom: 16, left: 20,
            child: Row(
              children: [
                // Стрелка НАЗАД (Левее)
                GestureDetector(
                  onTapDown: (_) => setState(() => _btnLeftPressed = true),
                  onTapUp: (_) => setState(() => _btnLeftPressed = false),
                  onTapCancel: () => setState(() => _btnLeftPressed = false),
                  child: Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: _btnLeftPressed ? const Color(0xAAFF1744) : Colors.white12,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white60, width: 1.5),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 16),
                // Стрелка ВПЕРЁД (Правее)
                GestureDetector(
                  onTapDown: (_) => setState(() => _btnRightPressed = true),
                  onTapUp: (_) => setState(() => _btnRightPressed = false),
                  onTapCancel: () => setState(() => _btnRightPressed = false),
                  child: Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: _btnRightPressed ? const Color(0xAAFF1744) : Colors.white12,
                      shape: BoxShape.circle,
                    border: Border.all(
                      color: _bossState == BossState.dizzy
                          ? Color.lerp(Colors.white60, Colors.greenAccent, (sin(_staggerEffectTimer * 8.0) + 1.0) / 2.0)!
                          : Colors.white60,
                      width: _bossState == BossState.dizzy ? 2.5 : 1.5,
                    ),
                    ),
                    child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),

           Positioned(
            bottom: 16, right: 24,
            child: GestureDetector(
              // ЗАМЕНИТЬ СТРОГО ТОЧЕЧНО ВНУТРИ КНОПКИ ПРЫЖКА (ПРАВАЯ РУКА):
              onTapDown: (_) {
                if (!_vanyaIsJumping) {
                  setState(() {
                    _btnJumpPressed = true;
                    _vanyaIsJumping = true;
                    
                    // ИСПРАВЛЕНО ТОЧЕЧНО: Горизонтальный импульс урезан до 0.16 — прыжок стал намного короче в длину!
                    if (_btnRightPressed) {
                      _vanyaVy = -4.1; 
                      _vanyaVx = 0.16; // Аккуратный укороченный полёт вперёд
                    } else if (_btnLeftPressed) {
                      _vanyaVy = -4.1;
                      _vanyaVx = -0.16; // Аккуратный укороченный полёт назад
                    } else {
                      _vanyaVy = -3.9; // Небольшой прыжок строго вверх на месте
                    }
                  });
                }
              },
              onTapUp: (_) => setState(() => _btnJumpPressed = false),
              onTapCancel: () => setState(() => _btnJumpPressed = false),
              child: Container(
                width: 58, height: 58,
                decoration: BoxDecoration(
                  color: _btnJumpPressed ? const Color(0xAAFF1744) : Colors.white12,
                  shape: BoxShape.circle,
                border: Border.all(
                  color: _bossState == BossState.dizzy
                      ? Color.lerp(Colors.white60, Colors.greenAccent, (sin(_staggerEffectTimer * 8.0) + 1.0) / 2.0)!
                      : Colors.white60,
                  width: _bossState == BossState.dizzy ? 2.5 : 1.8,
                ),
                ),
                child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 26),
              ),
            ),
          ),

          // Экран триумфа, если тестовый босс полностью повержен
          if (_bossCurrentHp <= 0)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9), 
            borderRadius: BorderRadius.circular(16), 
            border: Border.all(color: Colors.orange, width: 2),
          ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                                    children: [
                    const Text("ТЫ УБИЛ БОССА!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      onPressed: () async {
                        // ИСПРАВЛЕНО: Сначала полностью сбрасываем и уничтожаем ВСЕ плееры уровня
                        await AudioManager.stopLevel5Rain();
                        AudioManager.stopAllLevelSounds();
                        await AudioManager.stopLevelAudioAndPlayMenu();
                        
                        if (context.mounted) {
                          setState(() {
                            _isGameplayActive = false;
                          });
                          Navigator.pop(context); // Чистый выход в меню
                        }
                      },
                      child: const Text("В МЕНЮ УРОВНЕЙ", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
           // ТОЧЕЧНО ВСТАВИТЬ В САМЫЙ КОНЕЦ СПИСКА CHILDREN В МЕТОДЕ _buildLiveGameplayArena:

          // =========================================================================
          // 🟥 ИСПРАВЛЕНО ПО ТЗ: ОВЕРЛЕЙ ПРОИГРЫША ПРИ ОБНУЛЕНИИ СЕРДЕЦ ШЕРИФА
          // =========================================================================
          if (_vanyaHearts <= 0)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.85), // Плотное зловещее затемнение арены
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    constraints: const BoxConstraints(maxWidth: 320),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A0A0A), // Темно-бордовый оттенок проигрыша
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFB71C1C), width: 3),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15)],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "ШЕРИФ ПОВЕРЖЕН",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFB71C1C), letterSpacing: 1.5, decoration: TextDecoration.none),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "У вас закончились жизни. Замок Дона Моллюска обрушился...",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: Colors.white70, decoration: TextDecoration.none),
                        ),
                        const SizedBox(height: 20),
                        
                        // РОДНАЯ И ЕДИНСТВЕННАЯ КНОПКА «КОНЕЦ» ДЛЯ ВЫЛЕТА В ПЛОХУЮ КОНЦОВКУ
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB71C1C),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 5,
                            ),
                            onPressed: () {
                              // Полностью зачищаем звуки арены финала
                              AudioManager.startCastleDrops();
                              
                              // ПРИНУДИТЕЛЬНО И МОМЕНТАЛЬНО ПЕРЕНАПРАВЛЯЕМ ИГРОКА НА ЭКРАН ПЛОХОЙ КОНЦОВКИ!
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const Level6Case07Screen()), // Твой класс из level6_bad_route_screen.dart
                              );
                            },
                            child: const Text(
                              "КОНЕЦ", 
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // =========================================================================
  // РАЗБЛОКИРОВАННАЯ КНОПКА НАВИГАЦИИ С КОРОТКОЙ НАДПИСЬЮ «КОНЕЦ»
  // =========================================================================
  Widget _buildNavigationButton() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 240),
      height: 38, 
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          backgroundColor: const Color(0xFF37474F), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          if (_currentFrame < 3) {
            setState(() => _currentFrame++);
            
            if (_currentFrame == 3) {
              AudioManager.playCastleCollapse();
              _debrisController.forward(from: 0.0);
            }
          } else {
            // Кнопка полностью РАЗБЛОКИРОВАНА и запускает живой тест геймплея арены!
            AudioManager.startLevel6BattleMusic();
            setState(() {
              _isGameplayActive = true;
            });
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _currentFrame == 3 ? "КОНЕЦ" : "ДАЛЬШЕ", 
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ), 
            const SizedBox(width: 6), 
            Icon(_currentFrame == 3 ? Icons.play_circle_filled_rounded : Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvanced3DFrame({required Widget child, required bool hasHole}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black, width: 3.5),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF14141E), Color(0xFF06060A)],
                  ),
                ),
              ),
            ),
            if (hasHole)
              Positioned(
                top: 0, left: 45, right: 45, height: 18,
                child: Container(color: const Color(0xFF0D1B2A)), 
              ),
            Positioned(top: 0, left: 0, right: 0, child: CustomPaint(size: const Size(double.infinity, 35), painter: _CeilingPainter(drawHole: hasHole))),
            Positioned(bottom: 0, left: 0, right: 0, child: CustomPaint(size: const Size(double.infinity, 24), painter: _FloorTilesPainter())),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildFallingDebris(double w, double h) {
    return Container(
      width: w, height: h,
      decoration: BoxDecoration(color: const Color(0xFF455A64), border: Border.all(color: Colors.black, width: 1)),
    );
  }

  Widget _buildThrone() {
    return SizedBox(
      width: 40, height: 58,
      child: Stack(
        children: [
          Positioned(bottom: 4, left: 4, right: 4, child: Container(height: 54, decoration: BoxDecoration(color: const Color(0xFF3E2723), borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)), border: Border.all(color: const Color(0xFF1A0C00), width: 1.8)))),
          Positioned(bottom: 4, left: 0, child: Container(width: 5, height: 26, decoration: BoxDecoration(color: const Color(0xFF4E342E), border: Border.all(color: Colors.black, width: 0.8)))),
          Positioned(bottom: 4, right: 0, child: Container(width: 5, height: 26, decoration: BoxDecoration(color: const Color(0xFF4E342E), border: Border.all(color: Colors.black, width: 0.8)))),
          Positioned(bottom: 6, left: 3, right: 3, child: Container(height: 14, color: const Color(0xFF4E342E))),
          Positioned(bottom: 14, left: 4, right: 4, child: Container(height: 6, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFFF5252), Color(0xFFB71C1C)]), borderRadius: BorderRadius.circular(2)))),
        ],
      ),
    );
  }

  Widget _buildGoldTotem(double size) {
    return SizedBox(
      width: size, height: size * 1.1,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(bottom: 0, child: Container(width: size * 0.75, height: size * 0.16, decoration: BoxDecoration(color: const Color(0xFF111116), borderRadius: BorderRadius.circular(2), border: Border.all(color: Colors.black, width: 1.5)))),
          Positioned(bottom: size * 0.14, child: Container(width: size * 0.14, height: size * 0.32, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFE5A632), Color(0xFFFFD54F), Color(0xFFB57C1E)])))),
          Positioned(bottom: size * 0.38, child: SizedBox(width: size * 1.05, height: size * 0.65, child: CustomPaint(painter: _WingsPainter()))),
        ],
      ),
    );
  }

        Widget _buildDonMollusk(double size) {
    final sizeMedia = MediaQuery.of(context).size;
    
    // Вычисляем прогресс атаки от 0.0 до 1.0 внутри секунды удара
    double attackProgress = 0.0;
    if (_bossState == BossState.attacking) {
      if (_bossStateTimer < 0.25) {
        attackProgress = _bossStateTimer / 0.25; // Молниеносный выпад вперед
      } else {
        attackProgress = (1.0 - _bossStateTimer) / 0.75; // Возврат назад
      }
    }
    
    double stretchFactor = 1.0 + (attackProgress * 3.5);
    
    // Ограничиваем вылет границей экрана (0.02)
    double maxPunchDistance = sizeMedia.width * (_bossX - 0.02);
    double punchOffset = attackProgress * maxPunchDistance;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 🐙 ЛЕВОЕ НИЖНЕЕ ЩУПАЛЬЦЕ (Бьет ПО ЗЕМЛЕ во всю длину экрана)
          Positioned(
            bottom: size * 0.24, left: size * 0.04, 
            child: Transform.translate(
              offset: Offset(_bossState == BossState.attacking && _activeLimb == BossLimb.leftTentacle ? -punchOffset : 0, _bossState == BossState.attacking && _activeLimb == BossLimb.leftTentacle ? size * 0.2 : 0),
              child: Transform.scale(
                // Растягиваем щупальце в длину по горизонтали (ось X)
                scaleX: _bossState == BossState.attacking && _activeLimb == BossLimb.leftTentacle ? stretchFactor : 1.0,
                alignment: Alignment.centerRight, // Растяжение идет от тела босса влево!
                child: Transform.rotate(
                  angle: _bossState == BossState.windingUp && _activeLimb == BossLimb.leftTentacle ? _limbRotationAngle : -0.3, 
                  child: CustomPaint(size: Size(size * 0.28, size * 0.58), painter: _DetailedTentaclePainter(isLeft: true, isFallen: _bossState == BossState.dizzy)),
                ),
              ),
            ),
          ),
          
          // Фоновые щупальца
          Positioned(top: size * 0.06, left: size * 0.12, child: Transform.rotate(angle: -1.3, child: CustomPaint(size: Size(size * 0.25, size * 0.53), painter: _DetailedTentaclePainter(isLeft: true, isFallen: _bossState == BossState.dizzy)))),
          Positioned(top: size * 0.06, right: size * 0.12, child: Transform.rotate(angle: 1.3, child: CustomPaint(size: Size(size * 0.25, size * 0.53), painter: _DetailedTentaclePainter(isLeft: false, isFallen: _bossState == BossState.dizzy)))),

          // 🐙 ПРАВОЕ НИЖНЕЕ ЩУПАЛЬЦЕ (Бьет ПО ЗЕМЛЕ во всю длину экрана)
          Positioned(
            bottom: size * 0.24, right: size * 0.04, 
            child: Transform.translate(
              offset: Offset(_bossState == BossState.attacking && _activeLimb == BossLimb.rightTentacle ? -punchOffset : 0, _bossState == BossState.attacking && _activeLimb == BossLimb.rightTentacle ? size * 0.2 : 0),
              child: Transform.scale(
                scaleX: _bossState == BossState.attacking && _activeLimb == BossLimb.rightTentacle ? stretchFactor : 1.0,
                alignment: Alignment.centerRight,
                child: Transform.rotate(
                  angle: _bossState == BossState.windingUp && _activeLimb == BossLimb.rightTentacle ? _limbRotationAngle : 0.4, 
                  child: CustomPaint(size: Size(size * 0.28, size * 0.58), painter: _DetailedTentaclePainter(isLeft: false, isFallen: _bossState == BossState.dizzy)),
                ),
              ),
            ),
          ),

          // 🐷 УШКИ БОССА
          Positioned(top: size * 0.10, left: size * 0.08, child: Transform.rotate(angle: -0.2, child: Container(width: size * 0.18, height: size * 0.26, decoration: BoxDecoration(color: const Color(0xFF689F38), borderRadius: BorderRadius.circular(size * 0.09), border: Border.all(color: Colors.black, width: 1.8)), child: Center(child: Container(width: size * 0.08, height: size * 0.14, decoration: BoxDecoration(color: const Color(0xFF558B2F), borderRadius: BorderRadius.circular(size * 0.05))))))),
          Positioned(top: size * 0.10, right: size * 0.08, child: Transform.rotate(angle: 0.2, child: Container(width: size * 0.18, height: size * 0.26, decoration: BoxDecoration(color: const Color(0xFF689F38), borderRadius: BorderRadius.circular(size * 0.09), border: Border.all(color: Colors.black, width: 1.8)), child: Center(child: Container(width: size * 0.08, height: size * 0.14, decoration: BoxDecoration(color: const Color(0xFF558B2F), borderRadius: BorderRadius.circular(size * 0.05))))))),

          // 🦀 ЛЕВАЯ НИЖНЯЯ КЛЕШНЯ (Бьет ПО ВЕРХУ во всю длину экрана)
          Positioned(
            bottom: size * 0.16, left: -size * 0.02,
            child: Transform.translate(
              offset: Offset(_bossState == BossState.attacking && _activeLimb == BossLimb.leftClaw ? -punchOffset : 0, _bossState == BossState.attacking && _activeLimb == BossLimb.leftClaw ? -punchOffset * 0.35 : 0),
              child: Transform.scale(
                scaleX: _bossState == BossState.attacking && _activeLimb == BossLimb.leftClaw ? stretchFactor : 1.0,
                alignment: Alignment.centerRight,
                child: Transform.rotate(
                  angle: _bossState == BossState.windingUp && _activeLimb == BossLimb.leftClaw ? _limbRotationAngle : -0.1, 
                  child: CustomPaint(size: Size(size * 0.34, size * 0.34), painter: _DetailedCrabClawPainter(isOpen: false, isFallen: _bossState == BossState.dizzy)),
                ),
              ),
            ),
          ),
          
          // 🦀 ПРАВАЯ НИЖНЯЯ КЛЕШНЯ (Бьет ПО ВЕРХУ во всю длину экрана)
          Positioned(
            bottom: size * 0.16, right: -size * 0.02,
            child: Transform.translate(
              offset: Offset(_bossState == BossState.attacking && _activeLimb == BossLimb.rightClaw ? -punchOffset : 0, _bossState == BossState.attacking && _activeLimb == BossLimb.rightClaw ? -punchOffset * 0.35 : 0),
              child: Transform.scale(
                scaleX: _bossState == BossState.attacking && _activeLimb == BossLimb.rightClaw ? stretchFactor : 1.0,
                alignment: Alignment.centerRight,
                child: Transform.rotate(
                  angle: _bossState == BossState.windingUp && _activeLimb == BossLimb.rightClaw ? _limbRotationAngle : 0.1, 
                  child: CustomPaint(size: Size(size * 0.34, size * 0.34), painter: _DetailedCrabClawPainter(isOpen: false, isFallen: _bossState == BossState.dizzy)),
                ),
              ),
            ),
          ),

          // 🦀 ВЕРХНЯЯ КЛЕШНЯ НА МАКУШКЕ
          Positioned(
            top: _bossState == BossState.dizzy ? 0 : -size * 0.12, 
            left: size * 0.33,
            child: Transform.translate(
              offset: Offset(_bossState == BossState.attacking && _activeLimb == BossLimb.rightClaw ? -punchOffset * 0.7 : 0, _bossState == BossState.attacking && _activeLimb == BossLimb.rightClaw ? punchOffset * 0.5 : 0),
              child: CustomPaint(size: Size(size * 0.34, size * 0.34), painter: _DetailedCrabClawPainter(isOpen: true, isFallen: _bossState == BossState.dizzy)),
            ),
          ),

          // 🟢 ЦЕНТРАЛЬНОЕ ТЕЛО БОССА
          Container(
            width: size * 0.70, height: size * 0.70,
            decoration: BoxDecoration(color: const Color(0xFF558B2F), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF1B5E20), width: 2.2), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))]),
            child: ClipOval(child: Image.asset('assets/images/maksim_boss.png', fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF558B2F)))),
          ),
        ],
      ),
    );
  }


  

  // ЗАМЕНИТЬ СТРОГО ТОЧЕЧНО В КОНЦЕ КЛАССА СОСТОЯНИЯ (МЕТОД _buildCharacter):
  Widget _buildCharacter(String assetPath, double size) {
    return Container(
      width: size, 
      height: size, 
      decoration: BoxDecoration(
        color: assetPath.contains('bunnyhop') ? const Color(0xFFE53935) : const Color(0xFF7CB342), 
        shape: BoxShape.circle, 
        border: Border.all(color: Colors.black, width: 2.0),
      ), 
      child: ClipOval(
        child: Image.asset(assetPath, fit: BoxFit.cover),
      ),
    );
  }
} // <--- ЗАКРЫТИЕ КЛАССА СОСТОЯНИЯ ЭКРАНА СТРАНИЦЫ _Level6GoodRouteScreenState

class _CeilingPainter extends CustomPainter {
  final bool drawHole;
  final bool isBloodMode; // Добавили поддержку крови
  _CeilingPainter({required this.drawHole, this.isBloodMode = false});

  @override
  void paint(Canvas canvas, Size size) {
    // Если вторая фаза — потолок окрашивается в кирпично-бордовый цвет нагара
    final ceilPaint = Paint()..color = isBloodMode ? const Color(0xFF4A1414) : const Color(0xFF15151D)..style = PaintingStyle.fill;
    final beamPaint = Paint()..color = isBloodMode ? const Color(0xFF1A0000) : const Color(0xFF09090D)..style = PaintingStyle.stroke..strokeWidth = 2.2;
    
    if (!drawHole) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), ceilPaint);
      for (int i = 0; i <= 6; i++) {
        canvas.drawLine(Offset(size.width * 0.5, 0), Offset(size.width * (i / 6), size.height), beamPaint);
      }
    } else {
      final leftPath = Path()
        ..moveTo(0, 0)..lineTo(size.width * 0.42, 0)
        ..lineTo(size.width * 0.35, size.height)..lineTo(0, size.height)..close();
      canvas.drawPath(leftPath, ceilPaint);
      canvas.drawPath(leftPath, beamPaint);

      final rightPath = Path()
        ..moveTo(size.width * 0.58, 0)..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)..lineTo(size.width * 0.65, size.height)..close();
      canvas.drawPath(rightPath, ceilPaint);
      canvas.drawPath(rightPath, beamPaint);
    }
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), beamPaint);
  }
  @override
  bool shouldRepaint(covariant _CeilingPainter oldDelegate) => true;
}

class _FloorTilesPainter extends CustomPainter {
  final bool isBloodMode; // Добавили поддержку крови
  _FloorTilesPainter({this.isBloodMode = false});

  @override
  void paint(Canvas canvas, Size size) {
    // Если вторая фаза — плитка пола заливается Кровавым неоном (угольно-красный 0xFF5C1616)
    final tilePaint = Paint()..color = isBloodMode ? const Color(0xFF5C1616) : const Color(0xFF1E1E24)..style = PaintingStyle.fill;
    final linePaint = Paint()..color = isBloodMode ? const Color(0xFF2D0000) : const Color(0xFF111114)..style = PaintingStyle.stroke..strokeWidth = 1.6;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), tilePaint);
    
    for (int i = 0; i < 5; i++) {
      double hY = size.height * (0.8 - (i * i * 0.8 / 16));
      canvas.drawLine(Offset(0, hY), Offset(size.width, hY), linePaint);
    }
    for (int i = 0; i <= 12; i++) {
      canvas.drawLine(Offset(size.width * (i / 12), 0), Offset(size.width * (0.3 + (i * 0.4 / 12)), size.height), linePaint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _WingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final goldPaint = Paint()..color = const Color(0xFFFFD54F)..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(size.width * 0.5, size.height);
    path.cubicTo(size.width * 0.25, size.height * 0.8, -size.width * 0.2, size.height * 0.2, -size.width * 0.1, -size.height * 0.25); 
    path.cubicTo(size.width * 0.15, size.height * 0.2, size.width * 0.35, size.height * 0.5, size.width * 0.5, size.height * 0.35);
    path.cubicTo(size.width * 0.65, size.height * 0.5, size.width * 0.85, size.height * 0.2, size.width * 1.1, -size.height * 0.25); 
    path.cubicTo(size.width * 1.2, size.height * 0.2, size.width * 0.75, size.height * 0.8, size.width * 0.5, size.height);
    path.close();
    canvas.drawPath(path, goldPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SpeechBubblePainter extends CustomPainter {
  final double tailXFactor;
  SpeechBubblePainter({required this.tailXFactor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final borderPaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.8;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(12)));
    double startX = size.width * tailXFactor;
    path.moveTo(startX - 6, size.height);
    path.lineTo(startX, size.height + 10); 
    path.lineTo(startX + 6, size.height);
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ПОЛНОСТЬЮ ЗАМЕНИТЬ КЛАСС _DetailedTentaclePainter В САМОМ КОНЦЕ ФАЙЛА:
class _DetailedTentaclePainter extends CustomPainter {
  final bool isLeft;
  final bool isFallen; // Добавили поддержку падения рук при отдышке
  _DetailedTentaclePainter({required this.isLeft, this.isFallen = false});

  @override
  void paint(Canvas canvas, Size size) {
    final tentaclePaint = Paint()..color = const Color(0xFF0288D1)..style = PaintingStyle.fill;
    final strokePaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.6;
    final suctionPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final suctionHolePaint = Paint()..color = const Color(0xFF01579B)..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(w * 0.5, h);
    
    // Если босс в стадии отдыха, щупальца безвольно прогибаются вниз к земле по ТЗ
    double controlY = isFallen ? h * 0.95 : h * 0.7;
    path.cubicTo(isLeft ? -w * 0.7 : w * 1.7, controlY, isLeft ? w * 0.1 : w * 0.9, h * 0.2, w * 0.5, isFallen ? h * 0.8 : 0);
    path.lineTo(w * 0.7, isFallen ? h * 0.8 : 0);
    path.cubicTo(isLeft ? w * 0.3 : w * 0.7, h * 0.2, isLeft ? -w * 0.4 : w * 1.4, controlY, w * 0.8, h);
    path.close();

    canvas.drawPath(path, tentaclePaint);
    canvas.drawPath(path, strokePaint);

    for (int i = 1; i <= 6; i++) {
      double factor = i * 0.14;
      double cx = isLeft ? w * (0.32 - factor * 0.15) : w * (0.68 + factor * 0.15);
      // Смещаем присоски вниз, если руки опущены
      double cy = h * factor + (isFallen ? 10 : 0);
      double radius = 2.2 - (i * 0.15); 
      if (radius > 0.6) {
        canvas.drawCircle(Offset(cx, cy), radius, suctionPaint);
        canvas.drawCircle(Offset(cx, cy), radius, strokePaint..strokeWidth = 0.4);
        canvas.drawCircle(Offset(cx, cy), radius * 0.4, suctionHolePaint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant _DetailedTentaclePainter oldDelegate) => true;
}


// ПОЛНОСТЬЮ ЗАМЕНИТЬ КЛАСС _DetailedCrabClawPainter В САМОМ КОНЦЕ ФАЙЛА:
class _DetailedCrabClawPainter extends CustomPainter {
  final bool isOpen;
  final bool isFallen; // ИСПРАВЛЕНО: Добавили флаг бессильного падения клешней на пол!
  _DetailedCrabClawPainter({required this.isOpen, this.isFallen = false});

  @override
  void paint(Canvas canvas, Size size) {
    final clawPaint = Paint()..color = const Color(0xFF2E6F22)..style = PaintingStyle.fill;
    final strokePaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.6;
    final w = size.width;
    final h = size.height;

    canvas.save();
    // Если босс устал (dizzy), мы наклоняем и опускаем всю структуру клешни к земле!
    if (isFallen) {
      canvas.translate(w * 0.1, h * 0.2);
      canvas.rotate(isOpen ? 0.0 : 0.4); // Подгибаем боковые щипцы наружу
    }

    // 1. Нижний сустав клешни
    final jointPath = Path()
      ..moveTo(w * 0.4, h)..lineTo(w * 0.3, h * 0.6)
      ..lineTo(w * 0.7, h * 0.6)..lineTo(w * 0.6, h)..close();
    canvas.drawPath(jointPath, clawPaint);
    canvas.drawPath(jointPath, strokePaint);

    // 2. Центральное тело клешни
    final mainClawPath = Path()
      ..moveTo(w * 0.3, h * 0.6)
      ..cubicTo(w * 0.05, h * 0.4, w * 0.1, 0, w * 0.5, 0)
      ..lineTo(w * 0.45, h * 0.2)
      ..cubicTo(w * 0.3, h * 0.3, w * 0.35, h * 0.5, w * 0.7, h * 0.6)..close();
    canvas.drawPath(mainClawPath, clawPaint);
    canvas.drawPath(mainClawPath, strokePaint);

    // 3. Подвижный щипец (палец) клешни
    final movingFingerPath = Path();
    if (isOpen) {
      // Если верхняя макушечная клешня открыта
      movingFingerPath.moveTo(w * 0.45, h * 0.25);
      movingFingerPath.cubicTo(w * 0.75, h * 0.1, w * 0.95, h * 0.2, w * 0.85, h * 0.5);
      movingFingerPath.lineTo(w * 0.6, h * 0.45);
    } else {
      // Боковые закрытые клешни
      movingFingerPath.moveTo(w * 0.42, h * 0.15);
      movingFingerPath.cubicTo(w * 0.65, h * 0.2, w * 0.75, h * 0.35, w * 0.65, h * 0.55);
      movingFingerPath.lineTo(w * 0.52, h * 0.42);
    }
    movingFingerPath.close();
    canvas.drawPath(movingFingerPath, clawPaint);
    canvas.drawPath(movingFingerPath, strokePaint);

    // 4. Острые зубы клешни
    final toothPaint = Paint()..color = Colors.white70..style = PaintingStyle.fill;
    canvas.drawTriangle(Offset(w * 0.38, h * 0.25), Offset(w * 0.34, h * 0.28), Offset(w * 0.42, h * 0.29), toothPaint);
    canvas.drawTriangle(Offset(w * 0.46, h * 0.32), Offset(w * 0.42, h * 0.35), Offset(w * 0.48, h * 0.36), toothPaint);

    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant _DetailedCrabClawPainter oldDelegate) => true;
}


class _EndingRoomBackgroundPainter extends CustomPainter {
  final bool hasHole;
  final bool showLightning;
  final bool isAcidSky; 
  final double acidTimer;
  final bool isBloodMode; // Добавили поддержку крови
  
  _EndingRoomBackgroundPainter({required this.hasHole, required this.showLightning, this.isAcidSky = false, this.acidTimer = 0.0, this.isBloodMode = false});

  @override
  void paint(Canvas canvas, Size size) {
    // Вторая фаза перекрашивает стены зала в адский тёмно-красный градиент!
    final wallPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isBloodMode 
          ? [const Color(0xFF2A0808), const Color(0xFF0D0202)] // Кровавые стены
          : [const Color(0xFF14141E), const Color(0xFF06060A)], // Обычные стены
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), wallPaint);

    if (hasHole) {
      final skyRect = Rect.fromLTWH(size.width * 0.25, 0, size.width * 0.5, 25);
      
      if (isAcidSky) {
        double wave = (sin(acidTimer * pi * 2) + 1.0) / 2.0;
        final acidPaint = Paint()
          ..shader = LinearGradient(
            colors: [
              Color.lerp(const Color(0xFFD500F9), const Color(0xFF2979FF), wave)!,
              Color.lerp(const Color(0xFF00E5FF), const Color(0xFFAA00FF), wave)!,
            ],
          ).createShader(skyRect);
        canvas.drawRect(skyRect, acidPaint);
      } else {
        // Если активирована вторая фаза — небо в проломе тоже становится багровым!
        canvas.drawRect(skyRect, Paint()..color = isBloodMode ? const Color(0xFF3A0000) : const Color(0xFF0D1B2A));
      }

      if (showLightning) {
        canvas.drawRect(skyRect, Paint()..color = Colors.white.withOpacity(0.85));
      }
    }
  }
  @override
  bool shouldRepaint(covariant _EndingRoomBackgroundPainter oldDelegate) => true;
}

// 2. ДОБАВИТЬ НОВЫЙ ВЕКТОРНЫЙ КЛАСС АУРЫ В САМЫЙ КОНЕЦ ТВОЕГО ФАЙЛА:
class _ViagraAuraPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    
    // Неоновая сине-голубая шипастая подложка ауры
    final auraPaint = Paint()
      ..color = const Color(0x6600E5FF)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5); // Эффект неонового свечения
    canvas.drawCircle(Offset(cx, cy), size.width * 0.45, auraPaint);

    // Рисуем маленькие летящие вокруг Шерифа четырёхконечные звёздочки ярости
    final starPaint = Paint()..color = Colors.white.withOpacity(0.9);
    for (int i = 0; i < 4; i++) {
      double angle = (i * pi / 2);
      double sx = cx + cos(angle) * (size.width * 0.38);
      double sy = cy + sin(angle) * (size.height * 0.38);
      
      final starPath = Path()
        ..moveTo(sx, sy - 5)..lineTo(sx + 1.5, sy - 1.5)
        ..lineTo(sx + 5, sy)..lineTo(sx + 1.5, sy + 1.5)
        ..lineTo(sx, sy + 5)..lineTo(sx - 1.5, sy + 1.5)
        ..lineTo(sx - 5, sy)..lineTo(sx - 1.5, sy - 1.5)
        ..close();
      canvas.drawPath(starPath, starPaint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


extension _Level6CanvasTriangleExt on Canvas {
  void drawTriangle(Offset p1, Offset p2, Offset p3, Paint paint) {
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();
    drawPath(path, paint);
    
    // Контрастный чёрный контур на каждый зубчик для бритвенной чёткости
    drawPath(path, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 0.5);
  }
}

enum BossState { idle, windingUp, attacking, dizzy }
enum BossLimb { leftTentacle, rightTentacle, leftClaw, rightClaw }

class _SheriffBloodPoolPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bloodPaint = Paint()..color = const Color(0xFFB71C1C)..style = PaintingStyle.fill;
    final strokePaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.8;

    final path = Path();
    // ИСПРАВЛЕНО: Более широкое и массивное растекание по координатам
    path.moveTo(size.width * 0.05, size.height * 0.5);
    path.cubicTo(size.width * 0.15, size.height * 0.05, size.width * 0.45, size.height * 0.15, size.width * 0.65, size.height * 0.35);
    path.cubicTo(size.width * 0.85, size.height * 0.05, size.width * 0.98, size.height * 0.55, size.width * 0.75, size.height * 0.85);
    path.cubicTo(size.width * 0.55, size.height * 1.05, size.width * 0.25, size.height * 0.95, size.width * 0.05, size.height * 0.5);
    path.close();

    canvas.drawPath(path, bloodPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


