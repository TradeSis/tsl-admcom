{admcab.i}
def var vtipo as char format "x(10)" extent 2
        initial["Sintetico","Analitico"].
def var totqtd as int.
def var totven as dec.
def var vresp as l format "C/R" initial yes.
def var varquivo as char format "x(20)".

def var vesc as char format "x(10)" extent 2 initial["Fornecedor","Produto"].
def var vprocod   like produ.procod.
def var vetbcod   like estab.etbcod.
def var vfuncod   like func.funcod.
def var vmovqtm   like movim.movqtm.
def var vfunc     like titulo.titvlcob.
def var vdti      like plani.pladat.
def var vdtf      like plani.pladat.
def var vforcod   like forne.forcod.
def var vtotal like plani.platot.
def var vqtd   like movim.movqtm.
def temp-table tt-venda
    field etbcod like estab.etbcod
    field procod like produ.procod
    field movqtm like movim.movqtm
    field movpc  like movim.movpc
    field numero like plani.numero
    field movdat like movim.movdat.

repeat:
    
    vmovqtm = 0.
    vtotal = 0.
    vqtd = 0.
    vprocod = 0.
    vforcod = 0.
    for each tt-venda:
        delete tt-venda.
    end.


    update vetbcod colon 18 with frame f1 centered side-label
                    color blue/cyan row 4 width 80.

    if vetbcod = 0
    then display "Geral" @ estab.etbnom no-label with frame f1.
    else do:
           find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            message  "Estabelecimento nao cadastrado".
            undo.
        end.
        disp estab.etbnom no-label with frame f1.
    end.

    update  vdti label "Dt.Inicial" colon 18
            vdtf label "Dt.Final"
                 with frame f1.

    update vforcod label "Fornecedor" 
                    with frame f12 side-label.
    find forne where forne.forcod = vforcod no-lock.
    disp forne.forfant no-label format "x(25)" 
            with frame f12 column 25 width 50.

    for each produ where produ.fabcod = vforcod no-lock:
        if vetbcod = 0
        then do:
            for each estab no-lock:
                for each movim where movim.procod = produ.procod and
                                     movim.etbcod = estab.etbcod and
                                     movim.movtdc = 5            and
                                     movim.movdat >= vdti        and
                                     movim.movdat <= vdtf no-lock:
        
                    find first plani where plani.etbcod = movim.etbcod and
                                           plani.placod = movim.placod 
                                                no-lock no-error.
                    if not avail plani
                    then next.
                    
                    find first tt-venda 
                        where tt-venda.etbcod = movim.etbcod and
                              tt-venda.procod = movim.procod and
                              tt-venda.numero = plani.numero no-error.
                    if not avail tt-venda
                    then do:
                        create tt-venda.
                        assign tt-venda.etbcod = movim.etbcod
                               tt-venda.procod = produ.procod
                               tt-venda.numero = plani.numero.
                     end.
                     assign tt-venda.movqtm = tt-venda.movqtm + movim.movqtm
                            tt-venda.movpc  = tt-venda.movpc + (movim.movpc *
                                                        movim.movqtm).
                end.    
            end.
        end.
        else do:
            for each movim where movim.procod = produ.procod and
                                 movim.etbcod = vetbcod      and
                                 movim.movtdc = 5            and
                                 movim.movdat >= vdti        and
                                 movim.movdat <= vdtf no-lock:

                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod 
                                             no-lock no-error.
                if not avail plani
                then next.
                    

                find first tt-venda where tt-venda.etbcod = movim.etbcod and
                                          tt-venda.procod = movim.procod and
                                          tt-venda.numero = plani.numero
                                                                no-error.
                if not avail tt-venda
                then do:
                    create tt-venda.
                    assign tt-venda.etbcod = movim.etbcod
                           tt-venda.procod = produ.procod
                           tt-venda.numero = plani.numero.
                end.
                assign tt-venda.movqtm = tt-venda.movqtm + movim.movqtm
                       tt-venda.movpc  = tt-venda.movpc + (movim.movpc *
                                                           movim.movqtm).
            end.    


        end.

    end.

        
    varquivo = "i:\admcom\relat\premio2" + STRING(day(today)) + 
                string(vetbcod,">>9").

    {mdadmcab.i
            &Saida     = "value(varquivo)" 
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = ""premio2""
            &Nom-Sis   = """SISTEMA DE VENDAS"""
            &Tit-Rel   = """VENDAS -  FORNECEDOR : "" 
                            + string(vforcod,"">>>>99"") + "" FILIAL "" + 
                                  string(vetbcod,"">>9"") +
                          "" PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "160"
            &Form      = "frame f-cabcab"}

     for each tt-venda break by  tt-venda.etbcod
                             by  tt-venda.procod
                             by  tt-venda.movdat:
         if first-of(tt-venda.etbcod)
         then do:                 
             disp tt-venda.etbcod 
                    label "Filial" with frame f-princ.  
         end.                    

         find produ where produ.procod = tt-venda.procod no-lock.
         disp tt-venda.numero column-label "Nota!Fiscal"
              tt-venda.procod
              produ.pronom 
              tt-venda.movqtm(total by tt-venda.etbcod) 
                      column-label "Quantidade" 
              tt-venda.movpc(total by tt-venda.etbcod)  
                        column-label "Preco" format ">>,>>>,>>9.99" 
                  with frame f-princ down width 200.
    end.
    
    output close.
    message "Consulta ou Relatorio" update vresp.
    if vresp
    then dos silent value("ved " + varquivo).  
    else dos silent value("type " + varquivo + " > prn").  



end.
