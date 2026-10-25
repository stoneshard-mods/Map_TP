# Map_TP

大地图传送模组（Stoneshard）。左键点大地图任意可通行格 → 在弹出菜单里选落点（左上 / 右上 / 左下 / 右下）→ 直接传到目标格所在房间。

## 传送方式：直接换房 + 落点修正

从源码看，房间内容是生成时按 `global.playerGridX/Y` 读取格数据（`scr_globaltile_get(...)`），
房间资产由该格的 `room_type` 决定，`o_player` 创建时读取 `localX/localY` 作为落点。
所以只要**格、房间、落点同时设置正确**就是自洽的；离线改存档出问题，是因为只写了其中一部分，房间与格不匹配才会地面/贴图错乱。

当前流程：

1. 目标格 `(gx,gy)` → `room = room_type(gx,gy)`；
2. 写 `localX/localY`（左上/右上/左下/右下 = 26/2288 组合）和 `playerGridX/Y`；
3. `scr_smoothRoomChange(room)`（目标与当前同房间则 `room_restart()`），让游戏按目标格生成房间；
4. 房间加载完成后用 `scr_pat_prototype` 检查落点：如果落在墙/水里，就在半径 12 格内找最近的可走格，`scr_invisible_teleport` 过去。

## 交互与界面

- **左键单击**可通行格打开菜单；中键拖拽地图、右键自定义标记保持游戏原样；
- 菜单复用游戏右键菜单的边框精灵（`s_gui_context_*` + `s_point`），字号为原生 0.5 倍，宽 156px；
- 菜单项：左上 / 右上 / 左下 / 右下 / 取消，标题显示目标格坐标；
- 左上角一行小字「左键：传送 / LMB」，提示/错误也显示在左上角；
- 传送过程中屏幕上方显示「传送中…」。

## 已知限制

- 传送后若落点被墙挡住会自动挪到附近空地；如果目标格本身是副本/室内房间，落点坐标按 26/2288 处理不一定合适；
- 传送会保留/携带过图敌人列表（与正常换房一致），跨远距离传送前建议先脱战。

## 安装

1. 用启动器编译（或把 `.sml` 放进 `%LOCALAPPDATA%\ModShardLauncher\Mods`）；
2. 打开**原版**数据文件（当前游戏目录里是 `original.win`），启用 `Map_TP`，打补丁并保存；
3. 进游戏按 M 打开大地图，左键点格子。

## 文件

```
Map_TP.csproj
MapTP.cs                          # 注入入口（对象 / 事件 / 脚本函数 / o_globalmap End Step 钩子）
Gml/scr_msl_maptp_cell.gml        # 屏幕坐标 → 世界格
Gml/scr_msl_maptp_can_enter.gml   # 目标格可传送判断
Gml/scr_msl_maptp_menu_index.gml  # 菜单命中测试
Gml/scr_msl_maptp_begin.gml       # 直接换房 + 落点
Gml/o_msl_maptp_Create.gml        # 控制器状态
Gml/o_msl_maptp_Step.gml          # 落点修正 + 输入
Gml/o_msl_maptp_Draw_64.gml       # 菜单绘制
```
