def input parameter p-tipo  as char.
def input parameter p-recid as recid.

def new shared temp-table tt-principal no-undo
    field clifor like titulo.clifor
    field titnum like titulo.titnum
    field titvlcob like titulo.titvlcob
    field titdes like titulo.titdes
    field principal as dec
    field acrescimo as dec
    index ttp1 clifor titnum.

def temp-table seq-mes no-undo
    field ano as int
    field mes as int
    field seq as int
    field avpdia as dec
    field vencido as dec
    field avencer as dec
    field acrescimo as dec
    field principal as dec
    index i1 ano mes.
 
def var vtitdtven like titulo.titdtven.

def var v-vtotal as dec.
def var v-vencido as dec.
def var v-vencer as dec.
def var v-principal as dec.
def var v-acrescimo as dec.
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

/*
if p-tipo = "PROCESSAR"
then do:
    output to value(varq).
    disp with frame f-top.
    put skip.    
    put  "Codigo;Nome;Documento;Parcela;Emissao;Vencimento;Valor;%AVP;MesAVP;DiasAVP;ValorAVP" skip.
    output close.
end.
*/

def temp-table tt-cli no-undo
    field clicod like clien.clico
    field clinom like clien.clinom
    field cpf as char format "x(16)"
    field titdtven like titulo.titdtven
    field titnum like titulo.titnum
    field valor as dec
    field situacao as int
    index i1 clicod titdtven
    index i2 situacao clinom titdtven
    .

/*******************
def temp-table tt-vencido 
    field clicod like clien.clico
    field clinom like clien.clinom
    field cpf as char format "x(16)"
    field titdtven like titulo.titdtven
    field titnum like titulo.titnum
    field valor as dec
    field situacao as int
    index i clicod
    index i1 clicod titdtven
    index i2 situacao clinom titdtven
    .

def temp-table tt-vencer
    field clicod like clien.clico
    field clinom like clien.clinom
    field cpf as char format "x(16)"
    field titdtven like titulo.titdtven
    field titnum like titulo.titnum
    field valor as dec
    field principal as dec
    field acrescimo as dec
    field situacao as int
    index i1 clicod titdtven
    index i2 situacao clinom titdtven
    .
*****************/    

form with frame f-tot row 14.

disp "Referencia = " vdatref with frame f-top 1 down no-label
    width 80 color normal no-box row 05.
        pause 0.

if vdtiemis <> ?
then disp "Emissao >= " vdtiemis no-label with frame f-top.
if vdtfemis <> ?
then disp "Emissao <= " vdtfemis no-label with frame f-top.           

pause 0.

def var varq-cli as char.

disp v-acao with frame f-bar 1 down no-label
    width 80 color message no-box row 06.
        pause 0.
        
def temp-table tt-titsalctb no-undo like SC012015.

def var vhora as int.
vhora = time.

if vdatref <= 12/31/15
then return.
/*if vdatref = 01/31/15
then run avp-012015.
else*/ if vdatref >= 12/31/15
then run avp-2016.
else run avp-2015.

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
seq-mes.principal = v-principal.
seq-mes.acrescimo = v-acrescimo.
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

    varq-cli = "/admcom/relat/saldo-devedores-avp-vencidos"
            + string(vdatref,"99999999") + "_" + string(time) + ".txt"
                    .
    output to value(varq-cli).
    disp with frame f-top.
    put skip.
    put  "Codigo;Nome;CPF;Vencimento;Valor" skip.
 
    for each tt-cli use-index i2 where
                tt-cli.situacao = 1 no-lock:
        put tt-cli.clicod format ">>>>>>>>>9"
            ";"
            tt-cli.clinom format "x(50)"
            ";"
            tt-cli.cpf    format "x(16)"
            ";"
            tt-cli.titdtven
            ";"
            tt-cli.valor  format ">>>,>>>,>>9.99"
            skip.
    end. 

    output close.

    varq-cli = "/admcom/relat/saldo-devedores-avp-vencer"
            + string(vdatref,"99999999") + "_" + string(time) + ".txt"
                    .
    output to value(varq-cli).
    disp with frame f-top.
    put skip.
    put  "Codigo;Nome;CPF;Vencimento;Valor" skip.
 
    for each tt-cli use-index i2 where
                tt-cli.situacao = 2 no-lock:
        put tt-cli.clicod format ">>>>>>>>>9"
            ";"
            tt-cli.clinom format "x(50)"
            ";"
            tt-cli.cpf    format "x(16)"
            ";"
            tt-cli.titdtven
            ";"
            tt-cli.valor  format ">>>,>>>,>>9.99"
            skip.
    end. 

    output close.
