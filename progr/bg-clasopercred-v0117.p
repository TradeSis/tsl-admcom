{admcab.i}

{retorna-pacnv.i new}

def input parameter vdatref as date.

def var a-dia as int extent 20.
def var b-dia as int extent 20.
def var v-risco as char extent 20.
def var v-pct as dec extent 20.
def var v-vencido as dec extent 20.

def var v-principal as dec.
def var v-acrescimo as dec.

def var pven-9999 as dec.
def var pven-5400 as dec.
def var pven-1800 as dec.
def var pven-1080 as dec.
def var pven-360  as dec.
def var pven-90   as dec.

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
 
find first indic where
           indic.indcod = 1
           no-lock no-error.
if not avail indic
then do:
    message color red/with
    "Indicador de juro não cadatrado."
    view-as alert-box.
    return.
end.    
find last indice where
           indice.indcod = indic.indcod and
           indice.inddat <= vdatref and
           indice.indvalor > 0
           no-lock no-error.
if not avail indice
then do:
    message color red/with
    "Falta indicador para data" vdatref "." skip
    "Inpossivel continuar."
    view-as alert-box.
    
    return.
end.

def var p-tj like indice.indvalor.
p-tj = indice.indvalor.
def var vdata as date.
def var vseq as int.
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

def temp-table tt-con no-undo
    field etbcod as int
    field clicod as int
    field titnum as char
    field titdtemi as date
    field qtdpar as int
    field risco  as char
    field vencido as dec
    field vencer  as dec
    field valaberto  as dec
    field qtdparab   as int
    field valtotal   as dec
    field qtdparco   as int
    field cobcod     as int 
    field principal  as dec
    field acrescimo  as dec
    field ven-9999  as dec
    field ven-5400  as dec
    field ven-1800  as dec
    field ven-1080  as dec
    field ven-360   as dec
    field ven-90    as dec
    index i1 etbcod clicod titnum 
    index i2 risco cobcod
    index i3 cobcod.

def temp-table tt-cli no-undo
    field clicod as int
    field cobcod as int
    field catcod as int
    field modcod as char
    field qtdpar as int
    field risco  as char
    field vencido as dec
    field vencer  as dec
    field valaberto  as dec
    field qtdparab   as int
    field valtotal   as dec
    field qtdparco   as int
    field principal  as dec
    field acrescimo  as dec
    field ven-9999  as dec
    field ven-5400  as dec
    field ven-1800  as dec
    field ven-1080  as dec
    field ven-360   as dec
    field ven-90    as dec
    index i1 clicod cobcod catcod modcod 
    index i2 risco
    . 

def temp-table tt-clicob no-undo
    field clicod as int
    field cobcod as int
    field qtdpar as int
    field risco  as char
    field vencido as dec
    field vencer  as dec
    field valaberto  as dec
    field qtdparab   as int
    field valtotal   as dec
    field qtdparco   as int
    field principal  as dec
    field acrescimo  as dec
    field ven-9999  as dec
    field ven-5400  as dec
    field ven-1800  as dec
    field ven-1080  as dec
    field ven-360   as dec
    field ven-90    as dec
    index i1 clicod cobcod 
    index i2 risco
    index i3 cobcod
    .

def temp-table tt-risco  no-undo
    field risco as char
    field des as char
    field vencido as dec  format ">>>,>>>,>>9.99"
    field vencer  as dec  format ">>>,>>>,>>9.99"
    field total   as dec  format ">>>,>>>,>>9.99"
    field principal as dec format ">>>,>>>,>>9.99"
    field acrescimo as dec format ">>>,>>>,>>9.99"
    field ven-9999  as dec
    field ven-5400  as dec
    field ven-1800  as dec
    field ven-1080  as dec
    field ven-360   as dec
    field ven-90    as dec
    index i1 risco
    .

def temp-table lb-risco  no-undo
    field risco as char
    field des as char
    field vencido as dec  format ">>>,>>>,>>9.99"
    field vencer  as dec  format ">>>,>>>,>>9.99"
    field total   as dec  format ">>>,>>>,>>9.99"
    field principal as dec format ">>>,>>>,>>9.99"
    field acrescimo as dec format ">>>,>>>,>>9.99"
    field ven-9999  as dec
    field ven-5400  as dec
    field ven-1800  as dec
    field ven-1080  as dec
    field ven-360   as dec
    field ven-90    as dec
    index i1 risco
    .

def temp-table fn-risco  no-undo
    field risco as char
    field des as char
    field vencido as dec  format ">>>,>>>,>>9.99"
    field vencer  as dec  format ">>>,>>>,>>9.99"
    field total   as dec  format ">>>,>>>,>>9.99"
    field principal as dec format ">>>,>>>,>>9.99"
    field acrescimo as dec format ">>>,>>>,>>9.99"
    field ven-9999  as dec
    field ven-5400  as dec
    field ven-1800  as dec
    field ven-1080  as dec
    field ven-360   as dec
    field ven-90    as dec
    index i1 risco
    .

