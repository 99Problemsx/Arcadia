#===============================================================================
# NTC_LPC
# New Trainer Card & League PC
#===============================================================================
# League PC code
#===============================================================================
def pbLeaguePC
  pbMessage(_INTL("\\se[PC open]{1} booted up the PC.", $player.name))
  pbMessage(_INTL("Hello {1}!", $player.registered? ? $player.name : "guest"))
  # Get all commands
  command_list = []
  commands = []
  MenuHandlers.each_available(:pc_league) do |option, hash, name|
    command_list.push(name)
    commands.push(hash)
  end
  # Main loop
  command = 0
  loop do
    choice = pbMessage(_INTL("What should I do?"), command_list, -1, nil, command)
    if choice < 0
      pbPlayCloseMenuSE
      break
    end
    break if commands[choice]["effect"].call
  end
  pbSEPlay("PC close")
end

#===============================================================================
#
#===============================================================================
MenuHandlers.add(:pc_league, :registering, {
  "name"      => proc { next _INTL("Registering")},
  "order"     => 10,
  "condition" => proc { !$player.registered? || TrainerCard_Config::SHOW_REGISTER_AFTER },
  "effect"    => proc { |menu|
    if $player.registered?
      pbMessage(_INTL("You are already registered to the Pokemon League."))
    else
      $player.expertise.upgradeExpertise
      pbMessage(_INTL("\\se[PC access]You registered to the Pokemon League."))
      if PluginManager.installed?("BadgeCase")
        pbMessage(_INTL("\\se[Item get]You obtained a badgecase."))
      end
    end
    next true
  }
})

MenuHandlers.add(:pc_league, :checking_status, {
  "name"      => proc { next _INTL("Checking status")},
  "order"     => 20,
  "condition" => proc { $player.registered? || TrainerCard_Config::SHOW_OPTIONS_UNREGISTERED },
  "effect"    => proc { |menu|
    if !$player.registered?
      pbMessage(_INTL("\\se[PC access]Your trainer ID not found, please register."))
    else
      pbMessage(_INTL("\\se[PC access]You obtained {1} Badges.\nYour rank is {2} Trainer.", $player.badge_count,$player.expertise.trainer_level.capitalize))
      pbMessage(_INTL("You can upgrade your rank.")) if $player.expertise.checkForUpgrade
    end
    next false
  }
})

MenuHandlers.add(:pc_league, :upgrade_rank, {
  "name"      => proc { next _INTL("Upgrade Rank")},
  "order"     => 30,
  "condition" => proc { $player.registered? || TrainerCard_Config::SHOW_OPTIONS_UNREGISTERED },
  "effect"    => proc { |menu|
    if !$player.registered?
      pbMessage(_INTL("\\se[PC access]Your trainer ID not found, please register."))
    else
      pbMessage(_INTL("Checking for upgrades..."))
      if $player.expertise.checkForUpgrade
        $player.expertise.upgradeExpertise
        pbMessage(_INTL("Your trainer rank upgraded."))
      else
        pbMessage(_INTL("You can't upgrade your rank right now."))
      end
    end
    next false
  }
})

MenuHandlers.add(:pc_league, :getting_badge, {
  "name"      => proc { next _INTL("Getting Badge")},
  "order"     => 40,
  "condition" => proc { $DEBUG && TrainerCard_Config::DEBUG_GET_BADGE && ($player.registered? || TrainerCard_Config::SHOW_OPTIONS_UNREGISTERED)},
  "effect"    => proc { |menu|
    if PluginManager.installed?("BadgeCase")
      if $PokemonGlobal.badges.unobtained_badges.length > 0
        pbGetBadge($PokemonGlobal.badges.unobtained_badges.sample)
      else
        pbMessage(_INTL("You already have all badges."))
      end
    else
      for i in 0...$player.badges.length
        if !$player.badges[i]
          $player.badges[i] = true
          break
        end
      end
    end
    next false
  }
})

MenuHandlers.add(:pc_league, :close, {
  "name"      => _INTL("Log off"),
  "order"     => 100,
  "effect"    => proc { |menu|
    next true
  }
})