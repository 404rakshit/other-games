#extends CanvasLayer
#
#const main_menu = preload("res://scenes/game/main_menu.tscn")
#const gameplay = preload("res://scenes/game/world.tscn")
#
#signal on_trigger_player_spawn(position, direction)
#
#var spawn_door_tag
#
#func go_to_level(level_tag, designation_tag):
	#var scene_to_load
	#
	#match level_tag:
		#"gameplay":
			#scene_to_load = gameplay
		#"menu":
			#scene_to_load= main_menu
		#
	#if scene_to_load != null:
		##Transi.transition()
		#spawn_door_tag = designation_tag
		#get_tree().change_scene_to_packed(scene_to_load)
#
#func trigger_player_spawn(position: Vector2, direction: String):
	#on_trigger_player_spawn.emit(postiion, direction)
