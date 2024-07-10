{admcab.i}

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

def new shared temp-table tt-principal no-undo
    field clifor like titulo.clifor
    field titnum like titulo.titnum
    field titvlcob like titulo.titvlcob
    field titdes like titulo.titdes
    field principal as dec
    field acrescimo as dec
    index ttp1 clifor titnum.

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

/**
do vi = 1 to q-nivel:
    disp a-dia[vi] b-dia[vi] v-risco[vi] v-pct[vi].
    pause.
end.
**/

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

def buffer btitulo for titulo.

def var vdatref as date .
def var vcatcod as int.
update vdatref  label "Data de referencia"
       help "Informe a data de referencia para Vencidos/Vencer."
              vcatcod  label "categoria"
                     help "Informe 31 para MOVEIS ou 41 para MODA."
                             with frame f11 1 down side-label width 80
                                     row 19 no-box.

disp "Aguarde processamento... "
    with frame f-pro 1 down row 10 width 80 no-box
    .
pause 0.
def var ttvencido as dec.
def var vq as int.    
def var vt as int.

for each titulo where   titulo.empcod = 19 and
                        titulo.titnat = no and
                        titulo.modcod = "CRE" and
                        titulo.titdtemi <= vdatref and
                       (titulo.titsit = "LIB" or
                       (titulo.titsit = "PAG" and
                        titulo.titdtpag > vdatref))
                        no-lock.
    vq = vq + 1.
    if vq = 200
    then do:
            disp titulo.titdtemi no-label
                 titulo.titnum no-label with frame f-pro.
            pause 0.
            vq = 0.
    end.
                
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
        tt-con.cobcod   = if titulo.cobcod = 10
                then titulo.cobcod else 2
        tt-con.risco  = "A"
        .
    
    assign
        p-principal = 0 p-renda     = 0 p-vencido   = 0 p-vencer    = 0
        p-risco     = "A" p-aberto    = 0 p-qtdpar    = 0 p-qtdparab  = 0
        p-total     = 0 p-entra     = 0 p-atraso    = 0 pven-9999   = 0
        pven-5400   = 0 pven-1800   = 0 pven-1080   = 0 pven-360    = 0
        pven-90     = 0
         .
                
    find first clasoper where
                   clasoper.dtvisao = vdatref and
                   clasoper.tpvisao = "gerencial" and
                   clasoper.modcod  = titulo.modcod and
                   clasoper.etbcod = titulo.etbcod and
                   clasoper.clifor = titulo.clifor and
                   clasoper.titnum  = titulo.titnum 
                   no-error.
    if not avail clasoper
    then do:
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
                do vi = 1 to q-nivel:
                    if vdatref - btitulo.titdtven <= b-dia[vi] 
                    then do:
                        p-atraso = vdatref - btitulo.titdtven.
                        if btitulo.titdtven <= vdatref
                        then do:
                            assign
                                p-vencido = p-vencido + btitulo.titvlcob
                                ttvencido = btitulo.titvlcob
                                .
                            if v-risco[vi] > p-risco
                            then p-risco  = v-risco[vi].
                        end.
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
        create clasoper.
        assign
            clasoper.dtvisao  = vdatref
            clasoper.tpvisao  = "gerencial"
            clasoper.modcod   = titulo.modcod
            clasoper.etbcod   = titulo.etbcod
            clasoper.etbcod   = titulo.etbcod
            clasoper.clifor   = titulo.clifor
            clasoper.titnum    = titulo.titnum
            clasoper.titdtemi = titulo.titdtemi
            clasoper.principal = p-principal
            clasoper.renda     = p-renda
            clasoper.vencido   = p-vencido
            clasoper.vencer    = p-vencer
            clasoper.qtdpar    = p-qtdpar
            clasoper.qtdparab  = p-qtdparab
            clasoper.matraso   = p-atraso
            clasoper.catcod    = p-catcod
            clasoper.riscon    = p-risco
            .

        if avail contrato
        then assign
                clasoper.vltotal = contrato.vltotal
                clasoper.vlentra = contrato.vlentra
                .
        else assign
                clasoper.vltotal = p-total
                clasoper.vlentra = p-entra
                    .
                         
        assign
            clasoper.ven-999999 = pven-9999
            clasoper.ven-5400 = pven-5400
            clasoper.ven-1800 = pven-1800
            clasoper.ven-1080 = pven-1080
            clasoper.ven-360  = pven-360
            clasoper.ven-90   = pven-90
            .

        assign
            tt-con.principal = clasoper.principal
            tt-con.acrescimo = clasoper.renda
            tt-con.vencido   = clasoper.vencido
            tt-con.vencer    = clasoper.vencer
            tt-con.risco     = clasoper.riscon
            tt-con.valaberto = clasoper.vencido + clasoper.vencer
            tt-con.qtdparab  = clasoper.qtdparab
            tt-con.ven-9999 = pven-9999
            tt-con.ven-5400 = pven-5400
            tt-con.ven-1800 = pven-1800
            tt-con.ven-1080 = pven-1080
            tt-con.ven-360  = pven-360
            tt-con.ven-90   = pven-90
                .
    end.
    else do:
        /*
        if clasoper.riscon = ""
        then do on error undo:
            clasoper.riscon = "A".
            do vi = 1 to q-nivel:
                if clasoper.matraso <= b-dia[vi] 
                then do:
                    clasoper.riscon = v-risco[vi].
                    leave.
                end.
            end.    
        end.
        */
        assign
            tt-con.principal = clasoper.principal 
            tt-con.acrescimo = clasoper.renda
            tt-con.vencido   = clasoper.vencido
            tt-con.vencer    = clasoper.vencer
            tt-con.risco     = clasoper.riscon
            tt-con.valaberto = clasoper.vencido + clasoper.vencer
            tt-con.qtdparab  = clasoper.qtdparab
            tt-con.ven-9999  = clasoper.ven-999999
            tt-con.ven-5400  = clasoper.ven-5400
            tt-con.ven-1800  = clasoper.ven-1800
            tt-con.ven-1080  = clasoper.ven-1080
            tt-con.ven-360   = clasoper.ven-360
            tt-con.ven-90    = clasoper.ven-90
                 .
    end.
    /*
    vqt = vqt + 1.
    if vqt >= 10000
    then leave.
    */
