# 🎮 拳皇地牢 (Fist Dungeon)

Rogue-like动作游戏，参考空洞骑士+死亡细胞风格。

## 游戏特色

- ⚔️ **拳法体系** - 冲刺拳、旋风腿、蓄力重击
- ✨ **技能系统** - 飞行、光束、地刺
- 👹 **Boss战** - 哥布林王，召唤小怪，多阶段
- 💀 **死亡惩罚** - 损失50%金币
- 💾 **自动存档** - 每房间自动保存

## 操作说明

| 按键 | 功能 |
|------|------|
| A/D | 左右移动 |
| W | 跳跃 |
| J | 攻击（按住蓄力） |
| K | 飞行技能 |
| L | 光束技能 |
| U | 地刺技能 |
| ESC | 暂停 |

## 文件结构

```
sckall_adventurous/
├── project.godot          # 项目配置
├── assets/                # 素材资源
│   ├── sprites/           # 像素图
│   ├── audio/             # 音效
│   └── tilemaps/          # 地砖图块
├── scripts/               # 核心代码
│   ├── Player.gd         # 玩家控制器
│   ├── Game.gd           # 游戏主控
│   ├── weapons/           # 武器系统
│   │   ├── WeaponSystem.gd
│   │   └── FistSystem.gd
│   ├── skills/            # 技能系统
│   │   ├── SkillBase.gd
│   │   ├── FlightSkill.gd
│   │   ├── BeamSkill.gd
│   │   └── SpikeSkill.gd
│   ├── enemies/          # 敌人系统
│   │   ├── EnemySystem.gd
│   │   ├── Bat.gd
│   │   ├── Slime.gd
│   │   ├── Goblin.gd
│   │   └── GoblinKing.gd
│   ├── dungeon/          # 地牢系统
│   │   └── DungeonSystem.gd
│   └── ui/               # UI系统
│       ├── GameUI.gd
│       └── SaveSystem.gd
└── scenes/               # 场景
```

## 扩展指南

### 新增武器

继承 `WeaponSystem`：

```gdscript
class_name StaffWeapon extends WeaponSystem

func _init():
    weapon_name = "棍法"
    skills = [SpinStaff(), Thrust()]
```

### 新增技能

继承 `SkillBase`：

```gdscript
class_name Fireball extends SkillBase

func _init():
    skill_name = "火球"
    cooldown = 3.0
```

### 新增敌人

继承 `EnemySystem`：

```gdscript
class_name Spider extends EnemySystem

func _init():
    enemy_name = "蜘蛛"
    hp = 2
    speed = 80.0
```

## 运行方法

```bash
# 打开Godot
open "/Volumes/SSD/app/Godot.app"

# 导入项目
# 选择 skall_adventurous 文件夹

# 按F5运行
```

## 版本历史

- v1.0 - MVP发布，拳法体系+3技能+3敌人+1Boss

## 参考游戏

- 空洞骑士 (Hollow Knight)
- 死亡细胞 (Dead Cells)
- 以撒的结合 (The Binding of Isaac)
