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
    initial ["","  INCLUI","  EXCLUI","  LIBERA VENDA","  PROCURA"].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","  FILIAL","","",""].
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5.

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
    esqpos1  = 2
    esqpos2  = 2.
/*
def temp-table tt-tbprice like tbprice.
*/
form " " 
    tbprice.serial
    help "Digite o SERIAL(ESN/IMEI) do aparelho celular."
    tbprice.etb_venda    format ">>9"   column-label "Filial"
    tbprice.nota_venda   format ">>>>>>>9" column-label "Venda"
    tbprice.data_venda    format "99/99/99" column-label "Data Venda"
     " "
     with frame f-linha 11 down color with/cyan /*no-box*/
     width 80.
                                                                         
                                                                                
disp "                  INCLUSAO SERIAIS - ESN/IMEI       " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.
def var vserial like tbprice.serial.
def var vetbcod like estab.etbcod.
vetbcod = setbcod.

l1: repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        .
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = tbprice  
        &cfield = tbprice.serial
        &ofield = " tbprice.etb_venda 
                    tbprice.nota_venda
                    tbprice.data_venda "  
        &aftfnd1 = " "
        &where  = " tbprice.etb_venda = vetbcod "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  CLASSE""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " esqpos1 = 2. 
                        run aftselect.
                        if keyfunction(lastkey) = ""END-ERROR""
                        then leave l1.
                        if vetbcod <> tbprice.etb_venda
                        then next l1.
                        a-seeid = -1.
                        if keyfunction(lastkey) = ""END-ERROR""
                        then leave l1.
                        else next l1.
                        "
        &otherkeys1 = " run controle. "
        &locktype = " NO-LOCK "
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
    def var vok as log. 
    def buffer btbprice for tbprice.
    clear frame f-linha1 all.

    if esqcom1[esqpos1] = "  INCLUI"
    THEN repeat on endkey undo, leave with frame f-linha:
        scroll from-current down with frame f-linha.
        do on error undo:
            create tbprice.
            tbprice.etb_venda = setbcod.
            update tbprice.serial .
            vok = yes.
            run veresnimei.p(input tbprice.serial, output vok).
       
        /* if not vok
        then do:
            message color red/with
                "SERIAL invalido."  view-as alert-box.
            undo.        
        end. */
        
            find first btbprice where
                   btbprice.serial = tbprice.serial no-lock no-error.
            if avail btbprice
            then do:
                message color red/with 
                    "Serial ja cadastrado." view-as alert-box.
                disp btbprice.etb_venda @ tbprice.etb_venda 
                     btbprice.nota_venda @ tbprice.nota_venda
                     btbprice.data_venda @ tbprice.data_venda 
                     with frame f-linha.
                pause. 
                disp "" @ tbprice.etb_venda 
                     "" @ tbprice.nota_venda
                     "" @ tbprice.data_venda 
                     with frame f-linha.
                undo.
            end. 
            tbprice.char3 = tbprice.char3 +
                            "FILIAL=" + string(setbcod,"999") + "|".     
        /**
        create tbprice.
        buffer-copy tt-tbprice to tbprice.
        **/
        end.          
    END.

    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
    
    END.

    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        if tbprice.nota_venda > 0
        then
            message color red/with
                "Serial com venda associada." skip
                "Exclusao nao permitida."
                 view-as alert-box.
        else do:
            sresp = no.
            message "Confirma excluir registro? " update sresp.
            if sresp
            then do ON ERROR UNDO:
                find current tbprice.
                delete tbprice.
            end.
        end.
    END.
    if esqcom1[esqpos1] = "  LIBERA VENDA"
    THEN DO:
        def var vsenha as char format "x(10)".
        update vsenha blank label "Senha"
            with frame f-senha centered side-labels.           
        hide frame f-senha no-pause.

        if vsenha = "price08"
        then do:
            if tbprice.nota_venda > 0
            then do:
                sresp = no.
                message color red/with
                    "Serial com venda associada." skip
                    "Confirma liberar venda?"
                     update sresp.
                if sresp
                then do ON ERROR UNDO:
                    find current tbprice exclusive.
                    assign
                        /*tbprice.etb_venda = 0*/
                        tbprice.nota_venda = 0
                        tbprice.data_venda = ?
                        tbprice.venda_efetiva = 0.
                end.     
            end.
        end.
    END.

    if esqcom1[esqpos1] = "  PROCURA"
    THEN DO:
        update vserial with frame f-procura 1 down centered side-label
            overlay row 10.
        find first tbprice where serial = vserial no-lock no-error.
        if avail tbprice
        then a-recid = recid(tbprice).
        
    END.

    if esqcom2[esqpos2] = "  FILIAL"
    THEN DO on error undo:
        update vetbcod with frame f-etb 1 down
            side-label centered.
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

