{admcab.i}

def input parameter par-rec as recid.

/***
def var recimp   as recid.
def var fila     as char.
***/
def var varquivo as char.
def var vsemipi  like plani.platot.
def var vpreco   like plani.platot.
def var vprvenda like estoq.estvenda.
def var vlipqtd  like liped.lipqtd.

find pedid where recid(pedid) = par-rec no-lock.

varquivo = "/admcom/relat/lpedidmoda" + string(time).
/***
        find first impress where impress.codimp = setbcod no-lock no-error. 
        if avail impress
        then do:
            run acha_imp.p (input recid(impress), 
                            output recimp).
            find impress where recid(impress) = recimp no-lock no-error.
            assign fila = string(impress.dfimp). 
        end.
***/
    {mdad.i
        &Saida     = "value(varquivo)"  
        &Page-Size = "64"
        &Cond-Var  = "153"
        &Page-Line = "66"
        &Nom-Rel   = ""LPEDIDMODA""
        &Nom-Sis   = """SISTEMA COMERCIAL"""
        &tit-rel   = """PEDIDO DE COMPRA - NUMERO "" +
                      STRING(pedid.pednum) + "" - "" + string(pedid.peddat)"
        &Width     = "147"
        &Form      = "frame f-cabcab"}

find forne where forne.forcod = pedid.clfcod no-lock.
find crepl of pedid no-lock.

display pedid.clfcod  colon  12 label "Fornecedor"
        forne.fornom  no-label format "x(39)"
        forne.forfone
        forne.email   skip 
        pedid.peddti  colon  12 label "Entrega___"
        " a "
        pedid.peddtf  no-label skip
        crepl.crenom  colon  12 label "Cond. Pagto"
        pedid.nfdes   colon  85 label "Desc.Nota"
        pedid.dupdes  colon 110 label "Desc.Duplic"
        pedid.ipides  label "IPI" format ">9.99 %"
        with side-labels with frame frel1 width 145.

put skip(1) fill("-",143) format "x(143)" skip.

def temp-table tt-produ
    field procod    like liped.procod
    field lipqtd    like liped.lipqtd
    
    index produ is primary unique procod.

def temp-table tt-pack
    field paccod    like lipedpai.paccod
    field lipqtd    like lipedpai.lipqtd
    
    index pack is primary unique paccod.

for each lipedpai of pedid no-lock
        break by lipedpai.itecod.

    create tt-pack.
    assign
        tt-pack.paccod = lipedpai.paccod
        tt-pack.lipqtd = lipedpai.lipqtd.

    for each liped where liped.etbcod  = pedid.etbcod
                     and liped.pedtdc = pedid.pedtdc
                     and liped.pednum = pedid.pednum
                     and liped.lipcor = string(lipedpai.paccod)
                   no-lock.
        find tt-produ of liped no-error.
        if not avail tt-produ
        then do.
            create tt-produ.
            assign
                tt-produ.procod = liped.procod
                tt-produ.lipqtd = tt-produ.lipqtd + liped.lipqtd.
        end.
    end.

    if last-of (lipedpai.itecod)
    then do.    
        find produpai of lipedpai no-lock.
        
        vsemipi = lipedpai.lippreco - (lipedpai.lippreco * (pedid.nfdes / 100)).
                    
        vpreco = lipedpai.lippreco - (lipedpai.lippreco * (pedid.nfdes / 100)).
        vpreco = vpreco + (vpreco * (pedid.ipides / 100)).
    
    disp
        lipedpai.itecod    column-label "Produto"
        produpai.pronom    column-label "PAI"
        lipedpai.lipqtdtot column-label "Qtde.Prod!Total"
        vsemipi column-label "Valor!Sem IPI" format ">>>,>>9.99"
        lipedpai.lipqtdtot * vsemipi
                column-label "Total!Sem IPI" format ">>>,>>9.99"
        lipedpai.lipqtdtot * (vpreco - vsemipi)
                column-label "Valor!IPI" format ">>>,>>9.99"
        vpreco column-label "Valor!Com IPI"
        vpreco * lipedpai.lipqtdtot column-label 
             "Total!Com IPI" format ">,>>>,>>9.99"
        lipedpai.lipqtdtot * (vpreco + (vpreco * (pedid.acrfin / 100)))
                               column-label "Total PC" format ">>>,>>9.99" 
/***
        vprvenda
***/
        with frame f-rom1 width 153 down.

        /* Filhos */
        for each tt-produ no-lock.
            find produ of tt-produ no-lock.
            find cor of produ no-lock.
            disp
                produ.procod colon 15
                produ.pronom
                cor.cornom   column-label "Cor"
                produ.protam
                tt-produ.lipqtd
                with frame f-produ down no-box width 136.
        end.

        put skip fill(" ", 8) fill("-",139) format "x(139)" skip(1).

        for each tt-pack no-lock.
            find pack of tt-pack no-lock.
            disp
                pack.paccod colon 20
                pack.pacnom no-label
                tt-pack.lipqtd label "Quantidade de Packs"
                pack.qtde      label "Quantidade Total de Produtos"
                with frame f-pack side-label no-box width 136.

            for each packprod of pack no-lock.
                find produ of packprod no-lock.
                find cor of produ no-lock.
                disp
                    packprod.procod colon 25
                    cor.cornom column-label "Cor" format "x(20)"
                    cor.pantone
                    produ.protam
                    packprod.qtd
                    with frame f-packprod down no-box.
            end.
        end.
    end.
end.
put skip fill("-",147) format "x(143)" skip(1).
      
      display "OBSERVACOES: "  skip 
              pedid.pedobs[1] format "x(78)" skip 
              pedid.pedobs[2] format "x(78)" skip 
              pedid.pedobs[3] format "x(78)" skip 
              pedid.pedobs[4] format "x(78)" skip 
              pedid.pedobs[5] format "x(78)" skip
              with frame fobsrel no-box width 143 no-label.

put unformatted
    "OBS: Mercadorias enviadas em desacordo com este pedido estao sujeitas a "
    "devolucao sem previo aviso." skip
    "Mencionar o Numero de nosso pedido de compra no corpo da Nota Fiscal."
    at 6 skip(1).

put skip fill("-",143) format "x(143)" at 1 skip.

      display skip (02)
              "___________________________________"    colon 22
              "___________________________________"    colon 90 skip
              forne.fornom  no-label  colon 25
              "COMPRADOR"             colon 95 skip
              "REPRESENTANTE"         colon 25              skip(1)
              with side-labels with frame frel2 width 143.     

output close.
run visurel.p(input varquivo, input "").

/***
        sparam = SESSION:PARAMETER.
        if num-entries(sparam,";") > 1
        then sparam = entry(2,sparam,";").
        if sparam = "AniTA"
        then do:
            find estab where estab.etbcod = setbcod no-lock.
            run visurel.p(input varquivo, input "").
        end.
        else do:
            os-command silent lpr value(fila + " " + varquivo).
        end.
***/