def temp-table tt-tbcntgen  no-undo
    field nivel as char
    field numini as char
    field numfim as char
    field valor as dec
    index i1 nivel.

def var va as dec.
def var vb as dec.
def var vc as int.
for each tbcntgen where tbcntgen.tipcon = 13
                    no-lock by tbcntgen.campo1[1]  :
    create tt-tbcntgen.
    assign
        tt-tbcntgen.nivel = tbcntgen.campo1[1]
        tt-tbcntgen.numini = tbcntgen.numini
        tt-tbcntgen.numfim = tbcntgen.numfim
        tt-tbcntgen.valor = tbcntgen.valor
        .
end. 

def var q-nivel as int.
def var v-vencer  as dec extent 20.
def var vi as int .

for each tt-tbcntgen no-lock.
    if tt-tbcntgen.nivel = ""
    then delete tt-tbcntgen.
    else assign
            vi = vi + 1
            a-dia[vi] = int(trim(tt-tbcntgen.numini))
            b-dia[vi] = int(trim(tt-tbcntgen.numfim))
            v-risco[vi] = tt-tbcntgen.nivel
            v-pct[vi] = tt-tbcntgen.valor
            .
end.

q-nivel = vi.

def var p-principal as dec.
def var p-renda as dec.
def var p-vencido as dec.
def var p-vencer as dec.
def var p-risco as char.
def var p-aberto as dec.
def var p-qtdpar as dec.
def var p-qtdparab as dec.
def var p-total as dec.
def var p-entra as dec.
def var p-atraso as dec.
def var vqt as int.
def var p-catcod as int.

def var val-avpdia as dec.

def var vcatcod as int.

sresp = no.
message "Confirma processamento referencia " vdatref "?" update sresp.
if not sresp then return.

disp "Aguarde processamento... "
    with frame f-pro 1 down row 10 width 80 no-box no-label
    .
pause 0.
def var vsaldo as dec format ">>>,>>>,>>9.99".
def var vrenda as dec format ">>>,>>>,>>9.99".
def var vindex_renda as dec.

def var tot-vencido as dec.
def var tot-avpdia as dec.
def var tot-vencer as dec.
def var tot-principal as dec.
def var tot-acrescimo as dec.

def var ttvencido as dec.
def var vq as int.    
def var vt as int.

def var p-cobcod like titulo.cobcod.
def var vmodcod like titulo.modcod.
vmodcod = "CRE".

def var vtotal as dec format ">>>,>>>,>>9.99".
def buffer atitulo for titulo.
def buffer btitulo for titulo.

def var qcli as int.
def temp-table tt-GClasOPC like GClasOPC.

def buffer wclien for clien.

