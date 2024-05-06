#-------------------------------------------------------------------------------
# Defining a new method for base Essentials followers to show dust animation
#-------------------------------------------------------------------------------
class Game_Follower
  def update_move
    was_jumping = jumping?
    super
    show_dust_animation if was_jumping && !jumping?
  end

  if !method_defined?(:show_dust_animation)
    def show_dust_animation
      spriteset = $scene.spriteset(map_id)
      spriteset&.addUserAnimation(Settings::DUST_ANIMATION_ID, self.x, self.y, true, 1)
    end
  end
end

#-------------------------------------------------------------------------------
# Defining a new class for Following Pokemon event which has several additions
# to make it more robust as a Following Pokemon
#-------------------------------------------------------------------------------
class Game_FollowingPkmn < Game_Follower
  #-----------------------------------------------------------------------------
  # Update pattern at a constant rate independent of move speed
  #-----------------------------------------------------------------------------
  def update_pattern
    return if @lock_pattern
    if @moved_last_frame && !@moved_this_frame && !@step_anime
      @pattern = @original_pattern
      @anime_count = 0
      return
    end
    if !@moved_last_frame && @moved_this_frame && !@step_anime
      @pattern = (@pattern + 1) % 4 if @walk_anime
      @anime_count = 0
      return
    end
    pattern_time = pattern_update_speed / 4   # 4 frames per cycle in a charset
    return if @anime_count < pattern_time
    # Advance to the next animation frame
    @pattern = (@pattern + 1) % 4
    @anime_count -= pattern_time
  end
  #-----------------------------------------------------------------------------
  # Don't turn off walk animation when sliding on ice if the following pokemon
  # is airborne.
  #-----------------------------------------------------------------------------
  alias __followingpkmn__walk_anime walk_anime= unless method_defined?(:__followingpkmn__walk_anime)
  def walk_anime=(value)
    return if $PokemonGlobal.ice_sliding && (!FollowingPkmn.active? || FollowingPkmn.airborne_follower?)
    __followingpkmn__walk_anime(value)
  end
  #-----------------------------------------------------------------------------
  # Don't reset walk animation when sliding on ice if the following pokemon is
  # airborne.
  #-----------------------------------------------------------------------------
  alias __followingpkmn__straighten straighten unless method_defined?(:__followingpkmn__straighten)
  def straighten
    return if $PokemonGlobal.ice_sliding && (!FollowingPkmn.active? || FollowingPkmn.airborne_follower?)
    __followingpkmn__straighten
  end
  #-----------------------------------------------------------------------------
  # Don't show dust animation if Following Pokemon isn't active or is airborne
  #-----------------------------------------------------------------------------
  def show_dust_animation
    return if !FollowingPkmn.active? || FollowingPkmn.airborne_follower?
    super
  end
  #-----------------------------------------------------------------------------
  # Allow following pokemon to freely walk on water
  #-----------------------------------------------------------------------------
  def location_passable?(x, y, direction)
    this_map = self.map
    return false if !this_map || !this_map.valid?(x, y)
    return true if @through
    passed_tile_checks = false
    bit = (1 << ((direction / 2) - 1)) & 0x0f
    # Check all events for ones using tiles as graphics, and see if they're passable
    this_map.events.each_value do |event|
      next if event.tile_id < 0 || event.through || !event.at_coordinate?(x, y)
      tile_data = GameData::TerrainTag.try_get(this_map.terrain_tags[event.tile_id])
      next if tile_data.ignore_passability
      next if tile_data.bridge && $PokemonGlobal.bridge == 0
      return false if tile_data.ledge
      # Allow Folllowers to surf if they can travel on water
      return true if tile_data.can_surf && FollowingPkmn.waterborne_follower?
      passage = this_map.passages[event.tile_id] || 0
      return false if passage & bit != 0
      passed_tile_checks = true if (tile_data.bridge && $PokemonGlobal.bridge > 0) ||
                                   (this_map.priorities[event.tile_id] || -1) == 0
      break if passed_tile_checks
    end
    # Check if tiles at (x, y) allow passage for follower
    if !passed_tile_checks
      [2, 1, 0].each do |i|
        tile_id = this_map.data[x, y, i] || 0
        next if tile_id == 0
        tile_data = GameData::TerrainTag.try_get(this_map.terrain_tags[tile_id])
        next if tile_data.ignore_passability
        next if tile_data.bridge && $PokemonGlobal.bridge == 0
        return false if tile_data.ledge
        # Allow Folllowers to surf if they can travel on water
        return true if tile_data.can_surf && FollowingPkmn.waterborne_follower?
        passage = this_map.passages[tile_id] || 0
        return false if passage & bit != 0
        break if tile_data.bridge && $PokemonGlobal.bridge > 0
        break if (this_map.priorities[tile_id] || -1) == 0
      end
    end
    # Check all events on the map to see if any are in the way
    this_map.events.values.each do |event|
      next if !event.at_coordinate?(x, y)
      return false if !event.through && event.character_name != ""
    end
    return true
  end
  #-----------------------------------------------------------------------------
  # Updating the event turning to prevent following Pokemon from changing it's
  # direction with the player
  #-----------------------------------------------------------------------------
  def turn_towards_leader(leader)
    return if FollowingPkmn.active? && !FollowingPkmn::ALWAYS_FACE_PLAYER
    pbTurnTowardEvent(self, leader)
  end
  #-----------------------------------------------------------------------------
  # Make Follower Appear above player
  #-----------------------------------------------------------------------------
  def screen_z(height = 0)
    ret = super
    return ret + 1
  end
  #-----------------------------------------------------------------------------
