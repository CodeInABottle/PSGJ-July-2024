class_name BattlefieldEnemyStatusIndicator
extends Control

@onready var resonate_indicator: BattlefieldResonateBar = %ResonateIndicator
@onready var primary: ProgressBar = %Primary
@onready var secondary: ProgressBar = %Secondary
@onready var hp_timer: Timer = %HPTimer

# Residue Related
@onready var earth_icon: TextureRect = %EarthIcon
@onready var earth_label: Label = %EarthLabel
@onready var water_icon: TextureRect = %WaterIcon
@onready var water_label: Label = %WaterLabel
@onready var air_icon: TextureRect = %AirIcon
@onready var air_label: Label = %AirLabel
@onready var fire_icon: TextureRect = %FireIcon
@onready var fire_label: Label = %FireLabel

var _damage_pooled: int = 0
var _tween: Tween

func _ready() -> void:
	set_residue(TypeChart.ResonateType.EARTH, 0)
	set_residue(TypeChart.ResonateType.WATER, 0)
	set_residue(TypeChart.ResonateType.AIR, 0)
	set_residue(TypeChart.ResonateType.FIRE, 0)

func set_health_data(max_health: int) -> void:
	primary.max_value = max_health
	primary.value = max_health
	secondary.max_value = max_health
	secondary.value = max_health

func update_health(damage: int) -> void:
	_damage_pooled += damage
	primary.value -= damage
	if primary.value <= 0:
		_on_hp_timer_timeout()
	hp_timer.start()

func set_resonate(type: TypeChart.ResonateType) -> void:
	resonate_indicator.set_data(type)

func set_residue(type: TypeChart.ResonateType, amount: int) -> void:
	match type:
		TypeChart.ResonateType.EARTH:
			if amount <= 0:
				earth_icon.hide()
			else:
				earth_icon.show()
			earth_label.text = str(amount) + "x"
		TypeChart.ResonateType.WATER:
			if amount <= 0:
				water_icon.hide()
			else:
				water_icon.show()
			water_label.text = str(amount) + "x"
		TypeChart.ResonateType.AIR:
			if amount <= 0:
				air_icon.hide()
			else:
				air_icon.show()
			air_label.text = str(amount) + "x"
		TypeChart.ResonateType.FIRE:
			if amount <= 0:
				fire_icon.hide()
			else:
				fire_icon.show()
			fire_label.text = str(amount) + "x"

func _on_hp_timer_timeout() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(secondary, "value", secondary.value - _damage_pooled, 0.25)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN)
	_damage_pooled = 0
