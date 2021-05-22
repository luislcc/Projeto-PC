-module(login_manager).
-export([start/0,create_account/2,close_account/2,login/2,logout/1,online/0]).

create_account(Username,Passwd) ->
	?MODULE ! {create_account,self(),Username,Passwd},
	receive {Res,?MODULE} -> Res end.

close_account(Username,Passwd) ->
	?MODULE ! {close_account,self(),Username,Passwd},
	receive {Res,?MODULE} -> Res end.

login(Username,Passwd) ->
	?MODULE ! {login,self(),Username,Passwd},
	receive {Res,?MODULE} -> Res end.

logout(Username) ->
	?MODULE ! {logout,self(),Username},
	receive {Res,?MODULE} -> Res end.

online()->
	?MODULE ! {online,self()},
	receive {_,Res,?MODULE} -> Res end.

loop(Dbase)->
   
   receive

    {create_account,Pid,Username,Passwd} -> 
    	case maps:is_key(Username,Dbase) of
    		true -> Pid ! {user_exists,?MODULE}, loop(Dbase);
    		false -> Pid ! {valid_create,?MODULE}, loop(maps:put(Username,{Passwd,false},Dbase))
    	end;

    {close_account,Pid,Username,Passwd} ->
    	case maps:get(Username,Dbase,error) of
    		{Passwd,_} -> Pid ! {valid_close,?MODULE}, loop(maps:remove(Username,Dbase));
    		error -> Pid ! {invalid_close,?MODULE},loop(Dbase)
    	end;

    {login,Pid,Username,Passwd} ->
    	case maps:get(Username,Dbase,error) of
    		{Passwd,false} ->
    			Pid ! {valid_login,?MODULE},
    			loop(maps:update(Username,{Passwd,true},Dbase));

    		_ -> Pid ! {invalid_login,?MODULE},loop(Dbase)

    	end;

    {logout,Pid,Username} ->
    	case maps:get(Username,Dbase,error) of
    		{Passwd,true} ->
    			Pid ! {valid_logout,?MODULE},
    			loop(maps:update(Username,{Passwd,false},Dbase));

    		_ -> Pid ! {invalid_logout,?MODULE}, loop(Dbase)

    	end;

    {online,Pid} -> 
    		Pid ! {online,[X || X <- maps:keys(Dbase), element(2,maps:get(X,Dbase))],?MODULE},
    		loop(Dbase)

    end.

start()-> register(?MODULE,spawn(fun()-> loop(maps:new()) end ) ).
