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

/*
 COPC2015                           
      pdvd2015  
       sqmavp2015
*/

def temp-table tt-COPC2015 like COPC2015.
def temp-table tt-sqmavp2015 like sqmavp2015.

def buffer wclien for clien.
def buffer btitulo for titulo.
def buffer ptitulo for titulo.
def var p-riscli as char.
def var vtpvisao as char.
def var vsq-mes as int.

vtpvisao = "GERENCIAL" + string(month(vdatref),"99")
                       + string(year(vdatref),"9999").


def var vcont as int.

/***********************************

/****
for each titulo where 
                       titulo.titnat = no and
                       titulo.titdtemi <= vdatref and
                       (titulo.titsit = "LIB" or
                            (titulo.titsit = "PAG" and
                             titulo.titdtpag <> ? and
                             titulo.titdtpag > vdatref)) and
                             titulo.cobcod = 10 and
                             titulo.titdtven <> ? 
                        no-lock:  
    
    vcont = vcont + 1.
    if vcont mod 100000 = 0
    then disp vcont with 1 down.
    pause 0.

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
****/


def temp-table tb-titulo like titulo.
input from /admcom/custom/Claudir/tb-titulo.d .
repeat:
    create tb-titulo.
    import tb-titulo.
end.
input close.

for each tb-titulo where 
                       tb-titulo.titnat = no and
                       tb-titulo.titdtemi <= vdatref and
                       (tb-titulo.titsit = "LIB" or
                            (tb-titulo.titsit = "PAG" and
                             tb-titulo.titdtpag <> ? and
                             tb-titulo.titdtpag > vdatref)) and
                             tb-titulo.cobcod = 10 and
                             tb-titulo.titdtven <> ? 
                        no-lock:  
    
    vcont = vcont + 1.
    if vcont mod 100000 = 0
    then disp vcont with 1 down.
    pause 0.

        find first tt-con where
               tt-con.etbcod = tb-titulo.etbcod and
               tt-con.clicod = tb-titulo.clifor and
               tt-con.titnum = tb-titulo.titnum
               no-error.
        if not avail tt-con
        then do:
            create tt-con.
            assign        
                tt-con.etbcod = tb-titulo.etbcod
                 tt-con.clicod = tb-titulo.clifor
                tt-con.titnum = tb-titulo.titnum
                tt-con.titdtemi = tb-titulo.titdtemi.
        end. 
end.


