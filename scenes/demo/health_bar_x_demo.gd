extends Control

var _hud_bar: HealthBarXControl
var _world_bar: HealthBarX2D
var _world_character: Node2D
var _style: HealthBarXStyle
var _scroll: ScrollContainer
var _vbox: VBoxContainer
var _value_slider: HSlider
var _world_value_slider: HSlider
var _world_offset_y_slider: HSlider
var _roundness_slider: HSlider
var _border_slider: HSlider
var _anim_duration_slider: HSlider
var _opt_label_pos: OptionButton
var _opt_icon_pos: OptionButton
var _opt_gradient_dir: OptionButton

var _DEMO_ICON_TEXTURE: Texture2D = preload("res://assets/images/hearth.png") as Texture2D

func _ready() -> void:
	_style = HealthBarXStyle.new()
	if _DEMO_ICON_TEXTURE:
		_style.icon_texture = _DEMO_ICON_TEXTURE
	_build_ui()

func _build_ui() -> void:
	var bg = ColorRect.new()
	bg.anchors_preset = Control.PRESET_FULL_RECT
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.12, 0.12, 0.14, 1)
	add_child(bg)

	_scroll = ScrollContainer.new()
	_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	_scroll.offset_left = 20
	_scroll.offset_top = 20
	_scroll.offset_right = -20
	_scroll.offset_bottom = -20
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_scroll)

	_vbox = VBoxContainer.new()
	_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vbox.add_theme_constant_override("separation", 12)
	_scroll.add_child(_vbox)

	var title = Label.new()
	title.text = "HealthBarX Demo"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	_vbox.add_child(title)

	_vbox.add_child(HSeparator.new())
	_add_section_title("HUD (UI) Demo")
	_hud_bar = HealthBarXControl.new()
	_hud_bar.style = _style
	_hud_bar.custom_minimum_size = Vector2(280, 28)
	_hud_bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_hud_bar.size = Vector2(280, 28)
	var hud_wrap = MarginContainer.new()
	hud_wrap.custom_minimum_size = Vector2(280, 28)
	hud_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hud_wrap.add_theme_constant_override("margin_left", 0)
	hud_wrap.add_theme_constant_override("margin_right", 0)
	hud_wrap.add_child(_hud_bar)
	_vbox.add_child(hud_wrap)
	call_deferred("_refresh_hud_bar")

	_value_slider = _add_slider("Value (0-100)", 0, 100, 100, _on_value_slider_changed, 1.0)

	_add_bar_controls()
	_add_preset_buttons()
	_vbox.add_child(HSeparator.new())
	_add_section_title("World / Over-character Demo")
	_build_world_section()
	_add_section_title("Presets")
	_add_reset_button()

func _add_section_title(text: String) -> void:
	var l = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 20)
	_vbox.add_child(l)

func _add_slider(label_text: String, min_v: float, max_v: float, default_v: float, callback: Callable, step_val: float = 0.0) -> HSlider:
	var row = HBoxContainer.new()
	var lab = Label.new()
	lab.text = label_text
	lab.custom_minimum_size.x = 180
	row.add_child(lab)
	var sl = HSlider.new()
	sl.min_value = min_v
	sl.max_value = max_v
	sl.value = default_v
	if step_val > 0:
		sl.step = step_val
	sl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sl.value_changed.connect(callback)
	row.add_child(sl)
	_vbox.add_child(row)
	return sl

func _add_label_position_option() -> void:
	var row = HBoxContainer.new()
	var lab = Label.new()
	lab.text = "Label position"
	lab.custom_minimum_size.x = 180
	row.add_child(lab)
	_opt_label_pos = OptionButton.new()
	for n in ["TOP", "BOTTOM", "LEFT", "RIGHT", "CENTER_INSIDE"]:
		_opt_label_pos.add_item(n)
	_opt_label_pos.selected = 4
	_opt_label_pos.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_opt_label_pos.item_selected.connect(func(i): _style.label_position = i; _queue_redraw_bars())
	row.add_child(_opt_label_pos)
	_vbox.add_child(row)

func _add_icon_position_option() -> void:
	var row = HBoxContainer.new()
	var lab = Label.new()
	lab.text = "Icon position"
	lab.custom_minimum_size.x = 180
	row.add_child(lab)
	_opt_icon_pos = OptionButton.new()
	for n in ["BEFORE", "AFTER", "ABOVE", "BELOW", "INSIDE_LEFT", "INSIDE_RIGHT"]:
		_opt_icon_pos.add_item(n)
	_opt_icon_pos.selected = 0
	_opt_icon_pos.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_opt_icon_pos.item_selected.connect(func(i): _style.icon_position = i; _queue_redraw_bars())
	row.add_child(_opt_icon_pos)
	_vbox.add_child(row)

