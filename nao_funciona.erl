-module(chat_server).
-export([start/1,stop/0]).

room(Pids)->
	io:format("PID: ~p ~n",[Pids]),
	receive
		{enter,Pid} ->
			io:format("user_entered~n",[]),
			room([Pid | Pids]);

		{line,Data} ->
			io:format("received ~p ~n",[Data]),
			[Pid ! {line,Data} || Pid <- Pids],
			room(Pids);

		{leave,Pid} ->
			io:format("user has left~n",[]),
			room(Pids -- [Pid]);

		_ -> io:format("bruh~n",[])

	end.

acceptor(Room,LSock)->
	Msg = gen_tcp:accept(LSock),
	case Msg of
		{ok,Sock} -> Pid = spawn(fun() -> user(Sock,Room) end),
					  Room ! {enter,Pid},
					  acceptor(Room,LSock);

		_ -> io:format("bruh")
	end.

server(Port)->
	{ok,LSock} = gen_tcp:listen(Port,[binary,{packet,line},{reuseaddr,true}]),
	Room = spawn(fun()->room([]) end),
	spawn(fun() -> acceptor(Room,LSock) end),
	receive
		{stop,bruh} -> ok
	end.

user(Sock,Room)->
	receive
		{line,Data} -> 
			gen_tcp:send(Sock,Data),
			user(Sock,Room);

		{tcp,_,Data} ->
			io:format("recebi"),
			Room ! {line,Data},
			user(Sock,Room);

		{tcp_closed,_} ->
			Room ! {leave,self()};

		{tcp_error,_,_} ->
			Room ! {leave,self()};

		Msg -> io:format("~p",[Msg])
	end.

stop()->
	?MODULE ! {stop,bruh}.




start(Port) -> register(?MODULE,spawn(fun() -> server(Port) end) ). 