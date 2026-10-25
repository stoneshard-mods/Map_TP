/// Map_TP — localized UI text: English / Chinese / Russian / Japanese / Korean.
/// Map_TP — 界面文本：英 / 中 / 俄 / 日 / 韩。
/// Unknown keys are returned unchanged, and any language falls back to English.
/// 未知键原样返回；任何语言缺项时回退英文。
/// (The body reads parameters via argumentN because the compiler renames declared params.)
/// 函数体用 argumentN 取参（编译器会把形参改名）。
function scr_msl_maptp_tr(_key)
{
    var _key0 = argument0;
    var _lang = scr_msl_maptp_lang();

    switch (_key0)
    {
        case "hint":
            if (_lang == "zh") return "左键：传送";
            if (_lang == "ru") return "ЛКМ: телепорт";
            if (_lang == "ja") return "左クリック：転送";
            if (_lang == "ko") return "좌클릭: 이동";
            return "Left-click: teleport";

        case "title":
            if (_lang == "zh") return "传送";
            if (_lang == "ru") return "Телепорт";
            if (_lang == "ja") return "転送";
            if (_lang == "ko") return "이동";
            return "Teleport";

        case "corner_tl":
            if (_lang == "zh") return "左上角";
            if (_lang == "ru") return "Верхний левый угол";
            if (_lang == "ja") return "左上隅";
            if (_lang == "ko") return "좌측 상단";
            return "Top-left corner";

        case "corner_tr":
            if (_lang == "zh") return "右上角";
            if (_lang == "ru") return "Верхний правый угол";
            if (_lang == "ja") return "右上隅";
            if (_lang == "ko") return "우측 상단";
            return "Top-right corner";

        case "corner_bl":
            if (_lang == "zh") return "左下角";
            if (_lang == "ru") return "Нижний левый угол";
            if (_lang == "ja") return "左下隅";
            if (_lang == "ko") return "좌측 하단";
            return "Bottom-left corner";

        case "corner_br":
            if (_lang == "zh") return "右下角";
            if (_lang == "ru") return "Нижний правый угол";
            if (_lang == "ja") return "右下隅";
            if (_lang == "ko") return "우측 하단";
            return "Bottom-right corner";

        case "cancel":
            if (_lang == "zh") return "取消";
            if (_lang == "ru") return "Отмена";
            if (_lang == "ja") return "キャンセル";
            if (_lang == "ko") return "취소";
            return "Cancel";

        case "teleporting":
            if (_lang == "zh") return "传送中…";
            if (_lang == "ru") return "Телепортация…";
            if (_lang == "ja") return "転送中…";
            if (_lang == "ko") return "이동 중…";
            return "Teleporting…";

        case "blocked":
            if (_lang == "zh") return "该格无法传送";
            if (_lang == "ru") return "Эта клетка недоступна";
            if (_lang == "ja") return "このマスは使えません";
            if (_lang == "ko") return "이 타일은 사용할 수 없습니다";
            return "This tile cannot be used";

        case "not_map":
            if (_lang == "zh") return "当前不在世界地图";
            if (_lang == "ru") return "Вы не на карте мира";
            if (_lang == "ja") return "ワールドマップ上ではありません";
            if (_lang == "ko") return "월드 맵이 아닙니다";
            return "Not on the world map";

        case "here":
            if (_lang == "zh") return "已经在这一格";
            if (_lang == "ru") return "Вы уже здесь";
            if (_lang == "ja") return "すでにこのマスにいます";
            if (_lang == "ko") return "이미 이 타일에 있습니다";
            return "Already on this tile";

        case "bad_room":
            if (_lang == "zh") return "目标房间无效";
            if (_lang == "ru") return "Неверная целевая комната";
            if (_lang == "ja") return "無効な部屋です";
            if (_lang == "ko") return "잘못된 방입니다";
            return "Invalid target room";

        case "timeout":
            if (_lang == "zh") return "传送超时";
            if (_lang == "ru") return "Время телепорта истекло";
            if (_lang == "ja") return "転送がタイムアウトしました";
            if (_lang == "ko") return "이동 시간이 초과되었습니다";
            return "Teleport timed out";
    }

    return _key0;
}
