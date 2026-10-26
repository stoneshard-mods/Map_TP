// Map_TP Step: landing correction + input handling.
// Map_TP 步事件：落点修正 + 输入处理。

if (noticeTimer > 0)
    noticeTimer -= 1;

// ---- Landing correction: after the target room loads, if the landing is in wall/water,
//      move the player to the nearest free tile -------------------------------------
// ---- 落点修正：房间加载后若落在墙/水里，挪到最近的空地块 ---------------------------
if (phase == 4)
{
    phaseTimer += 1;

    if (room == targetRoom)
    {
        var _gen = instance_find(o_biome_generation_controller, 0);
        var _ready = !instance_exists(_gen) || (_gen.endTime != undefined) || (phaseTimer > 120);

        if (phaseTimer > 8 && _ready && instance_exists(o_player))
        {
            var _px = o_player.x;
            var _py = o_player.y;
            var _nudged = false;

            if (scr_pat_prototype(_px, _py, 0, 0))
            {
                for (var _r = 1; _r <= 12 && !_nudged; _r++)
                {
                    for (var _ix = -_r; _ix <= _r && !_nudged; _ix++)
                    {
                        for (var _iy = -_r; _iy <= _r && !_nudged; _iy++)
                        {
                            if (abs(_ix) != _r && abs(_iy) != _r) continue;

                            var _tx = _px + _ix * 26;
                            var _ty = _py + _iy * 26;

                            if (_tx < 13 || _ty < 13 || _tx > room_width - 13 || _ty > room_height - 13) continue;
                            if (scr_pat_prototype(_tx, _ty, 0, 0)) continue;

                            global._msl_maptp_tx = _tx;
                            global._msl_maptp_ty = _ty;

                            with (o_player)
                                scr_invisible_teleport(global._msl_maptp_tx, global._msl_maptp_ty);

                            _nudged = true;
                        }
                    }
                }
            }

            var _fl = file_text_open_append("maptp_diag.txt");
            file_text_write_string(_fl, "landed: room=" + string(room) + " pos=" + string(_px) + "," + string(_py) + " nudged=" + string(_nudged) + "\n");
            file_text_close(_fl);

            phase = -1;
            phaseTimer = 0;
        }
    }
    else if (phaseTimer > 900)
    {
        notice = scr_msl_maptp_tr("timeout");
        noticeTimer = 180;
        phase = -1;
        phaseTimer = 0;
    }

    exit;
}

// ---- Legacy repair: stale dungeon floor counter -----------------------------------
// ---- 旧存档修复：地表残留的地牢层数 ------------------------------------------------
// Older builds left global.floor_counter at the dungeon floor after teleporting out, so
// the next single-floor dungeon generated floor-2 rooms and crashed in
// scr_dungeonChangeNodeRole -> ds_unique_object_get. Outside a generated dungeon room a
// non-zero value can never be valid, so reset it (and the derived locationFloor).
// 旧版本传送出地牢后会把 global.floor_counter 留成 1/2 带回地表，之后进单层地牢会按第
// 2 层取房间池，崩在 scr_dungeonChangeNodeRole -> ds_unique_object_get。不在程序生成
// 的地牢房里时，非 0 只可能是残留值，直接归零（并同步派生的 locationFloor）。
if (variable_global_exists("floor_counter") && global.floor_counter != 0)
{
    if (global.playerGridX != -4 && global.playerGridY != -4 && !instance_exists(o_dungeon_controller))
    {
        global.floor_counter = 0;

        if (variable_global_exists("locationFloor"))
            global.locationFloor = 0;
    }
}

// ---- Idle (world map not open) ----------------------------------------------------
// ---- 空闲（大地图未打开）----------------------------------------------------------
if (!instance_exists(o_globalmap))
{
    // Persistent controller: do nothing (and don't destroy itself) when the map is closed.
    // 控制器常驻：大地图没开时什么都不做，也不销毁自己。
    menuOpen = false;
    down = false;
    exit;
}

if (!variable_global_exists("guiMouseX"))
    exit;

