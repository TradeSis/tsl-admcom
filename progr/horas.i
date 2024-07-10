/*    Validada Hora   */   

if substr({&Var},1,2) > "23" 
then do: 
    bell. 
    message "Hora deve estar entre 0 e 23". 
    pause. 
    undo. 
end. 

if substr({&Var},3,2) > "59" 
then do: 
    bell. 
    message  "Minutos deve estar entre 0 e 59". 
    pause. 
    undo. 
end.

