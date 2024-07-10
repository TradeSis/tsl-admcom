

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
 
def var vtitdtven like titulo.titdtven.

def var v-vtotal as dec.
def var v-vencido as dec.
def var v-vencer as dec.
def var val-avpdia as dec.

def var vdatref as date.
def var vdatref2 as date.
def var vdtiemis as date.
def var vdtfemis as date.
def var vdata as date.
def var vseq as int.

find tbparavp where recid(tbparavp) = p-recid no-lock no-error.
if not avail tbparavp
then return.

assign
    vdatref = tbparavp.datref
    vdatref2 = tbparavp.datref2
    vdtiemis = tbparavp.dtiemis
    vdtfemis = tbparavp.dtfemis
    .

find first indic where
           indic.indcod = tbparavp.indcod
           no-lock no-error.
if not avail indic
then return.


find last indice where
           indice.indcod = indic.indcod and
           indice.inddat <= tbparavp.datref and
           indice.indvalor > 0
           no-lock no-error.
if not avail indice
then do:
    message color red/with
    "Falta indicador para data" tbparavp.datref "." skip
    "Inpossivel continuar."
    view-as alert-box.
    
    return.
end.

def var p-tj like indice.indvalor.
p-tj = indice.indvalor.

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
THEN v-acao = "SIMULANDO AVP DEVEDORES... ".
else if p-tipo = "PROCESSAR"
    then v-acao = "PROCESSANDO AVP DEVEDORES... ".
    
varq = "/admcom/relat/saldo-devedores-avp-dia"
        + string(vdatref,"99999999") + "_" + string(time) + ".txt"
        .

if p-tipo = "PROCESSAR"
then do:
    output to value(varq).
    disp with frame f-top.
    put skip.    
    put  "Codigo;Nome;Documento;Parcela;Emissao;Vencimento;Valor;%AVP;MesAVP;DiasAVP;ValorAVP" skip.
    output close.
end.

form with frame f-tot row 14.

disp "Referencia = " vdatref with frame f-top 1 down no-label
    width 80 color normal no-box row 05.
        pause 0.

if vdtiemis <> ?
then disp "Emissao >= " vdtiemis no-label with frame f-top.
if vdtfemis <> ?
then disp "Emissao <= " vdtfemis no-label with frame f-top.           

pause 0.

disp v-acao with frame f-bar 1 down no-label
    width 80 color message no-box row 06.
        pause 0.

def temp-table tt-titsalctb no-undo like SC2015.

def var vhora as int.
vhora = time.

run avp-2015.

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
if vdatref = 05/31/15
then v-vencido = v-vencido - 4676534.05.
if vdatref = 06/30/15
then v-vencido = v-vencido - 9377438.21.

disp v-vtotal   format ">>>,>>>,>>9.99"    label "Total Devedores"
     v-vencido format ">>>,>>>,>>9.99"     label "Total Vencidos"
     v-vencer  format ">>>,>>>,>>9.99"     label "Total Vencer" 
     val-avpdia   format ">>>,>>>,>>9.99"  label "Total AVP"
     with frame f-tot side-label 1 column
     .

def var ven-cido as char.
def var ven-cer  as char.
def var avp-dia  as char.
def var varquivo as char.

varquivo = "/admcom/relat/saldo-devedores-avp-dia"
           + string(vdatref,"99999999") + "_" +
            string(time) + ".csv".

output to value(varquivo).    

disp with frame f-top .
put skip.
put "Ano;Mes;Vencido;Vencer;Valor AVP" skip.

