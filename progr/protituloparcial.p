def input parameter recid-titulo as recid.
def output parameter p-retorno as char.

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

def var par-ori as int.
def var val-ori as dec.
def var val-pag as dec.
def var val-jur as dec.
def var jur-dis as dec.
def var val-abe as dec.

assign
    par-ori = 0
    val-ori = 0
    val-pag = 0
    val-jur = 0
    jur-dis = 0
    val-abe = 0
    .
    
def buffer btitulo for titulo.
def buffer ctitulo for titulo.

find titulo where recid(titulo) = recid-titulo no-lock no-error.
if not avail titulo then return.

if titulo.titparger = 0
then do:
    assign
        par-ori = titulo.titpar
        val-ori = titulo.titvlcob
        val-pag = titulo.titvlpag - titulo.titjuro
        val-jur = titulo.titjuro
        val-abe = val-ori - val-pag
        .
    if acha("DISPENSA-JURO",titulo.titobs[1]) <> ?
                then jur-dis = jur-dis +
                        dec(acha("DISPENSA-JURO",titulo.titobs[1])).
    find first ctitulo where
               ctitulo.empcod = titulo.empcod and
               ctitulo.titnat = titulo.titnat and
               ctitulo.modcod = titulo.modcod and
               ctitulo.etbcod = titulo.etbcod and
               ctitulo.clifor = titulo.clifor and
               ctitulo.titnum = titulo.titnum and
               ctitulo.titpar > titulo.titpar and
               ctitulo.titparger = titulo.titpar and
               ctitulo.titnumger = titulo.titnum
               no-lock no-error.
    if avail ctitulo
    then val-abe = ctitulo.titvlcob.           
    else val-abe = 0.           
end.
else do:
    assign
        par-ori = titulo.titparger
        val-pag = titulo.titvlpag - titulo.titjuro
        val-jur = titulo.titjuro.
    if acha("DISPENSA-JURO",titulo.titobs[1]) <> ?
                then jur-dis = jur-dis +
                        dec(acha("DISPENSA-JURO",titulo.titobs[1])).
    repeat:
        find first btitulo where
               btitulo.empcod = titulo.empcod and
               btitulo.titnat = titulo.titnat and
               btitulo.modcod = titulo.modcod and
               btitulo.etbcod = titulo.etbcod and
               btitulo.clifor = titulo.clifor and
               btitulo.titnum = titulo.titnum and
               btitulo.titpar = par-ori
               no-lock no-error.
        if avail btitulo and btitulo.titparger = 0
        then do:
            assign
                val-ori = btitulo.titvlcob
                val-pag = val-pag + (btitulo.titvlpag - btitulo.titjuro)
                val-jur = val-jur + btitulo.titjuro
                val-abe = val-ori - val-pag
                .
            if acha("DISPENSA-JURO",btitulo.titobs[1]) <> ?
            then jur-dis = jur-dis +
                        dec(acha("DISPENSA-JURO",btitulo.titobs[1])).

            find first ctitulo where
               ctitulo.empcod = titulo.empcod and
               ctitulo.titnat = titulo.titnat and
               ctitulo.modcod = titulo.modcod and
               ctitulo.etbcod = titulo.etbcod and
               ctitulo.clifor = titulo.clifor and
               ctitulo.titnum = titulo.titnum and
               ctitulo.titpar > titulo.titpar and
               ctitulo.titparger = titulo.titpar and
               ctitulo.titnumger = titulo.titnum
               no-lock no-error.
            if avail ctitulo
            then val-abe = ctitulo.titvlcob.           
            else val-abe = 0. 
            leave.
        end.
        else if avail btitulo
            then do:
                assign
                    par-ori = btitulo.titparger
                    val-pag = val-pag + (btitulo.titvlpag - btitulo.titjuro)
                    val-jur = val-jur + btitulo.titjuro
                    . 
                if acha("DISPENSA-JURO",btitulo.titobs[1]) <> ?
                then jur-dis = jur-dis +
                        dec(acha("DISPENSA-JURO",btitulo.titobs[1])).
            end.      
            else leave.           
    end.
end.

p-retorno = "PARCELA-ORIGEM=" + string(par-ori) + "|" +
            "VALOR-ORIGEM=" + string(val-ori) + "|" +
            "VALOR-PAGO=" + string(val-PAG) + "|" +
            "VALOR-JURO=" + string(val-jur) + "|" +
            "JURO-DISPENSADO=" + string(jur-dis) + "|" +
            "VALOR-ABERTO=" + string(val-abe) + "|" 
            .

