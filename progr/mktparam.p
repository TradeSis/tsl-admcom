{admcab.i }

def var vdtini as date format "99/99/9999" column-label "Inicio".
def var vdtfim as date format "99/99/9999" column-label "Fim".

def var vdata as date.

/* Temp-table de Selecao */

def workfile wffabri
    field fabcod        like fabri.fabcod init 0.
def buffer bwffabri for wffabri.

def var vfabri as log  format "Sim/Nao".
def var cfabri as char format "x(30)".

def workfile wfestab
    field etbcod        like estab.etbcod init 0.
def buffer bwfestab for wfestab.

def var vestab as log  format "Sim/Nao".
def var cestab as char format "x(30)".


def workfile wfvendedor
    field funcod        like func.funcod init 0.
def buffer bwfvendedor for wfvendedor.

def var vvendedor as log  format "Sim/Nao".
def var cvendedor as char format "x(30)".
/*
def workfile wftclifor
    field tclcod        like tclifor.tclcod init 0.
def buffer bwftclifor for wftclifor.
*/
def var vtclifor as log  format "Sim/Nao".
def var ctclifor as char format "x(30)".



def workfile wfclase
    field clacod        like clase.clacod init 0.
def buffer bwfclase for wfclase.

def var vclase as log  format "Sim/Nao".
def var cclase as char format "x(30)".

/** Testes de Frequencia de Compras */

def var vfreqini             as int format ">>>>9" initial 0.
def var vfreqfim             as int format ">>>>9" initial 99999.

/** Testes de Ticket Medio ou Media de compras */

def var vmedvenini             as dec format ">>>>>,>>9.99" initial 0.
def var vmedvenfim             as dec format ">>>>>,>>9.99" 
                                initial        99999999.99.


/** Testes de Maior da Venda */

def var vmaxvenini             as dec format ">>>>>,>>9.99" initial 0.
def var vmaxvenfim             as dec format ">>>>>,>>9.99" 
                                initial        99999999.99.


/** Clientes a Selecionar */

def var vqtdlistar           as int format ">>>>>>9" initial 9999999.

def var vranking as int.
def var vi as int.

def new shared temp-table tt-clifor
        field clfcod        like clien.clicod
        field ranking       as int
        field medven        as dec
        field maxven        as dec
        field freq          as int
        index freq     freq asc        
                       medven asc
                       maxven asc 
        index clifor   clfcod asc
        index maxven   maxven desc
        index rankink ranking asc.

def var vok as log.

repeat.
    
