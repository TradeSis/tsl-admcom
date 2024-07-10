{admcab.i new}

/**
connect ninja -H db2 -S sdrebninja -N tcp.
connect sensei -H 10.2.0.134 -S 60001 -N tcp.
**/

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

/*
def new shared temp-table tt-principal no-undo
    field clifor like titulo.clifor
    field titnum like titulo.titnum
    field titvlcob like titulo.titvlcob
    field titdes like titulo.titdes
    field principal as dec
    field acrescimo as dec
    index ttp1 clifor titnum.
*/

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
    index i1 clicod  
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


/*def var vdatref as date .
*/
def var vcatcod as int.
/*
update vdatref  label "Data de referencia"
       help "Informe a data de referencia para Vencidos/Vencer."
              vcatcod  label "categoria"
                     help "Informe 31 para MOVEIS ou 41 para MODA."
                           with frame f11 1 down side-label width 80
                                     row 19 no-box.

*/
sresp = no.
message "Confirma processamento referencia " vdatref "?" update sresp.
if not sresp then return.

disp "Aguarde processamento... "
    with frame f-pro 1 down row 10 width 80 no-box
    .
pause 0.
def var ttvencido as dec.
def var vq as int.    
def var vt as int.

def var p-cobcod like titulo.cobcod.
def var vmodcod like titulo.modcod.
vmodcod = "CRE".

def var vtotal as dec format ">>>,>>>,>>9.99".
def buffer atitulo for SC2016G.
def buffer btitulo for SC2016G.

/*********************/

for each atitulo use-index INDX2
                where
                        atitulo.titnat = no and
                        atitulo.titdtemi <= vdatref and
                       ((atitulo.titdtpag > vdatref and
                         atitulo.titsit = "PAG") or
                         atitulo.titsit = "LIB")
                         and atitulo.cobcod <> 10
                        no-lock.

    if atitulo.titdtmovref <> ? and
       atitulo.titdtmovref = 01/01/9000
    then next.

    vq = vq + 1.
    if vq = 200
    then do:
            disp atitulo.titdtemi no-label
                 atitulo.titnum no-label with frame f-pro.
            pause 0.
            vq = 0.
    end.
    if atitulo.titnum = "" or
       length(atitulo.titnum) > 15
    then next. 

    find first tt-con use-index i1 where
                   tt-con.etbcod = atitulo.etbcod and
                   tt-con.clicod = atitulo.clifor and
                   tt-con.titnum = atitulo.titnum
                   no-error.
    if avail tt-con
    then next.
    
    create tt-con.
    assign
        tt-con.etbcod   = atitulo.etbcod
        tt-con.clicod   = atitulo.clifor
        tt-con.titnum   = atitulo.titnum
        tt-con.titdtemi = atitulo.titdtemi
        tt-con.cobcod   = 2 /*if atitulo.cobcod = 10
                then atitulo.cobcod else 2*/
        tt-con.risco  = "A"
        .

    p-cobcod = 2.
    
    assign
        p-principal = 0 p-renda     = 0 p-vencido   = 0 p-vencer    = 0
        p-risco     = "A" p-aberto    = 0 p-qtdpar    = 0 p-qtdparab  = 0
        p-total     = 0 p-entra     = 0 p-atraso    = 0 pven-9999   = 0
        pven-5400   = 0 pven-1800   = 0 pven-1080   = 0 pven-360    = 0
        pven-90     = 0
         .
                
    find first gclasoper where
                   gclasoper.dtvisao = vdatref and
                   gclasoper.etbcod  = atitulo.etbcod and
                   gclasoper.clifor  = atitulo.clifor and
                   gclasoper.titnum  = atitulo.titnum 
                   no-error.
    if  not avail gclasoper
    then do:
        p-catcod = 99.
        
        find first contnf where contnf.etbcod = atitulo.etbcod and
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
        
        for each btitulo where
                     btitulo.empcod = atitulo.empcod and
                     btitulo.titnat = atitulo.titnat and
                     btitulo.modcod = atitulo.modcod and
                     btitulo.etbcod = atitulo.etbcod and
                     btitulo.clifor = atitulo.clifor and
                     btitulo.titnum = atitulo.titnum
                     no-lock:
        
            p-total = p-total + btitulo.titvlcob.

            if btitulo.titpar = 0
            then p-entra = btitulo.titvlcob.

            if btitulo.titpar > p-qtdpar
            then p-qtdpar = btitulo.titpar.
            
            if  btitulo.titdtemi <= vdatref and
                btitulo.titdtmovref <> 01/01/9000 and
               ( btitulo.titsit = "LIB" or
              (btitulo.titsit = "PAG" and
               btitulo.titdtpag > vdatref))
               and btitulo.cobcod <> 10
            then do:
            
                assign
                    p-principal = p-principal + v-principal
                    p-renda = p-renda + v-acrescimo
                    .
            
            
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
                else p-vencer  = p-vencer + btitulo.titvlcob.

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
        disp vtotal with 1 down.
        pause 0.

        find first contrato where contrato.contnum = int(atitulo.titnum)
                            no-lock no-error.
        create gclasoper.
        
        assign
            gclasoper.dtvisao  = vdatref
            gclasoper.tpvisao  = "GERENCIAL"
            gclasoper.modcod   = atitulo.modcod
            gclasoper.etbcod   = atitulo.etbcod
            gclasoper.etbcod   = atitulo.etbcod
            gclasoper.clifor   = atitulo.clifor
            gclasoper.titnum    = atitulo.titnum
            gclasoper.titdtemi = atitulo.titdtemi
            gclasoper.principal = p-principal
            gclasoper.renda     = p-renda
            gclasoper.vencido   = p-vencido
            gclasoper.vencer    = p-vencer
            gclasoper.qtdpar    = p-qtdpar
            gclasoper.qtdparab  = p-qtdparab
            gclasoper.matraso   = p-atraso
            gclasoper.catcod    = p-catcod
            gclasoper.riscon    = p-risco
            gclasoper.cobcod    = p-cobcod
            .
            
        if gclasoper.principal > (gclasoper.vencido + gclasoper.vencer)
        then assign
                gclasoper.principal = (gclasoper.vencido + gclasoper.vencer)
                gclasoper.renda = 0
                .
                
        if avail contrato and contrato.vltotal = p-total
        then assign
                gclasoper.vltotal = contrato.vltotal
                gclasoper.vlentra = contrato.vlentra
                .
        else assign
                gclasoper.vltotal = p-total
                gclasoper.vlentra = p-entra
                    .
                         
        assign
            gclasoper.ven-999999 = pven-9999
            gclasoper.ven-5400 = pven-5400
            gclasoper.ven-1800 = pven-1800
            gclasoper.ven-1080 = pven-1080
            gclasoper.ven-360  = pven-360
            gclasoper.ven-90   = pven-90
            .


        /*
        assign
            tt-con.principal = gclasoper.principal
            tt-con.acrescimo = gclasoper.renda
            tt-con.vencido   = gclasoper.vencido
            tt-con.vencer    = gclasoper.vencer
            tt-con.risco     = gclasoper.riscon
            tt-con.valaberto = gclasoper.vencido + gclasoper.vencer
            tt-con.qtdparab  = gclasoper.qtdparab
            tt-con.ven-9999 = pven-9999
            tt-con.ven-5400 = pven-5400
            tt-con.ven-1800 = pven-1800
            tt-con.ven-1080 = pven-1080
            tt-con.ven-360  = pven-360
            tt-con.ven-90   = pven-90
                .
          */
    end.
