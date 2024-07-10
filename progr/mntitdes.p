{admcab.i}

def var vdata as date.
def new shared var vdti  as date.
def new shared var vdtf  as date.
def new shared var vmodcod like modal.modcod.
def new shared var vsetcod like setaut.setcod.
def new shared var vetbcod like estab.etbcod.
def new shared var vforcod like forne.forcod.
def new shared var vfatnum like fatudesp.fatnum format ">>>>>>>>9".
def var vetbfun as int.
def var vfuncod as int.

 
form with frame f1.


do on error undo with frame f1 1 down side-label width 80.
 
    vmodcod = "".
    update vmodcod label "Modalidade".
    if vmodcod <> ""
    then do:
        find modal where modal.modcod = vmodcod no-lock no-error.
        if not avail modal
        then do:
            message "Modalidade nao cadatrada".
            undo, retry.
        end.
        disp modal.modnom no-label with frame f1.
    end.
            
    update vsetcod at 1 label "Setor".
    if vsetcod > 0
    then do:
        find setaut where setaut.setcod = vsetcod no-lock no-error.
        if not avail setaut
        then do:
            message "Setor nao cadastrado".
            undo, retry.
        end.
        disp setaut.setnom no-label with frame f1 .
        pause 0.
    end.
    update vetbcod at 1 label "Filial" .
    if vetbcod > 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            message color red/with
            "Estabelecimento nao cadastrado"
            view-as alert-box.
            undo, retry.
        end.
        disp estab.etbnom no-label.
        pause 0. 
    end.
    update vforcod at 1 label "Fornecedor".
    if vforcod > 0
    then do:
        find forne where 
             forne.forcod = vforcod no-lock no-error.
        if not avail forne
        then do:
            undo, retry.
        end.     
        disp forne.fornom no-label.
        pause 0.
    end.
    update vfatnum at 1 label "Numero".
    
    update vdti at 1 label "Pagamento de" format "99/99/9999"
           vdtf label "Ate" format "99/99/9999".
    if vdti = ? or vdtf = ?
    then undo, retry .
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
    initial ["","  ALTERA MODAL","  Altera setor","",""].
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


form 
     with frame f-linha 10 down color with/cyan /*no-box*/
     centered.
                                                                         
/*                                                                                
disp "                  INCLUSAO SERIAIS - ESN/IMEI       " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
*/

def buffer btbcntgen for tbcntgen.                            
def var i as int.

def temp-table tt-titulo like titulo.
def var vdata1 as date.

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
        &file =  titudesp 
        &cfield = titudesp.titnum
        &noncharacter = /* 
        &ofield = " 
                    titudesp.titpar 
                    titudesp.clifor
                    titudesp.titdtemi 
                    titudesp.titdtpag
                    titudesp.titvlpag format "">>>,>>9.99""
                    titudesp.modcod column-label ""ModD""
                    titudesp.titbanpag column-label ""Set""
                    "   
        &where = " titudesp.empcod = 19 and
                   titudesp.titnat = yes and
                   (if vmodcod <> """"
                   then titudesp.modcod = vmodcod else true) and
                   titudesp.titdtpag >= vdti and
                   titudesp.titdtpag <= vdtf and
                   (if vetbcod > 0
                   then titudesp.etbcod = vetbcod else true) and
                   (if vforcod > 0
                   then titudesp.clifor = vforcod else true) and
                   (if vfatnum > 0
                   then titudesp.titnum = string(vfatnum) else true) and
                   (if vsetcod > 0
                   then titudesp.titbanpag = vsetcod else true)
                 "  
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  CLASSE""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " /*bell.
                        message color red/with
                        ""Nenhum registro encontrado.""
                        view-as alert-box.
                        leave l1.
                        */
                        run mntitdes-cne.p.
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
    clear frame f-linha1 all.
    def buffer etitudesp for titudesp.
    if esqcom1[esqpos1] = "  ALTERA MODAL"
    THEN DO on error undo:
        /*run mntitdes01.p(recid(tt-titulo)).
        */
        prompt-for titudesp.modcod with frame f-linha.
        find first etitudesp where
                   etitudesp.empcod = titudesp.empcod and
                   etitudesp.titnat = titudesp.titnat and
                   etitudesp.modcod = input frame f-linha titudesp.modcod and
                   etitudesp.etbcod = titudesp.etbcod and
                   etitudesp.clifor = titudesp.clifor and
                   etitudesp.titnum = titudesp.titnum and
                   etitudesp.titpar = titudesp.titpar
                   no-lock no-error.
        if avail etitudesp
        then titudesp.titpar = titudesp.titpar + 1.
        
        titudesp.modcod = input frame f-linha titudesp.modcod.           

    END.
    if esqcom1[esqpos1] = "  ALTERA setor"
    THEN DO on error undo:
        UPdate titudesp.titbanpag with frame f-linha no-validate.
    END.

    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
    
    END.
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

