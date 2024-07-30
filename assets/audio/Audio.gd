extends Node

var crossfader : AnimationPlayer
var overworldTheme : AudioStreamPlayer
var battleTheme : AudioStreamPlayer
var SFX : AudioStreamPlayer
var isBattleMusic : bool = false

var acceptButtonSound : AudioStream = preload("res://assets/audio/SFX/accept_button.ogg")
var activateObeliskSound : AudioStream = preload("res://assets/audio/SFX/activate_obelisk.ogg")
var applyComponentSound : AudioStream = preload("res://assets/audio/SFX/apply_component.ogg")
var attackHitSound : AudioStream = preload("res://assets/audio/SFX/attack_hit.ogg")
var cleanComponentsSound : AudioStream = preload("res://assets/audio/SFX/clean_components.ogg")
var enterCombatSound : AudioStream = preload("res://assets/audio/SFX/enter_combat.ogg")
var itemPickupSound : AudioStream = preload("res://assets/audio/SFX/item_pickup.ogg")
var pageSound : AudioStream = preload("res://assets/audio/SFX/page.ogg")
var pickupComponentSound : AudioStream = preload("res://assets/audio/SFX/pickup_component.ogg")

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

func play_sfx(soundName : String) -> void:
	match soundName:
		"accept_button":
			SFX.stream = acceptButtonSound
		"activate_obelisk":
			SFX.stream = activateObeliskSound
		"apply_component":
			SFX.stream = applyComponentSound
		"attack_hit":
			SFX.stream = attackHitSound
		"clean_components":
			SFX.stream = cleanComponentsSound
		"enter_combat":
			SFX.stream = enterCombatSound
		"item_pickup":
			SFX.stream = itemPickupSound
		"page":
			SFX.stream = pageSound
		"pickup_component":
			SFX.stream = pickupComponentSound
		_:
			return
	SFX.play()
	
