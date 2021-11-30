program cmdIf (input, output);
var i, j: integer;
   q : boolean;
begin
   while (i < j) do
   begin
      if (i = 1) 
      then j := 1 - i + j * 4
      else q := true;
      i := 1
   end;
end.