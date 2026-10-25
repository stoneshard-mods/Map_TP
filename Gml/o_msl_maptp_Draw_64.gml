// Map_TP Draw: native-style teleport menu (reuses the game's right-click menu border sprites).
// Map_TP 绘制：原生风格的传送菜单（复用游戏右键菜单的边框精灵）。

var _camX = camera_get_view_x(global.cameraGUI);
var _camY = camera_get_view_y(global.cameraGUI);
var _camW = global.cameraWidth;
var _camH = global.cameraHeight;

// Teleport in progress: show a centered status line and skip the menu.
// 传送进行中：屏幕上方显示状态文字，跳过菜单绘制。
if (phase != -1)
{
    scr_drawText(_camX + (_camW / 2), _camY + 60, scr_msl_maptp_tr("teleporting"), make_color_rgb(235, 215, 165), 1, 1, global.f_digits, 0.5, 1);
    exit;
}

// Nothing to draw while the world map is closed.
// 大地图未打开时无需绘制。
if (!instance_exists(o_globalmap))
    exit;

// The journal embeds its own small map: no teleport UI there.
// 日志里内嵌的是小地图：不显示传送界面。
var _mapInstance = instance_find(o_globalmap, 0);
if (instance_exists(_mapInstance) && _mapInstance.journal != -4)
    exit;

// Inside a dungeon the mod is inactive: show the reason instead of the teleport hint.
// 地牢内本模组不生效：显示原因，而不是“左键：传送”。
if (variable_global_exists("floor_counter") && global.floor_counter != 0)
{
    scr_drawText(_camX + 12, _camY + 16, scr_msl_maptp_tr("in_dungeon"), make_color_rgb(190, 170, 140), 0, 1, global.f_dmg, 0.5, 0.8);
    exit;
}

// Optional top-left notice (errors / hints).
// 左上角可选提示（错误/提示）。
if (noticeTimer > 0 && notice != "")
{
    scr_drawText(_camX + 12, _camY + 32, notice, make_color_rgb(225, 110, 110), 0, 1, global.f_dmg, 0.5, 1);
}

scr_drawText(_camX + 12, _camY + 16, scr_msl_maptp_tr("hint"), make_color_rgb(190, 180, 160), 0, 1, global.f_dmg, 0.5, 0.7);

if (!menuOpen)
    exit;

var _panelH = 30 + menuHeaderH + menuRowH * menuRows;
var _x = menuPX;
var _y = menuPY;
var _w = menuW;

// Background + border (matches the game's native right-click menu)
// 背景 + 边框（与游戏原生右键菜单一致）
draw_sprite_ext(s_point, 0, _x + 5, _y + 5, _w - 10, _panelH - 10, 0, make_color_rgb(27, 25, 38), 1);
draw_sprite_ext(s_gui_context_top_line, 0, _x + 1, _y, _w - 2, 1, 0, c_white, 1);
draw_sprite_ext(s_gui_context_bot_line, 0, _x + 1, _y + _panelH - 14, _w - 2, 1, 0, c_white, 1);
draw_sprite_ext(s_gui_context_mid_line_left, 0, _x, _y + 2, 1, (_panelH - 4) / 3, 0, c_white, 1);
draw_sprite_ext(s_gui_context_mid_line_right, 0, _x + _w - 1, _y + 2, 1, (_panelH - 4) / 3, 0, c_white, 1);
draw_sprite(s_gui_context_topleft, 0, _x, _y);
draw_sprite(s_gui_context_topmid, 0, _x + (_w / 2), _y);
draw_sprite(s_gui_context_topright, 0, _x + _w - 1, _y);
draw_sprite(s_gui_context_botleft, 0, _x, _y + _panelH - 14);
draw_sprite(s_gui_context_botmid, 0, _x + (_w / 2), _y + _panelH - 14);
draw_sprite(s_gui_context_botright, 0, _x + _w - 1, _y + _panelH - 14);

// Title (target tile coordinates)
// 标题（目标格坐标）
scr_drawText(_x + 10, _y + 21, scr_msl_maptp_tr("title") + " " + string(menuGridX) + "," + string(menuGridY), make_color_rgb(160, 150, 130), 0, 1, global.f_dmg, 0.5, 1);

// Full-word labels instead of TL / TR / BL / BR abbreviations.
// 使用完整的单词标签，不再用 TL / TR / BL / BR 这类缩写。
var _labels =
[
    scr_msl_maptp_tr("corner_tl"),
    scr_msl_maptp_tr("corner_tr"),
    scr_msl_maptp_tr("corner_bl"),
    scr_msl_maptp_tr("corner_br"),
    scr_msl_maptp_tr("cancel")
];
var _hover = scr_msl_maptp_menu_index(global.guiMouseX, global.guiMouseY);
var _rowY0 = _y + 12 + menuHeaderH;

// menuRows rows; highlight the one currently under the mouse.
// 共 menuRows 行；高亮鼠标当前所在行。
for (var _i = 0; _i < menuRows; _i++)
{
    var _rowY = _rowY0 + _i * menuRowH;

    if (_hover == _i)
    {
        draw_set_alpha(0.18);
        draw_set_color(make_color_rgb(200, 170, 90));
        draw_rectangle(_x + 6, _rowY, _x + _w - 6, _rowY + menuRowH, false);
        draw_set_alpha(1);
    }

    scr_drawText(_x + 12, _rowY + menuRowH / 2, _labels[_i], make_color_rgb(225, 215, 195), 0, 1, global.f_dmg, 0.5, 1);
}

draw_set_color(c_white);
draw_set_alpha(1);
