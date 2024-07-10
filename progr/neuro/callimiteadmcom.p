/**                 
                run limiteadmcom.p (recid(neuclien.cpfcnpj),
                                    vtipoconsulta,
                                    vtime,
                                    setbcod,
                                    consultacliente.numero_pdvm
                                    output vvlrLimite,
                                    ouput vvctoLimite,
                                    ).

**/
/* #1 01.06.2018 helio agenda lebes */
/* #2 03.07.2018 #8 Helio - Revisao do Fluxo V2 */

def input parameter p-recid-neuclien as recid.
def input parameter p-tipoconsulta as char.
def input parameter p-time as int.
def input parameter p-etbcod as int.
def input parameter p-cxacod as int.

def output parameter p-vlrlimite as dec.
def output parameter p-vctolimite as date.
def output parameter p-status as char.

def new global shared var setbcod       as int.

{acha.i}            /* 03.04.2018 helio */
{neuro/achahash.i}  /* 03.04.2018 helio */
{neuro/varcomportamento.i} /* 03.04.2018 helio */

def var var-qtdpagas as int.
def var var-percpagas15 as dec.
def var var-diasvcto as int.


setbcod = p-etbcod.

/*** CREDSCORE - 17/05/2016 ***/
def var vpardias as dec.
def var vdisponivel as dec.

def NEW shared temp-table tt-dados
    field parametro as char
    field valor     as dec
    field valoralt  as dec
    field percent   as dec
    field vcalclim  as dec
    field operacao  as char format "x(1)" column-label ""
    field numseq    as int
    index dado1 numseq.
/*** ***/


p-status = "P".
find neuclien where recid(neuclien) = p-recid-neuclien no-lock no-error.
if not avail neuclien
then do:
    p-status = "E".
    return.
end.     

    find clien where clien.clicod = neuclien.clicod no-lock no-error.
    if not avail clien
    then do:
        p-status = "E".
        return.
    end.         
    

    run neuro/gravaneuclilog.p 
        (neuclien.cpfcnpj, 
         p-tipoconsulta, 
         p-time, 
         p-etbcod, 
         p-cxacod, 
         neuclien.sit_credito, 
         "CredScore"). 

/* helio 15032022 retirado depois de ver com o roberto        
    run calccredscore.p (input string(setbcod),
                         input recid(clien),
                         output p-vlrLimite,
                         output vpardias,
                         output vdisponivel).
*/
    
    p-vlrlimite = neuclien.vlrlimite. /* helio 15032022 */
    p-vctolimite = neuclien.vctolimite.

    if (neuclien.vctolimite = ? or
       neuclien.vctolimite < today or
        neuclien.vlrlimite = 0)
       and
       p-vlrlimite > 0     /* #1 Regra aplicada em 01.06.2018 , agenda helio se calcular limite zero , e estiver vencido, nao da novo limite */
    then do:    

        run neuro/comportamento.p (neuclien.clicod,
                                   ?,
                                   output var-propriedades).

        var-salaberto = dec(achahash("LIMITETOM",var-propriedades)).

 
        p-status = "A".
        
        var-qtdpagas    = int(pega_prop("QTDPAGAS")) .
        var-percpagas15 = dec(pega_prop("PERCPAGAS15")).
        
        if var-qtdpagas = ? then var-qtdpagas = 0.
        if var-percpagas15 = ? then var-percpagas15 = 0.
        
        if var-qtdpagas <= 100        
        then do:
            if var-percpagas15 < 60
            then var-diasvcto = 60.
            else if var-percpagas15 < 80
                 then var-diasvcto = 105.
                 else var-diasvcto = 120.
        end.
        else 
        if var-qtdpagas <= 499        
        then do:
            if var-percpagas15 < 60
            then var-diasvcto = 70.
            else if var-percpagas15 < 80
                 then var-diasvcto = 135.
                 else var-diasvcto = 150.
        end.
        else 
        if var-qtdpagas <= 999        
        then do:
            if var-percpagas15 < 60
            then var-diasvcto = 80.
            else if var-percpagas15 < 80
                 then var-diasvcto = 165.
                 else var-diasvcto = 180.
        end.
        else 
        if var-qtdpagas <= 1999        
        then do:
            if var-percpagas15 < 60
            then var-diasvcto = 85.
            else if var-percpagas15 < 80
                 then var-diasvcto = 195.
                 else var-diasvcto = 210.
        end.
        else do:
            if var-percpagas15 < 60
            then var-diasvcto = 90.
            else if var-percpagas15 < 80
                 then var-diasvcto = 225.
                 else var-diasvcto = 240.
        end. 
        
        /* #2 */
        if p-tipoconsulta = "ADMC" 
        then do:
            p-vctolimite = ?.
        end.
        else do:    
            if p-tipoconsulta = "ADMA"
            then p-vctolimite = today - 1.
            else p-vctolimite = today + var-diasvcto.
        end.    
                  
    end.
            
    /*
    run neuro/gravaneuclilog.p 
        (neuclien.cpfcnpj, 
         p-tipoconsulta, 
         p-time, 
         p-etbcod, 
         p-cxacod, 
         neuclien.sit_credito, 
         if p-vlrLimite <> neuclien.vlrlimite
         then "Limite de " + string(round(neuclien.vlrlimite,2)) + " p/ " + string(round(p-VlrLimite,2))
         else "Limite Mantido " + string(round(p-vlrLimite,2))). 
            
    run neuro/gravaneuclilog.p 
        (neuclien.cpfcnpj, 
         p-tipoconsulta, 
         p-time, 
         p-etbcod, 
         p-cxacod, 
         neuclien.sit_credito, 
         if p-vctoLimite <> neuclien.vctolimite
         then "Venc de " + 
                (if neuclien.vctolimite = ?
                 then "-"
                 else string(neuclien.vctolimite))
               + " p/ " + 
                (if p-vctolimite = ?
                then "-"
                else string(p-vctoLimite))
         else "Venc Mantido " + 
                if p-vctolimite = ?
                then "-"
                else string(p-vctoLimite)). 


    if p-vlrLimite   <> neuclien.vlrlimite or
       p-vctolimite <> neuclien.vctolimite 
    then do:
        if p-vctolimite <> ?
        then run neuro/gravaneuclihist.p 
                        (p-recid-neuclien,
                         p-tipoconsulta,
                         p-etbcod,
                         clien.clicod,
                         p-vctolimite,
                         p-vlrLimite,
                         0,
                         p-status).
    end.                             
    **/
    
    /* #2 */
    if p-vctolimite = ?
    then p-vctolimite = today - 1.
     
 