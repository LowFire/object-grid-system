extends GutTest

class TestGridSpaceNode2D extends GutTest:
	var grid_space: GridSpaceNode2D
	
	func before_each() -> void:
		grid_space = GridSpaceNode2D.new()
		add_child(grid_space)
		watch_signals(grid_space)
		
	func after_each() -> void:
		var connections = grid_space.object_removed.get_connections()
		for conn in connections:
			grid_space.object_removed.disconnect(conn.callable)
		grid_space.free()

	func test_get_set_grid_dimensions() -> void:
		grid_space.grid_dimensions = Vector2i(3,3)
		var result: Vector2i = grid_space.grid_dimensions
		
		assert_eq(result, Vector2i(3,3))

	func test_get_set_slot_dimensions() -> void:
		grid_space.slot_dimensions = Vector2i(200, 200)
		var result: Vector2i = grid_space.slot_dimensions
		
		assert_eq(result, Vector2i(200, 200))
		
	func test_add_object() -> void:
		var obj1: GridNode2D = GridNode2D.new()
		obj1.grid_dimensions = Vector2i(2, 2)
		obj1.grid_position = Vector2i(2, 2)
		watch_signals(obj1)
		
		var id = grid_space.add_object(obj1)
		
		var all_objects: Dictionary = grid_space.get_all_objects()
		assert_eq(all_objects.size(), 1)
		assert_true(all_objects.has(id))
		assert_eq(grid_space.get_child_count(), 1)
		assert_connected(obj1, grid_space, "grid_dimensions_changed")
		assert_connected(obj1, grid_space, "grid_position_changed")
		assert_signal_emitted(grid_space, "object_added")
		assert_eq(obj1.position, Vector2(200, 200))
	
	func test_add_multiple_objects() -> void:
		var obj1: GridNode2D = GridNode2D.new()
		var obj2: GridNode2D = GridNode2D.new()
		var obj3: GridNode2D = GridNode2D.new()
		obj1.grid_bounds = Rect2i(1,1,1,1)
		obj2.grid_bounds = Rect2i(2,3,1,1)
		obj3.grid_bounds = Rect2i(4,4,1,1)
		var obj_arr: Array[GridNode2D] = [obj1, obj2, obj3]
		watch_signals(obj1)
		watch_signals(obj2)
		watch_signals(obj3)
		
		var ids: Array[int] = grid_space.add_objects(obj_arr)
		
		var all_objects: Dictionary = grid_space.get_all_objects()
		assert_eq(all_objects.size(), 3)
		assert_eq(ids.size(), 3)
		for id in ids:
			assert_true(all_objects.has(id))
		for id in all_objects:
			var obj: GridNode2D = all_objects[id]
			assert_connected(obj, grid_space, "grid_dimensions_changed")
			assert_connected(obj, grid_space, "grid_position_changed")
		assert_signal_emitted(grid_space, "object_added")
		assert_signal_emit_count(grid_space, "object_added", 3)
		assert_eq(obj1.position, Vector2(100, 100))
		assert_eq(obj2.position, Vector2(200, 300))
		assert_eq(obj3.position, Vector2(400, 400))
	
	func test_get_all_objects() -> void:
		var obj1: GridNode2D = GridNode2D.new()
		var obj2: GridNode2D = GridNode2D.new()
		var obj_arr: Array[GridNode2D] = [obj1, obj2]
		grid_space.add_objects(obj_arr)
		
		var get_objs: Dictionary = grid_space.get_all_objects()
		
		assert_eq(get_objs.size(), 2)
	
	func test_grid_dimensions_changed_signal() -> void:
		var callback: Callable = func(old_dimensions: Vector2i, new_dimensions: Vector2i) -> void:
			assert_eq(old_dimensions, Vector2i(1,1))
			assert_eq(new_dimensions, Vector2i(3,3))
		grid_space.grid_dimensions_changed.connect(callback)
		
		grid_space.grid_dimensions = Vector2i(3,3)
		
		assert_signal_emitted(grid_space, "grid_dimensions_changed")
	
	func test_slot_dimensions_changed_signal() -> void:
		var callback: Callable = func(old_dimensions: Vector2i, new_dimensions: Vector2i) -> void:
			assert_eq(old_dimensions, Vector2i(100,100))
			assert_eq(new_dimensions, Vector2i(200,200))
		grid_space.slot_dimensions_changed.connect(callback)
		
		grid_space.slot_dimensions = Vector2i(200,200)
		
		assert_signal_emitted(grid_space, "slot_dimensions_changed")
		
	func test_object_added_signal() -> void:
		var callback: Callable = func(obj: GridNode2D, id: int) -> void:
			assert_ne(obj, null)
			assert_eq(id, 0)
		grid_space.object_added.connect(callback)
		
		var obj : GridNode2D = GridNode2D.new()
		grid_space.add_object(obj)
		
		assert_signal_emitted(grid_space, "object_added")
	
	func test_object_removed_signal() -> void:
		#var callback: Callable = func (obj: GridNode2D, id: int) -> void:
			#assert_ne(obj, null)
			#assert_eq(id, 0)
		#grid_space.object_removed.connect(callback)
		
		var obj: GridNode2D = GridNode2D.new()
		grid_space.add_object(obj)
		grid_space.remove_object(obj)
		
		assert_signal_emitted(grid_space, "object_removed")
		
	func test_object_dimensions_changed_signal() -> void:
		var callback: Callable = func (obj, old_dimensions: Vector2i, new_dimensions: Vector2i) -> void:
			assert_ne(obj, null)
			assert_eq(old_dimensions, Vector2i(1,1))
			assert_eq(new_dimensions, Vector2i(2,2))
			assert_eq(obj.grid_dimensions, Vector2i(2,2))
		var obj: GridNode2D = GridNode2D.new()
		grid_space.add_object(obj)
		grid_space.object_dimensions_changed.connect(callback)
		
		obj.grid_dimensions = Vector2i(2,2)
		
		assert_signal_emitted(grid_space, "object_dimensions_changed")
	
	func test_object_position_changed_signal() -> void:
		var callback: Callable = func (obj, old_position: Vector2i, new_position: Vector2i) -> void:
			assert_ne(obj, null)
			assert_eq(old_position, Vector2i(0,0))
			assert_eq(new_position, Vector2i(3,3))
			assert_eq(obj.grid_position, Vector2i(3,3))
		var obj: GridNode2D = GridNode2D.new()
		grid_space.add_object(obj)
		grid_space.object_position_changed.connect(callback)
		
		obj.grid_position = Vector2i(3,3)
		
		assert_signal_emitted(grid_space, "object_position_changed")
		
	func test_remove_object() -> void:
		var obj: GridNode2D = GridNode2D.new()
		grid_space.add_object(obj)
		
		grid_space.remove_object(obj)
		
		var all_objects: Dictionary = grid_space.get_all_objects()
		assert_eq(all_objects.size(), 0)
	
	func test_remove_object_by_id() -> void:
		var obj: GridNode2D = GridNode2D.new()
		var id: int = grid_space.add_object(obj)
		
		grid_space.remove_object_by_id(id)
		
		var all_objects: Dictionary = grid_space.get_all_objects()
		assert_eq(all_objects.size(), 0)
	
	func test_remove_all_objects() -> void:
		var obj_arr: Array[GridNode2D] = [GridNode2D.new(), GridNode2D.new(), GridNode2D.new()]
		grid_space.add_objects(obj_arr)
		
		grid_space.remove_all_objects()
		
		var all_objects: Dictionary = grid_space.get_all_objects()
		assert_eq(all_objects.size(), 0)
	
	func test_get_object_by_id() -> void:
		var obj: GridNode2D = GridNode2D.new()
		var id: int = grid_space.add_object(obj)
		
		var result: GridNode2D = grid_space.get_object_by_id(id)
		
		assert_eq(result, obj)
	
	func test_has_object() -> void:
		var obj: GridNode2D = GridNode2D.new()
		grid_space.add_object(obj)
		
		var result: bool = grid_space.has_object(obj)
		
		assert_true(result)
		
	func test_object_with_id_exists() -> void:
		var obj: GridNode2D = GridNode2D.new()
		var id: int = grid_space.add_object(obj)
		
		var result: bool = grid_space.object_with_id_exists(id)
		
		assert_true(result)
	
	func test_get_pixel_bounds_for_object() -> void:
		var obj: GridNode2D = GridNode2D.new()
		obj.grid_bounds = Rect2i(2,2,3,3)
		grid_space.add_object(obj)
		
		var bounds: Rect2i = grid_space.get_pixel_bounds_for_object(obj)
		
		assert_eq(bounds.position, Vector2i(200, 200))
		assert_eq(bounds.end, Vector2i(500, 500))
		assert_eq(bounds.size, Vector2i(300, 300))
		
	func test_object_is_overlapping() -> void:
		var obj1: GridNode2D = GridNode2D.new()
		var obj2: GridNode2D = GridNode2D.new()
		var obj3: GridNode2D = GridNode2D.new()
		var obj4: GridNode2D = GridNode2D.new()
		obj1.grid_bounds = Rect2i(1,1,2,2)
		obj2.grid_bounds = Rect2i(2,2,2,2)
		obj3.grid_bounds = Rect2i(5,2,2,2)
		obj4.grid_bounds = Rect2i(7,2,2,2)
		grid_space.add_objects([obj1, obj2, obj3, obj4])
		
		var result1: bool = grid_space.object_is_overlapping(obj1)
		var result2: bool = grid_space.object_is_overlapping(obj2)
		var result3: bool = grid_space.object_is_overlapping(obj3)
		var result4: bool = grid_space.object_is_overlapping(obj4)
		
		assert_true(result1)
		assert_true(result2)
		assert_false(result3)
		assert_false(result4)
	
	func test_objects_are_overlapping() -> void:
		var obj1: GridNode2D = GridNode2D.new()
		var obj2: GridNode2D = GridNode2D.new()
		var obj3: GridNode2D = GridNode2D.new()
		var obj4: GridNode2D = GridNode2D.new()
		obj1.grid_bounds = Rect2i(1,1,2,2)
		obj2.grid_bounds = Rect2i(2,2,2,2)
		obj3.grid_bounds = Rect2i(5,2,2,2)
		obj4.grid_bounds = Rect2i(7,2,2,2)
		grid_space.add_objects([obj1, obj2, obj3, obj4])
		
		var result1: bool = grid_space.objects_are_overlapping(obj1, obj2)
		var result2: bool = grid_space.objects_are_overlapping(obj1, obj3)
		var result3: bool = grid_space.objects_are_overlapping(obj3, obj4)
		
		assert_true(result1)
		assert_false(result2)
		assert_false(result3)
	
	func test_object_overlaps_at_position() -> void:
		var obj1: GridNode2D = GridNode2D.new()
		var obj2: GridNode2D = GridNode2D.new()
		obj1.grid_bounds = Rect2i(1,1,2,2)
		obj2.grid_bounds = Rect2i(5,2,2,2)
		grid_space.add_objects([obj1, obj2])
		
		var result1: bool = grid_space.object_overlaps_at_position(obj1, Vector2i(1,1))
		var result2: bool = grid_space.object_overlaps_at_position(obj1, Vector2i(1,5))
		var result3: bool = grid_space.object_overlaps_at_position(obj1, Vector2i(4,2))
		
		assert_false(result1)
		assert_false(result2)
		assert_true(result3)

