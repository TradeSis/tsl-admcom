{admcab.i}

def var a-dia as int extent 20.
def var b-dia as int extent 20.
def var v-risco as char extent 20.
def var v-pct as dec extent 20.
def var v-vencido as dec extent 20.

def temp-table tt-cli 
    field clicod like clien.clicod
    field risco as char
    field titnum as char
    field vencido as dec
    field vencer as dec
    field ven-90 as dec
    field ven-360 as dec
    field ven-1080 as dec
    field ven-1800 as dec
    field ven-5400 as dec
    field ven-9999 as dec
    index i1 clicod 
    .

def temp-table tt-cliv no-undo 
    field clicod like clien.clicod
    field risco as char
    field titnum as char
    field titdtven as date
    field vencido as dec
    field ven-90 as dec
    field ven-360 as dec
    field ven-1080 as dec
    field ven-1800 as dec
    field ven-5400 as dec
    field ven-9999 as dec
    index i1 clicod risco
    .

def temp-table tt-risco 
    field risco as char
    field des as char
    field vencido as dec
    field vencer as dec
    field total as dec
    field ven-90 as dec
    field ven-360 as dec
    field ven-1080 as dec
    field ven-1800 as dec
    field ven-5400 as dec
    field ven-9999 as dec
    index i1 risco
    .

def temp-table tt-tbcntgen 
    field nivel as char
    field numini as char
    field numfim as char
    field valor as dec
    index i1 nivel.

for each tbcntgen where tbcntgen.tipcon = 11
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
def var ttvencido as dec.
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
def var vq as int.    
def var vt as int.
    for each titulo where 
                    titulo.titnat = no and
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


        find first tt-cli where tt-cli.clicod = titulo.clifor 
                          no-error.
        if not avail tt-cli
        then do:
            create tt-cli.
            assign
                tt-cli.clicod = titulo.clifor
                tt-cli.risco  = "A"
                .
        end.
        ttvencido = 0.    
        do vi = 1 to q-nivel:
            /*message vi (vdatref - titulo.titdtven) b-dia[vi].
            pause.*/
            if vdatref - titulo.titdtven <= b-dia[vi] 
            then do:
                /*message vdatref titulo.titdtven. pause.*/
                if titulo.titdtven <= vdatref
                then do:
                    /*
                    find first tt-cliv where
                               tt-cliv.clicod = titulo.clifor and
                               tt-cliv.risco = v-risco[vi]
                               no-error.
                    if not avail tt-cliv
                    then do:
                        create tt-cliv.
                        tt-cliv.clicod = titulo.clifor.
                        tt-cliv.risco = v-risco[vi].
                    end.           
                    tt-cliv.vencido = tt-cliv.vencido + titulo.titvlcob.
                    */
                    tt-cli.vencido = tt-cli.vencido + titulo.titvlcob.
                    ttvencido = titulo.titvlcob.
            
                    if v-risco[vi] > tt-cli.risco
                    then  tt-cli.risco  = v-risco[vi].
                    find first tt-risco where
                           tt-risco.risco = v-risco[vi] no-error.
                    if not avail tt-risco
                    then do:
                        create tt-risco.
                        tt-risco.risco = v-risco[vi].
                    end.
                    tt-risco.vencido = tt-risco.vencido + titulo.titvlcob.  
                end.
                leave.
            end.    
        end.
        if titulo.titdtven <= vdatref 
        then do:
            if ttvencido = 0
            then do:
                tt-cli.vencido = tt-cli.vencido + titulo.titvlcob.
                
                find first tt-risco where
                           tt-risco.risco =
                                    if tt-cli.risco <> ""
                                    then tt-cli.risco else "K"
                            no-error.
                if not avail tt-risco
                then do:
                    create tt-risco.
                    tt-risco.risco = if tt-cli.risco <> ""
                                     then tt-cli.risco else "K".
                end.
                tt-risco.vencido = tt-risco.vencido + titulo.titvlcob.  
            end.
        end.
        else tt-cli.vencer = tt-cli.vencer + titulo.titvlcob.


            if titulo.titdtven - vdatref > 5400
            then tt-cli.ven-9999 = tt-cli.ven-9999 + titulo.titvlcob.
            else if titulo.titdtven - vdatref > 1800
            then tt-cli.ven-5400 = tt-cli.ven-5400 + titulo.titvlcob.
            else if titulo.titdtven - vdatref > 1080
            then tt-cli.ven-1800 = tt-cli.ven-1800 + titulo.titvlcob.
            else if titulo.titdtven - vdatref > 360
            then tt-cli.ven-1080 = tt-cli.ven-1080 + titulo.titvlcob.
            else if titulo.titdtven - vdatref > 90
            then tt-cli.ven-360 = tt-cli.ven-360 + titulo.titvlcob.
            else if titulo.titdtven - vdatref > 0
            then tt-cli.ven-90 = tt-cli.ven-90 + titulo.titvlcob.
        /*
        vt = vt + 1.
        if vt > 100000
        then leave.
        */
    end.                  
         

for each tt-risco: delete tt-risco. end.

