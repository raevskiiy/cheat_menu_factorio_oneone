# Cheat Menu (Factorio 2.1 beta)

**English** | [Русский](README.ru.md)

> **This branch targets Factorio 2.1 (currently in beta/experimental).**
> For Factorio **1.1** use the [`main` branch](../../tree/main).
> Factorio 2.0 (stable) is **not** supported by this branch, because the mod declares `factorio_version: 2.1`.

A simple cheat menu with a clean in-game window. Tweak your character, toggle cheats and run common actions without typing console commands. Integrates with [GUI Unifier](https://mods.factorio.com/mod/GUI_Unifyer) button styles.

## Features

**Character modifiers** (sliders)

| Slider | What it does | Range |
|---|---|---|
| Crafting speed | Handcrafting speed bonus | up to x101 |
| Running speed | Running speed bonus | up to x11 |
| Mining speed | Manual mining speed bonus | up to x101 |
| Reach distance | Build, reach, mining, item drop and pickup distance | +0 to +320 |
| Max health | Extra max health | up to +10000 |
| Inventory slots | Extra inventory slots | up to +200 |

**Toggles**

- Invulnerable (god mode)
- Vanilla cheat mode (free and instant crafting)
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

By default only **admins** can see and use the menu. Change this with the map setting **"Cheat Menu: admins only"** (Settings → Mod settings → Map). In singleplayer you are always an admin. All players on a 2.1 server must run the same Factorio version.

## GUI Unifier compatibility

GUI Unifier has no public API for other mods, it restyles buttons from a built-in list of supported mods. Cheat Menu therefore places its button in the standard mod button panel (`mod_gui`) and uses the button style you chose in GUI Unifier's settings, including the "selected" style while the window is open. If GUI Unifier is not installed, the default mod button style is used. GUI Unifier is an optional dependency.

## Installation

1. Opt in to the Factorio 2.1 beta (Steam: right click Factorio → Properties → Betas; or download the experimental build from factorio.com).
2. Download `cheat_menu_<version>.zip` from the [Releases](../../releases) page (the release tagged for 2.1).
3. Put the zip (do not unpack it) into your Factorio `mods` folder:
   - Windows: `%appdata%\Factorio\mods`
   - Linux: `~/.factorio/mods`
   - macOS: `~/Library/Application Support/factorio/mods`
4. Start the game and make sure **Cheat Menu** is enabled in the Mods menu.

## What changed compared to the 1.1 version

- `global` was replaced with `storage`.
- The close button uses the 2.x sprite names (`utility/close`).
- "Heal fully" uses `LuaEntity.max_health`, which no longer needs the prototype value.
- Slider values are snapped to the step in code instead of relying on slider flags.
- `info.json` targets Factorio 2.1 (`base >= 2.1.0`).

## Notes

- Factorio 2.1 is in beta, and its modding API can still change. If an update breaks the mod, please open an issue.
- Using cheats may disable achievements.
- If you remove the mod, modifiers applied to your character are not removed automatically. Press **Reset all** in the menu before uninstalling.
- This mod has not been run in-game against every 2.1 beta build yet, it was checked against the 2.1 API documentation.

## Localization

English and Russian. Translations live in `locale/<lang>/locale.cfg`, pull requests with new languages are welcome.

## Contributing

Bug reports and ideas are welcome in [Issues](../../issues). When reporting a crash, please attach `factorio-current.log`, your exact Factorio version (for example 2.1.23) and the list of enabled mods.

## License

Add a license of your choice (for example MIT) as a `LICENSE` file.
