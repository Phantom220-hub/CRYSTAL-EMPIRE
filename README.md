# CRYSTAL EMPIRE

A Roblox mining + tycoon adventure starter project, built with Luau and Rojo.

## Current playable systems
- Server-authoritative crystal mining with a mobile-friendly MINE button.
- Crystal inventory capacity and coin selling station.
- Four pickaxe upgrades that increase mining power and backpack capacity.
- Generated starter island, crystal nodes, exchange station, and forge.
- Player data persistence through Roblox DataStoreService.
- Leaderboard stats and a responsive HUD.
- GitHub Actions builds a `.rbxlx` place artifact on every push.

## Build
The project uses [Rojo](https://rojo.space/) and [Foreman](https://github.com/rojo-rbx/foreman).

1. Install Foreman and run `foreman install`.
2. Run `rojo build default.project.json -o CrystalEmpire.rbxlx`.
3. Open the generated place in Roblox Studio and publish it to Roblox.

GitHub Actions performs steps 1–2 automatically. Download the artifact from the Actions run.

## Roblox setup
- Publish the place from Roblox Studio once.
- For saving, enable **Game Settings → Security → Enable Studio Access to API Services** while testing in Studio.
- DataStore access in a live published experience is handled by Roblox.
- Keep the experience owned by the account/group that will publish and operate it.

## Important limitations
GitHub can build the place file, but it cannot replace Roblox Studio's initial experience creation and publishing workflow. Roblox Open Cloud can publish updates to an already-created place when a valid API key and universe/place IDs are configured; never commit API keys or secrets to this repository.

## Monetization
The code intentionally starts without paid advantages or random paid rewards. Any future Game Passes or Developer Products should be clearly described and optional. Earnings are not guaranteed.