for each wclien where wclien.clicod > 49 no-lock:
    qcli = qcli + 1.
    if qcli = 200 
    then do:
        disp wclien.clicod wclien.clinom with frame f-pro.
        pause 0.
        qcli = 0.
    end.
    find first GClasOPC where GClasOPC.clifor  = wclien.clicod and
                              GClasOPC.dtvisao = vdatref
                              no-lock no-error.
    if avail GClasOPC then next. 
    
    for each tt-GClasOPC: delete tt-GClasOPC. end.

    for each atitulo use-index por-clifor where atitulo.empcod = 19 and
                            atitulo.titnat = no and
                            atitulo.clifor = wclien.clicod and
                            atitulo.titdtemi <= vdatref and
                            (atitulo.titsit = "LIB" or
                             (atitulo.titdtpag > vdatref and
                              atitulo.titsit = "PAG")) 
                            /* and atitulo.titnum = "102375401" */
                            no-lock.
   
        vmodcod = atitulo.modcod.
    
        vq = vq + 1.
        if vq = 1000
        then do:
            disp atitulo.titdtemi no-label
                 atitulo.titnum no-label 
                 vtotal no-label
                 with frame f-pro.
            pause 0.
            vq = 0.
        end.
        if atitulo.titnum = "" or
           length(atitulo.titnum) > 15
        then next. 

        p-cobcod = 2.
        find first envfinan where
                   envfinan.empcod = atitulo.empcod and
                   envfinan.titnat = atitulo.titnat and
                   envfinan.modcod = atitulo.modcod and
                   envfinan.etbcod = atitulo.etbcod and
                   envfinan.clifor = atitulo.clifor and
                   envfinan.titnum = atitulo.titnum and
                   envfinan.titpar = atitulo.titpar
                   no-lock no-error.
        if avail envfinan and (envfinan.envsit = "PAG" or
                               envfinan.envsit = "INC")
        then p-cobcod = 10.
    
        find first tt-con use-index i1 where
                   tt-con.etbcod = atitulo.etbcod and
                   tt-con.clicod = atitulo.clifor and
                   tt-con.titnum = atitulo.titnum and
                   tt-con.cobcod = p-cobcod
                   no-error.
        if avail tt-con
        then next.
    
        create tt-con.
        assign
            tt-con.etbcod   = atitulo.etbcod
            tt-con.clicod   = atitulo.clifor
            tt-con.titnum   = atitulo.titnum
            tt-con.titdtemi = atitulo.titdtemi
            tt-con.cobcod   = p-cobcod
            tt-con.risco  = "A"
            .

        assign
            p-principal = 0 p-renda     = 0 p-vencido   = 0 p-vencer    = 0
            p-risco     = "A" p-aberto    = 0 p-qtdpar    = 0 p-qtdparab  = 0
            p-total     = 0 p-entra     = 0 p-atraso    = 0 pven-9999   = 0
            pven-5400   = 0 pven-1800   = 0 pven-1080   = 0 pven-360    = 0
            pven-90     = 0
            .
                
        find first tt-GClasOPC where
                   tt-GClasOPC.dtvisao = vdatref and
                   tt-GClasOPC.etbcod  = atitulo.etbcod and
                   tt-GClasOPC.clifor  = atitulo.clifor and
                   tt-GClasOPC.titnum  = atitulo.titnum and
                   tt-GClasOPC.cobcod  = p-cobcod
                   no-error.
        if  not avail tt-GClasOPC
        then do:
            create tt-GClasOPC.
            val-avpdia = 0.
        end.    
    
        p-catcod = 99.
        
        find last contnf where contnf.etbcod = atitulo.etbcod and
                   contnf.contnum = int(atitulo.titnum)
                                      no-lock no-error.
        if avail contnf
        then do:
            find first movim where movim.etbcod = contnf.etbcod and
                                       movim.placod = contnf.placod and
                                       movim.movtdc = 5
                                       no-lock no-error.
            if avail movim
            then do:
                find produ where produ.procod = movim.procod 
                                no-lock no-error.
                p-catcod = produ.catcod.
            end.
        end.
        
        assign
            v-principal = 0
            v-acrescimo = 0
            p-risco = "A".
        
        run principal-renda.
        
        v-principal = pacnv-principal.
        v-acrescimo = pacnv-acrescimo.
        
        for each btitulo where
                     btitulo.empcod = atitulo.empcod and
                     btitulo.titnat = atitulo.titnat and
                     btitulo.modcod = atitulo.modcod and
                     btitulo.etbcod = atitulo.etbcod and
                     btitulo.clifor = atitulo.clifor and
                     btitulo.titnum = atitulo.titnum and
                     btitulo.cobcod = p-cobcod
                     no-lock:
        
            p-total = p-total + btitulo.titvlcob.

            if btitulo.titpar = 0
            then p-entra = btitulo.titvlcob.

            if btitulo.titpar > p-qtdpar
            then p-qtdpar = btitulo.titpar.
            
            if btitulo.titsit = "LIB" or
              (btitulo.titsit = "PAG" and
               btitulo.titdtpag > vdatref)
            then do:
            
                assign
                    p-principal = p-principal + v-principal
                    p-renda = p-renda + v-acrescimo
                    .
                /*
                message btitulo.titnum
                        btitulo.titpar
                        btitulo.titdtven
                        btitulo.titdtpag
                        vdatref.
                pause.
                        */
                ttvencido = 0.
                if btitulo.titdtven <= vdatref
                then do vi = 1 to q-nivel:
                    if vdatref - btitulo.titdtven <= b-dia[vi] 
                    then do:
                        assign
                                p-atraso = vdatref - btitulo.titdtven
                                p-vencido = p-vencido + btitulo.titvlcob
                                ttvencido = btitulo.titvlcob
                                .
                        if v-risco[vi] > p-risco
                        then p-risco  = v-risco[vi].
                        leave.
                    end.    
                end.
                if btitulo.titdtven <= vdatref
                then do:
                    if ttvencido = 0
                    then assign
                            p-vencido = p-vencido + btitulo.titvlcob
                            p-atraso = vdatref - btitulo.titdtven
                            .

                end.
                else do:
                 
                    p-vencer  = p-vencer + btitulo.titvlcob.
                
                    /*** calculo AVP ***/
                    
                    find first seq-mes where
                               seq-mes.ano = year(btitulo.titdtven) and
                               seq-mes.mes = month(btitulo.titdtven)
                                no-error.
                    if avail seq-mes
                    then do:
                        
                        if p-tj = 0
                        then run cal-txjuro-contrato.p(input btitulo.titnum,
                                                       output p-tj).
            
                        va = 1 + ((p-tj / 100) / 30).
                        vb = va.
            
                        do vi = 2 to (btitulo.titdtven - vdatref):
                            vb = vb * va.
                        end.
                        assign
                            seq-mes.avpdia = seq-mes.avpdia + 
                                        (btitulo.titvlcob / vb)
                            val-avpdia = val-avpdia + (btitulo.titvlcob / vb)
                            seq-mes.avencer = seq-mes.avencer + btitulo.titvlcob
                            seq-mes.principal = seq-mes.principal + v-principal
                            seq-mes.acrescimo = seq-mes.acrescimo + v-acrescimo
                            .
                        
                    end.
                    /*****************/
        
                end.
                p-qtdparab  = p-qtdparab + 1. 

                if btitulo.titdtven - vdatref > 5400
                then pven-9999 = pven-9999 + btitulo.titvlcob.
                else if btitulo.titdtven - vdatref > 1800
                then pven-5400 = pven-5400 + btitulo.titvlcob.
                else if btitulo.titdtven - vdatref > 1080
                then pven-1800 = pven-1800 + btitulo.titvlcob.
                else if btitulo.titdtven - vdatref > 360
                then pven-1080 = pven-1080 + btitulo.titvlcob.
                else if btitulo.titdtven - vdatref > 90
                then pven-360  = pven-360 + btitulo.titvlcob.
                else if btitulo.titdtven - vdatref > 0
                then pven-90 = pven-90 + btitulo.titvlcob.

            end.
        end. 

        vtotal = vtotal + p-vencido + p-vencer.
        find first contrato where contrato.contnum = int(atitulo.titnum)
                            no-lock no-error.
        assign
            tt-GClasOPC.dtvisao  = vdatref
            tt-GClasOPC.tpvisao  = "GERENCIAL"
            tt-GClasOPC.modcod   = atitulo.modcod
            tt-GClasOPC.etbcod   = atitulo.etbcod
            tt-GClasOPC.clifor   = atitulo.clifor
            tt-GClasOPC.titnum    = atitulo.titnum
            tt-GClasOPC.titdtemi = atitulo.titdtemi
            tt-GClasOPC.principal = p-principal
            tt-GClasOPC.renda     = p-renda
            tt-GClasOPC.vencido   = p-vencido
            tt-GClasOPC.vencer    = p-vencer
            tt-GClasOPC.qtdpar    = p-qtdpar
            tt-GClasOPC.qtdparab  = p-qtdparab
            tt-GClasOPC.matraso   = p-atraso
            tt-GClasOPC.catcod    = p-catcod
            tt-GClasOPC.riscon    = p-risco
            tt-GClasOPC.cobcod    = p-cobcod
            tt-GClasOPC.valor-avp = val-avpdia
            .
            
        if tt-GClasOPC.principal > (tt-GClasOPC.vencido + tt-GClasOPC.vencer)
        then assign
                tt-GClasOPC.principal = (tt-GClasOPC.vencido + 
                                                tt-GClasOPC.vencer)
                tt-GClasOPC.renda = 0
                .
                
        if avail contrato and contrato.vltotal = p-total
        then assign
                tt-GClasOPC.vltotal = contrato.vltotal
                tt-GClasOPC.vlentra = contrato.vlentra
                tt-GClasOPC.crecod  = contrato.crecod
                .
        
        else assign
                tt-GClasOPC.vltotal = p-total
                tt-GClasOPC.vlentra = p-entra
                tt-GClasOPC.crecod  = ?
                .
                         
        assign
            tt-GClasOPC.ven-999999 = pven-9999
            tt-GClasOPC.ven-5400 = pven-5400
            tt-GClasOPC.ven-1800 = pven-1800
            tt-GClasOPC.ven-1080 = pven-1080
            tt-GClasOPC.ven-360  = pven-360
            tt-GClasOPC.ven-90   = pven-90
            .

        for each seq-mes no-lock by ano
                                 by mes 
                                 by seq:
            assign
                tt-GClasOPC.avp-ano[seq-mes.seq] = seq-mes.ano
                tt-GClasOPC.avp-mes[seq-mes.seq] = seq-mes.mes
                tt-GClasOPC.avp-valdia[seq-mes.seq] = seq-mes.avpdia
                tt-GClasOPC.avp-vencer[seq-mes.seq] = seq-mes.avencer
                tt-GClasOPC.avp-principal[seq-mes.seq] = seq-mes.principal
                tt-GClasOPC.avp-renda[seq-mes.seq] = seq-mes.acrescimo
                seq-mes.avpdia = 0
                seq-mes.avencer = 0
                seq-mes.principal = 0
                seq-mes.acrescimo = 0                
                .
        end.

    end.

