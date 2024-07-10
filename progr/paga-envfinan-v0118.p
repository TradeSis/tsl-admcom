{admcab.i}

/*update vetbcod like estab.etbcod label "Filial"
        with frame f1 width 80 side-label.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.
end. */

def var v-pago as dec.

update vdti as date  at 1 label "Data Inicial"
       vdtf as date       label "Data Final"
       with frame f1 width 80 side-label. 

def var vdata as date.
def temp-table tt-titulo like titulo.
def var vt-pagamento as dec.
def var vt-envfinan  as dec.
def var vparcela like titulo.titpar.
def var vparcial as log.
do vdata = vdti to vdtf:
    for each titulo where titulo.titnat = no and
                          titulo.titdtpag = vdata
                          no-lock:
        if titulo.titpar = 0 then next.
        vparcela = titulo.titpar.
        vparcial = no.
        run retorna-titpar-financeira.p(input recid(titulo),
                                        input-output vparcela,
                                        output vparcial).
        if titulo.titpar > 30 and vparcela < 30
        then vparcela = titulo.titpar. 
        find first envfinan where
                   envfinan.empcod = titulo.empcod and
                   envfinan.titnat = titulo.titnat and
                   envfinan.modcod = titulo.modcod and
                   envfinan.etbcod = titulo.etbcod and
                   envfinan.clifor = titulo.clifor and
                   envfinan.titnum = titulo.titnum and
                   envfinan.titpar = vparcela /*titulo.titpar*/
                   no-lock no-error.
        if avail envfinan and (envfinan.envsit = "PAG" or
                               envfinan.envsit = "INC")
        then do:
            v-pago = 0.
            if titulo.titvlpag <= titulo.titvlcob - titulo.titdes
            then v-pago = titulo.titvlpag.
            else v-pago = titulo.titvlcob - titulo.titdes.
 
            vt-pagamento = vt-pagamento + v-pago.
            if envfinan.envsit = "PAG"
            then vt-envfinan = vt-envfinan + v-pago.
            else do:
                create tt-titulo.
                buffer-copy titulo to tt-titulo.
            end.
        end.           
    end.
end.    
def var vdifer as dec.
vdifer = vt-pagamento - vt-envfinan.
disp vt-pagamento label "Vl.Pago"      format ">>>,>>>,>>9.99"
     vt-envfinan  label "Vl.Enviado"   format ">>>,>>>,>>9.99"
     vdifer label "Difer."     format "->>,>>>,>>9.99"
     with frame f2 side-label width 80
     .

if vdifer = 0
then do:
    pause.
    return.
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
     with frame f-linha row 9 down color overlay
     centered title " Parcelas não enviadas ".
                                                                         
                                                                                
def buffer btbcntgen for tbcntgen.                            
def var i as int.

l1: repeat:
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file  = tt-titulo  
        &cfield = tt-titulo.modcod
        &noncharacter = /* 
        &ofield = " 
                    tt-titulo.modcod
                    tt-titulo.etbcod 
                    tt-titulo.titnum
                    tt-titulo.titpar
                    tt-titulo.titvlcob
                    tt-titulo.titsit
                    tt-titulo.titvlpag
                       "
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
        &naoexiste1 = "  " 
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


for each tt-titulo.
    disp tt-titulo.modcod
         tt-titulo.etbcod 
         tt-titulo.titnum
         tt-titulo.titpar
         tt-titulo.titvlcob
         tt-titulo.titsit.   
end.
