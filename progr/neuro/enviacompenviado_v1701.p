/** #7 **/ /*  03.2019 helio.neto - inclusao de registro no campo neuclien.CompDtUltAlter para marcar que comportamnto mudou */

def input param p-etbcod as int.

def new global shared var setbcod as int.

{acha.i}            /* 03.04.2018 helio */
{neuro/achahash.i}  /* 03.04.2018 helio */
{neuro/varcomportamento.i} /* 03.04.2018 helio */


def var vvlrlimite as dec.
def var vvctolimite as date.
def var vsit_credito as char.
def var vtime as int.


setbcod = p-etbcod .
def var vt as int.
def var vl as int.

/** Vai calcular SALDO Limite para quem JA foi Enviado neuclien **/
for each neuclien where     neuclien.compsitenvio = "ENVIADO"
                        and neuclien.etbcod = setbcod 
          no-lock.
    if neuclien.clicod = ? then next.
    vt = vt + 1.
        
    run neuro/comportamento.p (neuclien.clicod,
                               ?,
                               output var-propriedades).

    var-salaberto = dec(achahash("LIMITETOM",var-propriedades)).
     
    /* #7 Limite venceu, e ainda nao marcoi alteracao , vai mandar*/
    if neuclien.vctolimite < today and 
       (neuclien.CompDtUltAlter = ? or
        neuclien.CompDtUltAlter < neuclien.vctolimite)
    then.
    else
        if (neuclien.vlrlimite - var-salaberto) = neuclien.compsldlimite
        then next.
    
    message today string(time,"HH:MM:SS") "Loja" p-etbcod 
    "      Cliente" neuclien.clicod "Saldo Alterado".
    vl = vl + 1.    
    
    run p.
    
end.

message today string(time,"HH:MM:SS") "Loja" p-etbcod 
"      Leu" vt "Clientes, e Marcou" vl "Clientes para ENVIAR.".

procedure p.
    do on error undo:
         find current neuclien exclusive.
         neuclien.compsitenvio = "ENVIAR".                                
         neuclien.compsldlimite = neuclien.vlrlimite - var-salaberto.                                

        /* #7 15.03.19 */
            neuclien.CompDtUltAlter = today.
        /* #7 15.03.19 */
         
         
    end.                                
end procedure.