end.

/***************************

disp skip "Aguarde gravando ... " with frame f-pro.

for each tt-cli: delete tt-cli. end.

for each gclasoper where
         gclasoper.dtvisao = vdatref and
         gclasoper.tpvisao = "GERENCIAL" and
         gclasoper.modcod = vmodcod
         no-lock:

    find first gprodevdu where
                   gprodevdu.data_visao = vdatref and
                   gprodevdu.tipo_visao = "GERENCIAL" and
                   gprodevdu.modo_visao = "CONTRATO"  and
                   gprodevdu.cobcod     = gclasoper.cobcod and
                    gprodevdu.categoria  = 0 and
                   gprodevdu.modalidade = vmodcod and
                   gprodevdu.faixa_risco = gclasoper.risco 
                   no-error.
    if not avail gprodevdu
    then do:
            create gprodevdu.
            assign
                gprodevdu.data_visao = vdatref 
                gprodevdu.tipo_visao = "GERENCIAL"
                gprodevdu.modo_visao = "CONTRATO" 
                gprodevdu.cobcod     = gclasoper.cobcod 
                gprodevdu.categoria  = 0 
                gprodevdu.modalidade = vmodcod 
                gprodevdu.faixa_risco = gclasoper.risco
                .
    end. 
    assign
            gprodevdu.vencidos = gprodevdu.vencidos + gclasoper.vencido
            gprodevdu.vencer_9999 = gprodevdu.vencer_9999 + gclasoper.ven-9999
            gprodevdu.vencer_5400 = gprodevdu.vencer_5400 + gclasoper.ven-5400
            gprodevdu.vencer_1800 = gprodevdu.vencer_1800 + gclasoper.ven-1800
            gprodevdu.vencer_1080 = gprodevdu.vencer_1080 + gclasoper.ven-1080
            gprodevdu.vencer_360  = gprodevdu.vencer_360  + gclasoper.ven-360
            gprodevdu.vencer_90   = gprodevdu.vencer_90   + gclasoper.ven-90
            gprodevdu.principal   = gprodevdu.principal   + gclasoper.principal
            gprodevdu.renda       = gprodevdu.renda       + gclasoper.renda
            gprodevdu.saldo_curva = gprodevdu.saldo_curva +
                                   gclasoper.vencido +
                                   gclasoper.ven-90 +
                                   gclasoper.ven-360 +
                                   gclasoper.ven-1080 +
                                   gclasoper.ven-1800 +
                                   gclasoper.ven-5400 +
                                   gclasoper.ven-9999
                                    .
                                          
        find first tbcntgen where 
                   tbcntgen.tipcon = 13 and
                   tbcntgen.campo1[1] = gclasoper.risco no-error.
        gprodevdu.descricao_faixa =  tbcntgen.numini + "-" +
                                    tbcntgen.numfim.
        gprodevdu.provisao = gprodevdu.saldo_curva * (tbcntgen.valor / 100).
        gprodevdu.pctprovisao = tbcntgen.valor.
    
    find first gprodevdu where
                   gprodevdu.data_visao = vdatref and
                   gprodevdu.tipo_visao = "GERENCIAL" and
                   gprodevdu.modo_visao = "CONTRATO"  and
                   gprodevdu.cobcod     = gclasoper.cobcod and
                   gprodevdu.categoria  = gclasoper.catcod and
                   gprodevdu.modalidade = vmodcod and
                   gprodevdu.faixa_risco = gclasoper.risco 
                   no-error.
    if not avail gprodevdu
    then do:
            create gprodevdu.
            assign
                gprodevdu.data_visao = vdatref 
                gprodevdu.tipo_visao = "GERENCIAL"
                gprodevdu.modo_visao = "CONTRATO" 
                gprodevdu.cobcod     = gclasoper.cobcod 
                gprodevdu.categoria  = gclasoper.catcod 
                gprodevdu.modalidade = vmodcod 
                gprodevdu.faixa_risco = gclasoper.risco
                .
    end. 
    assign
            gprodevdu.vencidos = gprodevdu.vencidos + gclasoper.vencido
            gprodevdu.vencer_9999 = gprodevdu.vencer_9999 + gclasoper.ven-9999
            gprodevdu.vencer_5400 = gprodevdu.vencer_5400 + gclasoper.ven-5400
            gprodevdu.vencer_1800 = gprodevdu.vencer_1800 + gclasoper.ven-1800
            gprodevdu.vencer_1080 = gprodevdu.vencer_1080 + gclasoper.ven-1080
            gprodevdu.vencer_360  = gprodevdu.vencer_360  + gclasoper.ven-360
            gprodevdu.vencer_90   = gprodevdu.vencer_90   + gclasoper.ven-90
            gprodevdu.principal   = gprodevdu.principal   + gclasoper.principal
            gprodevdu.renda       = gprodevdu.renda       + gclasoper.renda
            gprodevdu.saldo_curva = gprodevdu.saldo_curva +
                                   gclasoper.vencido +
                                   gclasoper.ven-90 +
                                   gclasoper.ven-360 +
                                   gclasoper.ven-1080 +
                                   gclasoper.ven-1800 +
                                   gclasoper.ven-5400 +
                                   gclasoper.ven-9999
                                    .
                                          
        find first tbcntgen where 
                   tbcntgen.tipcon = 13 and
                   tbcntgen.campo1[1] = gclasoper.risco no-error.
        gprodevdu.descricao_faixa =  tbcntgen.numini + "-" +
                                    tbcntgen.numfim.
        gprodevdu.provisao = gprodevdu.saldo_curva * (tbcntgen.valor / 100).
        gprodevdu.pctprovisao = tbcntgen.valor.
                  
    find first tt-cli where
               tt-cli.clicod = gclasoper.clifor and
               tt-cli.cobcod = gclasoper.cobcod and
               tt-cli.catcod = 0 no-error.
    if not avail tt-cli
    then do:
        create tt-cli.
        assign
            tt-cli.clicod = gclasoper.clifor
            tt-cli.cobcod = gclasoper.cobcod
            tt-cli.catcod = 0            .
    end.
    assign
        tt-cli.qtdpar = tt-cli.qtdpar + gclasoper.qtdpar
        tt-cli.qtdparab = tt-cli.qtdparab + gclasoper.qtdparab
        tt-cli.valtotal = tt-cli.valtotal + gclasoper.vltotal
        tt-cli.vencido  = tt-cli.vencido + gclasoper.vencido
        tt-cli.vencer   = tt-cli.vencer + gclasoper.vencer
        tt-cli.valaberto = tt-cli.valaberto + 
                                (gclasoper.vencido + gclasoper.vencer)
        tt-cli.principal = tt-cli.principal + gclasoper.principal
        tt-cli.acrescimo = tt-cli.acrescimo + gclasoper.renda
        tt-cli.ven-9999  = tt-cli.ven-9999 + gclasoper.ven-9999
        tt-cli.ven-5400  = tt-cli.ven-5400 + gclasoper.ven-5400
        tt-cli.ven-1800  = tt-cli.ven-1800 + gclasoper.ven-1800
        tt-cli.ven-1080  = tt-cli.ven-1080 + gclasoper.ven-1080
        tt-cli.ven-360   = tt-cli.ven-360  + gclasoper.ven-360
        tt-cli.ven-90    = tt-cli.ven-90   + gclasoper.ven-90
        .
    if gclasoper.riscon > tt-cli.risco
    then tt-cli.risco = gclasoper.riscon. 
 
    find first tt-cli where
               tt-cli.clicod = gclasoper.clifor and
               tt-cli.cobcod = gclasoper.cobcod and
               tt-cli.catcod = gclasoper.catcod no-error.
    if not avail tt-cli
    then do:
        create tt-cli.
        assign
            tt-cli.clicod = gclasoper.clifor
            tt-cli.cobcod = gclasoper.cobcod
            tt-cli.catcod = gclasoper.catcod
            .
    end.
    assign
        tt-cli.qtdpar = tt-cli.qtdpar + gclasoper.qtdpar
        tt-cli.qtdparab = tt-cli.qtdparab + gclasoper.qtdparab
        tt-cli.valtotal = tt-cli.valtotal + gclasoper.vltotal
        tt-cli.vencido  = tt-cli.vencido + gclasoper.vencido
        tt-cli.vencer   = tt-cli.vencer + gclasoper.vencer
        tt-cli.valaberto = tt-cli.valaberto + 
                                (gclasoper.vencido + gclasoper.vencer)
        tt-cli.principal = tt-cli.principal + gclasoper.principal
        tt-cli.acrescimo = tt-cli.acrescimo + gclasoper.renda
        tt-cli.ven-9999  = tt-cli.ven-9999 + gclasoper.ven-9999
        tt-cli.ven-5400  = tt-cli.ven-5400 + gclasoper.ven-5400
        tt-cli.ven-1800  = tt-cli.ven-1800 + gclasoper.ven-1800
        tt-cli.ven-1080  = tt-cli.ven-1080 + gclasoper.ven-1080
        tt-cli.ven-360   = tt-cli.ven-360  + gclasoper.ven-360
        tt-cli.ven-90    = tt-cli.ven-90   + gclasoper.ven-90
        .
    if gclasoper.riscon > tt-cli.risco
    then tt-cli.risco = gclasoper.riscon. 
 
end.

for each tt-cli where tt-cli.catcod = 0:
    find first gprodevdu where
                   gprodevdu.data_visao = vdatref and
                   gprodevdu.tipo_visao = "GERENCIAL" and
                   gprodevdu.modo_visao = "CLIENTE"  and
                   gprodevdu.cobcod     = tt-cli.cobcod and
                   gprodevdu.categoria  = 0 and
                   gprodevdu.modalidade = vmodcod and
                   gprodevdu.faixa_risco = tt-cli.risco 
                   no-error.
    if not avail gprodevdu
    then do:
            create gprodevdu.
            assign
                gprodevdu.data_visao = vdatref 
                gprodevdu.tipo_visao = "GERENCIAL"
                gprodevdu.modo_visao = "CLIENTE" 
                gprodevdu.cobcod     = tt-cli.cobcod 
                gprodevdu.categoria  = 0 
                gprodevdu.modalidade = vmodcod 
                gprodevdu.faixa_risco = tt-cli.risco
                .
    end. 
    assign
            gprodevdu.vencidos = gprodevdu.vencidos + tt-cli.vencido
            gprodevdu.vencer_9999 = gprodevdu.vencer_9999 + tt-cli.ven-9999
            gprodevdu.vencer_5400 = gprodevdu.vencer_5400 + tt-cli.ven-5400
            gprodevdu.vencer_1800 = gprodevdu.vencer_1800 + tt-cli.ven-1800
            gprodevdu.vencer_1080 = gprodevdu.vencer_1080 + tt-cli.ven-1080
            gprodevdu.vencer_360  = gprodevdu.vencer_360  + tt-cli.ven-360
            gprodevdu.vencer_90   = gprodevdu.vencer_90   + tt-cli.ven-90
            gprodevdu.principal   = gprodevdu.principal   + tt-cli.principal
            gprodevdu.renda       = gprodevdu.renda       + tt-cli.acrescimo
            gprodevdu.saldo_curva = gprodevdu.saldo_curva +
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
        gprodevdu.descricao_faixa =  tbcntgen.numini + "-" +
                                    tbcntgen.numfim.
        gprodevdu.provisao = gprodevdu.saldo_curva * (tbcntgen.valor / 100).
        gprodevdu.pctprovisao = tbcntgen.valor.

end.
for each tt-cli where tt-cli.catcod > 0:
    find first gprodevdu where
                   gprodevdu.data_visao = vdatref and
                   gprodevdu.tipo_visao = "GERENCIAL" and
                   gprodevdu.modo_visao = "CLIENTE"  and
                   gprodevdu.cobcod     = tt-cli.cobcod and
                   gprodevdu.categoria  = tt-cli.catcod and
                   gprodevdu.modalidade = vmodcod and
                   gprodevdu.faixa_risco = tt-cli.risco 
                   no-error.
    if not avail gprodevdu
    then do:
            create gprodevdu.
            assign
                gprodevdu.data_visao = vdatref 
                gprodevdu.tipo_visao = "GERENCIAL"
                gprodevdu.modo_visao = "CLIENTE" 
                gprodevdu.cobcod     = tt-cli.cobcod 
                gprodevdu.categoria  = tt-cli.catcod 
                gprodevdu.modalidade = vmodcod 
                gprodevdu.faixa_risco = tt-cli.risco
                .
    end. 
    assign
            gprodevdu.vencidos = gprodevdu.vencidos + tt-cli.vencido
            gprodevdu.vencer_9999 = gprodevdu.vencer_9999 + tt-cli.ven-9999
            gprodevdu.vencer_5400 = gprodevdu.vencer_5400 + tt-cli.ven-5400
            gprodevdu.vencer_1800 = gprodevdu.vencer_1800 + tt-cli.ven-1800
            gprodevdu.vencer_1080 = gprodevdu.vencer_1080 + tt-cli.ven-1080
            gprodevdu.vencer_360  = gprodevdu.vencer_360  + tt-cli.ven-360
            gprodevdu.vencer_90   = gprodevdu.vencer_90   + tt-cli.ven-90
            gprodevdu.principal   = gprodevdu.principal   + tt-cli.principal
            gprodevdu.renda       = gprodevdu.renda       + tt-cli.acrescimo
            gprodevdu.saldo_curva = gprodevdu.saldo_curva +
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
        gprodevdu.descricao_faixa =  tbcntgen.numini + "-" +
                                    tbcntgen.numfim.
        gprodevdu.provisao = gprodevdu.saldo_curva * (tbcntgen.valor / 100).
        gprodevdu.pctprovisao = tbcntgen.valor.

end.


hide frame f-pro no-pause.

***************************/

