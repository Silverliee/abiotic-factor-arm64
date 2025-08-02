# Abiotic Factor Dedicated Server for ARM64

Docker container to run an Abiotic Factor dedicated server on ARM64 systems using Box64 emulation.

## Prerequisites

- Docker and Docker Compose
- ARM64 architecture (aarch64)
- 4GB RAM minimum
- Ports 7777/UDP and 27015/UDP available

## Quick Start

1. Clone this repository
2. Run `docker-compose up -d`
3. Connect to your server at `<your-ip>:7777`

## Configuration

Environment variables can be set in `docker-compose.yml`:

| Variable | Default | Description |
|----------|---------|-------------|
| `MaxServerPlayers` | `6` | Maximum number of players |
| `Port` | `7777` | Server port |
| `QueryPort` | `27015` | Steam query port |
| `ServerPassword` | `password` | Server password |
| `SteamServerName` | `ARM64 Linux Server` | Server name |
| `WorldSaveName` | `Cascade` | World save name |
| `AutoUpdate` | `false` | Auto-update on startup |

## File Structure

```
├── gamefiles/     # Game files (auto-created)
├── data/         # Persistent save data (auto-created)
└── docker-compose.yml
```

## Management

```bash
# Start server
docker-compose up -d

# Stop server
docker-compose down

# View logs
docker-compose logs -f

# Update server
docker-compose down && docker-compose up -d --build
```

## Troubleshooting

**Server won't start**: Check logs with `docker-compose logs`

**Poor performance**: Increase memory limits in docker-compose.yml

**Can't connect**: Ensure ports 7777/UDP and 27015/UDP are open

## Technical Details

This container uses:
- Box64 for x86_64 emulation on ARM64
- Wine for Windows compatibility
- SteamCMD for game server installation
- Xvfb for headless operation

Performance may vary on ARM64 systems compared to native x86_64 servers.