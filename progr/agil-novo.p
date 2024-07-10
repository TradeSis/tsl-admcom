def var i as int init 1.                           
def var vfilial as char.                           
                                                   
do i = 301 to 307:

    if i = 145 then i = i + 1.
                                                   
    vfilial = "".                                                         
                                                   
    if i < 10 then vfilial = "filial0" + string(i).
    else vfilial = "filial" + string(i). 

    message "FILIAL " i.                                          
                                                                          
    connect nfe -H value(vfilial) -S sdrebnfe -N tcp -ld nfeloja no-error.
                                                                          
    run agil-novo-2.p(input i).                                          
                                                                          
    if connected ("nfeloja")                                              
    then disconnect nfeloja.  

    pause 0.                                            
end.                                                                      
                                                                          
message "Feitooo!".                                                         