/******************/

find first tt-GClasOPC where
           tt-GClasOPC.clifor = wclien.clicod
           no-error.
if not avail tt-GClasOPC then next.           

tot-vencido = 0.
for each tt-GClasOPC where 
         tt-GClasOPC.clifor = wclien.clicod 
         no-lock:
    create GClasOPC.
    buffer-copy tt-GClasOPC to GClasOPC.
    tot-vencido = tot-vencido + GClasOPC.vencido.
end.

assign
    tot-avpdia = 0
    tot-vencer = 0
    tot-principal = 0
    tot-acrescimo = 0
    .

/****************
for each seq-mes where seq-mes.mes <> 0 no-lock:
    assign
        tot-avpdia           = tot-avpdia + seq-mes.avpdia
        tot-vencer           = tot-vencer + seq-mes.avencer
        tot-principal        = tot-principal + seq-mes.principal
        tot-acrescimo        = tot-acrescimo  + seq-mes.acrescimo 
        .
end.

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

assign
    seq-mes.vencido   = tot-vencido
    seq-mes.avencer   = tot-vencer
    seq-mes.avpdia    = tot-avpdia
    seq-mes.principal = tot-principal
    seq-mes.acrescimo = tot-acrescimo
    .


for each seq-mes no-lock:
    find sqmesavp where sqmesavp.dtvisao = vdatref and
                        sqmesavp.ano     = seq-mes.ano and
                        sqmesavp.mes     = seq-mes.mes and
                        sqmesavp.seq     = seq-mes.seq
                        no-error.
    if not avail sqmesavp
    then do:
        create sqmesavp.
        assign
            sqmesavp.dtvisao = vdatref
            sqmesavp.ano     = seq-mes.ano
            sqmesavp.mes     = seq-mes.mes
            sqmesavp.seq     = seq-mes.seq
            .
    end.
    assign
        sqmesavp.avpdia      = seq-mes.avpdia
        sqmesavp.vencido     = seq-mes.vencido
        sqmesavp.avencer     = seq-mes.avencer
        sqmesavp.principal   = seq-mes.principal
        sqmesavp.acrescimo   = seq-mes.acrescimo
        .

end.
******************/

