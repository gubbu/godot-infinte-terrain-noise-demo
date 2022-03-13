tool
extends MeshInstance


export (Texture) var texture = null  setget extrude_mesh_from_image


# a cube made out of 6 quads, a quad is made out of 2 triangles
const TRIANGLECUBE = [
	{
		normal = Vector3(0, 1, 0),
		int_normal = [0, 1, 0],
		vertecies = [
			Vector3(-1, 1, 1), 
			Vector3(-1, 1, -1),
			Vector3(1, 1, -1),
			Vector3(1, 1, -1),
			Vector3(1, 1, 1),
			Vector3(-1, 1, 1)]
	},
	{
		normal = Vector3(0, -1, 0),
		int_normal = [0, -1, 0],
		vertecies = [
			Vector3(-1, -1, 1),
			Vector3(1, -1, 1),
			Vector3(1, -1, -1),
			Vector3(1, -1, -1),
			Vector3(-1, -1, -1),
			Vector3(-1, -1, 1), 
			]
	},
	{
		normal = Vector3(1, 0, 0),
		int_normal = [1, 0, 0],		
		vertecies = [
			Vector3(1, -1, 1),
			Vector3(1, 1, 1),
			Vector3(1, 1, -1),
			Vector3(1, 1, -1),
			Vector3(1, -1, -1),
			Vector3(1, -1, 1), 
			]
	},
	{
		normal = Vector3(-1, 0, 0),
		int_normal = [-1, 0, 0],
		vertecies = [
			Vector3(-1, -1, 1),
			Vector3(-1, -1, -1),
			Vector3(-1, 1, -1),
			Vector3(-1, 1, -1),
			Vector3(-1, 1, 1),
			Vector3(-1, -1, 1), 
			]
	},
	{
		normal = Vector3(0, 0, -1),
		int_normal = [0, 0, 1],
		vertecies = [
			Vector3(-1, 1, -1),
			Vector3(-1, -1, -1),
			Vector3(1, -1, -1),
			Vector3(1, -1, -1),
			Vector3(1, 1, -1),
			Vector3(-1, 1, -1), 
			]
	},
	{
		normal = Vector3(0, 0, 1),
		int_normal = [0, 0, -1],
		vertecies = [
			Vector3(-1, 1, 1),
			Vector3(1, 1, 1),
			Vector3(1, -1, 1),
			Vector3(1, -1, 1),
			Vector3(-1, -1, 1),
			Vector3(-1, 1, 1), 
			]
	},
]



func is_inside_3Darray(position: Vector3, array_dimensions: Vector3)->bool:
	var not_negative: bool = position.abs() == position
	var inside_bounds_x: bool = position.x < array_dimensions.x
	var inside_bounds_y: bool = position.y < array_dimensions.y
	var inside_bounds_z: bool = position.z < array_dimensions.z
	return not_negative and inside_bounds_x and inside_bounds_y and inside_bounds_z


# cubeworld 3D array is an 3D array of example cubes: a directory with the following components
#					var example_cube = {
#						gen_mesh = false,
#						color = Color(1.0, 0.0, 0.0),
#						solid = true
#				}
func cubeworld3D(cubeworld3Darray):
	var surfacetool = SurfaceTool.new()
	surfacetool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var height = cubeworld3Darray.size()
	var width = cubeworld3Darray[0].size()
	var depth = cubeworld3Darray[0][0].size()
	var array_3D_dimensions = Vector3(width, height, depth)
	for y in range(height):
		for x in range(width):
			for z in range(depth):
				var current_cube = cubeworld3Darray[y][x][z]
				if not current_cube.gen_mesh or not current_cube.solid:
					continue
				var current_cube_color = current_cube.color
				var array_cube_position = Vector3(x, y, z)
				var center_cube_geometry = Vector3(x*2, y*2, z*2)
				for quad in TRIANGLECUBE:
					var quad_normal: Vector3 = quad.normal
					var neighbor_index_2_check: Vector3 = array_cube_position + quad_normal
					var gen_quad_mesh = true
					if is_inside_3Darray(neighbor_index_2_check, array_3D_dimensions):
						var x2check: int = int(neighbor_index_2_check.x)
						var y2check: int = int(neighbor_index_2_check.y)
						var z2check: int = int(neighbor_index_2_check.z)
						gen_quad_mesh = not cubeworld3Darray[y2check][x2check][z2check].solid
						print(gen_quad_mesh)
					if gen_quad_mesh:
						for vertex in quad.vertecies:
							surfacetool.add_color(current_cube_color)
							surfacetool.add_normal(quad_normal)
							surfacetool.add_vertex(center_cube_geometry + vertex)
		self.mesh = surfacetool.commit()
	
func extrude_mesh_from_image(texture2D: Texture):
	if texture2D == null:
		return
	var image: Image = texture2D.get_data()
	
	image.lock()
	var width = image.get_width()
	var height = image.get_height()
	var image_blockdata2D = []
	for y in height:
		var row = []
		for x in width:
			var color: Color = image.get_pixel(x, y)
			
			if color.a < 0.1:
				row.append(
					{
						color = color,
						gen_mesh = false,
						solid = false
					})
				continue
			row.append(
				{
					color = color,
					gen_mesh = true,
					solid = true
				}
			)
		image_blockdata2D.append(row)
	image.unlock()
	
	cubeworld3D([image_blockdata2D])
	
	
	var newmaterial = SpatialMaterial.new()
	newmaterial.vertex_color_use_as_albedo = true
	self.mesh.surface_set_material(0, newmaterial)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	extrude_mesh_from_image(self.texture)

