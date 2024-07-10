{admcab.i}

def var vforcgc like forne.forcgc.
def var vforcod like forne.forcod.

def temp-table tt-fab
    field fabcod like fabri.fabcod
    field fabnom like fabri.fabnom
    index ifabcod is primary unique fabcod.

repeat:
    do on error undo:
        update /*vforcgc label "CNPJ Fornecedor"*/
            vforcod label "Fornecedor"
            with frame f-forne width 80 side-labels.
    
/*        find forne where forne.forcgc = vforcgc no-lock no-error.*/
        find forne where forne.forcod = vforcod no-lock no-error.
        if avail forne
        then do:
            disp forne.fornom no-label
                 with frame f-forne.
        end.
        else do:
            message "Fornecedor nao Cadastrado".
            undo.    
        end.
    end.
    
    for each tt-fab.
        delete tt-fab.
    end.
    
    message "Confirma emissao do Relatorio? " update sresp.
    if not sresp then undo.
    
    def var varquivo as char format "x(20)".
    if opsys = "UNIX"
    then
        varquivo = "/admcom/relat/forfab9" + string(day(today)).
    else 
        varquivo = "l:\relat\forfab9" + string(day(today)).

    for each plani where plani.emite = forne.forcod
                     and plani.movtdc = 4
                     and plani.serie = "U" no-lock:

        for each movim where movim.etbcod = plani.etbcod
                         and movim.movtdc = plani.movtdc
                         and movim.placod = plani.placod
                         and movim.movdat = plani.pladat no-lock.

            find produ where produ.procod = movim.procod no-lock no-error.
            if avail produ
            then do:
                find fabri where fabri.fabcod = produ.fabcod no-lock no-error.
                
                find tt-fab where tt-fab.fabcod = produ.fabcod no-error.
                if not avail tt-fab
                then do:
                    create tt-fab.
                    assign tt-fab.fabcod = produ.fabcod
                           tt-fab.fabnom = if avail fabri
                                           then fabri.fabnom
                                           else "".
                end.
            end.
                         
        end.                         
        
    end.

    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "90"
        &Page-Line = "0"
        &Nom-Rel   = ""forfab""
        &Nom-Sis   = """SISTEMA GERENCIAL"""
        &Tit-Rel   = """RELATORIO FORNECEDOR/FABRICANTE"""
        &Width     = "90"
        &Form      = "frame f-cabcab"}

    disp forne.forcod label "Fornecedor" forne.fornom no-label
        with frame f-dfor side-labels.
    
   for each tt-fab break by tt-fab.fabcod:
   
        disp space(5) tt-fab.fabcod label "Fabricante"
            tt-fab.fabnom no-label
            with frame f-dfab side-labels.
   
   end.

   if opsys = "UNIX"
   then do:
      output close.
      run visurel.p (input varquivo, input "Relatorio Fornecedor/Fabricante").
   end.
   else do:
    {mrod.i}
   end.        



end.