{admcab.i}

def var a-dia as int extent 20.
def var b-dia as int extent 20.
def var v-risco as char extent 20.
def var v-pct as dec extent 20.
def var v-vencido as dec extent 20.

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
    index i1 etbcod clicod titnum
    index i2 risco.
    
def temp-table tt-risco  no-undo
    field risco as char
    field des as char
    field vencido as dec  format ">>>,>>>,>>9.99"
    field vencer  as dec  format ">>>,>>>,>>9.99"
    field total   as dec  format ">>>,>>>,>>9.99"
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
def var vtitdtven like titulo.titdtven.
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
    with frame f-pro 1 down row 10 width 80 no-box .
    
pause 0.
def var vq as int.    
def var vt as int.

    for each SC2015 use-index INDX2  where 
                        SC2015.titnat = no and
                            SC2015.titdtemi <= vdatref
                and  ((SC2015.titdtpag > vdatref and
                      SC2015.titsit = "PAG") or
                      SC2015.titsit = "LIB")
                no-lock.

        if SC2015.titdtmovref > vdatref or
           SC2015.titdtmovref = ?
        then next.

        if vcatcod > 0
        then do:
            find first contnf where contnf.etbcod = SC2015.etbcod and
                   contnf.contnum = int(SC2015.titnum)
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
            disp SC2015.titdtemi no-label
                 SC2015.titnum no-label with frame f-pro.
            pause 0.
            vq = 0.
        end.

        if SC2015.titdtvenaux <> ?
        then vtitdtven = SC2015.titdtvenaux.
        else vtitdtven = SC2015.titdtven.

        find first tt-con use-index i1 where
                   tt-con.etbcod = SC2015.etbcod and
                   tt-con.clicod = SC2015.clifor and
                   tt-con.titnum = SC2015.titnum
                   no-error.
        if not avail tt-con
        then do:
            create tt-con.
            assign
                tt-con.etbcod = SC2015.etbcod
                tt-con.clicod = SC2015.clifor
                tt-con.titnum = SC2015.titnum
                tt-con.titdtemi = SC2015.titdtemi
                tt-con.risco  = "A"
                .
        end.           
        ttvencido = 0.
        do vi = 1 to q-nivel:
            if vdatref - vtitdtven <= b-dia[vi] 
            then do:
                if vtitdtven <= vdatref
                then do:
                    assign
                        tt-con.vencido = tt-con.vencido + SC2015.titvlcob
                        ttvencido = SC2015.titvlcob.
                    if v-risco[vi] > tt-con.risco
                       then tt-con.risco  = v-risco[vi].
                end.
                leave.
            end.    
        end.
        if vtitdtven <= vdatref
        then do:
            if ttvencido = 0
            then tt-con.vencido = tt-con.vencido + SC2015.titvlcob.
        end.
        else tt-con.vencer  = tt-con.vencer + SC2015.titvlcob.

        tt-con.valaberto = tt-con.valaberto + SC2015.titvlcob.
        tt-con.qtdparab  = tt-con.qtdparab + 1. 
        
        /*
        vt = vt + 1.
        if vt > 100000
        then leave.
        */
    
    end.                  
         
hide frame f-pro no-pause.
clear frame f-pro ALL.


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
        .
end.     

run relatorio.

hide frame f11 no-pause.

{setbrw.i}

assign
    a-seeid = -1 a-recid = -1 a-seerec = ?.

/*
for each tt-risco where  tt-risco.risco = "" :
    delete tt-risco.
end.             
*/         
form tt-risco.risco column-label "Faixa"
     tt-risco.des no-label   
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
    varquivo = "/admcom/relat/sfconven" + string(time).
        
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
    for each tt-risco /*where tt-risco.risco <> ""*/ NO-LOCK:
        find first tt-tbcntgen where
                   tt-tbcntgen.nivel = tt-risco.risco 
                   no-error.
        if avail tt-tbcntgen
        then tt-risco.des = tt-tbcntgen.numini + "-" +
                            tt-tbcntgen.numfim.
        else tt-risco.des = "".
        tt-risco.total = tt-risco.vencido + tt-risco.vencer.
        disp tt-risco.risco column-label "Faixa"
             tt-risco.des no-label   
             tt-risco.vencido(total) column-label "Vencidos"
             tt-risco.vencer(total)  column-label "Vencer"
             tt-risco.total(total)   column-label "Total"
             with frame f-disp down.
    end.     

    output close.

    run visurel.p(varquivo,"").
    
end procedure.

/*****
procedure relatorio-faixa-analitico:
    def input parameter p-risco as char.
    def var varquivo as char.
    def var sld-curva as dec.
    def var vprovisao as dec.
    varquivo = "/admcom/relat/afconven" + string(time).
    varq = "/admcom/relat/afconven-" +
            string(vdataref,"99999999") + "-risco" + p-risco + ".csv".    
    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "130"  
        &Page-Line = "66"
        &Nom-Rel   = ""prodevduv""  
        &Nom-Sis   = """SISTEMA ADMCOM CONTABIL"""
        &Tit-Rel   = """RELATORIO DEVEDORES"""
        &Width     = "130"
        &Form      = "frame f-cabcab"}

    disp with frame f11.
    vi = 0.    
    for each tt-risco where tt-risco.risco = p-risco NO-LOCK:
        find first tt-tbcntgen where
                   tt-tbcntgen.nivel = tt-risco.risco 
                   no-error.
        if avail tt-tbcntgen
        then tt-risco.des = tt-tbcntgen.numini + "-" +
                            tt-tbcntgen.numfim.
        tt-risco.total = tt-risco.vencido + tt-risco.vencer.
        disp tt-risco.risco column-label "Faixa"
             tt-risco.des no-label   
             tt-risco.vencido column-label "Vencidos"
             tt-risco.vencer  column-label "Vencer"
             tt-risco.total   column-label "Total"
             with frame f-disp.
         
    end.     

    for each tt-con where tt-con.risco = p-risco:
        find clien where clien.clicod = tt-con.clicod no-lock no-error.
        disp tt-con.clicod     column-label "Cliente"   format ">>>>>>>>>9"
             clien.clinom when avail clien    column-label "Nome"
             tt-con.titnum     column-label "Contrato"
             tt-con.titdtemi   column-label "Emissao"
             tt-con.vencido    column-label "Vencido"
             tt-con.vencer     column-label "Vencer"
             tt-con.valaberto  column-label "Total!Pendente"
             tt-con.qtdparab   column-label "Parcelas!Pendentes"
             /*tt-con.valtotal   column-label "Total!Contrato"
             tt-con.qtdparco   column-label "Parcelas!Total"
             */
             with frame f-disp1 down width 150.
    end.


    output close.

    run visurel.p(varquivo,"").
    
end procedure.
***************/

procedure relatorio-faixa-analitico:
    def input parameter p-risco as char.
    def var varquivo as char.
    def var sld-curva as dec.
    def var vprovisao as dec.
    varquivo = "/admcom/relat/afconven-" + string(vdatref,"99999999") + 
                        "-risco" + p-risco + ".csv".    
    output to value(varquivo).
    put "Codigo;Nome;Contrato;Emissao;Vencido;Vencer;Valaberto;Parcelas" skip.

    for each tt-con where tt-con.risco = p-risco:
        find clien where clien.clicod = tt-con.clicod no-lock no-error.
        put unformatted
            tt-con.clicod format ">>>>>>>>>9"
            ";"
            clien.clinom 
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


    output close.

    message color red/with
        "Arquivo csv gerado:" skip
        varquivo
        view-as alert-box
        .
    
end procedure.


