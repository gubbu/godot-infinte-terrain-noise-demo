extends CSGMesh

func _ready():
	
	var material = SpatialMaterial.new()
	material.vertex_color_use_as_albedo = true
	#material.albedo_color = Color.green
	
	self.material_override = material
	self.material = material
	
	var surfacetool = SurfaceTool.new()
	
	surfacetool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for i in [[-1, 1], [-1, -1], [1, -1]]:
		surfacetool.add_normal(Vector3(0, 1, 0))
		surfacetool.add_color(Color.red)
		surfacetool.add_uv(Vector2(0, 0))
		surfacetool.add_vertex(Vector3(i[0], 0, i[1]))

	self.mesh = surfacetool.commit()

