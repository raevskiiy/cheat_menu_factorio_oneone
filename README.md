# Cheat Menu

**English** | [Русский](README.ru.md)

A simple cheat menu for **Factorio 1.1** with a clean in-game window. Tweak your character, toggle cheats and run common actions without typing console commands. Integrates with [GUI Unifier](https://mods.factorio.com/mod/GUI_Unifyer) button styles.

## Features

**Character modifiers** (sliders)

| Slider | What it does | Range |
|---|---|---|
| Crafting speed | Handcrafting speed bonus | up to x101 |
| Running speed | Running speed bonus | up to x11 |
| Mining speed | Manual mining speed bonus | up to x101 |
| Reach distance | Build, reach, mining, item drop and pickup distance | +0 to +320 (engine limit) |
| Max health | Extra max health | up to +10000 |
| Inventory slots | Extra inventory slots | up to +200 |

**Toggles**

- Invulnerable (god mode)
- Vanilla cheat mode (free and instant crafting, all recipes)
- Always day on the current surface

**Actions**

- Heal fully
- Research all technologies
- Unlock all recipes
- Reveal the map (500 tiles around you)
- Clear pollution on the current surface
- Reset all modifiers

## Usage

- Click the **Cheat Menu** button in the top-left mod button panel, or
- press **Ctrl + Shift + C** (rebindable in Settings → Controls).

Your settings are saved with the save file and re-applied after respawn.

## Multiplayer

By default only **admins** can see and use the menu. Change this with the map setting **"Cheat Menu: admins only"** (Settings → Mod settings → Map). In singleplayer you are always an admin.

## GUI Unifier compatibility

GUI Unifier has no public API for other mods, it restyles buttons from a built-in list of supported mods. Cheat Menu therefore places its button in the standard mod button panel (`mod_gui`) and uses the button style you chose in GUI Unifier's settings, including the "selected" style while the window is open. If GUI Unifier is not installed, the default mod button style is used. GUI Unifier is an optional dependency.

## Installation

1. Download `cheat_menu_<version>.zip` from the [Releases](../../releases) page.
2. Put the zip (do not unpack it) into your Factorio `mods` folder:
   - Windows: `%appdata%\Factorio\mods`
   - Linux: `~/.factorio/mods`
   - macOS: `~/Library/Application Support/factorio/mods`
3. Start the game and make sure **Cheat Menu** is enabled in the Mods menu.

## Notes

- Using cheats may disable achievements.
- If you remove the mod, modifiers applied to your character are not removed automatically. Press **Reset all** in the menu before uninstalling.
- Tested with Factorio 1.1 only. Factorio 2.0 is not supported.

## Localization

English and Russian. Translations live in `locale/<lang>/locale.cfg`, pull requests with new languages are welcome.

## Contributing

Bug reports and ideas are welcome in [Issues](../../issues). When reporting a crash, please attach `factorio-current.log` and the list of enabled mods.

## License

Add a license of your choice (for example MIT) as a `LICENSE` file.