class TestGridNode2D extends GutTest:
	var grid_object: GridNode2D
	
	func before_each() -> void:
		grid_object = GridNode2D.new()
		watch_signals(grid_object)
		
	func after_each() -> void:
		grid_object.free()
		
	func test_get_set_grid_dimensions() -> void:
		grid_object.grid_dimensions = Vector2i(2,2)
		var result: Vector2i = grid_object.grid_dimensions
		
		assert_eq(result, Vector2i(2,2))
		
	func test_get_set_grid_position() -> void:
		grid_object.grid_position = Vector2i(2,2)
		var result: Vector2i = grid_object.grid_position
		
		assert_eq(result, Vector2i(2,2))
		
	func test_get_set_grid_bounds() -> void:
		grid_object.grid_bounds = Rect2i(1,1,2,2)
		var result: Rect2i = grid_object.grid_bounds
		
		assert_eq(result, Rect2i(1,1,2,2))
		
	func test_grid_dimensions_signal() -> void:
		var callback: Callable = func (obj: GridNode2D, old_dimensions: Vector2i, new_dimensions: Vector2i) -> void:
			assert_ne(obj, null)
			assert_eq(old_dimensions, Vector2i(1,1))
			assert_eq(new_dimensions, Vector2i(2,2))
		grid_object.grid_dimensions_changed.connect(callback)
		
		grid_object.grid_dimensions = Vector2i(2,2)
		
		assert_signal_emitted(grid_object, "grid_dimensions_changed")
		
	func test_grid_position_changed_signal() -> void:
		var callback: Callable = func (obj: GridNode2D, old_position: Vector2i, new_position: Vector2i) -> void:
			assert_ne(obj, null)
			assert_eq(old_position, Vector2i(0,0))
			assert_eq(new_position, Vector2i(2,2))
		grid_object.grid_position_changed.connect(callback)
		
		grid_object.grid_position = Vector2i(2,2)
		
		assert_signal_emitted(grid_object, "grid_position_changed")
		
	func test_signals_emit_on_grid_bounds_changed() -> void:
		var dimensions_changed_callback: Callable = func (obj: GridNode2D, old_dimensions: Vector2i, new_dimensions: Vector2i) -> void:
			assert_ne(obj, null)
			assert_eq(old_dimensions, Vector2i(1,1))
			assert_eq(new_dimensions, Vector2i(2,2))
		var position_changed_callback: Callable = func (obj: GridNode2D, old_position: Vector2i, new_position: Vector2i) -> void:
			assert_ne(obj, null)
			assert_eq(old_position, Vector2i(0,0))
			assert_eq(new_position, Vector2i(2,2))
		grid_object.grid_dimensions_changed.connect(dimensions_changed_callback)
		grid_object.grid_position_changed.connect(position_changed_callback)
		
		grid_object.grid_bounds = Rect2i(2,2,2,2)
		
		assert_signal_emitted(grid_object, "grid_dimensions_changed")
		assert_signal_emitted(grid_object, "grid_position_changed")

