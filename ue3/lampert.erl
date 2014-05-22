-module(lampert).
-export([go/0,setup/0]).
 

sendGivenIds(X,Y) ->
   X!Y.


loop(Ids,LokalTime) ->
   %io:fwrite("entered loop~w~n",[self()]),
   Random = random:uniform(), 
   %io:fwrite("~w has Random ~w ~n",[self(),Random]),
   if Random>=0.8 ->
      Receiver = random:uniform(4),
      lists:nth(Receiver,Ids)! LokalTime;
      true ->
         nop
   end,
   receive
      ReceivedTime -> 
         io:fwrite("~w has time ~w received ~w~n",[self(),ReceivedTime,LokalTime]),
         NewLokalTime = max(ReceivedTime,LokalTime)
   after 5->
         NewLokalTime = LokalTime
   end,
   timer:sleep(100),
   io:fwrite("~w,~w~n",[self(),NewLokalTime]),
   loop(Ids,NewLokalTime+1).

setup() ->
   random:seed(erlang:now()),
   io:fwrite("start process ~w~n",[self()]),
   LokalTime = random:uniform(80),
   io:fwrite("waiting for receive ~w~n",[self()]),
   timer:sleep(100),
   receive 
      Ids ->
      io:fwrite("received ~w~n",[self()]),
      loop(Ids,LokalTime)
   end.

go() ->
   io:fwrite("start~n"),
   Pid2 = spawn(lampert, setup, []),
   io:fwrite("first started~n"),
   Pid3 = spawn(lampert, setup, []),
   Pid4 = spawn(lampert, setup, []),
   Pid5 = spawn(lampert, setup, []),
   io:fwrite("setup done ~n"),
   timer:sleep(500),
   Pids = [Pid2,Pid3,Pid4,Pid5],
   SendIds = fun(X) -> 
               io:fwrite("sending to ~w~n",[X]),
                  sendGivenIds(X,Pids)
             end,
   lists:map(SendIds,Pids),
   io:fwrite("ids send ~n"),
   timer:sleep(infinity).
