{admcab.i}

def var recimp as recid.
def var fila as char.

def var vok as log.
def stream stela.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vetb1 like estab.etbcod.
def var vetb2 like estab.etbcod.
def var vtip as char format "x(20)" extent 2 initial ["Numerico","Alfabetico"].
def buffer bestab for estab.
def var varquivo as char.
def temp-table tt-produ
    field procod like produ.procod
    field pronom like produ.pronom
    field qtdent like estoq.estatual
    field qtdsai like estoq.estatual
    field estcusto like estoq.estcusto
    field estatual like estoq.estatual.


repeat:

    for each tt-produ:
        delete tt-produ.
    end.


    update vetb1 label "Filial 1" at 1
            with frame f1 side-label centered width 80
                title "Movimentacoes entre filiais".
    find estab where estab.etbcod = vetb1 no-lock.
    disp estab.etbnom no-label with frame f1.

    update vetb2 label "Filial 2" at 1
            with frame f1 side-label centered width 80.
            
    find bestab where bestab.etbcod = vetb2 no-lock.
    disp bestab.etbnom no-label with frame f1.



    update vdti at 1 label "Periodo" 
           vdtf no-label with frame f1.

    display vtip with frame f-tip no-label.
    choose field vtip with frame f-tip centered row 4.

    if opsys = "UNIX"
    then varquivo = "/admcom/relat/inv98" + string(day(vdti))
                                          + string(month(vdti))
                                          + string(estab.etbcod,">>9"). 
    else varquivo = "l:\relat\inv98" + string(day(vdti)) 
                                     +  string(month(vdti)) 
                                     + string(estab.etbcod,">>9").

 
    output stream stela to terminal.
    
    {mdad_l.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"  
        &Cond-Var  = "147"
        &Page-Line = "64" 
        &Nom-Rel   = """relinv98"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """Produtos Movimentados entre filial "" 
                      + string(vetb1,"">>9"") + "" E "" +
                        string(vetb2,"">>9"")"
                      ""Data: "" + string(vdti,""99/99/9999"") + 
                                   string(vdtf,""99/99/9999"")"
        &Width     = "147"
        &Form      = "frame f-cab"}

    

    for each plani where plani.etbcod = estab.etbcod  and
                         plani.movtdc = 06            and
                         plani.desti  = bestab.etbcod and
                         plani.pladat >= vdti         and
                         plani.pladat <= vdtf        no-lock:
                         
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat no-lock:
                             
            
            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = movim.procod no-lock no-error.
            if not avail estoq
            then next.
            find produ where produ.procod = movim.procod no-lock no-error.
            if not avail produ
            then next.
                             
            
            find first tt-produ where tt-produ.procod = movim.procod no-error.
            if not avail tt-produ
            then do:
                create tt-produ.
                assign tt-produ.procod = movim.procod
                       tt-produ.pronom = produ.pronom
                       tt-produ.estcusto = estoq.estcusto
                       tt-produ.estatual = estoq.estatual.
            end.
            tt-produ.qtdsai = tt-produ.qtdsai + movim.movqtm.
        
            display stream stela 
                    produ.procod
                            with frame ftot1 side-label centered row 10.
            pause 0.
 
        
        end.
    end.        
 
    for each plani where plani.etbcod = bestab.etbcod  and
                         plani.movtdc = 06            and
                         plani.desti  = estab.etbcod and
                         plani.pladat >= vdti         and
                         plani.pladat <= vdtf        no-lock:
                         
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat no-lock:
                             
            
            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = movim.procod no-lock no-error.
            if not avail estoq
            then next.
            find produ where produ.procod = movim.procod no-lock no-error.
            if not avail produ
            then next.
                             
            
            find first tt-produ where tt-produ.procod = movim.procod no-error.
            if not avail tt-produ
            then do:
                create tt-produ.
                assign tt-produ.procod   = movim.procod
                       tt-produ.pronom   = produ.pronom
                       tt-produ.estcusto = estoq.estcusto
                       tt-produ.estatual = estoq.estatual.
            end.
            tt-produ.qtdent = tt-produ.qtdent + movim.movqtm.
    
            display stream stela 
                    produ.procod
                            with frame ftot2 side-label centered row 10.
            pause 0.

 
        
        end.
    end.        

                 
        
    
    if frame-index = 1
    then do:

        
        for each tt-produ no-lock by tt-produ.procod.


                             
            display tt-produ.procod column-label "Codigo"
                    tt-produ.pronom format "x(40)"
                    tt-produ.estatual(TOTAL) 
                            column-label "Qtd." format "->>>>>9"
                    tt-produ.estcusto column-label "Pc.Custo" 
                            format "->>>,>>9.99"
                    (tt-produ.estcusto * tt-produ.estatual)(total)
                            column-label "Total Custo" format "->>>,>>9.99"
                    tt-produ.qtdent(total) column-label "Qtd.Entradas"
                                format ">>>>>>>9"
                    tt-produ.qtdsai(total) column-label "Qtd.Saidas  "                                           format ">>>>>>>9"
                                with frame f2 down width 200.
            

        end.
        
    end.
    
    else do:
        for each tt-produ no-lock by tt-produ.pronom.
                
            display tt-produ.procod column-label "Codigo"
                    tt-produ.pronom format "x(40)"
                    tt-produ.estatual(total) 
                                   column-label "Qtd." format "->>>>>9"
                    tt-produ.estcusto column-label "Pc.Custo" 
                            format "->>>,>>9.99"
                    (tt-produ.estcusto * tt-produ.estatual)(total)
                            column-label "Total Custo" format "->>,>>>,>>9.99"
                    tt-produ.qtdent(total) column-label "Qtd.Entradas"
                                format ">>>>>>>9"
                    tt-produ.qtdsai(total) column-label "Qtd.Saidas  "                                           format ">>>>>>>9"
                                    with frame f3 down width 200.
        

       end.
  
    end.

    output close.
    output stream stela close.
 
    if opsys = "UNIX"
    then do: 
        find first impress where impress.codimp = setbcod no-lock no-error.
        if avail impress  
        then do: 
            run acha_imp.p (input recid(impress),   
                            output recimp).

            find impress where recid(impress) = recimp no-lock no-error.
            
            assign fila = string(impress.dfimp). 
        end.      
        os-command silent lpr value(fila + " " + varquivo).
    end.
    else do: 
        {mrod_l.i}.
    end.        
end.
