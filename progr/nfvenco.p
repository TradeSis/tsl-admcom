/***
40553
***/
{admcab.i}

def var vetbcod like plani.etbcod.
def var vnumero like plani.numero format ">>>>>>9".
def var vserie  like plani.serie  format "x(3)".
def var vcartao-lebes as char.
def var vcupom as int.

repeat:
    update vetbcod with frame f1 centered side-labels color white/red.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.

    update vnumero
           vserie no-label
           with frame f1.

    find first plani where plani.movtdc = 5 and
                            plani.etbcod = vetbcod and
                            plani.emite  = vetbcod and
                            plani.serie  = vserie and
                            plani.numero = vnumero
                      no-lock no-error.
    if not avail plani
    then do:                                                    
        find first plani where plani.movtdc = 81 and            
                               plani.etbcod = vetbcod and     
                               plani.emite  = vetbcod and     
                               plani.serie  = vserie and      
                               plani.numero = vnumero         
                                          no-lock no-error.                    
   end.
   if not avail plani
   then do:
        find first plani where plani.movtdc = 45 and
                            plani.etbcod = vetbcod and
                            plani.emite  = vetbcod and
                            plani.serie  = vserie and
                            plani.numero = vnumero
                      no-lock no-error.
        if avail plani
        then message "Nota Fiscal cancelada".
        else message "Nota Fiscal nao Existe".
        pause.
    end.
    else do:
        vcartao-lebes = "".
        if acha("CARTAO-LEBES",PLANI.NOTOBS[1]) <> ?
        then vcartao-lebes = acha("CARTAO-LEBES",plani.notobs[1]).

        find func where func.etbcod = plani.etbcod and
                        func.funcod = plani.vencod no-lock no-error.
        
        if num-entries(plani.notped,"|") > 2
        then vcupom = int(entry(2, plani.notped, "|")).
        disp plani.pladat
             plani.vencod format ">>>>>9"
             plani.cxacod
             vcupom format  "999999"  label "NroCupom"
             func.funnom when avail func
             string(plani.horincl,"hh:mm") label "Hora" 
             with frame f1.
        find clien where clien.clicod = plani.desti no-lock no-error.
        if avail clien
        then do:
            disp clien.clicod
                 clien.clinom no-label
                 with frame f1 /* f3 centered color black/cyan side-labels*/.
        end.
        else disp plani.desti @ clien.clicod
                  "Nao encontrado" @ clien.clinom
                  with frame f1.
                  
        find finan where finan.fincod = plani.pedcod no-lock no-error.
        if avail finan
        then
        disp finan.fincod label "Plano"
             finan.finnom             
             finan.finfat no-label 
             plani.vlserv label "Devolucao" 
             plani.biss   label "Total Contrato" 
             plani.descprod label "Desconto" 
             vcartao-lebes format "x(13)" label "Cartao Lebes" 
             with frame f1.

/***
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movdat = plani.pladat and
                             movim.movtdc = plani.movtdc no-lock:
            find produ where produ.procod = movim.procod no-lock no-error.
            disp movim.procod
                 produ.pronom format "x(25)" when avail produ
                 movim.ocnum[8] column-label "Promo"
                 movim.ocnum[9] when length(string(movim.ocnum[9])) < 6 
                        column-label "Plano" 
                 movim.movqtm (total) 
                        column-label "Qtd." format ">>>9"
                 movim.movpc column-label "Unitario" format ">>,>>9.99"
                (movim.movqtm * movim.movpc) (total) format ">>,>>9.99"
                        column-label "Total"
                 with frame f2 centered color white/cyan down.
        end.
***/

    end.

    run nfppro-vnd.p (recid(plani)).
end.
