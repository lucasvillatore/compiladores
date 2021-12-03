program funcao (input, output); 
var  m: integer;      
function f(n: integer; var k: integer): integer; 
var p, q: integer;    
   function g(ng: integer; var kg: integer): integer; 
   var pg, qg: integer;   
      function k(nk: integer; var kk: integer): integer; 
      var pk, qk: integer;   
      begin
      if n < 2 then
      begin   
         k := f(nk,kk);
      end
      end; 
   begin
      if n < 2 then
      begin   
      g := f(ng,kg);
      end
   end;        
begin                    
   if n < 2 then
      begin          
         f:=n; k:=0     
      end              
   else                
      begin            
         f:=f(n-1,p) + g(n-2,q);   
         k:=p+q+1      
      end;             
   write(n,k);        
end;                      
begin                          
   write(f(3,m),m); 
end. 



