class_name BattlefieldEnemyStatusIndicator
extends Control

@onready var resonate_indicator: BattlefieldResonateBar = %ResonateIndicator
@onready var primary: ProgressBar = %Primary
@onready var secondary: ProgressBar = %Secondary
@onready var hp_timer: Timer = %HPTimer

@onready var earth_residue: TextureRect = %EarthResidue
@onready var water_residue: TextureRect = %WaterResidue
@onready var air_residue: TextureRect = %AirResidue
@onready var fire_residue: TextureRect = %FireResidue

var _damage_pooled: int = 0
var _tween: Tween

func set_health_data(max_health: int) -> void:
	primary.max_value = max_health
	primary.value = max_health
	secondary.max_value = max_health
	secondary.value = max_health

func damage_health(damage: int) -> void:
	_damage_pooled += damage
	primary.value -= damage
	if primary.value <= 0:
		_on_hp_timer_timeout()
	hp_timer.start()

func heal_health(amount: int) -> void:
	_damage_pooled = 0
	if _tween: _tween.kill()
	primary.value += amount
	secondary.value += amount

func set_resonate(type: TypeChart.ResonateType) -> void:
	resonate_indicator.set_data(type)

func update_residues(type: TypeChart.ResonateType, amount: int, blink: bool) -> void:
	match type:
		TypeChart.ResonateType.EARTH:
			earth_residue.set_amount(amount, blink)
		TypeChart.ResonateType.WATER:
			water_residue.set_amount(amount, blink)
		TypeChart.ResonateType.AIR:
			air_residue.set_amount(amount, blink)
		TypeChart.ResonateType.FIRE:
			fire_residue.set_amount(amount, blink)

func _on_hp_timer_timeout() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(secondary, "value", secondary.value - _damage_pooled, 0.25)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN)
	_damage_pooled = 0
