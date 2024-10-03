{admcab-batch.i}

DEF INPUT  PARAM    lcJsonEntrada AS LONGCHAR.
DEF OUTPUT PARAM    varquivo-return          AS CHAR.
DEF OUTPUT PARAM    vpdf          AS CHAR.

{tsr/tsrelat.i}
{api/acentos.i}

DEF VAR hentrada AS HANDLE.
def temp-table ttparametros serialize-name "parametros"
    FIELD etbcod            AS INT
    FIELD dti       AS char
    FIELD dtf         AS char
    FIELD dtveni        AS char
    FIELD dtvenf         AS char
    FIELD consulta-parcelas-LP        AS LOG
    FIELD  mod-sel           AS CHAR
    FIELD feirao-nome-limpo  AS LOG.
                        
hEntrada = temp-table ttparametros:HANDLE.

hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").
                        
find first ttparametros no-error.
if not avail ttparametros then return.


def var v-cont as integer.
def var v-cod as char.
def var vmod-sel as char.

def var vdtpag like titulo.titdtpag.
def var vetbcod like estab.etbcod.
def stream stela.

def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".

def var vdtveni    as date format "99/99/9999".
def var vdtvenf    as date format "99/99/9999".

def var v-consulta-parcelas-LP as logical format "Sim/Nao" initial no.
def var v-parcela-lp as log.
def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.

def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def var vtotjur like plani.platot.
def var vtotpre like plani.platot.
def stream stela.
def var vdata like plani.pladat.

def temp-table tt-modalidade-selec
    field modcod as char
    index pk modcod.

def var vval-carteira as dec.                                
def var vcontador as int.

    vetbcod = ttparametros.etbcod.

    if ttparametros.dtf BEGINS "#" then do:
        vdtf = calculadata(ttparametros.dtf,TODAY).
    end.
    ELSE DO:
        vdtf = convertedata(ttparametros.dtf).
    END.
    if ttparametros.dtf BEGINS "#" then do:
        vdti = calculadata(ttparametros.dti,TODAY).
    end.
    ELSE DO:
        vdti  = convertedata(ttparametros.dti).
    END.

    if ttparametros.dtvenf BEGINS "#" then do:
        vdtvenf = calculadata(ttparametros.dtvenf,TODAY).
    end.
    ELSE DO:
        vdtvenf = convertedata(ttparametros.dtvenf).
    END.
    if ttparametros.dtveni BEGINS "#" then do:
        vdtveni = calculadata(ttparametros.dtveni,TODAY).
    end.
    ELSE DO:
        vdtveni  = convertedata(ttparametros.dtveni).
    END.

    v-consulta-parcelas-LP = ttparametros.consulta-parcelas-LP.
    vmod-sel = ttparametros.mod-sel. 
    
    do vcontador = 1 to num-entries(vmod-sel,",").
      
      if entry(vcontador,vmod-sel,",") = "" then next.
      
      create tt-modalidade-selec.
      tt-modalidade-selec.modcod = entry(vcontador,vmod-sel,",").
    end.

    v-feirao-nome-limpo = ttparametros.feirao-nome-limpo.
    
    if AVAIL tsrelat then do:
        varquivo = replace(RemoveAcento(tsrelat.nomerel)," ","") +
            "-ID" + STRING(tsrelat.idrelat) + "-" +  
             STRING(TODAY,"99999999") +
             replace(STRING(TIME,"HH:MM:SS"),":","").
    end.
    ELSE DO:
        varquivo = "recper-" + STRING(TODAY,"99999999") +
                        replace(STRING(TIME,"HH:MM:SS"),":","").
    END.
    
    /* output stream stela to terminal. Lucas 240720204 - removido */
        {mdadmcab.i
            &Saida     = "VALUE(vdir + varquivo + """.txt""")"
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = ""recper""
            &Nom-Sis   = """SISTEMA FINANCEIRO"""
            &Tit-Rel   = """RECEBIMENTO POR PERIODO - Periodo: "" + 
                          string(vdti,""99/99/9999"") + "" ATE "" + 
                          string(vdtf,""99/99/9999"")"
            &Width     = "160"
            &Form      = "frame f-cabcab"}

    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock:
        vtotpre = 0.
        vtotjur = 0.
                                 
        do vdtpag = vdti to vdtf:                         
        for each tt-modalidade-selec,
        
            each titulo use-index titdtpag
                    where titulo.empcod = 19           and
                          titulo.titnat = no           and
                          titulo.modcod = tt-modalidade-selec.modcod and
                          titulo.titsit = "PAG"        and
                          titulo.etbcod = estab.etbcod and
                          titulo.titdtpag = vdtpag     no-lock.

            if titulo.titdtven >= vdtveni   and 
               titulo.titdtven <= vdtvenf 
            then.
            else next.

/***
            if acha("RENOVACAO",fin.titulo.titobs[1]) = "SIM"
***/
            IF titulo.tpcontrato = "L"
            then assign v-parcela-lp = yes.
            else assign v-parcela-lp = no.
                                                
            if v-consulta-parcelas-LP = no
                and v-parcela-lp = yes
            then next.
                            
            if v-consulta-parcelas-LP = yes
                and v-parcela-lp = no
            then next.

            {filtro-feiraonl.i}
            /* Lucas 240720204 - removido 
            display stream stela
                    titulo.etbcod
                    titulo.titdtpag
                    vtotpre
                    vtotjur with frame f-1 centered row 10.  
            
            pause 0.   */
            
            assign vtotpre = vtotpre + titulo.titvlcob
                   vtotjur = vtotjur + titulo.titjuro.
         
        end.
        end.
         
        display estab.etbcod  column-label "Filial"
                vtotpre(total) column-label "Total!Prestacoes"
                vtotjur(total) column-label "Total!Juros"
                (vtotpre + vtotjur)(total) format "->>>,>>>,>>9.99"
                                       column-label "Total!Receb." 
                             with frame f-down down width 200.
    end.
    output close.
    /* output stream stela close.  Lucas 240720204 - removido */
    run pdfout.p (INPUT vdir + varquivo + ".txt",
                  input vdir,
                  input varquivo + ".pdf",
                  input "Landscape", /* Landscape/Portrait */
                  input 7,
                  input 1,
                  output vpdf).
    varquivo-return = varquivo.

/* end. */

/* Lucas 240720204 - procedure p-seleciona-modal, removido para programa 1 */



