#===============================================================================
# * Language Option Overwrite
#===============================================================================

class Window_PokemonOption < Window_DrawableCommand
  def itemCount
    if PluginManager.installed?("Set the Controls Screen") && LangConfig::CONTROLS_IN_OPTIONS == true
      return @options.length + 3
    else
      return @options.length + 2
    end
  end

  def drawItem(index, _count, rect)
    rect = drawCursor(index, rect)
    sel_index = self.index
    # Draw option's name
    if PluginManager.installed?("Set the Controls Screen") && LangConfig::CONTROLS_IN_OPTIONS == true
      optionname = case index
      when @options.length+2; _INTL("Close")
      when @options.length+1; _INTL("Controls")
      when @options.length;   _INTL("Language")
      else; @options[index].name
      end
    else
      optionname = case index
      when @options.length+1; _INTL("Close")
      when @options.length;   _INTL("Language")
      else; @options[index].name
      end
    end
    optionwidth = rect.width * 9 / 20
    pbDrawShadowText(self.contents, rect.x, rect.y, optionwidth, rect.height, optionname,
                     (index == sel_index) ? SEL_NAME_BASE_COLOR : self.baseColor,
                     (index == sel_index) ? SEL_NAME_SHADOW_COLOR : self.shadowColor)
    if PluginManager.installed?("Set the Controls Screen") && LangConfig::CONTROLS_IN_OPTIONS == true
      return if index >= @options.length
    else
      return if index >= @options.length
    end
    # Draw option's values
    case @options[index]
    when EnumOption
      if @options[index].values.length > 1
        totalwidth = 0
        @options[index].values.each do |value|
          totalwidth += self.contents.text_size(value).width
        end
        spacing = (rect.width - rect.x - optionwidth - totalwidth) / (@options[index].values.length - 1)
        spacing = 0 if spacing < 0
        xpos = optionwidth + rect.x
        ivalue = 0
        @options[index].values.each do |value|
          pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value,
                           (ivalue == self[index]) ? SEL_VALUE_BASE_COLOR : self.baseColor,
                           (ivalue == self[index]) ? SEL_VALUE_SHADOW_COLOR : self.shadowColor)
          xpos += self.contents.text_size(value).width
          xpos += spacing
          ivalue += 1
        end
      else
        pbDrawShadowText(self.contents, rect.x + optionwidth, rect.y, optionwidth, rect.height,
                         optionname, self.baseColor, self.shadowColor)
      end
    when NumberOption
      value = _INTL("Type {1}/{2}", @options[index].lowest_value + self[index],
                    @options[index].highest_value - @options[index].lowest_value + 1)
      xpos = optionwidth + (rect.x * 2)
      pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value,
                       SEL_VALUE_BASE_COLOR, SEL_VALUE_SHADOW_COLOR, 1)
    when SliderOption
      value = sprintf(" %d", @options[index].highest_value)
      sliderlength = rect.width - rect.x - optionwidth - self.contents.text_size(value).width
      xpos = optionwidth + rect.x
      self.contents.fill_rect(xpos, rect.y - 2 + (rect.height / 2), sliderlength, 4, self.baseColor)
      self.contents.fill_rect(
        xpos + ((sliderlength - 8) * (@options[index].lowest_value + self[index]) / @options[index].highest_value),
        rect.y - 8 + (rect.height / 2),
        8, 16, SEL_VALUE_BASE_COLOR
      )
      value = (@options[index].lowest_value + self[index]).to_s
      xpos += (rect.width - rect.x - optionwidth) - self.contents.text_size(value).width
      pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value,
                       SEL_VALUE_BASE_COLOR, SEL_VALUE_SHADOW_COLOR)
    else
      value = @options[index].values[self[index]]
      xpos = optionwidth + rect.x
      pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value,
                       SEL_VALUE_BASE_COLOR, SEL_VALUE_SHADOW_COLOR)
    end
  end
end

class PokemonOption_Scene
  def pbChangeSelection
    hash = @hashes[@sprites["option"].index]
    # Call selected option's "on_select" proc (if defined)
    @sprites["textbox"].letterbyletter = false
    hash["on_select"]&.call(self) if hash
    # Set descriptive text
    description = ""
    if hash
      if hash["description"].is_a?(Proc)
        description = hash["description"].call
      elsif !hash["description"].nil?
        description = _INTL(hash["description"])
      end
    else
      if PluginManager.installed?("Set the Controls Screen") && LangConfig::CONTROLS_IN_OPTIONS == true
        if @sprites["option"].index==@options.length
          description = _INTL("Set the Language.")
        elsif @sprites["option"].index==@options.length + 1
          description = _INTL("Set the Controls.")
        else  
          description = _INTL("Close the screen.")
        end
      else
        if @sprites["option"].index==@options.length
          description = _INTL("Set the Language.")
        else  
          description = _INTL("Close the screen.")
        end
      end
    end
    @sprites["textbox"].text = description
    @sprites["textbox"].setSkin(MessageConfig.pbGetSpeechFrame)
  end

  def pbOptions
    pbActivateWindow(@sprites, "option") {
      index = -1
      loop do
        Graphics.update
        Input.update
        pbUpdate
        if @sprites["option"].index != index
          pbChangeSelection
          index = @sprites["option"].index
        end
        @options[index].set(@sprites["option"][index], self) if @sprites["option"].value_changed
        if Input.trigger?(Input::BACK)
          break
        elsif Input.trigger?(Input::USE)
          if PluginManager.installed?("Set the Controls Screen") && LangConfig::CONTROLS_IN_OPTIONS == true
            break if @sprites["option"].index == @options.length+2
            open_set_controls_ui if @sprites["option"].index == @options.length+1
            pbLanguageScreen if @sprites["option"].index == @options.length
          else
            break if @sprites["option"].index == @options.length+1
            pbLanguageScreen if @sprites["option"].index == @options.length
          end
        end
      end
    }
  end
end