end.
             
hide frame f-pro no-pause.
clear frame f-pro ALL.

for each tt-con no-lock:
    find first tt-cli where
               tt-cli.clicod = tt-con.clicod no-error.
    if not avail tt-cli
    then do:
        create tt-cli.
        assign
            tt-cli.clicod = tt-con.clicod
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
    
    find first tt-clicob where
               tt-clicob.clicod = tt-con.clicod and
               tt-clicob.cobcod = tt-con.cobcod no-error.
    if not avail tt-clicob
    then do:
        create tt-clicob.
        assign
            tt-clicob.clicod = tt-con.clicod
            tt-clicob.cobcod = tt-con.cobcod
            .
    end.
    assign
        tt-clicob.qtdpar = tt-clicob.qtdpar + tt-con.qtdpar
        tt-clicob.qtdparab = tt-clicob.qtdparab + tt-con.qtdparab
        tt-clicob.valtotal = tt-clicob.valtotal + tt-con.valtotal
        tt-clicob.vencido  = tt-clicob.vencido + tt-con.vencido
        tt-clicob.vencer   = tt-clicob.vencer + tt-con.vencer
        tt-clicob.valaberto = tt-clicob.valaberto + tt-con.valaberto
        tt-clicob.principal = tt-clicob.principal + tt-con.principal
        tt-clicob.acrescimo = tt-clicob.acrescimo + tt-con.acrescimo
        tt-clicob.ven-9999  = tt-clicob.ven-9999 + tt-con.ven-9999
        tt-clicob.ven-5400  = tt-clicob.ven-5400 + tt-con.ven-5400
        tt-clicob.ven-1800  = tt-clicob.ven-1800 + tt-con.ven-1800
        tt-clicob.ven-1080  = tt-clicob.ven-1080 + tt-con.ven-1080
        tt-clicob.ven-360   = tt-clicob.ven-360  + tt-con.ven-360
        tt-clicob.ven-90    = tt-clicob.ven-90   + tt-con.ven-90
        .
    if tt-con.risco > tt-clicob.risco
    then tt-clicob.risco = tt-con.risco.    
              