/**************************************************
for each tt-con: delete gclasoper. end.
for each tt-cli: delete tt-cli. end.

vmodcod = "GER".

def buffer bsc2016g for sc2016g.

for each sc2016g where  sc2016g.empcod = 19 and
                        sc2016g.titnat = no and
                        sc2016g.modcod = vmodcod and
                        sc2016g.titdtemi <= vdatref and
                       (sc2016g.titsit = "LIB" or
                       (sc2016g.titsit = "PAG" and
                        sc2016g.titdtpag > vdatref))
                        no-lock.
    find first titulo where titulo.empcod = sc2016g.empcod and
                      titulo.titnat = sc2016g.titnat and
                      titulo.modcod = "CRE" and
                      titulo.etbcod = sc2016g.etbcod and
                      titulo.clifor = sc2016g.clifor and
                      titulo.titnum = sc2016g.titnum and
                      titulo.titpar = sc2016g.titpar
                      no-lock no-error.

                                                                             
    vq = vq + 1.
    if vq = 200
    then do:
            disp titulo.titdtemi no-label
                 titulo.titnum no-label with frame f-pro.
            pause 0.
            vq = 0.
    end.
    if titulo.titnum = "" or
       length(titulo.titnum) > 15
    then next.            
    find first tt-con use-index i1 where
                   tt-con.etbcod = titulo.etbcod and
                   tt-con.clicod = titulo.clifor and
                   tt-con.titnum = titulo.titnum
                   no-error.
    if avail tt-con
    then next.
    
    create tt-con.
    assign
        tt-con.etbcod   = titulo.etbcod
        tt-con.clicod   = titulo.clifor
        tt-con.titnum   = titulo.titnum
        tt-con.titdtemi = titulo.titdtemi
        tt-con.cobcod   = if sc2016g.cobcod = 10
                then sc2016g.cobcod else 2
        tt-con.risco  = "A"
        .
    
    assign
        p-principal = 0 p-renda     = 0 p-vencido   = 0 p-vencer    = 0
        p-risco     = "A" p-aberto    = 0 p-qtdpar    = 0 p-qtdparab  = 0
        p-total     = 0 p-entra     = 0 p-atraso    = 0 pven-9999   = 0
        pven-5400   = 0 pven-1800   = 0 pven-1080   = 0 pven-360    = 0
        pven-90     = 0
         .
                
    /*find first gclasoper where
                   gclasoper.dtvisao = vdatref and
                   gclasoper.tpvisao = "GERENCIAL" and
                   gclasoper.cobcod  = tt-con.cobcod and
                   gclasoper.modcod  = titulo.modcod and
                   gclasoper.riscon  = "A" and
                   gclasoper.etbcod  = titulo.etbcod and
                   gclasoper.clifor  = titulo.clifor and
                   gclasoper.titnum  = titulo.titnum 
                   no-error.
    if not avail gclasoper
    then*/ do:
        p-catcod = 0.
        find first contnf where contnf.etbcod = titulo.etbcod and
                   contnf.contnum = int(titulo.titnum)
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
        
        for each btitulo where
                     btitulo.empcod = titulo.empcod and
                     btitulo.titnat = titulo.titnat and
                     btitulo.modcod = titulo.modcod and
                     btitulo.etbcod = titulo.etbcod and
                     btitulo.clifor = titulo.clifor and
                     btitulo.titnum = titulo.titnum
                     no-lock,
            first bsc2016g where bsc2016g.empcod = btitulo.empcod and
                                 bsc2016g.titnat = btitulo.titnat and
                                 bsc2016g.modcod = btitulo.modcod and
                                 bsc2016g.etbcod = btitulo.etbcod and
                                 bsc2016g.clifor = btitulo.clifor and
                                 bsc2016g.titnum = btitulo.titnum and
                                 bsc2016g.titpar = btitulo.titpar and
                                 bsc2016g.titsit = "LIB"
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
                    then p-vencido = p-vencido + btitulo.titvlcob.
                end.
                else p-vencer  = p-vencer + btitulo.titvlcob.

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

        find contrato where contrato.contnum = int(titulo.titnum)
                            no-lock no-error.
        create gclasoper.
        assign
            gclasoper.dtvisao  = vdatref
            gclasoper.tpvisao  = "GERENCIAL"
            gclasoper.modcod   = vmodcod
            gclasoper.etbcod   = titulo.etbcod
            gclasoper.etbcod   = titulo.etbcod
            gclasoper.clifor   = titulo.clifor
            gclasoper.titnum    = titulo.titnum
            gclasoper.titdtemi = titulo.titdtemi
            gclasoper.principal = p-principal
            gclasoper.renda     = p-renda
            gclasoper.vencido   = p-vencido
            gclasoper.vencer    = p-vencer
            gclasoper.qtdpar    = p-qtdpar
            gclasoper.qtdparab  = p-qtdparab
            gclasoper.matraso   = p-atraso
            gclasoper.catcod    = 1
            gclasoper.riscon    = p-risco
            gclasoper.cobcod    = tt-con.cobcod

            .
        if avail contrato and contrato.vltotal = p-total
        then assign
                gclasoper.vltotal = contrato.vltotal
                gclasoper.vlentra = contrato.vlentra
                .
        else assign
                gclasoper.vltotal = p-total
                gclasoper.vlentra = p-entra
                    .
                         
        assign
            gclasoper.ven-999999 = pven-9999
            gclasoper.ven-5400 = pven-5400
            gclasoper.ven-1800 = pven-1800
            gclasoper.ven-1080 = pven-1080
            gclasoper.ven-360  = pven-360
            gclasoper.ven-90   = pven-90
            .

        assign
            tt-con.principal = gclasoper.principal
            tt-con.acrescimo = gclasoper.renda
            tt-con.vencido   = gclasoper.vencido
            tt-con.vencer    = gclasoper.vencer
            tt-con.risco     = gclasoper.riscon
            tt-con.valaberto = gclasoper.vencido + gclasoper.vencer
            tt-con.qtdparab  = gclasoper.qtdparab
            tt-con.ven-9999 = pven-9999
            tt-con.ven-5400 = pven-5400
            tt-con.ven-1800 = pven-1800
            tt-con.ven-1080 = pven-1080
            tt-con.ven-360  = pven-360
            tt-con.ven-90   = pven-90
                .
        
    end.
