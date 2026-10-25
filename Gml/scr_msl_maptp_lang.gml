/// Map_TP — UI language: "en" / "zh" / "ru" / "ja" / "ko".
/// Map_TP — 界面语言："en" / "zh" / "ru" / "ja" / "ko"。
/// The language is picked in the launcher's in-game settings (MODS tab → Map_TP → Language),
/// which stores global.msl_maptp_lang_choice as one of the option labels below.
/// 语言在启动器的游戏内设置里选（MODS 页 → Map_TP → Language），
/// global.msl_maptp_lang_choice 存的就是下拉框里的选项文本。
/// "Auto" follows the OS locale; unsupported locales fall back to English.
/// "Auto" 跟随系统语言，没有对应语言时回退英文。
function scr_msl_maptp_lang()
{
    var _choice = variable_global_exists("msl_maptp_lang_choice") ? global.msl_maptp_lang_choice : "Auto";

    if (string_pos("中", _choice) > 0) return "zh";
    if (string_pos("Рус", _choice) > 0) return "ru";
    if (string_pos("日本", _choice) > 0) return "ja";
    if (string_pos("한국", _choice) > 0) return "ko";
    if (string_pos("English", _choice) > 0) return "en";

    // Auto: resolve the OS locale once and keep it.
    // Auto：系统语言只判定一次并缓存。
    if (!variable_global_exists("msl_maptp_lang_auto"))
    {
        var _os = string_lower(os_get_language());
        var _auto = "en";

        if (string_pos("zh", _os) > 0) _auto = "zh";
        else if (string_pos("ru", _os) > 0) _auto = "ru";
        else if (string_pos("ja", _os) > 0) _auto = "ja";
        else if (string_pos("ko", _os) > 0) _auto = "ko";

        global.msl_maptp_lang_auto = _auto;
    }

    return global.msl_maptp_lang_auto;
}
