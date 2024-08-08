/* helio 31072024 */
/*
    Titulos pagos com novacao
*/

DEF INPUT  PARAM    lcJsonEntrada AS LONGCHAR.
def output param    varquivo-return as char.
DEF OUTPUT PARAM    vpdf          AS CHAR.

{admcab-batch.i}
{tsr/tsrelat.i}
DEF VAR hentrada AS HANDLE.

def temp-table ttparametros serialize-name "parametros"
    field etbcod                AS int
    field dtinicial             AS char
    field dtfinal               AS char
    field sel-mod               AS CHAR
    field considerarfeirao      AS LOG.
                        
hEntrada = temp-table ttparametros:HANDLE.
hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").
                       
find first ttparametros no-error.
if not avail ttparametros then return.


def var vtipocxa as char.
def var vmodcod  as char. 
def var vmod-sel as char.
def var vetbcod like estab.etbcod.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.
def var vjuro as dec.

def temp-table tt-nov no-undo
    field etbcod like estab.etbcod
    field tipocxa as char format "x(3)" column-label "CXA"
    field modcod  like titulo.modcod
    field data as date
    field valor as dec
    field juro as dec
    field cont as int
    index i1 is unique primary data etbcod tipocxa modcod.

def var vtotal as dec.
def var vcont as int init 0.
      
def temp-table tt-modalidade-selec
    field modcod as char
    index pk modcod.
                               
def var vcontador as int.                                
def var dLoopDate as date.
   
 /* parametros vem do ttparametros */
 vetbcod = ttparametros.etbcod. 

 if ttparametros.dtfinal BEGINS "#" then do:
    vdtf = calculadata(ttparametros.dtfinal,TODAY).
end.
ELSE DO:
    vdtf =convertedata(ttparametros.dtfinal).
END.
if ttparametros.dtinicial BEGINS "#" then do:
    vdti = calculadata(ttparametros.dtinicial,vdtf).
end.
ELSE DO:
    vdti  = convertedata(ttparametros.dtinicial).
END.

 vmod-sel = ttparametros.sel-mod. 
 
 do vcontador = 1 to num-entries(vmod-sel,",").
      
      if entry(vcontador,vmod-sel,",") = "" then next.
      
      create tt-modalidade-selec.
      tt-modalidade-selec.modcod = entry(vcontador,vmod-sel,",").
    end.

 v-feirao-nome-limpo = ttparametros.considerarfeirao.  
 
for each estab where
             (if vetbcod > 0
              then estab.etbcod = vetbcod else true)
              no-lock:
    if vetbcod > 900 then next.

        
    do dLoopDate = vdti to vdtf:          
        
        vtotal = 0.
        vjuro = 0.
        for each tt-modalidade-selec,
            each titulo where
                 titulo.etbcobra = estab.etbcod and
                 titulo.titdtpag = dLoopDate and
                 titulo.modcod = tt-modalidade-selec.modcod and
                 titulo.moecod = "NOV" no-lock:

                 
            if v-feirao-nome-limpo
            then do:
                run filtro-feiraonl (output sresp).
                if not sresp
                then next.
            end.
                  vtotal = /*vtotal +*/ titulo.titvlcob.
            vjuro  = /*vjuro  +*/ titulo.titjuro.
            vcont  = /*vcont  +*/ 1.

            vtipocxa = if titulo.cxacod = ? or 
                          titulo.cxacod = 0 
                       then string(titulo.etbcobra,"999") 
                       else if titulo.cxacod >= 30 or  
                               titulo.etbcod = 140 
                            then "P2K" 
                            else "ADM".
            
            vmodcod = titulo.modcod.
            if vetbcod = 0 
            then do:
                vtipocxa = "".
                vmodcod  = "".
            end.    
                                                                      
            find first tt-nov where tt-nov.data = DLoopDate and
                                    tt-nov.etbcod = 0 and
                                    tt-nov.tipocxa = vtipocxa and
                                    tt-nov.modcod = vmodcod 
                                    no-error.
            if not avail tt-nov
            then do:
                create tt-nov.
                tt-nov.etbcod = 0.
                tt-nov.data = dLoopDate.    
                tt-nov.tipocxa = vtipocxa.
                tt-nov.modcod = vmodcod.
            end.
            tt-nov.valor = tt-nov.valor + vtotal.
            tt-nov.cont  = tt-nov.cont + 1.
                
            find first tt-nov where 
                                tt-nov.data = dLoopDate and
                                tt-nov.etbcod = estab.etbcod and
                                tt-nov.tipocxa = vtipocxa and
                                tt-nov.modcod = vmodcod

                                no-error.
            if not avail tt-nov
            then do:
                create tt-nov.
                tt-nov.data = dLoopDate.
                tt-nov.etbcod = estab.etbcod.    
                tt-nov.tipocxa = vtipocxa.
                tt-nov.modcod = vmodcod.
                
            end.
            tt-nov.valor = tt-nov.valor + vtotal.
            tt-nov.juro  = tt-nov.juro + vjuro.
            tt-nov.cont  = tt-nov.cont + 1.
                
            find first tt-nov where tt-nov.data = ? and
                                tt-nov.etbcod = estab.etbcod and
                                tt-nov.tipocxa = vtipocxa and
                                tt-nov.modcod = vmodcod

                                no-error.
            if not avail tt-nov
            then do:
                create tt-nov.
                tt-nov.data = ?.
                tt-nov.etbcod = estab.etbcod.    
                tt-nov.tipocxa = vtipocxa.
                tt-nov.modcod = vmodcod.
                
            end.
            tt-nov.valor = tt-nov.valor + vtotal.
            tt-nov.juro  = tt-nov.juro  + vjuro.
            tt-nov.cont  = tt-nov.cont  + 1.
        end.
    end.
    vcont = 0.