for each seq-mes no-lock:
    if ano = 0 then next.
    if seq-mes.avencer = 0 and
       seq-mes.avpdia = 0
    then next.
    
    if seq-mes.vencido > 0
    then do:
        if vdatref = 05/31/15
        then seq-mes.vencido = seq-mes.vencido - 4676534.05.
        if vdatref = 06/30/15
        then seq-mes.vencido = seq-mes.vencido - 9377438.21.
    end.
    
    assign
        ven-cido = string(seq-mes.vencido,">>>>>>>>9.99")
        ven-cido = replace(ven-cido,".",",")
        ven-cer  = string(seq-mes.avencer,">>>>>>>>9.99")
        ven-cer  = replace(ven-cer,".",",")
        avp-dia  = string(seq-mes.avpdia,">>>>>>>>9.99")
        avp-dia  = replace(avp-dia,".",",")
        .
    put 
        /*seq-mes.seq ";"*/
        seq-mes.ano format ">>>9" ";"
        seq-mes.mes ";"
        /*replace((seq-mes.vencido,">>>>>>>>9.99"),".",",") ";"
        replace((seq-mes.avencer,">>>>>>>>9.99"),".",",") ";"
        replace((seq-mes.avpdia,">>>>>>>>9.99"),".",",")
        */
        ven-cido format "x(15)" ";"
        ven-cer  format "x(15)" ";"
        avp-dia  format "x(15)" 
        skip.
end.       
output close.

message color red/with "Arquivos gerados " skip 
    varquivo skip varq
    view-as alert-box.
    
procedure avp-2015:

    def var v-reg as int.
    
    for each SC2015 where SC2015.titdtemi <= vdatref
                and (SC2015.titsit = "LIB" or
                     SC2015.titdtpag > vdatref)
                no-lock.

        if SC2015.titsit begins "EXC"
        then next.
     
        v-reg = v-reg + 1.
        if v-reg mod 10000 = 0
        then disp "Registros processados " v-reg 
                    string(time - vhora,"hh:mm:ss")
                    with frame f-bar.
        pause 0.
        if vdtiemis <> ? and
           SC2015.titdtemi < vdtiemis
        then next.
        if vdtfemis <> ? and
           SC2015.titdtemi > vdtfemis
        then next.
        
        find first clien where
             clien.clicod = SC2015.clifor no-lock no-error.
        if not avail clien
        then first find clien where
                  clien.clicod = 1 no-lock no-error.
        if not avail clien 
        then next.
         
        v-vtotal = v-vtotal + SC2015.titvlcob.

        if SC2015.titdtvenaux <> ?
        then vtitdtven = SC2015.titdtvenaux.
        else vtitdtven = SC2015.titdtven.
        
        if vtitdtven > vdatref
        then do:
            assign
                v-vencer = v-vencer + SC2015.titvlcob
                .
        
            find first seq-mes where
                   seq-mes.ano = year(vtitdtven) and
                   seq-mes.mes = month(vtitdtven)
                   no-error.
            if avail seq-mes
            then do:
            
                if p-tj = 0
                then run cal-txjuro-contrato.p(input int(SC2015.titnum),
                                           output p-tj).
            
                                           
                /*
                va = 1 + ((1.8 / 100) / 30).
                */
            
                va = 1 + ((p-tj / 100) / 30).
                vb = va.
            
                do vi = 2 to (vtitdtven - vdatref):
                    vb = vb * va.
                end.
            
                if p-tipo = "SIMULAR"
                then assign
                    seq-mes.avpdia = seq-mes.avpdia + 
                                (SC2015.titvlcob / vb)
                    val-avpdia = val-avpdia + (SC2015.titvlcob / vb)
                    seq-mes.avencer = seq-mes.avencer + SC2015.titvlcob
                    .
            end.
        end.
        else assign
            v-vencido = v-vencido + SC2015.titvlcob
            .

        if v-reg mod 10000 = 0
        then
        disp v-vtotal   format ">>>,>>>,>>9.99"    label "Total Devedores"
            v-vencido format ">>>,>>>,>>9.99"     label "Total Vencidos"
            v-vencer  format ">>>,>>>,>>9.99"     label "Total Vencer" 
            val-avpdia   format ">>>,>>>,>>9.99"  label "Total AVP"
            with frame f-tot side-label 1 column 1 down 
        .

    end.

end procedure.