end

class FollowerData
  #-----------------------------------------------------------------------------
  # Shorthand for checking whether the data is for a Following Pokemon event
  #-----------------------------------------------------------------------------
  def following_pkmn?; return name[/FollowingPkmn/]; end
  #-----------------------------------------------------------------------------
  # Updating the FollowerData interact method to allow Following Pokemon to
  # interact with the player without needing a common event
  #-----------------------------------------------------------------------------
  alias __followingpkmn__interact interact unless method_defined?(:__followingpkmn__interact)
  def interact(*args)
    return __followingpkmn__interact(*args) if !following_pkmn?
    if !@common_event_id
      event = args[0]
      $game_map.refresh if $game_map.need_refresh
	  event.lock
      FollowingPkmn.talk
      event.unlock
    elsif FollowingPkmn.can_talk?
      return __followingpkmn__interact(*args)
    end
  end
  #-----------------------------------------------------------------------------
end


class Game_FollowerFactory
  #-----------------------------------------------------------------------------
  # Define the Following as a different class from Game_Follower ie
  # Game_FollowingPkmn
  #-----------------------------------------------------------------------------
  alias __followingpkmn__create_follower_object create_follower_object unless private_method_defined?(:__followingpkmn__create_follower_object)
  def create_follower_object(*args)
    return Game_FollowingPkmn.new(args[0]) if args[0].following_pkmn?
    return __followingpkmn__create_follower_object(*args)
  end
  #-----------------------------------------------------------------------------
  # Following Pokemon shouldn't be a leader if it is inactive.
  #-----------------------------------------------------------------------------
  def move_followers
    leader = $game_player
    $PokemonGlobal.followers.each_with_index do |follower, i|
      event = @events[i]
      event.follow_leader(leader, false, (i == 0))
      follower.x              = event.x
      follower.y              = event.y
      follower.current_map_id = event.map.map_id
      follower.direction      = event.direction
      leader = event if !event.is_a?(Game_FollowingPkmn) || FollowingPkmn.active?
    end
  end
  #-----------------------------------------------------------------------------
  # Following Pokemon shouldn't be a leader if it is inactive.
  #-----------------------------------------------------------------------------
  def turn_followers
    leader = $game_player
    $PokemonGlobal.followers.each_with_index do |follower, i|
      event = @events[i]
      event.turn_towards_leader(leader)
      follower.direction = event.direction
      leader = event if !event.is_a?(Game_FollowingPkmn) || FollowingPkmn.active?
    end
  end
  #-----------------------------------------------------------------------------
  # Method to remove all Followers except Following Pokemon
  #-----------------------------------------------------------------------------
  def remove_all_except_following_pkmn
    followers = $PokemonGlobal.followers
    followers.each_with_index do |follower, i|
      next if follower.following_pkmn?
      followers[i] = nil
      @events[i] = nil
      @last_update += 1
    end
    followers.compact!
    @events.compact!
  end
  #-----------------------------------------------------------------------------
end
