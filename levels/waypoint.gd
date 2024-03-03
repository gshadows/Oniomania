class_name WayPoint extends Marker3D

signal arrived

enum PointType {
	# Intermediate points.
	WALK, GARBAGE_INTERNAL,
	# Destination points.
	COMPUTER, CLOSET, ENTRANCE, SHOP, GARBAGE
}
@export var point_type: PointType = PointType.WALK

@export var to_computer: WayPoint
@export var to_closet: WayPoint
@export var to_entrance: WayPoint
@export var to_shop: WayPoint
@export var to_garbage: WayPoint

@export_range(0.0, 10.0) var wait_here_sec: float


func get_type_name() -> String:
	match point_type:
		PointType.WALK: return "WALK"
		PointType.GARBAGE_INTERNAL: return "GARBAGE_INTERNAL"
		PointType.COMPUTER: return "COMPUTER"
		PointType.CLOSET: return "CLOSET"
		PointType.ENTRANCE: return "ENTRANCE"
		PointType.SHOP: return "SHOP"
		PointType.GARBAGE: return "GARBAGE"
		_: return str(point_type)
