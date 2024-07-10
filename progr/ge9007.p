def input parameter par-arquivo as char.
def input parameter par-dtini   as date.
def input parameter par-dtfim   as date.
def var vdg as char.

{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.tipcon = 9007 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.

def buffer sclase   for clase.
def buffer grupo    for clase.
def buffer setclase for clase.
def buffer depto    for clase.
def buffer bprodu for produ.

def var vestcusto like estoq.estcusto.

def var contaoutros as int.


def var vtotal as dec.
def var d as date .
def var vi as date.
def var vf as date.

def var vdata as date format "99/99/9999".
def buffer brepexporta for repexporta.
do vdata = par-dtini to par-dtfim:
    for each brepexporta where brepexporta.tabela   = "PRODU"       and
                              brepexporta.EVENTO   = "inclusao"    and
                              brepexporta.datatrig = vdata
                              no-lock.
        find produ where recid(produ) = brepexporta.tabela-recid 
                                    no-lock no-error.
        if not avail produ
        then next.
        /*
        find first liped where liped.procod = produ.procod no-lock no-error.
        if not avail liped
        then next.
        */

        find sClase     where sClase.clacod   = produ.clacod   no-lock no-error.
        if not avail sClase 
        then do on error undo.  
            next.
        end.        
        find Clase      where Clase.clacod    = sClase.clasup no-lock no-error.
        if not avail clase 
        then do on error undo.
            next.
        end.
        find grupo      where grupo.clacod    = Clase.clasup no-lock no-error.
        if not avail grupo 
        then do on error undo.
            next.
        end.
        find setClase where setClase.clacod = grupo.clasup no-lock no-error.  
        if not avail setclase 
        then do on error undo.
                next.
        end.
        find depto where depto.clacod = setclase.clasup no-lock no-error.   
        if not avail depto 
        then do on error undo.
            next.                  
        end.        

        find first estoq where estoq.procod = produ.procod 
                no-lock no-error.

        contaoutros = 0.
        
        for each bprodu where bprodu.fabcod = produ.fabcod and bprodu.procod <> produ.procod no-lock.
            contaoutros = contaoutros + 1.
            end.


        vdg = "9007".
        output to value(par-arquivo) append.
        put unformatted
                vdata           ";"
                vdg             ";"
                produ.procod        "|" 
                produ.catcod        "|"
                produ.fabcod        "|"
                produ.pronom        "|"
               (if avail estoq
                then estoq.estcusto
                else 0)             "|"
               (if avail estoq
                then estoq.estvenda 
                else 0)             "|"
                contaoutros
                ""  skip. 
        output close.
        find first repexporta where
                    repexporta.TABELA       = "PRODU"           and
                    repexporta.Tabela-Recid = recid(produ)      and
                    repexporta.EVENTO       = "9007"            and
                    repexporta.BASE         = "GESTAO_EXCECAO"  
                    no-lock no-error.
        if not avail repexporta
        then do on error undo.
            create repexporta.
            ASSIGN repexporta.TABELA       = "PRODU"
                   repexporta.DATATRIG     = brepexporta.datatrig 
                   repexporta.HORATRIG     = time
                   repexporta.EVENTO       = "9007"
                   repexporta.DATAEXP      = today
                   repexporta.HORAEXP      = time
                   repexporta.BASE         = "GESTAO_EXCECAO"
                   repexporta.Tabela-Recid = recid(produ).
        end.
    end.
end.

/*****************
for each repexporta where repexporta.TABELA       = "PRODU"
                      and repexporta.EVENTO       = "9007"
                      and repexporta.DATAEXP      = ?.
    find produ where recid(produ) = repexporta.Tabela-Recid no-lock no-error.
    if not avail produ
    then next.
    find first liped where liped.procod = produ.procod no-lock no-error.
    if not avail liped
    then next.

    find sClase     where sClase.clacod   = produ.clacod    no-lock no-error.
    if not avail sClase 
    then do on error undo.  
        next.
    end.        
    find Clase      where Clase.clacod    = sClase.clasup   no-lock no-error.
    if not avail clase 
    then do on error undo.
        next.
    end.                    
    find grupo      where grupo.clacod    = Clase.clasup    no-lock no-error.
    if not avail grupo 
    then do on error undo.
        next.
    end.
    find setClase   where setClase.clacod = grupo.clasup    no-lock no-error.  
    if not avail setclase 
    then do on error undo.
        next.
    end.
    find depto   where depto.clacod = setclase.clasup    no-lock no-error.   
    if not avail depto 
    then do on error undo.
        next.                  
    end.        

    find first estoq where estoq.procod = produ.procod 
            no-lock no-error.
    put unformatted
            produ.procod        ";" 
            produ.catcod        ";"
            produ.fabcod        ";"
            produ.pronom        ";"
           (if avail estoq
            then estoq.estcusto
            else 0)             ";"
           (if avail estoq
            then estoq.estvenda 
            else 0)             ";"
            ""  skip. 
    repexporta.DATAEXP = today.
    repexporta.HORAEXP = time.
end.
output close.

***************/
