 /* helio 14082023 - Melhoria Input de valores móo Casadinha - Processo 522795 */
def input param p-rec as recid.

def var varq as char format "x(76)".
def var vcp  as char init ";".

varq = "/admcom/tmp/valor.csv".
                               
    pause 0.
    update skip(2) varq skip(2)
        with
        centered 
        overlay
        color messages
        no-labels
        row 8
        title "arquivo de input".

if search(varq) = ?
then do:
    message "arquivo nao encontrado...".
    pause.
    undo.
end.
def buffer bctpromoc for ctpromoc.    
def buffer dctpromoc for ctpromoc.

find bctpromoc where recid(bctpromoc) = p-rec .

def var vcodigo as char.
def var vtipo as char .
def var vvalor as char.
def var vprocod as int.
def var vpreco as dec.
input from value(varq).
repeat:

    import delimiter ";" vcodigo vtipo vvalor.
    
    vprocod = int(vcodigo) no-error.
    if vprocod = ? then next.
    find produ where produ.procod = vprocod no-lock no-error.
    if not avail produ then next.
    if vtipo = "VALOR" or vtipo = "PERCENTUAL"
    then.
    else next.
    vpreco = dec(vvalor) no-error.
    if vpreco = ? or vpreco = 0 then next.
        
        
        find last dctpromoc where
                    dctpromoc.sequencia = bctpromoc.sequencia 
                    no-lock no-error.

        create ctpromoc.
        assign
            ctpromoc.promocod = bctpromoc.promocod
            ctpromoc.sequencia = bctpromoc.sequencia
            ctpromoc.linha     = dctpromoc.linha + 1
            ctpromoc.fincod = ?.
        ctpromoc.produtovendacasada = vprocod.
        ctpromoc.valorprodutovendacasada = vpreco.
        ctpromoc.tipo = "PRODUTO=|" + vtipo + "=|".
end.
input close. 
