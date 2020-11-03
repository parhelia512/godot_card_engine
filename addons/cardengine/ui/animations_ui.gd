tool
class_name AnimationsUi
extends Control

var _main_ui: CardEngineUI = null
var _selected_anim: int = -1
var _opened_anim: AnimationData = null

onready var _manager = CardEngine.anim()
onready var _anim_list = $AnimationsLayout/Toolbar/AnimSelect
onready var _edit_btn = $AnimationsLayout/Toolbar/EditBtn
onready var _delete_btn = $AnimationsLayout/Toolbar/DeleteBtn
onready var _save_btn = $AnimationsLayout/Toolbar/SaveBtn
onready var _reset_btn = $AnimationsLayout/Toolbar/ResetBtn
onready var _pos_seq = $AnimationsLayout/AnimEditLayout/PosSeqScroll/PosSeqLayout
onready var _scale_seq = $AnimationsLayout/AnimEditLayout/ScaleSeqScroll/ScaleSeqLayout
onready var _rot_seq = $AnimationsLayout/AnimEditLayout/RotSeqScroll/RotSeqLayout


func _ready():
	_manager.connect("changed", self, "_on_Animations_changed")


func set_main_ui(ui: CardEngineUI) -> void:
	_main_ui = ui


func delete_animation() -> void:
	if yield():
		_manager.delete_animation(_anim_list.get_item_metadata(_selected_anim))
		_select_anim(0)


func _select_anim(index: int) -> void:
	_anim_list.select(index)
	
	if index > 0:
		_selected_anim = index
		_opened_anim = _manager.get_animation(
			_anim_list.get_item_metadata(_selected_anim))
		_edit_btn.disabled = false
		_save_btn.disabled = false
		_reset_btn.disabled = false
		_delete_btn.disabled = false
		_load_animation()
	else:
		_selected_anim = -1
		_opened_anim = null
		_edit_btn.disabled = true
		_save_btn.disabled = true
		_reset_btn.disabled = true
		_delete_btn.disabled = true
		_clear_animation()


func _select_anim_by_id(id: String) -> void:
	for index in range(_anim_list.get_item_count()):
		if _anim_list.get_item_metadata(index) == id:
			_select_anim(index)
			return


func _load_animation() -> void:
	_clear_animation()
	
	var pos_steps = _opened_anim.position_seq()
	var scale_steps = _opened_anim.scale_seq()
	var rot_steps = _opened_anim.rotation_seq()
	
	_load_sequence(pos_steps, "pos", _pos_seq)
	_load_sequence(scale_steps, "scale", _scale_seq)
	_load_sequence(rot_steps, "rot", _rot_seq)


func _load_sequence(seq: Array, type: String, layout: Control) -> void:
	if seq.empty():
		var btn = Button.new()
		btn.text = "Initialize"
		layout.add_child(btn)
		btn.connect("pressed", self, "_on_InitBtn_pressed", [type])
	else:
		var index := 0
		for step in seq:
			var is_last = index == seq.size()-1
			if step.transi != null:
				var btn = Button.new()
				btn.text = "%dms %s %s" % [
					step.transi.duration * 1000.0,
					_transi_type_display(step.transi.type),
					_transi_easing_display(step.transi.easing)]
				btn.disabled = not step.editable_transi
				layout.add_child(btn)
			
			if step.val != null:
				var btn = Button.new()
				if type == "pos":
					match step.val.mode:
						StepValue.Mode.INITIAL:
							btn.text = "init(0.0, 0.0)"
						StepValue.Mode.FIXED:
							btn.text = "(%.1f, %.1f)" % [
								step.val.vec_val.x,
								step.val.vec_val.y]
						StepValue.Mode.RANDOM:
							btn.text = "rand(%.1f-%.1f, %.1f-%.1f)" % [
								step.val.vec_val.x,
								step.val.vec_range.x,
								step.val.vec_val.y,
								step.val.vec_range.y]
				elif type == "scale":
					match step.val.mode:
						StepValue.Mode.INITIAL:
							btn.text = "init(1.0, 1.0)"
						StepValue.Mode.FIXED:
							btn.text = "(%.1f, %.1f)" % [
								step.val.vec_val.x,
								step.val.vec_val.y]
						StepValue.Mode.RANDOM:
							btn.text = "rand(%.1f-%.1f, %.1f-%.1f)" % [
								step.val.vec_val.x,
								step.val.vec_range.x,
								step.val.vec_val.y,
								step.val.vec_range.y]
				elif type == "rot":
					match step.val.mode:
						StepValue.Mode.INITIAL:
							btn.text = "init(0.0°)"
						StepValue.Mode.FIXED:
							btn.text = "%.1f°" % step.val.num_val
						StepValue.Mode.RANDOM:
							btn.text = "rand(%.1f°-%.1f°)" % [
								step.val.num_val,
								step.val.num_range]
				btn.disabled = not step.editable_val
				layout.add_child(btn)
			
			if not is_last:
				var lbl = Label.new()
				lbl.text = ">"
				layout.add_child(lbl)
			
			index += 1
		var btn = Button.new()
		btn.text = "Clear sequence"
		layout.add_child(btn)
		btn.connect("pressed", self, "_on_ClearSeqBtn_pressed", [type])


