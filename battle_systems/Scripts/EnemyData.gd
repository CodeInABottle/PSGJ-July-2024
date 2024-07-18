class_name BattlefieldEnemyData
extends Resource

@export var name: String

@export_category("Stats")
@export var speed: int
@export var max_health: int
@export var max_alchemy_points: int
@export var ap_regen_rate: int

@export_category("Behaviors")
@export var resonate: TypeChart.ResonateType = TypeChart.ResonateType.NONE
@export var domain: StringName
@export var abilities: Array[BattlefieldAbility]

@export_category("Misc")
@export var sprite: CompressedTexture2D
