class_name WayPoint extends Marker3D

signal arrived

const DROP_POINT_WAIT_SEC := 0.5

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

static func make_drop_waypoint(pos: Vector3, current: WayPoint) -> WayPoint:
	var drop_point := WayPoint.new()
	drop_point.point_type = WayPoint.PointType.GARBAGE_INTERNAL
	drop_point.name = "_GarbageSlot_"
	current.add_child(drop_point)
	drop_point.global_position = pos
	drop_point.wait_here_sec = DROP_POINT_WAIT_SEC
	# Clone directions.
	drop_point.to_computer = current.to_computer
	drop_point.to_closet = current.to_closet
	drop_point.to_entrance = current.to_entrance
	drop_point.to_shop = current.to_shop
	drop_point.to_garbage = current.to_garbage
	return drop_point
