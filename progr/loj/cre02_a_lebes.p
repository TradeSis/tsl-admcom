/*  cre02_a.p                                                               */
/*  alterado em out/2014                                                    */
/*  Se titulo for da filial 10 e emissão for menor que 01/01/2014, o titulo */
/*  pertence a filial 23 .                                                  */
    
{admcab.i}

def var vpdf as char no-undo.

def var ii as int.
def stream stela.
def var vdata like plani.pladat.
def var vqtdcli as integer.
def var vdtvenini as date format "99/99/9999".
def var vdtvenfim as date format "99/99/9999".
def var vsubtot  like titulo.titvlcob.
def var vetbcod like estab.etbcod.
def var varquivo as char.

def temp-table ttcli
    field clicod like clien.clicod.

def temp-table tt-titulo
    field etbcod like titulo.etbcod
    field clifor like titulo.clifor
    field clinom like clien.clinom
    field fone like clien.fone
    field fax  like clien.fax
    field titnum like titulo.titnum
    field titpar like titulo.titpar
    field titdtemi like titulo.titdtemi
    field titdtven like titulo.titdtven
    field titvlcob like titulo.titvlcob
    field dias     as int
    field imp as log
    index i1 clinom
    .     
    
def var vqtite as int.

def var vcont-cli  as char format "x(14)" extent 5
      initial [" Alfabetica   ",
               " Vencimento   ",
               " Bairro       ",
               " Valor Vencido",
               " Novacao      "].

def var valfa as int.

/*
def new shared temp-table tt-extrato 
    field rec      as recid
    field ord      as int
    field cidade as char
    field bairro   like clien.bairro[1]
    field clinom   like clien.clinom
    field titnum   like titulo.titnum
    field titdtven like titulo.titdtven
    field etbcod   like estab.etbcod
    index ind-1 ord
    index i-bairro bairro
    index i1 bairro cidade clinom titdtven.
 */
 def new shared temp-table tt-extrato 
    field rec      as recid
    field ord      as int
    field cidade as char
    field bairro   like clien.bairro[1]
    field clinom   like clien.clinom
    field titnum   like titulo.titnum
    field titdtven like titulo.titdtven
    field etbcod   like estab.etbcod
    index ind-1 ord
    index i-bairro  bairro
    index i1        bairro cidade clinom titdtven
    index i-rec     rec.

 def new shared temp-table tt-bairro
    field cidade as char
    field bairro as char
    field marca as char
    field qtdcli as int
    index i1 bairro
    index i-cidbai  cidade bairro.

def var vfil17 as char extent 2 format "x(15)"
    init["Nova","Antiga"].
    
def var vindex as int.

def var v-consulta-parcelas-LP as logical format "Sim/Nao" initial no.
def var v-parcela-lp as log.
def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.

