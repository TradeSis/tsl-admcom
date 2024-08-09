{admcab.i}
DEF VAR lcJsonEntrada AS LONGCHAR.
DEF VAR hentrada AS HANDLE.

def temp-table ttparametros NO-UNDO serialize-name "parametros"
    field cre               as log
    field codigoFilial      as int
    field mod-sel           as char
    field dataInicial       as char
    field dataFinal         as char
    field dataReferencia    as char
    field consulta-parcelas-LP   as log
    field feirao-nome-limpo      as log
    field abreporanoemi          as log
    field clinovos          as log
    field porestab          as log
    field vindex            as INT.

hentrada =  temp-table ttparametros:HANDLE.
def var vetbcod like estab.etbcod.
def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def var vdtref  as   date format "99/99/9999" .
def var vporestab as log format "Sim/Nao".
def var vcre as log format "Geral/Facil" initial yes.
def var vtipo as log format "Nova/Antiga".
def var vdisp   as   char format "x(8)".
def var vtotal  like titulo.titvlcob.
def var vmes    as   char format "x(3)" extent 12 initial
["JAN","FEV","MAR","ABR","MAI","JUN",
"JUL","AGO","SET","OUT","NOV","DEZ"] .

def var vtot1   like titulo.titvlcob.
def var vtot2   like titulo.titvlcob.

def var v-consulta-parcelas-LP as logical format "Sim/Nao" initial no.
def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.
def var v-novacao as log format "Sim/Nao" initial no.
def var v-abreporanoemi as log format "Sim/Nao" initial no.
def var vclinovos as log format "Sim/Nao" initial no.

DEF VAR varquivo AS CHAR.
def var vpdf as char no-undo.

def var vmod-sel as char.
def var v-fil17 as char extent 2 format "x(15)"
    init ["Nova","Antiga"].
def var vindex as int. 
def var etb-tit like titulo.etbcod.

def NEW SHARED temp-table tt-modalidade-selec /* #1 */
    field modcod as char.

update vcre label "Cliente" colon 25 with side-label width 80.

assign sresp = false.
update sresp label "Seleciona Modalidades?" colon 25
help "Não = Modalidade CRE Padrão / Sim = Seleciona Modalidades"
 with side-label width 80.

if sresp
then run selec-modal.p ("REC"). /* #4 */
else do:
    create tt-modalidade-selec.
    assign tt-modalidade-selec.modcod = "CRE".
end.

assign vmod-sel = "".
for each tt-modalidade-selec.
    assign vmod-sel = vmod-sel + trim(tt-modalidade-selec.modcod) + ",".
end.
display vmod-sel format "x(40)" no-label.

if sremoto /* #3 */
then disp setbcod @ estab.etbcod.
else prompt-for estab.etbcod label "Estabelecimento"  colon 25.
if input estab.etbcod <> ""
then do:
    find estab where estab.etbcod = input estab.etbcod no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento Invalido".
        undo.
    end.
    display estab.etbnom no-label .
    pause 0.
   

    vindex = 0.
    if estab.etbcod = 17
    then do:
         disp v-fil17 with frame f-17 1 down centered row 10 
            no-label.
         choose field v-fil17 with frame f-17.
         vindex = frame-index.   
    end.
end.
else do on error undo:
    display "Geral" @ estab.etbnom.
    update vporestab label "Por Filial" colon 25.
    
    if vporestab
    then do on error undo:
        update vdti label "Periodo de"
               vdtf label "Ate" 
        with frame ff row 6 no-box side-label overlay column 40.
        if vdti = ? or vdtf = ?
        then undo.
    end.
end.        

vetbcod = input estab.etbcod.

if vporestab = no
then update vdtref   label "Data Referencia" colon 25
    with  side-label .
            
if (vcre and vporestab = no) or vcre = no
then
update v-consulta-parcelas-LP label " Considera apenas LP"
 help "'Sim' = Parcelas acima de 51 / 'Nao' = Parcelas abaixo de 51"  colon 25
    with  side-label .


if (vcre and vporestab = no) or vcre = no 
then
update v-feirao-nome-limpo label "Considerar apenas feirao"
        colon 25 with side-label.

update v-abreporanoemi label "Abre por Ano de Emissao?" colon 25.

update 
vclinovos label "Somente clientes novos(até 30 pagas) que atrasaram parcela(s)"
with frame fff111 1 down no-box overlay side-label.



    CREATE ttparametros.
    ttparametros.cre        = vcre.
    ttparametros.codigofilial   = vetbcod.
    ttparametros.mod-sel        = vmod-sel.
    ttparametros.datainicial    = string(vdti,"99/99/9999").
    ttparametros.datafinal      = string(vdtf,"99/99/9999"). 
    ttparametros.dataReferencia = string(vdtref,"99/99/9999"). 
    ttparametros.consulta-parcelas-LP         = v-consulta-parcelas-LP.
    ttparametros.feirao-nome-limpo     = v-feirao-nome-limpo.
    ttparametros.abreporanoemi     = v-abreporanoemi.
    ttparametros.clinovos       = vclinovos.
    ttparametros.porestab       = vporestab.
    ttparametros.vindex         = vindex.

    hentrada:WRITE-JSON("longchar",lcjsonentrada).

    
    RUN frsalcart_v2002_run.p (INPUT  lcjsonentrada,
                               input yes, /* tela */
                               OUTPUT varquivo,
                               OUTPUT vpdf). 
    
    
    run visurel.p(varquivo, "").
    

            

