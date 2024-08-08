/* helio 28072022 - incluido varquivo */
/* helio 27062022 pacote de melhorias cobanca */

/*  cre02_a.p                                                               */
/*  alterado em out/2014                                                    */
/*  Se titulo for da filial 10 e emissão for menor que 01/01/2014, o titulo */
/*  pertence a filial 23 .                                                  */

/* #1 Helio 04.04.18 - Regra definida 
    TITOBS[1] contem FEIRAO = YES - NAO PERTENCE A CARTEIRA 
    ou
    TPCONTRATO = "L" - NAO PERTENCE A CARTEIRA
*/
{admcab-batch.i}

DEF INPUT  PARAM    lcJsonEntrada AS LONGCHAR.
def input  param    ptela         as log.
def output param    varquivo1     as char.
DEF OUTPUT PARAM    vpdf          AS CHAR.

{tsr/tsrelat.i}

def temp-table ttmodal no-undo
    field modcod like modal.modcod.

DEF VAR hentrada AS HANDLE.

def temp-table ttparametros NO-UNDO serialize-name "parametros"
    field posicao       as int
    field modalidade    as char
    field codigoFilial  as int
    field dataInicial   as char
    field dataFinal     as char
    field consulta-parcelas-LP as log
    field feirao-nome-limpo    as log
    field alfa          as int
    field vindex        as int.

hentrada =  temp-table ttparametros:HANDLE.

hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").

find first ttparametros no-error.
if not avail ttparametros then return.
if ttparametros.modalidade = "CREDIARIO"
then do:
    create ttmodal. ttmodal.modcod = "CRE". 
end.
if ttparametros.modalidade = "EMPRESTIMOS"
then do:
    create ttmodal. ttmodal.modcod = "CP0". 
    create ttmodal. ttmodal.modcod = "CP1". 
    create ttmodal. ttmodal.modcod = "CPN". 
end.

def var ii as int.
def stream stela.
def var vdata like plani.pladat.
def var vqtdcli as integer.
def var vdtvenini as date format "99/99/9999".
def var vdtvenfim as date format "99/99/9999".
def var vsubtot  like titulo.titvlcob.
def var vetbcod like estab.etbcod.


def var vcont-cli  as char format "x(14)" extent 5
initial [" Alfabetica   ",
         " Vencimento   ",
         " Bairro       ",
         " Valor Vencido",
         " Novacao      "].
def var valfa  as int.
def var vqtite as int.

def temp-table ttcli no-undo
    field clicod like clien.clicod.

def temp-table tt-titulo no-undo
    field etbcod like titulo.etbcod
    field clifor like titulo.clifor
    field clinom like clien.clinom
    field fone like clien.fone
    field fax  like clien.fax
    field titnum like titulo.titnum
    field titpar like titulo.titpar
    field modcod like titulo.modcod
    field tpcontrato like titulo.tpcontrato
    field titdtemi like titulo.titdtemi
    field titdtven like titulo.titdtven
    field titvlcob like titulo.titvlcob
    field dias     as int
    field imp as log
    index i1 clinom.     
    
def  shared temp-table tt-extrato 
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
    index i1 bairro cidade clinom titdtven
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