repeat with 1 down side-labels centered row 5 width 80
        title " Database Marketing ".

    vok = no.
    for each tt-clifor.
    delete tt-clifor.
    end.
    /** Teste de Estab **/
    
    for each wfestab.
        delete wfestab.
    end.
    vestab = yes.
    cestab = "".
    update vestab          colon 30    label "Todos Estabelecimentos.."
                    help "Relatorio com Todos os Estabelecimentos ?".
    if vestab = yes
    then do:
        create wfestab.
        wfestab.etbcod = 0.
        cestab = "Geral".
    end.
    else repeat with frame festab title "Selecao de Estabelecimentos"
                        centered retain 1 row 14 overlay.
        find first wfestab no-error.
        if not avail wfestab
        then do:
            create wfestab.
            wfestab.etbcod = 0.
        end.
        else do:
            create wfestab.
        end.
        update wfestab.etbcod
            help "Selecione o Estabelecimento ou tecle <F4> para Sair da Seleca~o".

        if wfestab.etbcod = 0
        then do.
            /*display "Geral" @ estab.estabnom.*/
                    /*cestab = "Geral".*/
            for each wfestab where wfestab.etbcod <> 0.
            /*delete wfestab.*/
            end.
            leave.
        end.
        find first bwfestab where 
                bwfestab.etbcod = wfestab.etbcod and
                recid(bwfestab) <> recid(wfestab)
            no-error.
        if avail bwfestab
        then undo.
        find estab where
                    estab.etbcod = wfestab.etbcod no-lock no-error.
        if not avail estab
        then do:
            message "Estabelecimento Invalido".
            delete wfestab.
            undo.
        end.
        disp estab.etbnom.
    end.
    hide frame festab no-pause.

    /*cestab = "".*/
    vi = 0.
    for each wfestab by wfestab.etbcod.
        vi = vi + 1.
        find estab where
                estab.etbcod = wfestab.etbcod no-lock no-error.
        if not avail estab
        then next.
        cestab = trim(cestab + "  " + string(estab.etbcod)).
    end.
    if vi > 1
    then do:
        find first wfestab where wfestab.etbcod = 0 no-error.
        if avail wfestab
        then delete wfestab.
    end.    
    display cestab no-label.
     
    /** Fim teste Estabelecimentos **/
 
    /** Teste de tclifor **/
    
    /*
    for each wftclifor.
        delete wftclifor.
    end.
    vtclifor = yes.
    ctclifor = "".
   
    update vtclifor          colon 30    label "Todos Tipos Clientes.."
                    help "Relatorio com Todos os Tipos Clientes ?".
    if vtclifor = yes
    then do:
        create wftclifor.
        wftclifor.tclcod = 0.
        ctclifor = "Geral".
    end.
    else repeat with frame ftclifor title "Selecao de Tipos de Clientes"
                        centered retain 1 row 14 overlay.
        find first wftclifor no-error.
        if not avail wftclifor
        then do:
            create wftclifor.
            wftclifor.tclcod = 0.
        end.
        else do:
            create wftclifor.
        end.
        update wftclifor.tclcod
            help "Selecione o Tipo cliente ou tecle <F4> para Sair da Seleca~~o".

        if wftclifor.tclcod = 0
        then do.
            /*display "Geral" @ tclifor.tclifornom.*/
                    /*ctclifor = "Geral".*/
            for each wftclifor where wftclifor.tclcod <> 0.
            /*delete wftclifor.*/
            end.
            leave.
        end.
        find first bwftclifor where 
                bwftclifor.tclcod = wftclifor.tclcod and
                recid(bwftclifor) <> recid(wftclifor)
            no-error.
        if avail bwftclifor
        then undo.
        find tclifor where
                    tclifor.tclcod = wftclifor.tclcod no-lock no-error.
        if not avail tclifor
        then do:
            message "Tipo de Clientes Invalido".
            delete wftclifor.
            undo.
        end.
        disp tclifor.tclnom.
    end.
    hide frame ftclifor no-pause.
    
    /*ctclifor = "".*/
    vi = 0.
    for each wftclifor by wftclifor.tclcod.
        vi = vi + 1.
        find tclifor where
                tclifor.tclcod = wftclifor.tclcod no-lock no-error.
        if not avail tclifor
        then next.
        ctclifor = trim(ctclifor + "  " + string(tclifor.tclcod)).
    end.
    if vi > 1
    then do:
        find first wftclifor where wftclifor.tclcod = 0 no-error.
        if avail wftclifor
        then delete wftclifor.
    end.    
     display ctclifor no-label.
    */ 
    /** Fim teste Tclifor **/
 
    /** Teste de Fabricante **/
    
    for each wffabri.
        delete wffabri.
    end.
    vfabri = yes.
    cfabri = "".
    update vfabri          colon 30    label "Todos Fabricantes.."
                    help "Relatorio com Todos os Fabricantes ?".
    if vfabri = yes
    then do:
        create wffabri.
        wffabri.fabcod = 0.
        cfabri = "Geral".
    end.
    else repeat with frame ffabri title "Selecao de Fabricantes"
                        centered retain 1 row 14 overlay.
        find first wffabri no-error.
        if not avail wffabri
        then do:
            create wffabri.
            wffabri.fabcod = 0.
        end.
        else do:
            create wffabri.
        end.
        update wffabri.fabcod
            help "Selecione o Fabricante ou tecle <F4> para Sair da Selecao".

        if wffabri.fabcod = 0
        then do.
            /*display "Geral" @ fabri.fabrinom.*/
                    /*cfabri = "Geral".*/
            for each wffabri where wffabri.fabcod <> 0.
            /*delete wffabri.*/
            end.
            leave.
        end.
        find first bwffabri where 
                bwffabri.fabcod = wffabri.fabcod and
                recid(bwffabri) <> recid(wffabri)
            no-error.
        if avail bwffabri
        then undo.
        find fabri where
                    fabri.fabcod = wffabri.fabcod no-lock no-error.
        if not avail fabri
        then do:
            message "Fabricante Invalido".
            delete wffabri.
            undo.
        end.
        disp fabri.fabnom.
    end.
    hide frame ffabri no-pause.

    /*cfabri = "".*/
    vi  = 0.
    for each wffabri by wffabri.fabcod.
        vi = vi + 1.
        find fabri where
                fabri.fabcod = wffabri.fabcod no-lock no-error.
        if not avail fabri
        then next.
        cfabri = trim(cfabri + "  " + string(fabri.fabcod)).
    end.
    if vi > 1
    then do:
        find first wffabri where wffabri.fabcod = 0 no-error.
        if avail wffabri
        then delete wffabri.
    end.    
    display cfabri no-label.

    /** Fim teste Fabricante **/

    /** Teste de Clase **/
    
    for each wfclase.
        delete wfclase.
    end.
    vclase = yes.
    cclase = "".
    update vclase          colon 30    label "Todas Classes.."
                    help "Relatorio com Todas as Classes ?".
    if vclase = yes
    then do:
        create wfclase.
        wfclase.clacod = 0.
        cclase = "Geral".
    end.
    else repeat with frame fclase title "Selecao de Classes"
                        centered retain 1 row 14 overlay.
        find first wfclase no-error.
        if not avail wfclase
        then do:
            create wfclase.
            wfclase.clacod = 0.
        end.
        else do:
            create wfclase.
        end.
        update wfclase.clacod
            help "Selecione as Classes ou tecle <F4> para Sair da Selecao".

        if wfclase.clacod = 0
        then do.
            /*display "Geral" @ clase.clasenom.*/
                    /*cclase = "Geral".*/
            for each wfclase where wfclase.clacod <> 0.
            /*delete wfclase.*/
            end.
            leave.
        end.
        find first bwfclase where 
                bwfclase.clacod = wfclase.clacod and
                recid(bwfclase) <> recid(wfclase)
            no-error.
        if avail bwfclase
        then undo.
        find clase where
                    clase.clacod = wfclase.clacod no-lock no-error.
        if not avail clase
        then do:
            message "Classe Invalida".
            delete wfclase.
            undo.
        end.
        disp clase.clanom.
    end.
    hide frame fclase no-pause.

    /*cclase = "".*/
    vi = 0.
    for each wfclase by wfclase.clacod.
        vi = vi + 1.
        find clase where
                clase.clacod = wfclase.clacod no-lock no-error.
        if not avail clase
        then next.
        cclase = trim(cclase + "  " + string(clase.clacod)).
    end.
    if vi > 1
    then do:
        find first wfclase where wfclase.clacod = 0 no-error.
        if avail wfclase
        then delete wfclase.
    end.    
    display cclase no-label.

    /** Fim teste Clase **/
  

    /** Teste de vendedor **/
    
    for each wfvendedor.
        delete wfvendedor.
    end.
    vvendedor = yes.
    cvendedor = "".
    update vvendedor          colon 30    label "Todos vendedores.."
                    help "Relatorio com Todos os vendedores ?".
    if vvendedor = yes
    then do:
        create wfvendedor.
        wfvendedor.funcod = 0.
        cvendedor = "Geral".
    end.
    else repeat with frame fvendedor title "Selecao de vendedores"
                        centered retain 1 row 14 overlay.
        find first wfvendedor no-error.
        if not avail wfvendedor
        then do:
            create wfvendedor.
            wfvendedor.funcod = 0.
        end.
        else do:
            create wfvendedor.
        end.
        update wfvendedor.funcod
            help "Selecione o Vendedor ou tecle <F4> para Sair da Selecao".

        if wfvendedor.funcod = 0
        then do.
            /*display "Geral" @ vendedor.vendedornom.*/
                    /*cvendedor = "Geral".*/
            for each wfvendedor where wfvendedor.funcod <> 0.
            /*delete wfvendedor.*/
            end.
            leave.
        end.
        find first bwfvendedor where 
                bwfvendedor.funcod = wfvendedor.funcod and
                recid(bwfvendedor) <> recid(wfvendedor)
            no-error.
        if avail bwfvendedor
        then undo.
        find func where
                    func.funcod = wfvendedor.funcod no-lock no-error.
        if not avail func
        then do:
            message "Vendedor Invalido".
            delete wfvendedor.
            undo.
        end.
        disp func.funape.
    end.
    hide frame fvendedor no-pause.

    /*cvendedor = "".*/
    vi = 0.
    for each wfvendedor by wfvendedor.funcod.
        vi = vi + 1.
        find func where
                func.funcod = wfvendedor.funcod no-lock no-error.
        if not avail func
        then next.
        cvendedor = trim(cvendedor + "  " + string(func.funcod)).
    end.
    if vi > 1
    then do:
        find first wfvendedor where wfvendedor.funcod = 0 no-error.
        if avail wfvendedor
        then delete wfvendedor.
    end.    
    display cvendedor no-label.
     
    /** Fim teste vendedorelecimentos **/
     
    

    /* Testes de Frequencia de Vendas */
    
    update skip(2) 
            vfreqini    colon 30 label "Frequencia ->........."
            vfreqfim no-label
            help
       "Preencha com 9 (noves) para ir no limite".
  
     /* Testes de Media de Vendas */
     
    update 
            vmedvenini    colon 30 label "Ticket Medio ->........."
            vmedvenfim no-label
            help
       "Preencha com 9 (noves) para ir no limite".
  
     /* Testes de Maximo de Vendas */
     
    update 
            vmaxvenini    colon 30 label "Somatorio Venda ->......"
            vmaxvenfim no-label
            help
       "Preencha com 9 (noves) para ir no limite".
 
     /* Quantidade de Clientes a Selecionar */
     
    update 
            vqtdlistar    colon 30 label "Qtd Listar ->........."
            help
       "Preencha com 9 (noves) para ir no limite".
       
    
    update  skip(2)
            vdtini label "Periodo de Compra........"     colon 30
            validate(vdtini <> ?,"Obrigatorio Periodo Inicial")
            vdtfim label "A"
            validate(vdtfim <> ? and vdtfim >= input vdtini,
                     "Obrigatorio Periodo Final").

    run mktgera.
    
    run mktsel.p.
    
    vok = yes.
    leave.
    
