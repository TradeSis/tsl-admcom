def input parameter p-dg as char.
def input parameter varquivo as char.
def input parameter ip-assunto as char.

def var varqdg as char.
{/admcom/progr/cntgendf.i}
def var i as int.
def var e-mail as char extent 6.
FUNCTION acha returns character
    (input par-oque as char,
     input par-onde as char).
         
    def var vx as int.
    def var vret as char.  
    
    vret = ?.  
    
    do vx = 1 to num-entries(par-onde,"|"). 
        if entry(1,entry(vx,par-onde,"|"),"=") = par-oque 
        then do: 
            vret = entry(2,entry(vx,par-onde,"|"),"="). 
            leave. 
        end. 
    end.
    return vret. 
END FUNCTION.
 
find first tbcntgen where
           tbcntgen.tipcon = 1 and
           tbcntgen.etbcod = int(p-dg) and
           tbcntgen.numini = "INFORMATIVO"
           no-lock no-error.
if avail tbcntgen
then do:
    assign
        e-mail[1] = acha("email1",tbcntgen.campo3[1]) 
        e-mail[2] = acha("email2",tbcntgen.campo3[1])
        e-mail[3] = acha("email3",tbcntgen.campo3[1])
        e-mail[4] = acha("email4",tbcntgen.campo3[1])
        e-mail[5] = acha("email5",tbcntgen.campo3[1])
        e-mail[6] = acha("email6",tbcntgen.campo3[1])
        .
    do i = 1 to 6:
        if e-mail[i] <> "" and
           e-mail[i] <> "?"
        then do:   
            
            /* antonio Novo Servico */
            varqdg = "/admcom/progr/mail.sh " 
            + "~"" + ip-assunto + "~"" + " ~"" 
            + varquivo + "~"" + " ~"" 
            + e-mail[i] + "~"" 
            + " ~"informativo@lebes.com.br~"" 
            + " ~"text/html~"". 
            unix silent value(varqdg).
            /**/
            
        end.
    end.
end.           

 
