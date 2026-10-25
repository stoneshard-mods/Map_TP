/// Map_TP — menu hit-test. The menu has menuRows rows: the four corners, the language switch, cancel.
/// Map_TP — 菜单命中测试。菜单共 menuRows 行：四个角落、语言切换、取消。
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

    // Which row of the menu the pointer falls on.
    // 指针落在菜单的第几行。
    var _index = floor((_py - _y0) / menuRowH);
    if (_index < 0 || _index >= menuRows) return -1;

    return _index;
}
