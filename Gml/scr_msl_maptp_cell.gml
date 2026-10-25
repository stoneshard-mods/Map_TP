/// Map_TP — screen coordinates → world tile.
/// Map_TP — 屏幕坐标 → 世界格。
/// guiMouse is in the GUI camera's absolute space (its origin may be -5000,-5000),
/// so subtract the cameraGUI view origin first, then apply the map offset.
/// guiMouse 是 GUI 相机的绝对坐标（相机原点可能是 -5000,-5000），
/// 所以要先减去 cameraGUI 的视图原点，再叠加地图偏移。
function scr_msl_maptp_cell(_mx, _my)
{
    var _x = argument0;
    var _y = argument1;

    // No world map instance → no valid tile.
    // 没有大地图实例 → 无有效格。
    var _map = instance_find(o_globalmap, 0);
    if (!instance_exists(_map)) return [-1, -1];

    // Tile size in pixels = base tile (52) * current map zoom scale.
    // 单格像素尺寸 = 基础格(52) * 当前地图缩放比例。
    var _cell = 52 * _map.mapScale;
    if (_cell <= 0) return [-1, -1];

    var _camX = camera_get_view_x(global.cameraGUI);
    var _camY = camera_get_view_y(global.cameraGUI);

    return [floor((_x - _camX + _map.mapOffsetX) / _cell), floor((_y - _camY + _map.mapOffsetY) / _cell)];
}