for each tt-cli: delete tt-cli. end.

def var vdifer as dec.
def var vtotpro as dec.
def var vtotal-sal as dec format ">>>,>>>,>>9.99".
vtotal-sal = 0.

for each GClasOPC use-index indx7 where
         GClasOPC.dtvisao = vdatref and
         GClasOPC.tpvisao = "GERENCIAL" and
         GClasOPC.clifor = wclien.clicod and
         GClasOPC.situacao = "" 
         :

    
    run gera-prodevdu-contrato(input vdatref,
                      input "GERENCIAL",
                      input "CONTRATO",
                      input ?,
                      input ?,
                      input GClasOPC.modcod,
                      input GClasOPC.riscon).
    
    
    run gera-prodevdu-contrato(input vdatref,
                      input "GERENCIAL",
                      input "CONTRATO",
                      input GClasOPC.cobcod,
                      input ?,
                      input GClasOPC.modcod,
                      input GClasOPC.riscon).

    run gera-prodevdu-contrato(input vdatref,
                      input "GERENCIAL",
                      input "CONTRATO",
                      input ?,
                      input GClasOPC.catcod,
                      input GClasOPC.modcod,
                      input GClasOPC.riscon).
 
     run gera-prodevdu-contrato(input vdatref,
                      input "GERENCIAL",
                      input "CONTRATO",
                      input GClasOPC.cobcod,
                      input GClasOPC.catcod,
                      input GClasOPC.modcod,
                      input GClasOPC.riscon).
 
    
    run gera-ttcli(input GClasOPC.clifor,
                   input ?,
                   input ?,
                   input GClasOPC.modcod).
    
    
    run gera-ttcli(input GClasOPC.clifor,
                   input GClasOPC.cobcod,
                   input ?,
                   input GClasOPC.modcod).

    run gera-ttcli(input GClasOPC.clifor,
                   input ?,
                   input GClasOPC.catcod,
                   input GClasOPC.modcod).

    run gera-ttcli(input GClasOPC.clifor,
                   input GClasOPC.cobcod,
                   input GClasOPC.catcod,
                   input GClasOPC.modcod).
               

    if GClasOPC.crecod = 500
    then do:
        run gera-prodevdu-contrato(input vdatref,
                      input "GERENCIAL",
                      input "CONTRATO",
                      input ?,
                      input 500,
                      input ?,
                      input GClasOPC.riscon).
 
        run gera-prodevdu-contrato(input vdatref,
                      input "GERENCIAL",
                      input "CONTRATO",
                      input GClasOPC.cobcod,
                      input 500,
                      input ?,
                      input GClasOPC.riscon).
 
        run gera-prodevdu-contrato(input vdatref,
                      input "GERENCIAL",
                      input "CONTRATO",
                      input ?,
                      input 500,
                      input GClasOPC.modcod,
                      input GClasOPC.riscon).
 
        run gera-prodevdu-contrato(input vdatref,
                      input "GERENCIAL",
                      input "CONTRATO",
                      input GClasOPC.cobcod,
                      input 500,
                      input GClasOPC.modcod,
                      input GClasOPC.riscon).
 

        run gera-ttcli(input GClasOPC.clifor,
                   input ?,
                   input 500,
                   input ?).
        run gera-ttcli(input GClasOPC.clifor,
                   input GClasOPC.cobcod,
                   input 500,
                   input GClasOPC.modcod).
        run gera-ttcli(input GClasOPC.clifor,
                   input ?,
                   input 500,
                   input GClasOPC.modcod).
        run gera-ttcli(input GClasOPC.clifor,
                   input GClasOPC.cobcod,
                   input 500,
                   input ?).
                   
 
    end. 
        
