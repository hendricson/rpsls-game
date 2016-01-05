-module(rpsls).

-author('Anton Nikiforov <anton.hendricson@gmail.com>').

-export([start/1]).

-define(RPSLS_SIGNS, [rock, spock, paper, lizard, scissors]).

start(Port)-> 
	spawn(
		fun () -> 
			{ok, LSocket} = gen_tcp:listen(Port, [list,{active, false},{packet, http}]),  
			acceptor(LSocket) 
		end).
				
   	
acceptor(LSocket) ->	
	{ok, Socket} = gen_tcp:accept(LSocket),
    	Pid = spawn(
		fun () -> 
			Socket = receive {take, S} -> S end,
			handle(Socket)
		end),			
	gen_tcp:controlling_process(Socket, Pid),	
	Pid ! {take, Socket},	
	acceptor(LSocket).

	
handle(Socket) ->

	inet:setopts(Socket, [{active, once}]),

	receive

	   	{http, Socket, {http_request, 'GET', {abs_path, Path}, _Vers}} ->

			case mochiweb_util:parse_qs(Path) of
				
				
				[{"/", []}] -> 
					
					{ok, Data} = file:read_file("../html/index.html"),
					gen_tcp:send(Socket, rpsls_server:response(200, Data)),
					handle(Socket);
					
				
				[{"/do?v",Value}] ->
					
					random:seed(now()),
					PNumber = name_to_number(Value),
					CNumber = random:uniform(length(?RPSLS_SIGNS)),
					PPower = rpsls_util:mod(CNumber - PNumber, length(?RPSLS_SIGNS)),
					CPower = rpsls_util:mod(PNumber - CNumber, length(?RPSLS_SIGNS)),

				Res1 = if CPower > PPower -> lists:concat(["{\"win\" : 1, \"result\":\"Computer wins!\""]);
					 CPower < PPower -> lists:concat(["{\"win\" : 0, \"result\":\"Player wins!\""]);
					 true -> lists:concat(["{\"win\" : -1, \"result\":\"Draw game!\""])
				      end,
				Res2 = lists:concat([", \"player_chooses\":\"", number_to_name(PNumber), "\", \"computer_chooses\":\"", number_to_name(CNumber), "\"}"]),
					
					gen_tcp:send(Socket, rpsls_server:response(200, Res1++Res2)),
										
					handle(Socket);
					
				_ -> 
				
				handle(Socket)					
			end;	

		{tcp_closed, Socket} ->	
			gen_tcp:close(Socket);


		{tcp_error, Socket, _} ->
			gen_tcp:close(Socket);
		
		_ -> 
			handle(Socket)
						
	end.

name_to_number(Name) ->
	rpsls_util:index(list_to_atom(Name), ?RPSLS_SIGNS)-1.

number_to_name(Number) -> %Number >= 0, Number <= 4
	atom_to_list(lists:nth(Number+1, ?RPSLS_SIGNS)).