// The journal embeds its own small map; clicks there must never teleport, and the
// offset/scale math below is only valid for the fullscreen world map.
// 日志里内嵌的是小地图：那里的点击不应触发传送（下面的偏移/缩放换算只适用于全屏大地图）。
var _mapInstance = instance_find(o_globalmap, 0);
if (instance_exists(_mapInstance) && _mapInstance.journal != -4)
{
    menuOpen = false;
    down = false;
    exit;
}

// ---- Menu open: handle clicks -----------------------------------------------------
// ---- 菜单已打开：处理点击 ----------------------------------------------------------
if (menuOpen)
{
    // Ignore the click that opened the menu.
    // 忽略打开菜单的那一次点击。
    if (justOpened)
    {
        justOpened = false;
        exit;
    }

    if (mouse_check_button_released(mb_left))
    {
        var _index = scr_msl_maptp_menu_index(global.guiMouseX, global.guiMouseY);

        // Rows 0-3 are the four corners, row 4 cancels; clicking anywhere else closes the menu.
        // 第 0-3 行为四个角落，第 4 行取消；点击其它区域则关闭菜单。
        if (_index >= 0 && _index <= 3)
        {
            scr_msl_maptp_begin(menuGridX, menuGridY, _index);
        }
        else
        {
            menuOpen = false;
        }
    }

    exit;
}

// ---- Left-click on the map: open the secondary menu --------------------------------
// ---- 左键点地图：展开二级菜单 ------------------------------------------------------
if (mouse_check_button_pressed(mb_left))
{
    down = true;
    downX = global.guiMouseX;
    downY = global.guiMouseY;
}

if (!mouse_check_button_released(mb_left))
    exit;

var _wasDown = down;
down = false;

if (!_wasDown)
    exit;

// A drag is not a click (map panning uses the middle button; this just guards against mis-taps).
// 拖动地图不算点击（地图拖动本身用鼠标中键，这里只防误触）。
if (point_distance(downX, downY, global.guiMouseX, global.guiMouseY) > 8)
    exit;

var _cell = scr_msl_maptp_cell(global.guiMouseX, global.guiMouseY);
var _gx = _cell[0];
var _gy = _cell[1];

// Whether the clicked tile is in bounds and can be a teleport target.
// 点击格是否在地图范围内且可作为传送目标。
var _inBounds = (_gx >= 0 && _gy >= 0 && _gx < global.worldWidth && _gy < global.worldHeight);
var _can = _inBounds && scr_msl_maptp_can_enter(_gx, _gy);

if (!_inBounds)
    exit;

// No menu inside a dungeon: teleporting out would leave global.floor_counter stale and
// break the next dungeon's floor selection (see scr_msl_maptp_begin).
// 地牢内不弹菜单：传送出去会把 global.floor_counter 留成错层，破坏之后的地牢楼层选择
// （详见 scr_msl_maptp_begin）。
if (variable_global_exists("floor_counter") && global.floor_counter != 0)
{
    notice = scr_msl_maptp_tr("in_dungeon");
    noticeTimer = 90;
    exit;
}

if (!_can)
{
    notice = scr_msl_maptp_tr("blocked");
    noticeTimer = 90;
    exit;
}

menuGridX = _gx;
menuGridY = _gy;

// Cancel the map's own "move to clicked tile" animation so it doesn't drift under the menu.
// 打开菜单时取消地图自己的“点哪移哪”动画，避免地图在菜单下面漂移。
var _map = instance_find(o_globalmap, 0);
if (instance_exists(_map))
{
    _map.mapTargetGridX = -4;
    _map.mapTargetGridY = -4;
}

var _camX = camera_get_view_x(global.cameraGUI);
var _camY = camera_get_view_y(global.cameraGUI);

menuPX = clamp(global.guiMouseX + 8, _camX + 8, max(_camX + 8, _camX + global.cameraWidth - menuW - 8));
menuPY = clamp(global.guiMouseY + 8, _camY + 8, max(_camY + 8, _camY + global.cameraHeight - (30 + menuHeaderH + menuRowH * menuRows) - 8));
menuOpen = true;
justOpened = true;
