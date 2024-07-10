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
    initial ["====>>>>","Marca/Desmarca","Marca/Des/Tudo"," Confirma",""].
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
     tt-estab.data
     with frame f-linha 10 down color with/cyan /*no-box*/
     centered.
                                                                         
                                                                                
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

def var vndx-atraso as int.
def var vndx-comprou as int.

def var vatraso as char extent 3
                init["  SIM  ","  NAO  "," TODOS "].
def var dti-atraso as date.
def var dtf-atraso as date.
def var vcomprou as char extent 3 format "x(15)"
            init[" COMPROU "," NAO COMPROU "," TODOS "].
def var dti-comprou as date.
def var dtf-comprou as date.

l1: repeat:    
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
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
                    tt-estab.data format ""99/99/9999""
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
        disp vatraso with frame f-atraso no-label title " Atraso " overlay
            row 18.
        choose field vatraso with frame f-atraso.
        vndx-atraso = frame-index.
        update dti-atraso at 1 label "Periodo"
           dtf-atraso no-label
           with frame f-atraso side-label.
        if dti-atraso = ? or
           dtf-atraso = ? or
           dti-atraso > dtf-atraso
        then do:
            message color red/with
            "Periodo invalido para processamento."
            view-as alert-box.
            next.
        end.   
        leave.
    end.
    if keyfunction(lastkey) = "END-ERROR"
        then next l1.
    repeat:        
        disp vcomprou with frame f-comprou no-label .
        choose field vcomprou with frame f-comprou.
        vndx-comprou = frame-index.
        if vndx-comprou < 3
        then do:
            update Dti-comprou at 1 label "Periodo"
                dtf-comprou no-label
                with frame f-comprou side-label column 30 row 18
                title " Comprou/Nao comprou ".
            if  dti-comprou = ? or
                dtf-comprou = ? or
                dti-comprou > dtf-comprou
            then do:
                message color red/with
                "Periodo invalido para processamento."
                view-as alert-box.
                next.
            end.
        end. 
        leave.
    end.
    if keyfunction(lastkey) = "END-ERROR"
    then next l1.

    def var vqtd-cli as int.
    vqtd-cli = 0.
    message "Informe a quantidade de clientes por arquivo CSV".
    message "Informe 0 para um unico arquivo"
    update vqtd-cli
    .
    
    message "Aguarde processamento..." .
    pause 0.
    
    run sel-clien.
     
    if vndx-atraso = 1
    then run ndx1-atraso.
    else if vndx-atraso = 2
        then run ndx2-atraso.
        else if vndx-atraso = 3
            then run ndx-atraso.

    if vndx-comprou = 1
    then run ndx1-comprou.
        else if vndx-comprou = 2
            then run ndx2-comprou.
    
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

procedure relatorio:

    def var vetbcad as char.
    def var varquivo as char.
    def var varq-csv as char.
    def var vatraso as char.
    def var vcomprou as char.
    def var vttclien as int.
    def var vfiliais as char extent 7 format "x(115)".
    
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
    varquivo = "/admcom/relat-crm/Listagem_Grupo_Elite/relcli-estab" + string(etb-sel,"999") +
                "." + string(time).
    varq-csv = "/admcom/relat-crm/Listagem_Grupo_Elite/relcli-estab" + string(etb-sel,"999") +
                string(time) + ".csv".
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "120" 
                &Page-Line = "66" 
                &Nom-Rel   = ""relcli-estab"" 
                &Nom-Sis   = """COMERCIAL LEBES""" 
                &Tit-Rel   = """RELATORIO DE CLENTES""" 
                &Width     = "120"
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

    do with frame f-atr side-label:
        if vndx-atraso = 1
        then vatraso = "Atraso = SIM".
        else if vndx-atraso = 2
            then vatraso = "Atraso = NAO".
            else if vndx-atraso = 3
                then vatraso = "Atraso = TODOS".
        disp Vatraso no-label format "x(20)"
             dti-atraso at 1 label "Periodo"
             dtf-atraso no-label
             .
    end.

    do with frame f-comp side-label:
        if vndx-comprou = 1
        then vcomprou = "COMPROU".
        else if vndx-comprou = 2
            then vcomprou = "NAO COMPROU".
            else if vndx-comprou = 3
                then vcomprou = "TODOS".
        disp vcomprou label "Comprou/Nao Comprou" format "x(20)"
             dti-comprou at 1 label "Periodo"
             dtf-comprou no-label
             .
    end.
    
    vttclien = 0.
    for each tt-clien where tt-clien.elegivel = yes,
        first clien where clien.clicod = tt-clien.clicod no-lock 
        by clien.clinom.
        if length(string(clien.clicod)) = 10
        then vetbcad = substr(string(clien.clicod),2,3).
        else vetbcad = substr(string(clien.clicod,"999999999"),8,2) .
        disp clien.clicod 
             clien.clinom
             clien.fone   column-label "Telefone" format "(xx)xxxxxxxx"
             clien.fax    column-label "Celular"  format "(xx)xxxxxxxx"
             vetbcad      column-label "Fil Cadastro"
             with frame f-disp down width 120.
        vttclien = vttclien + 1.
    end.         
    put skip(1) "Total de Clientes:" vttclien skip.
    
    output close.

    def var vq as int.
    for each tt-clien where tt-clien.elegivel = yes,
        first clien where clien.clicod = tt-clien.clicod no-lock 
        by clien.clinom.
        vq = vq + 1.
        tt-clien.seq = vq.
    end.
    def var va as int.
    def var vb as int.
    if vqtd-cli = 0
    then va = 1.
    else do:
        va = vq / vqtd-cli.
        if vq > va * vqtd-cli
        then va = va + 1.
    end.
    def var vseq as int. 
    vseq = 0.
    /*message va vq vqtd-cli. pause.
    */ 
    do vb = 1 to va:
        varq-csv = "/admcom/relat-crm/Listagem_Grupo_Elite/relcli-estab" + string(etb-sel,"999") +
            "-" + string(vb,"9999") + "-" + string(time) + ".csv".
        output to value(varq-csv).
    
        put "Cliente;Nome;Telefone;Celular;Fil Cadastro" skip.
        
        vttclien = 0.
        for each tt-clien use-index i2 where tt-clien.elegivel = yes and
                        tt-clien.seq > vseq,
            first clien where clien.clicod = tt-clien.clicod no-lock 
            by clien.clinom.
            if length(string(clien.clicod)) = 10
            then vetbcad = substr(string(clien.clicod),2,3).
            else vetbcad = substr(string(clien.clicod,"999999999"),8,2) .
            put unformatted clien.clicod ";"
                clien.clinom ";"
                clien.fone   format "(xx)xxxxxxxx"  ";"
                clien.fax    format "(xx)xxxxxxxx"  ";"
                vetbcad      
                skip.
            vttclien = vttclien + 1.      
             
            if vqtd-cli > 0 and vttclien = vqtd-cli
            then do:
                vseq = tt-clien.seq.
                leave.
            end. 
        end.     
        put unformatted skip(1) ";Total de Clientes;" vttclien skip.
        output close.
    end.
    
    message color red/with
        "Gerou " va "arquivos CSV" skip varq-csv
        view-as alert-box.
        
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.

