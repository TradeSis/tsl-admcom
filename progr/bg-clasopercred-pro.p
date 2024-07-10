{admcab.i}

{retorna-pacnv.i new}

/**
connect ninja -H db2 -S sdrebninja -N tcp.
connect sensei -H 10.2.0.134 -S 60001 -N tcp.
**/

def input parameter vdatref as date.
/*
update vdatref.
*/  
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
def var vsaldo as dec format ">>>,>>>,>>9.99".
def var vrenda as dec format ">>>,>>>,>>9.99".
def var vindex_renda as dec.
/*
update vsaldo label "Saldo contabil" 
       vrenda label "Renda" 
        with frame f-pro.
vindex_renda = vrenda / vsaldo.
*/

def var ttvencido as dec.
def var vq as int.    
def var vt as int.

def var p-cobcod like titulo.cobcod.
def var vmodcod like titulo.modcod.
vmodcod = "CRE".

def var vtotal as dec format ">>>,>>>,>>9.99".
def buffer atitulo for titulo.
def buffer btitulo for titulo.

/*********************/

for each atitulo 
                where
                        atitulo.titnat = no and
                        /*atitulo.modcod = vmodcod and*/
                        atitulo.titdtemi <= vdatref and
                       ((atitulo.titdtpag > vdatref and
                         atitulo.titsit = "PAG") or
                         atitulo.titsit = "LIB")
                        no-lock.

    if atitulo.clifor < 50
    then next.
   
    vmodcod = atitulo.modcod.
    
    /**
    find  ctrsitua where
               ctrsitua.dtsitua  = vdatref and
               ctrsitua.carteira = 10 and
               ctrsitua.contrato = dec(atitulo.titnum)
               no-lock no-error.
    if avail ctrsitua then next.
    **/
    
    vq = vq + 1.
    if vq = 200
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

    p-cobcod = if atitulo.cobcod = 10
               then atitulo.cobcod else 2.
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
                
    find first GClasOPC where
                   GClasOPC.dtvisao = vdatref and
                   GClasOPC.etbcod  = atitulo.etbcod and
                   GClasOPC.clifor  = atitulo.clifor and
                   GClasOPC.titnum  = atitulo.titnum and
                   GClasOPC.cobcod  = p-cobcod
                   no-error.
    if  not avail GClasOPC
    then create GClasOPC.
    
    do:
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
        /*
        disp vtotal with 1 down.
        pause 0.
        */
        find first contrato where contrato.contnum = int(atitulo.titnum)
                            no-lock no-error.
        /*
        create GClasOPC.
        */
        assign
            GClasOPC.dtvisao  = vdatref
            GClasOPC.tpvisao  = "GERENCIAL"
            GClasOPC.modcod   = atitulo.modcod
            GClasOPC.etbcod   = atitulo.etbcod
            GClasOPC.clifor   = atitulo.clifor
            GClasOPC.titnum    = atitulo.titnum
            GClasOPC.titdtemi = atitulo.titdtemi
            GClasOPC.principal = p-principal
            GClasOPC.renda     = p-renda
            GClasOPC.vencido   = p-vencido
            GClasOPC.vencer    = p-vencer
            GClasOPC.qtdpar    = p-qtdpar
            GClasOPC.qtdparab  = p-qtdparab
            GClasOPC.matraso   = p-atraso
            GClasOPC.catcod    = p-catcod
            GClasOPC.riscon    = p-risco
            GClasOPC.cobcod    = p-cobcod
            .
            
        if GClasOPC.principal > (GClasOPC.vencido + GClasOPC.vencer)
        then assign
                GClasOPC.principal = (GClasOPC.vencido + GClasOPC.vencer)
                GClasOPC.renda = 0
                .
                
        if avail contrato and contrato.vltotal = p-total
        then assign
                GClasOPC.vltotal = contrato.vltotal
                GClasOPC.vlentra = contrato.vlentra
                GClasOPC.crecod  = contrato.crecod
                .
        else assign
                GClasOPC.vltotal = p-total
                GClasOPC.vlentra = p-entra
                GClasOPC.crecod  = ?
                .
                         
        assign
            GClasOPC.ven-999999 = pven-9999
            GClasOPC.ven-5400 = pven-5400
            GClasOPC.ven-1800 = pven-1800
            GClasOPC.ven-1080 = pven-1080
            GClasOPC.ven-360  = pven-360
            GClasOPC.ven-90   = pven-90
            .

    end.
