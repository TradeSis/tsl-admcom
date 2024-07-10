{admcab.i new}

def var vetbcod like estab.etbcod.
def var vdata as date format "99/99/9999".

update vetbcod vdata.

def temp-table tt-moeda
    field moecod as char
    field valor as dec.

def temp-table acum-moeda
    field moecod as char
    field valor as dec.
    
def temp-table pag-titulo no-undo
    field clifor like titulo.clifor
    field titnum like titulo.titnum
    field titpar like titulo.titpar
    field titvlcob like titulo.titvlcob
    field titvlpag like titulo.titvlpag
    index i1 clifor titnum titpar
    .
def temp-table pag-titmoe no-undo
    field clifor like titulo.clifor
    field titnum like titulo.titnum
    field titpar like titulo.titpar
    field moecod like titulo.moecod
    field titvlpag like titulo.titvlpag
    index i1 clifor titnum titpar
    .

form with frame fdisp down.
form with frame fdisp1 down.

run pdv-moeda(input vetbcod, input vdata).

def var varquivo as char.
varquivo = "/admcom/relat/venda-moeda." + string(time).

def var vmoenom as char.

output to value(varquivo).

put "Filial: " vetbcod    
    "    Data: " vdata
    skip.
    
put skip.

put "Fil  Numero        Pacela                  Valor "
skip.
for each titulo where titulo.titnat = no and
                            titulo.titdtpag = vdata and
                            titulo.etbcobra = vetbcod 
                     no-lock.

    if titulo.cxacod > 30 and
       titulo.cxacod  < 99 and
       titulo.modcod = "VVI" then next.

    put  titulo.etbcobra space(1)
         titulo.titnum  space(1)
         titulo.titpar  space(1)
         titulo.modcod space(1)
         titulo.titvlcob space(1)
         .     

    for each tt-moeda. delete tt-moeda. end.
    run titulo-moeda.

    for each tt-moeda .
        find moeda where moeda.moecod = tt-moeda.moecod no-lock no-error.
        if avail moeda
        then vmoenom = moeda.moenom.
        else vmoenom = "".
        put tt-moeda.moecod to 60 space(1) 
            vmoenom space(1)
             tt-moeda.valor 
             skip.
        find first acum-moeda where
                   acum-moeda.moecod = tt-moeda.moecod
                   no-error.
        if not avail acum-moeda
        then do:
            create acum-moeda.
            acum-moeda.moecod = tt-moeda.moecod.
        end.           
        acum-moeda.valor = acum-moeda.valor + tt-moeda.valor.           
    end. 
    put skip.
end.

for each acum-moeda:
    find moeda where moeda.moecod = acum-moeda.moecod no-lock no-error.
    disp acum-moeda.moecod
         moeda.moenom when avail moeda
         acum-moeda.valor(total)
         .
end.

output close.

run visurel.p(varquivo, "").


procedure titulo-moeda:
    def var pag-p2k as log.
    pag-p2k = no.
    def var vpaga as dec init 0.
    def var vt-paga like titulo.titvlcob.
    def var val-juro as dec.
    vt-paga = 0.
    if titulo.cxacod >= 30 and titulo.cxacod < 99 
        and titulo.modcod <> "VVI" 
        and titulo.moecod = "PDM"
    then do:
        vpaga = 0.
        for each   pag-titmoe where 
                    pag-titmoe.clifor = titulo.clifor and
                    pag-titmoe.titnum = titulo.titnum and
                    pag-titmoe.titpar = titulo.titpar
                    no-lock:
            pag-p2k = yes.
                
            find first moeda where moeda.moecod = pag-titmoe.moecod
                               no-lock no-error.

            find first tt-moeda where tt-moeda.moecod = pag-titmoe.moecod
                    no-error.
            if not avail tt-moeda
            then do:
                create tt-moeda.
                tt-moeda.moecod = pag-titmoe.moecod.
            end.        
            if vpaga + pag-titmoe.titvlpag <= titulo.titvlpag
            then assign
                     tt-moeda.valor = tt-moeda.valor + pag-titmoe.titvlpag
                     vpaga = vpaga + pag-titmoe.titvlpag
                        .
            else assign
                     tt-moeda.valor = tt-moeda.valor +
                                        (titulo.titvlpag - vpaga)
                     vpaga = vpaga + (titulo.titvlpag - vpaga)
                        .
        end.
    end.
    else if titulo.moecod = "PDM"
    then do:
        vpaga = 0.
        for each titpag where
                      titpag.empcod = titulo.empcod and
                      titpag.titnat = titulo.titnat and
                      titpag.modcod = titulo.modcod and
                      titpag.etbcod = titulo.etbcod and
                       titpag.clifor = titulo.clifor and
                      titpag.titnum = titulo.titnum and
                      titpag.titpar = titulo.titpar
                      no-lock:
                 
                find first moeda where  moeda.moecod = titpag.moecod
                               no-lock no-error.

                find first tt-moeda where tt-moeda.moecod = titpag.moecod
                    no-error.
            if not avail tt-moeda
            then do:
                create tt-moeda.
                tt-moeda.moecod = titpag.moecod.
            end.        
            tt-moeda.valor = tt-moeda.valor + titpag.titvlpag.
        end.
    end.
    else do:
        find first moeda where  moeda.moecod = titulo.moecod
                               no-lock no-error.

        find first tt-moeda where tt-moeda.moecod = titulo.moecod
                    no-error.
        if not avail tt-moeda
        then do:
                create tt-moeda.
                tt-moeda.moecod = titulo.moecod.
        end.        
        tt-moeda.valor = tt-moeda.valor + titulo.titvlpag.
    end.
    
end procedure.

procedure pdv-moeda:
    def input parameter p-etbcod like estab.etbcod.
    def input parameter p-data as date.
    def var vtroco as dec.
    for each pag-titulo. delete pag-titulo. end.
    for each pag-titmoe. delete pag-titmoe. end.
    for each pdvmov where
                 pdvmov.etbcod  = p-etbcod and
                 pdvmov.datamov = p-data no-lock:
        find first pdvmoeda of pdvmov
            where pdvmoeda.moecod = "CRE"
            no-lock no-error.
        if avail pdvmoeda then next.    
        for each pdvdoc of pdvmov where
            pdvdoc.clifor <> 1 and
            pdvdoc.titpar >= 0 
            no-lock:
            create pag-titulo.
            assign
                pag-titulo.clifor = pdvdoc.clifor
                pag-titulo.titnum = pdvdoc.contnum
                pag-titulo.titpar  = pdvdoc.titpar
                pag-titulo.titvlcob = pdvdoc.titvlcob
                pag-titulo.titvlpag = pdvdoc.valor
                .
             vtroco = 0.
             for each pdvmoeda of pdvmov no-lock:
                create pag-titmoe.
                assign
                    pag-titmoe.clifor = pdvdoc.clifor
                    pag-titmoe.titnum = pdvdoc.contnum
                    pag-titmoe.titpar  = pdvdoc.titpar
                    vtroco = pdvmov.valortroco *
                             (pdvmoe.valor / 
                             (pdvmov.valortot + pdvmov.valortroco))
                    pag-titmoe.moecod = pdvmoe.moecod
                    pag-titmoe.titvlpag = (pdvmoe.valor - vtroco) *
                            (pdvdoc.valor  / pdvmov.valortot)
                    .
                /*if pdvmoe.moecod = "REA"
                then pag-titmoe.titvlpag = pdvmoe.valor - pdvmov.valortroco.
                else pag-titmoe.titvlpag = pdvmoe.valor.    
                */
            end.
        end.
    end.
end procedure.