repeat:
    for each tt-extrato:
        delete tt-extrato.
    end.

    for each tt-bairro. delete tt-bairro. end.
    
    for each ttcli:
        delete ttcli.
    end.

    update vetbcod colon 25 with title " Posicao I ".
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento Invalido" .
        undo.
    end.
    display estab.etbnom no-label.

    pause 0.
    vindex = 0.
    if estab.etbcod = 17
    then do:
        disp vfil17 no-label with frame f-17 1 down row 10 centered
             side-label overlay.
        pause 0.     
        choose field vfil17  with frame f-17.
        vindex = frame-index.    
    end.
    
    update vdtvenini label "Vencimento Inicial" colon 25
           vdtvenfim label "Final"
                with row 4 side-labels width 80 .

    update v-consulta-parcelas-LP label " Considera apenas LP"
     help "'Sim' = Parcelas acima de 51 / 'Nao' = Parcelas abaixo de 51"
                    colon 25
        with  side-label .

    update v-feirao-nome-limpo label "Considerar apenas feirao"
                help "NAO = Geral    SIM = Feirao"
                                    colon 25 with side-label overlay .
                                    
    disp vcont-cli no-label with frame f1 width 80 row 10 
    overlay.
    choose field vcont-cli with frame f1.
    valfa = frame-index.
    for each tt-titulo.
        delete tt-titulo.
    end.    
    run p-gera.
    /**
    sresp = no.
    message "Deseja imprimir relatorio? " update sresp.
    if sresp
    then 
    repeat:    
    update vqtite label "Quantidade de linhas imprimir? " 
        with frame fqtite 1 down centered side-label.
    */
    varquivo = "/admcom/relat/cre02".

    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "120"
        &Page-Line = "66"
        &Nom-Rel   = """cre02_a"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
     &Tit-Rel   = """POSICAO FINANCEIRA GERAL P/FILIAL - CLIENTE - PERIODO DE ""
                       + string(vdtvenini) + "" A "" + string(vdtvenfim) "
        &Width     = "120"
        &Form      = "frame f-cab"}

    assign vqtdcli = 0 VSUBTOT = 0.

    run p-imprime.

    vqtdcli = 0.
    for each ttcli:
        vqtdcli = vqtdcli + 1.
    end.
                    
    display skip(2) 
            "TOTAL CLIENTES:" vqtdcli skip
            "TOTAL GERAL   :" vsubtot with frame ff no-labels no-box.
    output close.
    run visurel.p (varquivo,"").
    sresp = no.
    message "Deseja gerar um PDF do relatorio? " update sresp.
    if sresp
    then do:
        run pdfout.p (input varquivo,
                      input "/admcom/kbase/pdfout/",
                      input "cre02_a-" + string(time) + ".pdf",
                      input "Portrait",
                      input 8.2,
                      input 1,
                      output vpdf).
              
        message ("Arquivo " + vpdf + " gerado com sucesso!").
             
        /* substituido pela geracao de PDF
        os-command silent /fiscal/lp value(varquivo).*/
    end.
    /*
        leave.
    end.
    */
    hide frame fqtite no-pause.
    hide frame f-tela no-pause.
    sresp = no.
    message "Deseja gerar extratos? " update sresp.
    if sresp 
    then do:
        hide frame f1 no-pause.
        message "Aguarde... Processando ...".
        run loj/extrato2.p (input valfa).
    end.

    return.
end.

/* = = = = = = = = = = = = = = = = = = = = = */

procedure p-gera:

        disp "Aguarde.....!!" skip
             "Gerando Relatorio..."  with frame f-tela.
        
            FOR each titulo use-index titdtven where
                        titulo.empcod = wempre.empcod and
                        titulo.titnat = no            and
                        titulo.modcod = "CRE"         and
                        titulo.titdtven >= vdtvenini and
                        titulo.titdtven <= vdtvenfim and
                        titulo.etbcod = ESTAB.etbcod and
                        titulo.titsit = "LIB"   
                 no-lock:

                if v-feirao-nome-limpo
                then do:
                    if acha("FEIRAO-NOME-LIMPO",
                        titulo.titobs[1]) <> ? and
                       acha("FEIRAO-NOME-LIMPO",
                        titulo.titobs[1]) = "SIM"
                    then.
                    else next.
                end.

                if estab.etbcod = 17 and
                   vindex = 2 and
                   titulo.titdtemi >= 10/20/2010
                then next.
                else if estab.etbcod = 17 and
                    vindex = 1 and
                    titulo.titdtemi < 10/20/2010
                then next.
                
                if setbcod = 23 and
                   estab.etbcod = 10 and
                   titulo.titdtemi > 04/30/2011
                then next.
                