end.

for each tt-cli:

    run gera-prodevdu-cliente(input vdatref,
                      input "GERENCIAL",
                      input "CLIENTE",
                      input tt-cli.cobcod,
                      input tt-cli.catcod,
                      input tt-cli.modcod,
                      input tt-cli.risco).
 
    
end.

/**********/

for each GClasOPC where
         GClasOPC.dtvisao = vdatref and
         GClasOPC.tpvisao = "GERENCIAL" and
         GClasOPC.clifor  = wclien.clicod and
         GClasOPC.situacao = "":
    find first tt-cli where tt-cli.clicod = GClasOPC.clifor and
                            tt-cli.cobcod = GClasOPC.cobcod and
                            tt-cli.catcod = 0 and
                            tt-cli.modcod = GClasOPC.modcod
                            no-lock no-error.
    if avail tt-cli
    then GClasOPC.riscli = tt-cli.risco.
    else GClasOPC.riscli = GClasOPC.riscon.
end. 

end.

hide frame f-pro no-pause.


def var ven-cido as char.
def var ven-cer  as char.
def var avp-dia  as char.
def var varquivo as char.
def var prin-cipal as char.
def var acres-cimo as char.
/*********************
varquivo = "/admcom/TI/claudir/saldo-devedores-avp-dia"
           + string(vdatref,"99999999") + "_" +
            string(time) + ".csv".

output to value(varquivo).    

disp with frame f-top .
put skip.
put "Ano;Mes;Vencido;Vencer;Valor AVP;Principal;Acrescimo" skip.

for each seq-mes no-lock:
    if seq-mes.ano = 0 then next.
    if seq-mes.avencer = 0 and
       seq-mes.avpdia = 0
    then next.
    
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
********************/

/***************************/

procedure principal-renda:
    
    assign
        pacnv-avista     = 0
        pacnv-aprazo     = 0
        pacnv-principal  = 0
        pacnv-acrescimo  = 0
        pacnv-entrada    = 0
        pacnv-seguro     = 0
        pacnv-crepes     = 0
        pacnv-troca      = 0
        pacnv-voucher    = 0
        pacnv-black      = 0
        pacnv-chepres    = 0
        pacnv-combo      = 0
        pacnv-abate      = 0
        pacnv-novacao    = no
        pacnv-renovacao  = no
        pacnv-feiraonl   = no
        pacnv-cpfautoriza = ""
        pacnv-juroatu     = 0
        pacnv-juroacr     = 0
        .
        
    find first titpacnv where
               titpacnv.modcod = atitulo.modcod and
               titpacnv.etbcod = atitulo.etbcod and 
               titpacnv.clifor = atitulo.clifor and
               titpacnv.titnum = atitulo.titnum and
               titpacnv.titdtemi = atitulo.titdtemi
                       no-lock no-error.
    if not avail titpacnv
    then do:
        create titpacnv.
        assign
            titpacnv.modcod   = atitulo.modcod
            titpacnv.etbcod   = atitulo.etbcod
            titpacnv.clifor   = atitulo.clifor
            titpacnv.titnum   = atitulo.titnum
            titpacnv.titdtemi = atitulo.titdtemi
            titpacnv.titvlcob = atitulo.titvlcob
            titpacnv.titdes   = atitulo.titdes
            .
          
        run retorna-pacnv-valores-contrato.p 
                    (input ?, input ?, input recid(atitulo)).

        if  pacnv-principal <= 0 or
            pacnv-acrescimo <= 0
        then assign
                 pacnv-principal = atitulo.titvlcob
                 pacnv-acrescimo = 0
                 .

        assign
            titpacnv.principal = pacnv-principal
            titpacnv.acrescimo = pacnv-acrescimo
            .
    end.
    else assign
             pacnv-principal = titpacnv.principal
             pacnv-acrescimo = titpacnv.acrescimo
             pacnv-seguro    = titpacnv.titdes
             .

