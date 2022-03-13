tool
extends MeshInstance


export (int) var terrain_seed = 1234
export (Gradient) var gradient = Gradient.new()
export (float) var terrain_min_y = 0.0
export (float) var terrain_max_y = 10.0
export (Vector2) var xz_coordinates = Vector2(0.0, 0.0)
export (Vector2) var terrain_dimensions_xz = Vector2(20.0, 20.0)  
export (SpatialMaterial) var spatial_material = preload("res://use_vertexcolors.tres")
export (int) var resolution = 20


#var thread: Thread = Thread.new()

func on_generate(new_value):
	if Engine.editor_hint and new_value:
		generate_mesh()
		new_value = true

func triangle_normal(p1: Vector3, p2: Vector3, p3: Vector3)->Vector3:
	var V = p2 - p1
	var W = p3 - p1
	var normal = V.cross(W)
	normal = normal.normalized()
	return normal
	
func generate_mesh():
	var st = SurfaceTool.new()

	var noise = OpenSimplexNoise.new()
	noise.seed = terrain_seed

	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	
	
	for y in range(resolution):
		for x in range(resolution):
			var triangle_center_x = 2*x
			var triangle_center_y = 2*y
			# generate triangle points in the xz plane
			for triangle_vertex in [[-1, 1], [-1, -1], [1, -1], [-1, 1], [1, -1], [1, 1]]:
				
				var vertex = Vector3(triangle_vertex[0] + triangle_center_x, 0.0, triangle_vertex[1] + triangle_center_y)
				# make the xz coordinates between [0.0, 1.0] from [-1, (resolution-1)*2+1]
				# (resolution-1)*2+2 = resolution * 2
				vertex.x = (vertex.x + 1.0) / (resolution*2)
				vertex.z = (vertex.z + 1.0)  / (resolution*2)
				# calculate the global vertex xz coordinates
				vertex.x = vertex.x * terrain_dimensions_xz.x + xz_coordinates.x
				vertex.z = vertex.z * terrain_dimensions_xz.y + xz_coordinates.y
				#set the height:
				var height = noise.get_noise_2d(vertex.x, vertex.z)
				height = (height + 1)/2
				var interpolation = height
				height = height * (terrain_max_y - terrain_min_y) + terrain_min_y
				vertex.y = height
				# finally at the
				var color = gradient.interpolate(interpolation)
				st.add_color(color)
				st.add_vertex(vertex)
	# Create indices, indices are optional.
	st.index()
	st.generate_normals()
	# Commit to a mesh.
	self.mesh = st.commit()	
	self.create_trimesh_collision()
	self.mesh.surface_set_material(0, spatial_material)
# Called when the node enters the scene tree for the first time.
func _ready():
	#thread = Thread.new()
	#thread.start(self, "generate_mesh")
	generate_mesh()

func _exit_tree():
	#thread.wait_to_finish()
	pass
