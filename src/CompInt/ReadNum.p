	
UNIT ReadNumU;
INTERFACE

	function ReadNum(str: str255; var val: extended): integer;
	
IMPLEMENTATION

	function ReadNum(str: str255; var val: extended): integer;
	var
		i, mantixLen, esp, state : integer;
		basesign, espSign : -1..1;
		c	: char;
		base : extended;
		
	begin
		{ init vars }
		i 			:= 0;
		state 		:= 0;
		mantixLen 	:= 0;
		baseSign 	:= 1;
		espSign 	:= 1;
		esp 		:= 0;
		base 		:= 0.0;
		err			:= false;
		c 			:= str[0];
		
		while ((c <> '0') and (state <> 5)) do begin
			case state of
				0:
					if c = dot then begin
						state := 2;
						i := i + 1;
					end 
					else if c in ['e', 'E'] then begin
						base := 1;
						state := 3;
						i := i + 1;
					end
					else if c in [zero..nine] then begin
						base := ord(c) - ord(zero);
						state := 1;
						i := i + 1
					end
					else if c = minus then begin
						baseSign := -1;
						i := i + 1
					end
					else if c = plus then begin
						state := 1
					end
					else begin 	{ default for state 0 }
						err := true;
						state := 5
					end;
					
				1:
					if c = dot then begin
						state := 2;
						i := i + 1
					end
					else if c in ['e', 'E'] then begin
						state := 3;
						i := i + 1
					end
					else if c in [zero..nine] then begin
						base := base*10 + ord(c)-ord(zero);
						state := 1;
						i := i + 1
					end
					else begin 	{ default for state 1 }
						err := true;
						state := 5
					end;
						
				2:
					if c in ['e', 'E'] then begin
						state := 3;
						i := i+1;
					end
					else if c in [zero..nine] then begin
						mantixLen := mantixLen + 1;
						base := base + (ord(c)-ord(zero)) /
										10**mantixLen;
						i := i+1
					end
					else begin 	{ default for state 3 }
						err := true;
						state := 5
					end;
				3:
					if c = blank then begin
						i := i+1
					end
					else if c = plus then begin
						state := 4;
						i := i+1
					end
					else if c = minus then begin
						espSign := -1;
						i := i+1
					end
					else if c in [zero..nine] then begin
						state := 4;
						esp := ord(c) - ord(zero);
						i := i+1
					end
					else begin 	{ default for state 3 }
						err := true;
						state := 5
					end;
				4:
					if c in [zero..nine] then begin
						esp := esp * 10 + ord(c)-ord(zero);
						i := i+1
					end
					else begin	{ default for state 4 }
						err := true;
						state := 5
					end;
						
				5:
					{ do nothing }
					
			end;	{ of case }
			
			c := str[i]
		end;		{ of while }
		
		val := baseSign * base * 10**(espSign * esp)
	end; 			{ of ReadNum }

END.