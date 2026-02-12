# 🎮 拳皇地牢 (Fist Dungeon)

Rogue-like动作游戏，参考空洞骑士+死亡细胞风格。

## 游戏特色

- ⚔️ **拳法体系** - 冲刺拳、旋风腿、蓄力重击
- 🏏 **棍法体系** - 旋风棍、突刺、下劈（隐藏房间解锁）
- ✨ **技能系统** - 飞行、光束、地刺、隐身、治疗、毒雾
- 👹 **Boss战** - 哥布林王，召唤小怪，多阶段
- 💀 **死亡惩罚** - 损失50%金币
- 💾 **自动存档** - 每房间自动保存
- 🕵️ **隐藏房间** - 发现秘密获得宝藏

## 操作说明

| 按键 | 功能 |
|------|------|
| A/D | 左右移动 |
| W | 跳跃 |
| J | 攻击（按住蓄力） |
| K | 技能1（飞行/隐身） |
| L | 技能2（光束/治疗） |
| U | 技能3（地刺/毒雾） |
| ESC | 暂停 |

## 敌人列表

| 敌人 | 特点 |
|------|------|
| 🦇 **蝙蝠** | 飞行，速度快 |
| 🟢 **史莱姆** | 血厚，跳跃攻击 |
| 👺 **哥布林** | 会闪避 |
| 🕷️ **蜘蛛** | 吐丝减速（新增） |
| 👹 **哥布林王** | Boss，召唤+多阶段 |

## 文件结构

```
sckall_adventurous/
├── project.godot          # 项目配置
├── README.md              # 说明文档
├── assets/               # 素材资源
└── scripts/              # 核心代码
    ├── Player.gd         # 玩家控制器
    ├── Game.gd           # 游戏主控
    ├── AudioSystem.gd    # 音效系统
    ├── weapons/          # 武器系统
    │   ├── WeaponSystem.gd
    │   ├── FistSystem.gd  # 拳法
    │   └── StaffWeapon.gd # 棍法
    ├── skills/           # 技能系统
    │   ├── SkillBase.gd
    │   ├── FlightSkill.gd # 飞行
    │   ├── BeamSkill.gd   # 光束
    │   ├── SpikeSkill.gd  # 地刺
    │   ├── InvisibilitySkill.gd # 隐身
    │   ├── HealSkill.gd   # 治疗
    │   └── PoisonSkill.gd # 毒雾
    ├── enemies/          # 敌人系统
    │   ├── EnemySystem.gd
    │   ├── Bat.gd
    │   ├── Slime.gd
    │   ├── Goblin.gd
    │   ├── Spider.gd     # 新增
    │   └── GoblinKing.gd
    ├── dungeon/         # 地牢系统
    │   ├── DungeonSystem.gd
    │   └── SecretRoom.gd # 隐藏房间
    └── ui/              # UI系统
        ├── GameUI.gd
        └── SaveSystem.gd
```

## 扩展指南

### 新增武器

```gdscript
class_name SpearWeapon extends WeaponSystem

func _init():
    weapon_name = "枪法"
    damage = 4
```

### 新增技能

```gdscript
class_name Fireball extends SkillBase

func _init():
    skill_name = "火球"
    cooldown = 3.0
```

### 新增敌人

```gdscript
class_name Ghost extends EnemySystem

func _init():
    enemy_name = "幽灵"
    hp = 1
    speed = 100.0
```

## 更新日志

### v1.1 (2026-02-12)
- ✅ 新增隐身技能
- ✅ 新增治疗技能
- ✅ 新增毒雾技能
- ✅ 新增棍法武器体系
- ✅ 新增隐藏房间系统
- ✅ 新增蜘蛛敌人
- ✅ 音效系统框架

### v1.0 (2026-02-12)
- 🎮 MVP发布
- ⚔️ 拳法体系
- ✨ 飞行/光束/地刺技能
- 👹 3种敌人+哥布林王Boss
- 💾 存档系统

## 运行方法

```bash
# 打开Godot
open "/Volumes/SSD/app/Godot.app"

# 导入项目
# 选择 skall_adventurous 文件夹

# 按F5运行
```

## GitHub

https://github.com/sckall/fist-dungeon

## 参考游戏

- 空洞骑士 (Hollow Knight)
- 死亡细胞 (Dead Cells)
- 以撒的结合 (The Binding of Isaac)
