class_name BattlefieldEnemyStatusIndicator
extends Control

@onready var resonate_indicator: BattlefieldResonateBar = %ResonateIndicator
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var effect_points: Array[StatusSymbol] = [
	%StatusSymbol, %StatusSymbol2, %StatusSymbol3, %StatusSymbol4
]

func set_health_data(max_health: int) -> void:
	progress_bar.max_value = max_health
	progress_bar.value = max_health

func update_health(current_health: int) -> void:
	progress_bar.value = current_health

func set_resonate(type: TypeChart.ResonateType) -> void:
	resonate_indicator.set_data(type)

func update_statuses(data: Dictionary) -> void:
	for status_symbol: StatusSymbol in effect_points:
		status_symbol.hide()

	for effect: TypeChart.Effect in data:
		for status_symbol: StatusSymbol in effect_points:
			if status_symbol.get_type() != TypeChart.Effect.NONE: continue
			status_symbol.set_data(
				effect,
				TypeChart.get_effect_texture(effect),
				data[effect]
			)
			break

