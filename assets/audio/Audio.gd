extends Node

var crossfader
var overworldTheme
var battleTheme
var SFX
var isBattleMusic = false

# Called when the node enters the scene tree for the first time.
func _ready():
	overworldTheme = $MusicOverworld
	battleTheme = $MusicBattle
	SFX = $SFX
	crossfader = $Crossfade


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func crossfade_to_battle():
	if isBattleMusic:
		return
	else:
		isBattleMusic = true
		crossfader.play("FadeToBattle")
		
func crossfade_to_overworld():
	if isBattleMusic:
		isBattleMusic = false
		crossfader.play("FadeToOverworld")
	else:
		return

func play_sfx(sound : AudioStream):
	SFX.steam = sound
	SFX.play()
	
