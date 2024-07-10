{admcab.i}

def var vdti as date.
def var vdtf as date.
def var vdata as date.
def var vp as log.
def var vtitnum like titulo.titnum.

def temp-table wffatura
    field fatnum    as char format "x(15)"
    field fatdtemi  as date
    field rectitulo as recid
    field recfatura as recid
    field dtven     as date
    field dtpag     as date
    field vlcob     as dec
    field vlpag     as dec
    field saldo     as dec
    field dias      as int format ">>>"
    field contrato  as log format "C/".

def temp-table ttforma
    field seqforma like  pdvforma.seqforma
    field seqfp    like  pdvmoeda.seqfp
    field titpar   like  pdvmoeda.titpar
    field primeiraf as log

    field titnum   like titbsmoe.titnum
    field titdtven like titbsmoe.titdtven
    field modcod   like titbsmoe.modcod.
    
def temp-table tt-fpag 
    field etbcod like plani.etbcod
    field pladat  like plani.pladat
    field formap   as char
    field moecod  as char
    field moenom   as char
    field valforma as dec
    field valmoeda as dec
    field platot   as dec
    index i1 etbcod pladat formap moecod
    .
    
def var vetbcod like estab.etbcod.
update vetbcod label "Filial"
       vdti at 1   label "Periodo" 
       vdtf    no-label
       with frame f1 side-label width 80.

for each estab where (if vetbcod = 0 then true
                               else estab.etbcod = vetbcod) no-lock:
    
    do vdata = vdti to vdtf:

        for each plani where plani.etbcod = estab.etbcod and
                             plani.movtdc = 5 and
                             plani.pladat = vdata
                             no-lock:
            find tipmov of plani no-lock.

            /*if plani.crecod = 2 then next.
              */
            find cmon where cmon.etbcod = plani.etbcod
                            and cmon.cxacod = int(plani.serie)
                          no-lock no-error.
            if avail cmon
            then do.
                find first pdvdoc where pdvdoc.etbcod  = plani.etbcod
                                        and pdvdoc.cmocod  = cmon.cmocod
                                        and pdvdoc.datamov = plani.dtincl
                                        and pdvdoc.placod  = plani.placod
                                      no-lock no-error.
                if avail pdvdoc
                then do.

                    find pdvmov of pdvdoc no-lock.
                    find cmon of pdvmov no-lock.
                    find cmtipo of cmon no-lock.
                    
                    for each pdvforma of pdvmov no-lock
                                by pdvforma.seqforma desc.
                        create ttforma.
                        assign
                            ttforma.seqforma  = pdvforma.seqforma
                            ttforma.primeiraf = yes.
                          
                        vp = yes.
                        for each pdvmoeda of pdvforma no-lock.
                            if vp
                            then vp = no.
                            else do:
                                create ttforma.
                                assign
                                    ttforma.seqforma  = pdvforma.seqforma
                                    ttforma.primeiraf = vp.
                            end.
                            assign
                                ttforma.seqfp     = pdvmoeda.seqfp
                                ttforma.titpar    = pdvmoeda.titpar.

                            find titbsmoe of pdvmoeda no-lock no-error.
                            if avail titbsmoe
                            then assign
                                    ttforma.titnum = titbsmoe.titnum +
                                        (if pdvmoeda.titpar = 0
                                  then "" else ("/" + string(pdvmoeda.titpar)))
                                    ttforma.titdtven = titbsmoe.titdtven
                                    ttforma.modcod   = titbsmoe.modcod.
                        end.
                    end.     
                end.
            end.
            for each ttforma:
                run frame-a.
            end.    
            for each ttforma: delete ttforma. end.
        end.
    end.
end.

def var varquivo as char.
varquivo = "/admcom/relat/formas-pagamento-vendas.txt.".
output to value(varquivo).
put skip.
put "RELATORIO FORMAS/MOEDAS PGTO" skip(1).
disp with frame f1.
for each tt-fpag where tt-fpag.etbcod = ? and
                       tt-fpag.pladat = ?
                       :
    disp /*tt-fpag.etbcod column-label "Fil"
         tt-fpag.pladat column-label "Emissao" */
         tt-fpag.Formap column-label "Forma!Pagamento" format "x(20)"
         tt-fpag.valforma(total) column-label "Valor!Forma"
                    format ">>>,>>>,>>9.99"
         tt-fpag.moecod   column-label "Moeda"
         tt-fpag.moenom    no-label                     format "x(15)"
         tt-fpag.valmoeda(total) column-label "Valor!Moeda"
                    format ">>>,>>>,>>9.99"
         with frame ff width 120 down
         .
end.
                        
output close.
run visurel.p(varquivo,"").

