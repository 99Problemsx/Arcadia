#===============================================================================
# NTC_LPC
# New Trainer Card & League PC
#===============================================================================
# Main code for the backend of this plugin
#===============================================================================
class Expertises
  attr_accessor :expertises
  attr_accessor :trainer_level

  def initialize
    @expertises    = []
    constants = TrainerCard_Expertises.constants.sort_by { |expertise| TrainerCard_Expertises.const_get(expertise)[:ORDER] }
    for i in 0...constants.length
      @expertises.push(constants[i].to_s)
    end
    @trainer_level = @expertises[0]
  end

  def upgradeExpertise
    return if @expertises[-1] == @trainer_level
    last_index = @expertises.find_index(@trainer_level)
    @trainer_level = @expertises[last_index + 1]
  end

  def checkForUpgrade
    return false if @expertises[-1] == @trainer_level
    last_index = @expertises.find_index(@trainer_level)
    requirements = TrainerCard_Expertises.const_get(@expertises[last_index+1])[:REQUIREMENTS]
    return true if !requirements
    return requirements.call
  end
end

#===============================================================================
#
#===============================================================================
class Player < Trainer
  def expertise
    @expertise = Expertises.new if !@expertise
    return @expertise
  end

  alias expertise_init initialize
  def initialize(name, trainer_type)
    expertise_init(name, trainer_type)
    @expertise = Expertises.new
  end

  def badge_max
    return $player.badges.length
  end

  def registered?
    return (TrainerCard_Config::UNREGISTERED_RANK != expertise.trainer_level)
  end

  def get_rank
    return @expertise.trainer_level
  end
end
#===============================================================================
#
#===============================================================================