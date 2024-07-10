/*
  #v1802 Motor de Credito Pacote 01
  
*/

/** #7 **/ /*  03.2019 helio.neto - inclusao de registro no campo neuclien.CompDtUltAlter para marcar que comportamnto mudou */
 
def input parameter p-etbcod as int.

{acha.i}            /* 03.04.2018 helio */
{neuro/achahash.i}  /* 03.04.2018 helio */
{neuro/varcomportamento.i} /* 03.04.2018 helio */

def var var-DTULTCPA as date. /* #v1802 */
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

    if neuclien.vctolimite = ? or
       neuclien.vlrlimite = 0
    then do:
        vnovovcto = yes.
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
            "   Cliente" neuclien.clicod 
            "Calculado Limite de" vvlrlimite "em" time - vtime "s".
    end.
    
    run neuro/comportamento.p (neuclien.clicod,
                               ?,
                               output var-propriedades).

    var-salaberto = dec(achahash("LIMITETOM",var-propriedades)).
    var-DTULTCPA  = date(achahash("DTULTCPA",var-propriedades)). /* #v1802 */

    /* #v1802 */
    if var-dtultcpa = ? or
       (var-dtultcpa <> ? and
       today - var-dtultcpa >= 365)
    then assign
        vvctolimite = today - 4. 
    /* #v1802 */

    run p.
end.

message today string(time,"HH:MM:SS") "Loja" p-etbcod 
    "Atualizou" vt "Clientes, Calculou Limite de" vl "Clientes".

procedure p.
    do on error undo:
        find current neuclien exclusive.
        assign
            neuclien.compsitenvio = "ENVIAR"
            neuclien.compsldlimite = neuclien.vlrlimite - var-salaberto
            neuclien.vctolimite   = vvctolimite.

        /* #7 15.03.19 */
            neuclien.CompDtUltAlter = today.
        /* #7 15.03.19 */
             
            
            
        find current neuclien no-lock.
    end.
end procedure.

