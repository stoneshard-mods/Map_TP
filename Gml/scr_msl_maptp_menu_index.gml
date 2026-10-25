/// Map_TP — menu hit-test. The menu has 5 rows: top-left / top-right / bottom-left / bottom-right / cancel.
/// Map_TP — 菜单命中测试。菜单 5 行：左上 / 右上 / 左下 / 右下 / 取消。
/// (The body reads parameters via argumentN because the compiler renames declared params.)
/// 函数体用 argumentN 取参（编译器会把形参改名）。
function scr_msl_maptp_menu_index(_mx, _my)
{
    var _px = argument0;
    var _py = argument1;

    var _x0 = menuPX;
    var _y0 = menuPY + 12 + menuHeaderH;

    // Outside the menu width or above the first row → no hit.
    // 超出菜单宽度或首行之上 → 未命中。
    if (_px < _x0 || _px > _x0 + menuW) return -1;
    if (_py < _y0) return -1;

    // Which of the 5 rows the pointer falls on.
    // 指针落在 5 行中的第几行。
    var _index = floor((_py - _y0) / menuRowH);
    if (_index < 0 || _index > 4) return -1;

    return _index;
}
