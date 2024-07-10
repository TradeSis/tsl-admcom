{admcab.i}

def var a-dia as int extent 20.
def var b-dia as int extent 20.
def var v-risco as char extent 20.
def var v-pct as dec extent 20.
def var v-vencido as dec extent 20.

def var v-principal as dec.
def var v-acrescimo as dec.

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
    index i1 etbcod clicod titnum 
    index i2 risco cobcod
    index i3 cobcod.

def temp-table tt-risco  no-undo
    field risco as char
    field des as char
    field vencido as dec  format ">>>,>>>,>>9.99"
    field vencer  as dec  format ">>>,>>>,>>9.99"
    field total   as dec  format ">>>,>>>,>>9.99"
    field principal as dec format ">>>,>>>,>>9.99"
    field acrescimo as dec format ">>>,>>>,>>9.99"
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
    for each titulo where  titulo.titnat = no and
                           titulo.titdtemi <= vdatref and
                           titulo.modcod = "CRE" and
                          (titulo.titsit = "LIB" or
                          (titulo.titsit = "PAG" and
                           titulo.titdtpag > vdatref))
                           no-lock.
                                     
        if vcatcod > 0
        then do:
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
                    if avail produ and
                       int(subst(string(produ.catcod),1,1))
                           <> int(subst(string(vcatcod),1,1))
                    then next.
                end.
                else if vcatcod <> 31
                    then next. 
            end.
            else if vcatcod <> 31
                then next.
        end. 
        
        vq = vq + 1.
        if vq = 200
        then do:
            disp titulo.titdtemi no-label
                 titulo.titnum no-label with frame f-pro.
            pause 0.
            vq = 0.
        end.

        assign
            v-principal = 0
            v-acrescimo = 0.

        run principal-renda.
        
        find first tt-con use-index i1 where
                   tt-con.etbcod = titulo.etbcod and
                   tt-con.clicod = titulo.clifor and
                   tt-con.titnum = titulo.titnum
                   no-error.
        if not avail tt-con
        then do:
            create tt-con.
            assign
                tt-con.etbcod   = titulo.etbcod
                tt-con.clicod   = titulo.clifor
                tt-con.titnum   = titulo.titnum
                tt-con.titdtemi = titulo.titdtemi
                tt-con.cobcod   = titulo.cobcod
                tt-con.risco  = "A"
                .
            if titulo.cobcod <> 10
            then tt-con.cobcod = 2.        
        end.
                   
        assign
            tt-con.principal = tt-con.principal + v-principal
            tt-con.acrescimo = tt-con.acrescimo + v-acrescimo
            .
            
        ttvencido = 0.
        do vi = 1 to q-nivel:
            if vdatref - titulo.titdtven <= b-dia[vi] 
            then do:
                /**
                message vdatref titulo.titdtven 
                vdatref - titulo.titdtven b-dia[vi] v-risco[vi]
                tt-con.risco.
                pause.
                ***/
                if titulo.titdtven <= vdatref
                then do:
                    assign
                    tt-con.vencido = tt-con.vencido + titulo.titvlcob
                    ttvencido = titulo.titvlcob
                    .
                    if v-risco[vi] > tt-con.risco
                    then tt-con.risco  = v-risco[vi].
                end.
                leave.
            end.    
        end.
        if titulo.titdtven <= vdatref
        then do:
            if ttvencido = 0
            then tt-con.vencido = tt-con.vencido + titulo.titvlcob.
        end.
        else tt-con.vencer  = tt-con.vencer + titulo.titvlcob.
        tt-con.valaberto = tt-con.valaberto + titulo.titvlcob.
        tt-con.qtdparab  = tt-con.qtdparab + 1. 
    end.                  
         
hide frame f-pro no-pause.
clear frame f-pro ALL.

