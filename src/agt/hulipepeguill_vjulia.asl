
/*

Implementation of a Tic-Tac-Toe player that just plays random moves.

When the agent is started it must first perform a 'sayHello' action.
Once all agents have done this, the game or tournament starts.

Each turn the agent will observe the following percepts:

- symbol(x) or symbol(o) 
	This indicates which symbol this agent should use to mark the cells. It will be the same in every turn.

- a number of marks:  e.g. mark(0,0,x) , mark(0,1,o) ,  mark(2,2,x)
  this indicates which cells have been marked with a 'x' or an 'o'. 
  Of course, in the first turn no cell will be marked yet, so there will be no such percept.

- round(Z)
	Indicates in which round of the game we are. 
	Since this will be changing each round, it can be used by the agent as a trigger to start the plan to determine
	its next move.

Furthermore, the agent may also observe the following:

- next 
	This means that it is this agent's turn.
  
- winner(x) or winner(o)
	If the game is over and did not end in a draw. Indicates which player won.
	
- end 
	If the game is finished.
	
- After observing 'end' the agent must perform the action 'confirmEnd'.

To mark a cell, use the 'play' action. For example if you perform the action play(1,1). 
Then the cell with coordinates (1,1) will be marked with your symbol. 
This action will fail if that cell is already marked.

*/



/* Initial beliefs and rules */


// First, define a 'cell' to be a pair of numbers, between 0 and 2. i.e. (0,0) , (0,1), (0,2) ... (2,2).

isCoordinate(0).
isCoordinate(1).
isCoordinate(2).

isCell(X,Y) :- isCoordinate(X) & isCoordinate(Y).

/* A cell is 'available' if it does not contain a mark.*/
available(X,Y) :- isCell(X,Y) & not mark(X,Y,_).


started.


/* Plans */

/* When the agent is started, perform the 'sayHello' action. */
+started <- sayHello.

/* Round Planning */

+round(Z) : next <- .findall(available(X,Y),available(X,Y),AvailableCells);
					L = .length(AvailableCells);

					/* To adhere to the strategy effectively, it's crucial to identify 
					the symbol assigned to our agent in order to determine availability for
					potential moves and to locate the opposing symbol.
					
					AC -> Agent Symbol
					OC -> Oponent Symbol
					
					*/

					if (symbol(x)){AC=x; OC=o} else {AC=o; OC=x};


					/* Depending on the round, we will employ different strategies.
					
					We utilize the length of available cells (L) to determine the 
					current stage of the game. */

					if(L == 9){!firstmove};	
					if (L == 8){!secondmove};
					if (L < 8){!winningopportunity(AvailableCells, L, AC, OC)}.		


/* First Moves Strategy

In the first stage of the game, we will prioritize the center cell as it provides
the most opportunities for future moves.
*/

+!firstmove <- play(1,1); .print("Center is ours!").

+!secondmove <- if(available(1,1)) {play(1,1); .print("Center is ours!")}
				else{play(0,0); .print("I'll take the corner!")}.

/* Winning Opportunity Function

This function is called when the agent may have an opportunity to win the game.
It will prioritize the winning move over any other potential move. If no winning 
opportunity is found, the function will call the blockingopportunity function.

*/

+!winningopportunity(AvailableCells, L, AC, OC) <- 

							/* Horizontal and Vertical */			
							if ((mark(A,B, AC) & mark(A,C,AC) & available(A,X) & B\==C) | (mark(B,X,AC) & mark(C,X,AC) & available(A,X) & B\==C) ) {
								play(A, X);
								.print("I found a way to win!")}
							
							/* Diagonal */	
							else {
								if ((mark(A,A, AC) & mark(B,B,AC) & available(C,C) & A\==B)) {
								play(C,C);
								.print("I found a way to win!")}
								
								else{
									if (mark(A, C, AC) & mark(B, B, AC) & available(C, A) & (A==0 & C==2 | A==2 & C==0)){
										play(C, A);
										.print("I found a way to win!")
									}
									else{!blockingopportunity(AvailableCells, L, OC)}
								}}.


/* Blocking Opportunity Function

This function is called when the agent may have an opportunity to block the opponent from winning the game.
It will prioritize the blocking move over any other potential move. If no blocking	
opportunity is found, the function will call the playrandom function.

*/

+!blockingopportunity(AvailableCells, L, OC) <- if ((mark(A,B,OC) & mark(A,C,OC) & available(A,X) & B\==C) | (mark(B,X,OC) & mark(C,X,OC) & available(A,X) & B\==C) ) {
									play(A, X);
									.print("I blocked your opportunity!")
								}

							else {		
									if ((mark(A,A, OC) & mark(B,B,OC) & available(C,C) & A\==B)) {
										play(C,C);
										.print("I blocked your opportunity!")
									}

									else {

										if (mark(A, C, OC) & mark(B, B, OC) & available(C, A) & (A==0 & C==2 | A==2 & C==0)){
											play(C, A);
											.print("I blocked your opportunity!")}

										else{!playrandom(AvailableCells, L)}
										}

									}.

/* Random Cell Selection Function 

In certain situations, we may opt to deviate from a rigid strategy 
and instead embrace the element of chance.

*/

+!playrandom(AvailableCells, L) <- .print("Random move!");
									N = math.floor(math.random(L));
									.nth(N,AvailableCells,available(A,B));
									play(A,B).

						 
/* If I am the winner, then print "I won!"  */
+winner(S) : symbol(S) <- .print("I won!").

+end <- confirmEnd.
