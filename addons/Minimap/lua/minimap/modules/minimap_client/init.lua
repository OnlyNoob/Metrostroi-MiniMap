--Need Bromsock to work!
if !MiniMap.Client then MiniMap.Client = {} end

function MiniMap.Client.Init()
	--Load config
	include("minimap/configs/modules/minimap_client.lua")
	
	if MiniMap.Client.Enabled then
		MsgC(Color(20, 255, 20), "[MiniMap.Client]: Module enabled. Starting server.\n")
		require("bromsock")
		MiniMap.Client.StartServer()
	else
		MsgC(Color(255, 20, 20), "[MiniMap.Client]: Module disabled.\n")
		return
	end
end

function MiniMap.Client.StartServer()
	if MiniMap.Client.Server then MiniMap.Client.Server:Close() end
	MiniMap.Client.Server = BromSock(BROMSOCK_TCP)
	MiniMap.Client.Port = MiniMap.Client.Port or 5890

	MiniMap.Client.Server:SetCallbackAccept(CallbackAccept)
	
	if (not MiniMap.Client.Server:Listen(MiniMap.Client.Port)) then
		MsgC(Color(255, 20, 20), "[MiniMap.Client]: Failed to listen on port "..MiniMap.Client.Port.."\n")
	else
		MsgC(Color(20, 255, 20), "[MiniMap.Client]: Server listening on port "..MiniMap.Client.Port.."\n")
	end
	
	--MiniMap.Client.Server:Receive()
	MiniMap.Client.Server:Accept()
end

function CallbackAccept(sock, clientsock)
	MsgC(Color(20, 255, 20), "[MiniMap.Client]: Accepted - "..tostring(sock).." | "..tostring(clientsock).."\n")

	clientsock:SetCallbackReceive(function(sock, packet)
		print("[MiniMap.Client] Received:", sock, packet)
		print("[MiniMap.Client] R_String:", packet:ReadStringAll())
			
		--packet:WriteStringRaw("Woop woop woop a string")
		--sock:Send(packet)
			
		-- normaly you'd want to call Receive again to read the next packet. However, we know that the client ain't going to send more, so fuck it.
		-- theres only one way to see if a client disconnected, and that's when a error occurs while sending/receiving.
		-- this is why most applications have a disconnect packet in their code, so that the client informs the server that he exited cleanly. There's no other way.
		-- We set a timeout, so let's be stupid and hope there's another packet incomming. It'll timeout and disconnect.
		sock:Receive()
	end)
	
	clientsock:SetCallbackDisconnect(function(sock)
		MsgC(Color(255, 20, 20), "[MiniMap.Client]: Disconnected - "..tostring(sock).."\n")
	end)
	
	clientsock:SetTimeout(1000) -- timeout send/recv commands in 1 second. This will generate a Disconnect event if you're using callbacks
	
	clientsock:Receive()
		
	-- Who's next in line?
	sock:Accept()
end

function CallbackReceive(sock, packet)

end

function CallbackDisconnect(sock)

end

MiniMap.Client.Init()