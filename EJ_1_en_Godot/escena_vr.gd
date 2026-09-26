extends Node3D

# Variables de rotación
var velocidad_x: float = 0.0
var velocidad_y: float = 0.0
var estado_diseno: int = 0

# Referencias a los nodos de la escena
@onready var grupo_rotatorio = $GrupoRotatorio
@onready var plano1 = $GrupoRotatorio/Plano1
@onready var plano2 = $GrupoRotatorio/Plano2
@onready var texto_diseno = $HUD/TextoDiseno
@onready var texto_instrucciones = $HUD/TextoInstrucciones

func _ready():
	# Configuramos los textos iniciales de la interfaz
	texto_instrucciones.text = "INSTRUCCIONES:\nFlechas: Rotar ejes  |  D: Detener  |  R: Reiniciar animación y cambiar diseño"
	texto_instrucciones.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Creamos materiales únicos para cada plano
	plano1.material_override = StandardMaterial3D.new()
	plano2.material_override = StandardMaterial3D.new()
	
	actualizar_disenos()

func _process(delta):
	# Aplicamos la rotación constantemente multiplicada por delta (tiempo entre fotogramas)
	grupo_rotatorio.rotate_x(velocidad_x * delta)
	grupo_rotatorio.rotate_y(velocidad_y * delta)

func _input(event):
	# Usamos las acciones predeterminadas de Godot para las flechas
	if event.is_action_pressed("ui_up"):
		velocidad_x = -2.0
		velocidad_y = 0.0
	elif event.is_action_pressed("ui_down"):
		velocidad_x = 2.0
		velocidad_y = 0.0
	elif event.is_action_pressed("ui_left"):
		velocidad_y = -2.0
		velocidad_x = 0.0
	elif event.is_action_pressed("ui_right"):
		velocidad_y = 2.0
		velocidad_x = 0.0
		
	# Detectamos las teclas D y R
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_D:
			velocidad_x = 0.0
			velocidad_y = 0.0
		elif event.physical_keycode == KEY_R:
			# Reiniciar rotación y cambiar diseño
			grupo_rotatorio.rotation = Vector3.ZERO
			velocidad_x = 0.0
			velocidad_y = 0.0
			estado_diseno = (estado_diseno + 1) % 3
			actualizar_disenos()

func actualizar_disenos():
	# Nombres para la interfaz
	var nombres = ["Ajedrez", "Rayas", "Cuadros Anidados"]
	texto_diseno.text = "Diseño: " + nombres[estado_diseno]
	
	# Generamos y aplicamos las texturas procedimentales a los materiales
	var tex1 = generar_textura(estado_diseno, Color(0.98, 0.39, 0.20), Color(0.2, 0.08, 0.04))
	var tex2 = generar_textura(estado_diseno, Color(0.20, 0.78, 0.59), Color(0.04, 0.16, 0.12))
	
	plano1.material_override.albedo_texture = tex1
	plano2.material_override.albedo_texture = tex2

# Función equivalente a "drawTexturedPlane" de Processing (Genera una imagen por código)
func generar_textura(estado: int, c1: Color, c2: Color) -> ImageTexture:
	var tamano = 400
	var paso = 40
	# Creamos un lienzo en blanco de 400x400 píxeles
	var img = Image.create(tamano, tamano, false, Image.FORMAT_RGBA8)
	
	for x in range(0, tamano, paso):
		for y in range(0, tamano, paso):
			if estado == 0: # Ajedrez
				if ((x + y) / paso) % 2 == 0:
					img.fill_rect(Rect2i(x, y, paso, paso), c1)
				else:
					img.fill_rect(Rect2i(x, y, paso, paso), c2)
					
			elif estado == 1: # Rayas
				if (x / paso) % 2 == 0:
					img.fill_rect(Rect2i(x, y, paso, paso), c1)
				else:
					img.fill_rect(Rect2i(x, y, paso, paso), c2)
					
			elif estado == 2: # Cuadros anidados
				img.fill_rect(Rect2i(x, y, paso, paso), c1)
				img.fill_rect(Rect2i(x + 10, y + 10, paso - 20, paso - 20), c2)
				
	# Convertimos la imagen dibujada en una textura que Godot puede usar en 3D
	return ImageTexture.create_from_image(img)
