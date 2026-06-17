# brainCloud GDScript SDK

Official brainCloud client SDK for **Godot 4** (GDScript).  
Supports all brainCloud services — authentication, leaderboards, entities, RTT, relay multiplayer, and more.

---

## Requirements

- Godot 4.2 or later
- A [brainCloud](https://portal.braincloudservers.com/) account and app

---

## Installation

1. Copy the `addons/braincloud/` folder from this repo into the root of your Godot project.
2. Enable the plugin: **Project → Project Settings → Plugins → brainCloud → Enable**.

You can also find the SDK on the [Godot Asset Library](https://godotengine.org/asset-library/asset/5196) — download the zip, extract it, and copy `addons/braincloud/` the same way.

---

## Plugin Setup

Once the plugin is enabled a **brainCloud** dock appears on the right side of the editor. Enter your app credentials here and click **Save**.

| Dark theme | Light theme |
|:---:|:---:|
| ![brainCloud panel – dark](docs/plugin-panel-dark.png) | ![brainCloud panel – light](docs/plugin-panel-light.png) |

| Field | Description |
|---|---|
| **App ID** | Your app's ID from the brainCloud portal |
| **App Secret** | Your app's secret key |
| **Server URL** | Leave as default unless using a private deployment |
| **App Version** | Your game version string (e.g. `1.0.0`) |
| **Debug Logging** | Prints all API traffic to the Godot output panel |

Credentials are saved to `addons/braincloud/braincloud.cfg`, which the plugin automatically adds to your `.gitignore` so secrets are never committed.

---

## Autoload Singleton

When the plugin is enabled it registers **`brainCloud`** as a global autoload singleton (`BrainCloudWrapper`). It reads your saved credentials at startup and initialises itself automatically — no code required for basic setup.

Access it from any script:

```gdscript
brainCloud          # the BrainCloudWrapper singleton
brainCloud.authentication_service
brainCloud.entity_service
brainCloud.leaderboard_service
# … and every other brainCloud service
```

---

## Authenticating

All authentication calls are `await`-able and return a `Dictionary` with the full server response.

### Anonymous (simplest)

```gdscript
func _ready() -> void:
    var response = await brainCloud.authenticate_anonymous()
    if response.status == 200:
        print("Authenticated! Profile ID: ", response.data.profileId)
    else:
        print("Auth failed: ", response.reason_code)
```

### Email / Password

```gdscript
var response = await brainCloud.authenticate_email_password("user@example.com", "password", true)
if response.status == 200:
    print("Logged in as: ", response.data.profileId)
```

### Universal (username + password)

```gdscript
var response = await brainCloud.authenticate_universal("my_username", "my_password", true)
```

### Reconnect (restore a previous session)

`reconnect()` restores a session using only the stored **anonymous id** and **profile id**.
The SDK never stores or replays usernames or passwords, so reconnection always goes through
anonymous authentication (matching the C# SDK). Use `can_reconnect()` to check first.

```gdscript
if brainCloud.can_reconnect():
    var response = await brainCloud.reconnect()
```

### Auto-reconnect (transparent long sessions)

Enable auto-reconnect to have the SDK silently re-authenticate and replay any calls that
were lost when an authenticated session expires — game code never has to handle the
`PLAYER_SESSION_EXPIRED` error itself.

```gdscript
brainCloud.enable_auto_reconnect(true)

# Optional: be notified when a transparent reconnect succeeds or finally fails
brainCloud.braincloud_client.register_auto_reconnect_callback(func(response):
    print("Auto-reconnect result: ", response.status))
```

If re-authentication fails, auto-reconnect disables itself to avoid an infinite loop and the
original calls fail through to their callers.

Other supported providers: `authenticate_google`, `authenticate_apple`, `authenticate_facebook`, `authenticate_steam`, `authenticate_nintendo`, `authenticate_twitter`, and more — see `BrainCloudWrapper.gd` for the full list.

---

## Calling Services

Every brainCloud service is available through the singleton. All calls are `await`-able.

```gdscript
# Read a player entity
var response = await brainCloud.entity_service.get_entities_by_type("profile")
if response.status == 200:
    var entities = response.data.entities
    print("Got %d entities" % entities.size())

# Write a global statistic increment
await brainCloud.global_statistics_service.increment_global_statistics({"gamesPlayed": 1})

# Run a cloud script
var result = await brainCloud.script_service.run_script("MyCloudScript", {"param": "value"})
print(result.data.response)
```

---

## RTT & Relay Multiplayer

Real-Time Tech (RTT) must be enabled on your brainCloud app before use.

### Enable RTT

```gdscript
# Register event callbacks before enabling
brainCloud.rtt_service.register_rtt_lobby_callback(func(data): print("Lobby event: ", data))
brainCloud.rtt_service.register_rtt_event_callback(func(data): print("Event: ", data))

var response = await brainCloud.rtt_service.enable_rtt("WEBSOCKET")
if response.status == 200:
    print("RTT connected")
```

### Connect to a Relay Server

```gdscript
var connect_options = {
    "host":    lobby_data.connectData.host,
    "port":    lobby_data.connectData.ports.ws,
    "ssl":     false,
    "lobbyId": lobby_data.lobbyId,
    "passcode": lobby_data.passcode
}

brainCloud.relay_service.register_relay_callback(func(net_id, data): _on_relay_data(net_id, data))
brainCloud.relay_service.register_system_callback(func(data): print("System: ", data))

await brainCloud.relay_service.connect(connect_options,
    func(_r): print("Relay connected"),
    func(_r): print("Relay failed"))

# Send to all players
var payload = "hello".to_utf8_buffer()
brainCloud.relay_service.send(payload, BrainCloudRelay.TO_ALL_PLAYERS, true, true, BrainCloudRelay.CHANNEL_HIGH_PRIORITY_1)
```

---

## Manual Initialisation

If you prefer not to use the plugin panel you can initialise the SDK in code instead:

```gdscript
func _ready() -> void:
    brainCloud.init("YOUR_APP_SECRET", "YOUR_APP_ID", "1.0.0")
```

---

## Example Project

See the [brainCloud Godot Examples](https://github.com/getbraincloud/examples-godot) repo for a complete **Relay Test App-GDScript** demonstrating login, lobby, RTT, and relay multiplayer.

---

## Links

- [brainCloud Portal](https://portal.braincloudservers.com/)
- [API Reference](https://getbraincloud.com/apidocs/apiref/)
- [Documentation](https://getbraincloud.com/apidocs/)
- [Support](https://help.getbraincloud.com/)
