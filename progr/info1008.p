def output parameter varquivo as char.
{/admcom/progr/cntgendf.i}

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

find first tbcntgen where tbcntgen.etbcod = 1008 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para INFORMATIVO 1008 nao cadastrado ou desativado".
    pause 0.
    return.
end.

def var qtd-enviar as int.

def new shared var var-mail as char extent 10 .
if ENTRY(1,tbcntgen.campo3[3],";") = "CADASTRO" 
THEN assign
        var-mail[2] = acha("email1",tbcntgen.campo3[1]) 
        var-mail[3] = acha("email2",tbcntgen.campo3[1])
        var-mail[4] = acha("email3",tbcntgen.campo3[1])
        var-mail[5] = acha("email4",tbcntgen.campo3[1])
        var-mail[6] = acha("email5",tbcntgen.campo3[1])
        var-mail[7] = acha("email6",tbcntgen.campo3[1])
        var-mail[8] = acha("email7",tbcntgen.campo3[1])
        var-mail[9] = acha("email8",tbcntgen.campo3[1])
        var-mail[10] = acha("email9",tbcntgen.campo3[1])
        .

if  ENTRY(2,tbcntgen.campo3[3],";") = ""
then assign
        var-mail[1] = var-mail[2]
        var-mail[2] = var-mail[3]
        var-mail[3] = var-mail[4]
        var-mail[4] = var-mail[5]
        var-mail[5] = var-mail[6]
        var-mail[6] = var-mail[7]
        var-mail[7] = var-mail[8]
        var-mail[8] = var-mail[9]
        var-mail[9] = var-mail[10]
        var-mail[10] = "".
        
if entry(3,tbcntgen.campo3[3],";") = ""
then qtd-enviar = ?.
else qtd-enviar = int(entry(3,tbcntgen.campo3[3],";")).

def var valcompra as dec.
valcompra = tbcntgen.valor.
def var venvmail as log.
varquivo = "/admcom/work/informativo1008.txt".

def var qtd-enviados as int init 0.
for each estab no-lock where 
         estab.etbcod > 0 and
         estab.etbnom begins "DREBES-FIL" .
    for each plani where plani.etbcod = estab.etbcod and
                     plani.movtdc = 5 and
                     plani.pladat = today - 1
                     no-lock:

        if valcompra > 0 and
           valcompra > plani.platot
        then next.
            
        run /admcom/progr/email-venda.p(input recid(plani),
                                    input "",
                                    input-output qtd-enviados).
        pause 1 no-message.

        if qtd-enviados >= qtd-enviar
        then leave.
    end.
    if qtd-enviados >= qtd-enviar
    then leave.
end.
return.


