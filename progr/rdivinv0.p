{admcab.i new}

def var vcatcod like categoria.catcod.
def temp-table tt-dep
    field catcod like categoria.catcod
    index i-dep is primary unique catcod.
def var vdep as char.    

def var vetbcod like estab.etbcod.
def var vbaldat like balan.baldat.
def var varquivo as char.

def var vtotbalqtd like balan.balqtd.
def var vtotestatual like balan.estatual.

def var vlista as log format "Sim/Nao".
def var lestoq as logi init no.
  
form vetbcod
     estab.etbnom skip
     vbaldat skip
     vcatcod 
     vdep 
     with frame f-dados.

repeat:

    assign vetbcod = 0 vbaldat = ?.
    
    do on error undo:
        update vetbcod label "Filial...."
               with frame f-dados width 80 side-labels.
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            message "Filial nao cadastrada.".
            undo, retry.
        end.
        else disp estab.etbnom no-label with frame f-dados.
    end.
           
    update skip
           vbaldat label "Dt.Balanco"
           with frame f-dados.

repeat: 
    do on error undo:
        vcatcod = 0.
        update skip
               vcatcod label "Departamento"
               help "Informe os Departamentos e F4 para Confirmar"
               with frame f-dados centered side-labels overlay row 3.

        find categoria where categoria.catcod = vcatcod no-lock no-error.
        if not avail categoria
        then do:
            message "Departamento nao cadastrado.".
            undo, retry.
        end.
        
    end.
    
    find tt-dep where tt-dep.catcod = vcatcod no-error.
    if not avail tt-dep
    then do:
        create tt-dep.
        assign tt-dep.catcod = vcatcod.
    end.
    vdep = "".
    for each tt-dep:
        vdep = vdep + string(tt-dep.catcod,"99") + "/".
    end.
    disp vdep no-label format "x(50)" with frame f-dados.
end.

    update vlista  label "Listar somente produtos com divergencia"
           with frame f-dados2 centered side-labels.
    
    message "Somente produtos com estoque...?"
            view-as alert-box buttons yes-no 
                    title "CONFIRMA" update lestoq.
                  
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/rdivinv0_" 
                    + string(vetbcod,"999") 
                    + "."
                    + string(time).
    else varquivo = "l:\relat\rdivinv0_"
                    + string(vetbcod,"999")
                    + "."
                    + string(time).
           
    message "Aguarde ...".
    
    {mdadmcab.i 
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "100"
        &Page-Line = "0"
        &Nom-Rel   = ""rdivinv0""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""  
        &Tit-Rel   = """RELATORIO DE DIVERGENCIA DE INVENTARIO - ""
                   + string(vbaldat,""99/99/9999"")
                   + "" - FILIAL "" 
                   + string(vetbcod,"">99"")"
        &Width     = "100"
        &Form      = "frame f-cabcab"}
    

    assign vtotbalqtd   = 0
           vtotestatual = 0.

    for each balan where balan.etbcod = vetbcod
                     and balan.baldat = vbaldat no-lock:
        find produ where produ.procod = balan.procod no-lock no-error.
        if not avail produ
        then next.
    
        if lestoq = yes
        then do:
                find first estoq where
                           estoq.procod = produ.procod no-lock no-error.
                if not avail estoq
                then next. 
        end.           

        find first tt-dep where tt-dep.catcod = produ.catcod no-error.
        if not avail tt-dep
        then next.
        
        assign vtotbalqtd   = vtotbalqtd + balan.balqtd
               vtotestatual = vtotestatual + balan.estatual.
    end.                     

    disp vtotbalqtd   label "TOTAL CONTADO:" SKIP
         vtotestatual label "TOTAL ESTOQUE:" skip(2)
         with frame fccc centered side-labels.

    for each balan where balan.etbcod = vetbcod
                     and balan.baldat = vbaldat no-lock,
        first produ where produ.procod = balan.procod no-lock
                            break by produ.pronom:

    
        find first tt-dep where tt-dep.catcod = produ.catcod no-error.
        if not avail tt-dep
        then next.

        if vlista
        then if balan.balqtd = balan.estatual then next.
        else do:
            if balan.estatual > 0 or
               balan.balqtd <> 0
            then.
            else next.
        end.
                
        disp balan.procod                   column-label "Codigo"
             produ.pronom                   column-label "Produto"
             balan.balqtd                   column-label "Qtd!Contada"
             (total)
             balan.estatual                 column-label "Qtd!Estoque"
             (total)
            (balan.balqtd - balan.estatual) column-label "Dif."
            (total)
             with frame f-bal width 100 down.
        down with frame f-bal.             
            
    end.

    output close.
    
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