for each tt-con no-lock,
    first wclien where wclien.clicod = tt-con.clicod no-lock:
    
    qcli = qcli + 1.
    if qcli = 200 
    then do:
        disp wclien.clicod wclien.clinom with frame f-pro.
        pause 0.
        qcli = 0.
    end.
    find first COPC2015 where   COPC2015.tpvisao = vtpvisao and
                                COPC2015.dtvisao = vdatref and
                                COPC2015.clifor  = wclien.clicod and
                                COPC2015.titnum  = tt-con.titnum and
                                COPC2015.etbcod  = tt-con.etbcod
                                no-lock no-error.
    if avail COPC2015 then next. 
    for each tt-COPC2015: delete tt-COPC2015. end.
    for each tt-sqmavp2015: delete tt-sqmavp2015. end.

    p-riscli = "A".

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
        if year(titulo.titdtven) > 2040 then next.
 
        vmodcod = titulo.modcod.
        p-cobcod = titulo.cobcod.
        if p-cobcod = 1 then p-cobcod = 2.

        /*if p-cobcod > 9 then next.
          */
          
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
        
        find first tt-COPC2015 where
                   tt-COPC2015.tpvisao = vtpvisao and
                   tt-COPC2015.dtvisao = vdatref and
                   tt-COPC2015.clifor  = titulo.clifor and
                   tt-COPC2015.titnum  = titulo.titnum and
                   tt-COPC2015.etbcod  = titulo.etbcod 
                   no-error.
        if  not avail tt-COPC2015
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

            create tt-COPC2015.
            assign
                tt-COPC2015.dtvisao  = vdatref
                tt-COPC2015.tpvisao  = vtpvisao
                tt-COPC2015.modcod   = titulo.modcod
                tt-COPC2015.etbcod   = titulo.etbcod
                tt-COPC2015.clifor   = titulo.clifor
                tt-COPC2015.titnum   = titulo.titnum
                tt-COPC2015.titdtemi = titulo.titdtemi
                tt-COPC2015.cobcod   = p-cobcod
                tt-COPC2015.catcod   = p-catcod
                tt-COPC2015.riscon   = "A"
                .
            
            if avail contrato 
            then assign
                tt-COPC2015.vltotal = contrato.vltotal
                tt-COPC2015.vlentra = contrato.vlentra
                tt-COPC2015.crecod  = contrato.crecod
                .
            else assign
                    tt-COPC2015.vltotal = p-total
                    tt-COPC2015.vlentra = p-entra
                    tt-COPC2015.crecod  = ?
                    .
                         
        end.
        
        if titulo.titdtven > vdatref
        then do:
        
            tt-COPC2015.vencer = tt-COPC2015.vencer + titulo.titvlcob.    
        
            if titulo.titdtven - vdatref > 5400
            then tt-COPC2015.ven-999999 = 
                 tt-COPC2015.ven-999999 + titulo.titvlcob.
            else if titulo.titdtven - vdatref > 1800
            then tt-COPC2015.ven-5400 = 
                 tt-COPC2015.ven-5400 + titulo.titvlcob.
            else if titulo.titdtven - vdatref > 1080
            then tt-COPC2015.ven-1800 = 
                 tt-COPC2015.ven-1800 + titulo.titvlcob.
            else if titulo.titdtven - vdatref > 360
            then tt-COPC2015.ven-1080 = 
                 tt-COPC2015.ven-1080 + titulo.titvlcob.
            else if titulo.titdtven - vdatref > 90
            then tt-COPC2015.ven-360  = 
                 tt-COPC2015.ven-360 + titulo.titvlcob.
            else if titulo.titdtven - vdatref > 0
            then tt-COPC2015.ven-90 = 
                 tt-COPC2015.ven-90 + titulo.titvlcob.
            else tt-COPC2015.ven-00 = 
                 tt-COPC2015.ven-00 + titulo.titvlcob.

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
                    tt-COPC2015.avp-ano[seq-mes.seq] = seq-mes.ano
                    tt-COPC2015.avp-mes[seq-mes.seq] = seq-mes.mes
                    tt-COPC2015.avp-valdia[seq-mes.seq] = 
                                tt-COPC2015.avp-valdia[seq-mes.seq] + 
                                (titulo.titvlcob / vb)
                    tt-COPC2015.avp-vencer[seq-mes.seq] = 
                                tt-COPC2015.avp-vencer[seq-mes.seq] +
                                titulo.titvlcob
                    tt-COPC2015.avp-principal[seq-mes.seq] = 
                                tt-COPC2015.avp-principal[seq-mes.seq] +
                                pacnv-principal
                    tt-COPC2015.avp-renda[seq-mes.seq] = 
                                tt-COPC2015.avp-renda[seq-mes.seq] +
                                pacnv-acrescimo
                    tt-COPC2015.valor-avp = tt-COPC2015.valor-avp +
                                (titulo.titvlcob / vb)
                    .

                find first tt-sqmavp2015 where 
                        tt-sqmavp2015.tpvisao = vtpvisao and
                        tt-sqmavp2015.dtvisao = vdatref and
                        tt-sqmavp2015.ano     = seq-mes.ano and
                        tt-sqmavp2015.mes     = seq-mes.mes and
                        tt-sqmavp2015.seq     = seq-mes.seq
                        no-error.
                if not avail tt-sqmavp2015
                then do:
                    create tt-sqmavp2015.
                    assign
                        tt-sqmavp2015.dtvisao = vdatref
                        tt-sqmavp2015.tpvisao = vtpvisao
                        tt-sqmavp2015.ano     = seq-mes.ano
                        tt-sqmavp2015.mes     = seq-mes.mes
                        tt-sqmavp2015.seq     = seq-mes.seq
                        .
                end.
                assign
                tt-sqmavp2015.avpdia      = tt-sqmavp2015.avpdia + 
                                            (titulo.titvlcob / vb)
                tt-sqmavp2015.avencer     = tt-sqmavp2015.avencer + 
                                            titulo.titvlcob
                tt-sqmavp2015.principal   = 
                                tt-sqmavp2015.principal + pacnv-principal
                tt-sqmavp2015.acrescimo   = 
                                tt-sqmavp2015.acrescimo + pacnv-acrescimo
                .
        
                find first tt-sqmavp2015 where 
                        tt-sqmavp2015.tpvisao = vtpvisao and
                        tt-sqmavp2015.dtvisao = vdatref and
                        tt-sqmavp2015.ano     = year(vdatref) and
                        tt-sqmavp2015.mes     = 0 and
                        tt-sqmavp2015.seq     = 0
                        no-error.
                if not avail tt-sqmavp2015
                then do:
                    create tt-sqmavp2015.
                    assign
                        tt-sqmavp2015.dtvisao = vdatref
                        tt-sqmavp2015.tpvisao = vtpvisao
                        tt-sqmavp2015.ano     = year(vdatref)
                        tt-sqmavp2015.mes     = 0
                        tt-sqmavp2015.seq     = 0
                        .
                end.
                assign
                tt-sqmavp2015.avpdia      = tt-sqmavp2015.avpdia + 
                                            (titulo.titvlcob / vb)
                tt-sqmavp2015.avencer     = tt-sqmavp2015.avencer + 
                                            titulo.titvlcob
                tt-sqmavp2015.principal   = 
                                tt-sqmavp2015.principal + pacnv-principal
                tt-sqmavp2015.acrescimo   = 
                                tt-sqmavp2015.acrescimo + pacnv-acrescimo
                .
                 
            end.

        end.
        else do:
            
            tt-COPC2015.vencido   = tt-COPC2015.vencido + titulo.titvlcob.
            if tt-COPC2015.matraso < vdatref - titulo.titdtven
            then tt-COPC2015.matraso   = vdatref - titulo.titdtven.

            do vi = 1 to q-nivel:
                if vdatref - titulo.titdtven <= b-dia[vi] 
                then do:
                     if v-risco[vi] > tt-COPC2015.riscon
                     then tt-COPC2015.riscon  = v-risco[vi].
                     if v-risco[vi] > p-riscli
                     then p-riscli = v-risco[vi].
                     leave.
                end.     
            end. 

            find first tt-sqmavp2015 where 
                        tt-sqmavp2015.tpvisao = vtpvisao and
                        tt-sqmavp2015.dtvisao = vdatref and
                        tt-sqmavp2015.ano     = year(vdatref) and
                        tt-sqmavp2015.mes     = 0 and
                        tt-sqmavp2015.seq     = 0
                        no-error.
            if not avail tt-sqmavp2015
            then do:
                    create tt-sqmavp2015.
                    assign
                        tt-sqmavp2015.dtvisao = vdatref
                        tt-sqmavp2015.tpvisao = vtpvisao
                        tt-sqmavp2015.ano     = year(vdatref)
                        tt-sqmavp2015.mes     = 0
                        tt-sqmavp2015.seq     = 0
                        .
            end.
            assign
                tt-sqmavp2015.vencido     = tt-sqmavp2015.vencido + 
                                            titulo.titvlcob
                tt-sqmavp2015.principal   = 
                                tt-sqmavp2015.principal + pacnv-principal
                tt-sqmavp2015.acrescimo   = 
                                tt-sqmavp2015.acrescimo + pacnv-acrescimo
                .
 

        end.
        assign
            tt-COPC2015.principal = tt-COPC2015.principal + pacnv-principal
            tt-COPC2015.renda     = tt-COPC2015.renda + pacnv-acrescimo
            tt-COPC2015.qtdparab  = tt-COPC2015.qtdparab + 1
            .
                        
        if tt-COPC2015.qtdpar < titulo.titpar
        then tt-COPC2015.qtdpar = titulo.titpar.
        
    end.

    find first tt-COPC2015 where
           tt-COPC2015.clifor = wclien.clicod
           no-error.
    if not avail tt-COPC2015 then next.           

    tot-vencido = 0.
    for each tt-COPC2015 where 
         tt-COPC2015.clifor = wclien.clicod 
         no-lock:
        create COPC2015.
        buffer-copy tt-COPC2015 to COPC2015.
        COPC2015.riscli = p-riscli.
    end.

    for each tt-sqmavp2015:
        find first sqmavp2015 where 
                   sqmavp2015.tpvisao = vtpvisao and
                   sqmavp2015.dtvisao = vdatref and
                   sqmavp2015.ano     = tt-sqmavp2015.ano and
                   sqmavp2015.mes     = tt-sqmavp2015.mes and
                   sqmavp2015.seq     = tt-sqmavp2015.seq
                   no-error.
        if not avail sqmavp2015
        then do:
                create sqmavp2015.
                assign
                    sqmavp2015.dtvisao = vdatref
                    sqmavp2015.tpvisao = vtpvisao
                    sqmavp2015.ano     = tt-sqmavp2015.ano
                    sqmavp2015.mes     = tt-sqmavp2015.mes
                    sqmavp2015.seq     = tt-sqmavp2015.seq
                    .
        end.
        assign
            sqmavp2015.avpdia      = sqmavp2015.avpdia + tt-sqmavp2015.avpdia 
            sqmavp2015.vencido     = sqmavp2015.vencido + tt-sqmavp2015.vencido
            sqmavp2015.avencer     = sqmavp2015.avencer + tt-sqmavp2015.avencer
            sqmavp2015.principal   = 
                            sqmavp2015.principal + tt-sqmavp2015.principal 
            sqmavp2015.acrescimo   = 
                            sqmavp2015.acrescimo + tt-sqmavp2015.acrescimo 
            .
    end.
        
