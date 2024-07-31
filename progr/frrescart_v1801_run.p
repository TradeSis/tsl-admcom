/* #1 06.06.17 Helio - Alteracao incluindo colunas por tipo de carteira */
/* #2 16.06.17 Helio - Procedure que retorno rpcontrato vlnominla e saldo */
/* #3 Helio 04.04.18 - Versionamento com Regra definida 
    TITOBS[1] contem FEIRAO = YES - NAO PERTENCE A CARTEIRA 
    ou
    TPCONTRATO = "L" - NAO PERTENCE A CARTEIRA
*/

{admcab-batch.i}

DEF INPUT  PARAM    lcJsonEntrada AS LONGCHAR.
DEF OUTPUT PARAM    vtxt          AS CHAR.
DEF OUTPUT PARAM    vpdf          AS CHAR.

{tsr/tsrelat.i}

DEF VAR hentrada AS HANDLE.

def temp-table ttparametros serialize-name "parametros"
    field cre               as LOG
    field dti            as char
    field dtf               AS char
    field clinovos              AS LOG
    field sel-mod               AS CHAR
    field feirao-nome-limpo      AS LOG
    FIELD vindex                AS INT.
                        
hEntrada = temp-table ttparametros:HANDLE.

hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").
                        
find first ttparametros no-error.


/* #2 */
def var par-parcial as log column-label "Par!cial" format "Par/Ori".
def var par-parorigem like titulo.titpar column-label "Par!Ori".
def var par-titvlcob as dec column-label "VlCarteira".
def var par-titdtpag as date column-label "DtPag".
def var par-titvlpag as dec column-label "VlPago".
def var par-saldo as dec column-label "VlSaldo".
def var par-tpcontrato as char format "x(1)" column-label "Tp".
def var par-titdtemi as date column-label "Dtemi".
def var par-titdesc as dec column-label "VlDesc".
def var par-titjuro as dec column-label "VlJuro".
/* #2 */

            
def var vclinovos as log format "Sim/Nao".
def buffer btitulo for titulo.

def var v-cont as integer.
def var v-cod as char.
def var vmod-sel as char.

DEF temp-table tt-modalidade-selec /* #4 */
    field modcod as char.
def var vval-carteira as dec.                                
                                

def var etb-tit like titulo.etbcod.

def var vcre as log format "Geral/Facil" initial yes.

/*
def temp-table tt-cli
    field clicod like clien.clicod.
*/

def temp-table tt-clinovo
    field clicod like clien.clicod
    index i1 clicod.

def var par-paga as int.
def var pag-atraso as log.
def buffer ctitulo for titulo.

def var vdt like titulo.titdtven.
def var vdti like titulo.titdtven.
def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.
def var vdtf like titulo.titdtven.
def var wcrenov like titulo.titvlcob.

def temp-table wtit no-undo /* #1 */
    field wetb like titulo.etbcod
    field wvalor like titulo.titvlcob
    /* #1 */
    field fei    like titulo.titvlcob
    field lp     like titulo.titvlcob
    field nov    like titulo.titvlcob
    field cre    like titulo.titvlcob
    /* #1 */
    field wpar   like titulo.titpar format ">>>>>>9"
    index i1 wetb.
                    

    
def temp-table tt-clien no-undo
    field clicod like clien.clicod
    field mostra as log init no
    index ind01 clicod.
    
def temp-table bwtit no-undo
    field bwetbcod like titulo.etbcod
    field bwclifor like titulo.clifor
    field bwtitvlcob like titulo.titvlcob
    field bwtitdtven like titulo.titdtven.

def var v-fil17 as char extent 2 format "x(15)"
    init ["Nova","Antiga"].
def var vindex as int. 
def var vcontador as int.

/* parametros vem do ttparametros */

vcre = ttparametros.cre.
if ttparametros.dtf BEGINS "#" then do:
    vdtf = calculadata(ttparametros.dtf,TODAY).
end.
ELSE DO:
    vdtf = convertedata(ttparametros.dtf).
END.
if ttparametros.dti BEGINS "#" then do:
    vdti = calculadata(ttparametros.dti,vdtf).
end.
ELSE DO:
    vdti  = convertedata(ttparametros.dti).
END.
vclinovos = ttparametros.clinovos.
vmod-sel = ttparametros.sel-mod. 
vindex = ttparametros.vindex.

do vcontador = 1 to num-entries(vmod-sel,",").
     
     if entry(vcontador,vmod-sel,",") = "" then next.
     
     create tt-modalidade-selec.
     tt-modalidade-selec.modcod = entry(vcontador,vmod-sel,",").
   end.
  
