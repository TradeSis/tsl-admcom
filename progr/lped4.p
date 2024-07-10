{admcab.i}
def var vdata as date format "99/99/9999".
def var vdti as date  format "99/99/9999".
def var vdtf as date  format "99/99/9999".
def var varquivo as char.
repeat:
    update vdti label "Data Inicial" 
           vdtf label "Data Final"
                with frame f1 side-label width 80.     
for each pedid where pedid.pedtdc = 4 and
                     pedid.peddat >= vdti and
                     pedid.peddat <= vdtf no-lock.
            /*
            if pednum > 1000
            then next.
            */
            display pedid.etbcod
                    pedid.pednum format ">>>>>>>>>"
                    pedid.peddat 
                    pedid.sitped with frame f2
                            down color white/cyan centered.
end.
    pause.
    message "Confirma Impressao do Pedido" update sresp.
    if not sresp
    then undo.
    for each pedid where pedid.pedtdc = 4 and
                         pedid.peddat >= vdti and
                         pedid.peddat <= vdtf.
        /*
        if pednum > 1000
        then next.
        */
        pedid.sitped = "L".

        varquivo = "..\relat\lped4" + string(time).
        {mdad.i &Saida     = "value(varquivo)" 
                &Page-Size = "63" 
                &Cond-Var  = "120"  
                &Page-Line = "66" 
                &Nom-Rel   = ""lped4"" 
                &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO""" 
                &Tit-Rel   = """REQUISICAO DE MERCADORIA VENDA"""
                &Width     = "120"
                &Form      = "frame f-cabcab"}
 
            put skip(5)
            "        DREBES & CIA LTDA         " at 40 skip(2).
            put "  REQUISI€AO DE MERCADORIA VENDA  " at 40 skip(2).
            find first liped where liped.etbcod = pedid.etbcod and
                                   liped.pedtdc = pedid.pedtdc and
                                   liped.pednum = pedid.pednum and
                                   liped.predt  = pedid.peddat no-lock no-error.
            if not avail liped
            then do:
                output close.
                next.
            end.
            
            find produ where produ.procod = liped.procod no-lock.
            find fabri where fabri.fabcod = produ.fabcod no-lock no-error.
            put fabri.fabfant at 40 skip(2).

            for each liped where liped.pedtdc = pedid.pedtdc and
                                 liped.etbcod = pedid.etbcod and
                                 liped.pednum = pedid.pednum and
                                 liped.predt  = pedid.peddat.
                liped.lipsit = "L".
                find estoq where estoq.etbcod = pedid.etbcod and
                                 estoq.procod = liped.procod no-lock.
                find produ of liped no-lock.
                disp produ.procod at 10
                     produ.pronom
                     liped.lipcor column-label "Cor"
                     liped.lipqtd column-label "QTD"
                     estoq.estvenda column-label "Preco"
                               with frame f-rom width 200 down.
            end.
            find func where func.etbcod = pedid.etbcod and
                            func.funcod = pedid.vencod no-lock no-error.
            put skip(7)
            "PEDIDO: " at 10 pedid.pednum format ">>>>>>>>>"
            "     ORDEM DE COMPRA : " pedid.comcod format ">>>>>>>9" SKIP(1)
            "NF: " at 10 pedid.frecod
            "         DATA VENDA: " pedid.condat format "99/99/9999" SKIP(1).
            if pedid.vencod <> 0
            then put "NOME: " at 10 func.funnom skip(1).
            else put "NOME:............... " at 10 skip(1).
            find estab where estab.etbcod = pedid.etbcod no-lock.
            put "DATA: " at 10 today format "99/99/9999"
            " FILIAL: " at 40
            estab.etbnom skip(1).
        output close.
        {mrod.i}
    end.
end.
