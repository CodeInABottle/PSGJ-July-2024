class_name BattlefieldEnemyData
extends Resource

@export var name: String
@export_group("Description")
@export_multiline var description: String

@export_category("Stats")
@export var max_health: int

@export_category("Behaviors")
@export var resonate: TypeChart.ResonateType = TypeChart.ResonateType.NONE
@export var domain: StringName
@export var abilities: Array[BattlefieldAbility]

@export_category("Misc")
@export var icon: CompressedTexture2D
@export var combat_animation: PackedScene
@export var special_frame_idx: int = -1
@export var attack_position: Vector2
