{admcab.i new}
sfuncod = 101.
message sfuncod. pause.
if sfuncod <> 101 then return.


{retorna-pacnv.i new}

def var /*input parameter*/ vdatref as date.
update vdatref.

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
def var pven-00   as dec.

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
for each seq-mes where seq-mes.seq = 0:
    delete seq-mes.
end.
/****
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
***/

def temp-table tt-con no-undo
    field etbcod as int
    field clicod as int
    field titnum as char
    field titdtemi as date
    index i1 etbcod clicod titnum 
    .
    
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


def var vparcela like titulo.titpar.
def var vparcial as log.
                                        
def var qcli as int.
def temp-table tt-ClaOPCtb like ClaOPCtb.
def temp-table tt-sqmesavp like sqmesavp.

def buffer wclien for clien.
def buffer btitulo for titulo.
def buffer ptitulo for titulo.
def var p-riscli as char.
def var vtpvisao as char.
def var vsq-mes as int.

vtpvisao = "GERENCIAL" + string(month(vdatref),"99")
                       + string(year(vdatref),"9999").

def var vcont as int.
for each titulo where 
                       titulo.titnat = no and
                       titulo.titdtemi <= vdatref and
                       (titulo.titsit = "LIB" or
                            (titulo.titsit = "PAG" and
                             titulo.titdtpag <> ? and
                             titulo.titdtpag > vdatref)) and
                             titulo.titdtven <> ? 
                        no-lock:  
    
    vcont = vcont + 1.
    if vcont mod 100000 = 0
    then disp vcont with 1 down.
    pause 0.
    /*
    find first ClaOPCtb where   ClaOPCtb.tpvisao = vtpvisao and
                                ClaOPCtb.dtvisao = vdatref and
                                ClaOPCtb.clifor  = titulo.clifor and
                                ClaOPCtb.titnum  = titulo.titnum and
                                ClaOPCtb.etbcod  = titulo.etbcod
                                no-lock no-error.
    if not avail ClaOPCtb
    then*/ do:

        find first tt-con where
               tt-con.etbcod = titulo.etbcod and
               tt-con.clicod = titulo.clifor and
               tt-con.titnum = titulo.titnum
               no-error.
        if not avail tt-con
        then do:
            create tt-con.
            assign        
                tt-con.etbcod = titulo.etbcod
                tt-con.clicod = titulo.clifor
                tt-con.titnum = titulo.titnum
                tt-con.titdtemi = titulo.titdtemi.
        end. 
    end.
end.

