/// Map_TP controller: created by o_globalmap's End Step while the world map is open; persistent.
/// Map_TP 控制器：打开大地图时由 o_globalmap 的 End Step 创建，persistent 常驻。
persistent = true;
visible = true;
// GUI camera depth order: o_guiRenderStart(-12000) → map(-12600) → this controller(-14900) → o_guiRenderEnd(-15000)
// GUI 相机 depth 绘制顺序：o_guiRenderStart(-12000) → 地图(-12600) → 本控制器(-14900) → o_guiRenderEnd(-15000)
depth = -14900;

// Menu state (sized to match the native right-click menu)
// 菜单状态（尺寸与原生右键菜单一致）
menuOpen = false;
justOpened = false;
menuGridX = -1;
menuGridY = -1;
menuPX = 0;
menuPY = 0;
menuW = 190;
menuRowH = 20;
menuHeaderH = 16;
// Rows: four corners + cancel. The UI language is chosen in the game settings (MODS tab).
// 行数：四个角落 + 取消。界面语言在游戏设置里选择（MODS 页）。
menuRows = 5;

// Mouse press tracking (to tell a click from a drag)
// 鼠标按下状态跟踪（用于区分点击与拖动）
down = false;
downX = 0;
downY = 0;

// Teleport state machine (phase 4 = waiting for the target room to finish loading)
// 过图状态机（phase == 4 表示等待目标房间加载完成）
phase = -1;
phaseTimer = 0;

// Current teleport target: tile / room / landing point
// 当前传送的目标：格 / 房间 / 落点
targetGridX = -1;
targetGridY = -1;
targetRoom = -4;
targetLocalX = 0;
targetLocalY = 0;

// On-screen notice (top-left hint / error message)
// 左上角提示信息（提示/错误）
notice = "";
noticeTimer = 0;
