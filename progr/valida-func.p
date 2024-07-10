{admcab.i }

if sfuncod <> 0
then do: 
message "usuario nao autorizado".
 return.
end.

 disp sfuncod.
 message "usuario ok".
 