v-feirao-nome-limpo = ttparametros.feirao-nome-limpo.
 
    
    for each wtit.
        delete wtit.
    end.
    
    if vcre 
    then do:
        
        for each estab no-lock:
        
            do vdt = vdti to vdtf:
                for each tt-modalidade-selec no-lock,
                
                    each titulo
                    where titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.modcod = tt-modalidade-selec.modcod and
                          titulo.etbcod = estab.etbcod and
                          titulo.titdtven = vdt no-lock:

                    if titulo.etbcod = 17 and
                        vindex = 2 and
                        titulo.titdtemi >= 10/20/2010
                    then next.  
                    else if titulo.etbcod = 17 and
                        vindex = 1 and
                        titulo.titdtemi < 10/20/2010
                    then next.

                    etb-tit = titulo.etbcod.
                    run muda-etb-tit.

                    /** {filtro-feiraonl.i} #1 */
                    
                    if vclinovos = yes
                    then do:
                        run cli-novo.
                    end.

                    find first tt-clinovo where 
                       tt-clinovo.clicod = titulo.clifor
                       no-error.
                    if not avail tt-clinovo 
                    and vclinovos
                    then next. 
                    
                    find first wtit where wtit.wetb = etb-tit 
                        no-error.
                    if not avail wtit
                    then do:
                        create wtit.
                        assign wtit.wetb = etb-tit.
                    end.    

                    par-tpcontrato = titulo.tpcontrato.
                        /* #2
                    run fbtituloposicao.p 
                        (recid(titulo), 
                         vdtf,
                         output par-parcial,
                         output par-parorigem,
                         output par-titdtemi,
                         output par-tpcontrato,
                         output par-titvlcob,
                         output par-titdtpag,
                         output par-titvlpag ,
                         output par-titdesc ,
                         output par-titjuro,
                         output par-saldo).
                      */

                    wtit.wvalor = wtit.wvalor + titulo.titvlcob.
                    wtit.wpar   = wtit.wpar   + 1.
                    
                    /* #1 */
                    /* #3 - regra esta correta */
                    if  /* #3 se FEIRAO ou TPCONTRATO = "L"
                              nao pertence a carteira
                        */      
                       acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM" or
                       titulo.tpcontrato = "L"  /* #3 */
                    then do:
                        /* #3  PRIORIZA FEIRAO */
                        if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                        then 
                          wtit.fei = wtit.fei + titulo.titvlcob.
                        else
                          wtit.lp  = wtit.lp  + titulo.titvlcob.
                    end.
                    else do:
                        if titulo.tpcontrato = "N"  /* #3 */
                        then
                           wtit.nov  = wtit.nov + titulo.titvlcob.
                        else
                           wtit.cre  = wtit.cre + titulo.titvlcob.
                    end.                
                    /* #3 */
                    /* #1 */

                    create bwtit.
                    assign bwtit.bwetbcod = etb-tit
                           bwtit.bwclifor = titulo.clifor
                           bwtit.bwtitvlcob = titulo.titvlcob
                           bwtit.bwtitdtven = titulo.titdtven.
                    pause 0.
                end.
            end.
        end.
    end.
    else do:
        for each /* tt-cli */ clien where clien.classe = 1 NO-LOCK,
        
            each tt-modalidade-selec,
        
            each titulo use-index iclicod where 
                              titulo.clifor = clien.clicod and
                              titulo.empcod = 19    and
                              titulo.titnat = no    and
                              titulo.modcod = tt-modalidade-selec.modcod and
                              titulo.titdtven >= vdti and
                              titulo.titdtven <= vdtf     
                                   no-lock: 
            
                if titulo.etbcod = 17 and
                   vindex = 2 and
                   titulo.titdtemi >= 10/20/2010
                then next.  
                else if titulo.etbcod = 17 and
                     vindex = 1 and
                     titulo.titdtemi < 10/20/2010
                then next.

                etb-tit = titulo.etbcod.
                
                run muda-etb-tit.

                par-tpcontrato = titulo.tpcontrato.
                /* #2
                    run fbtituloposicao.p 
                        (recid(titulo), 
                         vdtf,
                         output par-parcial,
                         output par-parorigem,
                         output par-titdtemi,
                         output par-tpcontrato,
                         output par-titvlcob,
                         output par-titdtpag,
                         output par-titvlpag ,
                         output par-titdesc ,
                         output par-titjuro,
                         output par-saldo).
                */

 
                {filtro-feiraonl.i}

                if vclinovos = yes
                then do:
                    run cli-novo.
                end.

                find first tt-clinovo where 
                       tt-clinovo.clicod = titulo.clifor
                       no-error.
                if not avail tt-clinovo 
                    and vclinovos
                then next. 
            
                find first wtit where wtit.wetb = etb-tit no-error.
                if not avail wtit
                then do:
                    create wtit.
                    assign wtit.wetb = etb-tit.
                end.    
                wtit.wvalor = wtit.wvalor + titulo.titvlcob.
                wtit.wpar   = wtit.wpar   + 1.
                create bwtit.
                assign bwtit.bwetbcod = etb-tit
                       bwtit.bwclifor = titulo.clifor
                       bwtit.bwtitvlcob = titulo.titvlcob
                       bwtit.bwtitdtven = titulo.titdtven.  
                pause 0.
            end.
    end.
   
   
            