end.
for each tt-cli: 
    find first tt-risco where
            tt-risco.risco = tt-cli.risco no-error.
    if not avail tt-risco
    then do:
        create tt-risco.
        tt-risco.risco = tt-cli.risco.
    end.    
    assign
        tt-risco.vencido = tt-risco.vencido + tt-cli.vencido
        tt-risco.vencer  = tt-risco.vencer  + tt-cli.vencer
        tt-risco.principal = tt-risco.principal + tt-cli.principal
        tt-risco.acrescimo = tt-risco.acrescimo + tt-cli.acrescimo
        tt-risco.ven-9999  = tt-risco.ven-9999 + tt-cli.ven-9999
        tt-risco.ven-5400  = tt-risco.ven-5400 + tt-cli.ven-5400
        tt-risco.ven-1800  = tt-risco.ven-1800 + tt-cli.ven-1800
        tt-risco.ven-1080  = tt-risco.ven-1080 + tt-cli.ven-1080
        tt-risco.ven-360   = tt-risco.ven-360  + tt-cli.ven-360
        tt-risco.ven-90    = tt-risco.ven-90   + tt-cli.ven-90
        .
end.
for each tt-clicob:
    if tt-clicob.cobcod = 10
    then do:
        find first fn-risco where
                fn-risco.risco = tt-clicob.risco no-error.
        if not avail fn-risco
        then do:
            create fn-risco.
            fn-risco.risco = tt-clicob.risco.
        end.    
        assign
            fn-risco.vencido = fn-risco.vencido + tt-clicob.vencido
            fn-risco.vencer  = fn-risco.vencer  + tt-clicob.vencer
            fn-risco.principal = fn-risco.principal + tt-clicob.principal
            fn-risco.acrescimo = fn-risco.acrescimo + tt-clicob.acrescimo
            fn-risco.ven-9999  = fn-risco.ven-9999 + tt-clicob.ven-9999
            fn-risco.ven-5400  = fn-risco.ven-5400 + tt-clicob.ven-5400
            fn-risco.ven-1800  = fn-risco.ven-1800 + tt-clicob.ven-1800
            fn-risco.ven-1080  = fn-risco.ven-1080 + tt-clicob.ven-1080
            fn-risco.ven-360   = fn-risco.ven-360  + tt-clicob.ven-360
            fn-risco.ven-90    = fn-risco.ven-90   + tt-clicob.ven-90
             .
    end.
    else do:
        find first lb-risco where
                lb-risco.risco = tt-clicob.risco no-error.
        if not avail lb-risco
        then do:
            create lb-risco.
            lb-risco.risco = tt-clicob.risco.
        end.    
        assign
            lb-risco.vencido = lb-risco.vencido + tt-clicob.vencido
            lb-risco.vencer  = lb-risco.vencer  + tt-clicob.vencer
            lb-risco.principal = lb-risco.principal + tt-clicob.principal
            lb-risco.acrescimo = lb-risco.acrescimo + tt-clicob.acrescimo
            lb-risco.ven-9999  = lb-risco.ven-9999 + tt-clicob.ven-9999
            lb-risco.ven-5400  = lb-risco.ven-5400 + tt-clicob.ven-5400
            lb-risco.ven-1800  = lb-risco.ven-1800 + tt-clicob.ven-1800
            lb-risco.ven-1080  = lb-risco.ven-1080 + tt-clicob.ven-1080
            lb-risco.ven-360   = lb-risco.ven-360  + tt-clicob.ven-360
            lb-risco.ven-90    = lb-risco.ven-90   + tt-clicob.ven-90

             .
    end.