func _add_gradient_direction_option() -> void:
	var row = HBoxContainer.new()
	var lab = Label.new()
	lab.text = "Gradient direction"
	lab.custom_minimum_size.x = 180
	row.add_child(lab)
	_opt_gradient_dir = OptionButton.new()
	for n in ["HORIZONTAL", "VERTICAL", "DIAGONAL_TOP_LEFT", "DIAGONAL_BOTTOM_LEFT"]:
		_opt_gradient_dir.add_item(n)
	_opt_gradient_dir.selected = 0
	_opt_gradient_dir.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_opt_gradient_dir.item_selected.connect(func(i): _style.gradient_direction = i; _queue_redraw_bars())
	row.add_child(_opt_gradient_dir)
	_vbox.add_child(row)

func _add_toggle(label_text: String, initial: bool, callback: Callable) -> CheckButton:
	var row = HBoxContainer.new()
	var lab = Label.new()
	lab.text = label_text
	lab.custom_minimum_size.x = 180
	row.add_child(lab)
	var check = CheckButton.new()
	check.button_pressed = initial
	check.toggled.connect(callback)
	row.add_child(check)
	_vbox.add_child(row)
	return check

func _add_bar_controls() -> void:
	_roundness_slider = _add_slider("Roundness (0-100)", 0, 100, 20, func(v): _style.roundness = v; _queue_redraw_bars(), 1.0)
	_border_slider = _add_slider("Border thickness", 0, 8, 2, func(v): _style.border_thickness = int(v); _style.border_enabled = v > 0; _queue_redraw_bars(), 1.0)
	_add_slider("Fill inset X", 0, 10, 2, func(v): _style.fill_inset.x = v; _queue_redraw_bars(), 0.5)
	_add_slider("Fill inset Y", 0, 10, 2, func(v): _style.fill_inset.y = v; _queue_redraw_bars(), 0.5)
	_anim_duration_slider = _add_slider("Animation duration", 0.05, 1.0, 0.25, func(v): _style.animation_duration = v; _queue_redraw_bars(), 0.01)
	_add_slider("Shadow blur passes", 0, 8, 3, func(v): _style.shadow_blur_passes = int(v); _queue_redraw_bars(), 1.0)
	_add_slider("Threshold red max", 0, 100, 10, func(v): _style.threshold_red_max = v; _style.use_threshold_colors = true; _queue_redraw_bars(), 1.0)
	_add_slider("Threshold orange max", 0, 100, 70, func(v): _style.threshold_orange_max = v; _style.use_threshold_colors = true; _queue_redraw_bars(), 1.0)
	_add_slider("Font size", 8, 32, 14, func(v): _style.font_size = int(v); _queue_redraw_bars(), 1.0)
	_add_slider("Icon size X", 0, 48, 24, func(v): _style.icon_forced_size.x = v; _queue_redraw_bars(), 1.0)
	_add_slider("Icon size Y", 0, 48, 24, func(v): _style.icon_forced_size.y = v; _queue_redraw_bars(), 1.0)
	_add_slider("Icon offset X", -40, 40, 0, func(v): _style.icon_offset.x = v; _queue_redraw_bars(), 1.0)
	_add_slider("Icon offset Y", -40, 40, 0, func(v): _style.icon_offset.y = v; _queue_redraw_bars(), 1.0)
	_add_slider("Label offset X", -40, 40, 0, func(v): _style.label_offset.x = v; _queue_redraw_bars(), 1.0)
	_add_slider("Label offset Y", -40, 40, 0, func(v): _style.label_offset.y = v; _queue_redraw_bars(), 1.0)
	_add_label_position_option()
	_add_icon_position_option()
	_add_toggle("Label enabled", _style.label_enabled, func(on): _style.label_enabled = on; _queue_redraw_bars())
	_add_toggle("Icon enabled", _style.icon_enabled, func(on): _style.icon_enabled = on; _queue_redraw_bars())
	_add_toggle("Border enabled", _style.border_enabled, func(on): _style.border_enabled = on; _queue_redraw_bars())
	_add_toggle("Shadow enabled", _style.shadow_enabled, func(on): _style.shadow_enabled = on; _queue_redraw_bars())
	_add_toggle("Gradient enabled", _style.gradient_enabled, func(on): _style.gradient_enabled = on; _queue_redraw_bars())
	_add_gradient_direction_option()
	_add_toggle("Animation enabled", _style.animation_enabled, func(on): _style.animation_enabled = on; _queue_redraw_bars())

