# Map_TP

大地图传送模组（Stoneshard）。左键点大地图任意可通行格 → 在弹出菜单里选落点（左上 / 右上 / 左下 / 右下）→ 直接传到目标格所在房间。

当前版本：**v0.5.0.0**（地牢内不提供传送；详见“地牢内不提供传送”与“变更记录”）。

## 传送方式：直接换房 + 落点修正

从源码看，房间内容是生成时按 `global.playerGridX/Y` 读取格数据（`scr_globaltile_get(...)`），
房间资产由该格的 `room_type` 决定，`o_player` 创建时读取 `localX/localY` 作为落点。
所以只要**格、房间、落点同时设置正确**就是自洽的；离线改存档出问题，是因为只写了其中一部分，房间与格不匹配才会地面/贴图错乱。

当前流程：

1. 目标格 `(gx,gy)` → `room = room_type(gx,gy)`；
2. 写 `localX/localY`（左上/右上/左下/右下 = 26/2288 组合）和 `playerGridX/Y`；
3. `scr_smoothRoomChange(room)`（目标与当前同房间则 `room_restart()`），让游戏按目标格生成房间；
4. 房间加载完成后用 `scr_pat_prototype` 检查落点：如果落在墙/水里，就在半径 12 格内找最近的可走格，`scr_invisible_teleport` 过去。

### 地牢内不提供传送（v0.5.0.0）

游戏只有在 `c_dungeon_enter` / 楼梯过渡里才会改 `global.floor_counter`（地牢层数），而出生点、房间池、`saveGraph` 的 `"Floor"+N`、楼梯的目标房间全都依赖它：

- `o_stairs_up_Create_0` 在**创建时**调用 `stairsUp()`，`stairsUp()` 里 `if (!(global.floor_counter > 1)) target_room = scr_globaltile_get_room();`
  —— 层数若偏小，2 层的上楼楼梯就会指向地表入口房间；
- 单层地牢（Tier 1–2 墓穴/地下墓/堡垒、所有洞穴）的房间池只有 `Entrance`/`Boss`，没有 `Ascent`；
  层数被留成 2 再进这类地牢，`scr_dungeonChangeNodeRole` → `ds_unique_object_get` 会拿到 `undefined` 直接崩溃。

所以 v0.4.0.0 里“在地牢里打开地图 → 传送出去”会把 `floor_counter` 留在 1/2 带回地表。v0.5.0.0 起：

- 地牢内（`floor_counter != 0`）不弹菜单，只显示“地牢内无法传送 / Cannot teleport inside a dungeon”；
- 日志（journal）里内嵌的小地图不响应点击（那里的 `mapOffsetX/mapScale` 与全屏地图不同，换算会点错格）；
- 站在地表且当前房间就是该世界格的房间时，若发现残留的层数（`floor_counter != 0`）会归零并同步 `global.locationFloor`，用于修复已经被旧版本写坏的存档。
  触发条件很严：无 `o_dungeon_controller`、无 `o_smoothRoomChanger`（正在换房时不动作，避免踩上地牢入口的淡出帧被误判）、无 `o_biome_generation_controller`，且 `scr_globaltile_get_room() == room`。

## 交互与界面

- **左键单击**可通行格打开菜单；中键拖拽地图、右键自定义标记保持游戏原样；
- 地牢内、以及日志里内嵌的小地图上，点击不弹菜单（日志地图只忽略点击，全屏地图则提示“地牢内无法传送”）；
- 菜单复用游戏右键菜单的边框精灵（`s_gui_context_*` + `s_point`），字号为原生 0.5 倍，宽 190px；
- 菜单项（英文用完整单词，不再用 TL / TR / BL / BR 缩写，中文同样用完整词）：
  `Top-left corner / 左上角`、`Top-right corner / 右上角`、`Bottom-left corner / 左下角`、
  `Bottom-right corner / 右下角`、`Cancel / 取消`；
  标题显示目标格坐标；
- 左上角一行小字（`Left-click: teleport` / `左键：传送`），提示/错误也显示在左上角；
- 传送过程中屏幕上方显示 `Teleporting…` / `传送中…`。

## 界面语言（中 / 英 / 俄 / 日 / 韩）

语言在**启动器的游戏内设置**里切换（与 Rusty 系列模组同一套机制，不再占用传送菜单的行）：

- 游戏内 `ESC → 设置 → MODS` 页 → `Map_TP` 分组 → `Language / 语言` 下拉框：
  `Auto` / `English` / `中文` / `Русский` / `日本語` / `한국어`；
- `Auto` 跟随系统语言（`os_get_language()`：`zh*` / `ru*` / `ja*` / `ko*` 对应中俄日韩，其余英文）；
- 选择由启动器的模组菜单系统保存到 `%LOCALAPPDATA%\StoneShard\msl_menu_mod.ini`（`[Map_TP]` 段），
  对应全局变量 `global.msl_maptp_lang_choice`，不需要额外的配置文件；
- 实现方式：`MapTP.cs` 中 `Msl.AddMenu(...)` 的 `UIComponent(..., UIComponentType.ComboBox, new[] { "Auto", "English", "中文", "Русский", "日本語", "한국어" })`；
- 所有界面文本都走 `scr_msl_maptp_tr(key)`，14 条文案 × 5 语言都在 `Gml/scr_msl_maptp_tr.gml`，新增语言只需在那里加一个分支。

