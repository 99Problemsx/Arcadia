#===============================================================================
# * WildPokemon Modify
#===============================================================================

# Activates script when a wild pokemon is created
EventHandlers.add(:on_wild_pokemon_created, :charm_modify,
  proc { |pkmn|
    pbMaxIV(pkmn) if $player.activeCharm?(:GENECHARM)
    pbHiddenAbility(pkmn) if $player.activeCharm?(:HIDDENCHARM)
    pbEggMove(pkmn) if $player.activeCharm?(:HERITAGECHARM)
    pkmn.calc_stats
  }
)