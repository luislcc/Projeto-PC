-module(queue_manager).
-export([start/0,stop/0]).


initialize()->
	spawn(fun()-> game:start() end ).
	loop(#{},0).



loop(Queue,PlayerNum) ->
	receive
		{join,Pid,Username} when (PlayerNum > 2) -> loop(enqueue(Pid,Username,Queue),PlayerNum);
		{join,Pid,Username} -> joinGame(Pid,Username), loop(Queue,PlayerNum+1);		
		{leave,Pid,_} -> Pid!{leftQueue,queue_manager},loop(removeQueue(Pid,Queue),PlayerNum);
		{left,game} -> {Dequeued,NewQueue} = dequeue(Queue), loop(NewQueue,PlayerNum-1+Dequeued)
	end.


joinGame(Pid,Username) ->
	game!{toJoin,Pid,Username,queue_manager},
	Pid!{joined,game}.


enqueue(Pid,Username,Queue)->
	Position = length(maps:to_list(Queue)),
	Pid!{enqueued,Position,queue_manager},
	maps:put(Pid,{Position,Username}).


removeQueue(Pid,Queue)->
	Position = maps:get(Pid,Queue),
	NewQueue = maps:remove(Pid,Queue),
	NewNewQueue = removeQueueAux(Position,maps:to_list(NewQueue)),
	[ PidK!{enqueued,PositionK} || {PidK,{PositionK,_}} <- maps:to_list(NewNewQueue)],
	NewNewQueue.

removeQueueAux(Position,QueueList)->
	if
		length(QueueList) < 1 -> QueueList;
		true -> [{PidK,{UserK,PositionK}}|T] = QueueList, 
				if
					PositionK > Position -> [{PidK,{UserK,PositionK-1}}|removeQueueAux(Position,T)];
					true -> [{PidK,{UserK,PositionK}}|removeQueueAux(Position,T)]
				end  
	end.


dequeue(Queue) ->
	Firsts = [{PidK,UserK} || {PidK,{UserK,PositionK}} <- maps:to_list(Queue), PositionK == 0],
	if 
		length(Firsts) < 1 -> {0,Queue};
		true -> [{PidF,UserF} | _] = Firsts, joinGame(PidF,UserF), {1,removeQueue(PidF,Queue)}  
	end. 


start()-> register(?MODULE,spawn(fun()-> initialize() end )).

stop()-> ?MODULE!stop.