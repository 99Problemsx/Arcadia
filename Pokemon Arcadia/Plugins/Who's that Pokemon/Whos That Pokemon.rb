class WTP_Scene
	# initialize starting values
  def initialize
	$player.current_wtp_pkmn ||= nil
	$stats.wtp_correct_count ||= 0
  end
  
  # Sets the Scene
  def pbStartScene
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/whosthatpokemon")
    @sprites["icon"]=PokemonSprite.new(@viewport)
    @sprites["icon"].x = 145
    @sprites["icon"].y = Graphics.height-210
    pbDeactivateWindows(@sprites)
	initialize if $player.current_wtp_pkmn.nil?
    pbRefresh
    Graphics.frame_reset
	pbFadeInAndShow(@sprites) { pbUpdate }
    choosePokemon
  end
  
  def pbRefresh
    pbUpdateSpriteHash(@sprites)
  end
  
  def choosePokemon
    list = []
	chosenPokemon ||= nil
	timer = checkTime
	ret = nil
	if timer == 1
	  $player.current_wtp_pkmn = nil
	end
	# Randomly selects a Pokemon to display
	if $player.current_wtp_pkmn.nil?
	  GameData::Species.each do |pkmn|
		list.push(pkmn)
	  end
	  chosenPokemon = list.sample
	  $player.current_wtp_pkmn = chosenPokemon
	else
	  chosenPokemon = $player.current_wtp_pkmn
	end

    # Displays Pokemon as a silhouette
    @sprites["icon"].setSpeciesBitmap(chosenPokemon.species, 0, 0, false)
    @sprites["icon"].tone = Tone.new(-255, -255, -255, 255)
    @sprites["icon"].visible = true
  
	#puts "select_pkmn:#{chosenPokemon.species}"
  
  # Handles cases with entered text
    loop do
      enteredPkmn = pbWTFText("Who's that Pokemon?", "", 140,Graphics.width)
      if enteredPkmn
        if enteredPkmn.downcase.strip == chosenPokemon.species.to_s.downcase.strip
          pbMessage(_INTL("Correct!"))
          pbMessage(_INTL("It's {1}!", GameData::Species.get(chosenPokemon).name))
          $player.current_wtp_pkmn = nil
          $stats.wtp_correct_count += 1
		  ret = pbConfirmMessage(_INTL("Would you like to play again?"))
          break
        else
          pbMessage(_INTL("Please try again."))
        end
      else
        pbMessage(_INTL("Come back if you change your mind."))
        break
      end
    end
	pbEndScene
	if ret
	  wtpMiniGame
	end
  end
 
   def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end
  
  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def checkTime
    $player.current_wtp_timer ||= 0
    current_time = Time.now.to_i
	
    if current_time - $player.current_wtp_timer >= 24 * 60 * 60  || $player.current_wtp_timer == 0# 24 hours in seconds
      $player.current_wtp_timer = current_time
      return 1
    else
      return 0
    end
  end
  
      # Modified text entry
  def pbWTFText(text, initialtext, maxlength, width = 70)
	window = Window_TextEntry_Keyboard.new(initialtext, 0, 0, 400, 96, text, true)
    ret = ""
    window.maxlength = maxlength
    window.visible = true
    window.z = 99999
    window.text = initialtext
	
	@helper = CharacterEntryHelper.new(text)
	
    Input.text_input = true
    loop do
      Graphics.update
      Input.update
      if Input.triggerex?(:ESCAPE)
        ret = nil
        break
      elsif Input.triggerex?(:RETURN)
        ret = window.text
        break
      end
      window.update
      yield if block_given?
    end
    Input.text_input = false
    window.dispose
    Input.update
    return ret
  end
  
    #Delete
	def text
    @helper.text
  end
    def text=(value)
    @helper.text = value
    self.refresh
  end
end

  def wtpMiniGame
    wtp_scene = WTP_Scene.new
    wtp_scene.pbStartScene
  end
  
  
  # Added Game Stats to keep a count of times correctly guessed
  class GameStats
    attr_accessor :wtp_correct_count
  end
  
  # Stored variables for currently selected pokemon and a reset timer
  #		Variables here will be stored through re-loads
  class Player
    attr_accessor :current_wtp_pkmn
    attr_accessor :current_wtp_timer
  end