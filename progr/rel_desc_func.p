{admcab.i}

def var vdti as date.
def var vdtf as date.
def var vdt  as date.

def var varquivo as char.

def var vlimite-disponivel as char.
def var vtotal-venda       as decimal.

update vdti label "Periodo de........" format "99/99/9999"  with frame f-filtros side-labels.

display " a " with frame f-filtros.

update  vdtf no-label format "99/99/9999"  with frame f-filtros.

assign vtotal-venda = 0.
        
    if opsys = "UNIX"
    then varquivo = "../relat/rel_desc_func." + string(time).
    else varquivo = "..\relat\rel_desc_func." + string(time).

    {mdadmcab.i 
        &Saida     = "value(varquivo)"
        &Page-Size = "63"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""rel_desc_func""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""  
      &Tit-Rel   = """RELATÓRIO DE VENDAS COM DESCONTO PARA FUNCIONARIO - DE "" 
                   + string(vdti,""99/99/9999"") + "" A ""
                   + string(vdtf,""99/99/9999"")"
        &Width     = "131"
        &Form      = "frame f-cabcab"}


for each estab where estab.tipoLoja = "Normal" or
                     estab.tipoLoja = "Outlet" no-lock.
                     
    do vdt = vdti to vdtf:
                         
        for each plani where plani.etbcod = estab.etbcod
                         and plani.movtdc = 5
                         and plani.pladat = vdt no-lock.
                         
            if not acha("DESCONTO_FUNCIONARIO",plani.notobs[3]) = "SIM"
            then next.             
                          
            find first func where func.etbcod = plani.etbcod
                              and func.funcod = plani.vencod
                                        no-lock no-error.

            find first clien where clien.clicod = plani.desti 
                                    no-lock no-error.
                    
            
            if acha("LIMITE-DISPONIVEL",plani.notobs[1]) <> ?
            then assign
                 vlimite-disponivel = acha("LIMITE-DISPONIVEL",plani.notobs[1]).
               
            assign vtotal-venda = vtotal-venda + plani.platot.
                         
            display plani.pladat format "99/99/9999" label "Data"
                    plani.etbcod format ">>9" column-label "Fil"
                    plani.vencod format ">>>>9" label "Ven"
                    func.funnom when avail func format "x(25)" label "Vendedor"
                    plani.desti format ">>>>>>>>>>>9" label "Cod Cliente"
                    clien.ciccgc when avail clien label "CPF"
                    clien.clinom format "x(25)" label "Cliente"
                    plani.numero format ">>>>>>>>9" label "NF. Numero" 
                    plani.platot format "->>>,>>>,>>9.99" skip
                    with width 200.
                    
                         

        end.                         
                         
    end.                     
                     
end.

display "Total........:" vtotal-venda format "->>>,>>>,>>>,>>>,>>9.99" no-label.

output close.

if opsys = "UNIX"
then do:
    run visurel.p (input varquivo,
                   input "").
end.
else do:
    {mrod.i}.
end.
                                                           


