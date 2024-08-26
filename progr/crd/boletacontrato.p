/* helio 24082024 - proj boletagem */
/* segundo programa do processo */
/* Gera boletos para todas as parcelas de um contrato */
/* Criar boletagparcela */
def input param pcontnum as int.

def var par-recid-boleto as rec.
def var mensagem_erro as char.
def var vparcelas as int.

find contrassin where contrassin.contnum = pcontnum no-lock.
find contrato of contrassin no-lock.
vparcelas = 0.
message "BOLETA CONTRATO" contrato.contnum.
for each titulo where titulo.contnum = contrato.contnum no-lock.
    if titulo.titpar = 0 then next.
    if titulo.bolcod <> ? then next. /* ja boletado */
    vparcelas = vparcelas + 1.
end.
message "BOLETA CONTRATO" contrato.contnum  "PARCELAS" vparcelas. 
IF vparcelas = 0
THEN RETURN.
for each titulo where titulo.contnum = contrato.contnum no-lock.
    
    if titulo.titpar = 0 then next.

    if titulo.bolcod <> ? then next. /* ja boletado */

    RUN api/boletoemitir.p (041, /* Banrisul */
                          contrato.clicod,
                          string(contrato.contnum) + "-" + string(titulo.titpar),  
                          titulo.titdtven,
                          titulo.titvlcob,
                          output par-recid-boleto,
                          output mensagem_erro).

    message "BOLETA CONTRATO" contrato.contnum titulo.titpar avail boletagbol.

    find boletagbol where recid(boletagbol) =  par-recid-boleto no-lock no-error.
    if avail boletagbol
    then do:
        message "BOLETA CONTRATO" contrato.contnum titulo.titpar boletagbol.bolcod boletagbol.dtemissao.
    
        if boletagbol.dtemissao <> ?
        then do on error undo:
            create boletagparcela.
            boletagparcela.bolcod    = boletagbol.bolcod.
            boletagparcela.contnum   = contrato.contnum.
            boletagparcela.titpar    = titulo.titpar.
            boletagparcela.VlCobrado = titulo.titvlcob.

            run ptitulo.
        end.
    end.



end.

if vparcelas = 0
then run pboletou.


procedure ptitulo.
do on error undo:
    find current titulo exclusive no-wait no-error.
    if avail titulo
    then do:
            titulo.bolcod = boletagbol.bolcod. /* titulo boletado */
            vparcelas = vparcelas - 1.
    end.
end.    
end procedure.

procedure pboletou.
do on error undo:
    find current contrassin exclusive no-wait no-error.
    if avail contrassin
    then do:
        contrassin.dtboletagem = today. 
    end.
end.
end procedure.
