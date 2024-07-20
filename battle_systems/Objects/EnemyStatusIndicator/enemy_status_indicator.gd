class_name BattlefieldEnemyStatusIndicator
extends Control

@onready var resonate_indicator: BattlefieldResonateBar = %ResonateIndicator
@onready var progress_bar: ProgressBar = %ProgressBar

func set_health_data(max_health: int) -> void:
	progress_bar.max_value = max_health
	progress_bar.value = max_health

func update_health(current_health: int) -> void:
	progress_bar.value = current_health

func set_resonate(type: TypeChart.ResonateType) -> void:
	resonate_indicator.set_data(type)
