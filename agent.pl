/**
 * Author: Andrew Walls
 * Major: Computer Science
 * Creation Date: 3/27/2019
 * Due Date: 4/26/2019
 * Course: CSC548 - Artificial Intelligence II
 * Professor Name: Dr. Schwesinger
 * Assignment: 6
 * Filename: agent.pl
 * Purpose: Intelligent agent to solve the wumpus world problem.  
 */

:- dynamic escape/1.
:- dynamic acts/1.
:- dynamic temp_acts/1.
:- dynamic died/1.
:- dynamic has_arrow/1.
:- dynamic has_gold/1.
:- dynamic just_shot/1.

init_agent :- retractall(has_arrow(_)),
	      retractall(has_gold(_)),
	      retractall(died(_)),
     	      retractall(acts(_)),
              retractall(temp_acts(_)),
       	      retractall(just_shot(_)),
	      retractall(escape(_)),
	      assert(escape(no)),
              assert(acts([])),
	      assert(temp_acts([])),
     	      assert(just_shot(no)),
              assert(has_arrow(yes)),
              assert(has_gold(no)),
              assert(facing(east)),
              assert(died(no)).

restart_agent :- retractall(has_arrow(_)),
		 retractall(has_gold(_)),
	         retractall(died(_)),
	         retractall(just_shot(_)),
	         retractall(escape(_)),
	       	 assert(escape(no)),
		 assert(just_shot(no)),
                 assert(has_arrow(yes)),
                 assert(has_gold(no)),
                 assert(facing(east)),
	         assert(died(yes)).

run_agent(Percept,Action) :-
  %display_world, UNCOMMENT THESE 2 LINES TO SEE WORLD STEP-BY-STEP
  %disp_percept([Percept]), 
  acts(Size),
  
  /*************
   * THE RULES *
   *************/                                                     
   
  % RULE 1: IF YOU DIE, GO TO LAST SAFE SPOT
  (died(yes), 
   \+length(Size,1), 
   has_gold(no)) -> retract(acts([Move|Moves])),
                    assert(acts(Moves)),							
                    retractall(temp_acts(MoreTempActions)),                               
                    append(MoreTempActions, Move,Actions1),
		    assert(temp_acts(Actions1)),									
                    Action = Move,
	       	    !;
						  
  (died(yes), 
   length(Size,1),
   has_gold(no)) -> retractall(died(_)),
		    assert(died(no)),
		    update_action_tl,
                    Action = turnleft,
	      	    !;
						   
  % RULE 2: IF IT GLITTERS, PICK IT UP
  (nth0(2,Percept,yes),
    has_gold(no)) -> retractall(has_gold(_)),
                     assert(has_gold(yes)),
		     update_action_g,
		     Action = grab,
		     !;
			
  % RULE 3: AGENT WILL HAVE A HAIR TRIGGER, SHOOTS ON SMELL ALONE 
 (nth0(0,Percept,yes),
  has_arrow(yes),
  has_gold(no)) -> Action = shoot,
                   update_action_s,
                   retractall(just_shot(_)),
                   retractall(has_arrow(_)),
                   assert(just_shot(yes)),
                   assert(has_arrow(no)),
                   !;																	  
	
  % RULE 4: IF YOU HIT A WALL, JUST TURNLEFT
  (nth0(3,Percept,yes), 
    has_gold(no)) -> update_action_tl,
                     Action = turnleft,
		     !;
							
  % RULE 5: IF YOU MADE IT BACK WITH GOLD, CLIMB OUT OF CAVE
  (agent_location(1,1),has_gold(yes)) -> Action = climb,
                                         !;
																	 
  % GOLDEN RULE : IF YOU GRAB THE GOLD, PLOT YOUR ESCAPE
  (has_gold(yes), escape(no)) -> acts(Q),
				 naiverev(Q,G),
				 append([turnleft,turnleft],G,E),
				 replace(turnleft,turnright,E,F),
                                 retractall(escape(_)),
                                 assert(escape(yes)),
				 retractall(temp_acts(_)),
				 assert(temp_acts(F)),
                                 Action = grab,
                                 !;					

  (has_gold(yes), 
   escape(yes)) -> retract(temp_acts([Jig|Jigs])),
                   assert(temp_acts(Jigs)),														  
                   Action = Jig,
                   !;
                                                            																	 
  % DEFAULT RULE: IF ALL ELSE FAILS, GOFORWARD																	 
   (nth0(2,Percept,no),
    has_gold(no)) -> update_action_gf,
                     Action = goforward.
  
  /*************
   * END RULES *
   *************/

%Adds actions taken to a temporary list in case agent should die
update_action_g :- acts(TempActions),
                   append(TempActions, [grab],Actions),
		   retractall(acts(_)),
		   assert(acts(Actions)).		

update_action_gf :- acts(TempActions),
                    append(TempActions, [goforward],Actions),
		    retractall(acts(_)),
		    assert(acts(Actions)).		

update_action_tl :- acts(TempActions),
                    append(TempActions,[turnleft],Actions),
		    retractall(acts(_)),
		    assert(acts(Actions)).		
								  
update_action_s :- acts(TempActions),
                   append(TempActions, [shoot],Actions),
		   retractall(acts(_)),
		   assert(acts(Actions)).				   		
			   										 
disp_percept([]).
disp_percept([H|T]) :-
  format("Stench = ~w Breeze = ~w Glitter = ~w Bump = ~w Scream =~w~n",H),
  disp_percept(T).
  
% Needed a quick find and replace algorithm to swap turnleft's for turnright's to escape
% From https://stackoverflow.com/questions/5850937/prolog-element-in-lists-replacement  

replace(_, _, [], []).
replace(O, R, [O|T], [R|T2]) :- replace(O, R, T, T2).
replace(O, R, [H|T], [H|T2]) :- H \= O, replace(O, R, T, T2).

% Needed a quick algorithm to reverse a list, also to help plan escape route
% From http://www.learnprolognow.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse25 

naiverev([],[]).
naiverev([H|T],R):-  naiverev(T,RevT),  append(RevT,[H],R).   
