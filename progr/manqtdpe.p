{admcab.i}
{setbrw.i}  
def input parameter p-recid as recid.
find pedid where recid(pedid) = p-recid .
def var vcan as log.
 
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  ALTERA","  PRODUTO","",""].
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

def var vprocod like produ.procod. 

form " " 
     liped.pednum column-label "Pedido"
     liped.procod column-label "Produto"
     produ.pronom no-label format "x(30)"
     liped.lipqtd column-label "Qtd"
     liped.predt
     /*liped.predtf*/
     " "
     with frame f-linha 10 down color with/cyan /*no-box*/
     centered overlay.
                                                                         
                                                                                
disp "                    MANUTENCAO EM QUANTIDADE PEDIDA " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
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
        &file =  liped 
        &cfield = liped.procod
        &noncharacter = /* 
        &ofield = " liped.pednum 
                    produ.pronom when avail produ 
                    liped.lipqtd 
                    liped.predt
                    /*liped.predtf*/ "  
        &aftfnd1 = " 
            find produ where produ.procod = liped.procod no-lock no-error.
                "
        &where  = " liped.pedtdc  = pedid.pedtdc and
                     liped.etbcod = pedid.etbcod and
                     liped.pednum = pedid.pednum and
                     liped.lipsit = ""Z""   
                     no-lock
                    "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  PRODUTO""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  bell.
                        message color red/with
                        ""Nenhum pedido pendente""
                        view-as alert-box.
                        leave l1.
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
    def var vlipqtd like liped.lipqtd.
    def var vok as log.
    clear frame f-linha1 all.
    def buffer bliped for liped.
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo:
        
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
        /**
        run psenauto.p(output vok).
        if vok = no
        then do:
            message "Alteracao nao permitida.Senha Invalida".
            pause 2 no-message.
            next.
        end.
        **/
        vlipqtd = liped.lipqtd.
        do on error undo transaction:
            update liped.lipqtd with frame f-linha with no-validate.
            if liped.lipqtd > vlipqtd
            then undo, retry.
        end.
        vcan = yes.
        for each bliped of pedid no-lock:
            if bliped.lipqtd > 0
            then vcan = no.
        end.    
        if vcan = yes
        then do transaction:
            pedid.sitped = "F".
        end.
    END.
    if esqcom1[esqpos1] = "  PRODUTO"
    THEN DO:
        update vprocod label "Produto"
            with frame f-procura   1 down centered row 10 side-label
                 color message OVERLAY.
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