end. 

run relatorio.

hide frame f11 no-pause.

{setbrw.i}

assign
    a-seeid = -1 a-recid = -1 a-seerec = ?.

for each tt-risco where  tt-risco.risco = "" :
    delete tt-risco.
end.             
         
form tt-risco.risco column-label "Faixa"
     tt-risco.des no-label format "x(12)"  
     tt-risco.vencido column-label "Vencidos"
     tt-risco.vencer  column-label "Vencer"
     tt-risco.total   column-label "Total"
     with frame f-linha down centered.

l1: repeat:
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file  = tt-risco  
        &help  = "Tecle ENTER para relatorio analitico por contrato"
        &cfield = tt-risco.risco
        &noncharacter = /* 
        &ofield = " tt-risco.des
                    tt-risco.vencido
                    tt-risco.vencer
                    tt-risco.total
                    "  
        &aftfnd1 = " "
        &where  = " "
        &aftselect1 = " 
                        run relatorio-faixa-analitico(tt-risco.risco).
                        
                        " 
        &go-on = F4 
        &naoexiste1 = " bell.
                        message color red/with
                        ""Nenhum registro encontrado""
                        view-as alert-box.
                        leave l1.
                        " 
        &otherkeys1 = " "
        &locktype = " "
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
end.

procedure relatorio:
    def var varquivo as char.
    def var sld-curva as dec.
    def var vprovisao as dec.
    varquivo = "/admcom/relat/bga-cliente-" 
                + string(vdatref,"99999999") + "-" + string(time).
        
    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "80"  
        &Page-Line = "66"
        &Nom-Rel   = ""prodevduv""  
        &Nom-Sis   = """SISTEMA ADMCOM CONTABIL"""
        &Tit-Rel   = """RELATORIO DEVEDORES"""
        &Width     = "80"
        &Form      = "frame f-cabcab"}

    disp with frame f11.
    vi = 0. 
    put skip(1) "CARTEIRA LEBES" skip.
    for each lb-risco where 
             lb-risco.risco <> "" NO-LOCK:
        find first tt-tbcntgen where
                   tt-tbcntgen.nivel = lb-risco.risco 
                   no-error.
        if avail tt-tbcntgen
        then lb-risco.des = tt-tbcntgen.numini + "-" +
                            tt-tbcntgen.numfim.
        lb-risco.total = lb-risco.vencido + lb-risco.vencer.
        /****
        disp lb-risco.risco column-label "Faixa"
             lb-risco.des no-label   format "x(12)"
             lb-risco.vencido(total) column-label "Vencidos"
             lb-risco.vencer(total)  column-label "Vencer"
             lb-risco.total(total)   column-label "Total"
             lb-risco.principal(total) column-label "Principal"
             lb-risco.acrescimo(total) column-label "Renda"
             with frame f-disp1 down width 120.
        *****/
        vi = vi + 1.    
        sld-curva = lb-risco.vencido + 
                    lb-risco.ven-90 + lb-risco.ven-360 +
                    lb-risco.ven-1080 + lb-risco.ven-1800 +
                    lb-risco.ven-5400 + lb-risco.ven-9999
                    .
        vprovisao = sld-curva * (v-pct[vi] / 100).
        disp lb-risco.risco column-label "Faixa"
             lb-risco.des no-label   format "x(12)"
             lb-risco.vencido column-label "Vencidos"
             format ">>>,>>>,>>9.99" (total)
             lb-risco.ven-90  column-label "Vencer!Ate 3 meses"
             format ">>>,>>>,>>9.99" (total)
             lb-risco.ven-360 column-label "Vencer!3 a 12 meses"
             format ">>>,>>>,>>9.99"  (total)
             lb-risco.ven-1080 column-label "Vencer!1 a 3 anos"
             format ">>>,>>>,>>9.99"  (total) 
             lb-risco.ven-1800 column-label "Vencer!3 a 5 anos"
             format ">>>,>>>,>>9.99"  (total)
             lb-risco.ven-5400 column-label "Vencer!5 a 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             lb-risco.ven-9999 column-label "Vencer!+ 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             sld-curva  column-label "Sld Curva"
             format ">>,>>>,>>>,>>9.99"  (total)
             vprovisao  column-label "Provisao"
             format ">>>,>>>,>>9.99"  (total)
             v-pct[vi] column-label "%"
             lb-risco.principal(total) column-label "Principal"
             format ">>>,>>>,>>9.99"
             lb-risco.acrescimo(total) column-label "Renda"
             format ">>>,>>>,>>9.99"
             with frame f-disp1 down width 220.
            .
        down with frame f-disp1.
    end.
    vi = 0.
    put skip(1) "CARTEIRA FINANCEIRA" skip.
    for each fn-risco NO-LOCK:
        find first tt-tbcntgen where
                   tt-tbcntgen.nivel = fn-risco.risco 
                   no-error.
        if avail tt-tbcntgen
        then fn-risco.des = tt-tbcntgen.numini + "-" +
                            tt-tbcntgen.numfim.
        fn-risco.total = fn-risco.vencido + fn-risco.vencer.
        /***
        disp fn-risco.risco column-label "Faixa"
             fn-risco.des no-label   format "x(12)"
             fn-risco.vencido(total) column-label "Vencidos"
             fn-risco.vencer(total)  column-label "Vencer"
             fn-risco.total(total)   column-label "Total"
             fn-risco.principal(total) column-label "Principal"
             fn-risco.acrescimo(total) column-label "Renda"
             with frame f-disp2 down width 120.
        ****/
        vi = vi + 1.    
        sld-curva = fn-risco.vencido +
                    fn-risco.ven-90 + fn-risco.ven-360 +
                    fn-risco.ven-1080 + fn-risco.ven-1800 +
                    fn-risco.ven-5400 + fn-risco.ven-9999
                    .
        vprovisao = sld-curva * (v-pct[vi] / 100).
        disp fn-risco.risco column-label "Faixa"
             fn-risco.des no-label   format "x(12)"
             fn-risco.vencido column-label "Vencidos"
             format ">>>,>>>,>>9.99" (total)
             fn-risco.ven-90  column-label "Vencer!Ate 3 meses"
             format ">>>,>>>,>>9.99" (total)
             fn-risco.ven-360 column-label "Vencer!3 a 12 meses"
             format ">>>,>>>,>>9.99"  (total)
             fn-risco.ven-1080 column-label "Vencer!1 a 3 anos"
             format ">>>,>>>,>>9.99"  (total) 
             fn-risco.ven-1800 column-label "Vencer!3 a 5 anos"
             format ">>>,>>>,>>9.99"  (total)
             fn-risco.ven-5400 column-label "Vencer!5 a 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             fn-risco.ven-9999 column-label "Vencer!+ 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             sld-curva  column-label "Sld Curva"
             format ">>,>>>,>>>,>>9.99"  (total)
             vprovisao  column-label "Provisao"
             format ">>>,>>>,>>9.99"  (total)
             v-pct[vi] column-label "%"
             fn-risco.principal(total) column-label "Principal"
             format ">>>,>>>,>>9.99"
             fn-risco.acrescimo(total) column-label "Renda"
             format ">>>,>>>,>>9.99"
             with frame f-disp2 down width 220.
            .
        down with frame f-disp2.

    end.   
    vi = 0.  
    put skip(1) "CARTEIRA GERAL" skip.
    for each tt-risco where tt-risco.risco <> "" NO-LOCK:
        find first tt-tbcntgen where
                   tt-tbcntgen.nivel = tt-risco.risco 
                   no-error.
        if avail tt-tbcntgen
        then tt-risco.des = tt-tbcntgen.numini + "-" +
                            tt-tbcntgen.numfim.
        tt-risco.total = tt-risco.vencido + tt-risco.vencer.
        
        /*******
        disp tt-risco.risco column-label "Faixa"
             tt-risco.des no-label   format "x(12)"
             tt-risco.vencido(total) column-label "Vencidos"
             tt-risco.vencer(total)  column-label "Vencer"
             tt-risco.total(total)   column-label "Total"
             tt-risco.principal(total) column-label "Principal"
             tt-risco.acrescimo(total) column-label "Renda"
             with frame f-disp3 down width 120.
        ***********/
        
        vi = vi + 1.    
        sld-curva = tt-risco.vencido + 
                    tt-risco.ven-90 + tt-risco.ven-360 +
                    tt-risco.ven-1080 + tt-risco.ven-1800 +
                    tt-risco.ven-5400 + tt-risco.ven-9999
                    .
        vprovisao = sld-curva * (v-pct[vi] / 100).
        disp tt-risco.risco column-label "Faixa"
             tt-risco.des no-label   format "x(12)"
             tt-risco.vencido column-label "Vencidos"
             format ">>>,>>>,>>9.99" (total)
             tt-risco.ven-90  column-label "Vencer!Ate 3 meses"
             format ">>>,>>>,>>9.99" (total)
             tt-risco.ven-360 column-label "Vencer!3 a 12 meses"
             format ">>>,>>>,>>9.99"  (total)
             tt-risco.ven-1080 column-label "Vencer!1 a 3 anos"
             format ">>>,>>>,>>9.99"  (total) 
             tt-risco.ven-1800 column-label "Vencer!3 a 5 anos"
             format ">>>,>>>,>>9.99"  (total)
             tt-risco.ven-5400 column-label "Vencer!5 a 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             tt-risco.ven-9999 column-label "Vencer!+ 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             sld-curva  column-label "Sld Curva"
             format ">>,>>>,>>>,>>9.99"  (total)
             vprovisao  column-label "Provisao"
             format ">>>,>>>,>>9.99"  (total)
             v-pct[vi] column-label "%"
             tt-risco.principal(total) column-label "Principal"
             format ">>>,>>>,>>9.99"
             tt-risco.acrescimo(total) column-label "Renda"
             format ">>>,>>>,>>9.99"
             with frame f-disp3 down width 220.
            .
        down with frame f-disp3.

    end.     

    output close.

    run visurel.p(varquivo,"").
    
