{admcab.i}
def var vdtini      as   date label "Data Inicial".
def var vdtfin      as   date label "Data Final".
def var vetbcod     like estab.etbcod.

def temp-table wfcli
    field rec   as recid
    field con   as recid.

update vetbcod colon 20
       with frame f1.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento Invalido".
        undo.
    end.
    display estab.etbnom with frame f1.
end.
else
    display "GERAL " @ estab.etbnom no-label with frame f1.

update vdtini  colon 20
       vdtfin  colon 20
       with frame f1 centered side-label width 80.

for each clien where datexp >= vdtini and
                     datexp <= vdtfin no-lock.

    if vetbcod > 0
    then do:
       for each contrato no-lock
           where contrato.etbcod = vetbcod      and
                 contrato.clicod = clien.clicod:
           create wfcli.
           assign wfcli.rec = recid(clien)
                  wfcli.con = recid(contrato).
           leave.
       end.
    end.
    else do:
       for each contrato of clien no-lock.
           create wfcli.
           assign wfcli.rec = recid(clien)
                  wfcli.con = recid(contrato).
           leave.
       end.
    end.
end.

{mdadmcab.i
    &Saida     = "printer"
    &Page-Size = "64"
    &Cond-Var  = "100"
    &Page-Line = "66"
    &Nom-Rel   = """DREB020"""
    &Nom-Sis   = """SISTEMA CREDIARIO"""
    &Tit-Rel   = """CLIENTES NOVOS PARA ANALISE DE CREDITO - PERIODO DE "" +
                    string(vdtini) + "" A "" + string(vdtfin) "
    &Width     = "100"
    &Form      = "frame f-cab"}

for each wfcli,
    clien where recid(clien) = wfcli.rec no-lock,
    contrato where recid(contrato) = wfcli.con no-lock
                                            break by contrato.etbcod
                                                  by clien.dtcad
                                                  by clien.clinom.
    display
        contrato.etbcod
        clien.clicod
        clien.clinom
        contrato.dtinicial  column-label "Inclusao"
        contrato.vltotal column-label "Valor Compra" (total by contrato.etbcod)
        with width 160 no-box.
end.

output close.
