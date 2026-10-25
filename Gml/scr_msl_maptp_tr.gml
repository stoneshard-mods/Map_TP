/// Map_TP — localized UI text (Chinese / English). Unknown keys are returned unchanged.
/// Map_TP — 界面文本的中英对照。未知键原样返回。
/// (The body reads parameters via argumentN because the compiler renames declared params.)
/// 函数体用 argumentN 取参（编译器会把形参改名）。
function scr_msl_maptp_tr(_key)
{
    var _key0 = argument0;
    var _zh = (scr_msl_maptp_lang() == "zh");

    switch (_key0)
    {
        case "hint":         return _zh ? "左键：传送" : "Left-click: teleport";
        case "title":        return _zh ? "传送" : "Teleport";
        case "corner_tl":    return _zh ? "左上角" : "Top-left corner";
        case "corner_tr":    return _zh ? "右上角" : "Top-right corner";
        case "corner_bl":    return _zh ? "左下角" : "Bottom-left corner";
        case "corner_br":    return _zh ? "右下角" : "Bottom-right corner";
        case "cancel":       return _zh ? "取消" : "Cancel";
        case "teleporting":  return _zh ? "传送中…" : "Teleporting…";
        case "blocked":      return _zh ? "该格无法传送" : "This tile cannot be used";
        case "not_map":      return _zh ? "当前不在世界地图" : "Not on the world map";
        case "here":         return _zh ? "已经在这一格" : "Already on this tile";
        case "bad_room":     return _zh ? "目标房间无效" : "Invalid target room";
        case "timeout":      return _zh ? "传送超时" : "Teleport timed out";
    }

    return _key0;
}
