{admcab.i}

def var vforcod like forne.forcod.
def var vdata-base as date format "99/99/9999" initial today.

def var vforcod2 like forne.forcod.
def buffer forne2 for forne.

def var fila as char.
def var varquivo    as char format "X(20)". 
def var vetbcod  like estab.etbcod.
def var vdti     as   date format "99/99/9999".
def var vdtf     as   date format "99/99/9999".
def var vdata    as   date format "99/99/9999".
def var vdias    as   inte.
def var vaspas   as   char format "x".
def buffer bestab for estab.

def temp-table tas
    field etbcod  like estab.etbcod
    field etbnom  like estab.etbnom
    field oscod   like asstec.oscod
    field forcod  like forne.forcod
    field fornom  like forne.fornom
    field procod  like produ.procod
    field pronom  like produ.pronom format "x(40)"
    field datexp   as   date format "99/99/9999"
    field dtenvfil as   date  format "99/99/9999"
    field dtentdep as   date  format "99/99/9999"
    field dtenvass as   date  format "99/99/9999".
    
def temp-table tt-for
    field forcod like forne.forcod
    field fornom like forne.fornom
    field qtd    as   integer.
    
def var vdatexp as date format "99/99/9999".

vaspas = chr(34).

def var vtotal-etb   as int.
def var vtotal-for   as int.
def var vtotal-geral as int.

if opsys = "UNIX" 
then do: 
    if search("/admcom/dg/dg010.ini") <> ? 
    then do:
        input from /admcom/dg/dg010.ini. 
           import  vdias. 
        input close. 
    end. 
end.
else do:
    if search("l:\dg\dg010.ini") <> ?
    then do:
        input from l:\dg\dg010.ini. 
            import vdias. 
        input close. 
    end. 
end.

if vdias = 0
then vdias = 15.

form 
    vetbcod label "Estabelecimento"
    estab.etbnom no-label
    skip
    vdata-base label "Data Base......"
    skip
/*    vdti    label "Data Inicial..."
    vdtf    label " Data Final"
    skip*/
    vdias   label "OS completando."
    " dias"                       skip
    vforcod label "Fornecedor....."
    forne.fornom no-label
    with frame f-os side-labels width 80.
    

REPEAT:
    for each tt-for. delete tt-for. end.    
    for each tas.
        delete tas.
    end.
    
    do on error undo:
        update vetbcod
               help "Informe o codigo do estabelecimento ou zero para todos"
               with frame f-os.
        if vetbcod = 0
        then disp "TODOS" @ estab.etbnom with frame f-os.
        else do:
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab
            then do:
                message "Estabelecimento nao cadastrado".
                undo.
            end.
            else disp estab.etbnom no-label with frame f-os.
        end.    
    end.       
    vdata-base = today - 30.   
    update /*vdti 
           vdtf*/
           vdata-base
           vdias
           with frame f-os.

    do on error undo:
        update vforcod
               help "Informe o codigo do fornecedor ou zero para todos" 
               with frame f-os.
        if vforcod = 0
        then disp "TODOS" @ forne.fornom with frame f-os.
        else do:
            find forne where forne.forcod = vforcod no-lock no-error.
            if not avail forne
            then do:
                message "Fornecedor nao Cadastrado".
                undo.
            end.
            else disp forne.fornom no-label with frame f-os.
        end.        
    end.

    do on error undo:
        update vforcod2 label "Fabricante do Produto"
             help "Informe o codigo do fabricante do produto ou 0 para todos." 
               with frame f-os2 centered side-labels.
        if vforcod2 = 0
        then disp "TODOS" @ forne2.fornom with frame f-os2.
        else do:
            find forne2 where forne2.forcod = vforcod2 no-lock no-error.
            if not avail forne2
            then do:
                message "Fabricante nao Cadastrado".
                undo.
            end.
            else disp forne2.fornom no-label with frame f-os2.
        end.        
    end.

    for each estab where estab.etbcod = (if vetbcod <> 0
                                         then vetbcod
                                         else estab.etbcod) no-lock,
        each asstec where asstec.etbcod = estab.etbcod
                      /*and asstec.dtentdep >= vdti
                      and asstec.dtentdep <= vdtf*/ no-lock:

        if vforcod <> 0
        then if asstec.forcod <> vforcod
             then next.
        
        if asstec.dtenvfil <> ?
        then next.
        
        vdatexp = asstec.datexp.

        if vdatexp = ?
        then vdatexp = asstec.dtentdep.
        
        /*
        if (today - vdatexp) < vdias
        then next.
        */

        if vdatexp < vdata-base 
        then next.        
        
        if vdatexp > (vdata-base + vdias)
        then next.        

        find produ where produ.procod = asstec.procod no-lock no-error.
        if vforcod2 <> 0
        then if produ.fabcod <> vforcod2
             then next.
        
        
        find forne where forne.forcod = asstec.forcod no-lock no-error.

        find tt-for where tt-for.forcod = asstec.forcod no-error.
        if not avail tt-for
        then do:
            create tt-for.
            assign tt-for.forcod = asstec.forcod
                   tt-for.fornom = (if avail forne 
                                   then forne.fornom
                                   else "NAO CADASTRADO").
        end.
        tt-for.qtd = tt-for.qtd + 1.
        
        find tas where tas.etbcod = estab.etbcod
                   and tas.forcod = asstec.forcod
                   and tas.oscod  = asstec.oscod no-error.
        if not avail tas
        then do:
            find produ where produ.procod = asstec.procod no-lock no-error.
            create tas.
            assign tas.etbcod   = asstec.etbcod
                   tas.etbnom   = estab.etbnom
                   tas.forcod   = asstec.forcod
                   tas.oscod    = asstec.oscod
                   tas.dtentdep = asstec.dtentdep
                   tas.dtenvfil = asstec.dtenvfil
                   tas.dtenvass = asstec.dtenvass
                   tas.datexp   = asstec.datexp
                   tas.fornom   = (if avail forne 
                                   then forne.fornom
                                   else "NAO CADASTRADO")
                   tas.procod  = produ.procod
                   tas.pronom  = produ.pronom.

        end.
    end.
    
    /***
    if opsys = "UNIX"
    then do:                                    
        find first impress where impress.codimp = setbcod no-lock no-error.
        if avail impress
        then assign fila = string(impress.dfimp)  
                    varquivo = "/admcom/relat/rdg010" + string(time).    
    
    end.
    else assign fila = ""
                varquivo = "l:\relat\rdg010" + string(time).

    ***/
    