*******************************/

for each tt-cli: delete tt-cli. end.

def var vdifer as dec.
def var vtotpro as dec.
def var vtotal-sal as dec format ">>>,>>>,>>9.99".
vtotal-sal = 0.

def var vtpfaixa as char.
/*
vtpfaixa = "CONTABIL" + string(month(vdatref),"99")
                       + string(year(vdatref),"9999").
*/
vtpfaixa = "CTBECD" + string(month(vdatref),"99")
                       + string(year(vdatref),"9999").

                
for each COPC2015  where
         COPC2015.dtvisao = vdatref and
         COPC2015.tpvisao = vtpvisao /*and
         /*COPC2015.clifor = */
         COPC2015.situacao <> "FORAECD"*/ 
         :
    
    run gera-pdvd2015-contrato(input vdatref,
                      input vtpfaixa,
                      input "CONTRATO",
                      input ?,
                      input ?,
                      input "CRE",
                      input COPC2015.riscon).
    
    /****
    run gera-pdvd2015-contrato(input vdatref,
                      input "GERENCIAL",
                      input "CONTRATO",
                      input COPC2015.cobcod,
                      input ?,
                      input COPC2015.modcod,
                      input COPC2015.riscon).

    run gera-pdvd2015-contrato(input vdatref,
                      input "GERENCIAL",
                      input "CONTRATO",
                      input ?,
                      input COPC2015.catcod,
                      input COPC2015.modcod,
                      input COPC2015.riscon).
 
     run gera-pdvd2015-contrato(input vdatref,
                      input "GERENCIAL",
                      input "CONTRATO",
                      input COPC2015.cobcod,
                      input COPC2015.catcod,
                      input COPC2015.modcod,
                      input COPC2015.riscon).
 
    ***/
    
    run gera-ttcli(input COPC2015.clifor,
                   input ?,
                   input ?,
                   input "CRE").
    
    /***
    run gera-ttcli(input COPC2015.clifor,
                   input COPC2015.cobcod,
                   input ?,
                   input COPC2015.modcod).

    run gera-ttcli(input COPC2015.clifor,
                   input ?,
                   input COPC2015.catcod,
                   input COPC2015.modcod).

    run gera-ttcli(input COPC2015.clifor,
                   input COPC2015.cobcod,
                   input COPC2015.catcod,
                   input COPC2015.modcod).
               

    if ClasOPC.crecod = 500
    then do:
        run gera-pdvd2015-contrato(input vdatref,
                      input "GERENCIAL",
                      input "CONTRATO",
                      input ?,
                      input 500,
                      input ?,
                      input COPC2015.riscon).
 
        run gera-pdvd2015-contrato(input vdatref,
                      input "GERENCIAL",
                      input "CONTRATO",
                      input COPC2015.cobcod,
                      input 500,
                      input ?,
                      input COPC2015.riscon).
 
        run gera-pdvd2015-contrato(input vdatref,
                      input "GERENCIAL",
                      input "CONTRATO",
                      input ?,
                      input 500,
                      input COPC2015.modcod,
                      input COPC2015.riscon).
 
        run gera-pdvd2015-contrato(input vdatref,
                      input "GERENCIAL",
                      input "CONTRATO",
                      input COPC2015.cobcod,
                      input 500,
                      input COPC2015.modcod,
                      input COPC2015.riscon).
 

        run gera-ttcli(input COPC2015.clifor,
                   input ?,
                   input 500,
                   input ?).
        run gera-ttcli(input COPC2015.clifor,
                   input COPC2015.cobcod,
                   input 500,
                   input COPC2015.modcod).
        run gera-ttcli(input COPC2015.clifor,
                   input ?,
                   input 500,
                   input COPC2015.modcod).
        run gera-ttcli(input COPC2015.clifor,
                   input COPC2015.cobcod,
                   input 500,
                   input ?).
                   
    end. 
    ****/
