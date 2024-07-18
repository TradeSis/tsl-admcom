/* #1 06.06.17 Helio - Alteracao incluindo colunas por tipo de carteira */
/* #2 16.06.17 Helio - Procedure que retorno rpcontrato vlnominla e saldo */
/* #3 Helio 04.04.18 - Versionamento com Regra definida 
    TITOBS[1] contem FEIRAO = YES - NAO PERTENCE A CARTEIRA 
    ou
    TPCONTRATO = "L" - NAO PERTENCE A CARTEIRA  
*/

{admcab.i}
{setbrw.i}
DEF VAR lcJsonEntrada AS LONGCHAR.
DEF VAR hentrada AS HANDLE.

def temp-table ttparametros serialize-name "parametros"
    field cliente               as LOG
    field dtinicial             as DATE
    field dtfinal               AS DATE
    field clinovos              AS LOG
    field sel-mod               AS CHAR
    field considerarfeirao      AS LOG.
hentrada =  temp-table ttparametros:HANDLE.


/* variaveis usadas na tela para pedir parametros */    
def var vcre as log format "Geral/Facil" initial yes.
def var vdti like titulo.titdtven.
def var vdtf like titulo.titdtven.
def var vclinovos as log format "Sim/Nao".
def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.
def var v-fil17 as char extent 2 format "x(15)" init ["Nova","Antiga"].

def var vpdf as char no-undo.

def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","RELATORIO","CLIENTE","",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","","","",""].


def var v-cont as integer.
def var v-cod as char.
def var vmod-sel as char.

def temp-table tt-modalidade-padrao 
    field modcod as char
    index pk modcod.

def NEW SHARED temp-table tt-modalidade-selec /* #4 */
    field modcod as char.
/*             
def temp-table tt-modalidade-selec
    field modcod as char
    index pk modcod.
*/
                               
                                
form
   a-seelst format "x" column-label "*"
   tt-modalidade-padrao.modcod no-label
        with frame f-nome
             centered down title "Modalidades"
             color withe/red overlay.    
                                                        
create tt-modalidade-padrao.
assign tt-modalidade-padrao.modcod = "CRE".

for each profin no-lock.
    create tt-modalidade-padrao.
    assign tt-modalidade-padrao.modcod = profin.modcod.        
end.

form
 esqcom1
    with frame f-com1
                 row 3  no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.


form " " 
     " "
     with frame f-linha 10 down color with/cyan /*no-box*/
     centered.

def var etb-tit like titulo.etbcod.


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
def var varquivo as char format "x(30)".
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

vdti = today - 1.
vdtf = vdti.

def var vindex as int. 

repeat:
    
    update vcre label "Cliente" colon 25
           help "Opcao: G=Geral; F=Carteira fácil"
           vdti label "Data Inicial"  colon 25
           vdtf label "Data Final"  colon 25
           skip
           vclinovos label 
           "Somente clientes novos(até 30 pagas) que atrasaram parcela(s)"
           with frame f1 side-label width 80.
           
    assign sresp = false.
           
    update sresp label "Seleciona Modalidades?" colon 25
           help "Não = Modalidade CRE Padrão / Sim = Seleciona Modalidades"
           with frame f1.

    
    update v-feirao-nome-limpo label "Considerar apenas feirao" colon 25
        when vcre = no /* #1 */
           with frame f1.
             
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
display vmod-sel format "x(40)" no-label with frame f1.

       
    if vdti = ? or vdtf = ?
       or vdti > vdtf 
    then do:
         message "Data invalida...".
         Next.
    end.     

    vindex = 0.
   repeat on endkey undo:
         disp v-fil17 with frame f-17 1 down centered row 12 
            no-label title " Filial 17 ".
         choose field v-fil17 with frame f-17.
         vindex = frame-index.  
         leave. 
    end.
    
    
    CREATE ttparametros.
    ttparametros.cliente = vcre.
    ttparametros.dtinicial = vdti.
    ttparametros.dtfinal = vdtf.
    ttparametros.clinovos = vclinovos.
    ttparametros.sel-mod = vmod-sel.
    ttparametros.considerarfeirao = v-feirao-nome-limpo.
  
    hentrada:WRITE-JSON("longchar",lcjsonentrada).
    
    RUN frrescart_v1801_run.p (INPUT  lcjsonentrada,
                               OUTPUT vpdf).

   
    
            
end.