func _clear_animation() -> void:
	Utils.delete_all_children(_pos_seq)
	Utils.delete_all_children(_scale_seq)
	Utils.delete_all_children(_rot_seq)


func _transi_type_display(type: int) -> String:
	match type:
		Tween.TRANS_LINEAR:
			return "Linear"
		Tween.TRANS_SINE:
			return "Sine"
		Tween.TRANS_QUINT:
			return "Quint"
		Tween.TRANS_QUART:
			return "Quart"
		Tween.TRANS_QUAD:
			return "Quad"
		Tween.TRANS_EXPO:
			return "Expo"
		Tween.TRANS_ELASTIC:
			return "Elastic"
		Tween.TRANS_CUBIC:
			return "Cubic"
		Tween.TRANS_CIRC:
			return "Circ"
		Tween.TRANS_BOUNCE:
			return "Bounce"
		Tween.TRANS_BACK:
			return "Back"
		_:
			return "None"


func _transi_easing_display(easing: int) -> String:
	match easing:
		Tween.EASE_IN:
			return "In"
		Tween.EASE_OUT:
			return "Out"
		Tween.EASE_IN_OUT:
			return "In/Out"
		Tween.EASE_OUT_IN:
			return "Out/In"
		_:
			return "None"


func _val_mode_display(mode: int) -> String:
	match mode:
		StepValue.Mode.INITIAL:
			return "Initial"
		StepValue.Mode.FIXED:
			return "Fixed"
		StepValue.Mode.RANDOM:
			return "Random"
		_:
			return "None"


func _on_Animations_changed() -> void:
	if _anim_list == null:
		return

	_anim_list.clear()
	
	_anim_list.add_item("Choose...")
	_anim_list.set_item_disabled(0, true)
	_select_anim(0)
	
	var animations = _manager.animations()
	var index: int = 1
	for id in animations:
		var anim = animations[id]
		_anim_list.add_item("%s (%s)" % [anim.name, anim.id])
		_anim_list.set_item_metadata(index, anim.id)
		
		index += 1


func _on_NewAnimationDialog_form_validated(form) -> void:
	if form["edit"]:
		_opened_anim.name = form["name"]
		_manager.update_animation(_opened_anim)
	else:
		_manager.create_animation(AnimationData.new(form["id"], form["name"]))
	
	_select_anim_by_id(form["id"])


func _on_AnimSelect_item_selected(index: int) -> void:
	_select_anim(index)


func _on_CreateBtn_pressed() -> void:
	_main_ui.show_new_animation_dialog()


func _on_EditBtn_pressed() -> void:
	var anim = _manager.get_animation(_anim_list.get_item_metadata(_selected_anim))
	_main_ui.show_new_animation_dialog({"id": anim.id, "name": anim.name})


func _on_DeleteBtn_pressed() -> void:
	_main_ui.show_confirmation_dialog(
			"Delete animation", funcref(self, "delete_animation"))


func _on_SaveBtn_pressed() -> void:
	var id = _opened_anim.id
	_manager.update_animation(_opened_anim)
	_select_anim_by_id(id)


func _on_InitBtn_pressed(seq: String) -> void:
	match seq:
		"pos":
			_opened_anim.init_position_seq()
		"scale":
			_opened_anim.init_scale_seq()
		"rot":
			_opened_anim.init_rotation_seq()
		_:
			pass
	
	_load_animation()


func _on_ClearSeqBtn_pressed(seq: String) -> void:
	match seq:
		"pos":
			_opened_anim.clear_position_seq()
		"scale":
			_opened_anim.clear_scale_seq()
		"rot":
			_opened_anim.clear_rotation_seq()
		_:
			pass
	
	_load_animation()


func _on_ResetBtn_pressed() -> void:
	_opened_anim = _manager.reset_animation(_opened_anim)
	_load_animation()
