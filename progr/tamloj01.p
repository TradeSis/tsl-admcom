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
    initial ["","  Inclui","  Altera","  Exclui","Relatorio"].
def var esqcom2         as char format "x(26)" extent 3
            initial ["","Classes distribui","  Tipos distribui"].
def var esqhel1         as char format "x(12)" extent 5
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
                 centered
                 .
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

def var vfiliais as char .
form 
     tamloja.tamanho  column-label "Tamanho" format "x(3)"
     tamloja.limite   column-label "Limite"  format ">>>>>9"
     /*vfiliais format "x(67)" column-label "Filiais"
     */
     with frame f-linha 7 down color with/cyan /*no-box*/
     centered.
                                                                         
                                                                                
disp "                             PARAMETROS DE DISTRIBUICAO      " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.
def var vcatcod like tamloja.catcod.
update vcatcod label "Categoria"
    with frame f0 1 down width 80 side-label.
find categoria where categoria.catcod = vcatcod no-lock.
disp categoria.catnom no-label with frame f0.

def temp-table tt-tamloja like tamloja.
def var fil-limite as int.
def var fil-enquadra as int.

if vcatcod = 31
then assign
        esqcom2[2] = "Associa Filiais"
        esqcom2[3] = ""
        .
l1: repeat :
    
    clear frame f-com1 all.
    clear frame f-com2 all.
    
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    hide frame f-linha no-pause.
    clear frame f-linha all.
    view frame f1.
    view frame f2.
    fil-limite = 0.
    for each tamloja no-lock:
        fil-limite = fil-limite + tamloja.limite.
    end. 
    /**
    fil-enquadra = 0.
    for each etbtam where etbtam.catcod = vcatcod and
                          etbtam.situacao = "E"
                          no-lock.
        fil-enquadra = fil-enquadra + 1.
    end.
    **/
    disp "Limite: " string(fil-limite)
         /*"         Filiais: " string(fil-enquadra)
         */
         with frame f-tot row 19 1 down no-box no-label.
    pause 0.                          
    
    {sklclstb.i  
        &color = with/cyan
        &file = tamloja     
        &cfield = tamloja.tamanho
        &noncharacter = /* 
        &ofield = " tamloja.limite "  
        &aftfnd1 = "  "
        &where  = " tamloja.catcod = vcatcod  "
        &aftselect1 =  " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  Tipos Distribui"" or
                           esqcom2[esqpos2] = ""classes distribui"" or
                           esqcom1[esqpos1] = ""Relatorio"" or
                           esqcom2[esqpos2] = ""Associa filiais""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " run inclui. 
                        hide frame f-inclui no-pause.
                        if keyfunction(lastkey) = ""end-error""
                        then leave l1.
                        else next l1. "
         
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
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo:
        run inclui.
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
        run altera.    
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        run exclui.    
    END.
    if esqcom1[esqpos1] = "Relatorio"
    THEN DO:
        run relatorio.    
        view frame fc1.
        view frame fc2.
    END.
    if esqcom2[esqpos2] = "Classes distribui"
    THEN DO:
        hide frame f-tot.
        run cladis01.p(input vcatcod).
    END.

    if esqcom2[esqpos2] = "  Tipos distribui"
    THEN DO:
        hide frame f-tot.
        run tipdis01.p(input vcatcod).
    END.
    if esqcom2[esqpos2] = "Associa Filiais"
    THEN DO:
        hide frame f-tot.
        run filtam02.p(input vcatcod, tamloja.tamanho).
    END.
    if esqcom2[esqpos2] = "outras opcoes"
    THEN DO :
        hide frame f-tot.
        run outras-opcoes.
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
                    do ve = 1 to 3:
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
                    esqpos2 = if esqpos2 = 3 then 3 else esqpos2 + 1.
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

    def buffer btamloja for tamloja.
    def var varquivo as char.
    def var v-filis as char.
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/tamloja." + string(time).
    else varquivo = "..~\relat~\tamloja." + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""tamloj01"" 
                &Nom-Sis   = """SISTEMA COMERCIAL""" 
                &Tit-Rel   = """ FILIAIS POR TAMANHO """ 
                &Width     = "80"
                &Form      = "frame f-cabcab"}
    fil-limite = 0.
    fil-enquadra = 0.
    for each btamloja no-lock:
        
        vfiliais = "".
        fil-limite = fil-limite + btamloja.limite.
        for each etbtam where etbtam.catcod  = btamloja.catcod and
                                  etbtam.tamanho = btamloja.tamanho and
                                  etbtam.situacao = "E"
                                  no-lock by etbtam.etbcod.
                vfiliais = vfiliais + string(etbtam.etbcod) + "-".
                fil-enquadra = fil-enquadra + 1.
        end.
        disp btamloja.tamanho column-label "Tamanho"
             btamloja.limite column-label "Limite"
             vfiliais format "x(64)" column-label "Filiais"
             with frame f-disp down width 82.
        down with frame f-disp.     
    end. 
    put fill("-",100) format "x(80)" skip.
    
    put "Limite: " string(fil-limite)
         "         Filiais: " string(fil-enquadra) skip.
    
    output close.
    
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
    
end procedure.

procedure inclui:
    do on error undo with frame f-inclui 1 down centered row 8
            1 column.
        for each tt-tamloja.
            delete tt-tamloja.
        end.
        create tt-tamloja.
        tt-tamloja.catcod = vcatcod.
        update tt-tamloja.tamanho label "Tamanho".
        tt-tamloja.tamanho = caps(tt-tamloja.tamanho).
        disp tt-tamloja.tamanho.
        update tt-tamloja.limite .

        create tamloja.
        buffer-copy tt-tamloja to tamloja.
    end.
    hide frame f-inclui no-pause.
end.            
procedure altera:
    do on error undo with frame f-altera 1 down centered row 8
            1 column.
        for each tt-tamloja.
        delete tt-tamloja.
        end.
        create tt-tamloja.
        buffer-copy tamloja to tt-tamloja.
        disp tt-tamloja.tamanho label "Tamanho".
        update tt-tamloja.limite.

        buffer-copy tt-tamloja to tamloja.
    end.

end procedure.
procedure exclui:
    do on error undo with frame f-exclui 1 down centered row 8
            1 column.
        /****
        find first expcapacidade where
                   expcapacidade.codexpositor = expositor.codexpositor
                   no-lock no-error.
        if avail expcapacidade
        then do:
            message color red/with
            "Expositor com capacidade cadatrada." skip
            "Impossivel excluir."
            view-as alert-box.
        end.           
        else***/  do:
            sresp = no.
            message "Confirma excluir?" update sresp.
            if sresp then delete tamloja.
        end.  
    end.

end procedure.

procedure outras-opcoes:
    def var vop as char format "x(30)" extent 2.
    vop[1] = "Classes para Distribuicao".
    vop[2] = "Enquadra Filiais a Tamanho".
    disp vop with frame f-op 1 down centered row 8
        1 column no-label.
    choose field vop with frame f-op.
    if frame-index = 1
    then do:
        run cladis01.p(input vcatcod).
    end.
    else if frame-index = 2    
    THEN DO :
        hide frame f-tot.
        run filtam01.p(input vcatcod).
    END.

end procedure.
