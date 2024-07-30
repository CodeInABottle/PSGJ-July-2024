extends Node

var crossfader : AnimationPlayer
var overworldTheme : AudioStreamPlayer
var battleTheme : AudioStreamPlayer
var SFX : AudioStreamPlayer
var isBattleMusic : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	overworldTheme = $MusicOverworld
	battleTheme = $MusicBattle
	SFX = $SFX
	crossfader = $Crossfade

func crossfade_to_battle() -> void:
	if isBattleMusic:
		return
	else:
		isBattleMusic = true
		crossfader.play("FadeToBattle")
		
func crossfade_to_overworld() -> void:
	if isBattleMusic:
		isBattleMusic = false
		crossfader.play("FadeToOverworld")
	else:
		return

func play_sfx(sound : AudioStream) -> void:
	SFX.steam = sound
	SFX.play()
	
