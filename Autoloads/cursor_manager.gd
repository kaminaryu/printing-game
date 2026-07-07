extends Node

# What each component does:
# - CURSOR_DEFAULT: Texture resource path for the regular pointer.
# - CURSOR_HOVER: Texture resource path for interactable objects.
# - HOTSPOT: The offset pixel vector where the actual click registers (e.g., top-left or center).
const CURSOR_DEFAULT := preload("res://Assets/Cursors/CursorDefault.png")
const CURSOR_CYAN    := preload("res://Assets/Cursors/CursorDefaultCyan.png")
const CURSOR_MAGENTA := preload("res://Assets/Cursors/CursorDefaultMagenta.png")
const CURSOR_YELLOW  := preload("res://Assets/Cursors/CursorDefaultYellow.png")
const CURSOR_KEY     := preload("res://Assets/Cursors/CursorDefaultKey.png")

const ROLLER_DEFAULT := preload("res://Assets/Cursors/RollerPin.png")
const ROLLER_CYAN    := preload("res://Assets/Cursors/RollerPinCyan.png")
const ROLLER_MAGENTA := preload("res://Assets/Cursors/RollerPinMagenta.png")
const ROLLER_YELLOW  := preload("res://Assets/Cursors/RollerPinYellow.png")
const ROLLER_KEY     := preload("res://Assets/Cursors/RollerPinKey.png")

# hotspot -> offset from top-left corner of the sprite to act as the pointer
const CURSOR_HOTSPOT := Vector2(0, 0)
const ROLLER_HOTSPOT  := Vector2(16, 8)


func reset() -> void :
	_set_default_cursor()


func _ready() -> void:
	# Sets the fallback system/default application cursor
	reset()


func _set_default_cursor() -> void :
	Input.set_custom_mouse_cursor(CURSOR_DEFAULT, Input.CURSOR_ARROW, CURSOR_HOTSPOT)


func set_cursor() -> void:
	var channel: String = ColorManager.get_color_channel()
	var texture: CompressedTexture2D

	match channel:
		"c": texture = CURSOR_CYAN
		"m": texture = CURSOR_MAGENTA
		"y": texture = CURSOR_YELLOW
		"k": texture = CURSOR_KEY
		"_": texture = CURSOR_DEFAULT

	Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW, CURSOR_HOTSPOT)


func set_roller() -> void:
	var channel: String = ColorManager.get_color_channel()
	var texture: CompressedTexture2D

	match channel:
		"c": texture = ROLLER_CYAN
		"m": texture = ROLLER_MAGENTA
		"y": texture = ROLLER_YELLOW
		"k": texture = ROLLER_KEY
		"_": texture = ROLLER_DEFAULT

	Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW, ROLLER_HOTSPOT)
