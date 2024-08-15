#===============================================================================
# * Difficulty Modes - by FL (Credits will be appreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It allows an easy way to make difficulty
# modes like the ones on Key System in B2W2.
#
# A difficulty mode may change:
# - Wild Pokémon levels
# - Trainer's Pokémon levels
# - Trainer's skill level
# - Trainer's money given
# - Trainer definition (define a different trainer entry in trainers.txt)
# - Exp received
#
#=== INSTALLATION ==============================================================
#
# To use this script as a plugin, place it in a folder named `DifficultyModesPlugin`
# within the `Plugins` folder of your Pokémon Essentials project.
#
#=== HOW TO USE ================================================================
#
# Change the variable number in "VARIABLE" to the variable index used to keep the 
# difficulty mode index.
#
# There are already three difficulties defined: Example Mode, Easy Mode, and Hard
# Mode. You can define more in 'def self.current_mode', see the instructions in
# this method.
#===============================================================================

if !PluginManager.installed?("Difficulty Modes")
  PluginManager.register({                                                 
    :name    => "Difficulty Modes",                                        
    :version => "1.1.1",                                                     
    :link    => "https://www.pokecommunity.com/showthread.php?t=300975",             
    :credits => "FL"
  })
end

module DifficultyModes
  # Number of variable that controls the difficulty.
  # To use a different variable, change this. 0 deactivates this script.
  VARIABLE=90 
  
  def self.current_mode
    return nil if DifficultyModes::VARIABLE<=0 
    difficulty_hash={}
    
    example_mode = Difficulty.new
    
    # A formula to change all wild Pokémon levels. 
    # IN THIS EXAMPLE: Every wild Pokémon has the level*1.2 (round down). 
    example_mode.wild_level_proc = proc{|pokemon|
      next pokemon.level*1.2
    }
    
    # A formula to change all trainer's Pokémon levels. 
    # IN THIS EXAMPLE: Every opponent Pokémon has the level*0.9 (round down). 
    example_mode.trainer_level_proc = proc{|pokemon,trainer|
      next pokemon.level*0.9
    }
    
    # A formula to change all trainers' skill levels.
    # IN THIS EXAMPLE: All trainers always have a low skill level (1).
    example_mode.skill_proc = proc{|skill_level,trainer|
      next 1
    }
    
    # A formula to change all trainers' base money.
    # IN THIS EXAMPLE: Multiply the money given by the opponent by 1.3 (round down).
    example_mode.money_proc = proc{|money,trainer|
      next money*1.3
    }
    
    # A formula to change exp gained.
    # IN THIS EXAMPLE: Multiply exp received by 1.2.
    example_mode.exp_proc = proc{|exp,receiver_battler|
      next exp*1.2
    }
    
    # Party ID number for trainers that can have another party.
    example_mode.id_jump = 100
    
    # The Hash index is the value that, when present in the VARIABLE number value,
    # the difficulty will be ON.
    difficulty_hash[1] = example_mode
    
    easy_mode = Difficulty.new
    easy_mode.id_jump = 200
    easy_mode.trainer_level_proc = proc{|pokemon,trainer|
      next pokemon.level*0.8
    }
    easy_mode.skill_proc = proc{|skill_level,trainer|
      next 1
    }
    easy_mode.money_proc = proc{|money,trainer|
      next money*1.5
    }
    difficulty_hash[2] = easy_mode
    
    hard_mode = Difficulty.new
    hard_mode.id_jump = 300
    hard_mode.trainer_level_proc = proc{|pokemon,trainer|
      next pokemon.level*1.2 + 1
    }
    hard_mode.skill_proc = proc{|skill_level,trainer|
      next 100
    }
    difficulty_hash[3] = hard_mode
    
    # Add new modes HERE

    return difficulty_hash[pbGet(DifficultyModes::VARIABLE)]
  end 
  
  def self.apply_wild_level_proc(pokemon)
    return pokemon.level if !current_mode || !current_mode.wild_level_proc
    return [[
      current_mode.wild_level_proc.call(pokemon).floor,
      GameData::GrowthRate.max_level
    ].min,1].max
  end
  
  def self.apply_trainer_level_proc(pokemon,trainer)
    return pokemon.level if !current_mode || !current_mode.trainer_level_proc
    return [[
      current_mode.trainer_level_proc.call(pokemon,trainer).floor,
      GameData::GrowthRate.max_level
    ].min,1].max
  end
  
  def self.apply_skill_proc(skill,trainer)
    return skill if !current_mode || !current_mode.skill_proc
    return [current_mode.skill_proc.call(skill,trainer).floor,0].max
  end
  
  def self.apply_money_proc(money,trainer)
    return money if !current_mode || !current_mode.money_proc
    return [current_mode.money_proc.call(money,trainer).floor,0].max
  end
  
  def self.apply_exp_proc(exp,receiver_battler)
    return exp if !current_mode || !current_mode.exp_proc
    return [current_mode.exp_proc.call(exp,receiver_battler).floor,0].max
  end
    
  private
  class Difficulty
    attr_accessor :wild_level_proc
    attr_accessor :trainer_level_proc
    attr_accessor :skill_proc
    attr_accessor :money_proc
    attr_accessor :exp_proc
    attr_accessor :id_jump
    
    def initialize
      @id_jump = 0
    end  
  end  
end

alias :_pbLoadTrainer_FL_dif :pbLoadTrainer
def pbLoadTrainer(tr_type, tr_name, tr_id = 0)
  if DifficultyModes.current_mode && DifficultyModes.current_mode.id_jump != 0
    ret = _pbLoadTrainer_FL_dif(
      tr_type, tr_name, DifficultyModes.current_mode.id_jump + tr_id
    )
  end
  if !ret
    ret = _pbLoadTrainer_FL_dif(tr_type, tr_name, tr_id)
    return ret if !ret 
    if DifficultyModes.current_mode
      for pkmn in ret.party
        pkmn.level = DifficultyModes.apply_trainer_level_proc(pkmn,self)
        pkmn.calc_stats
      end
    end
  end
  return ret
end

class Trainer
  alias :_base_money_FL_dif :base_money
  def base_money
    return DifficultyModes.apply_money_proc(_base_money_FL_dif,self)
  end

  alias :_skill_level_FL_dif :skill_level
  def skill_level
    return DifficultyModes.apply_skill_proc(_skill_level_FL_dif,self)
  end
end

class Battle
  module ItemEffects
    class << self
      # Essentials v19- compatibility
      def triggerExpGainModifier(item,battler,exp)
        BattleHandlers.triggerExpGainModifierItem(item,battler,exp)
      end unless method_defined?(:triggerExpGainModifier)

      alias :_triggerExpGainModifier_FL_dif :triggerExpGainModifier
      def triggerExpGainModifierItem(item,battler,exp)
        ret = _triggerExpGainModifier_FL_dif(item,battler,exp)
        if DifficultyModes.current_mode
          ret = DifficultyModes.apply_exp_proc(ret>0 ? ret : exp,battler)
        end
        return ret
      end
    end
  end
end

# Essentials v19- compatibility
if defined?(Events) && Events.respond_to?(:onWildPokemonCreate) 
  Events.onWildPokemonCreate+=proc {|sender,e|
    pkmn = e[0]
    pkmn.level = DifficultyModes.apply_wild_level_proc(pkmn)
    pkmn.calc_stats
  }
else
  EventHandlers.add(:on_wild_pokemon_created, :difficulty_mode,
    proc { |pkmn|
      pkmn.level = DifficultyModes.apply_wild_level_proc(pkmn)
      pkmn.calc_stats
    }
  )
end