end.
    

if not vok
then return.

end.
                 

PROCEDURE mktgera.
pause 0 before-hide.
form 
plani.pladat with frame tela side-labels
centered row 5.

for each wfestab,  
    each estab where (if wfestab.etbcod = 0
                      then true
                      else estab.etbcod = wfestab.etbcod)
    no-lock:
    
    do vdata = vdtini to vdtfim:

        for each plani where 
                plani.movtdc = 2 and
                plani.etbcod = estab.etbcod and
                plani.pladat = vdata
            no-lock
            use-index pladat:
            
            disp plani.pladat
                with frame tela.
                
            run executa-testes.
            
                               
        end.
        for each plani where 
                plani.movtdc = 5 and
                plani.etbcod = estab.etbcod and
                plani.pladat = vdata
            no-lock
            use-index pladat:
           
            disp plani.pladat
                with frame tela.
                
            run executa-testes.
                                            
        end.
 
    end.
end. 
           
vranking = 0.

for each tt-clifor 
        by tt-clifor.maxven descending:
    
    if not (tt-clifor.freq >= vfreqini and
            tt-clifor.freq <= vfreqfim)
    then do:
        delete tt-clifor.
        next.
    end.     

    if not (tt-clifor.maxven >= vmaxvenini and
            tt-clifor.maxven <= vmaxvenfim)
    then do:
        delete tt-clifor.
        next.
    end.     
    
    assign
        tt-clifor.medven = tt-clifor.maxven / tt-clifor.freq.

    if not (tt-clifor.medven >= vmedvenini and
            tt-clifor.medven <= vmedvenfim)
    then do:
        delete tt-clifor.
        next.
    end.     
       
         
    vranking = vranking + 1.

    assign
        tt-clifor.ranking = vranking.
        
    if vranking > vqtdlistar
    then delete tt-clifor.
        
