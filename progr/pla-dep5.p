{admcab.i}

def var vdt as date.
def var varquivo as char format "x(20)".
def var i as i.
def var v-de like plani.platot.
def var v-ac like plani.platot.
def var vetbcod like estab.etbcod.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.

def temp-table tt-tipmov 
    field data    like plani.pladat
    field custo   like plani.platot extent 20.

def var totcus like plani.platot extent 20.

def temp-table tt-plani
    field movtdc like plani.movtdc
    field movtnom like tipmov.movtnom.

def var totsai like plani.platot format ">>>,>>>,>>9.99".
def var totent like plani.platot format ">>>,>>>,>>9.99".


repeat:
    
    do i = 1 to 20:
        totcus[i] = 0.
    end.
    i = 0.


    totsai = 0.
    totent = 0.
    for each tt-plani:
        delete tt-plani.
    end.
    
    for each tt-tipmov.
        delete tt-tipmov.
    end.

    update vetbcod colon 16 label "Filial" with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    disp estab.etbnom no-label with frame f1.
    update vdti colon 16 label "Data Inicial"
           vdtf colon 16 label "Data Final"with frame f1.
    for each tipmov where tipmov.movtdc = 03 or
                          tipmov.movtdc = 06 no-lock:
        do vdt = vdti to vdtf:
        for each plani where plani.datexp = vdt           and
                             plani.movtdc = tipmov.movtdc  and
                             plani.desti  = estab.etbcod no-lock:
        
            disp plani.numero
                 plani.pladat
                        with frame ff2 1 down side-label. pause 0.
            find first tt-tipmov where tt-tipmov.data  = plani.datexp 
                                        no-error.
            if not avail tt-tipmov
            then do:
                create tt-tipmov.
                assign tt-tipmov.data = plani.datexp.
            end.
            tt-tipmov.custo[9] = tt-tipmov.custo[9] + plani.platot.
        
        end.
        end.
    end.

    hide frame ff2 no-pause.
    for each tipmov no-lock:
        if tipmov.movtdc = 9 or
           tipmov.movtdc = 10
        then next.   
 
        do vdt = vdti - 60 to vdtf + 60:
        for each plani where plani.datexp  = vdt            and
                             plani.movtdc  = tipmov.movtdc  and
                             plani.etbcod  = estab.etbcod no-lock:
        
        
            if plani.dtinclu >= vdti and
               plani.dtinclu <= vdtf
            then.
            else next.
            if plani.hiccod = 199 or
               plani.hiccod = 299
            then next.
               
               
            if plani.movtdc = 4 and
               plani.emite  = 5027 and
               plani.etbcod = 996
            then next.
            
            
            disp plani.numero
                 plani.pladat
                    with frame f2 1 down side-label. pause 0.
        
            find first tt-tipmov where tt-tipmov.data = plani.dtinclu no-error.
            if not avail tt-tipmov
            then do:
                create tt-tipmov.
                assign tt-tipmov.data = plani.dtinclu.
            end.
            tt-tipmov.custo[plani.movtdc] = tt-tipmov.custo[plani.movtdc] + 
                                  plani.platot.
        end.
        end.
    end.
    hide frame f2 no-pause.

    for each tt-tipmov no-lock:
        i = 0.
        do i = 1 to 20:
            if tt-tipmov.custo[i] <> 0
            then do:
                find first tt-plani where tt-plani.movtdc = i no-error.
                if not avail tt-plani
                then do:
                    create tt-plani.
                    assign tt-plani.movtdc = i.
                     
                    if i = 1
                    then tt-plani.movtnom = "ORC.ENTRAD".
                    if i = 2
                    then tt-plani.movtnom = "ORC.SAIDA ".

                    /*
                    if i = 3
                    then tt-plani.movtnom = "ORC.TRANSF".
                    */
                    
                    if i = 4
                    then tt-plani.movtnom = "NF ENTRADA".

 
                    if i = 5
                    then tt-plani.movtnom = "NF   SAIDA".
                    
                    if i = 6 or
                       i = 3
                    then tt-plani.movtnom = "TRANSF.SAI".

 
                    if i = 7
                    then tt-plani.movtnom = "AJUSTE ACR".
                    if i = 8
                    then tt-plani.movtnom = "AJUSTE DEC".

 
                    if i = 9
                    then tt-plani.movtnom = "TRANSF.ENT".
                    if i = 12
                    then tt-plani.movtnom = "DEV. VENDA".

 
                    if i = 13
                    then tt-plani.movtnom = "DEV.FORNEC".
                    if i = 14
                    then tt-plani.movtnom = "SIMP.REMES".

 
                    if i = 15
                    then tt-plani.movtnom = "ENT.CONSER".
                    if i = 16
                    then tt-plani.movtnom = "REM.CONSER".
 
                    if i = 17
                    then tt-plani.movtnom = "TROCA ENTR".
                    if i = 18
                    then tt-plani.movtnom = "TROCA SAI.".
                    
                    if i = 19
                    then tt-plani.movtnom = "ENT.AJUSTE".
                    if i = 20
                    then tt-plani.movtnom = "SAI.AJUSTE".

                end.
            end.
        end.
    end.


    varquivo = "..\relat\pla" + STRING(day(today)) + 
                string(estab.etbcod,">>9").

    {mdad.i
            &Saida     = "value(varquivo)" 
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""pla-dep""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """FILIAL "" + string(vetbcod,"">>9"") +
                          "" DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "130"
            &Form      = "frame f-cabcab"}


    put "DIA    ".
    for each tt-plani by tt-plani.movtdc:
        put tt-plani.movtnom format "x(11)"  "  " .
    end.
    put skip fill("-",130) format "x(130)" skip.
                    
    
    for each tt-tipmov by tt-tipmov.data:
        put day(tt-tipmov.data) format ">99"
            "  ".
        for each tt-plani by tt-plani.movtdc:
            put tt-tipmov.custo[tt-plani.movtdc] format ">,>>>,>>9.99" 
                " ".
            totcus[tt-plani.movtdc] = totcus[tt-plani.movtdc] +
                                      tt-tipmov.custo[tt-plani.movtdc].
                
            if tt-plani.movtdc = 4  or
               tt-plani.movtdc = 1  or
               tt-plani.movtdc = 7  or
               tt-plani.movtdc = 9  or
               tt-plani.movtdc = 12 or
               tt-plani.movtdc = 15 or
               tt-plani.movtdc = 17 
            then totent = totent + tt-tipmov.custo[tt-plani.movtdc].

            if tt-plani.movtdc = 5  or
               tt-plani.movtdc = 3  or
               tt-plani.movtdc = 6  or
               tt-plani.movtdc = 13 or
               tt-plani.movtdc = 14 or
               tt-plani.movtdc = 16 or
               tt-plani.movtdc = 8  or
               tt-plani.movtdc = 18
            then totsai = totsai + tt-tipmov.custo[tt-plani.movtdc].

        end.
        put skip.
    end.
    put skip fill("-",130) format "x(130)" skip
        "TOT..".
    for each tt-plani by tt-plani.movtdc:
        put totcus[tt-plani.movtdc] format ">>,>>>,>>9.9"
                " ".
    end.
    put skip fill("-",130) format "x(130)" skip.

    put "TOTAL DE ENTRADAS:   "  at 20 totent 
        
        "TOTAL DE SAIDAS  :   "  at 20 totsai .


    output close.
    /*
    message "Deseja Imprimir relatorio" update sresp.
    if sresp
    then dos silent value("type " + varquivo + " > prn").  
    */
    {mrod.i}
end.



            
    