end.

for each tt-cli:

    run gera-pdvd2015-cliente(input vdatref,
                      input vtpfaixa,
                      input "CLIENTE",
                      input tt-cli.cobcod,
                      input tt-cli.catcod,
                      input tt-cli.modcod,
                      input tt-cli.risco).
 
    
end.

/**********/

for each COPC2015 where
         COPC2015.dtvisao = vdatref and
         COPC2015.tpvisao = vtpvisao /*and
         /*COPC2015.clifor = */
         COPC2015.situacao <> "FORAECD"*/:
    find first tt-cli where tt-cli.clicod = COPC2015.clifor and
                            tt-cli.cobcod = COPC2015.cobcod and
                            tt-cli.catcod = 0 and
                            tt-cli.modcod = "CRE"
                            no-lock no-error.
    if avail tt-cli
    then COPC2015.riscli = tt-cli.risco.
    else COPC2015.riscli = COPC2015.riscon.
end. 

/***************************/

/*end.*/

hide frame f-pro no-pause.


def var ven-cido as char.
def var ven-cer  as char.
def var avp-dia  as char.
def var varquivo as char.
def var prin-cipal as char.
def var acres-cimo as char.

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
    if COPC2015.principal_antes = 0
    then assign 
        COPC2015.principal_antes = COPC2015.principal
        COPC2015.renda_antes = COPC2015.renda.
                            
    assign
        vsaldo_princ = COPC2015.vencido + COPC2015.ven-90 + COPC2015.ven-360 +
                       COPC2015.ven-1080 + COPC2015.ven-1800 +
                       COPC2015.ven-5400 + COPC2015.ven-9999 
        COPC2015.renda = vsaldo_princ * vindex_renda
        COPC2015.principal = vsaldo_princ - COPC2015.renda.
        