end.

if vdatref = 05/31/15
then v-vencido = v-vencido - 4676534.05.
if vdatref = 06/30/15
then v-vencido = v-vencido - 9377438.21.
if vdatref = 07/31/15
then v-vencido = v-vencido - 68556.29.
if vdatref = 08/31/15
then v-vencido = v-vencido - 250316.74.
if vdatref = 09/30/15
then v-vencido = v-vencido - 34723.92.
if vdatref = 10/31/15
then v-vencido = v-vencido - 18400.00.
  
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
def var prin-cipal as char.
def var acres-cimo as char.

varquivo = "/admcom/relat/saldo-devedores-avp-dia"
           + string(vdatref,"99999999") + "_" +
            string(time) + ".csv".

output to value(varquivo).    

disp with frame f-top .
put skip.
put "Ano;Mes;Vencido;Vencer;Valor AVP;Principal;Acrescimo" skip.

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
        if vdatref = 07/31/15
        then seq-mes.vencido = seq-mes.vencido - 68556.29.
        if vdatref = 08/31/15
        then seq-mes.vencido = seq-mes.vencido - 250316.74.
        if vdatref = 09/30/15
        then seq-mes.vencido = seq-mes.vencido - 34723.92.
        if vdatref = 10/31/15
        then seq-mes.vencido = seq-mes.vencido - 18400.00.
    end.
    
    assign
        ven-cido = string(seq-mes.vencido,">>>>>>>>9.99")
        ven-cido = replace(ven-cido,".",",")
        ven-cer  = string(seq-mes.avencer,">>>>>>>>9.99")
        ven-cer  = replace(ven-cer,".",",")
        avp-dia  = string(seq-mes.avpdia,">>>>>>>>9.99")
        avp-dia  = replace(avp-dia,".",",")
        prin-cipal = string(seq-mes.principal,">>>>>>>>9.99")
        prin-cipal = replace(prin-cipal,".",",")
        acres-cimo = string(seq-mes.acrescimo,">>>>>>>>9.99")
        acres-cimo = replace(acres-cimo,".",",")
        .
    put 
        seq-mes.ano format ">>>9" ";"
        seq-mes.mes ";"
        ven-cido format "x(15)" ";"
        ven-cer  format "x(15)" ";"
        avp-dia  format "x(15)" ";"
        prin-cipal format "x(15)" ";"
        acres-cimo format "x(15)" 
        skip.
end.       
output close.

def var p-seguro as dec.
def var p-principal as dec.
def var p-acrescimo as dec.
def var p-juros as dec.
def var p-crepes as dec.

message color red/with "Arquivos gerados " skip 
    varquivo skip varq
    view-as alert-box.
    
def var v22 as dec.
    
