  #==============================================================================#
  #        Pokemon HGSS Save Script by Abdoulgaming for V20.X  and V21.X         #
  #==============================================================================#
  #                This script recreates the Save Screen from HGSS               #
  #==============================================================================# 
  #                     Please give Credit when using it                         #
  #==============================================================================#
  #                              Regular Configs                                 #
  #==============================================================================#
  MenuAnimation = true # For little fading when you open / close the save screen
  PokemonIcons = false # Shows you current Party in the Screen
  WaitTime = 0.05
  
  #==============================================================================#
  #                                Colors                                        #
  #==============================================================================#
  DATATEXT = Color.new(255, 255, 255)
  DATASHADOWTEXT = Color.new(173, 189, 189)
  LOCATIONTEXT = Color.new(239, 33, 16)
  LOCATIONSHADOWTEXT = Color.new(255, 173, 189)
  OTHERCOLOR = Color.new(0, 0, 0)
  OTHERSHADOWCOLOR = Color.new(173, 189, 189)
  #==============================================================================#
  #                           Script starts here                                 #
  #==============================================================================#
  class PokemonSave_Scene
    def wait_milliseconds(milliseconds)
      frames = (milliseconds * Graphics.frame_rate / 1000.0).to_i
      frames.times do
        Graphics.update
      end
    end
	
	def wait(seconds)
	  wait_milliseconds(seconds * 1000)
	end


    def pbStartScreen
      @sprites = {}
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 99999
      totalsec = Graphics.frame_count / Graphics.frame_rate
      hour = totalsec / 60 / 60
      min = totalsec / 60 % 60
      
      @sprites["background"] = Sprite.new(@viewport)
      @sprites["background"].bitmap = Bitmap.new("Graphics/Pictures/Save/savebg") if !PokemonIcons || $player.party_count == 0
	    @sprites["background"].bitmap = Bitmap.new("Graphics/Pictures/Save/savebgicons") if PokemonIcons && $player.party_count > 0
      @sprites["background"].opacity = 0
      @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      pbSetSystemFont(@sprites["overlay"].bitmap)
      @sprites["overlay"].opacity = 0
	
	if PokemonIcons
	  for i in 0...$player.party.length
	    @sprites["party#{i}"] = PokemonIconSprite.new($player.party[i],@viewport)
	    @sprites["party#{i}"].x = 84 + 112 / 2 *(i*1)
		  @sprites["party#{i}"].y = 176
		  @sprites["party#{i}"].z = 99999
	  end
  end

	  
      @textpos = []
      @textpos.push([_INTL("{1}", $game_map.name), Settings::SCREEN_WIDTH / 2, 38, 2, LOCATIONTEXT, LOCATIONSHADOWTEXT])
      @textpos.push([_INTL("PLAYER:"), 112, 70, 0, DATATEXT, DATASHADOWTEXT])
      @textpos.push([_INTL("{1}", $player.name), 412, 70, 1, OTHERCOLOR, OTHERSHADOWCOLOR])
      @textpos.push([_INTL("BADGES:"), 112, 102, 0, DATATEXT, DATASHADOWTEXT])
      @textpos.push([_INTL("{1}", $player.badge_count), 412, 102, 1, OTHERCOLOR, OTHERSHADOWCOLOR])
      if $player.has_pokedex
        @textpos.push([_INTL("POKéDEX:"), 112, 134, 0, DATATEXT, DATASHADOWTEXT])
        @textpos.push([_INTL("{1}", $player.pokedex.owned_count), 412, 134, 1, OTHERCOLOR, OTHERSHADOWCOLOR])
      end
      @textpos.push([_INTL("TIME:"), 112, 166, 0, DATATEXT, DATASHADOWTEXT])
      @textpos.push([_ISPRINTF("{1:02d}:{2:02d}", hour, min), 412, 166, 1, OTHERCOLOR, OTHERSHADOWCOLOR])
      pbDrawTextPositions(@sprites["overlay"].bitmap,@textpos)
      if MenuAnimation
        10.times do
          if PokemonIcons
            for i in 0...$player.party.length
              @sprites["party#{i}"].opacity += 25.5
            end
          end

          @sprites["background"].opacity += 25.5
          @sprites["overlay"].opacity += 25.5
		      wait(WaitTime)
        end
      else
        @sprites["background"].opacity = 255
        @sprites["overlay"].opacity = 255
      end
    end

	
    def pbEndScreen
      if MenuAnimation
        10.times do
          if PokemonIcons
            for i in 0...$player.party.length
             @sprites["party#{i}"].opacity -= 25.5
            end
          end

          @sprites["background"].opacity -= 25.5
          @sprites["overlay"].opacity -= 25.5
          wait(WaitTime)
        end
      else
        @sprites["background"].opacity = 0
        @sprites["overlay"].opacity = 0
      end
      pbDisposeSpriteHash(@sprites)
      @viewport.dispose
    end
  end

  #==============================================================================#
  #                            Default Save Function                             #
  #==============================================================================#

  class PokemonSaveScreen
    def initialize(scene)
      @scene = scene
    end
  
    def pbDisplay(text, brief = false)
      @scene.pbDisplay(text, brief)
    end
  
    def pbDisplayPaused(text)
      @scene.pbDisplayPaused(text)
    end
  
    def pbConfirm(text)
      return @scene.pbConfirm(text)
    end
  
    def pbSaveScreen
      ret = false
      @scene.pbStartScreen
      if pbConfirmMessage(_INTL("Would you like to save the game?"))
        if SaveData.exists? && $game_temp.begun_new_game
          pbMessage(_INTL("WARNING!"))
          pbMessage(_INTL("There is a different game file that is already saved."))
          pbMessage(_INTL("If you save now, the other file's adventure, including items and Pokémon, will be entirely lost."))
          if !pbConfirmMessageSerious(_INTL("Are you sure you want to save now and overwrite the other save file?"))
            pbSEPlay("GUI save choice")
            @scene.pbEndScreen
            return false
          end
        elsif SaveData.exists?
          pbSEPlay("GUI save choice")
          if !pbConfirmMessage(_INTL("There is already a saved file. \nIs it OK to overwrite it?"))
            pbSEPlay("GUI save choice")
            @scene.pbEndScreen
            return false
          end
        end
        $game_temp.begun_new_game = false
        pbSEPlay("GUI save choice")
        if Game.save
          pbMessage(_INTL("\\se[]{1} saved the game.\\me[GUI save game]\\wtnp[30]", $player.name))
          ret = true
        else
          pbMessage(_INTL("\\se[]Save failed.\\wtnp[30]"))
          ret = false
        end
      else
        pbSEPlay("GUI save choice")
      end
      @scene.pbEndScreen
      return ret
    end
  end
  
  #==============================================================================#
  #  Unnecessary things that can be removed as long you don't remove UI_Save     # 
  #                           In the Script Editor                               #
  #==============================================================================#
  
  def pbEmergencySave
    oldscene = $scene
    $scene = nil
    pbMessage(_INTL("The script is taking too long. The game will restart."))
    return if !$player
    if SaveData.exists?
      File.open(SaveData::FILE_PATH, "rb") do |r|
        File.open(SaveData::FILE_PATH + ".bak", "wb") do |w|
          loop do
            s = r.read(4096)
            break if !s
            w.write(s)
          end
        end
      end
    end
    if Game.save
      pbMessage(_INTL("\\se[]The game was saved.\\me[GUI save game] The previous save file has been backed up.\\wtnp[30]"))
    else
      pbMessage(_INTL("\\se[]Save failed.\\wtnp[30]"))
    end
    $scene = oldscene
  end
