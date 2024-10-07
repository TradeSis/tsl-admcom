/*
#1 - 31.08.2017 - Nova novacao - novo filtro de modaildades
*/
{admcab-batch.i}
DEF INPUT  PARAM    lcJsonEntrada AS LONGCHAR.
def input  PARAM    ptela         as log.
def output param    varquivo1     as char.
DEF OUTPUT PARAM    vpdf          AS CHAR.

{tsr/tsrelat.i}
{api/acentos.i}

DEF VAR hentrada AS HANDLE.

def temp-table ttparametros NO-UNDO serialize-name "parametros"
    field mod-sel       as char
    field dataInicial   as char
    field dataFinal     as char
    field feirao-nome-limpo    as log.
                        
hEntrada = temp-table ttparametros:HANDLE.

hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").
                        
find first ttparametros no-error.
if not avail ttparametros then return.

def temp-table tt-cli NO-UNDO
    field clicod like clien.clicod.

def var vdata like plani.pladat.
def var i as i.
def var vdtini  like plani.pladat.
def var vdtfin  like plani.pladat.
def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.
def var vtotal  like titulo.titvlcob column-label "Total".

def temp-table wftotal NO-UNDO
 field etbcod like estab.etbcod    column-label "Estab"
 field data   like titulo.titdtpag column-label "Data"
field atras  like titulo.titvlcob column-label "Atrasados"
format ">>,>>>,>>9.99"
field pont1  like titulo.titvlcob column-label "Pontual 1"
format ">>,>>>,>>9.99"
field entra  like titulo.titvlcob column-label "Entrada"
format ">>,>>>,>>9.99"
field vista  like titulo.titvlcob column-label "A Vista"
format ">>,>>>,>>9.99"
field pont2  like titulo.titvlcob column-label "Pontual 2"
format ">>,>>>,>>9.99"
field antec  like titulo.titvlcob column-label "Antecipado"
format ">>,>>>,>>9.99".

def var v-cont as integer.
def var v-cod as char.
def var vmod-sel as char.

def NEW SHARED temp-table tt-modalidade-selec NO-UNDO /* #1 */
    field modcod as char.

def var vconta as int.

    /* parametrois vem do ttparametros */
    vmod-sel = ttparametros.mod-sel. 
    
    do vconta = 1 to num-entries(vmod-sel,",").
      
      if entry(vconta,vmod-sel,",") = "" then next.
      
      create tt-modalidade-selec.
      tt-modalidade-selec.modcod = entry(vconta,vmod-sel,",").
    end.

    v-feirao-nome-limpo = ttparametros.feirao-nome-limpo.

    if ttparametros.dataFinal BEGINS "#" then do:
        vdtfin = calculadata(ttparametros.dataFinal,TODAY).
    end.
    ELSE DO:
        vdtfin =convertedata(ttparametros.dataFinal).
    END.
    if ttparametros.dataInicial BEGINS "#" then do:
        vdtini = calculadata(ttparametros.dataInicial,TODAY).
    end.
    ELSE DO:
        vdtini  = convertedata(ttparametros.dataInicial).
    END.

def var etb-tit like titulo.etbcod.

for each estab no-lock.
    do vdata = vdtini to vdtfin:
        for each tt-modalidade-selec,
        
            each titulo where titulo.empcod = 19 and
                              titulo.titnat = no and
                              titulo.modcod = tt-modalidade-selec.modcod and
                              titulo.titdtpag = vdata and
                              titulo.etbcod = estab.etbcod no-lock:

            etb-tit = titulo.etbcod.
            if etb-tit = 10 and
                titulo.titdtemi < 01/01/2014
            then etb-tit = 23.
            if ptela
            then do:
                display "Processando Loja" estab.etbcod vdata
                with centered row 10 frame festab no-label.
                pause 0 before-hide.    
            end.
            if titulo.titpar = 0
            then next.
            if titulo.modcod = "VVI"
            then next.
            if titulo.clifor <= 1
            then next.
             /**
            {filtro-feiraonl.i}
            **/
            if titulo.titsit <> "PAG"
            then next.
            
            find first wftotal where wftotal.etbcod = etb-tit no-error.
            if not avail wftotal
            then do:
                create wftotal.
                assign wftotal.etbcod = etb-tit.
            end.
            
            if titulo.titdtven < date(month(vdtini),01,year(vdtini))
            then wftotal.atras = wftotal.atras + titulo.titvlcob.
            else
            if month(titulo.titdtven) = month(vdtfin) and
               year(titulo.titdtven) = year(vdtfin) and
               titulo.titdtemi < vdtini
            then wftotal.pont1 = wftotal.pont1 + titulo.titvlcob.
            else
            if month(titulo.titdtemi) = month(vdtfin) and
               year(titulo.titdtemi) = year(vdtfin) and
               month(titulo.titdtven) = month(vdtfin) and
               year(titulo.titdtven) = year(vdtfin)
            then wftotal.pont2 = wftotal.pont2 + titulo.titvlcob.
            else
            wftotal.antec = wftotal.antec + titulo.titvlcob.
        end.
    end.
end.


if AVAIL tsrelat then do:
    varquivo = replace(RemoveAcento(tsrelat.nomerel)," ","") +
    "-ID" + STRING(tsrelat.idrelat) + "-" +  
     STRING(TODAY,"99999999") +
     replace(STRING(TIME,"HH:MM:SS"),":","").
end.
ELSE DO:
    varquivo = "resliq-" + STRING(TODAY,"99999999") +
                    replace(STRING(TIME,"HH:MM:SS"),":","").
END.

output to value(vdir + varquivo + ".txt") page-size 65.

for each wftotal break by wftotal.etbcod with width 127.
    form header wempre.emprazsoc
         space(6) "RESLIQ"  at 107
         "Pag.: " at 118 page-number format ">>9" skip
         "RESUMO DAS LIQUIDACOES "
         "PERIODO DE " string(vdtini) " A " string(vdtfin)
         today format "99/99/9999" at 107
         string(time,"hh:mm:ss") at 120
         skip fill("-",127) format "x(127)" skip
         with frame fcab no-label page-top no-box width 127.
    view frame fcab.

    if first-of(wftotal.etbcod)
    then vtotal = 0.
    vtotal = wftotal.atras + wftotal.pont1 + wftotal.pont2 + wftotal.antec.
    display wftotal.etbcod
            wftotal.atras (TOTAL)
            wftotal.pont1 (TOTAL)
            wftotal.pont2 (TOTAL)   /******* tirar , colocar Prestacoes ****/
            wftotal.antec (TOTAL).
   display vtotal        (TOTAL).  /******* tirar ******/
end.
output close.


run pdfout.p (INPUT vdir + varquivo + ".txt",
            input vdir,
            input varquivo + ".pdf",
            input "Landscape", /* Landscape/Portrait */
            input 7,
            input 1,
            output vpdf).
varquivo1 = vdir + varquivo + ".txt".

