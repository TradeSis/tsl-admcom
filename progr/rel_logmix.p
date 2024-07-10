/*              */
/* Projeto Melhorias Mix - Luciano                                      */

{admcab.i }
def buffer bfunc for func.
def  var cestab     as char format "x(60)".
def  var cprodu     as char format "x(60)".

def  var vEstab     as log  format "Sim/Nao"  init yes.
def  var vprodu     as log  format "Sim/Nao"  init yes.
def  var ctitrel      as char .
def temp-table wfestab
    field etbcod        like estab.etbcod init 0.
def temp-table wfprodu
    field procod        like produ.procod init 0.
def buffer bwfestab    for wfestab.
def buffer bwfprodu    for wfprodu.


def  var cclase     as char format "x(30)".
def  var vclase     as log  format "Sim/Nao"  init yes.
def  temp-table wfclase
    field clacod-classe like clase.clacod init 0. 
def buffer bwfclase    for wfclase.

def  var csclase     as char format "x(30)".
def  var vsclase     as log  format "Sim/Nao"  init yes.
def  temp-table wfsclase
    field clacod        like clase.clacod init 0. 
def buffer bwfsclase    for wfsclase.

def  var vdtini  as Date    label "Data Inicial" form "99/99/99".
def  var vdtfim  as Date    label "Data Final"   form "99/99/99".

/** Processamento do filtro: **/
def buffer grupo   for clase.
def buffer classe  for clase.
def buffer sclasse for clase.
def var par-tipo as char format "x(15)" extent 3
        init [" Todas ", " Inclusao ", " Exclusao "].

form
    vEstab          colon 30   label "Todos Estabelecimentos.."
            help "Relatorio com Todos os Estabelecimentos ?"
            cestab no-label format "x(40)"
    vprodu          colon 30   label "Todos Produtos.........."
            help "Relatorio com Todos os Produtos ?"
            cprodu no-label format "x(40)"
    vclase         colon 30    label "Todas as Classes........"
            help "Relatorio com todas as Classes ?"
            cclase no-label format "x(30)"
    vsclase        colon 30    label "Todas as Sub-Classes...."
            help "Relatorio com todas as Sub-Classes ?"
            csclase no-label format "x(30)"
    "Tipo....................:" at 6
                par-tipo no-label
            
    skip
    with frame fopcoes
        row 3 side-label width 80.
disp par-tipo     with frame fopcoes
.
form                                           
    "Periodo"  at 18
    vdtini help "Informe a Data Inicial do Periodo"
    "a"
    vdtfim help "Informe a Data Final do Periodo"
    with frame fperiodo
        no-label row 10 width 81 no-box overlay.

do:
end.

display
    vEstab
    par-tipo   
    
    with frame fopcoes.