end.
/******************/

disp skip "Aguarde gravando ... " with frame f-pro.

for each tt-cli: delete tt-cli. end.

def var vdifer as dec.
def var vtotpro as dec.
def var vtotal-sal as dec format ">>>,>>>,>>9.99".
vtotal-sal = 0.

/****
for each GClasOPC where
         GClasOPC.dtvisao = vdatref and
         GClasOPC.situacao = ""
         :
    find first clien where clien.clicod = GClasOPC.clifor no-lock no-error.
    if not avail clien or
       GClasOPC.ven-999999 > 0 or
       GClasOPC.ven-5400 > 0 or
       GClasOPC.ven-1800 > 0
    then do:
        GClasOPC.situacao = "EXC".
    end.
    else vtotal-sal = vtotal-sal + (GClasOPC.vencido + GClasOPC.vencer).
end.

vdifer = 0.
if vtotal-sal <> vsaldo
then do:
    vdifer = vtotal-sal - vsaldo.
    if vdifer > 0
    then for each GClasOPC where
                  GClasOPC.dtvisao = vdatref and
                  GClasOPC.situacao = "" :
            if vtotpro + (GClasOPC.vencido + GClasOPC.vencer) <= vdifer
            then do:
                vtotpro = vtotpro + (GClasOPC.vencido + GClasOPC.vencer).
                GClasOPC.situacao = "CAN".
            end.
         end.         
end.

***/
                                                                            