/********
  Se titulo for da filial 10 e emissão for menor que 01/01/2014, o titulo
  pertence a filial 23 .  
   *************/
                if estab.etbcod = 10 and 
                   titulo.titdtemi < 01/01/2014
                then next. 

                if titulo.clifor = 1 then next.

                find clien where clien.clicod = titulo.clifor 
                  no-lock no-error.
                if not avail clien then next.
                
                if (titulo.titpar = 0 or titulo.titpar >= 51) and (acha("RENOVACAO",titulo.titobs[1]) = "SIM" or titulo.tpcontrato = "L")
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.
                                    
                if v-consulta-parcelas-LP = no
                    and v-parcela-lp = yes
                then next.
            
                if v-consulta-parcelas-LP = yes
                    and v-parcela-lp = no
                then next.

                vsubtot = vsubtot + titulo.titvlcob.

                output stream stela to terminal.
                  display stream stela
                          titulo.clifor
                          titulo.titnum
                          titulo.titpar
                          titulo.titdtven
                          with frame f-tela centered
                          1 down no-label. pause 0.
                output stream stela close.
            
                find first tt-bairro where
                           tt-bairro.cidade = clien.cidade[1] and 
                           tt-bairro.bairro = clien.bairro[1]
                           no-error.
                if not avail tt-bairro
                then do:
                    create tt-bairro.
                    tt-bairro.cidade = clien.cidade[1].
                    tt-bairro.bairro = clien.bairro[1].
                end.
                 
                find first tt-extrato 
                  where tt-extrato.rec = recid(clien) no-error.
                if not avail tt-extrato then do:
                    ii = ii + 1.
                    create tt-extrato.
                    assign 
                      tt-extrato.rec    = recid(clien)
                      tt-extrato.ord    = ii
                      tt-extrato.cidade = clien.cidade[1]
                      tt-extrato.bairro = clien.bairro[1]
                      tt-extrato.clinom = clien.clinom
                      tt-extrato.titnum = titulo.titnum
                      tt-extrato.titdtven = titulo.titdtven
                      tt-extrato.etbcod   = titulo.etbcod
                      tt-bairro.qtdcli = tt-bairro.qtdcli + 1.
                end.
                find first ttcli where 
                     ttcli.clicod = titulo.clifor no-error.
                if not avail ttcli then do:
                    create ttcli.
                    assign ttcli.clicod = titulo.clifor.
                end.

                create tt-titulo.
                assign
                    tt-titulo.etbcod = titulo.etbcod 
                    tt-titulo.clinom = clien.clinom 
                    tt-titulo.fone   = clien.fone 
                    tt-titulo.fax    = clien.fax  
                    tt-titulo.clifor = titulo.clifor 
                    tt-titulo.titnum = titulo.titnum 
                    tt-titulo.titpar = titulo.titpar 
                    tt-titulo.titdtemi =  titulo.titdtemi 
                    tt-titulo.titdtven =  titulo.titdtven 
                    tt-titulo.titvlcob =  titulo.titvlcob 
                    tt-titulo.dias =  titulo.titdtven - TODAY.
        end.
        
end procedure.

