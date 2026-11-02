# Eagle Eye | Multiplayer Networking Showcase
A standalone Godot 4 networking demonstration based on the multiplayer architecture developed for Eagle Eye, a multiplayer FPS project. Featuring ENet, peer-to-peer communication through a host, player authority, synchronized movement, and server-approved interactions using Remote Procedure Calls (RPCs).


# Features
* ENet Networking: Host and join multiplayer sessions using Godot's ENet implementation over UDP.
* Connection Management: Handle peer connections, disconnections, connection failures, and duplicate connection attempts.
* Dynamic Player Spawning: Automatically replicate player creation and removal using MultiplayerSpawner.
* Multiplayer Authority: Assign ownership using unique peer IDs so each player controls their own character.
* Movement Synchronization: Replicate player positions using MultiplayerSynchronizer.
* Player-Specific Cameras: Activate the camera belonging to the locally controlled player.
* Remote Procedure Calls (RPCs): Send interaction requests to the server, validate the sender's participation, and broadcast approved interactions.=
* Two-Player Support: Demonstrate multiplayer communication between a host and one client.