procedure avp-2016:

    def var v-reg as int.
    for each SC2015 use-index INDX2 where 
                        SC2015.titnat = no and
                        SC2015.titdtemi <= vdatref and
                       ((SC2015.titdtpag > vdatref and
                      SC2015.titsit = "PAG") or
                      SC2015.titsit = "LIB")
                      no-lock:
        
        if SC2015.titdtmovref > vdatref or
           SC2015.titdtmovref = ?
        then next.
        /*
        find clien where
             clien.clicod = SC2015.clifor no-lock no-error.
        if not avail clien 
        then next.
        */
        if vdtiemis <> ? and
           SC2015.titdtemi < vdtiemis
        then next.
        if vdtfemis <> ? and
           SC2015.titdtemi > vdtfemis
        then next.
  
        v-reg = v-reg + 1.
        if v-reg mod 10000 = 0
        then disp "Registros processados " v-reg 
                    string(time - vhora,"hh:mm:ss")
                    with frame f-bar.
        pause 0.
         
        v-vtotal = v-vtotal + SC2015.titvlcob.
        /*
        create tt-titsalctb.
        buffer-copy SC2015 to tt-titsalctb.
        */
        if SC2015.titdtvenaux <> ?
        then vtitdtven = SC2015.titdtvenaux.
        else vtitdtven = SC2015.titdtven.

            assign
                p-principal = 0
                p-acrescimo = 0
                p-seguro = 0
                p-juros = 0
                p-crepes = 0.
            find first tt-principal where
                       tt-principal.clifor = sc2015.clifor and
                       tt-principal.titnum = sc2015.titnum 
                       no-lock no-error.
            if not avail tt-principal
            then do:
                create tt-principal.
                assign
                    tt-principal.clifor = sc2015.clifor
                    tt-principal.titnum = sc2015.titnum
                    tt-principal.titvlcob = sc2015.titvlcob
                    tt-principal.titdes  = sc2015.titdes
                    .
                find titulo where titulo.empcod = sc2015.empcod and
                                  titulo.titnat = sc2015.titnat and
                                  titulo.modcod = sc2015.modcod and
                                  titulo.etbcod = sc2015.etbcod and
                                  titulo.clifor = sc2015.clifor and
                                  titulo.titnum = sc2015.titnum and
                                  titulo.titpar = 2
                                  no-lock no-error.
                if avail titulo
                then do:
                                  
                    run retorna-principal-acrescimo-titulo.p
                                        (input recid(titulo),
                                         output p-principal,
                                         output p-acrescimo,
                                         output p-seguro,
                                         output p-crepes).
                    if  p-principal <= 0 or
                            p-acrescimo <= 0
                    then assign
                                 p-principal = SC2015.titvlcob
                                 p-acrescimo = 0
                                 .
                    assign
                            tt-principal.principal = p-principal
                            tt-principal.acrescimo = p-acrescimo
                            .
                end.
                else assign
                         p-principal = SC2015.titvlcob
                         p-acrescimo = 0
                         tt-principal.principal = p-principal
                         tt-principal.acrescimo = p-acrescimo
                         .          
            end.
            else assign
                    p-principal = tt-principal.principal
                    p-acrescimo = tt-principal.acrescimo
                    .

            if p-principal >= SC2015.titvlcob
            then assign
                    p-principal = SC2015.titvlcob
                    p-acrescimo = 0.

            if (p-principal + p-acrescimo) > SC2015.titvlcob
            then p-principal = p-principal - 
                ((p-principal + p-acrescimo) - SC2015.titvlcob).
            else if (p-principal + p-acrescimo) < SC2015.titvlcob     
                then p-principal = p-principal + 
                    (SC2015.titvlcob - (p-principal + p-acrescimo)).
            assign
                v-principal = v-principal + p-principal
                v-acrescimo = v-acrescimo + p-acrescimo
                .
        
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
                else if p-tipo = "PROCESSAR"
                then do:
                    assign
                        /*tt-titsalctb.pctavp = p-tj /*1.80*/
                        tt-titsalctb.seqavp = seq-mes.seq
                        tt-titsalctb.seqdia = vtitdtven - vdatref
                        tt-titsalctb.valavpdia = (tt-titsalctb.titvlcob / vb)
                        */
                        seq-mes.avpdia = seq-mes.avpdia + 
                                            tt-titsalctb.valavpdia
                        val-avpdia = val-avpdia + tt-titsalctb.valavpdia
                        seq-mes.avencer = seq-mes.avencer +            
                                                 tt-titsalctb.titvlcob
                        .
                     
                end.
                assign
                    seq-mes.principal = seq-mes.principal + p-principal
                    seq-mes.acrescimo = seq-mes.acrescimo + p-acrescimo.
            end.
            /*********************
            find first tt-vencer where
                       tt-vencer.clicod = sc2015.clifor and
                       tt-vencer.titdtven = vtitdtven
                       no-error.
            if not avail tt-vencer
            then do:
                create tt-vencer.
                assign
                    tt-vencer.clicod = sc2015.clifor
                    tt-vencer.clinom = ""
                    tt-vencer.cpf = ""
                    tt-vencer.titdtven = vtitdtven
                    .
            end.
            tt-vencer.valor = tt-vencer.valor + SC2015.titvlcob.
            
            assign
                tt-vencer.acrescimo = tt-vencer.acrescimo + p-acrescimo.
                tt-vencer.principal = tt-vencer.principal + p-principal.
            *************************/
        end.
        else do:
            assign
                v-vencido = v-vencido + SC2015.titvlcob .

            /*******************
            find first tt-vencido where
                       tt-vencido.clicod = sc2015.clifor 
                       no-error.
            if not avail tt-vencido
            then do:
                create tt-vencido.
                assign
                    tt-vencido.clicod = sc2015.clifor
                    tt-vencido.clinom = ""
                    tt-vencido.cpf = ""
                    .
            end.
            tt-vencido.valor = tt-vencido.valor + SC2015.titvlcob.
            ********************/
            
         end.

        if v-reg mod 10000 = 0
        then
        disp v-vtotal   format ">>>,>>>,>>9.99"    label "Total Devedores"
            v-vencido format ">>>,>>>,>>9.99"     label "Total Vencidos"
            v-vencer  format ">>>,>>>,>>9.99"     label "Total Vencer" 
            val-avpdia   format ">>>,>>>,>>9.99"  label "Total AVP"
            with frame f-tot side-label 1 column 1 down 
        .

        if p-tipo = "PROCESSAR"
        then do:

            find first tt-cli where
                       tt-cli.clicod = sc2015.clifor and
                       tt-cli.titdtven = vtitdtven
                       no-error.
            if not avail tt-cli
            then do:
                create tt-cli.
                assign
                    tt-cli.clicod = sc2015.clifor
                    tt-cli.clinom = ""
                    tt-cli.cpf = ""
                    tt-cli.titdtven = vtitdtven
                    .
                if vtitdtven > vdatref
                then tt-cli.situacao = 2.
                else tt-cli.situacao = 1.
            end.
            tt-cli.valor = tt-cli.valor + SC2015.titvlcob.
        end.
    end.