end.


    if AVAIL tsrelat then do:
        varquivo = replace(tsrelat.nomerel," ","") +
        "-ID" + STRING(tsrelat.idrelat) + "-" +  
         STRING(TODAY,"99999999") +
         replace(STRING(TIME,"HH:MM:SS"),":","").
    end.
    ELSE DO:
        varquivo = "rec-moe-nov-" + STRING(TODAY,"99999999") +
                        replace(STRING(TIME,"HH:MM:SS"),":","").
    END.
    
{mdad_l.i
        &Saida     = "VALUE(vdir + varquivo + """.txt""")"
        &Page-Size = "0"
        &Cond-Var  = "120"
        &Page-Line = "66"
        &Nom-Rel   = ""rec-moe-nov""
        &Nom-Sis   = """SISTEMA CCREDIARIO"""
        &Tit-Rel   = """ NOVACOES POR CAIXA/FILIAL "" +
                        string(vdti,""99/99/9999"") + "" A "" +
                        string(vdtf,""99/99/9999"") "
        &Width     = "120"
        &Form      = "frame f-cabcab"}


for each tt-nov where 
        tt-nov.data = ? and
        tt-nov.etbcod < 900 
        no-lock
        break by tt-nov.etbcod
              by tt-nov.tipocxa
              by tt-nov.modcod.
    find estab where estab.etbcod = tt-nov.etbcod no-lock.
  
    disp tt-nov.etbcod column-label "Estab."
    estab.etbnom column-label "Filial"
    tt-nov.tipocxa
    tt-nov.modcod
    
    tt-nov.valor(total)  format ">>>,>>>,>>9.99" column-label "Total (R$)"
    tt-nov.juro(total)   format ">>>,>>9.99" column-label "Juro P2K"
    tt-nov.cont(total) column-label "Total (qtd)"
    with frame f-disp down.
    down with frame f-disp.     

end.

output close.

 run pdfout.p (INPUT vdir + varquivo + ".txt",
                  input vdir,
                  input varquivo + ".pdf",
                  input "Landscape", /* Landscape/Portrait */
                  input 7,
                  input 1,
                  output vpdf).

varquivo-return = varquivo.


procedure filtro-feiraonl.
    def output parameter par-ok as log init yes.

    def buffer nov-titulo for titulo.

    find first tit_novacao where
                        tit_novacao.ori_empcod = titulo.empcod and
                        tit_novacao.ori_titnat = titulo.titnat and
                        tit_novacao.ori_modcod = titulo.modcod and
                        tit_novacao.ori_etbcod = titulo.etbcod and
                        tit_novacao.ori_clifor = titulo.clifor and
                        tit_novacao.ori_titnum = titulo.titnum and
                        tit_novacao.ori_titpar = titulo.titpar and
                        tit_novacao.ori_titdtemi = titulo.titdtemi
                    no-lock no-error.
    if avail tit_novacao
    then do.
        find contrato where contrato.contnum = tit_novacao.ger_contnum
                      no-lock no-error.
        if avail contrato
        then do.
            find last nov-titulo where nov-titulo.empcod = 19
                               and nov-titulo.titnat = no
                               and nov-titulo.modcod = "CRE"
                               and nov-titulo.etbcod = contrato.etbcod
                               and nov-titulo.clifor = contrato.clicod
                               and nov-titulo.titnum = string(contrato.contnum)
                               no-lock no-error.
            if avail nov-titulo
            then
                if v-feirao-nome-limpo
                then
                    if acha("FEIRAO-NOME-LIMPO",nov-titulo.titobs[1]) = "SIM"
                    then .
                    else par-ok = no.
                else
                    if acha("FEIRAO-NOME-LIMPO",nov-titulo.titobs[1]) = "SIM"
                    then par-ok = no.
        end.
    end.

end procedure.