procedure sel-clien:
    for each tt-estab where
             tt-estab.marca = "*" :
        disp tt-estab.etbcod no-label with frame f-posi.
        pause 0.
        if tt-estab.etbcod >= 100
        then do:
            for each clien where
                        int(substr(string(clien.clicod,"9999999999"),2,3))
                        = tt-estab.etbcod
                        no-lock:
                find first tt-clien where
                           tt-clien.clicod = clien.clicod
                           no-error.
                if not avail tt-clien
                then do:            
                    create tt-clien.
                    tt-clien.clicod = clien.clicod.
                    tt-clien.elegivel = yes.
                end.
            end.            
        end.
        else do:
            for each clien where
                        int(substr(string(clien.clicod,"9999999999"),9,2))
                        = tt-estab.etbcod
                        no-lock:
                if clien.clicod < 10
                then next.
                
                find first tt-clien where
                           tt-clien.clicod = clien.clicod
                           no-error.
                if not avail tt-clien
                then do:            
                    create tt-clien.
                    tt-clien.clicod = clien.clicod.
                    tt-clien.elegivel = yes.
                end.
            end. 
        end.
        assign
            qtd-sel = qtd-sel + 1
            etb-sel = tt-estab.etbcod
            .
    end.         
end procedure.
procedure ndx1-atraso:
    for each tt-clien where tt-clien.elegivel = yes:
        disp tt-clien.clicod no-label with frame f-posi.
        pause 0.
        find first titulo where 
                 titulo.clifor = tt-clien.clicod and
                 titulo.titdtven >= dti-atraso and
                 titulo.titdtven <= dtf-atraso and
                 titulo.titsit = "LIB" and
                 titulo.titdtven < today
                 no-lock no-error.
        if not avail titulo
        then tt-clien.elegivel = no.         
    end. 
end procedure.
procedure ndx2-atraso:
    for each tt-clien where tt-clien.elegivel = yes:
        disp tt-clien.clicod no-label with frame f-posi.
        pause 0.
        find first titulo where 
                 titulo.clifor = tt-clien.clicod and
                 titulo.titdtven >= dti-atraso and
                 titulo.titdtven <= dtf-atraso and
                 titulo.titsit = "LIB" and
                 titulo.titdtven < today
                 no-lock no-error.
        if avail titulo
        then tt-clien.elegivel = no.         
    end.                 
end procedure.

procedure ndx-atraso:
    for each tt-clien where tt-clien.elegivel = yes:
        disp tt-clien.clicod no-label with frame f-posi.
        pause 0.    
        find first titulo where 
                 titulo.clifor = tt-clien.clicod and
                 titulo.titdtven >= dti-atraso and
                 titulo.titdtven <= dtf-atraso 
                 no-lock no-error.
        if not avail titulo
        then tt-clien.elegivel = no.         
    end. 
end procedure.
procedure ndx1-comprou:
    for each tt-clien where tt-clien.elegivel = yes:
        disp tt-clien.clicod no-label with frame f-posi.
        pause 0.
        find first plani where plani.movtdc = 5 and
                             plani.desti = tt-clien.clicod and
                             plani.pladat >= dti-comprou and
                             plani.pladat <= dtf-comprou
                             no-lock no-error.
        if not avail plani
        then tt-clien.elegivel = no.                     
    end.                                
end procedure.
procedure ndx2-comprou:
    for each tt-clien where tt-clien.elegivel = yes:
        disp tt-clien.clicod no-label with frame f-posi.
        pause 0.
        find first plani where plani.movtdc = 5 and
                             plani.desti = tt-clien.clicod and
                             plani.pladat >= dti-comprou and
                             plani.pladat <= dtf-comprou
                             no-lock no-error.
        if avail plani
        then tt-clien.elegivel = no.                     
    end.                                
end procedure.