do on error undo.
    
    clear frame fopcoes all no-pause.

    /*
      Estabelecimentos 
    */    
    for each wfestab.
        delete wfestab.
    end.
    cestab = "".
    update vestab
           with frame fopcoes.
    if vestab = yes
    then 
        cestab = "Geral".
    else
      repeat with frame festab title "Selecao de Estabelecimentos"
                        centered retain 1 row 14 overlay.
        create wfEstab.
        update wfestab.etbcod
    help "Selecione o Estabelecimento ou tecle <F4> para Sair da Selecao".

        if wfestab.etbcod = 0
        then leave.
        find first bwfestab where bwfestab.etbcod = wfestab.etbcod and
                             recid(bwfestab) <> recid(wfestab) no-error.
        if avail bwfestab
        then do :
           delete wfestab. 
           undo.
        end.
        find first estab where estab.etbcod = wfestab.etbcod no-lock no-error.
        if not avail estab
        then do:
            message "Estabelecimento Invalido".
            delete wfestab.
            undo.
        end.
        disp estab.etbnom.
      end.
    hide frame festab no-pause.

    if not vEstab then
      for each wfestab by wfestab.etbcod.
        find estab where estab.etbcod = wfestab.etbcod no-lock no-error.
        if not avail estab
        then next.
        cestab = trim(cestab + " " + string(estab.etbcod)).
      end.
    display cestab with frame fopcoes.

    /******************************/
    
    /*
      produtos 
    */    
    for each wfprodu.
        delete wfprodu.
    end.
    cprodu = "".
    update vprodu
           with frame fopcoes.
    if vprodu = yes
    then 
        cprodu = "Geral".
    else
      repeat with frame fprodu title "Selecao de produtos"
                        centered retain 1 row 14 overlay.
        create wfprodu.
        update wfprodu.procod
    help "Selecione o Produtos ou tecle <F4> para Sair da Selecao".

        if wfprodu.procod = 0
        then leave.
        find first bwfprodu where bwfprodu.procod = wfprodu.procod and
                             recid(bwfprodu) <> recid(wfprodu) no-error.
        if avail bwfprodu
        then do :
           delete wfprodu. 
           undo.
        end.
        find first produ where produ.procod = wfprodu.procod no-lock no-error.
        if not avail produ
        then do:
            message "Produto Invalido".
            delete wfprodu.
            undo.
        end.
        disp produ.pronom.
      end.
    hide frame fprodu no-pause.

    if not vprodu then
      for each wfprodu by wfprodu.procod.
        find produ where produ.procod = wfprodu.procod no-lock no-error.
        if not avail produ
        then next.
        cprodu = trim(cprodu + " " + string(produ.procod)).
      end.
    display cprodu with frame fopcoes.

    /******************************/
    
    
    /*
      Classe
    */
    update vclase         
             with frame fopcoes.

    for each wfclase.
       delete wfclase.
    end. 
    cclase = "".
    if vclase
    then 
        cclase = "Geral".
    else
      repeat with frame fclase title "Selecao de Classes"
                        centered retain 1 row 14 overlay.
        create wfclase.
        update wfclase.clacod-classe
    help "Selecione a sub-classe ou tecle <F4> para Sair da Selecao".

        if wfclase.clacod-classe = 0
        then leave.
        find first bwfclase where 
                            bwfclase.clacod-classe = wfclase.clacod-classe and
                             recid(bwfclase) <> recid(wfclase) no-error.
        if avail bwfclase
        then do :
           delete wfclase. 
           undo.
        end.
        find clase where clase.clacod = wfclase.clacod-classe no-lock no-error.
        if not avail clase
        then do:
            message "Classe Invalida".
            delete wfclase.
            undo.
        end.
        disp clase.clanom.
      end.
    hide frame fclase no-pause.

    if not vclase then
      for each wfclase by wfclase.clacod-classe.
        find clase where clase.clacod = wfclase.clacod-classe no-lock no-error.
        if not avail clase
        then next.
        cclase = trim(cclase + " " + string(clase.clacod)).
      end.
    display cclase no-label with frame fopcoes.

/*****************/

    /******************************/
    
    /*
      SubClasse
    */
    update vsclase         
             with frame fopcoes.

    for each wfsclase.
       delete wfsclase.
    end. 
    csclase = "".
    if vsclase
    then 
        csclase = "Geral".
    else
      repeat with frame fsclase title "Selecao de Sub-Classes"
                        centered retain 1 row 14 overlay.
        create wfsclase.
        update wfsclase.clacod
    help "Selecione a sub-classe ou tecle <F4> para Sair da Selecao".

        if wfsclase.clacod = 0
        then leave.
        find first bwfsclase where bwfsclase.clacod = wfsclase.clacod and
                             recid(bwfsclase) <> recid(wfsclase) no-error.
        if avail bwfsclase
        then do :
           delete wfsclase. 
           undo.
        end.
        find clase where clase.clacod = wfsclase.clacod no-lock no-error.
        if not avail clase
        then do:
            message "Sub-classe Invalida".
            delete wfsclase.
            undo.
        end.
        disp clase.clanom.
      end.
    hide frame fsclase no-pause.

    if not vsclase then
      for each wfsclase by wfsclase.clacod.
        find clase where clase.clacod = wfsclase.clacod no-lock no-error.
        if not avail clase
        then next.
        csclase = trim(csclase + " " + string(clase.clacod)).
      end.
    display csclase no-label with frame fopcoes.

/**/
    disp par-tipo     with frame fopcoes.
    choose field par-tipo with frame fopcoes.
    def var vindex as int.
    vindex = frame-index.
    
    /*
      Datas
    */
    pause 0.
    update  vdtini format "99/99/9999"
            vdtfim format "99/99/9999"
            with frame fperiodo.
    if vDtFim < vDtIni 
    then do:
      message "Data invalida" view-as alert-box.
      undo.
    end.
