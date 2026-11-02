extends Node3D

const PORT: int = 9999
const HOST_SPAWN := Vector3(-3, 0, 0)
const CLIENT_SPAWN := Vector3(3, 0, 0)

@export var player_scene: PackedScene
@onready var players_container: Node3D = $Players

var peer: ENetMultiplayerPeer


func _ready() -> void:
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func host_game() -> void:
	if is_connection_active():
		push_warning("Already hosting or connected to a session.")
		return
	
	
	peer = ENetMultiplayerPeer.new()

	var error := peer.create_server(PORT, 2)

	if error != OK:
		push_error("Failed to create server: " + error_string(error))
		return

	multiplayer.multiplayer_peer = peer

	print("Server started on port ", PORT)
	print("Local peer ID: ", multiplayer.get_unique_id())

	spawn_player(multiplayer.get_unique_id())



func join_game(address: String) -> void:
	if is_connection_active():
		push_warning("Already hosting or connected to a session.")
		return
		
	peer = ENetMultiplayerPeer.new()

	var error := peer.create_client(address, PORT)

	if error != OK:
		push_error("Failed to initiate connection: " + error_string(error))
		return

	multiplayer.multiplayer_peer = peer

	print("Attempting to connect to ", address)


func _on_connected_to_server() -> void:
	print("Successfully connected!")
	print("My peer ID: ", multiplayer.get_unique_id())


func _on_connection_failed() -> void:
	push_error("Connection to server failed.")
	
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	peer = null


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if not event.pressed or event.echo:
			return

		if event.keycode == KEY_H:
			print("H pressed: Hosting...")
			host_game()

		elif event.keycode == KEY_J:
			print("J pressed: Joining...")
			join_game("127.0.0.1")
		
		elif event.keycode == KEY_F:
			if multiplayer.is_server():
				request_interaction()
			elif multiplayer.multiplayer_peer != null:
				request_interaction.rpc_id(1)


func spawn_player(id: int) -> void:
	if not multiplayer.is_server():
		return

	var player := player_scene.instantiate() as CharacterBody3D

	player.name = str(id)
	
	if id == 1:
		player.position = HOST_SPAWN
	else:
		player.position = CLIENT_SPAWN

	players_container.add_child(player, true)

	print("Spawned player: ", id)


func _on_peer_connected(id: int) -> void:
	print("Peer connected: ", id)

	if multiplayer.is_server():
		spawn_player(id)


func _on_peer_disconnected(id: int) -> void:
	print("Peer disconnected: ", id)

	if multiplayer.is_server():
		var player := players_container.get_node_or_null(str(id))

		if player != null:
			player.queue_free()


func is_connection_active() -> bool:
	return peer != null and (
		peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED
	)

func _on_server_disconnected() -> void:
	print("Disconnected from server.")
	
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	peer = null




@rpc("any_peer", "reliable")
func request_interaction() -> void:
	if not multiplayer.is_server():
		return

	var sender_id := multiplayer.get_remote_sender_id()

	if sender_id == 0:
		sender_id = multiplayer.get_unique_id()

	if not players_container.has_node(str(sender_id)):
		return

	print("Server approved interaction from peer: ", sender_id)

	broadcast_interaction.rpc(sender_id)


@rpc("authority", "call_local", "reliable")
func broadcast_interaction(player_id: int) -> void:
	print("Player ", player_id, " performed an interaction!")