end.

disp skip "Aguarde gravando ... " with frame f-pro.

for each tt-cli: delete tt-cli. end.

vmodcod = "CRE".
for each tt-con:
    find first gprodevdu where
                   gprodevdu.data_visao = vdatref and
                   gprodevdu.tipo_visao = "GERENCIAL" and
                   gprodevdu.modo_visao = "CONTRATO"  and
                   gprodevdu.cobcod     = tt-con.cobcod and
                   gprodevdu.categoria  = 0 and
                   gprodevdu.modalidade = vmodcod and
                   gprodevdu.faixa_risco = tt-con.risco 
                   no-error.
    if not avail gprodevdu
    then do:
            create gprodevdu.
            assign
                gprodevdu.data_visao = vdatref 
                gprodevdu.tipo_visao = "GERENCIAL"
                gprodevdu.modo_visao = "CONTRATO" 
                gprodevdu.cobcod     = tt-con.cobcod 
                gprodevdu.categoria  = 0 
                gprodevdu.modalidade = vmodcod 
                gprodevdu.faixa_risco = tt-con.risco
                .
    end. 
    assign
            gprodevdu.vencidos = gprodevdu.vencidos + tt-con.vencido
            gprodevdu.vencer_9999 = gprodevdu.vencer_9999 + tt-con.ven-9999
            gprodevdu.vencer_5400 = gprodevdu.vencer_5400 + tt-con.ven-5400
            gprodevdu.vencer_1800 = gprodevdu.vencer_1800 + tt-con.ven-1800
            gprodevdu.vencer_1080 = gprodevdu.vencer_1080 + tt-con.ven-1080
            gprodevdu.vencer_360  = gprodevdu.vencer_360  + tt-con.ven-360
            gprodevdu.vencer_90   = gprodevdu.vencer_90   + tt-con.ven-90
            gprodevdu.principal   = gprodevdu.principal   + tt-con.principal
            gprodevdu.renda       = gprodevdu.renda       + tt-con.acrescimo
            gprodevdu.saldo_curva = gprodevdu.saldo_curva +
                                   tt-con.vencido +
                                   tt-con.ven-90 +
                                   tt-con.ven-360 +
                                   tt-con.ven-1080 +
                                   tt-con.ven-1800 +
                                   tt-con.ven-5400 +
                                   tt-con.ven-9999
                                    .
                                          
        find first tbcntgen where 
                   tbcntgen.tipcon = 13 and
                   tbcntgen.campo1[1] = tt-con.risco no-error.
        gprodevdu.descricao_faixa =  tbcntgen.numini + "-" +
                                    tbcntgen.numfim.
        gprodevdu.provisao = gprodevdu.saldo_curva * (tbcntgen.valor / 100).
        gprodevdu.pctprovisao = tbcntgen.valor.
                 
    find first tt-cli where
               tt-cli.clicod = tt-con.clicod and
               tt-cli.cobcod = tt-con.cobcod no-error.
    if not avail tt-cli
    then do:
        create tt-cli.
        assign
            tt-cli.clicod = tt-con.clicod
            tt-cli.cobcod = tt-con.cobcod
            .
    end.
    assign
        tt-cli.qtdpar = tt-cli.qtdpar + tt-con.qtdpar
        tt-cli.qtdparab = tt-cli.qtdparab + tt-con.qtdparab
        tt-cli.valtotal = tt-cli.valtotal + tt-con.valtotal
        tt-cli.vencido  = tt-cli.vencido + tt-con.vencido
        tt-cli.vencer   = tt-cli.vencer + tt-con.vencer
        tt-cli.valaberto = tt-cli.valaberto + tt-con.valaberto
        tt-cli.principal = tt-cli.principal + tt-con.principal
        tt-cli.acrescimo = tt-cli.acrescimo + tt-con.acrescimo
        tt-cli.ven-9999  = tt-cli.ven-9999 + tt-con.ven-9999
        tt-cli.ven-5400  = tt-cli.ven-5400 + tt-con.ven-5400
        tt-cli.ven-1800  = tt-cli.ven-1800 + tt-con.ven-1800
        tt-cli.ven-1080  = tt-cli.ven-1080 + tt-con.ven-1080
        tt-cli.ven-360   = tt-cli.ven-360  + tt-con.ven-360
        tt-cli.ven-90    = tt-cli.ven-90   + tt-con.ven-90
        .
    if tt-con.risco > tt-cli.risco
    then tt-cli.risco = tt-con.risco. 
    
