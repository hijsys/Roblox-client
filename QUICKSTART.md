# 🦦 Otter Client - Quick Start Guide

## ⚡ 60-Second Setup

### Step 1: Execute the Script
```lua
-- Copy and paste OtterClient.lua into your executor, then run it
```

### Step 2: Open the GUI
```
Press: RightShift
```

### Step 3: Enable Features
- Click on any tab (Combat, Movement, Utility, World)
- Click toggle buttons to enable features
- Features turn GREEN when enabled

---

## 🎯 Most Popular Feature Combos

### "God Mode" (Maximum Advantage)
```
✅ Combat → KillAura (ON)
✅ Combat → Velocity (ON)
✅ Movement → Speed (ON)
✅ Utility → ESP (ON)
✅ Utility → AutoCollect (ON)
```

### "Ghost Mode" (Stealthy)
```
✅ Utility → ESP (ON)
✅ Utility → Tracers (ON)
✅ World → Fullbright (ON)
⚠️ Keep other features OFF for minimal detection
```

### "Speed Demon" (Fast & Aggressive)
```
✅ Movement → Speed (ON)
✅ Movement → Fly (ON)
✅ Combat → KillAura (ON)
✅ Utility → Scaffold (ON)
✅ Movement → NoFall (ON)
```

---

## ⌨️ Essential Controls

| Key | Action |
|-----|--------|
| **RightShift** | Toggle GUI On/Off |
| **Click & Drag** | Move GUI window |
| **Click Tabs** | Switch categories |
| **Click Toggles** | Enable/Disable features |

### Fly Mode Controls (when enabled)
- **W/A/S/D** - Move horizontally
- **Space** - Fly up
- **Left Shift** - Fly down

---

## 🎮 Feature Guide

### Combat Tab ⚔️
| Feature | What It Does | Recommended |
|---------|-------------|-------------|
| KillAura | Auto-attacks enemies | ⭐⭐⭐⭐⭐ |
| Velocity | Reduces knockback | ⭐⭐⭐⭐⭐ |
| Reach | Longer attack range | ⭐⭐⭐⭐ |
| AutoBlock | Auto sword block | ⭐⭐⭐ |
| Criticals | Critical hits | ⭐⭐⭐ |

### Movement Tab 🏃
| Feature | What It Does | Recommended |
|---------|-------------|-------------|
| Speed | Move faster | ⭐⭐⭐⭐⭐ |
| Fly | Enable flight | ⭐⭐⭐⭐⭐ |
| NoFall | No fall damage | ⭐⭐⭐⭐⭐ |
| Spider | Climb walls | ⭐⭐⭐ |
| LongJump | Jump further | ⭐⭐⭐ |

### Utility Tab 🔧
| Feature | What It Does | Recommended |
|---------|-------------|-------------|
| AutoCollect | Auto-collect items | ⭐⭐⭐⭐⭐ |
| ChestStealer | Instant chest loot | ⭐⭐⭐⭐ |
| Nuker | Break blocks fast | ⭐⭐⭐⭐ |
| Scaffold | Auto-place blocks | ⭐⭐⭐⭐ |
| ESP | See through walls | ⭐⭐⭐⭐⭐ |
| Tracers | Lines to players | ⭐⭐⭐⭐ |
| AntiVoid | Void protection | ⭐⭐⭐⭐⭐ |

### World Tab 🌍
| Feature | What It Does | Recommended |
|---------|-------------|-------------|
| Fullbright | Remove darkness | ⭐⭐⭐⭐⭐ |
| NoWeather | Clear weather | ⭐⭐⭐ |
| Zoom | Extended camera | ⭐⭐⭐⭐ |

---

## ⚙️ Quick Settings Adjustment

Want to customize? Edit `Config.lua`:

```lua
-- Example: Change KillAura range
Combat = {
    KillAura = {
        DefaultRange = 20,  -- Change this number
    }
}

-- Example: Change Speed amount
Movement = {
    Speed = {
        DefaultAmount = 23,  -- Change this number
    }
}

-- Example: Change GUI colors
GUI = {
    Theme = {
        Primary = Color3.fromRGB(100, 200, 255),  -- Change these
    }
}
```

---

## 🐛 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| GUI won't open | Press RightShift multiple times |
| Features not working | Make sure you're in BedWars |
| Script error | Copy the ENTIRE script |
| Can't drag GUI | Click the header bar (top) |
| Features disabled after death | Normal - they auto-reload |

---

## 💡 Pro Tips

1. **Start Conservative**: Enable a few features first, then add more
2. **Check Notifications**: Top-right corner shows feature status
3. **Drag the Window**: Move it anywhere on screen
4. **Use Tabs**: Organized by category for easy access
5. **Fly Carefully**: Don't fly too high or obvious
6. **ESP is Key**: Always enable ESP first for awareness
7. **Combo Features**: Speed + Fly + KillAura = Maximum advantage
8. **Stay Mobile**: Use movement features to dodge
9. **AutoCollect Always**: Never miss resources
10. **AntiVoid Saves**: Prevents embarrassing void deaths

---

## 🎯 Beginner → Advanced Progression

### Phase 1: "Learning" (First 3 games)
```
Enable: ESP, Fullbright, AutoCollect
Goal: Learn to use the GUI and see how ESP helps
```

### Phase 2: "Improving" (Next 5 games)
```
Add: Speed, NoFall, AntiVoid
Goal: Get comfortable with enhanced movement
```

### Phase 3: "Dominating" (Next 10 games)
```
Add: KillAura, Velocity
Goal: Master combat with auto-attack
```

### Phase 4: "God Mode" (Advanced)
```
Use: All features
Goal: Complete battlefield dominance
```

---

## ⚠️ Safety Recommendations

### Low Detection Risk:
- ESP
- Fullbright
- AutoCollect (range ≤ 20)
- Speed (≤ 23)
- Tracers

### Medium Detection Risk:
- KillAura (range ≤ 18)
- Velocity (vertical ≥ 80%)
- Reach (≤ 16)
- Nuker

### High Detection Risk:
- Fly
- KillAura (range > 20)
- Speed (> 30)
- Teleportation features

**Recommendation**: Use low-risk features on main account, high-risk on alt accounts.

---

## 📱 Contact & Support

Having issues? Check these files:
- `InstallGuide.txt` - Detailed installation help
- `FeaturesOverview.md` - Complete feature explanations
- `Config.lua` - Customization options

---

## 🎉 You're Ready!

1. ✅ Load OtterClient.lua
2. ✅ Press RightShift
3. ✅ Enable your favorite features
4. ✅ Dominate BedWars!

**Enjoy Otter Client v2.0! 🦦**

---

*Remember: Use responsibly and have fun!*
