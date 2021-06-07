-module(game_state).
-export([new_state/5, calculate_state/2,create_player/3,alternate_propulsion/3,alternate_angular_propulsion/3, count_players/1]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Constantes

max_velocity(Radius) ->
	10 + 50/Radius.

min_velocity() ->
	10.

max_acceleration() ->
	20.

min_acceleration() ->
	(-5).

max_Radius() ->
	30.

min_Radius() ->
	5.

max_ang_velocity() ->
	10.

max_side_acceleration() ->
	20.

pressed_propulsion() ->
	5.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


caculate_state(State,TimeDelta) ->
	check_Overlaps(calculate_players(calculate_creatures(State,TimeDelta),TimeDelta),TimeDelta). %returns new state and [Deads]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

new_state() -> {new_map(1000, 600, 20, 10, 6),#{},[]}.


new_map(Width, Height,RadMax, RadMin,Obst)->
	Obstacles = [{{rand:uniform()*Width, rand:uniform()*Height},RadMin + rand:uniform()*(RadMax-RadMin)} || _ <- lists:seq(1,Obst)],
	{Width, Height, Obstacles}.


create_player(State,Pid,Radius) ->
	if Radius < 1 -> Radius = min_Radius()*2 end,
	Info = #{},
	Info = maps:put(pos,new_position(State,Radius),Info),
	Info = maps:put(radius,Radius,Info),
	Info = maps:put(direction,rand:uniform()*math:pi()*2,Info),
	Info = maps:put(energy,100,Info),
	Info = maps:put(velocity,min_velocity(),Info),
	Info = maps:put(angular_velocity,0,Info),
	Info = maps:put(fwd_acceleration,0,Info),
	Info = maps:put(propulsion,0,Info),
	Info = maps:put(side_acceleration,0,Info),
	Info = maps:put(side_propulsion,0,Info),
	Info = maps:put(points,0,Info),
	Info = maps:put(is_boosting,false,Info),
	Info = maps:put(is_angular_boosting,false,Info),
	maps:put(Pid,Info,element(2,State)).


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
	Creatures_pos = [ {maps:get(pos,Creature),maps:get(radius,Creature)} || Creature <- maps:values(element(3,State))],
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



create_creature(State, Vel_Max, Vel_Min) ->
	Info = #{},
	Info = maps:put(type,rand:uniform(2)-1,Info),
	Info = maps:put(pos,new_position(State,min_Radius()),Info),
	Info = maps:put(radius,min_Radius(),Info),
	Info = maps:put(direction,rand:uniform()*math:pi()*2,Info),
	Info = maps:put(velocity,Vel_Min+rand:uniform()*(Vel_Max-Vel_Min),Info),
	[Info | element(3,State)].






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% Overlaps between entities

check_Overlaps(State,TimeDelta) -> 
	{State,[]}.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Creatures
calculate_creatures(State,TimeDelta) ->
	{A,B,Creatures} = State,
	NewCreatures = [ environment_collision(State,Obj,TimeDelta) || Obj <- Creatures],
	{A,B,NewCreatures}.




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Player



calculate_player(State,Player,TimeDelta) -> 
	Player = calculate_velocity(Player,TimeDelta),
	Player = calculate_acceleration(Player,TimeDelta),
	Player = calculate_propulsion(Player),
	Player = calculate_angular_velocity(Player,TimeDelta),
	Player = calculate_angular_acceleration(Player,TimeDelta),
	Player = calculate_angular_propulsion(Player,TimeDelta),
	% calculate_energy
	environment_collision(State,Player,TimeDelta).


calculate_acceleration(Player,TimeDelta) -> 
	Delta = maps:get(propulsion,Player),
	Acc = (Delta*TimeDelta) + maps:get(acceleration,Player),
	Acc = min(max(Acc, min_acceleration()),max_acceleration()),
	maps:put(acceleration,Acc,Player).



calculate_velocity(Player,TimeDelta) ->
	Acc = maps:get(acceleration,Player),
	Vel = (Acc*TimeDelta) + maps:get(acceleration,Player),
	Vel = min(max(Acc, min_velocity()),max_velocity(maps:get(radius,Player))),
	maps:put(velocity,Vel,Player).


calculate_side_acceleration(Player,TimeDelta) -> 
	Delta = maps:get(side_propulsion,Player),
	Acc = (Delta*TimeDelta) + maps:get(side_acceleration,Player),
	Acc = min(max(Acc, -1* max_side_acceleration()),max_side_acceleration()),
	maps:put(side_acceleration,Acc,Player).


calculate_angular_velocity(Player,TimeDelta) ->
	Acc = maps:get(side_acceleration,Player),
	Vel = (Acc*TimeDelta) + maps:get(angular_velocity,Player),
	Vel = min(max(Acc, -1* max_ang_velocity()), max_ang_velocity()),
	maps:put(angular_velocity,Vel,Player).


calculate_direction(Player,TimeDelta) ->
	Vel = maps:get(angular_velocity,Player),
	Direction = maps:get(direction,Player),
	NewDirection = fmod(Direction + Vel*TimeDelta,2*math:pi()),
	maps:put(direction,NewDirection,Player).



calculate_players(State,TimeDelta) ->
	{A,Players,C} = State,
	Aux = maps:to_list(Players),
	NewPlayers = [ {Pid,calculate_player(State,Player,TimeDelta)} || {Pid,Player} <- Aux],
	{A,maps:from_list(NewPlayers),C}.



alternate_propulsion(Pid,State,KeyState) ->
	{A,Players,C} = State,
	Player = maps:get(Pid,Players),
	Fact = (-1),
	if KeyState -> Fact*(-1) end,
	Delta = maps:get(propulsion,Player) + Fact*(pressed_propulsion()),
	NewPlayer = maps:put(propulsion,Delta,Player),
	NewPlayers = maps:put(Pid,NewPlayer,Players),
	{A,NewPlayers,C}.



calculate_propulsion(Player) ->
	Prop = maps:get(propulsion,Player),
	Acc = maps:get(acceleration,Player),
	M = min_acceleration(),
	if
		Acc > M + (0.01)  -> NewProp = Prop + math:sqrt(Acc);
		true -> NewProp = 0
	end,
	maps:put(propulsion,NewProp,Player).


alternate_angular_propulsion(Pid,State,Factor) ->
	{A,Players,C} = State,
	Player = maps:get(Pid,Players),
	Delta = maps:get(side_propulsion,Player) + Factor*(pressed_propulsion()),
	NewPlayer = maps:put(side_propulsion,Delta,Player),
	NewPlayers = maps:put(Pid,NewPlayer,Players),
	{A,NewPlayers,C}.



calculate_angular_propulsion(Player) ->
	Prop = maps:get(side_propulsion,Player),
	Acc = maps:get(side_acceleration,Player),
	if
		Acc > (0.01)  -> NewProp = Prop - Acc;
		Acc < (0.01)  -> NewProp = Prop - Acc;
		true -> NewProp = 0
	end,
	maps:put(propulsion,NewProp,Player).






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Deslocamento

environment_collision(State, Obj,TimeDelta)->
	Radius = maps:get(radius,Obj),
	Position = maps:get(pos,Obj),
	Direction = maps:get(direction,Obj),
	Velocity = maps:get(velocity,Obj),

	{{New_x,New_y},Direction} = calculate_position(Position,Direction,Velocity,TimeDelta),
	{MapW,MapH,Positions} = element(1,State),
	B = lists:any((fun({{X,Y},Rad}) -> math:sqrt( math:pow(New_x-X,2) + math:pow(New_y-Y,2)) < (Rad+Radius) end),Positions),	
	if
		B -> {{New_x,New_y},Direction} = calculate_position(Position,invert_direction(Direction),Velocity,TimeDelta);
		(New_x > (MapW - Radius)) or (New_x < Radius) or (New_y > (MapH - Radius)) or (New_y < Radius) -> {{New_x,New_y},Direction} = calculate_position(Position,invert_direction(Direction),Velocity,TimeDelta)
	end,
	maps:put(pos,{New_x,New_y},Obj), maps:put(direction,Direction,Obj),
	Obj.	



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