end procedure.

procedure recal-renda:

    def var vsaldo_princ as dec.
    vsaldo_princ = 0.
    if GClasOPC.principal_antes = 0
    then assign 
        GClasOPC.principal_antes = GClasOPC.principal
        GClasOPC.renda_antes = GClasOPC.renda.
                            
    assign
        vsaldo_princ = GClasOPC.vencido + GClasOPC.ven-90 + GClasOPC.ven-360 +
                       GClasOPC.ven-1080 + GClasOPC.ven-1800 +
                       GClasOPC.ven-5400 + GClasOPC.ven-9999 
        GClasOPC.renda = vsaldo_princ * vindex_renda
        GClasOPC.principal = vsaldo_princ - GClasOPC.renda.
        
end procedure.     

procedure gera-prodevdu-contrato:

    def input parameter par-data-visao as date.
    def input parameter par-tipo-visao as char.
    def input parameter par-modo-visao as char.
    def input parameter par-cobcod as int .
    def input parameter par-catcod as int .
    def input parameter par-modcod as char .
    def input parameter par-faixa-risco like GClasOPC.riscon.
    
    find first prodevdu where
                   prodevdu.data_visao  = par-data-visao and
                   prodevdu.tipo_visao  = par-tipo-visao and
                   prodevdu.modo_visao  = par-modo-visao and
                   prodevdu.cobcod      = par-cobcod and
                   prodevdu.categoria   = par-catcod and
                   prodevdu.modalidade  = par-modcod and
                   prodevdu.faixa_risco = par-faixa-risco 
                   no-error.
    if not avail prodevdu
    then do:
            create prodevdu.
            assign
                prodevdu.data_visao = par-data-visao 
                prodevdu.tipo_visao = par-tipo-visao
                prodevdu.modo_visao = par-modo-visao 
                prodevdu.cobcod     = par-cobcod 
                prodevdu.categoria  = par-catcod 
                prodevdu.modalidade = par-modcod 
                prodevdu.faixa_risco = par-faixa-risco
                .
    end. 
    assign
            prodevdu.vencidos = prodevdu.vencidos + GClasOPC.vencido
            prodevdu.vencer_9999 = prodevdu.vencer_9999 + GClasOPC.ven-9999
            prodevdu.vencer_5400 = prodevdu.vencer_5400 + GClasOPC.ven-5400
            prodevdu.vencer_1800 = prodevdu.vencer_1800 + GClasOPC.ven-1800
            prodevdu.vencer_1080 = prodevdu.vencer_1080 + GClasOPC.ven-1080
            prodevdu.vencer_360  = prodevdu.vencer_360  + GClasOPC.ven-360
            prodevdu.vencer_90   = prodevdu.vencer_90   + GClasOPC.ven-90
            prodevdu.principal   = prodevdu.principal   + GClasOPC.principal
            prodevdu.renda       = prodevdu.renda       + GClasOPC.renda
            prodevdu.saldo_curva = prodevdu.saldo_curva +
                                   GClasOPC.vencido +
                                   GClasOPC.ven-90 +
                                   GClasOPC.ven-360 +
                                   GClasOPC.ven-1080 +
                                   GClasOPC.ven-1800 +
                                   GClasOPC.ven-5400 +
                                   GClasOPC.ven-9999
                                    .
                                          
        find first tbcntgen where 
                   tbcntgen.tipcon = 13 and
                   tbcntgen.campo1[1] = GClasOPC.riscon no-error.
        prodevdu.descricao_faixa =  tbcntgen.numini + "-" +
                                    tbcntgen.numfim.
        prodevdu.provisao = prodevdu.saldo_curva * (tbcntgen.valor / 100).
        prodevdu.pctprovisao = tbcntgen.valor.

end procedure.
 
