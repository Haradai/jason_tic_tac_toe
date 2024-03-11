
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

/* Whenever it is my turn, play a random move. Specifically:
	- find all available cells and put them in a list called AvailableCells.
	- Get the length L of that list.
	- pick a random integer N between 0 and L.
	- pick the N-th cell of the list, and store its coordinates in the variables A and B.
	- mark that cell by performing the action play(A,B).
*/
+round(Z) : next <- .findall(available(X,Y),available(X,Y),AvailableCells); /* Find Available Cells */
					L = .length(AvailableCells);

					if (symbol(x)){AC=x; OC=o}
					else {AC=o; OC=x};

					/* Create lists to alocate the cells corresponding to each agent. */					

					.findall(mark(X,Y,OC),mark(X,Y, OC), OponentCells);  /* Find Oponent Cells*/
					.findall(mark(X,Y,AC),mark(X,Y,AC), AgentCells);  /* Find Our Cells*/

					/* We want to occupy the center of the greed, so we try it. */

					if(L == 9){
						play(1,1);
						.print("Center is ours!")
					};
							
					if (L == 8){

						if(available(1,1)) {
							play(1,1);
							.print("Center is ours!")
						}
						else{
							play(0,0);
							}
						};

					if (L<8){
		
					/* Prioritize blocking the opponent from winning and look for winning oportunities. */	

					/* Horizontal and Vertical */			
					if ((mark(A,B, AC) & mark(A,C,AC) & available(A,X) & B\==C) | (mark(B,X,AC) & mark(C,X,AC) & available(A,X) & B\==C) ) {
						
						.print(AC);
						.print(OponentCells);
						.print(AgentCells);
						.print(A, X);
						play(A, X)
					}

					/* Horizontal and Vertical */	

					else {
						
						if ((mark(A,A, AC) & mark(B,B,AC) & available(C,C) & A\==B)) {
							.print(C,C);
							play(C,C)

						}
						
						else {

							if (mark(A, C, AC) & mark(B, B, AC) & available(C, A) & A\==B){

								.print(C, A);
								play(C, A)
							}
							 
							else {

								.print("Playing random!");
								L = .length(AvailableCells);
								N = math.floor(math.random(L));
								.nth(N,AvailableCells,available(A,B));
								play(A,B)

							}
			
						}

					}}.

						 
/* If I am the winner, then print "I won!"  */
+winner(S) : symbol(S) <- .print("I won!").

+end <- confirmEnd.
