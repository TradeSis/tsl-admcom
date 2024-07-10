{admcab.i}

def var varquivo as char.
def var vprocod like produ.procod.


repeat:

           
    update vprocod label "Produto"
           with frame f-dados width 80 side-labels.

    if vprocod <> 0
    then do:
        find produ where produ.procod = vprocod no-lock no-error.
        if not avail produ
        then do:
            message "Produto nao cadastrado.".
            undo, retry.
        end.
        else disp produ.pronom no-label with frame f-dados.
    end.
    else disp "Todos" @ produ.pronom no-label with frame f-dados.

    if opsys = "UNIX"
    then varquivo = "../relat/rqtdmaxp." + string(time).
    else varquivo = "..\relat\rqtdmaxp." + string(time).

    {mdadmcab.i 
      &Saida     = "value(varquivo)"
      &Page-Size = "63"
      &Cond-Var  = "90"
      &Page-Line = "66"
      &Nom-Rel   = ""rqtdmaxp""
      &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""  
      &Tit-Rel   = """LISTAGEM DE QUANTIDADE MAXIMA DE PRODUTOS POR PEDIDO """
      &Width     = "90" 
      &Form      = "frame f-cabcab"}


    if vprocod = 0
    then do:
        for each estoq where estoq.etbcod = 993
                          or estoq.etbcod = 900 no-lock.
            if estoq.estloc = ""
            then next.
            
            find produ where produ.procod = estoq.procod no-lock no-error.
            if not avail produ
            then next.
            
            disp estoq.procod column-label "Produto"
                 produ.pronom column-label "Descricao"
                 estoq.estloc column-label "Qtd.Max!Pedido"
                 with frame f-mostra width 90 down.

            down with frame f-mostra.

        end.
    end.
    else do:

        for each estoq where (estoq.etbcod = 993 or estoq.etbcod = 900) 
                         and estoq.procod = vprocod no-lock.
            if estoq.estloc = ""
            then next.
            
            find produ where produ.procod = estoq.procod no-lock no-error.
            if not avail produ
            then next.
            
            disp estoq.procod column-label "Produto"
                 produ.pronom column-label "Descricao"
                 estoq.estloc column-label "Qtd.Max!Pedido"
                 with frame f-mostra2 width 90 down.

            down with frame f-mostra2.

        end.
    
    
    end.
    
    output close.
    
    if opsys = "UNIX"
    then run visurel.p (input varquivo, input "").
    else {mrod.i}.

    hide frame f-cabcab no-pause.
    hide frame f-mostra no-pause.
    hide frame f-mostra2 no-pause.
end.