def var vforma as char.
PROCEDURE frame-a.
            
    find pdvforma of pdvmov where pdvforma.seqforma = ttforma.seqforma no-lock.
    find pdvtforma of pdvforma no-lock no-error.

    vforma = pdvforma.pdvtfcod + "-" + if avail pdvtforma
                                   then pdvtforma.pdvtfnom
                                   else "".

    find first pdvmoeda of pdvforma
            where pdvmoeda.seqfp  = ttforma.seqfp and
                  pdvmoeda.titpar = ttforma.titpar
            no-lock no-error.
    if avail pdvmoeda
    then find moeda of pdvmoeda no-lock no-error.

    find first tt-fpag where
               tt-fpag.etbcod = plani.etbcod and
               tt-fpag.pladat = plani.pladat and
               tt-fpag.formap  = vforma      and
               tt-fpag.moecod = (if avail pdvmoeda 
                                 then pdvmoeda.moecod else "")
               no-error.
    if not avail tt-fpag 
    then do:
        create tt-fpag.
        assign
            tt-fpag.etbcod = plani.etbcod
            tt-fpag.pladat = plani.pladat
            tt-fpag.formap  = vforma
            tt-fpag.moecod = (if avail pdvmoeda
                              then pdvmoeda.moecod else "")  
            .
    end.
    if ttforma.primeiraf
    then  tt-fpag.valforma = tt-fpag.valforma + pdvforma.valor .
          assign
             tt-fpag.moenom   = (if avail moeda
                                then moeda.moenom else "")
             tt-fpag.valmoeda = tt-fpag.valmoeda + (if avail pdvmoeda
                                 then pdvmoeda.valor else 0)
                .

    find first tt-fpag where
               tt-fpag.etbcod = plani.etbcod and
               tt-fpag.pladat = ? and
               tt-fpag.formap  = vforma      and
               tt-fpag.moecod = (if avail pdvmoeda 
                                 then pdvmoeda.moecod else "")
               no-error.
    if not avail tt-fpag 
    then do:
        create tt-fpag.
        assign
            tt-fpag.etbcod = plani.etbcod
            tt-fpag.pladat = ?
            tt-fpag.formap  = vforma
            tt-fpag.moecod = (if avail pdvmoeda
                              then pdvmoeda.moecod else "")  
            .
    end.
    if ttforma.primeiraf
    then assign
             tt-fpag.valforma = tt-fpag.valforma + pdvforma.valor.
             assign
             tt-fpag.moenom   = (if avail moeda
                                then moeda.moenom else "")
             tt-fpag.valmoeda = tt-fpag.valmoeda + (if avail pdvmoeda
                                 then pdvmoeda.valor else 0)
                .

    find first tt-fpag where
               tt-fpag.etbcod = ? and
               tt-fpag.pladat = plani.pladat and
               tt-fpag.formap  = vforma      and
               tt-fpag.moecod = (if avail pdvmoeda 
                                 then pdvmoeda.moecod else "")
               no-error.
    if not avail tt-fpag 
    then do:
        create tt-fpag.
        assign
            tt-fpag.etbcod = ?
            tt-fpag.pladat = plani.pladat
            tt-fpag.formap  = vforma
            tt-fpag.moecod = (if avail pdvmoeda
                              then pdvmoeda.moecod else "")  
            .
    end.
    if ttforma.primeiraf
    then assign
             tt-fpag.valforma = tt-fpag.valforma + pdvforma.valor.
             assign
             tt-fpag.moenom   = (if avail moeda
                                then moeda.moenom else "")
             tt-fpag.valmoeda = tt-fpag.valmoeda + (if avail pdvmoeda
                                 then pdvmoeda.valor else 0)
                .
    find first tt-fpag where
               tt-fpag.etbcod = ? and
               tt-fpag.pladat = ? and
               tt-fpag.formap  = vforma      and
               tt-fpag.moecod = (if avail pdvmoeda 
                                 then pdvmoeda.moecod else "")
               no-error.
    if not avail tt-fpag 
    then do:
        create tt-fpag.
        assign
            tt-fpag.etbcod = ?
            tt-fpag.pladat = ?
            tt-fpag.formap  = vforma
            tt-fpag.moecod = (if avail pdvmoeda
                              then pdvmoeda.moecod else "")  
            .
    end.
    if ttforma.primeiraf
    then assign
             tt-fpag.valforma = tt-fpag.valforma + pdvforma.valor.
             assign
             tt-fpag.moenom   = (if avail moeda
                                then moeda.moenom else "")
             tt-fpag.valmoeda = tt-fpag.valmoeda + (if avail pdvmoeda
                                 then pdvmoeda.valor else 0)
                .
                

end procedure.


procedure estorno.

    def var vct as int.
    def buffer bttforma for ttforma.

    for each bttforma where bttforma.seqforma = ttforma.seqforma.
        find first pdvmoeda of pdvforma
                            where pdvmoeda.seqfp  = bttforma.seqfp and
                                  pdvmoeda.titpar = bttforma.titpar
                            no-lock.
        find first titbsmoe of pdvmoeda exclusive no-error.
        if avail titbsmoe
        then do.
            vct = vct + 1.
            assign
                bttforma.modcod = "EST".
                titbsmoe.modcod = "EST". /** Relatorios buscam modcod = CAR **/
        end.
    end.
    message "Registros alterados=" vct view-as alert-box.

end procedure.

