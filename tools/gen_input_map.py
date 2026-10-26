"""Genera la sección [input] de project.godot (teclado + mando)."""
KEYS = {"A":65,"D":68,"W":87,"S":83,"J":74,"K":75,"L":76,"I":73,"SPACE":32,
        "ESC":4194305,"LEFT":4194319,"UP":4194320,"RIGHT":4194321,"DOWN":4194322,"F3":4194334}
# (teclas, botones de mando, ejes (eje, valor))
ACTIONS = {
    "move_left":  (["A","LEFT"], [13], [(0,-1.0)]),
    "move_right": (["D","RIGHT"], [14], [(0,1.0)]),
    "move_up":    (["W","UP"], [11], [(1,-1.0)]),
    "move_down":  (["S","DOWN"], [12], [(1,1.0)]),
    "jump":       (["SPACE"], [0], []),
    "attack":     (["J"], [2], []),
    "dash":       (["K"], [10], []),
    "heal":       (["L"], [1], []),
    "puddle":     (["I"], [9], []),
    "interact":   (["W","UP"], [3], []),
    "pause":      (["ESC"], [6], []),
    "debug_fps":  (["F3"], [], []),
}
def key(code):
    return ('Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,'
            '"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,'
            f'"keycode":0,"physical_keycode":{code},"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)')
def btn(i):
    return ('Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,'
            f'"button_index":{i},"pressure":0.0,"pressed":true,"script":null)')
def axis(a, v):
    return ('Object(InputEventJoypadMotion,"resource_local_to_scene":false,"resource_name":"","device":-1,'
            f'"axis":{a},"axis_value":{v},"script":null)')
out = ["[input]", ""]
for name, (ks, bs, axs) in ACTIONS.items():
    evs = [key(KEYS[k]) for k in ks] + [btn(b) for b in bs] + [axis(a, v) for a, v in axs]
    out.append(name + "={")
    out.append('"deadzone": 0.25,')
    out.append('"events": [' + "\n, ".join(evs) + "\n]")
    out.append("}")
print("\n".join(out))