end procedure.

/*********************
procedure avp-2015:

    def var v-reg as int.
    
    for each SC2015 use-index INDX2  where 
                        SC2015.titnat = no and
                            SC2015.titdtemi <= vdatref
                and  ((SC2015.titdtpag > vdatref and
                      SC2015.titsit = "PAG") or
                      SC2015.titsit = "LIB")
                no-lock.
        
        if vdtfemis = 12/31/14
        then.
        else if SC2015.titsit begins "EXC" /*= "EXCSALDO"*/
        then do:
            if vdatref = 01/31/16
            and v22 + sc2015.titvlcob <= 700829.70
            then v22 = v22 + sc2015.titvlcob.
            else next.
        end.
        if vdatref = 07/31/15 and
           sc2015.cobcod = 22 and
           SC2015.titdtven > 08/20/15 
        then next.
        if vdatref = 08/31/15 and
           sc2015.cobcod = 22 and
           SC2015.titdtven > 02/09/15
        then next.    
        if vdatref = 09/30/15 and
           sc2015.cobcod = 22 and
           SC2015.titdtven > 01/01/15
        then next.
        if vdatref = 10/31/15 and
           sc2015.cobcod = 22 and
           SC2015.titdtven > 07/29/16 /*07/31/16*/
        then next.
        if vdatref = 11/30/15 and
           sc2015.cobcod = 22 and
           SC2015.titdtven > 11/06/14 
        then do:
            if v22 + sc2015.titvlcob <= 244377.98
            then v22 = v22 + sc2015.titvlcob.
            else next.
        end.
        /*
        if vdatref = 12/31/15 and
           sc2015.cobcod = 22 and
           SC2015.titdtven > 12/31/15 and
           v22 + sc2015.titvlcob <= 1650369.55 /*1617393.12*/
        then do:
            v22 = v22 + sc2015.titvlcob.
            next.
        end.   
        */
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
        
        find clien where
             clien.clicod = SC2015.clifor no-lock no-error.
        if not avail clien
        then /*find clien where
                  clien.clicod = 1 no-lock no-error.
        if not avail clien 
        then*/ next.
         
        v-vtotal = v-vtotal + SC2015.titvlcob.
        /*
        create tt-titsalctb.
        buffer-copy SC2015 to tt-titsalctb.
        */
        if SC2015.titdtvenaux <> ?
        then vtitdtven = SC2015.titdtvenaux.
        else vtitdtven = SC2015.titdtven.
        
        if vtitdtven > vdatref
        then do:
            assign
                v-vencer = v-vencer + SC2015.titvlcob.
        
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
                else if p-tipo = "PROCESSAR"
                then do /*transaction*/:
                    assign
                        /*tt-titsalctb.pctavp = p-tj /*1.80*/
                        tt-titsalctb.seqavp = seq-mes.seq
                        tt-titsalctb.seqdia = vtitdtven - vdatref
                        tt-titsalctb.valavpdia = (tt-titsalctb.titvlcob / vb)*/
                        seq-mes.avpdia = seq-mes.avpdia + 
                                            tt-titsalctb.valavpdia
                        val-avpdia = val-avpdia + tt-titsalctb.valavpdia
                        seq-mes.avencer = seq-mes.avencer +            
                                                 tt-titsalctb.titvlcob
                        .
                     
                end.
            end.
            find first tt-vencer where
                       tt-vencer.clicod = clien.clicod and
                       tt-vencer.titdtven = vtitdtven
                       no-error.
            if not avail tt-vencer
            then do:
                create tt-vencer.
                assign
                    tt-vencer.clicod = clien.clicod
                    tt-vencer.clinom = if clien.clicod = 1
                            then "1" else clien.clinom
                    tt-vencer.cpf = clien.ciccgc
                    tt-vencer.titdtven = vtitdtven
                    .
            end.
            tt-vencer.valor = tt-vencer.valor + SC2015.titvlcob.
         end.
        else do:
            assign
                v-vencido = v-vencido + SC2015.titvlcob .

            find first tt-vencido where
                       tt-vencido.clicod = clien.clicod 
                       no-error.
            if not avail tt-vencido
            then do:
                create tt-vencido.
                assign
                    tt-vencido.clicod = clien.clicod
                    tt-vencido.clinom = if clien.clicod = 1
                            then "1" else clien.clinom
                    tt-vencido.cpf = clien.ciccgc
                    .
            end.
            tt-vencido.valor = tt-vencido.valor + SC2015.titvlcob.
         end.

        if v-reg mod 10000 = 0
        then
        disp v-vtotal   format ">>>,>>>,>>9.99"    label "Total Devedores"
            v-vencido format ">>>,>>>,>>9.99"     label "Total Vencidos"
            v-vencer  format ">>>,>>>,>>9.99"     label "Total Vencer" 
            val-avpdia   format ">>>,>>>,>>9.99"  label "Total AVP"
            with frame f-tot side-label 1 column 1 down 
        .

        if p-tipo = "PROCESSAR"
        then do:
            /****
            output to value(varq) append.    

            put  clien.clicod          format ">>>>>>>>>9"
             ";"
             clien.clinom          format "x(40)"
             ";"
             tt-titsalctb.titnum      format "x(15)"
             ";"
             tt-titsalctb.titpar      format ">>9"
             ";"
             tt-titsalctb.titdtemi    format "99/99/9999"
             ";"
             vtitdtven    format "99/99/9999"
             ";"
             tt-titsalctb.titvlcob    format ">>>>>>>>9.99"
             ";"
             tt-titsalctb.pctavp      format ">>9.999999"
             ";"
             tt-titsalctb.seqavp      format ">>>9"
             ";"
             tt-titsalctb.seqdia      format ">>>9"
             ";"
             tt-titsalctb.valavpdia   format ">>>>>>>>9.99"
             skip.
                 
            output close.
            ***/

            find first tt-cli where
                       tt-cli.clicod = clien.clicod and
                       tt-cli.titdtven = vtitdtven
                       no-error.
            if not avail tt-cli
            then do:
                create tt-cli.
                assign
                    tt-cli.clicod = clien.clicod
                    tt-cli.clinom = if clien.clicod = 1
                            then "1" else clien.clinom
                    tt-cli.cpf = clien.ciccgc
                    tt-cli.titdtven = vtitdtven
                    .
                if vtitdtven > vdatref
                then tt-cli.situacao = 2.
                else tt-cli.situacao = 1.
            end.
            tt-cli.valor = tt-cli.valor + SC2015.titvlcob.
        end.
    end.
