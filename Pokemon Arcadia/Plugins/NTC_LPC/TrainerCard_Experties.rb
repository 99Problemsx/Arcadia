#===============================================================================
# NTC_LPC
# New Trainer Card & League PC
#===============================================================================
# Those are the ranks, each rank should contain:
# ID - The rank ID should match it's sprite on Pictures/New Trainer Card
# TITLE - The rank name as it should be displayed
# REQUIREMENTS - The requirements for reaching this level (probably badge_count)
# ORDER - It's order (low to high)
# INFO - What should be displayed on the trainer card of this rank
#===============================================================================
# INFO GUIDE:
#
# [:INFO, X position, Y position, (Distance between title and data)]
#
# :TITLE - Rank title
# :PICTURE - Player picture
# :NAME - Player name
# :ID - Player ID number (need a distance value)
# :MONEY - Player money (need a distance value)
# :POKEDEX - Pokedex seen/Pokedex owned (need a distance value)
# :TIME - Time played (need a distance value)
# :STARTED - Time started playing (need a distance value)
# :BADGES - Badges obtained/All badges (need a distance value)
# :BATTLES - Wild battles won/All wild battles (need a distance value)
# :TRAINERS - Trainers battles won/All trainers battles (need a distance value)
#===============================================================================
module TrainerCard_Expertises
  NOVICE = {
    :ID => "NOVICE",
    :TITLE => "Novice",
    :ORDER => 0,
    :INFO => [
      [:PICTURE,400,210],
      [:NAME,34,104,268],
      [:ID,332,104,136],
      [:MONEY,34,152,268],
      [:TIME,34,200,268],
      [:STARTED,34,248,268]
    ]
  }

  ROOKIE = {
    :ID => "ROOKIE",
    :TITLE => "Rookie",
    :ORDER => 1,
    :INFO => [
      [:PICTURE,400,206],
      [:TITLE,148,64],
      [:NAME,34,100,268],
      [:ID,332,100,136],
      [:MONEY,34,148,268],
      [:POKEDEX,34,196,268],
      [:TIME,34,244,268],
      [:STARTED,34,292,268]
    ]
  }

  BEGINNER = {
    :ID => "BEGINNER",
    :TITLE => "Beginner",
    :REQUIREMENTS => proc {$player.badge_count > 0},
    :ORDER => 2,
    :INFO => [
      [:PICTURE,400,182],
      [:TITLE,256,40],
      [:NAME,34,76,268],
      [:ID,332,76,136],
      [:MONEY,34,124,268],
      [:POKEDEX,34,172,268],
      [:TIME,34,220,268],
      [:STARTED,34,268,268],
      [:BADGES,34,316,268]
    ]
  }

  INTERMEDIATE = {
    :ID => "INTERMEDIATE",
    :TITLE => "Intermediate",
    :REQUIREMENTS => proc {$player.badge_count > 1},
    :ORDER => 3,
    :INFO => [
      [:PICTURE,388,182],
      [:TITLE,256,32],
      [:NAME,74,72,210],
      [:ID,280,90,200],
      [:MONEY,46,238,210],
      [:POKEDEX,46,268,210],
      [:TIME,46,298,210],
      [:STARTED,46,328,210],
      [:BADGES,290,268,176],
      [:BATTLES,290,298,176],
      [:TRAINERS,290,328,176]
    ]
  }

  EXPERIENCED = {
    :ID => "EXPERIENCED",
    :TITLE => "Experienced",
    :REQUIREMENTS => proc {$player.badge_count > 2},
    :ORDER => 4,
    :INFO => [
      [:PICTURE,388,182],
      [:TITLE,256,32],
      [:NAME,74,72,210],
      [:ID,280,90,200],
      [:MONEY,46,238,210],
      [:POKEDEX,46,268,210],
      [:TIME,46,298,210],
      [:STARTED,46,328,210],
      [:BADGES,290,268,176],
      [:BATTLES,290,298,176],
      [:TRAINERS,290,328,176]
    ]
  }

  EXPERT = {
    :ID => "EXPERT",
    :TITLE => "Expert",
    :REQUIREMENTS => proc {$player.badge_count > 3},
    :ORDER => 5,
    :INFO => [
      [:PICTURE,388,182],
      [:TITLE,256,32],
      [:NAME,74,72,210],
      [:ID,280,90,200],
      [:MONEY,46,238,210],
      [:POKEDEX,46,268,210],
      [:TIME,46,298,210],
      [:STARTED,46,328,210],
      [:BADGES,290,268,176],
      [:BATTLES,290,298,176],
      [:TRAINERS,290,328,176]
    ]
  }

  MASTER = {
    :ID => "MASTER",
    :TITLE => "Master",
    :REQUIREMENTS => proc {$player.badge_count > 4},
    :ORDER => 6,
    :INFO => [
      [:PICTURE,388,182],
      [:TITLE,256,32],
      [:NAME,74,72,210],
      [:ID,280,90,200],
      [:MONEY,46,238,210],
      [:POKEDEX,46,268,210],
      [:TIME,46,298,210],
      [:STARTED,46,328,210],
      [:BADGES,290,268,176],
      [:BATTLES,290,298,176],
      [:TRAINERS,290,328,176]
    ]
  }

  LEGENDARY = {
    :ID => "LEGENDARY",
    :TITLE => "Legendary",
    :REQUIREMENTS => proc {$game_switches[12]}, # Won Pokemon league switch (Pokemon Champion)
    :ORDER => 7,
    :INFO => [
      [:PICTURE,388,182],
      [:TITLE,256,32],
      [:NAME,74,72,210],
      [:ID,280,90,200],
      [:MONEY,46,238,210],
      [:POKEDEX,46,268,210],
      [:TIME,46,298,210],
      [:STARTED,46,328,210],
      [:BADGES,290,268,176],
      [:BATTLES,290,298,176],
      [:TRAINERS,290,328,176]
    ]
  }
end