end procedure.

procedure relatorio-faixa-analitico:
    def input parameter p-risco as char.
    def var varquivo as char.
    def var sld-curva as dec.
    def var vprovisao as dec.
    def var vclinom like clien.clinom.
    def var vindex as int.
    def var vescolha as char format "x(15)" extent 3
        init["  Geral  ","  Lebes  ","  Financeira  "].
    disp vescolha with frame f-escolha overlay no-label
        centered row 7.
    choose field vescolha with frame f-escolha.
    vindex = frame-index.     
    message "Gerando relatorio... Aguarde!".  
    varquivo = "/admcom/relat/bga-cliente-" + vescolha[vindex] + "-"
                + string(vdatref,"99999999") + "-risco" 
                + p-risco + ".csv".    
    message varquivo. pause 1 no-message.
    
    output to value(varquivo).
    put 
    "Filial;Codigo;Nome;Contrato;Emissao;Vencido;Vencer;Valaberto;Parcelas" 
    skip.

    if vindex = 1
    then
    for each tt-con where tt-con.risco = p-risco:
        find clien where clien.clicod = tt-con.clicod no-lock no-error.
        if avail clien
        then vclinom = clien.clinom.
        else vclinom = "NOME".
        put unformatted
            tt-con.etbcod format ">>9"
            ";" 
            tt-con.clicod format ">>>>>>>>>9"
            ";"
            Vclinom 
            ";"
            tt-con.titnum 
            ";"
            tt-con.titdtemi
            ";"
            tt-con.vencido
            ";"
            tt-con.vencer 
            ";"
            tt-con.valaberto
            ";"
            tt-con.qtdparab
            skip
            .
    end.
    else if vindex = 2
    then
    for each tt-con where tt-con.risco = p-risco and
                          tt-con.cobcod <> 10  :
        find clien where clien.clicod = tt-con.clicod no-lock no-error.
        if avail clien
        then vclinom = clien.clinom.
        else vclinom = "NOME".
        put unformatted
            tt-con.etbcod format ">>9"
            ";" 
            tt-con.clicod format ">>>>>>>>>9"
            ";"
            Vclinom 
            ";"
            tt-con.titnum 
            ";"
            tt-con.titdtemi
            ";"
            tt-con.vencido
            ";"
            tt-con.vencer 
            ";"
            tt-con.valaberto
            ";"
            tt-con.qtdparab
            skip
            .
    end.
    else if vindex = 3
    then
    for each tt-con where tt-con.risco = p-risco and
                          tt-con.cobcod = 10  :
        find clien where clien.clicod = tt-con.clicod no-lock no-error.
        if avail clien
        then vclinom = clien.clinom.
        else vclinom = "NOME".
        put unformatted
            tt-con.etbcod format ">>9"
            ";" 
            tt-con.clicod format ">>>>>>>>>9"
            ";"
            Vclinom 
            ";"
            tt-con.titnum 
            ";"
            tt-con.titdtemi
            ";"
            tt-con.vencido
            ";"
            tt-con.vencer 
            ";"
            tt-con.valaberto
            ";"
            tt-con.qtdparab
            skip
            .
    end.

    hide message no-pause.


    output close.

    message color red/with
        "Arquivo csv gerado:" skip
        varquivo
        view-as alert-box
        .
    
