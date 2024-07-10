{admcab.i}
{setbrw.i}                                                                      

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var qtd-sel as int.
def var etb-sel like estab.etbcod.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["Marca/Desmarca","Marca/Des/Tudo"," Confirma","",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["teste teste",
             "",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["teste teste  ",
            " ",
            " ",
            " ",
            " "].

form
    esqcom1
    with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

def temp-table tt-estab 
    field etbcod like estab.etbcod 
    field data as date
    field marca as char format "x"
    index i1 etbcod.

def temp-table tt-clien
    field clicod like clien.clicod
    field elegivel as log 
    field seq as int
    index i1 clicod
    index i2 seq
    .

form  
     tt-estab.marca format "x" no-label
     tt-estab.etbcod
     estab.etbnom
     with frame f-linha down width 45
     .
                                                                         
def temp-table tt-indica
    field etbcod like estab.etbcod
    field clicod like clien.clicod
    field cod_indica like clien.clicod
    field n-cart as char
    field q-cart as int
    field q-clie as int
    field numero like plani.numero
    index i1 etbcod
    .
def temp-table tt-indicado
    field etbcod like estab.etbcod
    field data as date format "99/99/9999"
    field clicod like clien.clicod
    field numero like plani.numero
    field valor like plani.platot
    field q-cli as int
    field procod like produ.procod
    index i1 etbcod
    .

def buffer btbcntgen for tbcntgen.                            
def var i as int.

for each estab where estab.etbcod <= 200 no-lock:
    create tt-estab.
    tt-estab.etbcod = estab.etbcod.
    find first plani use-index pladat where 
              plani.etbcod = estab.etbcod and
              plani.movtdc = 5
              no-lock no-error.
    if avail plani
    then tt-estab.data = plani.pladat.
end.

form "Aguarde processamento... " with frame f-posi
    row 16 color message width 80 no-box overlay.

def var vndx-cli as int.
def var vndx-tipo as int.

def var vcli as char extent 2 format "x(20)"
                init["CLIENTE INDICOU","CLIENTE INDICADO"].
def var vtipo as char extent 2 format "x(15)"
            init[" ANALITICO "," SINTETICO "].
def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".

l1: repeat:    
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    pause 0.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    color display message esqcom1[esqpos1] with frame f-com1.
        
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = tt-estab   
        &cfield =  tt-estab.etbcod
        &noncharacter = /* 
        &ofield = " tt-estab.marca
                    tt-estab.etbcod
                    estab.etbnom when avail estab   no-label
                    column-label ""Abertura"" "  
        &aftfnd1 = " find estab where estab.etbcod = tt-estab.etbcod
                            no-lock no-error. "
        &where  = " "
        &aftselect1 = " run aftselect.
                        if esqcom1[esqpos1] = "" Confirma"" 
                        then do:
                            leave keys-loop.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  " 
        &otherkeys1 = " run controle. "
        &locktype = " "
        &form   = " frame f-linha "
    }   
    
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
    
    repeat:
        disp vcli with frame f-atraso no-label overlay
            column 50 row 7.
        choose field vcli with frame f-atraso.
        vndx-cli = frame-index.
        leave.
    end.
    if keyfunction(lastkey) = "END-ERROR"
        then next l1.
    repeat:        
        disp vtipo with frame f-comprou no-label overlay
                column 50 .
        choose field vtipo with frame f-comprou.
        vndx-tipo = frame-index.
        leave.
    end.
    if keyfunction(lastkey) = "END-ERROR"
    then next l1.

    update vdti no-label
           vdtf no-label
           with frame f-data side-label
           title " periodo " column 50 row 15
           .
    /**
    def var vqtd-cli as int.
    vqtd-cli = 0.
    message "Informe a quantidade de clientes por arquivo CSV".
    message "Informe 0 para um unico arquivo"
    update vqtd-cli
    .
    ***/
    
    message "Aguarde processamento..." .
    pause 0.

    if vndx-cli = 1
    then run ndx1-cli.
    else run ndx2-cli.
    
    run relatorio.
    
    for each tt-estab:
        tt-estab.marca = "".
    end.
    leave l1.    
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.

procedure aftselect:
    clear frame f-linha1 all.
    if esqcom1[esqpos1] = "Marca/Desmarca"
    THEN DO on error undo:
        if tt-estab.marca = "*"
        then tt-estab.marca = "".
        else tt-estab.marca = "*".
        disp tt-estab.marca with frame f-linha.
        pause 0.
    END.
    else
    if esqcom1[esqpos1] = "Marca/Des/Tudo"
    THEN DO:
        find first tt-estab where tt-estab.marca  = "*" no-error
        .
        if avail tt-estab
        then for each tt-estab:
                tt-estab.marca = "".
             end.
        else for each tt-estab:
                tt-estab.marca = "*".
             end.
        a-seeid = -1.

    END.
    else
    if esqcom1[esqpos1] = " Confirma"
    THEN DO:
        find first tt-estab where tt-estab.marca = "*" no-error.
        if not avail tt-estab
        then do:
            message color red/with
            "Marcar filial antes de confirmar."
            view-as alert-box.
            color display normal esqcom1[esqpos1] with frame f-com1.
            esqpos1 = 1.
            color display message esqcom1[esqpos1] with frame f-com1.
        end.
    END.
    else
    if esqcom2[esqpos2] = "    "
    THEN DO on error undo:
    
    END.

end procedure.

procedure controle:
        def var ve as int.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    esqpos1 = 1.
                    do ve = 1 to 5:
                    color display normal esqcom1[ve] with frame f-com1.
                    end.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    do ve = 1 to 5:
                    color display normal esqcom2[ve] with frame f-com2.
                    end.
                    esqpos2 = 1.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
end procedure.

/****
procedure ndx1-cli:
    for each titulo use-index titdtven 
                    where titulo.empcod    = 19 and
                          titulo.titnat    = yes and
                          titulo.modcod    = "CHP" and
                          titulo.etbcod    = 999 and
                          titulo.titdtven >= vdti and
                          titulo.titdtven <= vdtf and
                          titulo.clifor    = 110165 and
                          titulo.titvlcob  = 20  
                          no-lock:
        find first tt-estab where
                   tt-estab.etbcod =
                     int(acha("ETBCODVENDACHP",titulo.titobs[1]))
               and tt-estab.marca = "*"
                     no-error.
        if not avail tt-estab
        then next.             
        find first plani where
             plani.movtdc = 5 and
             plani.etbcod = int(acha("ETBCODVENDACHP",titulo.titobs[1])) and
             plani.placod = int(acha("PLACODVENDACHP",titulo.titobs[1])) and
             plani.pladat = titulo.titdtven
             no-lock no-error.
        if avail plani
        then do:     
            find first indicacl where    
                       indicacl.clicod = plani.desti
                       no-lock no-error.
            if avail indicacl            
            then do:            
                create tt-indica.
                assign
                    tt-indica.etbcod = plani.etbcod 
                    tt-indica.clicod = indicacl.cod_indica 
                    tt-indica.n-cart = titulo.titnum 
                    tt-indica.q-cart = 1 
                    tt-indica.q-clie = 1 
                    tt-indica.numero = plani.numero
                    .
            end.
        end.         
    end.
end procedure.
****/

procedure ndx1-cli:
    for each indicacl where
             indicacl.dtinclu >= vdti and
             indicacl.dtinclu <= vdtf
             no-lock:
        
        find first plani where plani.movtdc = 5 and
                               plani.desti = indicacl.clicod and
                               plani.pladat = indicacl.dtinclu 
                               no-lock no-error.
        if avail plani and
            can-find(first tt-estab where
                           tt-estab.etbcod = plani.etbcod and
                           tt-estab.marca  = "*")
        then do:

            create tt-indica.
            assign
            tt-indica.clicod = indicacl.clicod
            tt-indica.cod_indica = indicacl.cod_indica
            .

            for each titulo use-index titdtven 
                    where titulo.empcod    = 19 and
                          titulo.titnat    = yes and
                          titulo.modcod    = "CHP" and
                          titulo.etbcod    = 999 and
                          titulo.titdtven  = plani.pladat and
                          titulo.clifor    = 110165 and
                          titulo.titvlcob  = 20  
                          no-lock:

                if int(acha("ETBCODVENDACHP",titulo.titobs[1])) 
                                = plani.etbcod
                   and int(acha("PLACODVENDACHP",titulo.titobs[1])) 
                                = plani.placod
                then do:
                    assign
                        tt-indica.n-cart = titulo.titnum
                        tt-indica.q-cart = 1
                        .
                    leave.
                end.        
            end.                                            
            
            assign
                    tt-indica.etbcod = plani.etbcod 
                    tt-indica.q-clie = 1 
                    tt-indica.numero = plani.numero
                    .
        end.
    end.        
end procedure.

procedure ndx2-cli:
    for each indicacl where
             indicacl.dtinclu >= vdti and
             indicacl.dtinclu <= vdtf
             no-lock:
        find first plani where plani.movtdc = 5 and
                               plani.desti = indicacl.clicod and
                               plani.pladat = indicacl.dtinclu 
                               no-lock no-error.
        if avail plani and
            can-find(first tt-estab where
                           tt-estab.etbcod = plani.etbcod and
                           tt-estab.marca  = "*")
        then do:
            create tt-indicado.
            assign
                tt-indicado.etbcod = plani.etbcod
                tt-indicado.data   = indicacl.dtinclu
                tt-indicado.clicod = indicacl.clicod
                tt-indicado.numero = plani.numero
                tt-indicado.valor  = plani.platot
                tt-indicado.q-cli  = 1
                .
            for each movim where
                     movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.movtdc = plani.movtdc and
                     movim.movdat = plani.pladat
                     no-lock:
                if movim.movpc = 1
                then tt-indicado.procod = movim.procod.
            end.                    
        end.
    end.        
end procedure.

procedure relatorio:

    def var vclinom like clien.clinom.
    def var vetbcad as char.
    def var varquivo as char.
    def var varq-csv as char.
    def var vatraso as char.
    def var vcomprou as char.
    def var vttclien as int.
    def var vfiliais as char extent 7 format "x(115)".
    
    def var t-cart as int.
    def var t-clie as int.
    def var t-cli as int.
    def var t-cad as int.
    def var t-val as dec.
    
    for each tt-estab where tt-estab.marca = "*":
        if tt-estab.etbcod < 31
        then vfiliais[1] = vfiliais[1] + string(tt-estab.etbcod) + "," .
        else if tt-estab.etbcod < 61
        then vfiliais[2] = vfiliais[2] + string(tt-estab.etbcod) + "," .
        else if tt-estab.etbcod < 91
        then vfiliais[3] = vfiliais[3] + string(tt-estab.etbcod) + "," .
        else if tt-estab.etbcod < 121
        then vfiliais[4] = vfiliais[4] + string(tt-estab.etbcod) + "," .
        else if tt-estab.etbcod < 151
        then vfiliais[5] = vfiliais[5] + string(tt-estab.etbcod) + "," .
        else if tt-estab.etbcod < 181
        then vfiliais[6] = vfiliais[6] + string(tt-estab.etbcod) + "," .
        else if tt-estab.etbcod < 111
        then vfiliais[7] = vfiliais[7] + string(tt-estab.etbcod) + "," .
     end.   
    if qtd-sel > 1
    then etb-sel = 999. 
    varquivo = "/admcom/relat/rcampindamigos" +
                "." + string(time).
    varq-csv = "/admcom/relat/rcampindamigos" +
                string(time) + ".csv".
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "100" 
                &Page-Line = "66" 
                &Nom-Rel   = ""relcli-estab"" 
                &Nom-Sis   = """COMERCIAL LEBES""" 
                &Tit-Rel   = """RELATORIO INDCACAO DE CLIENTES""" 
                &Width     = "100"
                &Form      = "frame f-cabcab"}

    put "Filial/Filiais:" skip.
    if vfiliais[1] <> ""
    then put vfiliais[1] format "x(120)" skip.
    if vfiliais[2] <> ""
    then put vfiliais[2] format "x(120)" skip.
    if vfiliais[3] <> ""
    then put vfiliais[3] format "x(120)" skip.
    if vfiliais[4] <> ""
    then put vfiliais[4] format "x(120)" skip.
    if vfiliais[5] <> ""
    then put vfiliais[5] format "x(120)" skip.
    if vfiliais[6] <> ""
    then put vfiliais[6] format "x(120)" skip.
    if vfiliais[7] <> ""
    then put vfiliais[7] format "x(120)" skip.

    put vcli[vndx-cli] format "x(20)".
    put vtipo[vndx-tipo] format "x(20)".
    put "Periodo: " vdti " Ate " vdtf.
    put skip.

    if vndx-cli = 1 and vndx-tipo = 1
    then do:
        for each tt-indica :
            find clien where clien.clicod = tt-indica.cod_indica
                            no-lock no-error.
            if not avail clien then next.
            disp tt-indica.etbcod column-label "Filial"
                 tt-indica.cod_indica column-label "Cliente"
                 clien.clinom when avail clien column-label "Nome"
                 tt-indica.n-cart column-label "Cartao"
                 tt-indica.numero column-label "NFiscal" format ">>>>>>>>>>>>>>>>9"
                 with frame tt-indica down width 100
                 .
        end.                                   
    end.
    else if vndx-cli = 1 and vndx-tipo = 2
    then do:
        for each tt-indica 
                break by tt-indica.etbcod by tt-indica.cod_indica:
            find clien where clien.clicod = tt-indica.cod_indica
                            no-lock no-error.
            t-cart = t-cart + tt-indica.q-cart.
            t-clie = t-clie + tt-indica.q-clie.
            if last-of(tt-indica.cod_indica)
            then do:    
                disp tt-indica.etbcod column-label "Filial"
                     tt-indica.cod_indica column-label "Cliente"
                     clien.clinom  when avail clien column-label "Nome"
                     t-cart (total by tt-indica.etbcod)
                               column-label "Total!Cartao"
                     t-clie (total by tt-indica.etbcod)
                               column-label "Total!Indicado"
                     with frame tt-indica1 down width 100
                     .
                assign
                    t-cart = 0
                    t-clie = 0
                    .
            end.
        end.        
    end.
    else if vndx-cli = 2 and vndx-tipo = 1
    then do:
        for each tt-indicado:
            find clien where clien.clicod = tt-indicado.clicod
                no-lock no-error.
            disp tt-indicado.etbcod column-label "Filial"
                 tt-indicado.data   column-label "Cadastro"
                 tt-indicado.clicod column-label "Indicado"
                 clien.clinom when avail clien column-label "Nome"
                 tt-indicado.numero column-label "NFiscal" format ">>>>>>>>>>>>>>9" 
                 tt-indicado.valor  column-label "Valor"
                 with frame f-indicado down width 100.
        end.
    end.
    else if vndx-cli = 2 and vndx-tipo = 2
    then do:
        for each tt-indicado break by tt-indicado.etbcod:
            find clien where clien.clicod = tt-indicado.clicod
                no-lock no-error.
            
            assign
                t-cli = t-cli + 1
                t-val = t-val + tt-indicado.valor
                .

            if tt-indicado.procod = 405248 or
               tt-indicado.procod = 518440 or
               tt-indicado.procod = 549356
            then t-cad = t-cad + 1.    
            
            if last-of(tt-indicado.etbcod)
            then do:
                disp tt-indicado.etbcod column-label "Filial"
                     t-cli(total) column-label "Indicado" 
                     t-val(total) column-label "Valor" format ">,>>>,>>9.99"
                     t-cad(total) column-label "Cadeiras"
                     with frame f-indicado1 down width 100.
                assign
                    t-cli = 0
                    t-cad = 0
                    t-val = 0
                    .
            end.
        end.
    end.

    output close.
    
    /********************* gera CSV *******************/

    output to value(varq-csv).
    
    put vcli[vndx-cli] format "x(20)".
    put vtipo[vndx-tipo] format "x(20)".
    put "Periodo: " vdti " Ate " vdtf.
    put skip.

    if vndx-cli = 1 and vndx-tipo = 1
    then do:
        put unformatted "Flilial;Cliente;Nome;Cartao;NFiscal" skip.
        for each tt-indica :
            find clien where clien.clicod = tt-indica.cod_indica
                            no-lock no-error.
            if avail clien
            then vclinom = clien.clinom.
            else vclinom = "".
            put unformatted
                 tt-indica.etbcod ";"
                 tt-indica.cod_indica ";"
                 vclinom ";"
                 tt-indica.n-cart ";"
                 tt-indica.numero ";"
                 skip
                 .
        end.
        output close.  
    end.
    else if vndx-cli = 1 and vndx-tipo = 2
    then do:
        put unformatted 
            "Filial;Cliente;Nome;TotalCartao;TotalIndicado"
            skip.
        for each tt-indica 
                break by tt-indica.etbcod by tt-indica.cod_indica:
            find clien where clien.clicod = tt-indica.cod_indica
                            no-lock no-error.
            if avail clien
            then vclinom = clien.clinom.
            else vclinom = "".
            t-cart = t-cart + tt-indica.q-cart.
            t-clie = t-clie + tt-indica.q-clie.
            if last-of(tt-indica.cod_indica)
            then do:    
                put unformatted
                     tt-indica.etbcod ";"
                     tt-indica.cod_indica ";"
                     vclinom  ";"
                     t-cart ";"
                     t-clie ";"
                     skip
                     .
                assign
                    t-cart = 0
                    t-clie = 0
                    .
            end.
        end.        
    end.
    else if vndx-cli = 2 and vndx-tipo = 1
    then do:
        put unformatted
            "Filial;Cadastro;Indicado;Nome;NFiscal;Valor"
            skip.
        for each tt-indicado:
            find clien where clien.clicod = tt-indicado.clicod
                no-lock no-error.
            if avail clien
            then vclinom = clien.clinom.
            else vclinom = "".
            put unformatted
                 tt-indicado.etbcod ";"
                 tt-indicado.data   ";"
                 tt-indicado.clicod ";"
                 vclinom ";"
                 tt-indicado.numero ";"
                 tt-indicado.valor  ";"
                 skip. 
        end.
    end.
    else if vndx-cli = 2 and vndx-tipo = 2
    then do:
        put unformatted
            "Filial;Indicaco;Valor;Cadeiras"
            skip.
            
        for each tt-indicado break by tt-indicado.etbcod:
            find clien where clien.clicod = tt-indicado.clicod
                no-lock no-error.
            if avail clien
            then vclinom = clien.clinom.
            else vclinom = "".
            assign
                t-cli = t-cli + 1
                t-val = t-val + tt-indicado.valor
                .

            if tt-indicado.procod = 405248 or
               tt-indicado.procod = 518440 or
               tt-indicado.procod = 549356
            then t-cad = t-cad + 1.    
            
            if last-of(tt-indicado.etbcod)
            then do:
                put unformatted
                     tt-indicado.etbcod ";"
                     t-cli ";"
                     t-val ";"
                     t-cad ";"
                     skip.
                     
                assign
                    t-cli = 0
                    t-cad = 0
                    t-val = 0
                    .
            end.
        end.
    end.
    output close.
    
    message color red/with
        "Arquivo CSV gerado" skip
        varq-csv view-as alert-box.
        
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.



