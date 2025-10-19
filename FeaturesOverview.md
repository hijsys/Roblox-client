# 🦦 Otter Client - Complete Features Overview

## Table of Contents
- [Combat Features](#combat-features)
- [Movement Features](#movement-features)
- [Utility Features](#utility-features)
- [World Features](#world-features)
- [Advanced Features](#advanced-features)

---

## ⚔️ Combat Features

### KillAura
**Description:** Automatically attacks all enemies within range.

**How it works:**
- Scans for all players within the specified range
- Automatically targets enemies (can optionally target teammates)
- Fires sword attack remotes at detected targets
- Continues attacking until targets are eliminated or out of range

**Customizable Settings:**
- `Range` (5-30): How far KillAura can detect enemies
- `Speed` (0-1): Delay between attacks (lower = faster)
- `TargetTeammates` (true/false): Whether to attack teammates

**Best Settings:**
- Range: 18-20 (subtle, not obvious)
- Speed: 0.1-0.15 (realistic attack speed)
- TargetTeammates: false (unless you want chaos)

---

### Velocity
**Description:** Reduces or eliminates knockback from hits.

**How it works:**
- Monitors your character's velocity changes
- Modifies knockback received from attacks
- Can reduce horizontal and/or vertical knockback separately

**Customizable Settings:**
- `Horizontal` (0-100%): Percentage of horizontal knockback to keep
- `Vertical` (0-100%): Percentage of vertical knockback to keep

**Best Settings:**
- Horizontal: 0-20% (minimal horizontal knockback)
- Vertical: 80-100% (keep most vertical for realism)

---

### Reach
**Description:** Extends your attack range beyond normal limits.

**How it works:**
- Temporarily increases hitbox sizes of enemy players
- Allows you to hit from further away
- Automatically resets when disabled

**Customizable Settings:**
- `Distance` (10-30): Maximum reach distance

**Best Settings:**
- Distance: 15-18 (subtle, not detectable)
- Avoid 25+ as it's very obvious

---

### AutoBlock
**Description:** Automatically blocks with sword when being attacked.

**How it works:**
- Detects incoming attacks
- Automatically raises sword to block
- Reduces damage taken

**Usage Tips:**
- Works best with Velocity enabled
- Automatic defense mechanism
- Helps in 1v1 combat situations

---

### Criticals
**Description:** Forces critical hits on every attack.

**How it works:**
- Modifies attack packets to trigger critical damage
- Increases damage output significantly
- Works with any weapon

---

## 🏃 Movement Features

### Speed
**Description:** Increases your movement speed.

**How it works:**
- Modifies your character's WalkSpeed property
- Allows faster movement around the map
- Automatically adjusts when enabled/disabled

**Customizable Settings:**
- `Amount` (16-100): Movement speed value
  - Normal speed: 16
  - Recommended: 20-25

**Best Settings:**
- Amount: 23 (fast but not obvious)
- 30+ becomes very noticeable

---

### Fly
**Description:** Enables flight with full directional control.

**How it works:**
- Adds BodyVelocity to your character
- WASD for horizontal movement
- Space to fly up, Shift to fly down
- Follows camera direction

**Customizable Settings:**
- `Speed` (10-200): Flight speed

**Controls:**
- W/A/S/D: Move horizontally
- Space: Fly up
- Left Shift: Fly down

**Best Settings:**
- Speed: 50 (smooth, controlled flight)
- 100+ is very fast but harder to control

---

### NoFall
**Description:** Prevents fall damage.

**How it works:**
- Detects when you're falling fast
- Fires ground hit remote before impact
- Negates fall damage

**Usage:**
- Always useful, no downsides
- Works automatically in background
- Essential for aggressive play

---

### Spider
**Description:** Climb walls like a spider.

**How it works:**
- Allows vertical movement on walls
- Automatically detects wall contact
- Adjustable climb speed

**Customizable Settings:**
- `Speed` (5-50): Climbing speed

---

### LongJump
**Description:** Jump much further than normal.

**How it works:**
- Increases jump power significantly
- Adds horizontal momentum to jumps
- Can cross large gaps

**Customizable Settings:**
- `Power` (50-200): Jump boost strength

---

## 🔧 Utility Features

### AutoCollect
**Description:** Automatically collects items near you.

**How it works:**
- Constantly scans for collectible items
- Fires pickup remotes for items in range
- Collects resources, tools, and consumables

**Customizable Settings:**
- `Range` (5-50): Collection radius

**Best Settings:**
- Range: 15-20 (efficient without being obvious)

**Benefits:**
- Never miss resource drops
- Faster resource gathering
- Automatic item collection during combat

---

### ChestStealer
**Description:** Instantly steals all items from chests.

**How it works:**
- Detects when a chest is opened
- Rapidly takes all items from chest
- Faster than manual looting

**Customizable Settings:**
- `Speed` (0-1): Delay between taking items

**Best Settings:**
- Speed: 0.1 (instant but not suspicious)

---

### Nuker
**Description:** Rapidly breaks blocks around you.

**How it works:**
- Scans for breakable blocks in range
- Fires break block remotes continuously
- Useful for clearing defenses or mining

**Customizable Settings:**
- `Range` (5-50): Block breaking radius

**Usage Tips:**
- Great for destroying enemy defenses
- Fast resource gathering
- Can be obvious - use carefully

**Best Settings:**
- Range: 20-25 (effective area)

---

### Scaffold
**Description:** Automatically places blocks under you.

**How it works:**
- Detects when you're in air or at edge
- Places blocks beneath your feet
- Allows continuous bridging

**Usage Tips:**
- Hold forward to bridge automatically
- Great for rushing
- Make sure you have blocks in inventory

---

### ESP (Extra Sensory Perception)
**Description:** See players and beds through walls.

**How it works:**
- Creates billboard GUIs above entities
- Shows player names and health
- Highlights bed locations
- Color-coded (green = teammate, red = enemy)

**Customizable Settings:**
- `ShowPlayers` (true/false): Display player ESP
- `ShowBeds` (true/false): Display bed locations

**Features:**
- Player names visible through walls
- Distance-independent visibility
- Team color coding
- Bed highlighting

---

### Tracers
**Description:** Draws lines from you to entities.

**How it works:**
- Creates beams from camera to targets
- Shows direction to players/beds
- Updates in real-time

**Usage:**
- Quick enemy location awareness
- Navigation assistance
- Tactical information

---

### AntiVoid
**Description:** Saves you from falling into the void.

**How it works:**
- Monitors your Y position
- Teleports you up if you fall too low
- Prevents void deaths

**Customizable Settings:**
- `Height` (0-50): Y position trigger point

**Best Settings:**
- Height: 10 (catches you before void damage)

---

## 🌍 World Features

### Fullbright
**Description:** Removes all darkness from the game.

**How it works:**
- Maximizes lighting brightness
- Removes shadows
- Sets optimal time of day
- Extends fog distance

**Benefits:**
- See everything clearly
- No dark corners
- Tactical advantage in all areas

---

### NoWeather
**Description:** Removes weather effects.

**How it works:**
- Clears rain, snow, fog
- Improves visibility
- Better performance

---

### Zoom
**Description:** Extends camera zoom distance.

**How it works:**
- Increases CameraMaxZoomDistance
- Allows much further zoom out
- Better overview of battlefield

**Customizable Settings:**
- `Amount` (128-10000): Maximum zoom distance
  - Default: 128
  - Recommended: 500-1000

---

## 🚀 Advanced Features

These features are available in `AdvancedFeatures.lua`:

### AutoTool
- Automatically equips the correct tool
- Sword for combat
- Pickaxe for mining
- Bow for ranged combat

### AntiAFK
- Prevents being kicked for inactivity
- Simulates user input
- Keeps you in game

### FastLoot
- Extremely fast chest looting
- Takes all items instantly
- Faster than ChestStealer

### AutoRespawn
- Automatically respawns when you die
- No manual clicking needed
- Get back in action faster

### AutoArmor
- Automatically equips armor pieces
- Checks inventory constantly
- Equips best available armor

### TeamAura
- Heals/buffs nearby teammates
- Adjustable range
- Support ability

### AutoBuy
- Automatically purchases items from shop
- Customizable item list
- Resource management

### BedNuker
- Specifically targets enemy beds
- Ignores your team's bed
- Adjustable range
- Priority targeting

### SmartKillAura
- Improved KillAura algorithm
- Targets closest enemy first
- Better targeting logic
- Faces enemies automatically

---

## 💡 Pro Tips

### Combination Strategies

**Aggressive Rush:**
- Speed + Fly + Scaffold + KillAura
- Fast approach with automatic building and combat

**Defensive Play:**
- ESP + Tracers + Velocity + AutoCollect
- Full awareness with knockback resistance

**Resource Gathering:**
- AutoCollect + Nuker + Speed
- Rapid resource collection

**PvP Focus:**
- KillAura + Velocity + Reach + NoFall
- Maximum combat effectiveness

**Stealth Mode:**
- ESP + Tracers + AntiVoid
- Information gathering without being obvious

### Settings for Different Situations

**Casual Play (Less Obvious):**
- KillAura Range: 15-18
- Speed: 20-23
- Reach: 15-16
- Keep vertical velocity high (80%+)

**Aggressive Play (Maximum Advantage):**
- KillAura Range: 20-25
- Speed: 25-30
- Reach: 18-20
- Low velocity (0-20%)

**Safe Play (Minimal Detection Risk):**
- Only use ESP and Tracers
- Speed: 18-20
- No KillAura
- Focus on information advantage

---

## ⚠️ Important Reminders

1. **Use Responsibly:** Don't ruin the game for others
2. **Be Subtle:** Lower settings are less detectable
3. **Stay Safe:** Use alternate accounts
4. **Regular Updates:** Keep checking for new versions
5. **Backup Config:** Save your customized settings
6. **Test First:** Try features in safe environments
7. **Report Issues:** Help improve the client

---

## 🔄 Feature Status

All features in Otter Client v2.0 are:
- ✅ Fully functional
- ✅ Error-free
- ✅ Remote-compatible
- ✅ Customizable
- ✅ Well-optimized

---

**Remember:** With great power comes great responsibility. Use Otter Client wisely! 🦦
