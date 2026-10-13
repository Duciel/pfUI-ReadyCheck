# pfUI-ReadyCheck

A small third-party module for [pfUI](https://github.com/brues-code/pfUI) (vanilla 1.12 clients) that adds two buttons for raid leaders and assistants:

- **Ready Check**: starts a ready check with one click.
- **Pull**: starts a BigWigs pull timer (`/pull X`) with a configurable countdown.

Both buttons use the pfUI skin, can be moved with pfUI's unlock mode, and are configured from the regular pfUI settings window.

## Requirements

- [pfUI](https://github.com/brues-code/pfUI) (loaded first, declared as a dependency in the `.toc`)
- BigWigs or any addon providing a `/pull` command (only needed for the Pull button)

## Installation

Clone or download this repository into:

```
Interface\AddOns\pfUI-ReadyCheck
```

The folder name must match the `.toc` file name, so rename the folder if you download the zip (GitHub names it `pfUI-ReadyCheck-main`). Restart the game; `/reload` is not always enough after a `.toc` change.

## How it works

### Visibility

The buttons are only shown when you are allowed to use them:

| Situation | Buttons visible? |
| --- | --- |
| In a raid, raid leader or assistant | Yes |
| In a raid, regular member | No |
| In a party, party leader | Yes (can be disabled, see `Also Show In Party`) |
| In a party, regular member | No |
| Not in a group | No |

Visibility is refreshed automatically when the raid roster changes, when leadership changes, and when you enter the world. The Pull button is attached to the Ready Check button, so it moves with it and is hidden with it.

### Ready Check button

- **Left-click**: starts a ready check (`DoReadyCheck()`).
- **Right-click**: first announces "Ready check! Check your consumables." (as a raid warning if you are leader/assistant, otherwise in raid or party chat), then starts the ready check.

### Pull button

The button label shows the configured countdown (for example `Pull 10`).

- **Left-click**: runs `/pull X`, where `X` is the configured number of seconds.
- **Right-click**: runs `/pull 0` to cancel a running countdown (depends on your BigWigs version supporting it).

The addon does not implement its own timer. It looks up the `/pull` slash command registered by BigWigs and calls it exactly as if you had typed it, so the countdown, bars and announcements are BigWigs'. If no `/pull` command is registered, a message is printed in the chat frame.

### Slash commands

| Command | Effect |
| --- | --- |
| `/rc` | Starts a ready check (leader/assistant only) |
| `/rcpull` | Runs `/pull X` with the configured time (leader/assistant only) |

These are handy in macros or key bindings.

## Configuration

Open the pfUI settings with `/pfui`, then go to **Thirdparty -> Ready Check**.

| Option | Default | Description |
| --- | --- | --- |
| Enable Button | on | Show the Ready Check button |
| Also Show In Party (Leader) | on | Also show the buttons when you lead a 5-man party |
| Button Text | `Ready Check` | Label of the Ready Check button |
| Width / Height | 90 / 22 | Size of the Ready Check button (height is shared with the Pull button) |
| Show Pull Button | on | Show the Pull button |
| Pull Timer (Seconds) | 10 | Countdown passed to `/pull` |
| Pull Button Width | 60 | Width of the Pull button |

Changes apply immediately.

## Moving the buttons

Type `/pfui unlock`, drag the Ready Check button where you want it, then lock again. The position is saved by pfUI in your profile. The default position is near the top of the screen.

## How it is built

The addon registers itself as a pfUI module with `pfUI:RegisterModule`, so it runs inside pfUI's environment and uses pfUI's own helpers (`SkinButton`, `UpdateMovable`, `UpdateConfig`, the config GUI). Its settings are stored in pfUI's config under `C.readycheckbutton`, with defaults filled in without overwriting saved values.

Files:

- `pfUI-ReadyCheck.toc`: addon metadata, depends on pfUI
- `pfUI-ReadyCheck.lua`: the whole module

## Troubleshooting

- **No button**: you must be raid leader/assistant (or party leader with the party option on). Check `Enable Button` in the config.
- **Pull does nothing**: make sure BigWigs is loaded and that typing `/pull 10` yourself works.
- **Config entry missing**: check that `pfUI-ReadyCheck` is enabled in the AddOns list at character selection and that pfUI is installed.
