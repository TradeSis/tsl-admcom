{admcab.i}


def var varquivo as char.

def shared temp-table tt-che
    field rec  as recid
    index rec is primary unique rec asc.

             
    if opsys = "UNIX"
    then  varquivo = "../relat/relchcof." + string(time).
    else  varquivo = "..~\relat~\relchcof." + string(time).

    {mdad.i
         &Saida     = "value(varquivo)"
         &Page-Size = "64"
         &Cond-Var  = "130"
         &Page-Line = "66"
         &Nom-Rel   = ""CONF2.P""
         &Nom-Sis   = """SISTEMA FINANCEIRO"""
         &Tit-Rel   = """RELATORIO DE CHEQUES"""
         &Width     = "130"
         &Form      = "frame dep1"}
     
     for each tt-che,
         chq where recid(chq) = tt-che.rec no-lock
            break by chq.data:

        if first-of(chq.data)
        then display  chq.data label "Vencto"
                with frame f2.
        disp        
                chq.datemi column-label "Emissao"
                chq.comp
                chq.banco
                chq.agencia format ">>>>>>9"
                chq.controle1
                chq.conta format "x(15)"
                chq.controle2
                chq.numero
                chq.controle3
                chq.valor(total by chq.data) format ">>>,>>>,>>9.99" 
                    with frame f2 down width 200.

        down with frame f2.
    end.
    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i} .
    end.
