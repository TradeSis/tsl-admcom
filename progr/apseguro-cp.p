{admcab.i}
{setbrw.i}                                                                      

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  Importa","  Filtro","  Relatorio",""].
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

def temp-table tt-apseguro like apseguro.

form  tt-apseguro.apolice         column-label "Produto/Apolice"
        format "x(27)"
      tt-apseguro.processamento   column-label "Processamento"
      tt-apseguro.inicio_vigencia column-label "Inicio"
      tt-apseguro.CPF             column-label "CPF"  format "x(16)"
      tt-apseguro.premio_total    column-label "Premio"
      with frame f-linha width 80 down
      .
 
/*                                                                                
disp "                  INCLUSAO SERIAIS - ESN/IMEI       " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
*/

def var v-cpf as char.
def var v-processa as date.
def var v-dti as date.
def var v-dtf as date.
def var v-sit as char.


def var i as int.
def buffer bapseguro for apsegur.

l1: repeat:
    for each tt-apseguro: delete tt-apseguro. end.
    
    find last bapseguro use-index processamento
        no-lock no-error.

    if v-processa <> ?
    then
    for each apseguro where
              apseguro.processamento = v-processa 
              no-lock:
        if v-cpf <> "" and
           apseguro.cpf <> v-cpf
        then next.  
        if v-sit <> ""
        then.   
        create tt-apseguro.
        buffer-copy apseguro to tt-apseguro.
    end.          
    else if v-dti <> ? and v-dtf <> ?
    then 
    for each apseguro where
              apseguro.inicio_vigencia >= v-dti and
              apseguro.inicio_vigencia <= v-dtf 
              no-lock:
        if v-cpf <> "" and
           apseguro.cpf <> v-cpf
        then next.  
        if v-sit <> ""
        then.   
        create tt-apseguro.
        buffer-copy apseguro to tt-apseguro.
    end. 
    else if v-dti <> ?
    then
    for each apseguro where
              apseguro.inicio_vigencia = v-dti 
              no-lock:
        if v-cpf <> "" and
           apseguro.cpf <> v-cpf
        then next.  
        if v-sit <> ""
        then.   
        create tt-apseguro.
        buffer-copy apseguro to tt-apseguro.
    end. 
    else if v-cpf <> ""
    then
    for each apseguro where
              apseguro.cpf = v-cpf
              no-lock:
        if v-sit <> ""
        then.   
        create tt-apseguro.
        buffer-copy apseguro to tt-apseguro.
    end. 
    else 
    for each apseguro where
              apseguro.processamento = bapseguro.processamento 
              no-lock:
        if v-cpf <> "" and
           apseguro.cpf <> v-cpf
        then next.  
        if v-sit <> ""
        then.   
        create tt-apseguro.
        buffer-copy apseguro to tt-apseguro.
    end. 
              
    clear frame f-com1 all.
    clear frame f-com2 all.
    hide frame f-com1.
    hide frame f-com2.
    pause 0.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    pause 0.
 
    {sklclstb.i  
        &color = with/cyan
        &file = tt-apseguro   
        &cfield = tt-apseguro.apolice
        &noncharacter = /* 
        &ofield = " tt-apseguro.processamento
                    tt-apseguro.inicio_vigencia
                    tt-apseguro.CPF
                    tt-apseguro.premio_total
                    "  
        &aftfnd1 = " "
        &where  = " "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  Importa"" or
                           esqcom1[esqpos1] = ""  Filtro""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " /*bell.
                        Message color red/with
                        ""Nenhum registro encontrado.""
                        view-as alert-box. */
                        esqcom1[esqpos1] = ""  Importa"".
                        run aftselect.
                        next l1.
                        " 
        &otherkeys1 = " run controle. "
        &locktype = " "
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.

procedure aftselect:
    clear frame f-linha1 all.
    if esqcom1[esqpos1] = "  Importa"
    THEN DO on error undo:
        run importa-apseguro-1.p.
    END.
    if esqcom1[esqpos1] = "  Filtro"
    THEN DO:
        update v-processa label "Processamento"
               v-dti label "Inicio de"
               v-dtf label "nicio ate"
               v-cpf label "CPF"  format "x(16)"
               v-sit label "Situacao"
               with frame f-filtro overlay 1 down centered row 8 
               side-label 1 column .
        hide frame f-filtro.
    END.
    if esqcom1[esqpos1] = "  Relatorio"
    THEN DO:
        run relatorio.
    END.
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

    def var varquivo as char.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/" + string(setbcod) + "."
                    + string(time).
    else varquivo = "..~\relat~\" + string(setbcod) + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""programa"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """ RELATORIO SEGUROS """ 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

    for each tt-apseguro no-lock:
        
        disp tt-apseguro.apolice         column-label "Produto/Apolice"
                format "x(30)"
      tt-apseguro.processamento   column-label "Processamento"
      tt-apseguro.inicio_vigencia column-label "Inicio"
      tt-apseguro.CPF             column-label "CPF"  format "x(16)"
      tt-apseguro.premio_total(total)    column-label "Premio"
      with frame f-rel width 80 down .

        down with frame f-rel.
    end.
    
    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.