def var p-total as dec format ">>>,>>>,>>9.99".
for each tt-con no-lock:
    find first tt-risco where
            tt-risco.risco = tt-con.risco no-error.
    if not avail tt-risco
    then do:
        create tt-risco.
        tt-risco.risco = tt-con.risco.
    end.    
    assign
        tt-risco.vencido = tt-risco.vencido + tt-con.vencido
        tt-risco.vencer  = tt-risco.vencer  + tt-con.vencer
        tt-risco.principal = tt-risco.principal + tt-con.principal
        tt-risco.acrescimo = tt-risco.acrescimo + tt-con.acrescimo
        .
    if tt-con.cobcod = 10
    then do:
        find first fn-risco where
                fn-risco.risco = tt-con.risco no-error.
        if not avail fn-risco
        then do:
            create fn-risco.
            fn-risco.risco = tt-con.risco.
        end.    
        assign
            fn-risco.vencido = fn-risco.vencido + tt-con.vencido
            fn-risco.vencer  = fn-risco.vencer  + tt-con.vencer
            fn-risco.principal = fn-risco.principal + tt-con.principal
            fn-risco.acrescimo = fn-risco.acrescimo + tt-con.acrescimo
             .
    end.
    else do:
        find first lb-risco where
                lb-risco.risco = tt-con.risco no-error.
        if not avail lb-risco
        then do:
            create lb-risco.
            lb-risco.risco = tt-con.risco.
        end.    
        assign
            lb-risco.vencido = lb-risco.vencido + tt-con.vencido
            lb-risco.vencer  = lb-risco.vencer  + tt-con.vencer
            lb-risco.principal = lb-risco.principal + tt-con.principal
            lb-risco.acrescimo = lb-risco.acrescimo + tt-con.acrescimo
             .
    end.
    p-total = p-total + tt-con.vencido + tt-con.vencer.
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
    varquivo = "/admcom/relat/bga-contrato-" 
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
        disp lb-risco.risco column-label "Faixa"
             lb-risco.des no-label   format "x(12)"
             lb-risco.vencido column-label "Vencidos"
             lb-risco.vencer  column-label "Vencer"
             lb-risco.total   column-label "Total"
             lb-risco.principal column-label "Principal"
             lb-risco.acrescimo column-label "Renda"
             with frame f-disp1 down width 120.
    end.
    put skip(1) "CARTEIRA FINANCEIRA" skip.
    for each fn-risco NO-LOCK:
        find first tt-tbcntgen where
                   tt-tbcntgen.nivel = fn-risco.risco 
                   no-error.
        if avail tt-tbcntgen
        then fn-risco.des = tt-tbcntgen.numini + "-" +
                            tt-tbcntgen.numfim.
        fn-risco.total = fn-risco.vencido + fn-risco.vencer.
        disp fn-risco.risco column-label "Faixa"
             fn-risco.des no-label   format "x(12)"
             fn-risco.vencido column-label "Vencidos"
             fn-risco.vencer  column-label "Vencer"
             fn-risco.total   column-label "Total"
             fn-risco.principal column-label "Principal"
             fn-risco.acrescimo column-label "Renda"
             with frame f-disp2 down width 120.
    end.     
    put skip(1) "CARTEIRA GERAL" skip.
    for each tt-risco where tt-risco.risco <> "" NO-LOCK:
        find first tt-tbcntgen where
                   tt-tbcntgen.nivel = tt-risco.risco 
                   no-error.
        if avail tt-tbcntgen
        then tt-risco.des = tt-tbcntgen.numini + "-" +
                            tt-tbcntgen.numfim.
        tt-risco.total = tt-risco.vencido + tt-risco.vencer.
        disp tt-risco.risco column-label "Faixa"
             tt-risco.des no-label   format "x(12)"
             tt-risco.vencido column-label "Vencidos"
             tt-risco.vencer  column-label "Vencer"
             tt-risco.total   column-label "Total"
             tt-risco.principal column-label "Principal"
             tt-risco.acrescimo column-label "Renda"
             with frame f-disp3 down width 120.
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
    varquivo = "/admcom/relat/bga-contrato-" + trim(vescolha[vindex]) + "-"
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

