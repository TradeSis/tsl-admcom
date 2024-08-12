{admcab.i}

def input param pmodalidade as char.


DEF VAR lcJsonEntrada AS LONGCHAR.
DEF VAR hentrada AS HANDLE.

def temp-table ttparametros NO-UNDO serialize-name "parametros"
    field posicao       as int
    field modalidade    as char
    field codigoFilial  as int
    field dataInicial   as char
    field dataFinal     as char
    field consulta-parcelas-LP as log
    field feirao-nome-limpo    as log
    field alfa          as int
    field vindex        as int.
    
hentrada =  temp-table ttparametros:HANDLE.


def var vcont-cli  as char format "x(14)" extent 5
      initial [" Alfabetica   ",
               " Vencimento   ",
               " Bairro       ",
               " Valor Vencido",
               " Novacao      "].
def var valfa as int.

def NEW shared temp-table tt-extrato 
    field rec      as recid
    field ord      as int
    field cidade as char
    field bairro   like clien.bairro[1]
    field clinom   like clien.clinom
    field titnum   like titulo.titnum
    field titdtven like titulo.titdtven
    field etbcod   like estab.etbcod
    index ind-1 ord
    index i-bairro bairro
    index i1 bairro cidade clinom titdtven
    index i-rec     rec.
    
def new shared temp-table tt-bairro
    field cidade as char
    field bairro as char
    field marca as char
    field qtdcli as int
    index i1 bairro
    index i-cidbai  cidade bairro.

def var vdtvenini as date format "99/99/9999".
def var vdtvenfim as date format "99/99/9999".
def var vetbcod like estab.etbcod.
def var vfil17 as char extent 2 format "x(15)"
    init["Nova","Antiga"].
def var vindex as int.
def var v-consulta-parcelas-LP as logical format "Sim/Nao" initial no.
def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.
def var vpdf as char no-undo.
DEF VAR varquivo AS CHAR.

repeat with 1 down:
    for each tt-extrato:
        delete tt-extrato.
    end.

    for each tt-bairro. delete tt-bairro. end.
       
    if setbcod = 999
    then do:
        update vetbcod colon 25 with title pmodalidade + " - Posicao I ".
    end.
    else do:
        vetbcod = setbcod.
        disp vetbcod.
    end.
            
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento Invalido" .
        undo.
    end.
    display estab.etbnom no-label.

    pause 0.
    vindex = 0.
    if estab.etbcod = 17
    then do:
        disp vfil17 no-label with frame f-17 1 down row 10 centered
             side-label overlay.
        pause 0.     
        choose field vfil17  with frame f-17.
        vindex = frame-index.    
    end.
    
    update vdtvenini label "Vencimento Inicial" colon 25
           vdtvenfim label "Final"
                with row 4 side-labels width 80 .

    update v-consulta-parcelas-LP label " Considera apenas LP"
     help "'Sim' = Parcelas acima de 51 / 'Nao' = Parcelas abaixo de 51"
                    colon 25
        with  side-label .

    update v-feirao-nome-limpo label "Considerar apenas feirao"
                help "NAO = Geral    SIM = Feirao"
                                    colon 25 with side-label overlay .
                                    
    disp vcont-cli no-label with frame f1 width 80 row 10 
    overlay.
    choose field vcont-cli with frame f1.
    valfa = frame-index.

    CREATE ttparametros.
    ttparametros.posicao        = 1.    /* este programa */
    ttparametros.modalidade     = pmodalidade.
    
    ttparametros.codigofilial   = vetbcod.
    ttparametros.datainicial    = string(vdtvenini,"99/99/9999").
    ttparametros.datafinal      = string(vdtvenfim,"99/99/9999"). 
    ttparametros.consulta-parcelas-LP         = v-consulta-parcelas-LP.
    ttparametros.feirao-nome-limpo     = v-feirao-nome-limpo.
    ttparametros.alfa           = valfa.
    ttparametros.vindex         = vindex.
    
    hentrada:WRITE-JSON("longchar",lcjsonentrada).
    
    RUN loj/cre02_a_run.p (INPUT  lcjsonentrada,
                           input yes, /* tela */
                           output varquivo,
                           OUTPUT vpdf).
                     

    message ("Arquivo " + vpdf + " gerado com sucesso!").

    run visurel.p (varquivo,"").

    message "Deseja gerar extratos? " update sresp.
    if sresp 
    then do:
        hide frame f1 no-pause.
        message "Aguarde... Processando ...".
        run loj/extrato2.p (input valfa).
    end.

    return.
end.
