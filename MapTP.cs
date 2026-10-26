using ModShardLauncher;
using ModShardLauncher.Mods;
using UndertaleModLib.Models;

namespace MapTP;

/// <summary>
/// Map_TP: left-click a walkable world-map tile to open a secondary menu and teleport into
/// the target tile's room at the chosen corner (top-left / top-right / bottom-left / bottom-right).
/// Map_TP：大地图左键打开二级菜单，选择房间四角作为落点，直接传送到目标格所在房间。
/// It does not walk through a neighbouring o_tile_transition; instead it sets the world grid,
/// resolves the target room from that tile's room_type, writes the landing localX/localY and
/// lets the game regenerate the room (scr_smoothRoomChange / room_restart), keeping grid, room
/// and landing consistent. If the landing falls in wall/water, the Step event nudges the player
/// to the nearest free tile.
/// 实现不靠踩相邻格的 o_tile_transition，而是同时设置「格 + 房间 + 落点」后让游戏按目标格重新生成房间，
/// 保持自洽；若落点落在墙/水里，Step 事件会把角色挪到最近的可走格。
/// </summary>
public class MapTP : Mod
{
    public override string Name => "Map_TP";
    public override string Author => "Pixel32E-QQ:3566723459";
    public override string Description => "大地图左键打开二级菜单，按落点（房间四角）传送到选中的世界格；菜单支持中/英双语";
    public override string ShortDesc => "Teleport from the world map through real room transitions (Chinese/English UI)";
    public override string Version => "v0.5.0.0";

    // Keep the controller alive while the world map is open.
    // 打开大地图期间保证控制器实例存在。
    // (Appended to o_globalmap's End Step = Step subtype 2, a structured event independent of text order.)
    // （挂到 o_globalmap 的 End Step，即 Step 子类型 2，是结构化事件，不依赖文本插入位置。）
    // No diagnostics here: this runs every frame while the map is open, and the old
    // file_text write produced one line per frame in maptp_diag.txt.
    // 这里不再写诊断：该事件在打开地图期间每帧执行，旧的写文件会每帧追加一行。
    private const string CreateController =
        "if (!instance_exists(o_msl_maptp)) instance_create_depth(-50, -50, -14900, o_msl_maptp);";

    public override void PatchMod()
    {
        // Register the global script functions as GML functions, like the game's own scr_* ones.
        // 把全局脚本函数注册成 GML 函数（与游戏自带的 scr_* 一样）。
        // Order matters: a function must exist before another one calls it.
        // 顺序有影响：被调用的函数必须先注册。
        Msl.AddFunction(Code("scr_msl_maptp_lang.gml"), "scr_msl_maptp_lang");
        Msl.AddFunction(Code("scr_msl_maptp_tr.gml"), "scr_msl_maptp_tr");
        Msl.AddFunction(Code("scr_msl_maptp_cell.gml"), "scr_msl_maptp_cell");
        Msl.AddFunction(Code("scr_msl_maptp_can_enter.gml"), "scr_msl_maptp_can_enter");
        Msl.AddFunction(Code("scr_msl_maptp_menu_index.gml"), "scr_msl_maptp_menu_index");
        Msl.AddFunction(Code("scr_msl_maptp_begin.gml"), "scr_msl_maptp_begin");

        // World-map controller object: menu drawing, click handling and the teleport state machine.
        // 大地图控制器对象：负责菜单绘制、点击与过图状态机。
        Msl.AddObject("o_msl_maptp", spriteName: "", parentName: "", isVisible: true, isPersistent: true, isAwake: true);
        Msl.AddNewEvent("o_msl_maptp", Code("o_msl_maptp_Create.gml"), EventType.Create, 0);
        Msl.AddNewEvent("o_msl_maptp", Code("o_msl_maptp_Step.gml"), EventType.Step, 0);
        Msl.AddNewEvent("o_msl_maptp", Code("o_msl_maptp_Draw_64.gml"), EventType.Draw, 0);

        // While the map is open, its End Step keeps the controller instance alive.
        // 大地图打开期间由 o_globalmap 的 End Step 保证控制器存在。
        AddMapEndStep();

        // UI language picker in the launcher's in-game settings (MODS tab), the same mechanism
        // the Rusty mods use: a combobox bound to global.msl_maptp_lang_choice and persisted in
        // msl_menu_mod.ini, so no separate settings file is needed.
        // 界面语言选择放进启动器的游戏内设置（MODS 页），机制与 Rusty 系列模组相同：
        // 下拉框绑定 global.msl_maptp_lang_choice，选择存进 msl_menu_mod.ini，不需要单独配置文件。
        Msl.AddMenu(
            "Map_TP",
            new UIComponent(
                "Language / 语言",
                "msl_maptp_lang_choice",
                UIComponentType.ComboBox,
                new[] { "Auto", "English", "中文", "Русский", "日本語", "한국어" }));
    }

    // Make sure the controller gets created: hook o_globalmap's End Step, falling back to
    // o_globalmap_controller if the map object already has one.
    // 确保控制器被创建：挂到 o_globalmap 的 End Step（若其已有则退而挂到 o_globalmap_controller）。
    private static void AddMapEndStep()
    {
        UndertaleGameObject mapObject = Msl.GetObject("o_globalmap");

        // Avoid LINQ: the stock MSL is net6.0, and referencing System.Linq 10.0 makes the mod fail to load.
        // 不用 LINQ：原版 MSL 是 net6.0，mod 一旦引用 System.Linq 10.0 会在加载时失败。
        bool hasEndStep = HasEndStep(mapObject);

        if (hasEndStep)
        {
            // A few builds may already have an End Step: fall back to the map controller object.
            // 极少数版本可能已有 End Step：退而求其次挂到地图控制器上。
            mapObject = Msl.GetObject("o_globalmap_controller");
            hasEndStep = HasEndStep(mapObject);
        }

        if (!hasEndStep)
        {
            Msl.AddNewEvent(mapObject, CreateController, EventType.Step, 2);
        }
    }

    // Return true if the object already has a Step event with subtype 2 (End Step).
    // 若该对象已有子类型为 2（End Step）的 Step 事件，则返回 true。
    private static bool HasEndStep(UndertaleGameObject gameObject)
    {
        foreach (var stepEvent in gameObject.Events[(int)EventType.Step])
        {
            if (stepEvent.EventSubtype == 2)
            {
                return true;
            }
        }

        return false;
    }

    // Load the source text of a bundled .gml file.
    // 读取打包的 .gml 文件源码文本。
    private string Code(string fileName) => ModFiles.GetCode(fileName);
}
