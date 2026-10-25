/// Map_TP — UI language, either "zh" or "en".
/// Map_TP — 界面语言，取值 "zh" 或 "en"。
/// The language is picked in the launcher's in-game settings (MODS tab → Map_TP → Language),
/// which stores global.msl_maptp_lang_choice as "Auto" / "English" / "中文".
/// 语言在启动器的游戏内设置里选（MODS 页 → Map_TP → Language），
/// 对应全局变量 msl_maptp_lang_choice："Auto" / "English" / "中文"。
/// "Auto" follows the OS locale (zh* → Chinese, everything else → English).
/// "Auto" 跟随系统语言（zh* 用中文，其余用英文）。
function scr_msl_maptp_lang()
{
    var _choice = variable_global_exists("msl_maptp_lang_choice") ? global.msl_maptp_lang_choice : "Auto";

    if (string_pos("中", _choice) > 0) return "zh";
    if (string_pos("English", _choice) > 0) return "en";

    // Auto: resolve the OS locale once and keep it.
    // Auto：系统语言只判定一次并缓存。
    if (!variable_global_exists("msl_maptp_lang_auto"))
    {
        global.msl_maptp_lang_auto = (string_pos("zh", string_lower(os_get_language())) > 0) ? "zh" : "en";
    }

    return global.msl_maptp_lang_auto;
}
