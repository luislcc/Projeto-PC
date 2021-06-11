-module(gameEngine).
-export([addPlayer/3,removePlayer/2,newState/0,applyUserInput/4,probableCreature/1,getPoints/1,calculateState/2]).





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%constants
max_velocity(Radius) ->
	min_velocity() + 500/Radius.

constant_deaccelereation() ->
	60.

min_velocity() ->
	10.

max_creatures() ->
	10.

max_acceleration() ->
	20.

min_acceleration() ->
	(-10).

max_Radius() ->
	50.

min_Radius() ->
	5.

rads_per_Sec() ->
	(0.5).

energy_per_Sec()->
	50.

rads_per_creature()->
	4.

accel_per_creature()->
	4.

accel_per_key()->
	10.
%constants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%









%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%initializer
newState() -> {new_map(1000, 600, 40, 20, 9),#{},[]}.

new_map(Width, Height,RadMax, RadMin,Obst)->
	Obstacles = [{{rand:uniform()*Width, rand:uniform()*Height},RadMin + rand:uniform()*(RadMax-RadMin)} || _ <- lists:seq(1,Obst)],
	{Width, Height, Obstacles}.

%initializer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%base players

addPlayer(Pid,Username,State) ->
	create_player(State,Pid,Username,min_Radius()).

removePlayer(Pid,State) ->
	{Map,Players,Creatures} = State,
	{Map,maps:remove(Pid,Players),Creatures}.


create_player(State,Pid,Username,Rad) ->
	Info = #{},
	Info1 = maps:put(pos,new_position(State,Rad),Info),
	Info2 = maps:put(radius,Rad,Info1),
	Info3 = maps:put(direction,rand:uniform()*math:pi()*2,Info2),
	Info4 = maps:put(energy,100,Info3),
	Info5 = maps:put(velocity,min_velocity(),Info4),
	Info6 = maps:put(l_velocity,0,Info5),
	Info6 = maps:put(r_velocity,0,Info5),
	Info7 = maps:put(f_acceleration,0,Info6),
	Info8 = maps:put(l_acceleration,0,Info7),
	Info9 = maps:put(r_acceleration,0,Info8),
	Info10 = maps:put(points,0,Info9),
	Info11 = maps:put(is_boosting,false,Info10),
	Info12 = maps:put(is_angular_boostingL,false,Info11),
	Info13 = maps:put(is_angular_boostingR,false,Info12),
	Info14 = maps:put(username,Username,Info13),
	{element(1,State),maps:put(Pid,Info14,element(2,State)),element(3,State)}.


getPoints(State) ->
	[{maps:get(username,Player),maps:get(points,Player)} || {_,Player} <- maps:to_list(element(2,State))].

%base players
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%











%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%base criaturas
probableCreature(State) ->
	{Map,Players,Creatures} = State,
	NewCreatures = [maps:put(accel_ang,(rand:uniform(2)-1)*100,Creature) || Creature <- Creatures],
	Prob = rand:uniform(10),
	CountMax =  max_creatures(),
	if
		(Prob == 0) and (length(NewCreatures) < CountMax)-> create_creatures({Map,Players,NewCreatures});
		true -> {Map,Players,NewCreatures}
	end.

create_creatures(State) ->
	Info = #{},
	Vel_Min = min_velocity(),
	Vel_Max = max_velocity(min_Radius()),
	Info1 = maps:put(type,rand:uniform(2)-1,Info),
	Info2 = maps:put(pos,new_position(State,min_Radius()),Info1),
	Info3 = maps:put(radius,min_Radius()+0.2 + rand:uniform()* (max_Radius()-min_Radius()) ,Info2),
	Info4 = maps:put(direction,rand:uniform()*math:pi()*2,Info3),
	Info5 = maps:put(velocity,Vel_Min+rand:uniform()*(Vel_Max-Vel_Min),Info4),
	Info6 = maps:put(velocity_ang,Vel_Min+rand:uniform()*(Vel_Max-Vel_Min),Info5),
	Info7 = maps:put(accel_ang,(Vel_Min+rand:uniform()*(Vel_Max-Vel_Min))/20,Info6),
	{Map,Players,Creatures} = State,
	{Map,Players,[Info7 | Creatures]}. 


new_position(State, Radius) ->
	{_,_,MapObs} = element(1,State),
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

%base criaturas
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%












%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%update Player

updatePlayer(Player,TimeDelta) ->
	Player1 = updateEnergy(Player,TimeDelta),	
	Player2 = updateAccelPlayer(Player1,TimeDelta),
	Player3 = updateVelocityPlayer(Player2,TimeDelta),
	Player4 = updateRadiusPlayer(Player3,TimeDelta),
	updateDirectionPlayer(Player4,TimeDelta).


updateAccelPlayer(Player,TimeDelta)->
	Accf = maps:put(f_acceleration, max(min(maps:get(f_acceleration,Player)- constant_deaccelereation()*TimeDelta,max_acceleration()), min_acceleration()) ,Player),
	AccR = maps:put(r_acceleration, max(min(maps:get(r_acceleration,Player)- constant_deaccelereation()*TimeDelta,max_acceleration()), min_acceleration()) ,Accf),
	maps:put(l_acceleration, max(min(maps:get(l_acceleration,Player)- constant_deaccelereation()*TimeDelta,max_acceleration()), min_acceleration()) ,AccR).


updateVelocityPlayer(Player,TimeDelta)->
	Accf = maps:put(velocity, max(min(maps:get(velocity,Player)+maps:get(f_acceleration,Player) *TimeDelta, min_velocity()),max_velocity(maps:get(radius,Player))) ,Player),
	Accr = maps:put(r_velocity, max(min(maps:get(r_velocity,Player)+maps:get(r_acceleration,Player) *TimeDelta, 0),max_velocity(maps:get(radius,Player))) ,Accf),
	maps:put(l_velocity, max(min(maps:get(l_velocity,Player)+ maps:get(l_acceleration,Player)*TimeDelta, 0),max_velocity(maps:get(radius,Player))) ,Accr).


updateEnergy(Player,TimeDelta) ->
	Cond = maps:get(is_boosting,Player) or maps:get(is_angular_boostingL,Player) or maps:get(is_angular_boostingR,Player),
	NowEnergy = maps:get(energy,Player),
	if
		NowEnergy =< 0 -> maps:put(energy,NowEnergy+ energy_per_Sec()*TimeDelta/5,deactivateAllBoosts(Player));
		Cond -> maps:put(energy,NowEnergy- energy_per_Sec()*TimeDelta,Player);
		true -> maps:put(energy,NowEnergy+ energy_per_Sec()*TimeDelta/5,Player)
	end.


updateDirectionPlayer(Player,TimeDelta) ->
	maps:put(direction,fmod( maps:get(direction,Player) - (maps:get(r_velocity,Player)*TimeDelta) + (maps:get(l_velocity,Player)*TimeDelta)  ,2*math:pi()),Player).


deactivateAllBoosts(Player) ->
	Player1 = applyUserInputPlayer(Player,w,u),
	Player2 = applyUserInputPlayer(Player1,a,u),
	applyUserInputPlayer(Player2,d,u).


applyUserInputPlayer(Player,Key,KeyState) ->
	Eny = maps:get(energy,Player),
	Boost = maps:get(is_boosting,Player),
	BoostR = maps:get(is_angular_boostingR,Player),
	BoostL = maps:get(is_angular_boostingL,Player),
	case Key of
		w when (KeyState == d) and (Eny > 0.01) and (not Boost) -> maps:put(is_boosting,true,maps:put(f_acceleration, maps:get(f_acceleration,Player) + accel_per_key(), Player));
		w when (KeyState == u) and (Boost) -> maps:put(is_boosting,false,maps:put(f_acceleration, maps:get(f_acceleration,Player) - accel_per_key(), Player));

		a when (KeyState == d) and (Eny > 0.01) and (not BoostL) -> maps:put(is_angular_boostingL,true,maps:put(l_acceleration, maps:get(l_acceleration,Player) + accel_per_key(), Player));
		a when (KeyState == u) and (BoostL) -> maps:put(is_angular_boostingL,false,maps:put(l_acceleration, maps:get(l_acceleration,Player) - accel_per_key(), Player));

		a when (KeyState == d) and (Eny > 0.01) and (not BoostR) -> maps:put(is_angular_boostingR,true,maps:put(r_acceleration, maps:get(r_acceleration,Player) + accel_per_key(), Player));
		a when (KeyState == u) and (BoostR) -> maps:put(is_angular_boostingR,false,maps:put(r_acceleration, maps:get(r_acceleration,Player) - accel_per_key(), Player))
	end.


applyUserInput(Pid,State,Key,KeyState) ->
	{Map,Players,Creatures} = State,
	IsPlayer = maps:is_key(Pid,Players),
	if
		IsPlayer -> {Map,maps:put(Pid, applyUserInputPlayer(maps:get(Pid,Players),Key,KeyState),Players),Creatures};
		true -> State
	end.


updateRadiusPlayer(Player,TimeDelta) ->
	maps:put(radius,maps:get(radius,Player) - rads_per_Sec()*TimeDelta,Player).


giveAgility(Pid,Players,Agility) ->
	Player = maps:get(Pid,Players),
	maps:put(Pid, maps:put(f_acceleration, maps:get(f_acceleration,Player) + Agility, Player), Players).

giveRadius(Pid,Players,Radius) ->
	Player = maps:get(Pid,Players),
	maps:put(Pid, maps:put(radius, maps:get(radius,Player) + Radius, Player), Players).


givePoints(Pid,Players,Points) ->
	Player = maps:get(Pid,Players),
	maps:put(Pid, maps:put(points, maps:get(points,Player) + Points, Player), Players).	

invertPlayer(Pid,Players) ->
	Player = maps:get(Pid,Players),
	maps:put(Pid,maps:put(direction,invert_direction(maps:get(direction,Player)),Player),Players).

%update Player
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%update Creatures

updateCreatures(Creature,TimeDelta) ->
	updateDirectionCreature(updateVelocityAngCreature(Creature,TimeDelta),TimeDelta).


updateVelocityAngCreature(Creature,TimeDelta) ->
	maps:put(velocity_ang, min(max(maps:get(velocity_ang,Creature)+maps:get(accel_ang,Creature)*TimeDelta,-20),20)).

updateDirectionCreature(Creature,TimeDelta) ->
	maps:put(direction,fmod( maps:get(direction,Creature) + (maps:get(velocity_ang,Creature)*TimeDelta)  ,2*math:pi()),Creature).


%update Creatures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%update All Entities
updateAll(State,TimeDelta) ->
	{Map,Players,Creatures} = State,
	NewCreatures = [updateCreatures(Creature,TimeDelta) || Creature <- Creatures],
	NewPlayers = maps:from_list([{Pid,updatePlayer(Player,TimeDelta)} || {Pid,Player} <- maps:to_list(Players)]),
	{Map,NewPlayers,NewCreatures}.
%update All Entities
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%













%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%movement

moveAll(State,TimeDelta) ->
	{Map,Players,Creatures} = State,
	NewCreatures = [calculate_position(Creature,TimeDelta) || Creature <- Creatures],
	NewPlayers = maps:from_list([{Pid,calculate_position(Player,TimeDelta)} || {Pid,Player} <- maps:to_list(Players)]),
	{Map,NewPlayers,NewCreatures}.



calculate_position(Obj,TimeDelta) ->
	Velocity = maps:get(velocity),
	Position = maps:get(pos,Obj),
	Direction = maps:get(direction,Obj),
	{X,Y} = Position,
	{DeltaX, DeltaY} = {math:cos(Direction)*Velocity*TimeDelta,math:sin(Direction)*Velocity*TimeDelta},
	maps:put(pos,{X+DeltaX,Y+DeltaY},Obj).

fmod(A, B) -> 
	(A - trunc(A/B) * B).


invert_direction(Direction) ->
	fmod((Direction + math:pi()),2*math:pi()).

%movement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%












%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Colisions

distance(Xa,Ya,Xb,Yb) ->
	math:sqrt((Xa-Xb)*(Xa-Xb) + (Ya-Yb)*(Ya-Yb)).


detectColision(A,B) ->
	{{XA,YA},RadA} = A,
	{{XB,YB},RadB} = B,
	distance(XA,YA,XB,YB) < (RadA+RadB).

detectWall(A,Mx,My) ->
	{{New_x,New_y},Radius} = A,
	(New_x > (Mx - Radius)) or (New_x < Radius) or (New_y > (My - Radius)) or (New_y < Radius).


colisionObject(Obj, Elastic, Deadly, Poisonous, Good , Killable, Reset, Mx,My) ->
	ValsObj        = {maps:get(pos,Obj),map:get(radius,Obj)},
	CheckWalls     = [(fun(_) -> B = min_Radius(), if K =< B + (0.01) -> dead; true -> elastic end end) || {_,K} <- [ValsObj], detectWall(ValsObj,Mx,My)],
	CheckDead      = [dead || ValDead <- Deadly, detectColision(ValsObj,ValDead)], %morto
	CheckReset     = [reset || ValReset <- Reset, detectColision(ValsObj,ValReset)], %morreu por outro jogador
	CheckPoisonous = [poison || ValPoisonous <- Poisonous, detectColision(ValsObj,ValPoisonous)], %comida envenenada
	CheckKillable  = [kill || ValKillable <- Killable, detectColision(ValsObj,ValKillable)], %jogador
	CheckGood      = [good || ValGood <- Good, detectColision(ValsObj,ValGood)], %comida
	CheckElastic   = [elastic || ValElastic <- Elastic, detectColision(ValsObj,ValElastic)], %comida
	
	CheckWalls ++ CheckDead++CheckPoisonous++CheckKillable++CheckGood+CheckElastic++CheckReset.



checkColisionPlayer(Pid,Player,State) ->
	{Map,Players,Creatures} = State,
	Elastic = element(3,Map),
	B = min_Radius(),
	Rad = maps:get(radius,Player),
	Poisonous = [{maps:get(pos,Creature),maps:get(radius,Creature)} || Creature <- Creatures,  (maps:get(type,Creature) == 1)],
	Good = [{maps:get(pos,Creature),maps:get(radius,Creature)} || Creature <- Creatures, (maps:get(type,Creature) == 0)],
	Killable = [{maps:get(pos,PlayerL),maps:get(radius,PlayerL)} || {_,PlayerL} <- maps:to_list(Players), Rad > maps:get(radius,PlayerL)],
	Reset = [{maps:get(pos,PlayerL),maps:get(radius,PlayerL)} || {PidK,PlayerL} <- maps:to_list(Players), (Rad =< maps:get(radius,PlayerL)) and (Pid /= PidK)],
	if
		(Rad =< B + (0.01)) ->Deadly = Elastic++Poisonous;
		true ->Deadly = []
	end,

	colisionObject(Player,Elastic,Deadly,Poisonous,Good,Killable,Reset, element(1,Map), element(2,Map)).


checkColisionCreature(Creature,State) ->
	{Map,Players,Creatures} = State,
	Deadly = [{maps:get(pos,PlayerL),maps:get(radius,PlayerL)} || {_,PlayerL} <- maps:to_list(Players)],
	Elastic = element(3,Map) ++  [{maps:get(pos,CreatureK),maps:get(radius,CreatureK)} || CreatureK <- Creatures,  (Creature /= CreatureK)],
	colisionObject(Creature,Elastic,Deadly,[],[],[],[],element(1,Map), element(2,Map)).



applyChangesPlayer(Pid,Changes,State,Deads) ->
	{Map,Players,Creatures} = State,
	Player = maps:get(Pid,Players),
	if
		length(Changes) < 1 -> State;
		true -> [H|T] = Changes, 
		case H of
			dead -> {removePlayer(Pid,State),[Pid|Deads]};
			
			reset -> {MapK,PlayersK,CreaturesK} = create_player(State,Pid,maps:get(username,Player),max(maps:get(radius,Player)- rads_per_creature(),min_Radius())), applyChangesPlayer(Pid,T,{MapK, giveAgility(Pid,PlayersK,accel_per_creature()),CreaturesK} ,Deads);
			
			poison -> NewState = {Map,giveAgility(Pid,Players,(-1)* accel_per_creature()),Creatures}, applyChangesPlayer(Pid,T,NewState,Deads);
			
			kill -> applyChangesPlayer(Pid,T,{Map,givePoints(Pid,giveAgility(Pid,giveRadius(Pid,Players,rads_per_creature()),(-1)* accel_per_creature()),1),Creatures}, Deads);
			
			good -> applyChangesPlayer(Pid,T,{Map,giveAgility(Pid,giveRadius(Pid,Players,rads_per_creature()),accel_per_creature()),Creatures},Deads);
			
			_ -> applyChangesPlayer(Pid,T,{Map, invertPlayer(Pid,Players),Creatures},Deads)
		end
	end.



applyChangesCreature(Creature,Changes) ->
	Dead = lists:member(dead,Changes),
	Dir = lists:member(elastic,Changes),
	if 
		Dead -> [];
		Dir  -> [ maps:put(direction,invert_direction(maps:get(direction,Creature)),Creature) ];
		true -> [Creature]
	end.




checkColisionAll(State) ->
	{Map,Players,Creatures} = State,
	NewCreatures = lists:append([applyChangesCreature(Creature,checkColisionCreature(Creature,State)) || Creature <- Creatures]),
	PlCols = [{Pid,checkColisionPlayer(Pid,Player,State)} || {Pid,Player} <- maps:to_list(Players)],
	{{_,NewPlayers,_},Deads} = lists:foldl(fun({Pid,Changes},{Stt,Dds}) -> applyChangesPlayer(Pid,Changes,Stt,Dds) end,{State,[]},PlCols),
	{{Map,NewPlayers,NewCreatures},Deads}.

%Colisions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%













%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculate State

calculateState(State,TimeDelta) ->
	New = updateAll(State,TimeDelta),
	Next = moveAll(New,TimeDelta),
	checkColisionAll(Next).


%Calculate State
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

