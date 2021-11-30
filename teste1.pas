program cmdIf (input, output);
var i, j: integer;
begin
   i:=0;
   j := i + 5;
   j := j * i;
   while (i < j) do
   begin
      if (i = 1) then
        i := 1;   
   end;
end.