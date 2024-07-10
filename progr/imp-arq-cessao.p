def var vestipo as char extent 2 format "x(15)".
vestipo[1] = "RECEBIMENTO".
vestipo[2] = "CESSAO".
def var vindex as int.
disp vestipo with frame f-tipo 1 down no-label 1 column.
choose field vestipo with frame f-tipo.
vindex = frame-index.


def temp-table d-arquivo like frecebimento.
    
def var vdata as date.
def var vlinha as char.
def var vqlinha as int.
def var vi as int.    
def var varquivo as char.
varquivo = "/admcom/financeira/CTB2015/Recebimentos/recebimentos31082015.csv".
update vdata label "Data Movimento"  format "99/99/9999"
       with frame f-1.
if vdata = ? then return.
     
if vindex = 1
then varquivo = "/admcom/financeira/CTB2015/Recebimentos/recebimentos" +
                string(vdata,"99999999") + ".csv".
else if vindex = 2
then varquivo = "/admcom/financeira/CTB2015/Cessao/resumovendalebes" + 
                string(vdata,"99999999") + ".csv".
       
update varquivo at 1 label "Arquivo" format "x(69)"
       with frame f-1 1 down width 80 side-label.
       
vqlinha = 0.
input from value(varquivo).
repeat:
    import unformatted vlinha.
    vqlinha = vqlinha + 1.

    create d-arquivo.
    assign
        d-arquivo.arquivo = varquivo 
        d-arquivo.linha   = vqlinha
        d-arquivo.tipo    = vestipo[vindex]
        d-arquivo.data    = vdata
        .

    
    do vi = 1 to num-entries(vlinha,";"):
        d-arquivo.campo[vi] = entry(vi,vlinha,";").
    end.

end.

def var valor as char.
def var val as dec format ">>>,>>>,>>9.99".

for each d-arquivo exclusive:
    create frecebimento.
    buffer-copy d-arquivo to frecebimento.
end.

def var val-char as char.
for each frecebimento where frecebimento.data = 08/31/15 
    and frecebimento.tipo = "RECEBIMENTO" no-lock 
    by frecebimento.linha:

    val-char = frecebimento.campo[15].
    val-char = replace(val-char,".","").
    val-char = replace(val-char,",",".").
 
    find contrato where contrato.contnum = int(frecebimento.campo[3]) 
            no-lock no-error.
    if avail contrato 
    then do:

        find first envfinan where
               envfinan.empcod = 19 and
               envfinan.titnat = no and
               envfinan.modcod = "CRE" and
               envfinan.etbcod = contrato.etbcod and
               envfinan.clifor = contrato.clicod and
               envfinan.titnum = string(contrato.contnum) and
               envfinan.titpar = int(trim(frecebimento.campo[4]))
               no-error.
        if not avail envfinan
        then do:
            create envfinan.
            assign
                envfinan.empcod = 19
                envfinan.titnat = no
                envfinan.modcod = "CRE"
                envfinan.etbcod = contrato.etbcod
                envfinan.clifor = contrato.clicod
                envfinan.titnum = string(contrato.contnum)
                envfinan.titpar = int(trim(frecebimento.campo[4]))
                envfinan.envdt  = ?
                .
        end.
        envfinan.dt1 = frecebimento.data.
        envfinan.envsit = "CES".
        envfinan.dec1 = dec(val-char). 
    end.
end.