end.

for each tt-cli:
    find first gprodevdu where
                   gprodevdu.data_visao = vdatref and
                   gprodevdu.tipo_visao = "GERENCIAL" and
                   gprodevdu.modo_visao = "CLIENTE"  and
                   gprodevdu.cobcod     = tt-cli.cobcod and
                   gprodevdu.categoria  = 0 and
                   gprodevdu.modalidade = vmodcod and
                   gprodevdu.faixa_risco = tt-cli.risco 
                   no-error.
    if not avail gprodevdu
    then do:
            create gprodevdu.
            assign
                gprodevdu.data_visao = vdatref 
                gprodevdu.tipo_visao = "GERENCIAL"
                gprodevdu.modo_visao = "CLIENTE" 
                gprodevdu.cobcod     = tt-cli.cobcod 
                gprodevdu.categoria  = 0 
                gprodevdu.modalidade = vmodcod 
                gprodevdu.faixa_risco = tt-cli.risco
                .
    end. 
    assign
            gprodevdu.vencidos = gprodevdu.vencidos + tt-cli.vencido
            gprodevdu.vencer_9999 = gprodevdu.vencer_9999 + tt-cli.ven-9999
            gprodevdu.vencer_5400 = gprodevdu.vencer_5400 + tt-cli.ven-5400
            gprodevdu.vencer_1800 = gprodevdu.vencer_1800 + tt-cli.ven-1800
            gprodevdu.vencer_1080 = gprodevdu.vencer_1080 + tt-cli.ven-1080
            gprodevdu.vencer_360  = gprodevdu.vencer_360  + tt-cli.ven-360
            gprodevdu.vencer_90   = gprodevdu.vencer_90   + tt-cli.ven-90
            gprodevdu.principal   = gprodevdu.principal   + tt-cli.principal
            gprodevdu.renda       = gprodevdu.renda       + tt-cli.acrescimo
            gprodevdu.saldo_curva = gprodevdu.saldo_curva +
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
        gprodevdu.descricao_faixa =  tbcntgen.numini + "-" +
                                    tbcntgen.numfim.
        gprodevdu.provisao = gprodevdu.saldo_curva * (tbcntgen.valor / 100).
        gprodevdu.pctprovisao = tbcntgen.valor.