procedure gera-prodevdu-cliente:

    def input parameter par-data-visao as date.
    def input parameter par-tipo-visao as char.
    def input parameter par-modo-visao as char.
    def input parameter par-cobcod as int .
    def input parameter par-catcod as int .
    def input parameter par-modcod as char .
    def input parameter par-faixa-risco like GClasOPC.riscon.

    find first prodevdu where
                   prodevdu.data_visao  = par-data-visao and
                   prodevdu.tipo_visao  = par-tipo-visao and
                   prodevdu.modo_visao  = par-modo-visao and
                   prodevdu.cobcod      = par-cobcod and
                   prodevdu.categoria   = par-catcod and
                   prodevdu.modalidade  = par-modcod and
                   prodevdu.faixa_risco = par-faixa-risco 
                   no-error.
    if not avail prodevdu
    then do:
            create prodevdu.
            assign
                prodevdu.data_visao = par-data-visao 
                prodevdu.tipo_visao = par-tipo-visao
                prodevdu.modo_visao = par-modo-visao 
                prodevdu.cobcod     = par-cobcod 
                prodevdu.categoria  = par-catcod 
                prodevdu.modalidade = par-modcod 
                prodevdu.faixa_risco = par-faixa-risco
                .
    end. 
    assign
            prodevdu.vencidos = prodevdu.vencidos + tt-cli.vencido
            prodevdu.vencer_9999 = prodevdu.vencer_9999 + tt-cli.ven-9999
            prodevdu.vencer_5400 = prodevdu.vencer_5400 + tt-cli.ven-5400
            prodevdu.vencer_1800 = prodevdu.vencer_1800 + tt-cli.ven-1800
            prodevdu.vencer_1080 = prodevdu.vencer_1080 + tt-cli.ven-1080
            prodevdu.vencer_360  = prodevdu.vencer_360  + tt-cli.ven-360
            prodevdu.vencer_90   = prodevdu.vencer_90   + tt-cli.ven-90
            prodevdu.principal   = prodevdu.principal   + tt-cli.principal
            prodevdu.renda       = prodevdu.renda       + tt-cli.acrescimo
            prodevdu.saldo_curva = prodevdu.saldo_curva +
                                   tt-cli.vencido +
                                   tt-cli.ven-90 +
                                   tt-cli.ven-360 +
                                   tt-cli.ven-1080 +
                                   tt-cli.ven-1800 +
                                   tt-cli.ven-5400 +
                                   tt-cli.ven-9999
                                    .
                                          
        find first tbcntgen where 
                   tbcntgen.tipcon = 13 and
                   tbcntgen.campo1[1] = tt-cli.risco no-error.
        prodevdu.descricao_faixa =  tbcntgen.numini + "-" +
                                    tbcntgen.numfim.
        prodevdu.provisao = prodevdu.saldo_curva * (tbcntgen.valor / 100).
        prodevdu.pctprovisao = tbcntgen.valor.

end procedure.

procedure gera-ttcli:
   
    def input parameter par-clifor like GClasOPC.clifor.
    def input parameter par-cobcod like GClasOPC.cobcod.
    def input parameter par-catcod like GClasOPC.catcod.
    def input parameter par-modcod like GClasOPC.modcod.
    
    find first tt-cli where
               tt-cli.clicod = par-clifor and
               tt-cli.cobcod = par-cobcod and
               tt-cli.catcod = par-catcod and
               tt-cli.modcod = par-modcod no-error.
    if not avail tt-cli
    then do:
        create tt-cli.
        assign
            tt-cli.clicod = par-clifor
            tt-cli.cobcod = par-cobcod
            tt-cli.catcod = par-catcod
            tt-cli.modcod = par-modcod
            .
    end.
    assign
        tt-cli.qtdpar = tt-cli.qtdpar + GClasOPC.qtdpar
        tt-cli.qtdparab = tt-cli.qtdparab + GClasOPC.qtdparab
        tt-cli.valtotal = tt-cli.valtotal + GClasOPC.vltotal
        tt-cli.vencido  = tt-cli.vencido + GClasOPC.vencido
        tt-cli.vencer   = tt-cli.vencer + GClasOPC.vencer
        tt-cli.valaberto = tt-cli.valaberto + 
                                (GClasOPC.vencido + GClasOPC.vencer)
        tt-cli.principal = tt-cli.principal + GClasOPC.principal
        tt-cli.acrescimo = tt-cli.acrescimo + GClasOPC.renda
        tt-cli.ven-9999  = tt-cli.ven-9999 + GClasOPC.ven-9999
        tt-cli.ven-5400  = tt-cli.ven-5400 + GClasOPC.ven-5400
        tt-cli.ven-1800  = tt-cli.ven-1800 + GClasOPC.ven-1800
        tt-cli.ven-1080  = tt-cli.ven-1080 + GClasOPC.ven-1080
        tt-cli.ven-360   = tt-cli.ven-360  + GClasOPC.ven-360
        tt-cli.ven-90    = tt-cli.ven-90   + GClasOPC.ven-90
        .
    if GClasOPC.riscon > tt-cli.risco
    then tt-cli.risco = GClasOPC.riscon. 
    
end procedure
                               
                               

                               
                               
