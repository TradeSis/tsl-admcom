/*
    28/01/2015 - Atualizar MIX via importacao de arquivo
    02/04/2015 - Permitir arquivos com mais de um codigo de mix
*/
{admcab.i}

def var vpasta   as char init "/admcom/mix/".
def var varquivo as char.
def var verro    as log.
def var vnovo    as int.
def var valter   as int.
def buffer p-tabmix for tabmix.
def buffer f-tabmix for tabmix.

def temp-table tt-mix
    field codmix     like tabmix.codmix
    field procod     like tabmix.promix
    field qtdmix     like tabmix.qtdmix
    field mostruario as char.

do on error undo with frame f-importa side-label.
    disp " Layout: Cod.Mix;Cod.Produto;Estoque Minimo;Mostruario".

    update vpasta   label "  Pasta" format "x(20)".

    update varquivo label "Arquivo" format "x(50)".

    if search(vpasta + varquivo) = ?
    then do.
        message "Arquivo nao encontrado" view-as alert-box.
        undo.
    end.
end.

input from value(vpasta + varquivo).
repeat.
    create tt-mix.
    import delimiter ";" tt-mix.
end.
input close.

/*
    Validar arquivo recebido
*/
verro = no.
for each tt-mix.
    find tabmix where tabmix.tipomix = "M"
                  and tabmix.codmix  = tt-mix.codmix
                no-lock no-error.
    if not avail tabmix or tt-mix.codmix = 99
    then do.
        message "Codigo do MIX incorreto:" tt-mix.codmix view-as alert-box.
        verro = yes.
    end.

    find produ where produ.procod = tt-mix.procod no-lock no-error.
    if not avail produ
    then do.
        message "Produto incorreto" tt-mix.procod view-as alert-box.
        verro = yes.
    end.
    if tt-mix.qtdmix <= 0
    then do.
        message "Quantidade incorreta:" tt-mix.procod view-as alert-box.
        verro = yes.
    end.
end.
if verro
then return.

sresp = no.
message "Confirma importacao?" update sresp.
if not sresp
then return.

/***
def temp-table tt-codmix
    field codmix like tabmix.codmix.
***/
    
for each tt-mix.
    find tabmix where tabmix.tipomix = "M"
                  and tabmix.codmix  = tt-mix.codmix
                no-lock.
    find produ where produ.procod = tt-mix.procod no-lock.

    find first p-tabmix where p-tabmix.tipomix = "P"
                          and p-tabmix.codmix  = tt-mix.codmix
                          and p-tabmix.promix  = tt-mix.procod
                      no-error.
    if not avail p-tabmix
    then do.
        vnovo = vnovo + 1.
        create p-tabmix.
        assign
            p-tabmix.tipomix = "P"
            p-tabmix.codmix  = tt-mix.codmix
            p-tabmix.promix  = tt-mix.procod
            p-tabmix.etbcod  = 0.
    end.
    else
        assign
            valter = valter + 1.

    assign
        p-tabmix.qtdmix     = tt-mix.qtdmix
        p-tabmix.mostruario = tt-mix.mostruario = "Sim".

    /* Criar subclasse */
    find first f-tabmix where f-tabmix.tipomix = "F"
                          and f-tabmix.codmix  = tt-mix.codmix
                          and f-tabmix.promix  = produ.clacod
                      no-lock no-error.
    if not avail f-tabmix
    then do.
        create f-tabmix.
        assign
            f-tabmix.tipomix = "F"
            f-tabmix.codmix  = tt-mix.codmix
            f-tabmix.promix  = produ.clacod
            f-tabmix.etbcod  = tabmix.etbcod
            f-tabmix.campodat1 = today /* Data Inicio */
            f-tabmix.campolog2 = yes.  /* Ajusta Mix */
    end.

    /* Replicacao para as lojas */
    if p-tabmix.mostruario
    then run grava (produ.procod, tabmix.etbcod, "Sim").
    else run grava (produ.procod, tabmix.etbcod, "Nao").

/***
    find first tt-codmix where
               tt-codmix.codmix = tt-mix.codmix
               no-error.
    if not avail tt-codmix
    then do:
        create tt-codmix.
        tt-codmix.codmix = tt-mix.codmix.
    end.           
***/
end.

/***
for each tt-codmix where tt-codmix.codmix > 0:
    message "Enviando MIX " tt-codmix.codmix.
    pause 0.
    run expmix01.p(input tt-codmix.codmix, 0).
end.
***/

message "Arquivo importado: Novos = " vnovo " Alterados = " valter
        view-as alert-box.


/* adaptado de expmix01.p */
procedure grava.

    def input parameter par-procod like produaux.procod.
    def input parameter par-etbcod as int.
    def input parameter par-valor  as char.
    def var vacao as char.     

    find first produaux where
                          produaux.procod     = par-procod and
                          produaux.nome_campo = "Mix" and
                          produaux.valor_campo begins string(par-etbcod,"999")
                          no-error.
    if not avail produaux
    then do.
        create produaux.
        assign
            produaux.procod     = par-procod
            produaux.nome_campo = "Mix".
            vacao = "INCLUSAO".
    end.
    vacao = if par-valor = "Nao"
            then "EXCLUSAO"
            else "INCLUSAO".   
    assign
        produaux.valor_campo = string(par-etbcod,"999") + "," + par-valor
        produaux.datexp   = today
        produaux.exportar = yes. 
    release produaux.
    
/***
    create tablog.
    ASSIGN tablog.etbcod      = par-etbcod                 
           tablog.funcod      = sfuncod                 
           tablog.banco       = "COM"                   
           tablog.tabela      = "LOGMIX"                
           tablog.acao        = vacao                   
           tablog.data        = today                   
           tablog.hora        = ?
           tablog.dec2        = time
           tablog.dec1        = dec(setbcod)                   
           tablog.char1       = string(tabmix.codmix)    /* "CODMIX" */ 
           tablog.char2       = string(par-procod)  /* "PROCOD" */.
    release tablog.
***/

end procedure.
        