> 字体提示：菜单用游戏自带字体绘制（`global.f_dmg`）。该字体含完整拉丁与西里尔字形（俄文没问题），
> 中日韩字形覆盖取决于当前 `data.win` 里的字体资源；若某种语言的文字显示为空白，说明该 `data.win` 的字体缺这些字形，
> 需要另外注入字体资源才能显示。

## 已知限制

- 传送后若落点被墙挡住会自动挪到附近空地；如果目标格本身是副本/室内房间，落点坐标按 26/2288 处理不一定合适；
- 传送会保留/携带过图敌人列表（与正常换房一致），跨远距离传送前建议先脱战；
- **地牢内不能传送**（含洞穴）。这是刻意限制：绕过楼梯移动会把 `global.floor_counter` 留错，进而破坏后续地牢的楼层生成（详见上文的“地牢内不提供传送”）；
- 地牢入口房间（地表那间）仍可正常传送，它与地牢内部是两回事。

## 变更记录

### v0.5.0.0（当前）

- **修复崩溃**：从地牢里用地图传送出去后，`global.floor_counter` 会留在地牢层数上带回地表；之后进入单层地牢
  （Tier 1–2 的墓穴 / 地下墓 / 堡垒、所有洞穴）会崩在 `o_dungeon_controller` Create → User Defined 15 →
  `scr_dungeonChangeNodeRole` → `ds_unique_object_get`（`DoSub :2: undefined value`）。现在：
  - 地牢内不再提供传送，显示“地牢内无法传送 / Cannot teleport inside a dungeon”；
  - 新增残留层数自愈，已被旧版本写坏的存档站在地表时自动修复；
- **修复**：日志（journal）里内嵌的小地图点击会触发传送、且格子坐标算错（`mapOffsetX/mapScale` 语义不同），现在完全忽略；
- **修复**：`o_globalmap` 的 End Step 每帧写一次 `maptp_diag.txt`（地图打开时约 60 行/秒），已移除；
- 新增 5 语言文案 `in_dungeon`。

### 更早版本

- v0.4.0.0：界面语言扩展到中 / 英 / 俄 / 日 / 韩，`Auto` 跟随系统语言；
- 更早：大地图二级菜单传送（四角落落点、直接换房、落点修正、MODS 页语言下拉框）。

## 安装

1. 用启动器编译（或把 `.sml` 放进 `%LOCALAPPDATA%\ModShardLauncher\Mods`）；
2. 打开**原版**数据文件（当前游戏目录里是 `original.win`），启用 `Map_TP`，打补丁并保存；
3. 进游戏按 M 打开大地图，左键点格子。

## 编译（dotnet build）

仓库已内置以下两个引用 DLL，克隆后无需安装启动器即可直接编译：

- `lib/ModShardLauncher.dll`
- `lib/UndertaleModLib.dll`

**来源**：从 ModShardLauncher（Avalonia 版）安装目录（默认 `%LOCALAPPDATA%\Programs\ModShardLauncher`）复制而来；二者均为 GPL-3.0 组件，与本仓库的 GPL-3.0 许可兼容。`Map_TP.csproj` 通过 `$(MSBuildThisFileDirectory)lib\...` 引用它们，与本机安装路径无关。

编译：

```bash
dotnet build Map_TP.csproj
```

输出：`bin/<Configuration>/net10.0/Map_TP.dll`。

注意：`Map_TP.csproj` 仅供 IDE / `dotnet` 编译使用，实际生成 `.sml` 由启动器打包完成；内置 DLL 与启动器 API 绑定，启动器升级后若接口变动需同步更新 `lib/` 内文件。

## 文件

```
Map_TP.csproj
MapTP.cs                          # 注入入口（对象 / 事件 / 脚本函数 / o_globalmap End Step 钩子）
lib/ModShardLauncher.dll          # 内置引用 DLL（编译用）
lib/UndertaleModLib.dll           # 内置引用 DLL（编译用）
Gml/scr_msl_maptp_lang.gml        # 语言判定（设置里的选择 → 系统语言）
Gml/scr_msl_maptp_tr.gml          # 中英文本表
Gml/scr_msl_maptp_cell.gml        # 屏幕坐标 → 世界格
Gml/scr_msl_maptp_can_enter.gml   # 目标格可传送判断
Gml/scr_msl_maptp_menu_index.gml  # 菜单命中测试
Gml/scr_msl_maptp_begin.gml       # 地牢守卫 + 直接换房 + 落点
Gml/o_msl_maptp_Create.gml        # 控制器状态
Gml/o_msl_maptp_Step.gml          # 地牢/日志地图守卫 + 残留层数自愈 + 落点修正 + 输入
Gml/o_msl_maptp_Draw_64.gml       # 菜单绘制（地牢内/日志地图不绘制传送 UI）
```

## 打包与验证（CLI）

用**已安装**的启动器自带的 CLI 无头编译与打补丁（默认安装到 `%LOCALAPPDATA%\Programs\ModShardLauncher`）：

```powershell
$cli = "$env:LOCALAPPDATA\Programs\ModShardLauncher\ModShardLauncher.CLI.exe"

# 编译源码为 .sml（输出到 %LOCALAPPDATA%\ModShardLauncher\Mods）
& $cli compile --source "$env:LOCALAPPDATA\ModShardLauncher\ModSources\Map_TP"

# 从原版 data.win 打补丁，检查 GML 是否能正确装配
& $cli patch --data "C:\Program Files (x86)\Steam\steamapps\common\Stoneshard\original.win" `
             --output "C:\Program Files (x86)\Steam\steamapps\common\Stoneshard\original_patched.win" `
             --enable Map_TP
```
