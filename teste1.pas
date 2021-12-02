program cmdIf (input, output);
var i: integer;
procedure teste;
   procedure teste2;
      procedure teste3;
      begin
         teste;
      end;

      procedure teste4;
      begin
      end;
   begin
      teste3;
   end
begin
   teste2;
end

begin
   teste;  
   i := i * i + 2 + 10 + 10 div 10;  
end. 

