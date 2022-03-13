extends CSGMesh


export (Texture) var base_sprite = null

	
func generate_mesh():
	var image: Image = base_sprite.get_data()
	
	#var newmaterial = SpatialMaterial.new()
	#newmaterial.vertex_color_use_as_albedo = true
	#newmaterial.vertex_color_is_srgb = true
	
	#self.material = newmaterial
	#self.material_override = newmaterial
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	image.lock()
	var width = image.get_width()
	var height = image.get_height()
	for y in height:
		for x in width:
			var color: Color = image.get_pixel(x, y)
			if color.a < 0.1:
				continue
			var triangle_center_x = 2 * x
			var triangle_center_y = 2 * y
			for triangle_vertex in [[-1, 1], [-1, -1], [1, -1]]:
				st.add_normal(Vector3(0, 1, 0))
				var vertex = Vector3(triangle_center_x + triangle_vertex[0], 0, triangle_center_y + triangle_vertex[1])
				st.add_color(Color(1, 0, 0, 1))
				st.add_vertex(vertex)
			
			for triangle_vertex in [[1, -1], [1, 1], [-1, 1]]:
				st.add_normal(Vector3(0, 1, 0))
				var vertex = Vector3(triangle_center_x + triangle_vertex[0], 0, triangle_center_y + triangle_vertex[1])
				st.add_color(Color(1, 0, 0, 1))
				st.add_vertex(vertex)
	image.unlock()
	self.mesh = st.commit()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	generate_mesh()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