for each GClasOPC where
         GClasOPC.dtvisao = vdatref and
         GClasOPC.tpvisao = "GERENCIAL" and
         /*GClasOPC.modcod = "CRE" and
         GClasOPC.cobcod = 2 and*/
         GClasOPC.situacao = ""
         :

    /*     
    run recal-renda.
    */                                
 
    /***************/
    
    run gera-prodevdu-contrato(input vdatref,
                      input "GERENCIAL",
                      input "CONTRATO",
                      input ?,
                      input ?,
                      input GClasOPC.modcod,
                      input GClasOPC.riscon).
    
    
    /**********                    
    find first prodevdu where
                   prodevdu.data_visao  = vdatref and
                   prodevdu.tipo_visao  = "GERENCIAL" and
                   prodevdu.modo_visao  = "CONTRATO"  and
                   prodevdu.cobcod      = GClasOPC.cobcod and
                   prodevdu.categoria   = 0 and
                   prodevdu.modalidade  = GClasOPC.modcod and
                   prodevdu.faixa_risco = GClasOPC.riscon 
                   no-error.
    if not avail prodevdu
    then do:
            create prodevdu.
            assign
                prodevdu.data_visao = vdatref 
                prodevdu.tipo_visao = "GERENCIAL"
                prodevdu.modo_visao = "CONTRATO" 
                prodevdu.cobcod     = GClasOPC.cobcod 
                prodevdu.categoria  = 0 
                prodevdu.modalidade = GClasOPC.modcod 
                prodevdu.faixa_risco = GClasOPC.riscon
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
    ***********************/
    
    
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
 
     /*************************
    find first prodevdu where
                   prodevdu.data_visao = vdatref and
                   prodevdu.tipo_visao = "GERENCIAL" and
                   prodevdu.modo_visao = "CONTRATO"  and
                   prodevdu.cobcod     = GClasOPC.cobcod and
                   prodevdu.categoria  = GClasOPC.catcod and
                   prodevdu.modalidade = GClasOPC.modcod and
                   prodevdu.faixa_risco = GClasOPC.riscon 
                   no-error.
    if not avail prodevdu
    then do:
            create prodevdu.
            assign
                prodevdu.data_visao = vdatref 
                prodevdu.tipo_visao = "GERENCIAL"
                prodevdu.modo_visao = "CONTRATO" 
                prodevdu.cobcod     = GClasOPC.cobcod 
                prodevdu.categoria  = GClasOPC.catcod
                prodevdu.modalidade = GClasOPC.modcod 
                prodevdu.faixa_risco = GClasOPC.riscon
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
    *********************/
    
    run gera-ttcli(input GClasOPC.clifor,
                   input ?,
                   input ?,
                   input GClasOPC.modcod).
    
    /************               
    find first tt-cli where
               tt-cli.clicod = GClasOPC.clifor and
               tt-cli.cobcod = GClasOPC.cobcod and
               tt-cli.catcod = 0 and
               tt-cli.modcod = GClasOPC.modcod no-error.
    if not avail tt-cli
    then do:
        create tt-cli.
        assign
            tt-cli.clicod = GClasOPC.clifor
            tt-cli.cobcod = GClasOPC.cobcod
            tt-cli.catcod = 0
            tt-cli.modcod = GClasOPC.modcod
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
    ************/
    
    
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
               

    /***********************
    find first tt-cli where
               tt-cli.clicod = GClasOPC.clifor and
               tt-cli.cobcod = GClasOPC.cobcod and
               tt-cli.catcod = GClasOPC.catcod and
               tt-cli.modcod = GClasOPC.modcod no-error.
    if not avail tt-cli
    then do:
        create tt-cli.
        assign
            tt-cli.clicod = GClasOPC.clifor
            tt-cli.cobcod = GClasOPC.cobcod
            tt-cli.catcod = GClasOPC.catcod
            tt-cli.modcod = GClasOPC.modcod
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

    ********/

    
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
 
        /*********
          find first prodevdu where
                   prodevdu.data_visao = vdatref and
                   prodevdu.tipo_visao = "GERENCIAL" and
                   prodevdu.modo_visao = "CONTRATO"  and
                   prodevdu.cobcod     = GClasOPC.cobcod and
                   prodevdu.categoria  = GClasOPC.crecod and
                   prodevdu.modalidade = GClasOPC.modcod and
                   prodevdu.faixa_risco = GClasOPC.riscon 
                   no-error.
        if not avail prodevdu
        then do:
            create prodevdu.
            assign
                prodevdu.data_visao = vdatref 
                prodevdu.tipo_visao = "GERENCIAL"
                prodevdu.modo_visao = "CONTRATO" 
                prodevdu.cobcod     = GClasOPC.cobcod 
                prodevdu.categoria  = GClasOPC.crecod
                prodevdu.modalidade = GClasOPC.modcod 
                prodevdu.faixa_risco = GClasOPC.riscon
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
    
        ******/

        run gera-ttcli(input GClasOPC.clifor,
                   input GClasOPC.cobcod,
                   input 500,
                   input GClasOPC.modcod).
        
        /******
        find first tt-cli where
               tt-cli.clicod = GClasOPC.clifor and
               tt-cli.cobcod = GClasOPC.cobcod and
               tt-cli.catcod = GClasOPC.crecod and
               tt-cli.modcod = GClasOPC.modcod no-error.
        if not avail tt-cli
        then do:
            create tt-cli.
            assign
                tt-cli.clicod = GClasOPC.clifor
                tt-cli.cobcod = GClasOPC.cobcod
                tt-cli.catcod = GClasOPC.crecod
                tt-cli.modcod = GClasOPC.modcod
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
        ***********/
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
 
    /*****
    find first prodevdu where
                   prodevdu.data_visao = vdatref and
                   prodevdu.tipo_visao = "GERENCIAL" and
                   prodevdu.modo_visao = "CLIENTE"  and
                   prodevdu.cobcod     = tt-cli.cobcod and
                   prodevdu.categoria  = tt-cli.catcod and
                   prodevdu.modalidade = tt-cli.modcod and
                   prodevdu.faixa_risco = tt-cli.risco 
                   no-error.
    if not avail prodevdu
    then do:
            create prodevdu.
            assign
                prodevdu.data_visao = vdatref 
                prodevdu.tipo_visao = "GERENCIAL"
                prodevdu.modo_visao = "CLIENTE" 
                prodevdu.cobcod     = tt-cli.cobcod 
                prodevdu.categoria  = tt-cli.catcod
                prodevdu.modalidade = tt-cli.modcod 
                prodevdu.faixa_risco = tt-cli.risco
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
    *********/
    
end.

/**********/

for each GClasOPC where
         GClasOPC.dtvisao = vdatref and
         GClasOPC.tpvisao = "GERENCIAL" :
    find first tt-cli where tt-cli.clicod = GClasOPC.clifor and
                            tt-cli.cobcod = GClasOPC.cobcod and
                            tt-cli.catcod = 0 and
                            tt-cli.modcod = GClasOPC.modcod
                            no-lock no-error.
    if avail tt-cli
    then GClasOPC.riscli = tt-cli.risco.
    else GClasOPC.riscli = GClasOPC.riscon.
end. 
hide frame f-pro no-pause.

/***********/

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
          
        run /admcom/custom/Claudir/retorna-pacnv-valores.p 
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
                               
                               

                               
                               
