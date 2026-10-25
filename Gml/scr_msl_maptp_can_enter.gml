/// Map_TP — whether this tile can be a teleport target.
/// Map_TP — 这一格能否作为传送目标。
/// (The body reads parameters via argumentN because the compiler renames declared params.)
/// 函数体用 argumentN 取参（编译器会把形参改名）。
function scr_msl_maptp_can_enter(_gx, _gy)
{
    var _cx = argument0;
    var _cy = argument1;

    // Exclude the outermost border so the target always has room space around it.
    // 排除最外边框，保证目标格周围始终有可用的房间空间。
    if (_cx < 1 || _cy < 1) return false;
    if (_cx >= global.worldWidth - 1) return false;
    if (_cy >= global.worldHeight - 1) return false;

    // Mountains are unreachable.
    // 山地不可到达。
    if (scr_globaltile_get("Biome", _cx, _cy, "N/A") == "Mount") return false;

    // Tiles with collision/blocking are not valid targets.
    // 有碰撞/阻挡的格不能作为目标。
    if (scr_globaltile_get("Collision", _cx, _cy, false)) return false;

    // The tile must resolve to a real room asset.
    // 该格必须能解析到有效的房间资产。
    var _type = scr_globaltile_get("room_type", _cx, _cy, "");
    if (_type == "" || _type == "N/A") return false;

    return __asset_get_index(_type) > 0;
}