for each tt-cli no-lock:
    
    find first tt-risco where
            tt-risco.risco = tt-cli.risco no-error.
    if not avail tt-risco
    then do:
        create tt-risco.
        tt-risco.risco = tt-cli.risco.
    end.    
        
    assign
        tt-risco.vencido = tt-risco.vencido + tt-cli.vencido
        tt-risco.vencer  = tt-risco.vencer + tt-cli.ven-90 + tt-cli.ven-360
             + tt-cli.ven-1080 + tt-cli.ven-1800 + tt-cli.ven-5400 +
              tt-cli.ven-9999
        tt-risco.ven-90  = tt-risco.ven-90  + tt-cli.ven-90
        tt-risco.ven-360  = tt-risco.ven-360  + tt-cli.ven-360
        tt-risco.ven-1080  = tt-risco.ven-1080  + tt-cli.ven-1080
        tt-risco.ven-1800  = tt-risco.ven-1800  + tt-cli.ven-1800
        tt-risco.ven-5400  = tt-risco.ven-5400  + tt-cli.ven-5400
        tt-risco.ven-9999  = tt-risco.ven-9999  + tt-cli.ven-9999
        .
end.     

run relatorio.

hide frame f11 no-pause.
hide frame f-pro no-pause.

{setbrw.i}

assign
    a-seeid = -1 a-recid = -1 a-seerec = ?.

for each tt-risco :
    if tt-risco.risco = ""
    then delete tt-risco.
    else do:
        tt-risco.total = tt-risco.total + tt-risco.vencido + tt-risco.vencer.
        find first tt-tbcntgen where
                   tt-tbcntgen.nivel = tt-risco.risco 
                   no-error.
        if avail tt-tbcntgen
        then tt-risco.des = tt-tbcntgen.numini + "-" +
                            tt-tbcntgen.numfim.
        tt-risco.total = tt-risco.vencido + tt-risco.vencer.
    end.
end.             
         
form tt-risco.risco column-label "Faixa"
     tt-risco.des no-label   
     tt-risco.vencido column-label "Vencidos"  format ">>>,>>>,>>9.99"
     tt-risco.vencer  column-label "Vencer"    format ">>>,>>>,>>9.99"
     tt-risco.total   column-label "Total"     format ">>>,>>>,>>9.99"
     with frame f-linha down centered.

l1: repeat:
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file  = tt-risco  
        &help  = "Tecle ENTER pra relatorio analitico por contrato"
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
    varquivo = "/admcom/relat/bg-prodevduv" + string(time).
        
    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "140"  
        &Page-Line = "66"
        &Nom-Rel   = ""prodevduv""  
        &Nom-Sis   = """SISTEMA ADMCOM CONTABIL"""
        &Tit-Rel   = """PROVISAO DE DEVEDORES DUVIDOSOS - GERENCIAL"""
        &Width     = "140"
        &Form      = "frame f-cabcab"}

    disp with frame f11.
    vi = 0.    
    for each tt-risco where tt-risco.risco <> "" NO-LOCK:
        vi = vi + 1.    
        sld-curva = /*sld-curva +*/ tt-risco.vencido +
                    tt-risco.ven-90 + tt-risco.ven-360 +
                    tt-risco.ven-1080 + tt-risco.ven-1800 +
                    tt-risco.ven-5400 + tt-risco.ven-9999
                    .
        vprovisao = sld-curva * (v-pct[vi] / 100).
        disp tt-risco.risco column-label "Faixa"
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
             with frame f-disp down width 200.
            .
        down with frame f-disp.
end.     



    output close.
        
    run visurel.p(varquivo,"").
    
end procedure.
procedure relatorio-faixa-analitico:
    def input parameter vrisco as char.
    def var vclinom like clien.clinom.
    def var vciccgc as char format "x(16)".
    def var varq as char.
 
    varq = "/admcom/relat/bg-devedores-31122015-risco" + vrisco + ".csv". 
    output to value(varq).
    put "Codigo;Nome;CPF;Valor;Faixa" skip.
    for each tt-cliv where tt-cliv.clicod > 0 and
            tt-cliv.risco = vrisco no-lock:
        find clien where clien.clicod = tt-cliv.clicod no-lock no-error.
        if avail clien
        then assign
                vclinom = clien.clinom
                vciccgc = clien.ciccgc.
        else assign
                vclinom = ""
                vciccgc = "".
        if (tt-cliv.vencido +
             tt-cliv.ven-90  +
             tt-cliv.ven-360 +
             tt-cliv.ven-1080 +
             tt-cliv.ven-1800 +
             tt-cliv.ven-5400 +
             tt-cliv.ven-9999)  = 0
        then next.
             
        vclinom = replace(vclinom,";","").
        vciccgc = replace(vciccgc,";","").
        vciccgc = replace(vciccgc,",","").
        vciccgc = replace(vciccgc,".","").
        vciccgc = replace(vciccgc,"/","").

        put tt-cliv.clicod format ">>>>>>>>>9"
            ";"
            vclinom format "x(40)"
            ";"
            vciccgc format "x(16)"
            ";"
            (tt-cliv.vencido +
             tt-cliv.ven-90  +
             tt-cliv.ven-360 +
             tt-cliv.ven-1080 +
             tt-cliv.ven-1800 +
             tt-cliv.ven-5400 +
             tt-cliv.ven-9999) format ">>>,>>>,>>9.99"
             ";"
             tt-cliv.risco
             skip.
    end.
    output close. 
    message color red/with
        "Arquivo csv gerado:" skip
        varq
        view-as alert-box
        .
end procedure.