func _refresh_hud_bar() -> void:
	if not _hud_bar:
		return
	if _hud_bar.size.x <= 0 or _hud_bar.size.y <= 0:
		_hud_bar.size = Vector2(280, 28)
	_hud_bar.queue_redraw()

func _queue_redraw_bars() -> void:
	if _hud_bar:
		_hud_bar.queue_redraw()
	if _world_bar:
		_world_bar.queue_redraw()

func _on_value_slider_changed(v: float) -> void:
	_hud_bar.set_value(v, _style.animation_enabled)
	if _world_bar:
		_world_bar.set_value(v, _style.animation_enabled)

func _add_preset_buttons() -> void:
	var presets = [
		["Classic Health Bar", _preset_classic],
		["Badge/Pill", _preset_pill],
		["Threshold Segmented", _preset_threshold],
		["With Icon Overlap", _preset_icon_overlap],
		["With Label Inside", _preset_label_inside],
		["With Gradient + Shadow", _preset_gradient_shadow],
		["No Border Flat", _preset_no_border],
	]
	var grid = GridContainer.new()
	grid.columns = 3
	for name_and_cb in presets:
		var btn = Button.new()
		btn.text = name_and_cb[0]
		btn.pressed.connect(name_and_cb[1])
		grid.add_child(btn)
	_vbox.add_child(grid)

func _preset_classic() -> void:
	_style.border_enabled = true
	_style.border_thickness = 2
	_style.roundness = 4
	_style.fill_inset = Vector2(2, 2)
	_style.use_threshold_colors = true
	_style.threshold_red_max = 25
	_style.threshold_orange_max = 60
	_style.label_enabled = true
	_style.label_position = HealthBarXEnums.LabelPosition.CENTER_INSIDE
	_style.label_format = "{value}%"
	_style.shadow_enabled = false
	_style.gradient_enabled = false
	_style.animation_enabled = true
	_apply_preset_and_sliders()

func _preset_pill() -> void:
	_style.border_enabled = false
	_style.roundness = 100
	_style.fill_inset = Vector2(2, 2)
	_style.use_threshold_colors = false
	_style.fill_color = Color(0.3, 0.7, 0.4, 1)
	_style.label_enabled = true
	_style.label_position = HealthBarXEnums.LabelPosition.CENTER_INSIDE
	_style.shadow_enabled = true
	_style.shadow_blur_passes = 4
	_apply_preset_and_sliders()

func _preset_threshold() -> void:
	_style.use_threshold_colors = true
	_style.threshold_red_max = 10
	_style.threshold_orange_max = 70
	_style.label_enabled = true
	_style.label_position = HealthBarXEnums.LabelPosition.RIGHT
	_style.label_offset = Vector2(8, 0)
	_apply_preset_and_sliders()

func _preset_icon_overlap() -> void:
	_style.icon_enabled = true
	_style.icon_position = HealthBarXEnums.IconPosition.INSIDE_LEFT
	_style.icon_offset = Vector2(4, 0)
	_style.icon_forced_size = Vector2(20, 20)
	_style.icon_texture = _DEMO_ICON_TEXTURE
	_style.label_enabled = true
	_style.label_position = HealthBarXEnums.LabelPosition.CENTER_INSIDE
	_apply_preset_and_sliders()

func _preset_label_inside() -> void:
	_style.label_enabled = true
	_style.label_position = HealthBarXEnums.LabelPosition.CENTER_INSIDE
	_style.label_format = "{value}%"
	_style.font_color = Color.WHITE
	_style.outline_size = 1
	_style.outline_color = Color.BLACK
	_apply_preset_and_sliders()

func _preset_gradient_shadow() -> void:
	_style.gradient_enabled = true
	_style.gradient_direction = HealthBarXEnums.GradientDirection.VERTICAL
	_style.gradient_start_color = Color(1, 1, 1, 0.3)
	_style.gradient_end_color = Color(0, 0, 0, 0.2)
	_style.shadow_enabled = true
	_style.shadow_offset = Vector2(2, 3)
	_style.shadow_blur_passes = 4
	_apply_preset_and_sliders()