class TestGridSpaceControl extends GutTest:
	var grid_space: GridSpaceControl
	
	func before_each() -> void:
		grid_space = GridSpaceControl.new()
		add_child(grid_space)
		watch_signals(grid_space)
		
	func after_each() -> void:
		var connections = grid_space.object_removed.get_connections()
		for conn in connections:
			grid_space.object_removed.disconnect(conn.callable)
		grid_space.free()

	func test_get_set_grid_dimensions() -> void:
		grid_space.grid_dimensions = Vector2i(3,3)
		var result: Vector2i = grid_space.grid_dimensions
		
		assert_eq(result, Vector2i(3,3))

	func test_get_set_slot_dimensions() -> void:
		grid_space.slot_dimensions = Vector2i(200, 200)
		var result: Vector2i = grid_space.slot_dimensions
		
		assert_eq(result, Vector2i(200, 200))
		
	func test_add_object() -> void:
		var obj1: GridControl = GridControl.new()
		obj1.grid_dimensions = Vector2i(2, 2)
		obj1.grid_position = Vector2i(2, 2)
		watch_signals(obj1)
		
		var id = grid_space.add_object(obj1)
		
		var all_objects: Dictionary = grid_space.get_all_objects()
		assert_eq(all_objects.size(), 1)
		assert_true(all_objects.has(id))
		assert_eq(grid_space.get_child_count(), 1)
		assert_connected(obj1, grid_space, "grid_dimensions_changed")
		assert_connected(obj1, grid_space, "grid_position_changed")
		assert_signal_emitted(grid_space, "object_added")
		assert_eq(obj1.position, Vector2(200, 200))
	
	func test_add_multiple_objects() -> void:
		var obj1: GridControl = GridControl.new()
		var obj2: GridControl = GridControl.new()
		var obj3: GridControl = GridControl.new()
		obj1.grid_bounds = Rect2i(1,1,1,1)
		obj2.grid_bounds = Rect2i(2,3,1,1)
		obj3.grid_bounds = Rect2i(4,4,1,1)
		var obj_arr: Array[GridControl] = [obj1, obj2, obj3]
		watch_signals(obj1)
		watch_signals(obj2)
		watch_signals(obj3)
		
		var ids: Array[int] = grid_space.add_objects(obj_arr)
		
		var all_objects: Dictionary = grid_space.get_all_objects()
		assert_eq(all_objects.size(), 3)
		assert_eq(ids.size(), 3)
		for id in ids:
			assert_true(all_objects.has(id))
		for id in all_objects:
			var obj: GridControl = all_objects[id]
			assert_connected(obj, grid_space, "grid_dimensions_changed")
			assert_connected(obj, grid_space, "grid_position_changed")
		assert_signal_emitted(grid_space, "object_added")
		assert_signal_emit_count(grid_space, "object_added", 3)
		assert_eq(obj1.position, Vector2(100, 100))
		assert_eq(obj2.position, Vector2(200, 300))
		assert_eq(obj3.position, Vector2(400, 400))
	
	func test_get_all_objects() -> void:
		var obj1: GridControl = GridControl.new()
		var obj2: GridControl = GridControl.new()
		var obj_arr: Array[GridControl] = [obj1, obj2]
		grid_space.add_objects(obj_arr)
		
		var get_objs: Dictionary = grid_space.get_all_objects()
		
		assert_eq(get_objs.size(), 2)
	
	func test_grid_dimensions_changed_signal() -> void:
		var callback: Callable = func(old_dimensions: Vector2i, new_dimensions: Vector2i) -> void:
			assert_eq(old_dimensions, Vector2i(1,1))
			assert_eq(new_dimensions, Vector2i(3,3))
		grid_space.grid_dimensions_changed.connect(callback)
		
		grid_space.grid_dimensions = Vector2i(3,3)
		
		assert_signal_emitted(grid_space, "grid_dimensions_changed")
	
	func test_slot_dimensions_changed_signal() -> void:
		var callback: Callable = func(old_dimensions: Vector2i, new_dimensions: Vector2i) -> void:
			assert_eq(old_dimensions, Vector2i(100,100))
			assert_eq(new_dimensions, Vector2i(200,200))
		grid_space.slot_dimensions_changed.connect(callback)
		
		grid_space.slot_dimensions = Vector2i(200,200)
		
		assert_signal_emitted(grid_space, "slot_dimensions_changed")
		
	func test_object_added_signal() -> void:
		var callback: Callable = func(obj: GridControl, id: int) -> void:
			assert_ne(obj, null)
			assert_eq(id, 0)
		grid_space.object_added.connect(callback)
		
		var obj : GridControl = GridControl.new()
		grid_space.add_object(obj)
		
		assert_signal_emitted(grid_space, "object_added")
	
	func test_object_removed_signal() -> void:
		#var callback: Callable = func (obj: GridControl, id: int) -> void:
			#assert_ne(obj, null)
			#assert_eq(id, 0)
		#grid_space.object_removed.connect(callback)
		
		var obj: GridControl = GridControl.new()
		grid_space.add_object(obj)
		grid_space.remove_object(obj)
		
		assert_signal_emitted(grid_space, "object_removed")
		
	func test_object_dimensions_changed_signal() -> void:
		var callback: Callable = func (obj, old_dimensions: Vector2i, new_dimensions: Vector2i) -> void:
			assert_ne(obj, null)
			assert_eq(old_dimensions, Vector2i(1,1))
			assert_eq(new_dimensions, Vector2i(2,2))
			assert_eq(obj.grid_dimensions, Vector2i(2,2))
		var obj: GridControl = GridControl.new()
		grid_space.add_object(obj)
		grid_space.object_dimensions_changed.connect(callback)
		
		obj.grid_dimensions = Vector2i(2,2)
		
		assert_signal_emitted(grid_space, "object_dimensions_changed")
	
	func test_object_position_changed_signal() -> void:
		var callback: Callable = func (obj, old_position: Vector2i, new_position: Vector2i) -> void:
			assert_ne(obj, null)
			assert_eq(old_position, Vector2i(0,0))
			assert_eq(new_position, Vector2i(3,3))
			assert_eq(obj.grid_position, Vector2i(3,3))
		var obj: GridControl = GridControl.new()
		grid_space.add_object(obj)
		grid_space.object_position_changed.connect(callback)
		
		obj.grid_position = Vector2i(3,3)
		
		assert_signal_emitted(grid_space, "object_position_changed")
		
	func test_remove_object() -> void:
		var obj: GridControl = GridControl.new()
		grid_space.add_object(obj)
		
		grid_space.remove_object(obj)
		
		var all_objects: Dictionary = grid_space.get_all_objects()
		assert_eq(all_objects.size(), 0)
	
	func test_remove_object_by_id() -> void:
		var obj: GridControl = GridControl.new()
		var id: int = grid_space.add_object(obj)
		
		grid_space.remove_object_by_id(id)
		
		var all_objects: Dictionary = grid_space.get_all_objects()
		assert_eq(all_objects.size(), 0)
	
	func test_remove_all_objects() -> void:
		var obj_arr: Array[GridControl] = [GridControl.new(), GridControl.new(), GridControl.new()]
		grid_space.add_objects(obj_arr)
		
		grid_space.remove_all_objects()
		
		var all_objects: Dictionary = grid_space.get_all_objects()
		assert_eq(all_objects.size(), 0)
	
	func test_get_object_by_id() -> void:
		var obj: GridControl = GridControl.new()
		var id: int = grid_space.add_object(obj)
		
		var result: GridControl = grid_space.get_object_by_id(id)
		
		assert_eq(result, obj)
	
	func test_has_object() -> void:
		var obj: GridControl = GridControl.new()
		grid_space.add_object(obj)
		
		var result: bool = grid_space.has_object(obj)
		
		assert_true(result)
		
	func test_object_with_id_exists() -> void:
		var obj: GridControl = GridControl.new()
		var id: int = grid_space.add_object(obj)
		
		var result: bool = grid_space.object_with_id_exists(id)
		
		assert_true(result)
	
	func test_get_pixel_bounds_for_object() -> void:
		var obj: GridControl = GridControl.new()
		obj.grid_bounds = Rect2i(2,2,3,3)
		grid_space.add_object(obj)
		
		var bounds: Rect2i = grid_space.get_pixel_bounds_for_object(obj)
		
		assert_eq(bounds.position, Vector2i(200, 200))
		assert_eq(bounds.end, Vector2i(500, 500))
		assert_eq(bounds.size, Vector2i(300, 300))
		
	func test_object_is_overlapping() -> void:
		var obj1: GridControl = GridControl.new()
		var obj2: GridControl = GridControl.new()
		var obj3: GridControl = GridControl.new()
		var obj4: GridControl = GridControl.new()
		obj1.grid_bounds = Rect2i(1,1,2,2)
		obj2.grid_bounds = Rect2i(2,2,2,2)
		obj3.grid_bounds = Rect2i(5,2,2,2)
		obj4.grid_bounds = Rect2i(7,2,2,2)
		grid_space.add_objects([obj1, obj2, obj3, obj4])
		
		var result1: bool = grid_space.object_is_overlapping(obj1)
		var result2: bool = grid_space.object_is_overlapping(obj2)
		var result3: bool = grid_space.object_is_overlapping(obj3)
		var result4: bool = grid_space.object_is_overlapping(obj4)
		
		assert_true(result1)
		assert_true(result2)
		assert_false(result3)
		assert_false(result4)
	
	func test_objects_are_overlapping() -> void:
		var obj1: GridControl = GridControl.new()
		var obj2: GridControl = GridControl.new()
		var obj3: GridControl = GridControl.new()
		var obj4: GridControl = GridControl.new()
		obj1.grid_bounds = Rect2i(1,1,2,2)
		obj2.grid_bounds = Rect2i(2,2,2,2)
		obj3.grid_bounds = Rect2i(5,2,2,2)
		obj4.grid_bounds = Rect2i(7,2,2,2)
		grid_space.add_objects([obj1, obj2, obj3, obj4])
		
		var result1: bool = grid_space.objects_are_overlapping(obj1, obj2)
		var result2: bool = grid_space.objects_are_overlapping(obj1, obj3)
		var result3: bool = grid_space.objects_are_overlapping(obj3, obj4)
		
		assert_true(result1)
		assert_false(result2)
		assert_false(result3)
	
	func test_object_overlaps_at_position() -> void:
		var obj1: GridControl = GridControl.new()
		var obj2: GridControl = GridControl.new()
		obj1.grid_bounds = Rect2i(1,1,2,2)
		obj2.grid_bounds = Rect2i(5,2,2,2)
		grid_space.add_objects([obj1, obj2])
		
		var result1: bool = grid_space.object_overlaps_at_position(obj1, Vector2i(1,1))
		var result2: bool = grid_space.object_overlaps_at_position(obj1, Vector2i(1,5))
		var result3: bool = grid_space.object_overlaps_at_position(obj1, Vector2i(4,2))
		
		assert_false(result1)
		assert_false(result2)
		assert_true(result3)