end procedure.     

procedure gera-pdvd2015-contrato:

    def input parameter par-data-visao as date.
    def input parameter par-tipo-visao as char.
    def input parameter par-modo-visao as char.
    def input parameter par-cobcod as int .
    def input parameter par-catcod as int .
    def input parameter par-modcod as char .
    def input parameter par-faixa-risco like ClasOPC.riscon.
    
    find first pdvd2015 where
                   pdvd2015.data_visao  = par-data-visao and
                   pdvd2015.tipo_visao  = par-tipo-visao and
                   pdvd2015.modo_visao  = par-modo-visao and
                   pdvd2015.cobcod      = par-cobcod and
                   pdvd2015.categoria   = par-catcod and
                   pdvd2015.modalidade  = par-modcod and
                   pdvd2015.faixa_risco = par-faixa-risco 
                   no-error.
    if not avail pdvd2015
    then do:
            create pdvd2015.
            assign
                pdvd2015.data_visao = par-data-visao 
                pdvd2015.tipo_visao = par-tipo-visao
                pdvd2015.modo_visao = par-modo-visao 
                pdvd2015.cobcod     = par-cobcod 
                pdvd2015.categoria  = par-catcod 
                pdvd2015.modalidade = par-modcod 
                pdvd2015.faixa_risco = par-faixa-risco
                .
    end. 
    assign
            pdvd2015.vencidos = pdvd2015.vencidos + COPC2015.vencido
            pdvd2015.vencer_9999 = pdvd2015.vencer_9999 + COPC2015.ven-9999
            pdvd2015.vencer_5400 = pdvd2015.vencer_5400 + COPC2015.ven-5400
            pdvd2015.vencer_1800 = pdvd2015.vencer_1800 + COPC2015.ven-1800
            pdvd2015.vencer_1080 = pdvd2015.vencer_1080 + COPC2015.ven-1080
            pdvd2015.vencer_360  = pdvd2015.vencer_360  + COPC2015.ven-360
            pdvd2015.vencer_90   = pdvd2015.vencer_90   + COPC2015.ven-90
            pdvd2015.principal   = pdvd2015.principal   + COPC2015.principal
            pdvd2015.renda       = pdvd2015.renda       + COPC2015.renda
            pdvd2015.saldo_curva = pdvd2015.saldo_curva +
                                   COPC2015.vencido +
                                   COPC2015.ven-90 +
                                   COPC2015.ven-360 +
                                   COPC2015.ven-1080 +
                                   COPC2015.ven-1800 +
                                   COPC2015.ven-5400 +
                                   COPC2015.ven-9999
                                    .
                                          
        find first tbcntgen where 
                   tbcntgen.tipcon = 13 and
                   tbcntgen.campo1[1] = COPC2015.riscon no-error.
        pdvd2015.descricao_faixa =  tbcntgen.numini + "-" +
                                    tbcntgen.numfim.
        pdvd2015.provisao = pdvd2015.saldo_curva * (tbcntgen.valor / 100).
        pdvd2015.pctprovisao = tbcntgen.valor.

