
def input parameter p-tipo  as char.
def input parameter p-recid as recid.
def temp-table seq-mes no-undo
    field ano as int
    field mes as int
    field seq as int
    field avpdia as dec
    field vencido as dec
    field avencer as dec
    index i1 ano mes.
 
def var v-vtotal as dec.
def var v-vencido as dec.
def var v-vencer as dec.
def var val-avpdia as dec.

def var vdatref as date.
def var vdata as date.
def var vseq as int.

find tbparavp where recid(tbparavp) = p-recid no-lock no-error.
if not avail tbparavp
then return.

vdatref = tbparavp.datref.

find first indic where
           indic.indcod = tbparavp.indcod
           no-lock no-error.
if not avail indic
then return.
find first indice where
           indice.indcod = indic.indcod and
           indice.inddat = tbparavp.datref
           no-lock no-error.
if not avail indice
then return.

def var p-tj like indice.indvalor.
p-tj = indice.indvalor.

if p-tj <= 0
then do:
    message color red/with
    "Para CREDORES a taxa de juros não pode ser 0(zero)."
    view-as alert-box.
    return.
end.

do vdata = vdatref + 1 to vdatref + 3600:
    find first seq-mes where
               seq-mes.ano = year(vdata) and
               seq-mes.mes = month(vdata)
               no-error.
    if not avail seq-mes
    then do on error undo:
        create seq-mes.
        assign
            seq-mes.ano = year(vdata)
            seq-mes.mes = month(vdata)
            vseq = vseq + 1
            seq-mes.seq = vseq
            .
    end.           
end.

def var vi as int.
def var vb as dec.
def var va as dec.

def var varq as char.

def var v-acao as char format "x(30)".

if p-tipo = "SIMULAR"
THEN v-acao = "SIMULANDO AVP CREDORES... ".
else if p-tipo = "PROCESSAR"
    then v-acao = "PROCESSANDO AVP CREDORES... ".
    
varq = "/admcom/relat/saldo-credores-avp-dia"
        + string(vdatref,"99999999") + "_" + string(time) + ".txt"
        .

if p-tipo = "PROCESSAR"
then do:

    output to value(varq).
        
    put  "Codigo;Razao Soc.;Documento;Parcela;Emissao;Vencimento;Valor;%AVP;MesAVP;DiasAVP;V alorAVP" skip.
    output close.
end.

form with frame f-tot row 14.

disp "Aguarde " v-acao vdatref with frame f-bar 1 down no-label
    width 80 color message no-box row 06.
        pause 0.

def temp-table tt-titulo no-undo like titulo
    field pctavp as dec
    field seqavp as dec
    field seqdia as dec
    field valavpdia as dec
    .
 
