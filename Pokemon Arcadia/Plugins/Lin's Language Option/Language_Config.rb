#===============================================================================
# * Language Settings
#===============================================================================

module LangConfig
  # Change the color of the "Language" text. Change only the numbers to change the colors
  TITLE_BASE = Color.new(80, 80, 88)	  # Default: 248, 248, 248 (with background) or 80, 80, 88 (without background)
  TITLE_SHADOW = Color.new(160, 160, 168) # Default: 0, 0, 0 (with background) or 160, 160, 168 (without background)

  # Change the color of the options text. Change only the numbers to change the colors
  TEXT_BASE = Color.new(80, 80, 88)	  # Default: 248, 248, 248 (with background) or 80, 80, 88 (without background)
  TEXT_SHADOW = Color.new(160, 160, 168) # Default: 0, 0, 0 (with background) or 160, 160, 168 (without background)

  # Change the position of the "Language" text
  TITLE_X = 0		# Default: 0
  TITLE_Y = 0		# Default: -10 (with background) or 0 (without background)

  # Change the position of the options
  # It only changes the position of the text window so no individual positioning of the options
  OPTIONS_X = 0		# Default: 0
  OPTIONS_Y = 10	# Default: -16 (with background) or 10 (without background)

  # Set to true to use a background. False will use the window boxes.
  USE_BACKGROUND = false

  # Set to true to have acces to the Controls Screen from the Options Screen.
  # If you have my Options Screen plugin installed, it will use the configuration you set there for this option.
  # Will not work if the plugin isn't installed.
  condition = PluginManager.installed?("Lin's HGSS Options Screen")
  CONTROLS_IN_OPTIONS = (condition) ? OptionsConfig::CONTROLS_IN_OPTIONS : false
end