end procedure.
 
procedure gera-pdvd2015-cliente:

    def input parameter par-data-visao as date.
    def input parameter par-tipo-visao as char.
    def input parameter par-modo-visao as char.
    def input parameter par-cobcod as int .
    def input parameter par-catcod as int .
    def input parameter par-modcod as char .
    def input parameter par-faixa-risco like ClasOPC.riscon.

    find first pdvd2015 where
                   pdvd2015.data_visao  = par-data-visao and
                   pdvd2015.tipo_visao  = par-tipo-visao and
                   pdvd2015.modo_visao  = par-modo-visao and
                   pdvd2015.cobcod      = par-cobcod and
                   pdvd2015.categoria   = par-catcod and
                   pdvd2015.modalidade  = par-modcod and
                   pdvd2015.faixa_risco = par-faixa-risco 
                   no-error.
    if not avail pdvd2015
    then do:
            create pdvd2015.
            assign
                pdvd2015.data_visao = par-data-visao 
                pdvd2015.tipo_visao = par-tipo-visao
                pdvd2015.modo_visao = par-modo-visao 
                pdvd2015.cobcod     = par-cobcod 
                pdvd2015.categoria  = par-catcod 
                pdvd2015.modalidade = par-modcod 
                pdvd2015.faixa_risco = par-faixa-risco
                .
    end. 
    assign
            pdvd2015.vencidos = pdvd2015.vencidos + tt-cli.vencido
            pdvd2015.vencer_9999 = pdvd2015.vencer_9999 + tt-cli.ven-9999
            pdvd2015.vencer_5400 = pdvd2015.vencer_5400 + tt-cli.ven-5400
            pdvd2015.vencer_1800 = pdvd2015.vencer_1800 + tt-cli.ven-1800
            pdvd2015.vencer_1080 = pdvd2015.vencer_1080 + tt-cli.ven-1080
            pdvd2015.vencer_360  = pdvd2015.vencer_360  + tt-cli.ven-360
            pdvd2015.vencer_90   = pdvd2015.vencer_90   + tt-cli.ven-90
            pdvd2015.principal   = pdvd2015.principal   + tt-cli.principal
            pdvd2015.renda       = pdvd2015.renda       + tt-cli.acrescimo
            pdvd2015.saldo_curva = pdvd2015.saldo_curva +
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
        pdvd2015.descricao_faixa =  tbcntgen.numini + "-" +
                                    tbcntgen.numfim.
        pdvd2015.provisao = pdvd2015.saldo_curva * (tbcntgen.valor / 100).
        pdvd2015.pctprovisao = tbcntgen.valor.

