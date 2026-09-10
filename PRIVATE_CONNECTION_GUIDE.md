# HARLEY PRIVATE CONNECTION GUIDE
# Dell Workstation -> Chromebook & S23
# Generated: September 9, 2026

## DELL SSH IS RUNNING BUT PORTS ARE BLOCKED/FILTERED

The Dell has OpenSSH running on port 22 but something is blocking connections.
This guide gives you multiple ways to reach Dell from the Book and Twin.

## OPTION 1: TAILSCALE DIRECT (RECOMMENDED)

Dell Tailscale IP: 100.104.127.89
Chromebook Tailscale IP: 100.82.48.34
S23 Tailscale IP: 100.126.38.38

If Tailscale is connected on both ends, try:
  ssh georg@100.104.127.89

If Tailscale is blocked, try Tailscale direct connection:
  tailscale ping jimmysgsmworkstation-1

## OPTION 2: REVERSE SSH TUNNEL (Dell connects OUT to you)

If Dell can reach the Book, Dell creates a reverse tunnel.
On Dell, run this command:

  ssh -R 2222:localhost:22 georg@100.82.48.34 -N

Then on Chromebook, connect locally:
  ssh georg@localhost -p 2222

For S23, Dell would need to connect to S23 first.

## OPTION 3: TAILSCALE FUNNEL (expose Dell SSH via public URL)

On Dell, run:
  tailscale funnel 22

This exposes SSH on a public HTTPS URL like:
  https://jimmysgsmworkstation-1.georgiaboy77535.gmail.com.dev.tailscale.net

Then from Chromebook:
  ssh georg@jimmysgsmworkstation-1.georgiaboy77535.gmail.com.dev.tailscale.net

NOTE: Tailscale Funnel may need to be enabled in admin console.

## OPTION 4: HARLEYLINK WEB ACCESS

Dell runs HarleyLink on port 8080. If accessible:
  http://100.104.127.89:8080

This gives browser-based access to Dell desktop.

## OPTION 5: OLLAMA API (AI MODELS ONLY)

If you just need the AI models:
  http://100.104.127.89:11434/v1/chat/completions

Models available:
  - harley:latest (3.4GB, Qwen3.5 uncensored)
  - harley-tech:latest (3.4GB, full GSM/system expertise)
  - harley-uncensored:latest (3.4GB)
  - dolphin-harley:latest (4.1GB)

## OPTION 6: TAILSCALE SSH

Tailscale has built-in SSH. If enabled:
  tailscale ssh jimmysgsmworkstation-1

This bypasses all port blocking because it goes through
Tailscale's encrypted mesh, not regular TCP ports.

To enable Tailscale SSH on Dell:
  1. Open Tailscale app
  2. Go to Settings -> SSH
  3. Enable "SSH access"
  4. Set auth mode to "Password" or "Keys"

## OPTION 7: WINDOWS RDP VIA TAILSCALE

If SSH is completely blocked, use RDP:
  From Chromebook: remmina or xfreerdp to 100.104.127.89
  Username: georg
  Password: (Windows login)

RDP uses port 3389 which may also be blocked.
If so, Tailscale RDP works differently.

## OPTION 8: CHROME REMOTE DESKTOP

Already configured on Dell. Access from Chromebook:
  https://remotedesktop.google.com
  Sign in with: georgiaboy77535@gmail.com

## CREDENTIALS
  Dell Username: georg
  Dell Tailscale: 100.104.127.89
  Dell SSH Port: 22
  Ollama Port: 11434
  HarleyLink Port: 8080
  RDP Port: 3389
  Gmail: georgiaboy77535@gmail.com
  App Password: ikwiazqmwjwbsiua

## OPTION 9: SSH ON PORT 443 (ACTIVE NOW)
Harley has a proxy running on port 443 forwarding to SSH port 22.
Port 443 (HTTPS) is usually allowed through firewalls.

From Chromebook:
  ssh georg@100.104.127.89 -p 443

From S23 Termux:
  ssh georg@100.104.127.89 -p 443

Password: (your Windows login password)

## IMMEDIATE ACTION
Try Option 9 (port 443) FIRST - it's running now.
If that doesn't work, try Option 8 (Chrome Remote Desktop).
If nothing works, run the admin scripts on Dell to fix firewall.
