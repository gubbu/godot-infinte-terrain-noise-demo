extends MeshInstance

func _ready():
	

	
	var surfacetool = SurfaceTool.new()
	
	surfacetool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for i in [[-1, 1], [-1, -1], [1, -1]]:
		surfacetool.add_normal(Vector3(0, 1, 0))
		surfacetool.add_color(Color.red)
		surfacetool.add_uv(Vector2(0, 0))
		surfacetool.add_vertex(Vector3(i[0], 0, i[1]))

	self.mesh = surfacetool.commit()


	var material = SpatialMaterial.new()
	material.vertex_color_use_as_albedo = true
	self.mesh.surface_set_material(0, material)