end.

hide frame tela no-pause.

end procedure.


PROCEDURE executa-testes.
            
def var vsem-movim as log.

            find clien where
                    clien.clicod = plani.desti
                no-lock no-error.
            if not avail clien then leave.
            /*    
            find first wftclifor no-error.
            if wftclifor.tclcod <> 0
            then do:
                find first wftclifor where
                    wftclifor.tclcod = clifor.tclcod
                    no-error.
                if not avail wftclifor
                then return.
            end. 
            */
            find first wfvendedor no-error.
            if wfvendedor.funcod <> 0
            then do:
                find first wfvendedor where
                    wfvendedor.funcod = plani.vencod
                    no-error.
                if not avail wfvendedor
                then return.
            end.
            
            vsem-movim = no.
            
            find first wffabri no-error.
            find first wfclase no-error.
            if wffabri.fabcod <> 0 or
               wfclase.clacod <> 0
            then do: /* Ler movim para testar fabri */
                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod no-lock.
                    find produ of movim no-lock.

                    find first wffabri no-error.
                    if wffabri.fabcod <> 0
                    then do:
                        find first wffabri where
                                wffabri.fabcod = produ.fabcod
                            no-error.
                        if not avail wffabri
                        then do:
                            vsem-movim = yes.
                        end.
                    end.
                    find first wfclase no-error.
                    if wfclase.clacod <> 0
                    then do:
                        find first wfclase where
                                wfclase.clacod = produ.clacod
                            no-error.
                        if not avail wfclase
                        then do:
                            vsem-movim = yes.
                        end.
                    end.
                end.
            end.
            
            if vsem-movim
            then return.
            
            find first tt-clifor where 
                    tt-clifor.clfcod = plani.desti no-error.
            if not avail tt-clifor
            then do:
                create tt-clifor.
                assign tt-clifor.clfcod = plani.desti.
            end.
                                
            assign tt-clifor.freq  = tt-clifor.freq + 1
                   tt-clifor.maxven = tt-clifor.maxven + plani.platot.

end procedure.
