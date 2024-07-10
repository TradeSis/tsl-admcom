def input parameter parq-onde as char.
def input parameter parq-oque as char.
def output parameter p-resultado as char.

def var vlinha as char format "x(300)" extent 300.

FUNCTION pega returns character
    (input par-oque as char,
     input par-onde as char).
         
    def var vx as int.
    def var vret as char.  
    
    vret = ?.  
    
    do vx = 1 to num-entries(par-onde,"<"). 
        if entry(1,entry(vx,par-onde,"<"),">") = par-oque 
        then do: 
            vret = entry(2,entry(vx,par-onde,"<"),">"). 
            leave. 
        end. 
    end.
    return vret. 
END FUNCTION.
def var vi as int. 

message parq-onde. pause.
input from value(parq-onde).
repeat:

    import  vlinha /*vlinha[2] vlinha[3] vlinha[4] vlinha[5] vlinha[6]*/.

    do vi = 1 to 100:
        if vlinha[vi] = "" then leave.
        message vlinha[vi]. pause.
        p-resultado =  pega(parq-oque,vlinha[vi]) .
    end.
end.
input close. 