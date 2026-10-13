# pfUI-ReadyCheck

A small third-party module for [pfUI](https://github.com/brues-code/pfUI) (vanilla 1.12 clients) that adds:

- a **Ready Check** button, visible only when you are raid leader / assistant (or party leader, optional)
- a **Pull** button that runs BigWigs' `/pull X`, with a configurable countdown

## Installation

Clone or download this repository into `Interface\AddOns\pfUI-ReadyCheck` (the folder name must match the `.toc` file, so rename the folder if you download the zip). Restart the game.

## Usage

| Action | Result |
| --- | --- |
| Left-click **Ready Check** | Starts a ready check |
| Right-click **Ready Check** | Announces in raid warning / raid / party, then starts a ready check |
| Left-click **Pull** | Runs `/pull X` (X = configured seconds) |
| Right-click **Pull** | Runs `/pull 0` (cancel) |
| `/rc` | Starts a ready check |
| `/rcpull` | Runs `/pull X` with the configured time |
| `/pfui unlock` | Move the buttons |

## Configuration

`/pfui` -> Thirdparty -> Ready Check: enable button, show in party, button text, sizes, show pull button, pull time (seconds).

## Requirements

pfUI, and BigWigs for the pull timer.
