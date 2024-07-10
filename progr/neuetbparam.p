{admcab.i}
{setbrw.i}                                                                      


def var p-tipo as char.
p-tipo = "NEUROTECH".


def temp-table tt-grupo no-undo
    field tipo as char
    field codigo as int                    label "Codigo"
    field descri as char format "x(30)"    label "Descricao"
    index i1 codigo
    .
    
def temp-table tt-gfil no-undo
    field codigo as int                    label "Codigo"
    field etbcod like estab.etbcod         label "Filial"
    index i1 codigo etbcod.
    

for each agfilcre where agfilcre.tipo = p-tipo no-lock:
    find first tt-grupo where
               tt-grupo.codigo = agfilcre.codigo no-error.
    if not avail tt-grupo
    then do:
        create tt-grupo.
        assign
            tt-grupo.tipo   = agfilcre.tipo
            tt-grupo.codigo = agfilcre.codigo
            tt-grupo.descri = agfilcre.descri
            .
    end.
end.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  ALTERA","  INCLUI","  FILIAIS","  REGRAS"].
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


form tt-grupo.codigo
     tt-grupo.descri format "x(25)"
     with frame f-linha 10 down color with/cyan /*no-box*/
     width 40 overlay
     title " agrupamentos ".
                                                                         
                                                                                
def buffer btbcntgen for tbcntgen.                            
def var i as int.

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
        &file  = tt-grupo  
        &cfield = tt-grupo.codigo
        &noncharacter = /* 
        &ofield = " tt-grupo.descri "  
        &aftfnd1 = " "
        &where  = " true "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  CLASSE""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  esqcom1[esqpos1] = ""  INCLUI"".
                         run aftselect.
                         esqcom1[esqpos1] ="""".
                         if keyfunction(lastkey) = ""END-ERROR""
                            AND NOT CAN-FIND(FIRST TT-GRUPO)
                         THEN LEAVE l1.
                         ELSE next l1.
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
    def var vdescri as char.
    clear frame f-linha1 all.
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo, return:
        scroll from-current down with frame f-linha.
        create tt-grupo.
        tt-grupo.tipo = p-tipo.
        update tt-grupo.codigo
               tt-grupo.descri
               with frame f-linha.
               .
        hide frame f-com1.
        run agfilcre1.p(input tt-grupo.tipo,
                        input tt-grupo.codigo,
                        input tt-grupo.descri).
        view frame f-com1.
        /*
        if keyfunction(lastkey) = "END-ERROR"
        then return.
        */
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
        vdescri = tt-grupo.descri.
        UPDATE tt-grupo.descri with frame f-linha.
        if tt-grupo.descri <> vdescri
        then
        for each agfilcre where agfilcre.tipo = tt-grupo.tipo and 
                                agfilcre.descri = vdescri:
            agfilcre.descri = tt-grupo.descri.
        end. 
    END.
    if esqcom1[esqpos1] = "  FILIAIS"
    then do:
        hide frame f-com1.
        run agfilcre1.p(input tt-grupo.tipo,
                        input tt-grupo.codigo,
                        input tt-grupo.descri).
        view frame f-com1.
    end.
    if esqcom1[esqpos1] = "  REGRAS"
    then do:
       repeat:

        def var cpoliticas as char format "x(40)"
            extent 12 init
            ["P1 - Pre Aprovacao",
             "P2 - Cliente Novo",
             "P3 - Atualizacao de Dados",
             "P4 - Atualizacao Limites",
             "P5 - Autoriza Venda Normal",
             "P6 - Autoriza Saque Facil",
             "P7 - Autoriza Credito Pessoal",
             "P8 - Autoriza Novacao",
             "" ].
        def var vpoliticas as char 
            extent 12 init
            ["P1",
             "P2",
             "P3",
             "P4",
             "P5",
             "P6",
             "P7",
             "P8",
             ""].
        def var epolitica as char.
                         
        disp 
            cpoliticas
                with frame fpoliticas
                no-labels
                overlay
                row 5
                col 20
                title "Politicas".
                
        choose field cpoliticas
            with frame fpoliticas.
            
            
        epolitica = vpoliticas[frame-index].
        hide frame f-com1.
                    
        run neuro/neuparam.p(input tt-grupo.tipo,
                          input tt-grupo.codigo,
                          input tt-grupo.descri,
                          epolitica).
        hide frame fpoliticas no-pause.
       end.
       hide frame fpoliticas no-pause.
                                  
        view frame f-com1.
    end.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        
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
                &Tit-Rel   = """TITULO""" 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.