end.
hide frame f-pro no-pause.
********************************/

procedure principal-renda:
    
    def var p-principal as dec.
    def var p-acrescimo as dec.
    def var p-seguro as dec.
    def var p-juros as dec.
    def var p-crepes as dec.
    
    assign
         p-principal = 0
         p-acrescimo = 0
         p-seguro = 0
         p-juros = 0
         p-crepes = 0.
    
    find first titprinc where
               titprinc.clifor = atitulo.clifor and
               titprinc.titnum = atitulo.titnum 
                       no-lock no-error.
    if not avail titprinc
    then do:
        create titprinc.
        assign
            titprinc.clifor   = atitulo.clifor
            titprinc.titnum   = atitulo.titnum
            titprinc.titvlcob = atitulo.titvlcob
            titprinc.titdes   = atitulo.titdes
            .
          
        find first titulo where
                   titulo.empcod = 19 and
                   titulo.titnat = no and
                   titulo.modcod = atitulo.modcod and
                   titulo.etbcod = atitulo.etbcod and
                   titulo.clifor = atitulo.clifor and
                   titulo.titnum = atitulo.titnum
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
                     p-principal = atitulo.titvlcob
                     p-acrescimo = 0
                     .
            assign
                titprinc.principal = p-principal
                titprinc.acrescimo = p-acrescimo
                .
        end.
        else assign
                 p-principal = atitulo.titvlcob
                 p-acrescimo = 0
                 titprinc.principal = p-principal
                 titprinc.acrescimo = p-acrescimo
                 .          
    end.
    else assign
             p-principal = titprinc.principal
             p-acrescimo = titprinc.acrescimo
             .

    if p-principal >= atitulo.titvlcob
    then assign
             p-principal = atitulo.titvlcob
             p-acrescimo = 0.

    if (p-principal + p-acrescimo) > atitulo.titvlcob
    then p-principal = p-principal - 
               ((p-principal + p-acrescimo) - atitulo.titvlcob).
    else if (p-principal + p-acrescimo) < atitulo.titvlcob     
        then p-principal = p-principal + 
                    (atitulo.titvlcob - (p-principal + p-acrescimo)).
    assign
        v-principal = v-principal + p-principal
        v-acrescimo = v-acrescimo + p-acrescimo
        .
end procedure.

