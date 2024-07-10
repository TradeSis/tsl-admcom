{admcab.i}

def var varquivo as char format "x(15)".
def var vsit as char format "x(15)".
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vetbcod like estab.etbcod.
def var vesc as log format "Emitente/Destinatario".
def var vetb like estab.etbcod.

def new shared temp-table tt-plani
    field movtdc like plani.movtdc
    field pladat like plani.pladat  
    field datexp like plani.datexp format "99/99/9999" 
    field emite  like plani.emite 
    field desti  like plani.desti
    field numero like plani.numero format ">>>>>>9"
    field notant like plani.numero format ">>>>>>9"
    field serie  like plani.serie  
    field placod like plani.placod
    field confi  as char format "x(15)".
    
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
    
    def var vserie as char.
    
    if vetbcod = 22
        then vserie = "55".
        else vserie = "U".

    varquivo = "/admcom/relat/con" + string(time).
    {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""con-con""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """CONFIRMACAO DE TRANSFERENCIA FILIAL - "" +
                          string(vetbcod) +  "" PERIODO DE  "" +
                          string(vdti,""99/99/9999"") +
                          string(vdtf,""99/99/9999"")"
            &Width     = "130"
            &Form      = "frame f-cabcab"}


    if vesc
    then do:
        for each tipmov where tipmov.movtdc = 06 or
                              tipmov.movtdc = 09 no-lock,
            each plani where plani.movtdc = tipmov.movtdc and
                             plani.etbcod = vetbcod and
                             (plani.serie  = vserie or
                              plani.serie  = "1"  or
                              plani.serie  = "01" or
                              plani.serie = "55"  or
                              plani.serie = "2"   or
                              plani.serie = "02") and 
                             plani.pladat >= vdti and
                             plani.pladat <= vdtf no-lock:
      
            if vetb <> 0
            then if vetb <> plani.desti
                 then next.
            
            vsit = "Confirmada".
            find first nottra where nottra.etbcod = plani.etbcod and
                                    nottra.desti  = plani.desti  and
                                    nottra.movtdc = plani.movtdc and
                                    nottra.numero = plani.numero and
                                    nottra.serie  = plani.serie 
                                        no-lock no-error.
            if not avail nottra
            then vsit = "Nao Confirmada".

            disp plani.pladat 
                 plani.datexp format "99/99/9999" 
                 plani.emite
                 plani.desti 
                 plani.numero format ">>>>>>9"
                 plani.nottran format ">>>>>>9" column-label "Num.Antigo"
                 plani.serie 
                 vsit no-label with frame f2 down centered.
        
            create tt-plani.
            assign tt-plani.movtdc = plani.movtdc
                   tt-plani.pladat = plani.pladat  
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
        for each tipmov where tipmov.movtdc = 06 or
                              tipmov.movtdc = 09 no-lock,
            each plani where plani.movtdc = tipmov.movtdc and
                              plani.desti  = vetbcod and
                              (plani.serie  = vserie or
                              plani.serie  = "01" or
                              plani.serie  = "1"  or
                              plani.serie = "55"  or
                              plani.serie = "2"   or
                              plani.serie = "02") and
                              plani.pladat >= vdti and
                              plani.pladat <= vdtf no-lock:
      
            if vetb <> 0
            then if vetb <> plani.emite
                 then next.
            
             
            vsit = "Confirmada".
            find first nottra where nottra.etbcod = plani.etbcod and
                                    nottra.desti  = plani.desti  and
                                    nottra.movtdc = plani.movtdc and
                                    nottra.numero = plani.numero and
                                    nottra.serie  = plani.serie 
                                        no-lock no-error.
            if not avail nottra
            then vsit = "Nao Confirmada".

            disp plani.pladat 
                 plani.datexp format "99/99/9999" 
                 plani.emite
                 plani.desti 
                 plani.numero format ">>>>>>9"
                 plani.nottran format ">>>>>>9" column-label "Num.Antigo" 
                 plani.serie 
                 vsit no-label with frame f3 down centered.
        
            create tt-plani.
            assign tt-plani.movtdc = plani.movtdc
                   tt-plani.pladat = plani.pladat  
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

    output close.
    run visurel.p (input varquivo, input "").

    run confir_1.p(input vetbcod).
end.