procedure p-imprime:
    def var vqtd as int init 0. 
    if valfa = 1
    then do:
        for each tt-titulo where tt-titulo.imp = no
                break by  tt-titulo.clinom :
        find clien where clien.clicod = tt-titulo.clifor no-lock no-error.
        display tt-titulo.etbcod column-label "Fil." 
                tt-titulo.clinom column-label "Nome do Cliente" format "x(20)"
                tt-titulo.fone column-label "fone" when avail clien
                tt-titulo.fax  column-label "Celular" when avail clien
                tt-titulo.clifor column-label "Cod."        format ">>>>>>>>>9"
                tt-titulo.titnum column-label "Contr."      format "x(10)"
                tt-titulo.titpar column-label "Pr."      
                tt-titulo.titdtemi column-label "Dt.Venda"  format "99/99/99"
                tt-titulo.titdtven column-label "Vencim."   format "99/99/99"
                tt-titulo.titvlcob  column-label "Valor da!Prestacao" 
                    format ">>>,>>9.99"
                tt-titulo.titdtven - TODAY column-label "Dias" format "->>>>9"
                            with frame ff1 width 130 down.
        
        tt-titulo.imp = yes.
        vqtd = vqtd + 1.
        end.
    end.
    else if valfa = 2
    then do:
        for each tt-titulo where tt-titulo.imp = no
                break by  tt-titulo.titdtven :
        find clien where clien.clicod = tt-titulo.clifor no-lock no-error.
        display tt-titulo.etbcod column-label "Fil." 
                tt-titulo.clinom column-label "Nome do Cliente"
                                      format "x(20)"
                tt-titulo.fone column-label "fone" when avail clien
                tt-titulo.fax  column-label "Celular" when avail clien
                tt-titulo.clifor column-label "Cod."      format ">>>>>>>>>9"
                tt-titulo.titnum column-label "Contr."    format "x(10)"
                tt-titulo.titpar column-label "Pr."      
                tt-titulo.titdtemi column-label "Dt.Venda" format "99/99/99"
                tt-titulo.titdtven column-label "Vencim."  format "99/99/99"
                tt-titulo.titvlcob  column-label "Valor da!Prestacao" 
                    format ">>>,>>9.99"
                tt-titulo.titdtven - TODAY column-label "Dias" format "->>>>9"
                            with frame ff2 width 130 down.

        tt-titulo.imp = yes.
        vqtd = vqtd + 1.
        end.
    end.
    else if valfa = 3
    then do:
        for each tt-titulo where tt-titulo.imp = no no-lock,
            first clien where clien.clicod = tt-titulo.clifor no-lock  
                                  break by clien.bairro[1]
                                  by clien.clinom
                                  by tt-titulo.titdtven.

            display tt-titulo.etbcod column-label "Fil." 
                tt-titulo.clinom column-label "Nome do Cliente"
                                      format "x(20)"
                clien.bairro[1] format "x(15)" column-label "Bairro"
                tt-titulo.fone column-label "fone" when avail clien
                tt-titulo.fax  column-label "Celular" when avail clien
                tt-titulo.clifor column-label "Cod."     
                        format ">>>>>>>>>9"
                tt-titulo.titnum column-label "Contr."    format "x(10)"
                tt-titulo.titpar column-label "Pr."      
                tt-titulo.titdtemi column-label "Dt.Venda" format "99/99/99"
                tt-titulo.titdtven column-label "Vencim."  format "99/99/99"
                tt-titulo.titvlcob  column-label "Valor da!Prestacao" 
                    format ">>>,>>9.99"
                tt-titulo.titdtven - TODAY column-label "Dias" format "->>>>9"
                            with frame ff3 width 160 down.

        tt-titulo.imp = yes.
        vqtd = vqtd + 1.
        end.
    end.
    else if valfa = 4
    then do:
        for each tt-titulo where tt-titulo.imp = no :
            find clien where clien.clicod = tt-titulo.clifor no-lock no-error.
             display tt-titulo.etbcod column-label "Fil." 
                tt-titulo.clinom column-label "Nome do Cliente"
                                      format "x(20)"
                tt-titulo.fone column-label "fone" when avail clien
                tt-titulo.fax  column-label "Celular" when avail clien
                tt-titulo.clifor column-label "Cod."      format ">>>>>>>>>9"
                tt-titulo.titnum column-label "Contr."    format "x(10)"
                tt-titulo.titpar column-label "Pr."      
                tt-titulo.titdtemi column-label "Dt.Venda"  format "99/99/99"
                tt-titulo.titdtven column-label "Vencim."   format "99/99/99"
                tt-titulo.titvlcob  column-label "Valor da!Prestacao" 
                    format ">>>,>>9.99"
                tt-titulo.titdtven - TODAY column-label "Dias" format "->>>>9"
                            with frame ff4 width 130 down.

        tt-titulo.imp = yes.
        vqtd = vqtd + 1.
        end.
    end.
    else if valfa = 5
    then do:
        for each tt-titulo where tt-titulo.imp = no
                    and tt-titulo.titpar > 30
                    break by  tt-titulo.clinom :
            find clien where clien.clicod = tt-titulo.clifor no-lock no-error. 
            display tt-titulo.etbcod column-label "Fil." 
                tt-titulo.clinom column-label "Nome do Cliente" format "x(20)"
                tt-titulo.fone column-label "fone" when avail clien
                tt-titulo.fax  column-label "Celular" when avail clien
                tt-titulo.clifor column-label "Cod."      format ">>>>>>>>>9"
                tt-titulo.titnum column-label "Contr."    format "x(10)"
                tt-titulo.titpar column-label "Pr."      
                tt-titulo.titdtemi column-label "Dt.Venda"  format "99/99/99"
                tt-titulo.titdtven column-label "Vencim."   format "99/99/99"
                tt-titulo.titvlcob  column-label "Valor da!Prestacao" 
                    format ">>>,>>9.99"
                tt-titulo.titdtven - TODAY    column-label "Dias"
                            format "->>>>9"
                            with frame ff5 width 130 down.
        
        tt-titulo.imp = yes.
        vqtd = vqtd + 1.
        end.
    end.
end procedure.