for each tt-con no-lock,
    first wclien where wclien.clicod = tt-con.clicod no-lock:
    
    /****
for each wclien where wclien.clicod > 49 and
                      wclien.clinom <> "" no-lock,
    first ptitulo where ptitulo.empcod = 19 and
                       ptitulo.titnat = no and
                       ptitulo.clifor = wclien.clicod and
                       ptitulo.titdtemi <= vdatref and
                       (ptitulo.titsit = "LIB" or
                            (ptitulo.titsit = "PAG" and
                             ptitulo.titdtpag <> ? and
                             ptitulo.titdtpag > vdatref)) and
                             ptitulo.titdtven <> ? 
                        no-lock:   
    ***/

    qcli = qcli + 1.
    if qcli = 200 
    then do:
        disp wclien.clicod wclien.clinom with frame f-pro.
        pause 0.
        qcli = 0.
    end.
    find first ClaOPCtb where   ClaOPCtb.tpvisao = vtpvisao and
                                ClaOPCtb.dtvisao = vdatref and
                                ClaOPCtb.clifor  = wclien.clicod and
                                ClaOPCtb.titnum  = tt-con.titnum and
                                ClaOPCtb.etbcod  = tt-con.etbcod
                                no-lock no-error.
    if avail ClaOPCtb then next. 
    /*
    message wclien.clicod ptitulo.titnum 
    ptitulo.titdtpag ptitulo.titdtven
    ptitulo.titsit ptitulo.modcod . pause.
    */
    for each tt-ClaOPCtb: delete tt-ClaOPCtb. end.
    for each tt-sqmesavp: delete tt-sqmesavp. end.

    p-riscli = "A".
    /*for each estab no-lock,*/
    for each titulo  where  titulo.empcod = 19 and
                            titulo.titnat = no and
                            titulo.modcod = "CRE" and
                            titulo.etbcod = tt-con.etbcod and
                            titulo.clifor = tt-con.clicod and
                            titulo.titnum = tt-con.titnum and
                           ((titulo.titsit = "LIB" and
                             titulo.titdtpag = ?) or
                            (titulo.titsit = "PAG" and
                             titulo.titdtpag <> ? and
                             titulo.titdtpag > vdatref))
                            no-lock .
    
        
        if titulo.titnum = "" or length(titulo.titnum) > 15
        then next. 

        if titulo.titdtven = ? then next.
        if year(titdtven) > 2040 then next.
 
        vmodcod = titulo.modcod.
        p-cobcod = titulo.cobcod.
        if p-cobcod = 1 then p-cobcod = 2.
        
        vtotal = vtotal + titulo.titvlcob.
        
        vq = vq + 1.
        if vq = 10000
        then do:
            disp titulo.titdtemi no-label
                 titulo.titnum no-label 
                 vtotal no-label
                 with frame f-pro.
            pause 0.
            vq = 0.
        end.

        assign
            p-principal = 0 p-renda     = 0 p-vencido   = 0 p-vencer    = 0
            p-risco     = "A" p-aberto    = 0 p-qtdpar    = 0 p-qtdparab  = 0
            p-total     = 0 p-entra     = 0 p-atraso    = 0 pven-9999   = 0
            pven-5400   = 0 pven-1800   = 0 pven-1080   = 0 pven-360    = 0
            pven-90     = 0
            .
        
        find first tt-ClaOPCtb where
                   tt-claopctb.tpvisao = vtpvisao and
                   tt-ClaOPCtb.dtvisao = vdatref and
                   tt-ClaOPCtb.clifor  = titulo.clifor and
                   tt-ClaOPCtb.titnum  = titulo.titnum and
                   tt-ClaOPCtb.etbcod  = titulo.etbcod 
                   no-error.
        if  not avail tt-ClaOPCtb
        then do:
            val-avpdia = 0.
        
            find first contrato where contrato.contnum = int(titulo.titnum)
                                       no-lock no-error.
            if not avail contrato
            then do:
                for each btitulo where
                         btitulo.empcod = titulo.empcod and
                         btitulo.titnat = titulo.titnat and
                         btitulo.modcod = titulo.modcod and
                         btitulo.etbcod = titulo.etbcod and
                         btitulo.clifor = titulo.clifor and
                         btitulo.titnum = titulo.titnum
                         no-lock:
                    if btitulo.titpar = 0
                    then p-entra = btitulo.titpar.
                    else do:
                        vparcela = btitulo.titpar.
                        vparcial = no.
                        run retorna-titpar-financeira.p(input recid(btitulo),
                                        input-output vparcela,
                                        output vparcial).
                        if btitulo.titpar > 30 and vparcela < 30
                        then vparcela = btitulo.titpar.    
                
                        if vparcial
                        then.
                        else p-total   = p-total + btitulo.titvlcob. 
                    end. 
                end.             
            end.                           
                                       
            p-catcod = 99.

            find last contnf where contnf.etbcod = titulo.etbcod and
                  contnf.contnum = int(titulo.titnum)
                                      no-lock no-error.
            if avail contnf
            then do:
                for each movim where movim.etbcod = contnf.etbcod   and
                                       movim.placod = contnf.placod /*and
                                       movim.movtdc = 5*/
                                       no-lock .
                    find produ where produ.procod = movim.procod 
                                no-lock no-error.
                    p-catcod = produ.catcod.
                    if p-catcod = 31 or
                       p-catcod = 41
                    then leave.   
                end.
            end.
            
            assign
                pacnv-principal = 0
                pacnv-acrescimo = 0.
            
            run principal-renda.

            create tt-ClaOPCtb.
            assign
                tt-ClaOPCtb.dtvisao  = vdatref
                tt-ClaOPCtb.tpvisao  = vtpvisao
                tt-ClaOPCtb.modcod   = titulo.modcod
                tt-ClaOPCtb.etbcod   = titulo.etbcod
                tt-ClaOPCtb.clifor   = titulo.clifor
                tt-ClaOPCtb.titnum   = titulo.titnum
                tt-ClaOPCtb.titdtemi = titulo.titdtemi
                tt-ClaOPCtb.cobcod   = p-cobcod
                tt-ClaOPCtb.catcod   = p-catcod
                tt-ClaOPCtb.riscon   = "A"
                .
            
            if avail contrato 
            then assign
                tt-ClaOPCtb.vltotal = contrato.vltotal
                tt-ClaOPCtb.vlentra = contrato.vlentra
                tt-ClaOPCtb.crecod  = contrato.crecod
                .
            else assign
                    tt-ClaOPCtb.vltotal = p-total
                    tt-ClaOPCtb.vlentra = p-entra
                    tt-ClaOPCtb.crecod  = ?
                    .
                         
        end.
        
        if titulo.titdtven > vdatref
        then do:
        
            tt-ClaOPCtb.vencer = tt-ClaOPCtb.vencer + titulo.titvlcob.    
        
            if titulo.titdtven - vdatref > 5400
            then tt-ClaOPCtb.ven-999999 = 
                 tt-ClaOPCtb.ven-999999 + titulo.titvlcob.
            else if titulo.titdtven - vdatref > 1800
            then tt-ClaOPCtb.ven-5400 = 
                 tt-ClaOPCtb.ven-5400 + titulo.titvlcob.
            else if titulo.titdtven - vdatref > 1080
            then tt-ClaOPCtb.ven-1800 = 
                 tt-ClaOPCtb.ven-1800 + titulo.titvlcob.
            else if titulo.titdtven - vdatref > 360
            then tt-ClaOPCtb.ven-1080 = 
                 tt-ClaOPCtb.ven-1080 + titulo.titvlcob.
            else if titulo.titdtven - vdatref > 90
            then tt-ClaOPCtb.ven-360  = 
                 tt-ClaOPCtb.ven-360 + titulo.titvlcob.
            else if titulo.titdtven - vdatref > 0
            then tt-ClaOPCtb.ven-90 = 
                 tt-ClaOPCtb.ven-90 + titulo.titvlcob.
            else tt-ClaOPCtb.ven-00 = 
                 tt-ClaOPCtb.ven-00 + titulo.titvlcob.

            find first seq-mes where
                               seq-mes.ano = year(titulo.titdtven) and
                               seq-mes.mes = month(titulo.titdtven)
                                no-error.
            if avail seq-mes
            then do:
                        
                if p-tj = 0
                then run cal-txjuro-contrato.p(input titulo.titnum,
                                                       output p-tj).
            
                va = 1 + ((p-tj / 100) / 30).
                vb = va.
            
                do vi = 2 to (titulo.titdtven - vdatref):
                    vb = vb * va.
                end.
                
                assign
                    tt-ClaOPCtb.avp-ano[seq-mes.seq] = seq-mes.ano
                    tt-ClaOPCtb.avp-mes[seq-mes.seq] = seq-mes.mes
                    tt-ClaOPCtb.avp-valdia[seq-mes.seq] = 
                                tt-ClaOPCtb.avp-valdia[seq-mes.seq] + 
                                (titulo.titvlcob / vb)
                    tt-ClaOPCtb.avp-vencer[seq-mes.seq] = 
                                tt-ClaOPCtb.avp-vencer[seq-mes.seq] +
                                titulo.titvlcob
                    tt-ClaOPCtb.avp-principal[seq-mes.seq] = 
                                tt-ClaOPCtb.avp-principal[seq-mes.seq] +
                                pacnv-principal
                    tt-ClaOPCtb.avp-renda[seq-mes.seq] = 
                                tt-ClaOPCtb.avp-renda[seq-mes.seq] +
                                pacnv-acrescimo
                    tt-ClaOPCtb.valor-avp = tt-ClaOPCtb.valor-avp +
                                (titulo.titvlcob / vb)
                    .

                find first tt-sqmesavp where 
                        tt-sqmesavp.tpvisao = vtpvisao and
                        tt-sqmesavp.dtvisao = vdatref and
                        tt-sqmesavp.ano     = seq-mes.ano and
                        tt-sqmesavp.mes     = seq-mes.mes and
                        tt-sqmesavp.seq     = seq-mes.seq
                        no-error.
                if not avail tt-sqmesavp
                then do:
                    create tt-sqmesavp.
                    assign
                        tt-sqmesavp.dtvisao = vdatref
                        tt-sqmesavp.tpvisao = vtpvisao
                        tt-sqmesavp.ano     = seq-mes.ano
                        tt-sqmesavp.mes     = seq-mes.mes
                        tt-sqmesavp.seq     = seq-mes.seq
                        .
                end.
                assign
                tt-sqmesavp.avpdia      = tt-sqmesavp.avpdia + 
                                            (titulo.titvlcob / vb)
                tt-sqmesavp.avencer     = tt-sqmesavp.avencer + 
                                            titulo.titvlcob
                tt-sqmesavp.principal   = 
                                tt-sqmesavp.principal + pacnv-principal
                tt-sqmesavp.acrescimo   = 
                                tt-sqmesavp.acrescimo + pacnv-acrescimo
                .
        
                find first tt-sqmesavp where 
                        tt-sqmesavp.tpvisao = vtpvisao and
                        tt-sqmesavp.dtvisao = vdatref and
                        tt-sqmesavp.ano     = year(vdatref) and
                        tt-sqmesavp.mes     = 0 and
                        tt-sqmesavp.seq     = 0
                        no-error.
                if not avail tt-sqmesavp
                then do:
                    create tt-sqmesavp.
                    assign
                        tt-sqmesavp.dtvisao = vdatref
                        tt-sqmesavp.tpvisao = vtpvisao
                        tt-sqmesavp.ano     = year(vdatref)
                        tt-sqmesavp.mes     = 0
                        tt-sqmesavp.seq     = 0
                        .
                end.
                assign
                tt-sqmesavp.avpdia      = tt-sqmesavp.avpdia + 
                                            (titulo.titvlcob / vb)
                tt-sqmesavp.avencer     = tt-sqmesavp.avencer + 
                                            titulo.titvlcob
                tt-sqmesavp.principal   = 
                                tt-sqmesavp.principal + pacnv-principal
                tt-sqmesavp.acrescimo   = 
                                tt-sqmesavp.acrescimo + pacnv-acrescimo
                .
                 
            end.

        end.
        else do:
            
            tt-ClaOPCtb.vencido   = tt-ClaOPCtb.vencido + titulo.titvlcob.
            if tt-ClaOPCtb.matraso < vdatref - titulo.titdtven
            then tt-ClaOPCtb.matraso   = vdatref - titulo.titdtven.

            do vi = 1 to q-nivel:
                if vdatref - titulo.titdtven <= b-dia[vi] 
                then do:
                     if v-risco[vi] > tt-ClaOPCtb.riscon
                     then tt-ClaOPCtb.riscon  = v-risco[vi].
                     if v-risco[vi] > p-riscli
                     then p-riscli = v-risco[vi].
                     leave.
                end.     
            end. 

            find first tt-sqmesavp where 
                        tt-sqmesavp.tpvisao = vtpvisao and
                        tt-sqmesavp.dtvisao = vdatref and
                        tt-sqmesavp.ano     = year(vdatref) and
                        tt-sqmesavp.mes     = 0 and
                        tt-sqmesavp.seq     = 0
                        no-error.
            if not avail tt-sqmesavp
            then do:
                    create tt-sqmesavp.
                    assign
                        tt-sqmesavp.dtvisao = vdatref
                        tt-sqmesavp.tpvisao = vtpvisao
                        tt-sqmesavp.ano     = year(vdatref)
                        tt-sqmesavp.mes     = 0
                        tt-sqmesavp.seq     = 0
                        .
            end.
            assign
                tt-sqmesavp.vencido     = tt-sqmesavp.vencido + 
                                            titulo.titvlcob
                tt-sqmesavp.principal   = 
                                tt-sqmesavp.principal + pacnv-principal
                tt-sqmesavp.acrescimo   = 
                                tt-sqmesavp.acrescimo + pacnv-acrescimo
                .
 

        end.
        assign
            tt-ClaOPCtb.principal = tt-ClaOPCtb.principal + pacnv-principal
            tt-ClaOPCtb.renda     = tt-ClaOPCtb.renda + pacnv-acrescimo
            tt-ClaOPCtb.qtdparab  = tt-ClaOPCtb.qtdparab + 1
            .
                        
        if tt-ClaOPCtb.qtdpar < titulo.titpar
        then tt-ClaOPCtb.qtdpar = titulo.titpar.
        
    end.

    find first tt-ClaOPCtb where
           tt-ClaOPCtb.clifor = wclien.clicod
           no-error.
    if not avail tt-ClaOPCtb then next.           

    tot-vencido = 0.
    for each tt-ClaOPCtb where 
         tt-ClaOPCtb.clifor = wclien.clicod 
         no-lock:
        create ClaOPCtb.
        buffer-copy tt-ClaOPCtb to ClaOPCtb.
        ClaOPCtb.riscli = p-riscli.
    end.

    for each tt-sqmesavp:
        find first sqmesavp where 
                   sqmesavp.tpvisao = vtpvisao and
                   sqmesavp.dtvisao = vdatref and
                   sqmesavp.ano     = tt-sqmesavp.ano and
                   sqmesavp.mes     = tt-sqmesavp.mes and
                   sqmesavp.seq     = tt-sqmesavp.seq
                   no-error.
        if not avail sqmesavp
        then do:
                create sqmesavp.
                assign
                    sqmesavp.dtvisao = vdatref
                    sqmesavp.tpvisao = vtpvisao
                    sqmesavp.ano     = tt-sqmesavp.ano
                    sqmesavp.mes     = tt-sqmesavp.mes
                    sqmesavp.seq     = tt-sqmesavp.seq
                    .
        end.
        assign
            sqmesavp.avpdia      = sqmesavp.avpdia + tt-sqmesavp.avpdia 
            sqmesavp.vencido     = sqmesavp.vencido + tt-sqmesavp.vencido
            sqmesavp.avencer     = sqmesavp.avencer + tt-sqmesavp.avencer
            sqmesavp.principal   = 
                            sqmesavp.principal + tt-sqmesavp.principal 
            sqmesavp.acrescimo   = 
                            sqmesavp.acrescimo + tt-sqmesavp.acrescimo 
            .
    end.
        
