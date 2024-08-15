#===============================================================================
# NTC_LPC
# New Trainer Card & League PC
#===============================================================================
# This script contains the UI code for the alternative trainer card
#===============================================================================
class PokemonTrainerCard_Scene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @trainer_level = $player.expertise.trainer_level
    @sprites = {}
    addBackgroundPlane(@sprites, "bg", "New Trainer Card/bg", @viewport)
    @sprites["card"] = IconSprite.new(0,0,@viewport)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["trainer"] = IconSprite.new(0,0,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbDrawTrainerCardFront
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbDrawTrainerCardFront
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    @sprites["card"].setBitmap("Graphics/Pictures/New Trainer Card/"+@trainer_level.to_s.upcase)
    @sprites["trainer"].setBitmap(GameData::TrainerType.player_front_sprite_filename($player.trainer_type))
    @sprites["trainer"].z = 2
    baseColor   = Color.new(72, 72, 72)
    shadowColor = Color.new(160, 160, 160)
    totalsec = $stats.play_time.to_i
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    time = (hour > 0) ? _INTL("{1}h {2}m", hour, min) : _INTL("{1}m", min)
    $PokemonGlobal.startTime = pbGetTimeNow if !$PokemonGlobal.startTime
    starttime = _INTL("{1} {2}, {3}",
                      pbGetAbbrevMonthName($PokemonGlobal.startTime.mon),
                      $PokemonGlobal.startTime.day,
                      $PokemonGlobal.startTime.year)
    infos = TrainerCard_Expertises.const_get(@trainer_level)[:INFO]
    textPositions = []
    for i in 0...infos.length
      info = infos[i]
      case info[0]
      when :TITLE
        textPositions.push([_INTL("{1} TRAINER",@trainer_level),info[1],info[2],2,baseColor,shadowColor])
      when :NAME
        textPositions.push([$player.name, info[1], info[2], 0, baseColor, shadowColor])
      when :ID
        textPositions.push([_INTL("ID No."), info[1], info[2], 0, baseColor, shadowColor])
        textPositions.push([sprintf("%05d", $player.public_ID), info[1]+info[3], info[2], 1, baseColor, shadowColor])
      when :MONEY
        textPositions.push([_INTL("Money"), info[1], info[2], 0, baseColor, shadowColor])
        textPositions.push([_INTL("${1}", $player.money.to_s_formatted), info[1]+info[3], info[2], 1, baseColor, shadowColor])
      when :POKEDEX
        textPositions.push([_INTL("Pokedex"), info[1], info[2], 0, baseColor, shadowColor])
        textPositions.push([sprintf("%d/%d", $player.pokedex.owned_count, $player.pokedex.seen_count), info[1]+info[3], info[2], 1, baseColor, shadowColor])
      when :TIME
        textPositions.push([_INTL("Time"), info[1], info[2], 0, baseColor, shadowColor])
        textPositions.push([time, info[1]+info[3], info[2], 1, baseColor, shadowColor])
      when :STARTED
        textPositions.push([_INTL("Start"), info[1], info[2], 0, baseColor, shadowColor])
        textPositions.push([starttime, info[1]+info[3], info[2], 1, baseColor, shadowColor])
      when :BADGES
        textPositions.push([_INTL("Badges"),info[1], info[2],0,baseColor,shadowColor])
        textPositions.push([sprintf("%d/%d",$player.badge_count,$player.badge_max),info[1]+info[3], info[2],1,baseColor,shadowColor])
      when :BATTLES
        textPositions.push([_INTL("Battles"),info[1], info[2],0,baseColor,shadowColor])
        textPositions.push([sprintf("%d/%d",$stats.wild_battles_won,($stats.wild_battles_won+$stats.wild_battles_lost)),info[1]+info[3], info[2],1,baseColor,shadowColor])
      when :TRAINERS
        textPositions.push([_INTL("Trainers"),info[1], info[2],0,baseColor,shadowColor])
        textPositions.push([sprintf("%d/%d",$stats.trainer_battles_won,($stats.trainer_battles_won+$stats.trainer_battles_lost)),info[1]+info[3], info[2],1,baseColor,shadowColor])
      when :HALL_OF_FAME
        hall_of_fame_sec = $stats.time_to_enter_hall_of_fame.to_i
        hall_of_fame_hour = hall_of_fame_sec / 60 / 60
        hall_of_fame_min = hall_of_fame_sec / 60 % 60
        hall_of_fame_time = (hall_of_fame_hour > 0) ? _INTL("{1}h {2}m", hall_of_fame_hour, hall_of_fame_min) : _INTL("{1}m", hall_of_fame_min)
        textPositions.push([_INTL("Hall of Fame"),info[1], info[2],0,baseColor,shadowColor])
        textPositions.push([hall_of_fame_time,info[1]+info[3], info[2],1,baseColor,shadowColor])
      when :TRADES
        textPositions.push([_INTL("Trades"),info[1], info[2],0,baseColor,shadowColor])
        textPositions.push([$stats.trade_count,info[1]+info[3], info[2],1,baseColor,shadowColor])
      when :BATTLE_POINTS
        textPositions.push([_INTL("Battle Points"), info[1], info[2], 0, baseColor, shadowColor])
        textPositions.push([$player.battle_points.to_s_formatted, info[1]+info[3], info[2], 1, baseColor, shadowColor])
      when :SHADOW_PURED
        textPositions.push([_INTL("Shadows Pured"), info[1], info[2], 0, baseColor, shadowColor])
        textPositions.push([$stats.shadow_pokemon_purified, info[1]+info[3], info[2], 1, baseColor, shadowColor])
      when :EVOLUTION
        textPositions.push([_INTL("Evolutions"), info[1], info[2], 0, baseColor, shadowColor])
        textPositions.push([$stats.evolution_count, info[1]+info[3], info[2], 1, baseColor, shadowColor])
      when :EGGS
        textPositions.push([_INTL("Eggs Hatched"), info[1], info[2], 0, baseColor, shadowColor])
        textPositions.push([$stats.eggs_hatched, info[1]+info[3], info[2], 1, baseColor, shadowColor])
      when :MEGA
        textPositions.push([_INTL("Mega Evolutions"), info[1], info[2], 0, baseColor, shadowColor])
        textPositions.push([$stats.mega_evolution_count, info[1]+info[3], info[2], 1, baseColor, shadowColor])
      when :WALK
        textPositions.push([_INTL("Walked"), info[1], info[2], 0, baseColor, shadowColor])
        textPositions.push([$stats.distance_walked, info[1]+info[3], info[2], 1, baseColor, shadowColor])
      when :CYCLE
        textPositions.push([_INTL("Cycled"), info[1], info[2], 0, baseColor, shadowColor])
        textPositions.push([$stats.distance_cycled, info[1]+info[3], info[2], 1, baseColor, shadowColor])
      when :SURF
        textPositions.push([_INTL("Surfed"), info[1], info[2], 0, baseColor, shadowColor])
        textPositions.push([$stats.distance_surfed, info[1]+info[3], info[2], 1, baseColor, shadowColor])
      when :ICE
        textPositions.push([_INTL("Slid on Ice"), info[1], info[2], 0, baseColor, shadowColor])
        textPositions.push([$stats.distance_slid_on_ice, info[1]+info[3], info[2], 1, baseColor, shadowColor])
      when :PICTURE
        @sprites["trainer"].x = info[1] - (@sprites["trainer"].bitmap.width / 2)
        @sprites["trainer"].y = info[2] - (@sprites["trainer"].bitmap.height / 2)
      end
    end
    pbDrawTextPositions(overlay, textPositions)
  end

  def pbTrainerCard
    pbSEPlay("GUI trainer card open")
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      end
    end
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
#
#===============================================================================
class PokemonTrainerCardScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbTrainerCard
    @scene.pbEndScene
  end
end