//end.

procedure muda-etb-tit.

    if etb-tit = 10 and
        titulo.titdtemi < 01/01/2014
    then etb-tit = 23.
    
end procedure.
                    
     if AVAIL tsrelat then do:
        varquivo = "frrescart-ID" + STRING(tsrelat.idrelat) + "-" +  
                        STRING(TODAY,"99999999") +
                        replace(STRING(TIME,"HH:MM:SS"),":","").
    end.
    ELSE DO:
        varquivo = "frrescart-" + STRING(TODAY,"99999999") +
                        replace(STRING(TIME,"HH:MM:SS"),":","").
    END.
    
    {mdadmcab.i
        &Saida     = "VALUE(vdir + varquivo + """.txt""")"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""frrescart1801"" /* #1 */
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """MOVIMENTO DA CARTEIRA POR FILIAL - PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "140"
            &Form      = "frame f-cabcab"}

    for each wtit use-index i1:
        wcrenov = wtit.nov + wtit.cre. /* #1 */
        disp wtit.wetb column-label "Filial"
             wtit.wvalor(total) column-label "(1+2+3+4) Vl.Total"
             wtit.wpar(total) column-label "Tot.Par"
              /* #1 */
             wtit.fei (total) column-label "(1) Feirao"
             wtit.lp  (total) column-label "(2) LP" 
             wtit.nov (total) column-label "(3) Novacao"
             wtit.cre (total) column-label "(4) Venda"
             wcrenov (total) column-label "(3+4) Crediario"
             /* #1 */
             with frame f2 down width 140.
    end.            
    output close.
    
     run pdfout.p (INPUT vdir + varquivo + ".txt",
                  input vdir,
                  input varquivo + ".pdf",
                  input "Landscape", /* Landscape/Portrait */
                  input 7,
                  input 1,
                  output vpdf).
        vtxt =  vdir + varquivo + ".txt".             

                  
/* helio 1807 deixar comentado
procedure p-cliente:

    if opsys = "UNIX"
    then  varquivo = "../relat/cartlc" + string(day(today)).
    else  varquivo = "..\relat\cartwc" + string(day(today)).
 
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""CARTE1c""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """CARTEIRA CLIENTES POR FILIAL - PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "80"
            &Form      = "frame f-cabcab"}

    for each bwtit where
             bwtit.bwetbcod = wtit.wetb
             no-lock:
        disp bwtit.bwetbcod   column-label "Filial"
             bwtit.bwclifor   column-label "Cliente"
             bwtit.bwtitvlcob column-label "Valor Parc." 
             bwtit.bwtitdtven   column-label "Data Vencto."
             with frame f2 down width 130.
    end.            
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}.
        /*dos silent value("type " + varquivo + " > prn").
        */
    end.     
    
end procedure.
*/

procedure cli-novo:
    find first tt-clinovo where
               tt-clinovo.clicod = titulo.clifor
               no-error.
    if not avail tt-clinovo
    then do:
        par-paga = 0.
        pag-atraso = no.

        for each ctitulo where
                 ctitulo.clifor = titulo.clifor 
                 no-lock:
            if ctitulo.titpar = 0 then next.
            if ctitulo.modcod = "DEV" or
                ctitulo.modcod = "BON" or
                ctitulo.modcod = "CHP"
            then next.
 
            if ctitulo.titsit = "LIB"
            then next.

            par-paga = par-paga + 1.
            if par-paga = 31
            then leave.
            if ctitulo.titdtpag > ctitulo.titdtven 
            then pag-atraso = yes.   
            
        end.
        find first posicli where posicli.clicod = titulo.clifor
               no-lock no-error.
        if avail posicli
        then par-paga = par-paga + posicli.qtdparpg.
            
        find first credscor where credscor.clicod = titulo.clifor
                        no-lock no-error.
        if avail credscor
        then  par-paga = par-paga + credscor.numpcp.
        
        if par-paga <= 30 and pag-atraso = yes
        then do:   
            create tt-clinovo.
            tt-clinovo.clicod = titulo.clifor.
        end.
    end. 
end procedure.



