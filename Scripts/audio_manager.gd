extends Node2D

## 🔊 This is your library of all sound effects.
## Drag your sound files from the FileSystem dock into the "Value" part.

@onready var footsteps_audio: AudioStreamPlayer = $FootstepsAudio

# AudioManager.play_sfx("button_click")
@export var sfx_library: Dictionary[String, AudioStream] = {
	"clicksfx": preload("res://Assets/sounds/sounds/Click_SFX.mp3"),
	"lol":preload("uid://qb65ufe4oef4"),
	"power":preload("res://Assets/output.mp3"),
	"footsteps":preload("uid://cf6aqrhkypacx"),
	"heartbeat":preload("uid://348ylsy7towo"),
	"jumpscare":preload("uid://cebakduu3fou7"),
	"woodmash":preload("uid://bv57adc0yejs4")
}

# This will hold all our AudioStreamPlayer nodes
var sfx_players: Array[AudioStreamPlayer2D] = []



func _ready():
	for child in get_children():
		if child is AudioStreamPlayer2D:
			sfx_players.append(child)


func _process(delta):
	pass


## 🎵 This is the only function you'll ever need to call from other scripts.
func play_sfx(sound_name: String):
	if not sfx_library.has(sound_name):
		print("ERROR: Sound not found in AudioManager: ", sound_name)
		return

	# 2. Get the sound resource from the library
	var sound_resource = sfx_library[sound_name]

	# 3. Find a sound player that isn't busy
	for player in sfx_players:
		if not player.is_playing():
			# 4. Found a free player! Play the sound.
			player.stream = sound_resource
			player.play()
			return
			
	# 5. (Optional) If we get here, all players are busy.
	print("Warning: All SFX players are busy. Sound not played: ", sound_name)
	
func play_footsteps(surface: String):
	var current_surface_footsteps = str("Footsteps"+surface)
	footsteps_audio["parameters/switch_to_clip"] = current_surface_footsteps
	if not footsteps_audio.playing:
		footsteps_audio.play()
	print("audiomanager:" + current_surface_footsteps)
	
func stop_footsteps():
	if footsteps_audio.playing:
		footsteps_audio.stop()

#func play_footsteps():
	#var sound_name = current_footstep_surface + "_footsteps"
#
	#if not footsteps_audio.playing:
		#footsteps_audio.stream = sfx_library[sound_name]
		#footsteps_audio.play()
#
#
#func stop_footsteps():
	#if footsteps_audio.playing:
		#footsteps_audio.stop()
#
#
#func set_footstep_surface(surface: String):
	#if current_footstep_surface != surface:
		#current_footstep_surface = surface
#
		## Change sound immediately if currently walking
		#if footsteps_audio.playing:
			#footsteps_audio.stream = sfx_library[surface + "_footsteps"]
			#footsteps_audio.play()
