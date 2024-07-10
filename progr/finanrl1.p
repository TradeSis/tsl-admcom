{admcab.i}
def temp-table tt-contrato like contrato.
def temp-table tt-titulo like titulo
use-index cxmdat
use-index datexp
use-index etbcod
use-index exportado
use-index iclicod
use-index titdtpag
use-index titdtven
use-index titnum
use-index titsit
.
def var vetbcod like estab.etbcod.
def var vanalitico as log format "Sim/Nao".
def var vdata as date.
def var vdti as date.
def var vdtf as date.
def temp-table tt-estab 
    field etbcod like estab.etbcod
    .
update vetbcod label "Filial" with frame f1.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.
    create tt-estab.
    tt-estab.etbcod = estab.etbcod.
end.
else do:
    for each estab where estab.etbnom begins "DREBES-FIL" NO-LOCK:
        create tt-estab.
        tt-estab.etbcod = estab.etbcod.
    end.
end.        
update vdti at 1 label "Periodo Financeira" format "99/99/9999"
       vdtf no-label format "99/99/9999"
       with frame f1 width 80 1 down side-label.

if vdti = ? or vdtf = ? or vdti > vdtf
then undo.

/*       
update       vdata at 1  label "Data Financeira" format "99/99/9999"
       with frame f1 width 80 1 down
       side-label.
if vdata = ? or
   vdata > today
then undo.   
*/

update vanalitico at 1 label "Analitico" with frame f1.

do vdata = vdti to vdtf:
for each tt-estab,
    each envfinan where envfinan.etbcod = tt-estab.etbcod and
                        envfinan.datexp = vdata and
                        envfinan.envsit <> "RET" no-lock.
    find contrato where contrato.contnum = int(envfinan.titnum)
                    no-lock no-error.
    if not avail contrato then next.
    find first tt-contrato where 
               tt-contrato.contnum = contrato.contnum
                               no-error.
    if not avail tt-contrato
    then do:
        create tt-contrato.
        buffer-copy contrato to tt-contrato.
    end.
    find titulo where titulo.empcod = 19 and
                      titulo.titnat = no and
                      titulo.modcod = "CRE" and
                      titulo.etbcod = contrato.etbcod and
                      titulo.clifor = contrato.clicod and
                      titulo.titnum = string(contrato.contnum) and
                      titulo.titpar = envfinan.titpar
                      no-lock no-error.
    if not avail titulo or
       (titulo.cobcod = 2 and contrato.banco <> 10)
    then delete tt-contrato.
    else do:
        find first tt-titulo of titulo no-error.
        if not avail tt-titulo
        then do:
            create tt-titulo.
            buffer-copy titulo to tt-titulo.        
        end.          
    end.
end.
end.
form with frame ff.
def var vtotal as dec.
def var vtotal-con as dec.
def var varquivo as char.
if opsys = "UNIX"
then varquivo = "/admcom/import/financeira/finanre1." + string(time).
else varquivo = "l:~\relat\finanre1." + string(time).

{mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "120" 
                &Page-Line = "66" 
                &Nom-Rel   = ""finanre1"" 
                &Nom-Sis   = """SISTEMA FINANCEIRO/CONTABIL""" 
                &Tit-Rel   = """ CONTRATOS FINANCEIRA""" 
                &Width     = "120"
                &Form      = "frame f-cabcab"}

DISP with frame f1.
def var vqtd-con as int.
for each tt-estab:
for each tt-contrato where tt-contrato.etbcod = tt-estab.etbcod no-lock:
    find clien where clien.clicod = tt-contrato.clicod no-lock.
    vqtd-con = vqtd-con + 1.
    disp     tt-contrato.etbcod column-label "Fil"
             tt-contrato.contnum     format ">>>>>>>>>9"
             tt-contrato.clicod  format ">>>>>>>>>9"
             clien.clinom   format "x(20)"
             tt-contrato.vltotal    format ">,>>>,>>9.99"
             tt-contrato.dtinicial  format "99/99/99"
             vqtd-con column-label "Quant." format ">>>>>>9"
             with frame ff width 145 down
             .
    vtotal = 0.
    if vanalitico
    then do:
    for each tt-titulo where 
             tt-titulo.clifor = clien.clicod and
             tt-titulo.titnum = string(tt-contrato.contnum)
             no-lock by tt-titulo.titpar :
        disp tt-titulo.titpar
             tt-titulo.titdtven format "99/99/99"
             tt-titulo.titvlcob format ">>,>>9.99"
             tt-titulo.titdtpag format "99/99/99"
             tt-titulo.titvlpag when tt-titulo.titvlpag <> 0
                    format ">>,>>9.99"
             with frame ff 
             .
        vtotal = vtotal + tt-titulo.titvlcob.
        down with frame ff.
    end. 
    put fill("-",130) format "x(120)" skip.            
    disp    "TOTAL " @ tt-titulo.titdtven
            vtotal @ tt-titulo.titvlcob with frame ff.
    down with frame ff.
    put fill("=",130) format "x(120)" skip.
    end.
    else down with frame ff.
    vtotal-con = vtotal-con + tt-contrato.vltotal.
end.
disp "TOTAL GERAL" @ CLIEN.CLINOM
     vtotal-con @ tt-contrato.vltotal
     vqtd-con
     with frame ff.
end.     
put skip(2).
output close.     
if opsys = "UNIX"       
then do:
    run visurel.p(varquivo,"").
end.
else do:
    {mrod.i}
end.    
