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
    field desti  like plani.desti
    field numero like plani.numero format ">>>>>>9"
    field notant like plani.numero format ">>>>>>9"
    field serie  like plani.serie  
    field placod like plani.placod
    field confi  as char format "x(15)".

 
    
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
           vdtf label "Data Final" 
           vesc label "Consulta" 
           vetb label "Estabelecimento" with frame f1.

    
        
    if vesc
    then do:
        for each plani where plani.movtdc = 9 and
                             plani.etbcod = vetbcod and
                             plani.serie  = "u"   and 
                             plani.pladat >= vdti and
                             plani.pladat <= vdtf no-lock:
      
            if vetb <> 0
            then if vetb <> plani.desti
                 then next.
            
        
            create tt-plani.
            assign tt-plani.pladat = plani.pladat  
                   tt-plani.datexp = plani.datexp
                   tt-plani.emite  = plani.emite 
                   tt-plani.desti  = plani.desti
                   tt-plani.numero = plani.numero 
                   tt-plani.notant = plani.nottran
                   tt-plani.serie  = plani.serie  
                   tt-plani.placod = plani.placod
                   tt-plani.confi  = vsit.
                

        end.
    end.
    else do:
    
         for each plani where plani.movtdc = 9 and
                              plani.desti  = vetbcod and
                              plani.serie  = "U" and
                              plani.pladat >= vdti and
                              plani.pladat <= vdtf no-lock:
      
            if vetb <> 0
            then if vetb <> plani.emite
                 then next.
            
            create tt-plani.
            assign tt-plani.pladat = plani.pladat  
                   tt-plani.datexp = plani.datexp
                   tt-plani.emite  = plani.emite 
                   tt-plani.desti  = plani.desti
                   tt-plani.numero = plani.numero 
                   tt-plani.notant = plani.nottran
                   tt-plani.serie  = plani.serie  
                   tt-plani.placod = plani.placod
                   tt-plani.confi  = vsit.

        end.
    
    end.


    run confir_2.p (input vetb,
                    input vdti,
                    input vdtf).


end.

 