for each modal no-lock:
    for each estab no-lock:
    for each titulo where 
             titulo.empcod = 19 and
             titulo.titnat = yes and
             titulo.modcod = modal.modcod and
             titulo.etbcod = estab.etbcod and
             titulo.titdtemi <= vdatref and
             (titulo.titsit = "LIB" or 
                titulo.titdtpag > vdatref)  
                no-lock .

        find forne where
             forne.forcod = titulo.clifor no-lock no-error.
        if not avail forne then next.
         
        v-vtotal = v-vtotal + titulo.titvlcob.
        disp titulo.titdtemi with frame f-bar.
        pause 0.
      
        create tt-titulo.
        buffer-copy titulo to tt-titulo.
        
        if titulo.titdtven > vdatref
        then do:
            assign
                v-vencer = v-vencer + titulo.titvlcob
                .
        
            find first seq-mes where
                   seq-mes.ano = year(titulo.titdtven) and
                   seq-mes.mes = month(titulo.titdtven)
                   no-error.
            if avail seq-mes
            then do:
            
                va = 1 + ((p-tj / 100) / 30).
                vb = va.
            
                do vi = 2 to (titulo.titdtven - vdatref):
                    vb = vb * va.
                end.
            
                if p-tipo = "SIMULAR"
                then assign
                    seq-mes.avpdia = seq-mes.avpdia + 
                                (titulo.titvlcob / vb)
                    val-avpdia = val-avpdia + (titulo.titvlcob / vb)
                    seq-mes.avencer = seq-mes.avencer + titulo.titvlcob
                    .
                else if p-tipo = "PROCESSAR"
                then do transaction:
                    assign
                        tt-titulo.pctavp = p-tj /*1.80*/
                        tt-titulo.seqavp = seq-mes.seq
                        tt-titulo.seqdia = tt-titulo.titdtven - vdatref
                        tt-titulo.valavpdia = (tt-titulo.titvlcob / vb)
                        seq-mes.avpdia = seq-mes.avpdia + 
                                            tt-titulo.valavpdia
                        val-avpdia = val-avpdia + tt-titulo.valavpdia
                        seq-mes.avencer = seq-mes.avencer +            
                                                 tt-titulo.titvlcob
                        .
                     
                end.
            end.
        end.
        else assign
            v-vencido = v-vencido + titulo.titvlcob
            .

        disp v-vtotal   format ">>>,>>>,>>9.99"    label "Total Devedores"
            v-vencido format ">>>,>>>,>>9.99"     label "Total Vencidos"
            v-vencer  format ">>>,>>>,>>9.99"     label "Total Vencer" 
            val-avpdia   format ">>>,>>>,>>9.99"  label "Total AVP"
            with frame f-tot side-label 1 column 1 down 
        .

        if p-tipo = "PROCESSAR"
        then do:
            
            output to value(varq) append.    

            put  forne.forcod          format ">>>>>>>>>9"
             ";"
             forne.fornom          format "x(40)"
             ";"
             tt-titulo.titnum      format "x(15)"
             ";"
             tt-titulo.titpar      format ">>9"
             ";"
             tt-titulo.titdtemi    format "99/99/9999"
             ";"
             tt-titulo.titdtven    format "99/99/9999"
             ";"
             tt-titulo.titvlcob    format ">>>>>>>>9,99"
             ";"
             tt-titulo.pctavp      format ">>9,999999"
             ";"
             tt-titulo.seqavp      format ">>>9"
             ";"
             tt-titulo.seqdia      format ">>>9"
             ";"
             tt-titulo.valavpdia   format ">>>>>>>>9,99"
             skip.
                 
            output close.
        end.
    end.
    end.
end.

do on error undo:
find first seq-mes where
                   seq-mes.ano = year(vdatref) and
                   seq-mes.mes = 0
                   no-error.
if not avail seq-mes
then do:
        create seq-mes.
        assign
            seq-mes.ano = year(vdatref)
            seq-mes.mes = 0
            seq-mes.seq = 0
            .
end. 

seq-mes.vencido = v-vencido.
seq-mes.avencer   = v-vencer.
seq-mes.avpdia = val-avpdia.
end.

if p-tipo = "PROCESSAR" 
then do :
    do transaction:
        find tbparavp where recid(tbparavp) = p-recid 
                    exclusive-lock no-error.
        if avail tbparavp
        then
        assign
        tbparavp.val1_AVP = v-vtotal
        tbparavp.val2_AVP = v-vencido
        tbparavp.val3_AVP = v-vencer
        tbparavp.val4_AVP = val-avpdia
        tbparavp.val5_AVP = v-vencer - val-avpdia
        tbparavp.situacao = "PROCESSADO"
        .
        release tbparavp no-error.
        find current tbparavp no-lock no-error.
    end.
end.

disp v-vtotal   format ">>>,>>>,>>9.99"    label "Total Credores"
     v-vencido format ">>>,>>>,>>9.99"     label "Total Vencidos"
     v-vencer  format ">>>,>>>,>>9.99"     label "Total Vencer" 
     val-avpdia   format ">>>,>>>,>>9.99"  label "Total AVP"
     with frame f-tot side-label 1 column
     .

def var varquivo as char.

varquivo = "/admcom/relat/saldo-credores-avp-dia"
           + string(vdatref,"99999999") + "_" +
            string(time) + ".csv".
output to value(varquivo).    
for each seq-mes no-lock:
    if ano = 0 then next.
    if seq-mes.avencer = 0 and
       seq-mes.avpdia = 0
    then next.
       
    put 
        /*seq-mes.seq ";"*/
        seq-mes.ano ";"
        seq-mes.mes ";"
        seq-mes.vencido format ">>>>>>>>9.99" ";"
        seq-mes.avencer format ">>>>>>>>9.99" ";"
        seq-mes.avpdia  format ">>>>>>>>9.99"
        skip.
end.       
output close.

message color red/with "Arquivos gerados " skip 
    varquivo skip varq
    view-as alert-box.
    
    

