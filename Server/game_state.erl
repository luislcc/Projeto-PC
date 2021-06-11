-module(game_state).
-export([new_state/0, calculate_state/3,create_player/4,alternate_propulsion/3,alternate_angular_propulsion/3, count_players/1,get_points/1]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Constantes

max_velocity(Radius) ->
	min_velocity() + 500/Radius.

min_velocity() ->
	10.

max_creatures() ->
	10.

max_acceleration() ->
	20.

min_acceleration() ->
	(-5).

max_Radius() ->
	300.

min_Radius() ->
	5.

max_ang_velocity() ->
	10.

max_side_acceleration() ->
	20.

pressed_propulsion() ->
	20.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


get_points(State) ->
	{_,Players,_} = State,
	ListPlayers = maps:to_list(Players),
	[{maps:get(username,Player), maps:get(points,Player)} || {Pid,Player} <- ListPlayers].


calculate_state(State,TimeDelta,TimeStampCreatures) ->	
	{State1,Deads} = check_Overlaps(calculate_players(calculate_creatures(State,TimeDelta),TimeDelta)), %returns new state, [Deads]
	Prob = rand:uniform()*100,
	MaxC = max_creatures(),
	TimeDeltaCreatures = timer:now_diff(erlang:timestamp(),TimeStampCreatures),
	if
		(Prob < 1) and (TimeDeltaCreatures > 1000000) and (length(element(3,State)) < MaxC)-> NumberOfCreatures = 1,
					 NewState = create_creatures(State1,NumberOfCreatures),
					 {NewState,Deads,erlang:timestamp()};

		true -> {State1,Deads,TimeStampCreatures}
	end. 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

new_state() -> {new_map(1000, 600, 20, 10, 6),#{},[]}.


new_map(Width, Height,RadMax, RadMin,Obst)->
	Obstacles = [{{rand:uniform()*Width, rand:uniform()*Height},RadMin + rand:uniform()*(RadMax-RadMin)} || _ <- lists:seq(1,Obst)],
	{Width, Height, Obstacles}.


create_player(State,Pid,Radius,Username) ->
	%if Rad < 1 -> Radius = min_Radius()*2 end,
	Info = #{},
	Info1 = maps:put(pos,new_position(State,Radius),Info),
	Info2 = maps:put(radius,Radius,Info1),
	Info3 = maps:put(direction,rand:uniform()*math:pi()*2,Info2),
	Info4 = maps:put(energy,100,Info3),
	Info5 = maps:put(velocity,min_velocity(),Info4),
	Info6 = maps:put(angular_velocity,0,Info5),
	Info7 = maps:put(fwd_acceleration,0,Info6),
	Info8 = maps:put(propulsion,0,Info7),
	Info9 = maps:put(side_acceleration,0,Info8),
	Info0 = maps:put(side_propulsion,0,Info9),
	Info10 = maps:put(points,0,Info0),
	Info11 = maps:put(is_boosting,false,Info10),
	Info12 = maps:put(is_angular_boosting,false,Info11),
	Info13 = maps:put(username,Username,Info12),
	{element(1,State),maps:put(Pid,Info13,element(2,State)),element(3,State)}.


count_players(State) -> 
	{_,Players,_} = State,
	maps:size(Players).


remove_player(State,Pid) ->
	{A,Players,B} = State,
	NewPlayers = maps:remove(Pid,Players),
	{A,NewPlayers,B}.


get_players(State) ->
	{A,Players,B} = State,
	maps:keys(Players).

new_position(State, Radius) ->
	{MapW,MapH,MapObs} = element(1,State),
	Players_pos = [ {maps:get(pos,Player),maps:get(radius,Player)} || Player <- maps:values(element(2,State))],
	Creatures_pos = [ {maps:get(pos,Creature),maps:get(radius,Creature)} || Creature <- element(3,State)],
	new_positionAux(State, lists:append(lists:append(Players_pos,Creatures_pos),MapObs), Radius).



new_positionAux(State,Positions,Radius) ->
	{MapW,MapH,_} = element(1,State),
	New_x = min(max(rand:uniform()*MapW, Radius),MapW-Radius),
	New_y = min(max(rand:uniform()*MapH, Radius),MapH-Radius),
	B = lists:any((fun({{X,Y},Rad}) -> math:sqrt( math:pow(New_x-X,2) + math:pow(New_y-Y,2)) < (Rad+Radius) end),Positions),
	if
		B -> new_positionAux(State,Positions,Radius);
	
		true ->  {New_x,New_y}
	end.

create_creatures(State,Number)->
	if
		Number == 0 -> State;

		true -> create_creatures(create_creature(State),Number-1)
	end.

create_creature(State) ->
	Info = #{},
	Vel_Min = min_velocity(),
	Vel_Max = max_velocity(min_Radius()),
	Info1 = maps:put(type,rand:uniform(2)-1,Info),
	Info2 = maps:put(pos,new_position(State,min_Radius()),Info1),
	Info3 = maps:put(radius,min_Radius(),Info2),
	Info4 = maps:put(direction,rand:uniform()*math:pi()*2,Info3),
	Info5 = maps:put(velocity,Vel_Min+rand:uniform()*(Vel_Max-Vel_Min),Info4),
	Info6 = maps:put(velocity_ang,Vel_Min+rand:uniform()*(Vel_Max-Vel_Min),Info5),
	Info7 = maps:put(accel_ang,(Vel_Min+rand:uniform()*(Vel_Max-Vel_Min))/20,Info6),
	{Map,Players,Creatures} = State,
	{Map,Players,[Info7 | Creatures]}. 







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% Overlaps between entities


%check_Overlaps(StateDeads,TimeDelta) ->
%	{State,Deads} = StateDeads,
%	{Map,Players,Creatures} = State,
%	Aux = maps:to_list(Players),
%	NewPlayers = [ {Pid,calculate_overlap_player(State,Player,TimeDelta)} || {Pid,Player} <- Aux],
%	{State,[]}.

%check_Overlaps_aux(Players,Creatures)->
%	if
%		length(Players) == 0 ->	{Players,Creatures};
%
%		true -> [H | T] = Players, {NewPlayer,NewPlayers,NewCreatures} = overlap(H,T,Creatures),
%		 {ResPlayers,ResCreatures} = check_Overlaps_aux(NewPlayers,NewCreatures), {[NewPlayer | ResPlayers],ResCreatures}
%								
%	end.

%overlap(Player,Players,Creatures)->
%	[].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Creatures
calculate_creatures(State,TimeDelta) ->
	{A,B,Creatures} = State,
	Vel_Min = min_velocity(),
	Vel_Max = max_velocity(min_Radius()),
	NewCreatures = [element(1,environment_collision(State,Obj,TimeDelta)) || Obj <- Creatures],
	NewNewCreatures = [maps:put(accel_ang,(Vel_Min+rand:uniform()*(Vel_Max-Vel_Min))*100,maps:put(velocity_ang,TimeDelta*maps:get(accel_ang,NewCreature) + maps:get(velocity_ang,NewCreature), maps:put(direction, fmod(TimeDelta*maps:get(velocity_ang,NewCreature) + maps:get(direction,NewCreature), 2*math:pi()) ,NewCreature))) || NewCreature <- NewCreatures],
	{A,B,NewCreatures}.




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Player

calculate_angular_acceleration(Player,TimeDelta) -> 
	Delta = maps:get(side_propulsion,Player),
	Acc = (Delta*TimeDelta) + maps:get(side_acceleration,Player),
	Acc1 = min(max(Acc, -1* max_side_acceleration()),max_side_acceleration()),
	maps:put(side_acceleration,Acc1,Player).

calculate_acceleration(Player,TimeDelta) -> 
	Delta = maps:get(propulsion,Player),
	Acc = (Delta*TimeDelta) + maps:get(fwd_acceleration,Player),
	Acc1 = min(max(Acc, min_acceleration()),max_acceleration()),
	%io:format("Acceleration: ~p~n",[Acc1]),
	maps:put(fwd_acceleration,Acc1,Player).



calculate_velocity(Player,TimeDelta) ->
	Acc = maps:get(fwd_acceleration,Player),
	Vel = (Acc*TimeDelta) + maps:get(velocity,Player),
	Vel1 = min(max(Vel, min_velocity()),max_velocity(maps:get(radius,Player))),
	%io:format("Velocity: ~p~n",[Vel1]),
	maps:put(velocity,Vel1,Player).

calculate_angular_velocity(Player,TimeDelta) ->
	Acc = maps:get(side_acceleration,Player),
	%io:format("ACELERACAO ANGULAR: ~p~n",[Acc]),
	Vel = (Acc*TimeDelta) + maps:get(angular_velocity,Player),
	Vel1 = min(max(Vel, -1* max_ang_velocity()), max_ang_velocity()),
	maps:put(angular_velocity,Vel1,Player).


calculate_direction(Player,TimeDelta) ->
	Vel = maps:get(angular_velocity,Player),
	%io:format("VELOCIDADE ANGULAR: ~p~n",[Vel]),
	Direction = maps:get(direction,Player),
	NewDirection = fmod(Direction + Vel*TimeDelta,2*math:pi()),
	maps:put(direction,NewDirection,Player).



calculate_players(State,TimeDelta) ->
	{A,Players,C} = State,
	Aux = maps:to_list(Players),
	NewPlayers = [ {Pid,calculate_player(State,Player,TimeDelta)} || {Pid,Player} <- Aux],
	DeadPlayers = [X || {X,{Y,Z}} <- NewPlayers, Z == true],
	ResPlayers = [{X,Y} || {X,{Y,Z}} <- NewPlayers, Z == false],
	{{A,maps:from_list(ResPlayers),C},DeadPlayers}.



alternate_propulsion(Pid,State,KeyState) ->
	{A,Players,C} = State,
	Player = maps:get(Pid,Players),
	if 
		KeyState -> Fact = 1;
		true -> Fact = -10
	end,
	Delta = maps:get(propulsion,Player) + Fact*(pressed_propulsion()),
	%io:format("DELTA: ~p~n Fact ~p~n",[Delta,Fact]),
	NewPlayer = maps:put(propulsion,Delta,Player),
	NewPlayers = maps:put(Pid,NewPlayer,Players),
	{A,NewPlayers,C}.



calculate_propulsion(Player) ->
	Prop = maps:get(propulsion,Player),
	Acc = maps:get(fwd_acceleration,Player),
	M = min_acceleration(),
	if
		Acc > 0  -> NewProp = Prop;
		true -> NewProp = 0
	end,
	%io:format("PROPULSION: ~p~n",[NewProp]),
	maps:put(propulsion,NewProp,Player).


alternate_angular_propulsion(Pid,State,Factor) ->
	{A,Players,C} = State,
	Player = maps:get(Pid,Players),
	Delta = maps:get(side_propulsion,Player) + Factor*(pressed_propulsion()),
	%io:format("Delta: ~p~n",[Delta]),
	NewPlayer = maps:put(side_propulsion,Delta,Player),
	NewPlayers = maps:put(Pid,NewPlayer,Players),
	{A,NewPlayers,C}.



calculate_angular_propulsion(Player,TimeDelta) ->
	Prop = maps:get(side_propulsion,Player),
	Acc = maps:get(side_acceleration,Player),
	if
		Acc > (0.01)  -> NewProp = Prop - Acc;
		Acc < (0.01)  -> NewProp = Prop - Acc;
		true -> NewProp = 0
	end,
	maps:put(side_propulsion,NewProp,Player).


calculate_player(State,Player,TimeDelta) -> 
	Player0 = calculate_velocity(Player,TimeDelta),
	Player1 = calculate_acceleration(Player0,TimeDelta),
	Player2 = calculate_propulsion(Player1),
	Player3 = calculate_angular_velocity(Player2,TimeDelta),
	Player4 = calculate_angular_acceleration(Player3,TimeDelta),
	Player5 = calculate_angular_propulsion(Player4,TimeDelta),
	Player6 = calculate_direction(Player5,TimeDelta),
	% calculate_energy
	environment_collision(State,Player6,TimeDelta).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Deslocamento
%Problemas com direction pq single assignment
environment_collision(State, Obj,TimeDelta)->
	Radius = maps:get(radius,Obj),
	Position = maps:get(pos,Obj),
	Direction = maps:get(direction,Obj),
	Velocity = maps:get(velocity,Obj),

	{{New_x,New_y},Direction1} = calculate_position(Position,Direction,Velocity,TimeDelta),
	{MapW,MapH,Positions} = element(1,State),
	B = lists:any((fun({{X,Y},Rad}) -> math:sqrt( math:pow(New_x-X,2) + math:pow(New_y-Y,2)) < (Rad+Radius) end),Positions),	
	if
		B -> {{New_x1,New_y1},Direction2} = calculate_position(Position,invert_direction(Direction1),Velocity,TimeDelta),Obj1 = maps:put(pos,{New_x1,New_y1},Obj),
	Obj2 = maps:put(direction,Direction2,Obj1),
	{Obj2,Radius < min_Radius()+ 0.01};

		(New_x > (MapW - Radius)) or (New_x < Radius) or (New_y > (MapH - Radius)) or (New_y < Radius) -> {{New_x1,New_y1},Direction2} = calculate_position(Position,invert_direction(Direction1),Velocity,TimeDelta),Obj1 = maps:put(pos,{New_x1,New_y1},Obj),
	Obj2 = maps:put(direction,Direction2,Obj1),
	{Obj2,Radius < min_Radius()+ 0.01};

		true -> Obj1 = maps:put(pos,{New_x,New_y},Obj),
				Obj2 = maps:put(direction,Direction1,Obj1),
				{Obj2,false}
	end.

		



calculate_position(Position, Direction, Velocity,TimeDelta) ->
	{X,Y} = Position,
	{DeltaX, DeltaY} = {math:cos(Direction)*Velocity*TimeDelta,math:sin(Direction)*Velocity*TimeDelta},
	{{X+DeltaX,Y+DeltaY},Direction}.


fmod(A, B) -> 
	(A - trunc(A/B) * B).


invert_direction(Direction) ->
	fmod((Direction + math:pi()),2*math:pi()).






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% debug

print_stt(State) ->
	io:format("~p ~n",[State]).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

check_Overlaps(StateDeads) ->
	{State,Deads} = StateDeads,
	{Map,Players,Creatures} = State,
	%io:format("PLAYERS: ~p~n",[Players]),
	K = is_map(Players),
	%io:format("IS MAP: ~p~n",[K]),
	ListPlayers = maps:to_list(Players),
	{NewListPlayers,NewCreatures,NewDeads} = check_Overlaps_Aux(ListPlayers,Creatures,Deads),
	{{Map,maps:from_list(NewListPlayers),NewCreatures},NewDeads}.


check_Overlaps_Aux(Players,Creatures,Deads) ->
	if
		(length(Players) < 1) -> {Players,Creatures,Deads};
		true -> [H | T] = Players, {P,C,D} = check_Overlaps_Aux(T,Creatures,Deads), overlaps_player(H,maps:from_list(Players),Creatures,Deads)
	end.



overlap_player_player(PlayerA, PlayerB) -> % -1 se ocorreu a colisão e o player B comeu A, 0 se elastica, 1 se A comeu B, 2 se não houve colisão
	{Xa,Ya} = maps:get(pos,PlayerA),
	{Xb,Yb} = maps:get(pos,PlayerB),
	Ra =  maps:get(radius,PlayerA),
	Rb =  maps:get(radius,PlayerB),
	Dist = distance(Xa,Ya,Xb,Yb),
	if
		(Dist < Ra) and (Rb - Ra < 0.01) and (Rb - Ra > (- 0.01)) -> (0);
		(Dist < Ra) and (Ra > Rb) -> (-1);
		(Dist < Rb) and (Rb > Ra) -> (1);
		true -> 2
		
	end.




overlap_player_creature(Player,Creature) -> % true se comeu
	%io:format("PLAYER: ~p~n",[Player]),
	{Xa,Ya} = maps:get(pos,Player),
	{Xb,Yb} = maps:get(pos,Creature),
	Ra =  maps:get(radius,Player),
	Dist = distance(Xa,Ya,Xb,Yb),
	Dist =< Ra.



overlaps_player(PlayerAInfo,Players,Creatures,Deads) ->
	{Pid,PlayerA} = PlayerAInfo,
	%K = is_map(Players),
	%io:format("IS MAP PLAYERS: ~p~n",[K]),
	%G = is_map(PlayerA),
	%io:format("IS MAP: ~p~n",[G]),

	B = lists:any(fun(K) -> K == Pid end, Deads),
	if
		 B -> {Players,Creatures,Deads};
		 true -> I = 3  %miguezão
	end,
	Overlaps_players = [{PidB,PlayerB,overlap_player_player(PlayerA,PlayerB)} || {PidB,PlayerB} <- maps:to_list(Players), PidB /= Pid],
	Eaten_by = [Pid || {Pid,PlayerB,Cond} <- Overlaps_players, Cond == -1],
	Has_Eaten = [{Pid,PlayerB} || {Pid,PlayerB,Cond} <- Overlaps_players, Cond == 1],
	Has_no_Over = [{Pid,PlayerB} || {Pid,PlayerB,Cond} <- Overlaps_players, Cond == 2],
	Elastic = [{Pid,PlayerB} || {Pid,PlayerB,Cond} <- Overlaps_players, Cond == 0],
	Creatures_Eaten = [ maps:get(type,Creature) || Creature <- Creatures, overlap_player_creature(PlayerA,Creature)],
	Creatures_not_Eaten = [ Creature || Creature <- Creatures, not overlap_player_creature(PlayerA,Creature)],
	All_buffs = Creatures_Eaten ++ Has_Eaten,



	D = length(Eaten_by) > 0,
	K = [lmao || Tp <- Creatures_Eaten, Tp == 1],
	Rad = maps:get(radius,PlayerA),
	Radius_Min = min_Radius(),
	%Vel_Max = max_velocity(min_Radius()),

	if
		D -> [PidB | T] = Eaten_by,
				   PlayerB = maps:get(PidB,Players),
			{[{PidB,buff_player(PlayerB,[2])}| [{PidK,PlayerK} || {PidK,PlayerK,CondK} <- Overlaps_players, PidK /= PidB]],Creatures,[Pid]};
		
		(length(K) > 0) and (Rad < Radius_Min + (0.01))  -> {[{PidK,PlayerK} || {PidK,PlayerK,CondK} <- Overlaps_players],Creatures_not_Eaten,[Pid]};


		true -> {changes(Elastic,All_buffs,Has_no_Over,PlayerAInfo) , Creatures_not_Eaten, [PidK || {PidK,PlayerK} <- Has_Eaten]}
	end.



changes(Elastic,All_buffs,Has_no_Over,PlayerAInfo) ->
	Res = [{Pid, invert_player_direction(Player)} ||  {Pid,Player} <- Elastic],
	Res2 = Res ++ Has_no_Over,
	{PidA,PlayerA} = PlayerAInfo,
	[{PidA,buff_player(PlayerA,All_buffs)}| Res2].




invert_player_direction(Player) ->
	Dir = maps:get(direction,Player),
	maps:put(direction,invert_direction(Dir),Player).



buff_player(Player,Buffs) -> %
	if
		(length(Buffs) == 0 ) -> Player;

		true -> [H | T] = Buffs, apply_buffer(buff_player(Player,T),H)	
	end.


apply_buffer(Player,Buff) ->
	Rad = maps:get(radius,Player),
	Pts = maps:get(points,Player),
	Jk = maps:get(propulsion,Player),
	if
		(Buff == 0) -> P2 = maps:put(radius,min(Rad+increment(),max_Radius()),Player), maps:put(propulsion,Jk+jk_increment(),P2); %good 
		
		(Buff == 1) -> maps:put(propulsion,Jk-jk_increment(),Player); %bad
		
		true -> P2 = maps:put(radius,min(Rad+increment(),max_Radius()),Player), P3 = maps:put(propulsion,Jk-jk_increment(),P2), maps:put(points,Pts+1,P3) %player
	end.

increment() ->
	1.

jk_increment() ->
	1000.


distance(Xa,Ya,Xb,Yb) ->
	math:sqrt((Xa-Xb)*(Xa-Xb) + (Ya-Yb)*(Ya-Yb)).


%mapa
	%obstaculos
	%tamanho 

%jogador
	%tamanho
	%posição
	%direção
	%energia
	%velocidade Máxima
	%aceleração
	%pontuação

%criaturas
	%posição
	%tipo
	%velocidade
	%direção







% -module(myqueue).
% -export ([create/0, enqueue/2, dequeue/1]).

% create() -> {[],[]}.

% enqueue({L1,L2},Elem) -> {[Elem | L1],L2}.

% dequeue({[],[]}) -> empty;
% dequeue({L1,[]}) -> dequeue({[],lists:reverse(L1)});
% dequeue({L1,[Head | Tail]}) -> {{L1,Tail},Head}.