end.
def var vdata as date.

def var varquivo  as char.

if opsys = "UNIX"
then varquivo = "/admcom/relat/rel_logmix." + string(time).
else varquivo = "..~\relat~\rel_logmix." + string(time).
    
{mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "150" 
                &Page-Line = "66" 
                &Nom-Rel   = ""rel_logmix"" 
                &Nom-Sis   = """SISTEMA COMERCIAL""" 
                &Tit-Rel   = """ LOG DE ALTERACAO DE MIX  """ 
                &Width     = "150"
                &Form      = "frame f-cabcab"}

display 
    vEstab          colon 30   label "Todos Estabelecimentos.."
            cestab no-label format "x(40)"
    vprodu          colon 30   label "Todos Produtos.........."
            cprodu no-label format "x(40)"
    vclase         colon 30    label "Todas as Classes........"
            cclase no-label format "x(30)"
    vsclase        colon 30    label "Todas as Sub-Classes...."
            csclase no-label format "x(30)"
    "Tipo....................:" at 6
                par-tipo[vindex] @ par-tipo[1] no-label
            
    skip
    
    "Periodo"  at 18
    vdtini          no-label
    "a"
    vdtfim   no-label
    
    with frame fopcoes11
        row 3 side-label width 80.



for each Estab no-lock:
    if not vEstab then do:
        find wfEstab where wfEstab.Etbcod = Estab.Etbcod no-error.
        if not avail wfEstab then  
        next.
    end. 
    do vdata = vdtini to vdtfim :
        for each tablog where tablog.tabela = "LOGMIX"      and
                              tablog.etbcod = estab.etbcod  and
                              tablog.data   = vdata no-lock
                              by tablog.data
                              by tablog.dec2.
                              
            if vindex  = 1
            then.
            else if vindex = 2 and tablog.acao = "EXCLUSAO"
                 then next.
                 else if vindex = 1 and tablog.acao = "INCLUSAO"
                      then next.
            
            find produ where produ.procod = int(tablog.char2) 
                                        no-lock no-error.    
            if not avail produ then next.

            
            find sclasse of produ no-lock. /* Subclasse */
            find classe where classe.clacod = sclasse.clasup no-lock.
            find grupo where grupo.clacod = classe.clasup no-lock.

            if not vprodu
            then do.
                   find wfprodu where wfprodu.procod = produ.procod 
                            no-lock no-error.
                   if not avail wfprodu then
                      next.
            end.
            
            /* filtro: classe */
            if not vclase
            then do.
                   find wfclase where wfclase.clacod-classe = classe.clacod 
                            no-lock no-error.
                   if not avail wfclase then
                      next.
            end.
            
            /* Filtro: sub-classe */
            if not vsclase
            then do.
                    find wfsclase where wfsclase.clacod = produ.clacod 
                             no-lock no-error.
                    if not avail wfsclase then
                        next.
            end.     
            find bfunc where bfunc.funcod = tablog.funcod and
                             bfunc.etbcod = int(tablog.dec1) no-lock no-error.
            display tablog.etbcod   column-label "Etb"
                    estab.etbnom    column-label "Estab" format "x(15)"
                    produ.procod    column-label "Codigo"
                    produ.pronom    column-label "Descricao" format "x(25)"
                    classe.clanom   column-label "Classe"
                    sclasse.clanom  column-label "Sub Classe"
                    tablog.data     column-label "Data"
                    string(int(tablog.dec2),"HH:MM") no-label format "x(5)"   
                    tablog.acao     column-label "Tipo"  format "xxxxxxxxxxxxx"
                    tablog.funcod   column-label "Func"
                    bfunc.funnom     column-label "Funcionario" 
                                        when avail bfunc
                                                format "x(15)"
                    tablog.char1    column-label "Codigo Mix"
                    with frame ffff width 240 down.
                                                                    
        end.
    end.
end.            

output close.

if opsys = "UNIX"
then do:
    run visurel.p(varquivo,"").
end.
else do:
    {mrod.i}
end.

