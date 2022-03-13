extends Node
# this node must be a child of the player character.
var chunksize = 150
var chunk_x = 0
var chunk_z = 0
var view_size = 3
var unload_distance = view_size * 2


onready var terrain = $Terrain2
onready var player_position: Spatial = $bullet_storage/GodmodePlayer

var loaded_chunks: Dictionary = {}


func _ready():
	for x in range(-view_size, view_size):
		for z in range(-view_size, view_size):
			var terra_dupe: MeshInstance = terrain.duplicate()
			terra_dupe.terrain_dimensions_xz = Vector2(chunksize, chunksize)
			terra_dupe.xz_coordinates = Vector2(x*chunksize, z*chunksize)
			self.add_child(terra_dupe)
			loaded_chunks[[x*chunksize, z*chunksize]] = terra_dupe
			#print("init mesh", x,z)
# Called when the node enters the scene tree for the first time.
func _process(_delta):
	var global_position: Vector3 = player_position.global_transform.origin
	var current_chunk_x = int(global_position.x / chunksize)
	var current_chunk_z = int(global_position.z / chunksize)

	if current_chunk_x != chunk_x or current_chunk_z != chunk_z:
		#print("changing chunks x, z from:", chunk_x , "," , chunk_z, " to ", current_chunk_x, ",", current_chunk_z)
		chunk_x = current_chunk_x
		chunk_z = current_chunk_z
		#load new chunks
		for x in range(-view_size, view_size):
			for z in range(-view_size, view_size):
				var check_chunk_x = (chunk_x + x)*chunksize
				var check_chunk_z = (chunk_z + z)*chunksize
				if loaded_chunks.has([check_chunk_x, check_chunk_z]):
					#print("chunk", check_chunk_x, ",", check_chunk_z, "already loaded, skipping")
					continue
				#print("loading chunk", check_chunk_x, ",", check_chunk_z)
				var terra_dupe: MeshInstance = terrain.duplicate()
				terra_dupe.terrain_dimensions_xz = Vector2(chunksize, chunksize)
				terra_dupe.xz_coordinates = Vector2(check_chunk_x, check_chunk_z)
				self.add_child(terra_dupe)
				loaded_chunks[[check_chunk_x, check_chunk_z]] = terra_dupe
		
		#iterating over the keys is essential here.
		for key in loaded_chunks.keys():
			var manhatten_distance_2_center_chunk = abs(key[0]/chunksize - chunk_x) + abs(key[1]/chunksize - chunk_z)
			
			if manhatten_distance_2_center_chunk > unload_distance:
				var value: Node = loaded_chunks[key]
				self.remove_child(value)
				value.queue_free()
				loaded_chunks.erase(key) 
				print("deleted chunk", [key[0]/chunksize, key[1]/chunksize], "while in chunk", [chunk_x, chunk_z], "manhatten dst:", manhatten_distance_2_center_chunk)
				print("loaded chunks in dict:", loaded_chunks.size(), "terrain children:", self.get_children().size())
				continue
		
