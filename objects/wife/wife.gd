class_name Wife extends Node3D

signal drop_garbage(pos:Vector3)
signal need_garbage_place

const ARRIVAL_DISTANCE_SQUARED := 0.001
const WALKING_SPEED := 2.0
const GAME_START_WAIT_SEC := 1.0

@export var waypoint: WayPoint

@onready var mesh_stand: Node3D = $MeshStand
@onready var mesh_sit: Node3D = $MeshSit
@onready var mesh_goods: Node3D = $MeshGoods
@onready var mesh_garbage: Node3D = $MeshGargabe

enum State { SHOPPING, PICKING_UP, RECEIVING, STORING, LITTERING }
@export var state := State.SHOPPING
@export var wait_time := GAME_START_WAIT_SEC

var courier_arrived := false
var difficulty_modifier := 1.0 # Updated by the GameManager
var was_in_shop := false


func _process(delta: float) -> void:
	if difficulty_modifier <= 0: return
	if wait_time > 0:
		wait_time -= delta
		if wait_time <= 0:
			_do_after_delay()
		return
	var dir := waypoint.global_position - global_position
	var move_dist := delta * WALKING_SPEED * difficulty_modifier
	if dir.length_squared() < maxf(ARRIVAL_DISTANCE_SQUARED, move_dist * move_dist):
		# Arrived
		global_position = waypoint.global_position
		_do_waypoint_actions()
	else:
		# Walk to waypoint
		global_position += dir.normalized() * move_dist
		# TODO: Walk animation


func _do_waypoint_actions() -> void:
	print_verbose("Wife: At state %s arrived to %s (%s) and will wait %.2f sec" % [stname(state), waypoint.name, waypoint.get_type_name(), waypoint.wait_here_sec])
	wait_time = waypoint.wait_here_sec / difficulty_modifier
	waypoint.arrived.emit()

	match waypoint.point_type:
		WayPoint.PointType.COMPUTER:
			# Arrived to computer - sit down for shopping.
			Audio.computer()
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
			Audio.put_goods()
			_switch_state(State.LITTERING)
			_switch_waypoint(waypoint.to_garbage)
		WayPoint.PointType.GARBAGE:
			# Here wife just selects temporary destination where to drop the garbage.
			_proceed_to_empty_garbage_slot()
		WayPoint.PointType.GARBAGE_INTERNAL:
			# Arrived to empty garbage slot. Drop garbage and go shopping again :)
			_drop_garbage()
			mesh_garbage.visible = false
			waypoint.queue_free() # This was temporary waypoint and will be deleted next frame.
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
			Audio.door()
			if state == State.PICKING_UP:
				# We're here to pick up delivery.
				_switch_state(State.STORING)
				_switch_waypoint(waypoint.to_closet)
			else:
				_pass_through()
		WayPoint.PointType.SHOP:
			# Arrived to shop and disappeared inside.
			was_in_shop = true
			Audio.shop_enter()
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
	look_at(waypoint.global_position)
	match state:
		State.RECEIVING, State.PICKING_UP:
			# After computer - stand up.
			mesh_sit.visible = false
			mesh_stand.visible = true
		State.LITTERING:
			# After storing.
			mesh_goods.visible = false
			mesh_garbage.visible = true
			Audio.unpack()
		State.SHOPPING:
			# After throwing garbage (littering).
			mesh_garbage.visible = false
			Audio.drop()
		State.STORING:
			# After received goods in shop or from delivery.
			mesh_goods.visible = true
			mesh_stand.visible = true
			if was_in_shop:
				was_in_shop = false
				Audio.shop_ok()


func _proceed_to_empty_garbage_slot() -> void:
	need_garbage_place.emit() # Request Garbage Manager to provide empty slot.

# Called by Garbage Manager.
func notify_garbage_slot(pos: Vector3) -> void:
	var drop_point := WayPoint.make_drop_waypoint(pos, waypoint)
	_switch_waypoint(drop_point)

func _drop_garbage() -> void:
	drop_garbage.emit(waypoint.global_position) # Notify Garbage Manager that garbage was dropped.


func _switch_waypoint(next_point:WayPoint) -> void:
	print_verbose("Wife: Path %s (%s) -> %s (%s)" % [waypoint.name, waypoint.get_type_name(), next_point.name, next_point.get_type_name()])
	waypoint = next_point
	if waypoint.wait_here_sec <= 0:
		look_at(waypoint.global_position)

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