def var v-parcela-lp as log.
def var v-consulta-parcelas-LP as logical format "Sim/Nao" initial no.
def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.

    
    for each tt-extrato:
        delete tt-extrato.
    end.

    for each tt-bairro. delete tt-bairro. end.

    for each ttcli:
        delete ttcli.
    end.

    vetbcod = ttparametros.codigoFilial.
    find estab where estab.etbcod = vetbcod no-lock.    
    
    valfa = ttparametros.alfa.
    v-consulta-parcelas-LP = ttparametros.consulta-parcelas-LP.
    v-feirao-nome-limpo    = ttparametros.feirao-nome-limpo.
    vindex                 = ttparametros.vindex.

    if ttparametros.dataFinal BEGINS "#" then do:
        vdtvenfim = calculadata(ttparametros.dataFinal,TODAY).
    end.
    ELSE DO:
        vdtvenfim =convertedata(ttparametros.dataFinal).
    END.
    if ttparametros.dataInicial BEGINS "#" then do:
        vdtvenini = calculadata(ttparametros.dataInicial,vdtvenfim).
    end.
    ELSE DO:
        vdtvenini  = convertedata(ttparametros.dataInicial).
    END.

    for each tt-titulo.
        delete tt-titulo.
    end.    
    run p-gera.

    if AVAIL tsrelat then do:
        varquivo = "cre02_a" + string(setbcod) + "-ID" + STRING(tsrelat.idrelat) + "-" +  
                        STRING(TODAY,"99999999") +
                        replace(STRING(TIME,"HH:MM:SS"),":","").
    end.
    ELSE DO:
        varquivo = "cre02_a" + string(setbcod) + "-" + STRING(TODAY,"99999999") +
                        replace(STRING(TIME,"HH:MM:SS"),":","").
    END.
    if ptela then do:
        hide message no-pause.
        message "gerando relatorio" varquivo.
    end.
      
    {mdadmcab.i
        &Saida     = "VALUE(vdir + varquivo + """.txt""")"
        &Page-Size = "0"
        &Cond-Var  = "120"
        &Page-Line = "66"
        &Nom-Rel   = """cre02_a"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = """POSICAO FINANCEIRA GERAL P/FILIAL - CLIENTE - PERIODO DE ""
                       + string(vdtvenini) + "" A "" + string(vdtvenfim) "
        &Width     = "120"
        &Form      = "frame f-cab"}

    message "cre02_a" ttparametros.modalidade " - Posicao I - Ordem" vcont-cli[valfa].

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
    hide message no-pause.                                      
    
    run pdfout.p (INPUT vdir + varquivo + ".txt",
                  input vdir,
                  input varquivo + ".pdf",
                    input "Landscape",
                  input 7,
                  input 1,
                  output vpdf).
    varquivo1 = vdir + varquivo + ".txt".
    
/* = = = = = = = = = = = = = = = = = = = = = */

procedure p-gera:
    if ptela
    then do:
        disp "Aguarde.....!!" skip
        "Gerando Relatorio..."  with frame f-tela.
    end.
        FOR EACH TTMODAL,        
            each titulo use-index titdtven where
                        titulo.empcod = wempre.empcod and
                        titulo.titnat = no            and
                        titulo.modcod = ttmodal.modcod and
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
                else do:
                    /* #1 */
                    if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM" 
                    then next.
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
                
                if /* #1 (titulo.titpar = 0
                        or titulo.titpar >= 51)
                   and acha("RENOVACAO",titulo.titobs[1]) = "SIM"
                   */
                   titulo.tpcontrato = "L" /* #1 */
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.
                                    
                if v-consulta-parcelas-LP = no
                    and v-parcela-lp = yes
                then next.
            
                if v-consulta-parcelas-LP = yes
                    and v-parcela-lp = no
                then next.

                vsubtot = vsubtot + titulo.titvlcob.

                if ptela then do:
                    output stream stela to terminal.
                    display stream stela
                            titulo.clifor
                            titulo.titnum
                            titulo.titpar
                            titulo.titdtven
                            with frame f-tela centered
                            1 down no-label. pause 0.
                    output stream stela close.

                end.
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
                    tt-titulo.modcod = titulo.modcod
                    tt-titulo.tpcontrato = titulo.tpcontrato
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
                tt-titulo.modcod
                tt-titulo.titnum column-label "Contrato"      format "x(10)" /* helio 28072022 era "Contr." */
                tt-titulo.titpar column-label "Par"      
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
                tt-titulo.modcod
                tt-titulo.titnum column-label "Contrato"    format "x(10)" /* helio 28072022 era "Contr." */
                tt-titulo.titpar column-label "Par"      
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
                tt-titulo.modcod
                tt-titulo.titnum column-label "Contrato"    format "x(10)" /* helio 28072022 era "Contr." */
                tt-titulo.titpar column-label "Par"      
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
                tt-titulo.modcod 
                tt-titulo.titnum column-label "Contrato"    format "x(10)" /* helio 28072022 era "Contr." */
                tt-titulo.titpar column-label "Par"      
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
                    and tt-titulo.tpcontrato = "N"
                    break by  tt-titulo.clinom :
            find clien where clien.clicod = tt-titulo.clifor no-lock no-error. 
            display tt-titulo.etbcod column-label "Fil." 
                tt-titulo.clinom column-label "Nome do Cliente" format "x(20)"
                tt-titulo.fone column-label "fone" when avail clien
                tt-titulo.fax  column-label "Celular" when avail clien
                tt-titulo.clifor column-label "Cod."      format ">>>>>>>>>9"
                tt-titulo.modcod
                tt-titulo.titnum column-label "Contrato"    format "x(10)" /* helio 28072022 era "Contr." */
                tt-titulo.titpar column-label "Par"      
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
