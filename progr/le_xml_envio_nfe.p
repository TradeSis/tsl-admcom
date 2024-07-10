def input parameter parq-onde as char.
def input parameter parq-oque as char.
def output parameter p-resultado as char.

def temp-table tt-plani like plani.

def var vlinha as char format "x(300)" extent 300.

FUNCTION pega returns character
    (input par-oque as char,
     input par-onde as char).
              
    def var vx     as int.
    def var vx-ini as int.
    def var vx-fim as int.
    def var vret as char.  
    def var vpar-oque-aux as char.
    def var vpar-oque-aux2 as char.
    def var vtag-ini    as char.
    def var vtag-fim    as char.
    
    vret = ?.  
    
    assign vpar-oque-aux = "<" + par-oque + ">"
           vpar-oque-aux2 = "</" + par-oque.

    do vx = 1 to length(par-onde). 

        if substring(par-onde,vx,1) = "<"
        then assign vtag-ini = "<".
        else assign vtag-ini = vtag-ini + substring(par-onde,vx,1).
        
        if substring(par-onde,vx,1) = ">"
            and vtag-ini = vpar-oque-aux
        then vx-ini = vx + 1.            
        
        if substring(par-onde,vx,2) = "</"
        then assign vtag-fim = "<"
                    vx-fim = vx - 1.
        else assign vtag-fim = vtag-fim + substring(par-onde,vx,1).
        
        if ((num-entries(vpar-oque-aux2," ") > 0
            and entry(1,vpar-oque-aux2," ") = vtag-fim)
            or vpar-oque-aux2 = vtag-fim)
            and vx-ini > 0
        then leave.

    end.
    
    
    message "vx-fim " vx-fim " vx-ini " vx-ini " o que " par-oque
            " vtag-ini " vtag-ini " vtag-fim " vtag-fim view-as alert-box.
    
    vret = substring(par-onde,vx-ini,(vx-fim - vx-ini + 1)).
    
    return vret. 
END FUNCTION.
def var vi as int. 

def var vcha-arquivo-aux as char.

def var parq-oque-aux as char.
def var vcont         as int.

assign vcha-arquivo-aux = "/usr/dlc/bin/quoter " + parq-onde + " > "
                        + parq-onde + ".2".
                        
unix silent value(vcha-arquivo-aux).
                        
input from value(parq-onde + ".2").
repeat:

    import  vlinha /*vlinha[2] vlinha[3] vlinha[4] vlinha[5] vlinha[6]*/.

    do vi = 1 to 100:
        
        if vlinha[vi] = "" then leave.
        
        do vcont = 1 to num-entries(parq-oque,"."):
        
            assign parq-oque-aux = entry(vcont,parq-oque,".").

            assign p-resultado = vlinha[vi].

            if pega(parq-oque-aux,p-resultado) <> ?
            then  p-resultado =  pega(parq-oque-aux,p-resultado).
            
        end.

        /*
        if p-resultado <> ?
        then leave.
        */
    end.
end.
input close. 