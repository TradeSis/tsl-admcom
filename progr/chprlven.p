{admcab.i}

def var vetbcod  like estab.etbcod.
def var vdatini  as date.
def var vdatfin  as date.
def var vdata-aux as date.

def var vetbvenda like estab.etbcod.
def var vplavenda like plani.placod.
def var vetbutil  like plani.etbcod.

def var vqtdven   as int.
def var vvalven   as dec.

def var varquivo as char.

def var vdiferenca as dec.
def var vcodutil like plani.placod. 
def buffer bplani for plani.
def var vcatutil as int. 
def var vqtdutil as int.

repeat:
    vetbcod = 0.
    vdatini = ?.
    vdatfin = ?.
    
    update vetbcod label "Estabelecimento"
               help "0(zero) para Todos"
           with frame fopcoes.
    find estab where estab.etbcod = vetbcod no-lock no-error.           
    if vetbcod <> 0 and not avail estab
    then do:
        message "Estabelecimento Invalido".
        undo.
    end.
    update vdatini label "Data Inicial"
           vdatfin label "Data Final"
           with frame fopcoes side-labels.
    if vdatini = ? or vdatfin = ? or (vdatini > vdatfin)           
    then do:
        message "Periodo Invalido".
        undo.
    end.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/chprlven" + string(setbcod) + "."
                    + string(time).     
    else varquivo = "..~\relat~\chprlven" + string(setbcod) + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "0"  
                &Cond-Var  = "130" 
                &Page-Line = "66" 
                &Nom-Rel   = ""chprlven"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """ CARTAO PRESENTE - RELATORIO DE VENDAS """
                &Width     = "110"
                &Form      = "frame f-cabcab"}    

    disp with frame fopcoes.
    vqtdven   = 0.
    vqtdutil = 0.
    vvalven   = 0.
    
    do vdata-aux = vdatini to vdatfin:
      for each titulo use-index titdtven where titulo.empcod = 19
                      and titulo.titnat = yes
                      and titulo.modcod = "CHP"
                      and titulo.titsit = "PAG"
                      and titulo.etbcod = 999
                      and titulo.titdtven =  vdata-aux
                      and titulo.clifor = 110165 no-lock.

        vetbvenda = ?.
        vplavenda = ?.
        vetbutil = ?.
        release plani.

        vetbvenda = int(acha("ETBCODVENDACHP",titulo.titobs[1])).
        vplavenda = int(acha("PLACODVENDACHP",titulo.titobs[1])).

        if vetbvenda = ? or vplavenda = ? then next.
        if vetbcod <> 0 and vetbcod <> vetbvenda then next.
        
        find plani where plani.etbcod = vetbvenda
                          and plani.placod = vplavenda 
                          and plani.movtdc = 5 no-lock no-error.
        vetbutil = int(acha("ETBCODUTILIZACHP",titulo.titobs[2])).
        vetbutil = int(acha("ETBCODUTILIZACHP",titulo.titobs[2])).
        vcodutil = int(acha("PLACODUTILIZACHP",titulo.titobs[2])).
        find bplani where bplani.etbcod = vetbutil and
                          bplani.placod = vcodutil and
                          bplani.movtdc = 5
                          no-lock no-error.
        vcatutil = 0. 
        for each movim where movim.etbcod = bplani.etbcod and
                             movim.placod = bplani.placod and
                             movim.movtdc = bplani.movtdc 
                             no-lock.
            find produ where produ.procod = movim.procod no-lock no-error.
            if not avail produ then next.
            vcatutil = produ.catcod.
            if vcatutil = 31
            then leave.
        end.
        if avail plani and
                plani.pladat >= vdatini and
           plani.pladat <= vdatfin
        then vqtdven = vqtdven + 1.

        vqtdutil = vqtdutil + 1.
        vvalven = vvalven + titulo.titvlcob.
                    
        if avail bplani then vdiferenca = bplani.platot - titulo.titvlcob.                                 else vdiferenca = ?.
                  
        disp titulo.titnum                 column-label "Numero!Cartao"
             plani.etbcod when avail plani column-label "Fil!Ven"
             titulo.titdtven               column-label "Data!Ativacao"
             plani.vencod when avail plani column-label "Vend!Venda"
             plani.numero when avail plani column-label "Numero!Venda"
                format ">>>>>>>9"
             titulo.titvlcob    format ">>>>,>>9.99"
                            column-label "Valor!Cartao"
             vcatutil      format ">>9"                column-label "Set!Util"
             vetbutil when vetbutil <> ?   column-label "Fil!Util"
             titulo.titdtpag               column-label "Data!Util"
             bplani.vencod                 column-label "Vend!Util"
             bplani.numero                  column-label "Numero!Util"
                    format ">>>>>>>>9"
             bplani.platot when avail plani column-label "Valor!Util"
                            format ">>>>,>>9.99"
             vdiferenca  when avail bplani  column-label "Diferenca"
             with frame frame-a 10 down centered
                                   color white/red row 5 width 130.
     end. /* for each */
    end. /* Data */
    disp skip(3)
         vqtdutil label "Cartoes Utilizados no Periodo" 
         skip
         vqtdven  label "Cartoes Vendidos no Periodo.."
         with frame f-tot side-labels.
    
    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.    
end. /* repeat */
    
