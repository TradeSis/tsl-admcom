{admcab.i}

def var vdiver as log.
def var vpercdiver as dec format ">>9.99 %".


def var varquivo as char.
def var vetbcod like estab.etbcod.
def var vcatcod like categoria.catcod.
def var vtot like plani.platot format "->,>>>,>>9.9".
def var vtot-qtd as int.
def var varq as char.
def var vdata   as   date format "99/99/9999".
def var vdti    as   date format "99/99/9999".
def var vdtf    as   date format "99/99/9999".


def var vprecoliberado as log.
def var vpromo         as log.


def temp-table tt-livre
    field procod like produ.procod
    field fincod like finan.fincod
    field preco  like estoq.estvenda.


def temp-table tt-divtot
    field etbcod like estab.etbcod
    field qtd-pro as integer
    field diver   like plani.platot
    field vendido like plani.platot
    field total-venda like plani.platot
    field certo   like plani.platot.

def temp-table tt-brinde
    field procod like produ.procod.
 
repeat:

    for each tt-livre:
        delete tt-livre.
    end.
    for each tt-divtot.
        delete tt-divtot.
    end.        
    for each tt-brinde:
        delete tt-brinde.
    end.
        
    do on error undo:
    
        update vetbcod label "Filial......." 
               with frame fdata.
               
        if vetbcod <> 0
        then do:
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab
            then do:
                message "Filial nao Cadastrada".
                undo.
            end.
            else disp estab.etbnom no-label with frame fdata.
        end.
        else disp "TODAS" @ estab.etbnom with frame fdata.
        
    end.           

    update skip
           vdti    label "Data Inicial."
           vdtf    label "Data Final" skip
           vcatcod label "Categoria...."
                with frame fdata side-label width 80 row 3.
    
    if vcatcod = 0
    then display "Geral" @ categoria.catnom no-label with frame fdata.
    else do:
        find categoria where categoria.catcod = vcatcod no-lock.
        display categoria.catnom no-label with frame fdata.
    end.
    
    update skip vpercdiver label "% Divergencia"
           with frame fdata.

    for each estab where estab.etbcod = (if vetbcod <> 0
                                         then vetbcod
                                         else estab.etbcod) no-lock:
        do vdata = vdti to vdtf:
            for each divpre where divpre.etbcod = estab.etbcod and
                                  divpre.divdat = vdata:
                          
                if divpre.fincod = 73 and
                 ( divpre.preven - divpre.premat ) >= 0
                then do transaction:
                    delete divpre.
                end.
            end.
        end.
    end.

    if opsys = "UNIX"
    then input from ../progr/autoriza.txt.
    else input from ..\progr\autoriza.txt.

    repeat:
    
        import varq.

        find first tt-livre where tt-livre.procod = int(substring(varq,1,6))
                              and tt-livre.fincod = int(substring(varq,7,2))
                                  no-error. 
        if not avail tt-livre 
        then do:
        
            create tt-livre.
            assign tt-livre.procod = int(substring(varq,1,6))
                   tt-livre.fincod = int(substring(varq,7,2))
                   tt-livre.preco  = dec(substring(varq,9,9)).
               
        end.

    
    end.
    input close.
    
    for each tt-livre.
        find produ where produ.procod = tt-livre.procod no-lock no-error.
        if not avail produ
        then delete tt-livre.
    end.
    
    
    if opsys = "UNIX"
    then input from ../progr/brinde.txt.
    else input from ..\progr\brinde.txt.

    repeat:
        create tt-brinde.
        import tt-brinde.
    end.
    input close.

    for each tt-brinde.

        find produ where produ.procod = tt-brinde.procod no-lock no-error.
        if not avail produ
        then do:
            delete tt-brinde.
            next.
        end.
    
    end.    
 
    
    vtot = 0. vtot-qtd = 0.
    for each estab where estab.etbcod = (if vetbcod <> 0
                                         then vetbcod
                                         else estab.etbcod) no-lock:

        disp estab.etbcod with frame f-disp
        1 down centered no-box.
        pause 0.
        do vdata = vdti to vdtf:
            disp vdata with frame f-disp.
            pause 0.
            for each divpre where divpre.etbcod = estab.etbcod and
                                  divpre.divdat = vdata no-lock:

                find first plani where plani.etbcod = divpre.etbcod 
                                   and plani.placod = divpre.placod 
                                   and plani.pladat >= vdti         
                                   and plani.pladat <= vdtf no-lock no-error.
                if avail plani 
                then do:
                    find first movim where movim.etbcod = plani.etbcod 
                                       and movim.placod = plani.placod 
                                       and movim.movtdc = plani.movtdc 
                                       and movim.procod = divpre.procod 
                                       no-lock no-error.
                    if avail movim 
                    then do:     /*
                        if movim.ocnum[5] <> 0 and movim.ocnum[6] <> 0
                        then next. */
                    end.
                end.
                
                find produ where produ.procod = divpre.procod no-lock no-error.
                if not avail produ
                then next.

                if produ.clacod = 100 or
                   produ.clacod = 101 or
                   produ.clacod = 102 or
                   produ.clacod = 107 or
                   produ.clacod = 190 or
                   produ.clacod = 191
                then next.          
                
                if vcatcod <> 0
                then if produ.catcod <> vcatcod
                     then next.
         
                vdiver = yes.
                run p-altpreco3per ( output vdiver ).
                
                if not vdiver
                then next.

                find first tt-brinde where 
                           tt-brinde.procod = divpre.procod no-error.
                if avail tt-brinde
                then do:
                    if divpre.preven <= 1
                    then next.
                end.
        
                find first tt-livre where tt-livre.procod = divpre.procod
                                      and tt-livre.fincod = divpre.fincod
                                      no-error.
                if avail tt-livre
                then do:
                    if divpre.preven = divpre.premat
                    then next.
            
                    if tt-livre.preco > 0
                    then do:
                        if tt-livre.preco >= divpre.preven
                        then next.
                    end.
                
                end.
        
                if avail plani
                then do:
                    vprecoliberado = no.
                    vpromo = no.
                    run leplapromo.p(input recid(plani),
                                     input divpre.procod,
                                     output vpromo,
                                     output vprecoliberado).
                    if vprecoliberado or vpromo
                    then next.
                end.
                
                /* Valida se o desconto nos produtos
                  com Asterisco foi aplicado corretamente */

                if substring(produ.pronom,1,3) = "***"
                then do:
                    if ((divpre.premat * 30 / 100)
                        >= (divpre.premat - divpre.preven))
                    then next.
                                             
                end.
                else if substring(produ.pronom,1,2) = "**"
                then do:
                     if ((divpre.premat * 20 / 100)
                         >= (divpre.premat - divpre.preven))
                     then next.
                end.
                else if substring(produ.pronom,1,1) = "*"
                then do:
                     if ((divpre.premat * 10 / 100)
                         >= (divpre.premat - divpre.preven))
                     then next.
                end.
                                    
                if divpre.preven >= 0.01
                    and divpre.preven <= 1.5
                then do:
                                                                    
                    if can-find (first tabaux
                               where tabaux.tabela = "PlanoBiz"
                                 and tabaux.valor_campo = string(divpre.fincod))
                    then next.
                    
                    if produ.pronom matches("*BRINDE*")
                        or produ.pronom matches("*MODEM*")
                        or produ.pronom matches("*CHIP*")
                    then next.
                                            
                end.
                                                            

                find first tt-divtot where
                           tt-divtot.etbcod = divpre.etbcod no-error.
                if not avail tt-divtot
                then do:
                    create tt-divtot.
                    assign tt-divtot.etbcod = divpre.etbcod.
                end.                                                
                            
                if (divpre.preven - divpre.premat) < 0
                then assign
                     tt-divtot.qtd-pro = tt-divtot.qtd-pro + 1
                     tt-divtot.vendido = tt-divtot.vendido + divpre.preven
                     tt-divtot.certo = tt-divtot.certo + divpre.premat
                     tt-divtot.diver = 
                     tt-divtot.diver + ((divpre.preven - divpre.premat) * -1)
                     vtot = vtot + ((divpre.preven - divpre.premat) * -1)
                     vtot-qtd = vtot-qtd + 1.
                     
    
            end.    
        end.
    end.

    for each tt-divtot:
        do vdata = vdti to vdtf:
            for each plani where plani.movtdc = 5
                             and plani.etbcod = tt-divtot.etbcod
                             and plani.pladat = vdata no-lock:

                tt-divtot.total-venda = tt-divtot.total-venda +
                        (if plani.biss > 0             
                         then plani.biss
                         else plani.platot).
            end.
        end.             
    end.                 

    if opsys = "UNIX"
    then varquivo = "../relat/rel-div." + string(time).
    else varquivo = "..\relat\rel-div." + string(time).
    
 
    {mdadmcab.i 
        &Saida     = "value(varquivo)"
        &Page-Size = "63"
        &Cond-Var  = "100"
        &Page-Line = "66"
        &Nom-Rel   = ""rel-div""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""  
        &Tit-Rel   = """DIVERGENCIA DE PRECOS - SINTETICO - DE "" 
                   + string(vdti,""99/99/9999"") + "" A ""
                   + string(vdtf,""99/99/9999"")"
        &Width     = "100"
        &Form      = "frame f-cabcab"}

 
        for each tt-divtot.

            disp tt-divtot.etbcod  column-label "Filial"
                 tt-divtot.qtd-pro column-label "Quantidade!Produtos"(total) 
                 /*
                 ((tt-divtot.qtd-pro * 100) / vtot-qtd)
                             column-label "Perc!Quantidade" format ">>9.99 %" 
                             (total)
                 tt-divtot.certo   column-label "Preco!Original" (total)
                 tt-divtot.vendido column-label "Preco!Vendido" (total)*/
                 tt-divtot.total-venda column-label "Total!Venda"
                 tt-divtot.diver   column-label "Divergencia"
                                   format "->,>>>,>>9.9" (total)
                 ((tt-divtot.diver * 100 ) / tt-divtot.total-venda)
                        column-label "Perc!Valor"
                                   format ">>9.99 %" (total)
                 with frame f-div centered down width 100.
            down with frame f-div.
                             
        end.
    
    if opsys = "UNIX"
    then do:
        output close.
        run visurel.p (input varquivo,
                       input "").
    end.                       
    else do:
        {mrod.i}.
    end.
end.

procedure p-altpreco3per:

    def output parameter p-diver as log.
    def var percentual-altp as dec.
    
    percentual-altp = 0.
    percentual-altp = 
            (((divpre.preven - divpre.premat) / divpre.premat ) * 100).

    if percentual-altp < 0
    then percentual-altp = percentual-altp * -1.

    if percentual-altp <= vpercdiver
    then p-diver = no.
    else p-diver = yes.

    if produ.pronom begins "*"
    then p-diver = no.

end procedure.