end procedure.

procedure gera-ttcli:
   
    def input parameter par-clifor like COPC2015.clifor.
    def input parameter par-cobcod like COPC2015.cobcod.
    def input parameter par-catcod like COPC2015.catcod.
    def input parameter par-modcod like COPC2015.modcod.
    
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
        tt-cli.qtdpar = tt-cli.qtdpar + COPC2015.qtdpar
        tt-cli.qtdparab = tt-cli.qtdparab + COPC2015.qtdparab
        tt-cli.valtotal = tt-cli.valtotal + COPC2015.vltotal
        tt-cli.vencido  = tt-cli.vencido + COPC2015.vencido
        tt-cli.vencer   = tt-cli.vencer + COPC2015.vencer
        tt-cli.valaberto = tt-cli.valaberto + 
                                (COPC2015.vencido + COPC2015.vencer)
        tt-cli.principal = tt-cli.principal + COPC2015.principal
        tt-cli.acrescimo = tt-cli.acrescimo + COPC2015.renda
        tt-cli.ven-9999  = tt-cli.ven-9999 + COPC2015.ven-9999
        tt-cli.ven-5400  = tt-cli.ven-5400 + COPC2015.ven-5400
        tt-cli.ven-1800  = tt-cli.ven-1800 + COPC2015.ven-1800
        tt-cli.ven-1080  = tt-cli.ven-1080 + COPC2015.ven-1080
        tt-cli.ven-360   = tt-cli.ven-360  + COPC2015.ven-360
        tt-cli.ven-90    = tt-cli.ven-90   + COPC2015.ven-90
        .
    if COPC2015.riscon > tt-cli.risco
    then tt-cli.risco = COPC2015.riscon. 
    
end procedure
                               
                               

                               
                               
