tool
extends CSGMesh


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var height_scalar: float = 10.0
export (bool) var generateTerrain = false setget on_generate
export (int) var terrain_seed = 1234

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

	

	
	for y in range(20):
		for x in range(20):
			var triangle_center_x = 2*x
			var triangle_center_y = 2*y
			# generate triangle points in the xz plane
			var triangle1 = PoolVector3Array()
			triangle1.resize(3)
			for triangle_vertex in [[-1, 1], [-1, -1], [1, -1]]:
				var height = noise.get_noise_2d(triangle_center_x+triangle_vertex[0], triangle_center_y+triangle_vertex[1]) * height_scalar
				#print(height)
				#st.add_normal(Vector3(0, 1, 0))
				var Vertex = Vector3(triangle_vertex[0] + triangle_center_x, height, triangle_vertex[1] + triangle_center_y)
				triangle1.append(Vertex)
			
			var triangle1_normal = triangle_normal(triangle1[0], triangle1[1], triangle1[2])
			for vertex in triangle1:
				st.add_normal(triangle1_normal)
				st.add_vertex(vertex)
				
			var triangle2 = PoolVector3Array()
			triangle2.resize(3)
			for triangle_vertex in [[-1, 1], [1, -1], [1, 1]]:
				var height = noise.get_noise_2d(triangle_center_x+triangle_vertex[0], triangle_center_y+triangle_vertex[1])	* height_scalar			
#				var height = 0.0
				#st.add_normal(Vector3(0, 1, 0))
				var Vertex = Vector3(triangle_vertex[0] + triangle_center_x, height, triangle_vertex[1] + triangle_center_y)
				triangle2.append(Vertex)
			
			var triangle2_normal = triangle_normal(triangle2[0], triangle2[1], triangle2[2])
			for vertex in triangle2:
				st.add_normal(triangle2_normal)
				st.add_vertex(vertex)
	# Create indices, indices are optional.
	st.index()

	# Commit to a mesh.
	#var mesh = st.commit()
	self.mesh = st.commit()	
# Called when the node enters the scene tree for the first time.
func _ready():
	generate_mesh()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
