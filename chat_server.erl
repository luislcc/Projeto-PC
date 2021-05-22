-module(chat_server).
-export([start/1,stop/0]).

room(Pids)->
	receive
		{enter,Pid} ->
			io:format("user_entered~n",[]),
			room([Pid | Pids]);

		{line,Data} ->
			%X = string:trim(Data),
			%Y = list_to_integer(binary_to_list(X)),
			io:format("received ~p ~n",[Data]),
			[Pid ! {line,Data} || Pid <- Pids],
			room(Pids);

		{leave,Pid} ->
			io:format("user has left~n",[]),
			room(Pids -- [Pid])

	end.

acceptor(Room,LSock)->
	{ok,Sock} = gen_tcp:accept(LSock),
	spawn(fun()->acceptor(Room,LSock) end),
	Room ! {enter,self()},
	user(Sock,Room).

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
			Room ! {line,Data},
			user(Sock,Room);

		{tcp_closed,_} ->
			Room ! {leave,self()};

		{tcp_error,_,_} ->
			Room ! {leave,self()}
	end.

stop()->
	?MODULE ! {stop,bruh}.




start(Port) -> register(?MODULE,spawn(fun() -> server(Port) end) ). 