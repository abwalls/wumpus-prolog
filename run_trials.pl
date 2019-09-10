%  CSC 548, Spring 2019, Assignment 5 Solution


max_agent_trials(10).
max_agent_actions(100).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run_trials(Actions,Score,Iterations) :-
  initialize(Percept),
  init_agent,
  outer_loop(Percept,Actions,1,Score,Iterations).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outer_loop(_,[],NumTries,0,0) :- % agent exceeds maximum tries
  max_agent_trials(N),
  NumTries > N,
  !.

outer_loop(Percept,Actions,NumTries,Score,Trials) :-
  inner_loop(1,Percept,Acts),
  agent_score(Score1),
  process_iteration(Acts,Actions,NumTries,Score2,Trials1),
  Score is Score1 + Score2,
  Trials is Trials1 + 1.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
process_iteration(Acts,Acts,_,0,0) :-
  agent_gold(N),
  N >= 1,
  agent_in_cave(no),
  !.

process_iteration(_,Actions,NumTries,Score,Trials) :-
  restart(NewPercept),
  restart_agent,
  NumTries1 is NumTries + 1,
  outer_loop(NewPercept,Actions,NumTries1,Score,Trials).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inner_loop(_,_,[]) :- % agent died
  agent_health(dead),
  !.

inner_loop(_,_,[]) :- % agent left cave
  agent_in_cave(no),
  !.

inner_loop(NumActions,_,[]) :- % agent allowed only N actions
  max_agent_actions(N),
  NumActions > N,
  !.

inner_loop(NumActions,Percept,[Action | Actions]) :-
  run_agent(Percept,Action),
  execute(Action,NewPercept),
  NumActions1 is NumActions + 1,
  inner_loop(NumActions1,NewPercept,Actions).
