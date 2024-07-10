def input parameter p-etbcod as int.

{acha.i}            /* 03.04.2018 helio */
{neuro/achahash.i}  /* 03.04.2018 helio */
{neuro/varcomportamento.i} /* 03.04.2018 helio */

def var vvlrlimite as dec.
def var vvctolimite as date.
def var vsit_credito as char.
def var vtime as int.

def new global shared var setbcod as int.

setbcod = p-etbcod .

/** Vai calcular Limite para quem é novo no neuclien **/
def var vt as int.
def var vl as int.
def var vnovovcto as log.
def var var-qtdpagas as int.
def var var-percpagas15 as dec.
def var var-diasvcto as int.

vt = 0.
vl = 0.
for each neuclien where     neuclien.compsitenvio = ""
                        and neuclien.etbcod = setbcod 
                        and neuclien.clicod <> ?
          no-lock.
    vt = vt + 1.
    
    vnovovcto = no.

    if neuclien.vctolimite = ? 
    then do:
        vnovovcto = yes.
        message today string(time,"HH:MM:SS") "Loja" p-etbcod 
            "      Cliente" neuclien.clicod " Calculando Limite".
        vtime = time.
        vl = vl + 1.
        run neuro/callimiteadmcom.p (recid(neuclien), 
                                     "COMP", 
                                     vtime, 
                                     setbcod,  
                                     0, 
                                     output vvlrLimite, 
                                     output vvctoLimite, 
                                     output vsit_credito).

        message today string(time,"HH:MM:SS") "Loja" p-etbcod 
        "      Cliente" neuclien.clicod 
        " Calculado Limite de" vvlrlimite " em" time - vtime.

    end.
    
    
    run neuro/comportamento.p (neuclien.clicod,
                               ?,
                               output var-propriedades).

    var-salaberto = dec(achahash("LIMITETOM",var-propriedades)).

     run p.
   
end.

message today string(time,"HH:MM:SS") "Loja" p-etbcod 
"      Atualizou" vt "Clientes, Calculou Limite de" vl "Clientes.".

procedure p.
    do on error undo:
        find current neuclien exclusive.
        neuclien.compsitenvio = "ENVIAR".                                
        neuclien.compsldlimite = neuclien.vlrlimite - var-salaberto.
        neuclien.vctolimite   = vvctolimite. 
    end.                                
end procedure.