/*******************************

for each tt-cli: delete tt-cli. end.

def var vdifer as dec.
def var vtotpro as dec.
def var vtotal-sal as dec format ">>>,>>>,>>9.99".
vtotal-sal = 0.

for each ClasOPC use-index indx7 where
         ClasOPC.dtvisao = vdatref and
         ClasOPC.tpvisao = vtpvisao and
         ClasOPC.clifor = wclien.clicod and
         ClasOPC.situacao = "" 
         :

    
    run gera-prodevdu-contrato(input vdatref,
                      input "GERENCIAL",
                      input "CONTRATO",
                      input ?,
                      input ?,
                      input ClasOPC.modcod,
                      input ClasOPC.riscon).
    
    
    run gera-prodevdu-contrato(input vdatref,
                      input "GERENCIAL",
                      input "CONTRATO",
                      input ClasOPC.cobcod,
                      input ?,
                      input ClasOPC.modcod,
                      input ClasOPC.riscon).

    run gera-prodevdu-contrato(input vdatref,
                      input "GERENCIAL",
                      input "CONTRATO",
                      input ?,
                      input ClasOPC.catcod,
                      input ClasOPC.modcod,
                      input ClasOPC.riscon).
 
     run gera-prodevdu-contrato(input vdatref,
                      input "GERENCIAL",
                      input "CONTRATO",
                      input ClasOPC.cobcod,
                      input ClasOPC.catcod,
                      input ClasOPC.modcod,
                      input ClasOPC.riscon).
 
    
    run gera-ttcli(input ClasOPC.clifor,
                   input ?,
                   input ?,
                   input ClasOPC.modcod).
    
    
    run gera-ttcli(input ClasOPC.clifor,
                   input ClasOPC.cobcod,
                   input ?,
                   input ClasOPC.modcod).

    run gera-ttcli(input ClasOPC.clifor,
                   input ?,
                   input ClasOPC.catcod,
                   input ClasOPC.modcod).

    run gera-ttcli(input ClasOPC.clifor,
                   input ClasOPC.cobcod,
                   input ClasOPC.catcod,
                   input ClasOPC.modcod).
               

    if ClasOPC.crecod = 500
    then do:
        run gera-prodevdu-contrato(input vdatref,
                      input "GERENCIAL",
                      input "CONTRATO",
                      input ?,
                      input 500,
                      input ?,
                      input ClasOPC.riscon).
 
        run gera-prodevdu-contrato(input vdatref,
                      input "GERENCIAL",
                      input "CONTRATO",
                      input ClasOPC.cobcod,
                      input 500,
                      input ?,
                      input ClasOPC.riscon).
 
        run gera-prodevdu-contrato(input vdatref,
                      input "GERENCIAL",
                      input "CONTRATO",
                      input ?,
                      input 500,
                      input ClasOPC.modcod,
                      input ClasOPC.riscon).
 
        run gera-prodevdu-contrato(input vdatref,
                      input "GERENCIAL",
                      input "CONTRATO",
                      input ClasOPC.cobcod,
                      input 500,
                      input ClasOPC.modcod,
                      input ClasOPC.riscon).
 

        run gera-ttcli(input ClasOPC.clifor,
                   input ?,
                   input 500,
                   input ?).
        run gera-ttcli(input ClasOPC.clifor,
                   input ClasOPC.cobcod,
                   input 500,
                   input ClasOPC.modcod).
        run gera-ttcli(input ClasOPC.clifor,
                   input ?,
                   input 500,
                   input ClasOPC.modcod).
        run gera-ttcli(input ClasOPC.clifor,
                   input ClasOPC.cobcod,
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

for each ClasOPC where
         ClasOPC.dtvisao = vdatref and
         ClasOPC.tpvisao = "GERENCIAL" and
         ClasOPC.clifor  = wclien.clicod and
         ClasOPC.situacao = "":
    find first tt-cli where tt-cli.clicod = ClasOPC.clifor and
                            tt-cli.cobcod = ClasOPC.cobcod and
                            tt-cli.catcod = 0 and
                            tt-cli.modcod = ClasOPC.modcod
                            no-lock no-error.
    if avail tt-cli
    then ClasOPC.riscli = tt-cli.risco.
    else ClasOPC.riscli = ClasOPC.riscon.
end. 

***************************/

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
               titpacnv.modcod = titulo.modcod and
               titpacnv.etbcod = titulo.etbcod and 
               titpacnv.clifor = titulo.clifor and
               titpacnv.titnum = titulo.titnum and
               titpacnv.titdtemi = titulo.titdtemi
                       no-lock no-error.
    if not avail titpacnv
    then do:
        create titpacnv.
        assign
            titpacnv.modcod   = titulo.modcod
            titpacnv.etbcod   = titulo.etbcod
            titpacnv.clifor   = titulo.clifor
            titpacnv.titnum   = titulo.titnum
            titpacnv.titdtemi = titulo.titdtemi
            titpacnv.titvlcob = titulo.titvlcob
            titpacnv.titdes   = titulo.titdes
            .
          
        run retorna-pacnv-valores-contrato.p 
                    (input ?, input ?, input recid(titulo)).

        if  pacnv-principal <= 0 or
            pacnv-acrescimo <= 0
        then assign
                 pacnv-principal = titulo.titvlcob
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
    if ClasOPC.principal_antes = 0
    then assign 
        ClasOPC.principal_antes = ClasOPC.principal
        ClasOPC.renda_antes = ClasOPC.renda.
                            
    assign
        vsaldo_princ = ClasOPC.vencido + ClasOPC.ven-90 + ClasOPC.ven-360 +
                       ClasOPC.ven-1080 + ClasOPC.ven-1800 +
                       ClasOPC.ven-5400 + ClasOPC.ven-9999 
        ClasOPC.renda = vsaldo_princ * vindex_renda
        ClasOPC.principal = vsaldo_princ - ClasOPC.renda.
        
