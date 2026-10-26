extends Node
## Guarda y carga GameState en JSON. Escritura atómica y con versión.

const VERSION := 1

var save_dir: String = "user://"


func save(slot: int) -> bool:
	var data := GameState.to_dict()
	data["version"] = VERSION
	var path := _path(slot)
	var tmp := path + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		push_warning("SaveManager: no se pudo escribir %s" % tmp)
		return false
	f.store_string(JSON.stringify(data, "\t"))
	f.close()
	if DirAccess.rename_absolute(tmp, path) != OK:
		push_warning("SaveManager: no se pudo renombrar %s" % tmp)
		return false
	return true


func load(slot: int) -> bool:
	var path := _path(slot)
	if not FileAccess.file_exists(path):
		GameState.reset()
		return false
	var text := FileAccess.get_file_as_string(path)
	var json := JSON.new()
	if json.parse(text) != OK or not (json.data is Dictionary):
		push_warning("SaveManager: partida corrupta en %s; se empieza de nuevo" % path)
		GameState.reset()
		return false
	var data: Dictionary = json.data
	if int(data.get("version", -1)) != VERSION:
		push_warning("SaveManager: versión de partida incompatible; se empieza de nuevo")
		GameState.reset()
		return false
	GameState.from_dict(data)
	return true


func has_save(slot: int) -> bool:
	return FileAccess.file_exists(_path(slot))


func _path(slot: int) -> String:
	return save_dir.path_join("save_%d.json" % slot)