end procedure.

procedure avp-012015:

    def var v-reg as int.
    
    for each SC012015 where SC012015.titdtemi <= vdatref
                and (SC012015.titsit = "LIB" or
                     SC012015.titdtpag > vdatref)
                no-lock.
        
        if vdtfemis = 12/31/14
        then.
        else if SC012015.titsit = "EXCSALDO"
        then next.

        v-reg = v-reg + 1.
        if v-reg mod 10000 = 0
        then disp "Registros processados " v-reg 
                    string(time - vhora,"hh:mm:ss")
                    with frame f-bar.
        pause 0.
        if vdtiemis <> ? and
           SC012015.titdtemi < vdtiemis
        then next.
        if vdtfemis <> ? and
           SC012015.titdtemi > vdtfemis
        then next.
        
        find clien where
             clien.clicod = SC012015.clifor no-lock no-error.
        if not avail clien
        then find clien where
                  clien.clicod = 1 no-lock no-error.
        if not avail clien 
        then next.
         
        v-vtotal = v-vtotal + SC012015.titvlcob.

        create tt-titsalctb.
        buffer-copy SC012015 to tt-titsalctb.
        
        if SC012015.titdtvenaux <> ?
        then vtitdtven = SC012015.titdtvenaux.
        else vtitdtven = SC012015.titdtven.
        
        if vtitdtven > vdatref
        then do:
            assign
                v-vencer = v-vencer + SC012015.titvlcob
                .
        
            find first seq-mes where
                   seq-mes.ano = year(vtitdtven) and
                   seq-mes.mes = month(vtitdtven)
                   no-error.
            if avail seq-mes
            then do:
            
                if p-tj = 0
                then run cal-txjuro-contrato.p(input int(SC012015.titnum),
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
                                (SC012015.titvlcob / vb)
                    val-avpdia = val-avpdia + (SC012015.titvlcob / vb)
                    seq-mes.avencer = seq-mes.avencer + SC012015.titvlcob
                    .
                else if p-tipo = "PROCESSAR"
                then do transaction:
                    assign
                        tt-titsalctb.pctavp = p-tj /*1.80*/
                        tt-titsalctb.seqavp = seq-mes.seq
                        tt-titsalctb.seqdia = vtitdtven - vdatref
                        tt-titsalctb.valavpdia = (tt-titsalctb.titvlcob / vb)
                        seq-mes.avpdia = seq-mes.avpdia + 
                                            tt-titsalctb.valavpdia
                        val-avpdia = val-avpdia + tt-titsalctb.valavpdia
                        seq-mes.avencer = seq-mes.avencer +            
                                                 tt-titsalctb.titvlcob
                        .
                     
                end.
            end.
        end.
        else assign
            v-vencido = v-vencido + SC012015.titvlcob
            .

        if v-reg mod 10000 = 0
        then
        disp v-vtotal   format ">>>,>>>,>>9.99"    label "Total Devedores"
            v-vencido format ">>>,>>>,>>9.99"     label "Total Vencidos"
            v-vencer  format ">>>,>>>,>>9.99"     label "Total Vencer" 
            val-avpdia   format ">>>,>>>,>>9.99"  label "Total AVP"
            with frame f-tot side-label 1 column 1 down 
        .

        if p-tipo = "PROCESSAR"
        then do:
            
            output to value(varq) append.    

            put  clien.clicod          format ">>>>>>>>>9"
             ";"
             clien.clinom          format "x(40)"
             ";"
             tt-titsalctb.titnum      format "x(15)"
             ";"
             tt-titsalctb.titpar      format ">>9"
             ";"
             tt-titsalctb.titdtemi    format "99/99/9999"
             ";"
             vtitdtven    format "99/99/9999"
             ";"
             tt-titsalctb.titvlcob    format ">>>>>>>>9.99"
             ";"
             tt-titsalctb.pctavp      format ">>9.999999"
             ";"
             tt-titsalctb.seqavp      format ">>>9"
             ";"
             tt-titsalctb.seqdia      format ">>>9"
             ";"
             tt-titsalctb.valavpdia   format ">>>>>>>>9.99"
             skip.
                 
            output close.
        end.
        do transaction:
        create SC022015.
        buffer-copy SC012015 to SC022015.
        end.
    end.
end procedure.

procedure avp-022015:

    def var v-reg as int.
    
    for each SC022015 where SC022015.titdtemi <= vdatref
                and (SC022015.titsit = "LIB" or
                     SC022015.titdtpag > vdatref)
                no-lock.
        
        if vdtfemis = 12/31/14
        then.
        else if SC022015.titsit = "EXCSALDO"
        then next.

        v-reg = v-reg + 1.
        if v-reg mod 10000 = 0
        then disp "Registros processados " v-reg 
                    string(time - vhora,"hh:mm:ss")
                    with frame f-bar.
        pause 0.
        if vdtiemis <> ? and
           SC022015.titdtemi < vdtiemis
        then next.
        if vdtfemis <> ? and
           SC022015.titdtemi > vdtfemis
        then next.
        
        find clien where
             clien.clicod = SC022015.clifor no-lock no-error.
        if not avail clien
        then find clien where
                  clien.clicod = 1 no-lock no-error.
        if not avail clien 
        then next.
         
        v-vtotal = v-vtotal + SC022015.titvlcob.

        create tt-titsalctb.
        buffer-copy SC022015 to tt-titsalctb.
        
        if SC022015.titdtvenaux <> ?
        then vtitdtven = SC022015.titdtvenaux.
        else vtitdtven = SC022015.titdtven.
        
        if vtitdtven > vdatref
        then do:
            assign
                v-vencer = v-vencer + SC022015.titvlcob
                .
        
            find first seq-mes where
                   seq-mes.ano = year(vtitdtven) and
                   seq-mes.mes = month(vtitdtven)
                   no-error.
            if avail seq-mes
            then do:
            
                if p-tj = 0
                then run cal-txjuro-contrato.p(input int(SC022015.titnum),
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
                                (SC022015.titvlcob / vb)
                    val-avpdia = val-avpdia + (SC022015.titvlcob / vb)
                    seq-mes.avencer = seq-mes.avencer + SC022015.titvlcob
                    .
                else if p-tipo = "PROCESSAR"
                then do transaction:
                    assign
                        tt-titsalctb.pctavp = p-tj /*1.80*/
                        tt-titsalctb.seqavp = seq-mes.seq
                        tt-titsalctb.seqdia = vtitdtven - vdatref
                        tt-titsalctb.valavpdia = (tt-titsalctb.titvlcob / vb)
                        seq-mes.avpdia = seq-mes.avpdia + 
                                            tt-titsalctb.valavpdia
                        val-avpdia = val-avpdia + tt-titsalctb.valavpdia
                        seq-mes.avencer = seq-mes.avencer +            
                                                 tt-titsalctb.titvlcob
                        .
                     
                end.
            end.
        end.
        else assign
            v-vencido = v-vencido + SC022015.titvlcob
            .

        if v-reg mod 10000 = 0
        then
        disp v-vtotal   format ">>>,>>>,>>9.99"    label "Total Devedores"
            v-vencido format ">>>,>>>,>>9.99"     label "Total Vencidos"
            v-vencer  format ">>>,>>>,>>9.99"     label "Total Vencer" 
            val-avpdia   format ">>>,>>>,>>9.99"  label "Total AVP"
            with frame f-tot side-label 1 column 1 down 
        .

        if p-tipo = "PROCESSAR"
        then do:
            
            output to value(varq) append.    

            put  clien.clicod          format ">>>>>>>>>9"
             ";"
             clien.clinom          format "x(40)"
             ";"
             tt-titsalctb.titnum      format "x(15)"
             ";"
             tt-titsalctb.titpar      format ">>9"
             ";"
             tt-titsalctb.titdtemi    format "99/99/9999"
             ";"
             vtitdtven    format "99/99/9999"
             ";"
             tt-titsalctb.titvlcob    format ">>>>>>>>9.99"
             ";"
             tt-titsalctb.pctavp      format ">>9.999999"
             ";"
             tt-titsalctb.seqavp      format ">>>9"
             ";"
             tt-titsalctb.seqdia      format ">>>9"
             ";"
             tt-titsalctb.valavpdia   format ">>>>>>>>9.99"
             skip.
                 
            output close.
        end.
    end.
end procedure.
*******************/
