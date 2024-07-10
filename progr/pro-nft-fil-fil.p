{admcab.i new}

def var vetbcod like estab.etbcod.       
       
def temp-table ttestoq like estoq.
def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.

def var v-nota as int.
def var vnfs as int.

def buffer cplani for plani.
def buffer bplani for plani.
def buffer dplani for plani.

def buffer cplani1 for plani.
def buffer bplani1 for plani.
def buffer dplani1 for plani.


def var vplacod like plani.placod.
def var vnumero like plani.numero.
def var vserie like plani.serie.
def var vprotot like plani.protot.
def var vmovseq like movim.movseq.

def var vetb-desti like estab.etbcod.

form vetb-emit like estab.etbcod label "Filial emitente"
     vetb-dest like estab.etbcod label "Filial destino"
     vnumnf    like plani.numero label "Numero NF" format ">>>>>>>>9"
     with frame f-id  1 down width 80 side-label
     title "Informações da Nota Fiscal original" 
      .

vetb-dest = setbcod.

update vetb-emit 
       vetb-dest
       vnumnf with frame f-id.

if vetb-dest <> setbcod and setbcod <> 999
then undo.

find first plani where plani.movtdc = 6 and
                       plani.emite = vetb-emit and
                       plani.desti = vetb-dest and
                       plani.numero = vnumnf
                       no-lock no-error.
if not avail plani
then do:
    bell.
    message color red/with
    "Nota Fiscal não encontrada."
    view-as alert-box.
    undo.
end.
for each tt-plani: delete tt-plani. end.
for each tt-movim: delete tt-movim. end.

create tt-plani.
buffer-copy plani to tt-plani.
def var vtotal like plani.platot .    
vtotal = 0.
for each movim where movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.movtdc = plani.movtdc
                     no-lock:
    create tt-movim.
    buffer-copy movim to tt-movim.
    vtotal = vtotal + (tt-movim.movpc * tt-movim.movqtm).           
end.
    

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
    initial ["","  INCLUI","","",""].
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


assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.


form 
     with frame f-linha down color with/cyan /*no-box*/
     column 30.
                                                                         
             
def buffer n-estab for estab.
def buffer btbcntgen for tbcntgen.                            
def var i as int.
def var n-destino like estab.etbcod.

disp plani.platot label "Total Nota "
     vtotal     at 1  label "Total itens"
     with frame f-tot side-label.
     
l1: repeat:
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = tt-movim  
        &cfield = tt-movim.procod
        &noncharacter = /* 
        &ofield = " tt-movim.movqtm
                    tt-movim.movpc "  
        &where  = " true "
        &aftselect1 = " run aftselect.
                        "
        &go-on = TAB 
        &naoexiste1 = " bell.
                        message color red/with
                        ""Nenhum registro encontrado.""
                        view-as alert-box.
                        leave l1.
                        " 
        &otherkeys1 = " run controle. "
        &locktype = " "
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO on error undo:
        message "Novo destino" update n-destino.
        find n-estab where n-estab.etbcod = n-destino no-lock no-error.
        if not avail estab
        then undo.
        
        for each tt-plani:
            assign
                tt-plani.pladat = today
                tt-plani.datexp = today
                tt-plani.dtinclu = today
                tt-plani.etbcod = setbcod
                tt-plani.emite  = tt-plani.desti
                tt-plani.desti  = n-destino
                tt-plani.placod = ?
                tt-plani.numero = ?
                tt-plani.serie = "1"
                .
        end.
        for each tt-movim:
            assign
                tt-movim.etbcod = setbcod
                tt-movim.emite  = tt-movim.desti
                tt-movim.desti  = n-destino
                tt-movim.placod = ?
                tt-movim.movdat = today
                tt-movim.datexp = today
                .
        end.
                            
        sresp = no.
        
        message "Confirma Autorizar NFe?" update sresp.
        if sresp
        then do:
            run emissao-NFe.
        end. 
        leave l1.       

    END.
end.

hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.

procedure aftselect:
    clear frame f-linha1 all.

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

procedure emissao-NFe:
    def var p-ok as log init no.
    def var p-valor as char.
    p-valor = "".
    def var nfe-emite like plani.emite.
    if setbcod = 998
    then nfe-emite = 993.
    else nfe-emite = setbcod.
    run le_tabini.p (nfe-emite, 0,
            "NFE - TIPO DOCUMENTO", OUTPUT p-valor) .
    if p-valor = "NFE"
    then do:
        run manager_nfe.p (input "5152",
                           input ?,
                           output p-ok).
    end.
end procedure.