class TestGridControl extends GutTest:
	var grid_object: GridControl
	
	func before_each() -> void:
		grid_object = GridControl.new()
		watch_signals(grid_object)
		
	func after_each() -> void:
		grid_object.free()
		
	func test_get_set_grid_dimensions() -> void:
		grid_object.grid_dimensions = Vector2i(2,2)
		var result: Vector2i = grid_object.grid_dimensions
		
		assert_eq(result, Vector2i(2,2))
		
	func test_get_set_grid_position() -> void:
		grid_object.grid_position = Vector2i(2,2)
		var result: Vector2i = grid_object.grid_position
		
		assert_eq(result, Vector2i(2,2))
		
	func test_get_set_grid_bounds() -> void:
		grid_object.grid_bounds = Rect2i(1,1,2,2)
		var result: Rect2i = grid_object.grid_bounds
		
		assert_eq(result, Rect2i(1,1,2,2))
		
	func test_grid_dimensions_signal() -> void:
		var callback: Callable = func (obj: GridControl, old_dimensions: Vector2i, new_dimensions: Vector2i) -> void:
			assert_ne(obj, null)
			assert_eq(old_dimensions, Vector2i(1,1))
			assert_eq(new_dimensions, Vector2i(2,2))
		grid_object.grid_dimensions_changed.connect(callback)
		
		grid_object.grid_dimensions = Vector2i(2,2)
		
		assert_signal_emitted(grid_object, "grid_dimensions_changed")
		
	func test_grid_position_changed_signal() -> void:
		var callback: Callable = func (obj: GridControl, old_position: Vector2i, new_position: Vector2i) -> void:
			assert_ne(obj, null)
			assert_eq(old_position, Vector2i(0,0))
			assert_eq(new_position, Vector2i(2,2))
		grid_object.grid_position_changed.connect(callback)
		
		grid_object.grid_position = Vector2i(2,2)
		
		assert_signal_emitted(grid_object, "grid_position_changed")
		
	func test_signals_emit_on_grid_bounds_changed() -> void:
		var dimensions_changed_callback: Callable = func (obj: GridControl, old_dimensions: Vector2i, new_dimensions: Vector2i) -> void:
			assert_ne(obj, null)
			assert_eq(old_dimensions, Vector2i(1,1))
			assert_eq(new_dimensions, Vector2i(2,2))
		var position_changed_callback: Callable = func (obj: GridControl, old_position: Vector2i, new_position: Vector2i) -> void:
			assert_ne(obj, null)
			assert_eq(old_position, Vector2i(0,0))
			assert_eq(new_position, Vector2i(2,2))
		grid_object.grid_dimensions_changed.connect(dimensions_changed_callback)
		grid_object.grid_position_changed.connect(position_changed_callback)
		
		grid_object.grid_bounds = Rect2i(2,2,2,2)
		
		assert_signal_emitted(grid_object, "grid_dimensions_changed")
		assert_signal_emitted(grid_object, "grid_position_changed")