end procedure.     

procedure gera-prodevdu-contrato:

    def input parameter par-data-visao as date.
    def input parameter par-tipo-visao as char.
    def input parameter par-modo-visao as char.
    def input parameter par-cobcod as int .
    def input parameter par-catcod as int .
    def input parameter par-modcod as char .
    def input parameter par-faixa-risco like ClasOPC.riscon.
    
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
            prodevdu.vencidos = prodevdu.vencidos + ClasOPC.vencido
            prodevdu.vencer_9999 = prodevdu.vencer_9999 + ClasOPC.ven-9999
            prodevdu.vencer_5400 = prodevdu.vencer_5400 + ClasOPC.ven-5400
            prodevdu.vencer_1800 = prodevdu.vencer_1800 + ClasOPC.ven-1800
            prodevdu.vencer_1080 = prodevdu.vencer_1080 + ClasOPC.ven-1080
            prodevdu.vencer_360  = prodevdu.vencer_360  + ClasOPC.ven-360
            prodevdu.vencer_90   = prodevdu.vencer_90   + ClasOPC.ven-90
            prodevdu.principal   = prodevdu.principal   + ClasOPC.principal
            prodevdu.renda       = prodevdu.renda       + ClasOPC.renda
            prodevdu.saldo_curva = prodevdu.saldo_curva +
                                   ClasOPC.vencido +
                                   ClasOPC.ven-90 +
                                   ClasOPC.ven-360 +
                                   ClasOPC.ven-1080 +
                                   ClasOPC.ven-1800 +
                                   ClasOPC.ven-5400 +
                                   ClasOPC.ven-9999
                                    .
                                          
        find first tbcntgen where 
                   tbcntgen.tipcon = 13 and
                   tbcntgen.campo1[1] = ClasOPC.riscon no-error.
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
    def input parameter par-faixa-risco like ClasOPC.riscon.

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
   
    def input parameter par-clifor like ClasOPC.clifor.
    def input parameter par-cobcod like ClasOPC.cobcod.
    def input parameter par-catcod like ClasOPC.catcod.
    def input parameter par-modcod like ClasOPC.modcod.
    
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
        tt-cli.qtdpar = tt-cli.qtdpar + ClasOPC.qtdpar
        tt-cli.qtdparab = tt-cli.qtdparab + ClasOPC.qtdparab
        tt-cli.valtotal = tt-cli.valtotal + ClasOPC.vltotal
        tt-cli.vencido  = tt-cli.vencido + ClasOPC.vencido
        tt-cli.vencer   = tt-cli.vencer + ClasOPC.vencer
        tt-cli.valaberto = tt-cli.valaberto + 
                                (ClasOPC.vencido + ClasOPC.vencer)
        tt-cli.principal = tt-cli.principal + ClasOPC.principal
        tt-cli.acrescimo = tt-cli.acrescimo + ClasOPC.renda
        tt-cli.ven-9999  = tt-cli.ven-9999 + ClasOPC.ven-9999
        tt-cli.ven-5400  = tt-cli.ven-5400 + ClasOPC.ven-5400
        tt-cli.ven-1800  = tt-cli.ven-1800 + ClasOPC.ven-1800
        tt-cli.ven-1080  = tt-cli.ven-1080 + ClasOPC.ven-1080
        tt-cli.ven-360   = tt-cli.ven-360  + ClasOPC.ven-360
        tt-cli.ven-90    = tt-cli.ven-90   + ClasOPC.ven-90
        .
    if ClasOPC.riscon > tt-cli.risco
    then tt-cli.risco = ClasOPC.riscon. 
    
end procedure
                               
                               

                               
                               
