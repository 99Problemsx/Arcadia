#===============================================================================
# * Language Options Screen - by LinKazamine (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It adds a language selection screen to the options menu.
#
#== INSTALLATION ===============================================================
#
# Drop the folder in your Plugin's folder.
#
#===============================================================================

class LanguageOption_Scene # The scene class
  def pbStartScene
    # Initialize the sprite hash where all sprites are. This is used to easily
    # do things like update all sprites in pbUpdateSpriteHash.
    @sprites = {} 
    # Creates a Viewport (works similar to a camera) with z=99999, so player can
    # see all sprites with z below 99999. The higher z sprites are above the
    # lower ones.
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    # Creates a new IconSprite object and sets its bitmap to image_path
    addBackgroundOrColoredPlane(@sprites, "bg", "langbg", Color.new(192, 200, 208), @viewport)
    # Creates the window for the title.
    titleX = LangConfig::TITLE_X
    titleY = LangConfig::TITLE_Y
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Language"), titleX, titleY, Graphics.width, 64, @viewport
    )
    @sprites["title"].back_opacity = 0 if LangConfig::USE_BACKGROUND
    @sprites["title"].baseColor   = LangConfig::TITLE_BASE
    @sprites["title"].shadowColor = LangConfig::TITLE_SHADOW
    # Creates the window for the commands.
    @sprites["cmdwindow"] = Window_CommandPokemon.new([])
    @sprites["cmdwindow"].visible = false
    @sprites["cmdwindow"].viewport = @viewport
    # After everything is set, show the sprites with FadeIn effect.
    pbFadeInAndShow(@sprites) { update }
  end

  def pbMain
    ret = -1
    commands = []
    Settings::LANGUAGES.each do |lang|
      commands.push(lang[0])
    end
    # This variable was made just to calls 'overlay' insteady of
    # '@sprites["overlay"].bitmap'.
    cmdwindow = @sprites["cmdwindow"]
    cmdwindow.commands = commands
    cmdwindow.index    = $game_temp.menu_last_choice
#    cmdwindow.resizeToFit(commands)
    cmdwindow.width    = Graphics.width
    if LangConfig::USE_BACKGROUND
      cmdwindow.height   = Graphics.height - (-16 + 64 - 16)
    else
      cmdwindow.height   = Graphics.height - (-16 + 64 - 16) - 26
    end
    cmdwindow.x        = LangConfig::OPTIONS_X
      cmdwindow.y        = -16 + 64 + LangConfig::OPTIONS_Y
    cmdwindow.baseColor   = LangConfig::TEXT_BASE
    cmdwindow.shadowColor = LangConfig::TEXT_SHADOW
    cmdwindow.visible  = true 
    cmdwindow.back_opacity  = 0 if LangConfig::USE_BACKGROUND
    # Loop called once per frame.
    loop do
      # Updates the graphics.
      Graphics.update
      # Updates the button/key input check.
      Input.update
      # Calls the update method on this class (look at 'def update' in
      # this class).
      self.update
      # If button C or button B (trigger by keys C and X) is pressed, then
      # exits from loop and from pbMain (since the method contains only the
      # loop), starts pbEndScene (look at 'def pbStartScreen').
      if Input.trigger?(Input::BACK) || Input.trigger?(Input::ACTION)
        # To play the Cancel SE (defined in database) when the diploma is
        # canceled, then uncomment the below line.
        #pbPlayCancelSE
        ret = -1
        break
      # If you wish to switch between two texts when the C button is 
      # pressed (with a method like draw_text_2), then deletes the 
      # '|| Input.trigger?(Input::C)'. Before the 'loop do' put 'actual_text=1',
      # then use something like:      
      elsif Input.trigger?(Input::USE)
        ret = cmdwindow.index
        $game_temp.menu_last_choice = ret
        break
      end
    end
    return ret
  end

  # Called every frame.
  def update
    # Updates all sprites in @sprites variable.
    pbUpdateSpriteHash(@sprites)
  end

  def pbEndScene
    pbPlayCloseMenuSE
    # Hide all sprites with FadeOut effect.
    pbFadeOutAndHide(@sprites) { update }
    # Remove all sprites.
    pbDisposeSpriteHash(@sprites)
    # Remove the viewpoint.
    @viewport.dispose
  end
end

class LanguageOptionScreen # The screen class
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    # Put the method order in scene. The pbMain have the scene main loop 
    # that only closes the scene when the loop breaks.
    @scene.pbStartScene
    # Loop called once per frame.
    loop do
      if Settings::LANGUAGES.length >= 2
        choice = @scene.pbMain
        if choice >= 0 && choice < Settings::LANGUAGES.length
          $PokemonSystem.language = choice
          MessageTypes.load_message_files(Settings::LANGUAGES[$PokemonSystem.language][1])
        else
          break
        end
      else
        pbMessage(_INTL("There's only one language."))
        break
      end
    end
    @scene.pbEndScene
  end
end

# A def for a quick script call. 
# If user doesn't put some parameter, then it uses default values.
def pbLanguageScreen
  # Displays a fade out before the scene starts, and a fade in after the scene
  # ends
  pbFadeOutIn(99999) {
    scene = LanguageOption_Scene.new
    screen = LanguageOptionScreen.new(scene)
    screen.pbStartScreen
  }
end