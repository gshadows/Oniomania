extends Node3D

const ARRIVAL_DISTANCE_SQUARED := 0.001
const WALKING_SPEED := 2.0
const GAME_START_WAIT_SEC := 1.0

@export var waypoint: WayPoint

@onready var mesh_stand: MeshInstance3D = $MeshStand
@onready var mesh_sit: MeshInstance3D = $MeshSit
@onready var mesh_goods: MeshInstance3D = $MeshGoods
@onready var mesh_garbage: MeshInstance3D = $MeshGargabe

enum State { SHOPPING, PICKING_UP, RECEIVING, STORING, LITTERING }
var state := State.SHOPPING
var wait_time := GAME_START_WAIT_SEC
var courier_arrived := false
var difficulty_modifier := 1.0


func _process(delta: float) -> void:
	if wait_time > 0:
		wait_time -= delta
		if wait_time <= 0:
			_do_after_delay()
		return
	var dir := waypoint.global_position - global_position
	var speed := delta * WALKING_SPEED * difficulty_modifier
	if dir.length_squared() < minf(ARRIVAL_DISTANCE_SQUARED, speed * speed):
		# Arrived
		global_position = waypoint.global_position
		_do_waypoint_actions()
	else:
		# Walk to waypoint
		global_position += dir.normalized() * speed
		# TODO: Walk animation


func _do_waypoint_actions() -> void:
	print_verbose("Wife: At state %s arrived to %s (%s) and will wait %.2f sec" % [stname(state), waypoint.name, waypoint.get_type_name(), waypoint.wait_here_sec])
	wait_time = waypoint.wait_here_sec
	waypoint.arrived.emit()

	match waypoint.point_type:
		WayPoint.PointType.COMPUTER:
			# Arrived to computer - sit down for shopping.
			mesh_stand.visible = false
			mesh_sit.visible = true
			# Select next action after online shopping.
			if courier_arrived:
				# Delivery courier waiting - go to entrance to meet them.
				_switch_state(State.PICKING_UP)
				_switch_waypoint(waypoint.to_entrance)
			else:
				# No delivery - go to shop to receive parcels.
				_switch_state(State.RECEIVING)
				_switch_waypoint(waypoint.to_shop)
		WayPoint.PointType.CLOSET:
			# Arrived to closet. Stay some time with goods. Next will be garbage empty boxes.
			_switch_state(State.LITTERING)
			_switch_waypoint(waypoint.to_garbage)
		WayPoint.PointType.GARBAGE:
			# Here wife just selects temporary destination where to drop the garbage.
			_proceed_to_empty_garbage_slot()
		WayPoint.PointType.GARBAGE_INTERNAL:
			# Arrived to empty garbage slot. Drop garbage and go shopping again :)
			_drop_garbage()
			mesh_garbage.visible = false
			if courier_arrived:
				# Courier already waiting, go directly to entrance.
				_switch_state(State.PICKING_UP)
				_switch_waypoint(waypoint.to_entrance)
			else:
				# No courier! Too bad, need to go shopping immediately!
				_switch_state(State.SHOPPING)
				_switch_waypoint(waypoint.to_computer)
		WayPoint.PointType.ENTRANCE:
			# Arrived to entrance. We're here either passing through, or thi is our goal.
			if state == State.PICKING_UP:
				# We're here to pick up delivery.
				_switch_state(State.STORING)
				_switch_waypoint(waypoint.to_closet)
			else:
				_pass_through()
		WayPoint.PointType.SHOP:
			# Arrived to shop and disappeared inside.
			mesh_stand.visible = false
			_switch_state(State.STORING) # Next - store goods in closet.
			_switch_waypoint(waypoint.to_closet)
		WayPoint.PointType.WALK:
			_pass_through()

func _pass_through() -> void:
	match state:
		State.SHOPPING: # Pass through
			_switch_waypoint(waypoint.to_computer)
		State.RECEIVING: # Pass through
			_switch_waypoint(waypoint.to_shop)
		State.PICKING_UP:
			_switch_waypoint(waypoint.to_entrance)
		State.STORING: # Pass through
			_switch_waypoint(waypoint.to_closet)
		State.LITTERING: # Pass through
			_switch_waypoint(waypoint.to_garbage)


func _do_after_delay() -> void:
	print_verbose("Wife: End wait at state ", stname(state))
	match state:
		State.RECEIVING, State.PICKING_UP:
			# After computer - stand up.
			mesh_sit.visible = false
			mesh_stand.visible = true
		State.LITTERING:
			# After storing.
			mesh_goods.visible = false
			mesh_garbage.visible = true
		State.SHOPPING:
			# After throwing garbage (littering).
			mesh_garbage.visible = false
		State.STORING:
			# After received goods in shop or from delivery.
			mesh_goods.visible = true
			mesh_stand.visible = true


func _proceed_to_empty_garbage_slot() -> void:
	pass

func _drop_garbage() -> void:
	pass


func _switch_waypoint(next_point:WayPoint) -> void:
	print_verbose("Wife: Path %s (%s) -> %s (%s)" % [waypoint.name, waypoint.get_type_name(), next_point.name, next_point.get_type_name()])
	waypoint = next_point

func _switch_state(new_state:State) -> void:
	print_verbose("Wife: ", stname(state), " -> ", stname(new_state))
	state = new_state

func stname(st:State) -> String:
	match st:
		State.SHOPPING:		return "SHOPPING"
		State.PICKING_UP:	return "PICKING_UP"
		State.RECEIVING:	return "RECEIVING"
		State.STORING:		return "STORING"
		State.LITTERING:	return "LITTERING"
		_: return str(st)


func _coin() -> bool:
	return randi() % 100 > 50