end procedure.

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
    
    find first tt-principal where
               tt-principal.clifor = titulo.clifor and
               tt-principal.titnum = titulo.titnum 
                       no-lock no-error.
    if not avail tt-principal
    then do:
        create tt-principal.
        assign
            tt-principal.clifor   = titulo.clifor
            tt-principal.titnum   = titulo.titnum
            tt-principal.titvlcob = titulo.titvlcob
            tt-principal.titdes   = titulo.titdes
            .
        /*****
        find titulo where titulo.empcod = sc2015.empcod and
                                  titulo.titnat = sc2015.titnat and
                                  titulo.modcod = sc2015.modcod and
                                  titulo.etbcod = sc2015.etbcod and
                                  titulo.clifor = sc2015.clifor and
                                  titulo.titnum = sc2015.titnum and
                                  titulo.titpar = 2
                                  no-lock no-error.
        ******/
                
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
                     p-principal = titulo.titvlcob
                     p-acrescimo = 0
                     .
            assign
                tt-principal.principal = p-principal
                tt-principal.acrescimo = p-acrescimo
                .
        end.
        else assign
                 p-principal = titulo.titvlcob
                 p-acrescimo = 0
                 tt-principal.principal = p-principal
                 tt-principal.acrescimo = p-acrescimo
                 .          
    end.
    else assign
             p-principal = tt-principal.principal
             p-acrescimo = tt-principal.acrescimo
             .

    if p-principal >= titulo.titvlcob
    then assign
             p-principal = titulo.titvlcob
             p-acrescimo = 0.

    if (p-principal + p-acrescimo) > titulo.titvlcob
    then p-principal = p-principal - 
               ((p-principal + p-acrescimo) - titulo.titvlcob).
    else if (p-principal + p-acrescimo) < titulo.titvlcob     
        then p-principal = p-principal + 
                    (titulo.titvlcob - (p-principal + p-acrescimo)).
    assign
        v-principal = v-principal + p-principal
        v-acrescimo = v-acrescimo + p-acrescimo
        .
end procedure.