varquivo = "/admcom/relat/rdg010" + string(time).    

    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "63" 
        &Cond-Var  = "120"  
        &Page-Line = "66"
        &Nom-Rel   = ""rdg010""  
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""  
        &Tit-Rel   = """ASSISTENCIA TECNICA"" +  
                        "" - OS COMPLETANDO "" +   
                        string(vdias) + "" DIAS"""
        &Width     = "120"
        &Form      = "frame f-cabcab"}

        for each tas break by tas.etbcod
                           by tas.forcod
                           by tas.oscod:

            if first-of(tas.etbcod)
            then do:

                vtotal-etb = 0.
                disp tas.etbcod " - "
                      tas.etbnom no-label skip
                      with frame f-etb side-labels.
                      
                if vforcod2 <> 0
                then
                    disp forne2.forcod label "Fabricante....."
                         forne2.fornom no-label
                         with frame f-fab side-labels width 120.
                else
                    disp vforcod2 @ forne2.forcod
                         "TODOS" @ forne2.fornom with frame f-fab.

            end.
            
            if first-of(tas.forcod)
            then do:

                vtotal-for = 0.
                disp skip(1) space(3)
                      tas.forcod " - "
                      tas.fornom no-label skip
                      with frame f-for side-labels.
            
            end.

            find produ where produ.procod = tas.procod no-lock no-error.
            if avail produ
            then
                find fabri where fabri.fabcod = produ.fabcod no-lock no-error.
                                  
            disp space(6)
                 tas.oscod    column-label "Num. OS"
                 tas.procod   column-label "Produto"
                 tas.pronom   column-label "Descricao" format "x(28)"
                 /*
                 fabri.fabcod column-label "Codigo!Fabri" when avail fabri
                 fabri.fabnom column-label "Fabricante" when avail fabri
                                           format "x(15)"
                 */                          
                 tas.dtentdep column-label "Dt.Entr.!Deposito"
                 tas.dtenvass column-label "Dt.Envio!Assistencia"
                 tas.dtenvfil column-label "Dt.Envio!Filial"
                 tas.datexp   column-label "Dt.Inclu"
                 with frame f-tas width 120 down.
            
            assign vtotal-for   = vtotal-for + 1
                   vtotal-etb   = vtotal-etb + 1
                   vtotal-geral = vtotal-geral + 1.
            
            if last-of(tas.forcod)
            then put skip(1) space(6) "Total por Fornecedor --> " vtotal-for
                     skip.
            
            if last-of(tas.etbcod)
            then put skip space(6) "Total por Filial ------> " vtotal-etb
                     skip.
                     
        end.

        
        put skip space(6) "Total Geral      ------> " vtotal-geral
            skip.
        
        page.
        
        disp  skip(1)
              "RESUMO POR FORNECEDOR"
              skip(2)
              with frame f-fd centered no-box.
              
        disp    "TOTAL GERAL DE OS:" vtotal-geral no-label
                skip(1)
                with frame f-fff centered side-labels no-box.
                
        for each tt-for:
        
            disp tt-for.forcod tt-for.fornom tt-for.qtd (total)
                 with frame f-f1 centered down.
            down with frame f-f1.
            
        end.
                
        vtotal-geral = 0.
        

    
    output close.
    
    if opsys = "UNIX"
    then do:
                                       
        message "Deseja imprimir relatorio" update sresp.
        /*
        if sresp
        then os-command silent lpr value(fila + " " + varquivo).
        */

        run visurel.p (input varquivo,
                       input ""). 
    end.
    else do:
        {mrod.i}.
    end.
    
END.
