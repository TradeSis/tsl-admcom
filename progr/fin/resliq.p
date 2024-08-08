{admcab.i}

DEF VAR lcJsonEntrada AS LONGCHAR.
DEF VAR hentrada AS HANDLE.
def var vpdf as char no-undo.
def var varquivo as char no-undo.

def temp-table ttparametros NO-UNDO serialize-name "parametros"
    field mod-sel       as char
    field dataInicial   as char
    field dataFinal     as char
    field feirao-nome-limpo    as log.

hentrada =  temp-table ttparametros:HANDLE.

def var vdtini  like plani.pladat.
def var vdtfin  like plani.pladat.
def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.

def var vmod-sel as char.

def NEW SHARED temp-table tt-modalidade-selec /* #1 */
    field modcod as char.

assign sresp = false.
update sresp label "Seleciona Modalidades?" colon 25
        help "Não = Modalidade CRE Padrão / Sim = Seleciona Modalidades"
        with side-label width 80 frame f1.
if sresp
then run selec-modal.p ("REC"). /* #1 */
else do:
    create tt-modalidade-selec.
    assign tt-modalidade-selec.modcod = "CRE".
end.

assign vmod-sel = "".
for each tt-modalidade-selec.
    assign vmod-sel = vmod-sel + trim(tt-modalidade-selec.modcod) + ",".
end.     
display vmod-sel format "x(40)" no-label with frame f1.

update vdtini   colon 25 label "Data Inicial"
       vdtfin   colon 25 label "Data Final"
       with frame f1.

update v-feirao-nome-limpo label "Considerar apenas feirao" colon 25
       with frame f1.
 
CREATE ttparametros.
ttparametros.mod-sel       = vmod-sel.
ttparametros.datainicial   = string(vdtini,"99/99/9999").
ttparametros.datafinal     = string(vdtfin,"99/99/9999"). 
ttparametros.feirao-nome-limpo = v-feirao-nome-limpo.

hentrada:WRITE-JSON("longchar",lcjsonentrada).
 
RUN fin/resliq_run.p (INPUT  lcjsonentrada,
                       input  yes, /* tela */
                       output varquivo,
                       OUTPUT vpdf).
 
 
run visurel.p(varquivo,"").

 


