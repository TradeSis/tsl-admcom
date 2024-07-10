{admcab.i}
def var varquivo as char format "x(15)".
def stream stela.
def var vsit as char format "x(15)".
def var vdti like plani.pladat.
def var fila as char.
def var vdtf like plani.pladat.
def var vetbcod like estab.etbcod.
def var vesc as log format "Emitente/Destinatario".
def var vetb like estab.etbcod.

def new shared temp-table tt-plani
    field pladat like plani.pladat  
    field datexp like plani.datexp format "99/99/9999" 
    field emite  like plani.emite 
    field numero like plani.numero format ">>>>>>9"
    field serie  like plani.serie  
    field placod like plani.placod
    field platot like plani.platot.

 
    
if opsys = "unix"
   then do:
   find first impress where impress.codimp = setbcod no-lock no-error.
   if avail impress
      then assign fila = string(impress.dfimp). 
   end.                    
     else assign fila = "". 

repeat:

    for each tt-plani:
        delete tt-plani.
    end.
    
    vetb = 0.
    update vetbcod label "Filial" with frame f1 side-label.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1 width 80.
    update vdti label "Data Inicial" colon 13
           vdtf label "Data Final"  with frame f1.

    
        
    if opsys = "unix"
    then varquivo = "/admcom/relat/condev" + string(time).
    else varquivo = "l:\relat\condev" + string(time).

    {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""condev""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """DEVOLUCAO DE VENDA FILIAL - "" +
                          string(vetbcod) +  "" PERIODO DE  "" +
                          string(vdti,""99/99/9999"") +
                          string(vdtf,""99/99/9999"")"
            &Width     = "130"
            &Form      = "frame f-cabcab"}


    for each plani where plani.movtdc = 12 and
                         plani.etbcod = vetbcod and
                         plani.pladat >= vdti and
                         plani.pladat <= vdtf no-lock:
      
        disp plani.pladat 
             plani.datexp format "99/99/9999" 
             plani.emite
             plani.numero format ">>>>>>9"
             plani.serie 
                with frame f2 down centered.
        
        create tt-plani.
        assign tt-plani.pladat = plani.pladat  
               tt-plani.datexp = plani.datexp 
               tt-plani.emite  = plani.emite  
               tt-plani.numero = plani.numero  
               tt-plani.serie  = plani.serie   
               tt-plani.placod = plani.placod
               tt-plani.platot = plani.platot. 
                

    end.

    output close.

    run condev_1.p(input vetbcod).

    message "Confirma Listagem" update sresp.
    if sresp 
    then if opsys = "unix"   
         then os-command silent lpr value(fila + " " + varquivo).
         else os-command silent type value(varquivo) > prn.


end.

 