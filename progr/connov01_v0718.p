/* PROGRAMA DE EXEMPLO, ERA DE TELA SOMENTE */
/* FOI DIVIDIDO EM TELA (ESTE) E EXECUÇÃO - _run.p */
/* helio - fica apenas a parte que pede dados. */

{admcab.i}
{setbrw.i}
{tt-modalidade-padrao.i new}
create tt-modalidade-padrao.
tt-modalidade-padrao.modcod = "CPN".

DEF VAR lcJsonEntrada AS LONGCHAR.
DEF VAR hentrada AS HANDLE.
def var varquivo as char.
def temp-table ttparametros no-undo serialize-name "parametros"
    field codigoFilial      as int
    field dataInicial       as char
    field dataFinal         as char
    field considerarFeirao  as log
    field mod-sel           as char
    field vindex            as int.

hentrada =  temp-table ttparametros:HANDLE.



/* variaveis usadas na tela para pedir parametros */  
def var v-cont as integer.
def var v-cod as char.
def var vmod-sel as char.

def temp-table tt-modalidade-selec no-undo
    field modcod as char
    index pk modcod.


def var vetbcod like estab.etbcod.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.
def var vesc as char format "x(15)" extent 3
        init["ANALITICO","SINTETICO","POR DATA"]. 
def var vindex as int.
def var vpdf as char no-undo.
 
form
a-seelst format "x" column-label "*"
tt-modalidade-padrao.modcod no-label
with frame f-nome
    centered down title "Modalidades"
    color withe/red overlay.  

REPEAT:
   
    update vdti label "Data Inicial"  colon 25
    vdtf label "Data Final " with frame f1 side-label width 80.
 
    do on error undo:
    message "Informe a Filial para analitico" update vetbcod.  
    if vetbcod > 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab then undo.
    end.     
    end.

    assign sresp = false.
        
    update sresp label "Seleciona Modalidades?" colon 25
        help "Não = Modalidade CRE Padrão / Sim = Seleciona Modalidades"
        with side-label
        width 80 frame f1.
        
    if sresp
    then do:
    bl_sel_filiais:
    repeat:
        run p-seleciona-modal.
                                                
        if keyfunction(lastkey) = "end-error"
        then leave bl_sel_filiais.
    end.
    end.
    else do:
    create tt-modalidade-selec.
    assign tt-modalidade-selec.modcod = "CRE".
    end.

    assign vmod-sel = "".
    for each tt-modalidade-selec.
        assign vmod-sel = vmod-sel + trim(tt-modalidade-selec.modcod) + ",".
    end.   
    
    display vmod-sel format "x(40)" no-label with frame f1.

    update v-feirao-nome-limpo label "Considerar apenas feirao" colon 25
    with frame f1.

    IF vetbcod = 0
    then do:
        disp vesc with frame f-esc 1 down no-label.
        choose field vesc with frame f-esc.
        vindex = frame-index.
        hide frame f-esc.
        message "AGUARDE PROCESSAMENTO... " VESC[vindex].
    end.
    
    disp "Aguarde... Montando relatorio."
    with frame f-disp1 1 down no-box no-label color message.
    pause 0.

    CREATE ttparametros.
    ttparametros.mod-sel            = vmod-sel.
    ttparametros.codigofilial       = vetbcod.
    ttparametros.datainicial        = string(vdti,"99/99/9999").
    ttparametros.datafinal          = string(vdtf,"99/99/9999"). 
    ttparametros.considerarFeirao   = v-feirao-nome-limpo.
    ttparametros.vindex             = vindex.
    
    hentrada:WRITE-JSON("longchar",lcjsonentrada).
    
    RUN connov01_v0718_run.p (INPUT  lcjsonentrada,
                              input yes, /* tela */
                              output varquivo,
                              OUTPUT vpdf).
    
    run visurel.p(varquivo,"").    
    
end.

procedure p-seleciona-modal:
            
{sklcls.i
    &File   = tt-modalidade-padrao
    &help   = "                ENTER=Marca F4=Retorna F8=Marca Tudo"
    &CField = tt-modalidade-padrao.modcod    
    &Ofield = " tt-modalidade-padrao.modcod"
    &Where  = " true"
    &noncharacter = /*
    &LockType = "NO-LOCK"
    &UsePick = "*"          
    &PickFld = "tt-modalidade-padrao.modcod" 
    &PickFrm = "x(4)" 
    &otherkeys1 = "
        if keyfunction(lastkey) = ""CLEAR""
        then do:
            V-CONT = 0.
            for each tt-modalidade-padrao no-lock:
                a-seelst = a-seelst + "","" + tt-modalidade-padrao.modcod.
                v-cont = v-cont + 1.
            end.
            message ""                         SELECIONADAS "" 
            V-CONT ""FILIAIS                                   ""
            .
                         a-seeid = -1.
            a-recid = -1.
            next keys-loop.
        end. "
    &Form = " frame f-nome" 
}. 

hide frame f-nome.
v-cont = 2.
repeat :
    v-cod = "".
    if num-entries(a-seelst) >= v-cont
    then v-cod = entry(v-cont,a-seelst).

    v-cont = v-cont + 1.

    if v-cod = ""
    then leave.
    create tt-modalidade-selec.
    assign tt-modalidade-selec.modcod = v-cod.
end.


end.