func _preset_no_border() -> void:
	_style.border_enabled = false
	_style.roundness = 8
	_style.fill_inset = Vector2(0, 0)
	_style.background_color = Color(0.25, 0.25, 0.28, 1)
	_apply_preset_and_sliders()

func _apply_preset_and_sliders() -> void:
	_sync_ui_from_style()
	_queue_redraw_bars()
	if _value_slider:
		_hud_bar.set_value(_value_slider.value, false)
	if _world_value_slider and _world_bar:
		_world_bar.set_value(_world_value_slider.value, false)

func _sync_ui_from_style() -> void:
	if _roundness_slider:
		_roundness_slider.value = _style.roundness
	if _border_slider:
		_border_slider.value = _style.border_thickness
	if _anim_duration_slider:
		_anim_duration_slider.value = _style.animation_duration
	if _opt_label_pos:
		_opt_label_pos.selected = clampi(_style.label_position, 0, _opt_label_pos.item_count - 1)
	if _opt_icon_pos:
		_opt_icon_pos.selected = clampi(_style.icon_position, 0, _opt_icon_pos.item_count - 1)
	if _opt_gradient_dir:
		_opt_gradient_dir.selected = clampi(_style.gradient_direction, 0, _opt_gradient_dir.item_count - 1)

func _build_world_section() -> void:
	var viewport_container = SubViewportContainer.new()
	viewport_container.set_anchors_preset(Control.PRESET_TOP_LEFT)
	viewport_container.custom_minimum_size = Vector2(400, 220)
	viewport_container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	viewport_container.stretch = true
	_vbox.add_child(viewport_container)

	var viewport = SubViewport.new()
	viewport.size = Vector2i(400, 220)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport_container.add_child(viewport)

	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.18, 0.18, 0.2, 1)
	viewport.add_child(bg)

	var world_root = Node2D.new()
	viewport.add_child(world_root)

	_world_character = Node2D.new()
	_world_character.position = Vector2(200, 160)
	world_root.add_child(_world_character)
	var char_rect = Polygon2D.new()
	char_rect.polygon = PackedVector2Array([
		Vector2(-20, 0), Vector2(20, 0), Vector2(15, 40), Vector2(-15, 40)
	])
	char_rect.color = Color(0.4, 0.5, 0.7, 1)
	_world_character.add_child(char_rect)

	_world_bar = HealthBarX2D.new()
	_world_bar.bar_size = Vector2(120, 20)
	_world_bar.style = _style
	_world_bar.follow_target = _world_character
	_world_bar.follow_offset = Vector2(0, -48)
	_world_bar.value = 100
	_world_bar.z_index = 10
	world_root.add_child(_world_bar)
	_world_bar.position = Vector2.ZERO

	_world_value_slider = _add_slider("World bar value", 0, 100, 100, _on_world_value_slider_changed, 1.0)
	_world_offset_y_slider = _add_slider("World bar Y offset", -80, 20, -48, _on_world_offset_y_changed, 1.0)

	var move_row = HBoxContainer.new()
	move_row.add_child(Label.new())
	(move_row.get_child(0) as Label).text = "Move character (X): "
	var move_slider = HSlider.new()
	move_slider.min_value = 50
	move_slider.max_value = 350
	move_slider.value = 200
	move_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	move_slider.value_changed.connect(func(v): _world_character.position.x = v)
	move_row.add_child(move_slider)
	_vbox.add_child(move_row)

func _on_world_value_slider_changed(v: float) -> void:
	if _world_bar:
		_world_bar.set_value(v, _style.animation_enabled)

func _on_world_offset_y_changed(v: float) -> void:
	if _world_bar:
		_world_bar.follow_offset = Vector2(_world_bar.follow_offset.x, v)

func _add_reset_button() -> void:
	var btn = Button.new()
	btn.text = "Reset to Defaults"
	btn.pressed.connect(_on_reset_pressed)
	_vbox.add_child(btn)

func _on_reset_pressed() -> void:
	_style = HealthBarXStyle.new()
	if _DEMO_ICON_TEXTURE:
		_style.icon_texture = _DEMO_ICON_TEXTURE
	_hud_bar.style = _style
	if _world_bar:
		_world_bar.style = _style
	if _value_slider:
		_value_slider.value = 100
	if _world_value_slider:
		_world_value_slider.value = 100
	_hud_bar.set_value(100, false)
	if _world_bar:
		_world_bar.set_value(100, false)
	_queue_redraw_bars()
