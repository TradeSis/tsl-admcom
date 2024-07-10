{admcab.i}

def var varquivo as char format "x(30)".
def var vdata   as date format "99/99/9999".
def stream stela.
def temp-table tt-lote
    field lote like lotdep.lote
    field dia  like deposito.chedia
    field pre  like deposito.chedre.

def var che-deposito as dec.
repeat:
    for each tt-lote.
        delete tt-lote.
    end.
    
    update vdata label "Data"
            with frame f-data centered color blue/cyan side-label width 80.
    if opsys = "UNIX"
    then varquivo = "../relat/conf1.txt" + string(time).
    else varquivo = "..~\relat~\conf1.txt" + string(time).

   
    {mdad.i
         &Saida     = "value(varquivo)"
         &Page-Size = "64"
         &Cond-Var  = "130"
         &Page-Line = "66"
         &Nom-Rel   = ""CONF2.P""
         &Nom-Sis   = """SISTEMA DE CREDIARIO"""
         &Tit-Rel   = """RELATORIO DE CONFIRMACOES  "" + 
                          string(vdata,""99/99/9999"")"
         &Width     = "130"
         &Form      = "frame dep1"}

    for each estab no-lock,
    
         each deposito where deposito.datcon = vdata and
                            deposito.etbcod = estab.etbcod 
                                                    by deposito.etbcod
                                                    by deposito.datmov:
        che-deposito = 0.

        for each depban where
                 depban.etbcod = estab.etbcod and
                 depban.datmov = deposito.datmov and
                 depban.moecod = "CHV"
                 no-lock:
            for each chq where 
                        chq.data = depban.datmov and
                        chq.depcod = depban.dephora
                        no-lock:
                che-deposito = che-deposito + chq.valor.
            end.
        end.
        
        find lotdep where lotdep.etbcod = deposito.etbcod and
                          lotdep.datcon = deposito.datmov no-lock no-error.
        if avail lotdep
        then do:
            find first tt-lote where tt-lote.lote = lotdep.lote no-error.
            if not avail tt-lote
            then do:
                create tt-lote.
                assign tt-lote.lote = lotdep.lote.
            end.
            assign tt-lote.dia = tt-lote.dia + (deposito.chedia - che-deposito)
                   tt-lote.pre = tt-lote.pre + deposito.chedre.
        end.
                              
        display deposito.etbcod    column-label "Filial"
                deposito.datmov    column-label "Data!Movimento"
                deposito.chedia - che-deposito (total) column-label "Cheq Dia"
                format "->>,>>>,>>9.99"
                deposito.chedre(total) column-label "Cheq Pre"
                deposito.deppag(total) column-label "Pgtos"
                deposito.depalt        column-label "Alterado"
                lotdep.lote when avail lotdep
                    with frame f2 down width 200. 
    end.
    for each tt-lote by tt-lote.lote.
        disp tt-lote.lote
             tt-lote.dia(total)
             tt-lote.pre(total)
             (tt-lote.dia + tt-lote.pre)(total)
                with frame f-lote down width 200.
    end.
    
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end.
