{admcab.i}

def var cestab     as char format "x(60)".
def var vEstab     as log  format "Sim/Nao"  init yes.
def temp-table wfestab
    field etbcod        like estab.etbcod init 0.
def buffer bwfestab    for wfestab.

def var varquivo as char.
def var vdtini  as Date    label "Data Inicial" form "99/99/99".
def var vdtfim  as Date    label "Data Final"   form "99/99/99".
def var vdata   as date.
def var vclacod like produ.clacod.
def var vprocod like produ.procod.
def var vdestino as log.

def temp-table tt-rel
    field rec as recid
    field procod like produ.procod
    field clacod like produ.clacod
    field etbcod as int
    field data   as date
    
    index rel clacod etbcod data.

form
    vEstab    colon 30    label "Todos Estabelecimentos.."
                help "Relatorio com Todos os Estabelecimentos ?"
    cestab no-label format "x(40)"
    vclacod   colon 30
    vdtini    colon 30
    vdtfim label "ate"
    vdestino  colon 30    label "Destino"  format "Arquivo/Impressora"
        help "Arquivo/Impressora"
    with frame fopcoes row 3 side-label width 80.

do on error undo with frame fopcoes.
    clear frame fopcoes all no-pause.

    {filtro-estab.i}

    update vclacod.
    if vclacod > 0
    then do.
        find clase where clase.clacod = vclacod no-lock no-error.
        if not avail clase
        then do.
            message "Subclasse invailida" view-as alert-box.
            undo.
        end.
    end.

    /*
        Datas
    */
    update vdtini validate (vdtini <= today, "")
        vdtfim.
    if vDtFim < vDtIni
    then do:
        message "Data invalida" view-as alert-box.
        undo.
    end.
    update vdestino.
end.

for each estab no-lock.
    if not vEstab
    then do:
         find wfEstab where wfEstab.Etbcod = Estab.Etbcod no-error.
         if not avail wfEstab
         then next.
    end.

    do vdata = vdtini to vdtfim.
        for each tbprice where tbprice.etb_venda = estab.etbcod
                           and tbprice.data_venda = vdata
                           and tbprice.tipo = "CCID"
                         no-lock.
            vprocod = int(acha("PRODUTO", tbprice.char1)).
            find produ where produ.procod = vprocod no-lock.
            find clase of produ no-lock.
            if vclacod > 0 and clase.clasup <> vclacod
            then next.
            create tt-rel.
            assign
                tt-rel.rec    = recid(tbprice)
                tt-rel.procod = produ.procod
                tt-rel.clacod = clase.clasup
                tt-rel.etbcod = tbprice.etb_venda
                tt-rel.data   = tbprice.data_venda.
        end.
    end.
end.

if vdestino
then do.
    run arquivo.
    return.
end.

if opsys = "UNIX"
then varquivo = "../relat/rliccid" + string(time). 
else varquivo = "..\relat\rliccid" + string(time).

    {mdad.i &Saida     = "value(varquivo)" 
            &Page-Size = "64"
            &Cond-Var  = "120"
            &Page-Line = "66"
            &Nom-Rel   = ""rliccid""
            &Nom-Sis   = """SISTEMA ESTOQUE FILIAL """
            &Tit-Rel   = """LISTAGEM DE ICCID DE "" +
                          string(vdtini) + "" A "" + string(vdtfim)" 
            &Width     = "120" 
            &Form      = "frame f-cabcab2"} 
 
for each tt-rel no-lock
            break by tt-rel.clacod
                  by tt-rel.etbcod.
    find tbprice where recid(tbprice) = tt-rel.rec no-lock.
    find produ of tt-rel no-lock.
    find first func where func.funcod = tbprice.vendedor no-lock.
    if first-of (tt-rel.clacod)
    then put skip(2).
    disp
        tt-rel.clacod
        tbprice.etb_venda  column-label "Etb"
        tbprice.data_venda column-label "Data" format "99/99/99"
        tbprice.nota_venda
        tbprice.serial     format "x(20)"
        tbprice.vendedor
        func.funnom
        tt-rel.procod
        produ.pronom       format "x(30)"
        with frame f-lin down no-box width 160.
end.

output close.
if opsys = "UNIX"
then run visurel.p (input varquivo, input "").
else {mrod.i}.


procedure arquivo.

update varquivo label "Arquivo" format "x(50)" with frame f-arq side-label.

output to value(varquivo).

for each tt-rel no-lock break by tt-rel.clacod.
    find tbprice where recid(tbprice) = tt-rel.rec no-lock.
    find produ of tt-rel no-lock.
    find first func where func.funcod = tbprice.vendedor no-lock.
    export delimiter ";"
/*    put unformatted */
        tt-rel.clacod
        tbprice.etb_venda
        tbprice.data_venda
        tbprice.nota_venda
        tbprice.serial
        tbprice.vendedor
        func.funnom
        tt-rel.procod
        produ.pronom
        skip.
end.

output close.

message "Arquivo gerado" view-as alert-box.

end procedure.
 
