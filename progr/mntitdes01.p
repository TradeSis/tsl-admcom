{admcab.i new}

def input parameter p-recid as recid.
find titulo where recid(titulo) = p-recid no-lock no-error.

def var vdata as date.
def var vdti  as date.
def var vdtf  as date.
def var vmodcod like modal.modcod.
def var vsetcod like setaut.setcod.
def var vetbcod like estab.etbcod.
def var vforcod like forne.forcod.
def var vfatnum like fatudesp.fatnum format ">>>>>>>>9".
def var vetbfun as int.
def var vfuncod as int.
 
form with frame f1.

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
    initial ["","  ALTERA","","",""].
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


form " " 
     " "
     with frame f-linha 10 down color with/cyan /*no-box*/
     centered.
                                                                         
                                                                                
disp "                  INCLUSAO SERIAIS - ESN/IMEI       " 
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
        &file =  titudesp 
        &cfield = titudesp.titnum
        &noncharacter = /* 
        &ofield = " 
                    titudesp.titpar 
                    titudesp.titdtemi 
                    titudesp.titdtven
                    titudesp.titdtpag
                    titudesp.titvlpag 
                    titudesp.modcod 
                    titudesp.titbanpag column-label ""Set""
                    "   
        &aftfnd1 = " "
        &where  = " 
                    titudesp.clifor = titulo.clifor and
                    titudesp.titnum = titulo.titnum
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
        &naoexiste1 = " bell.
                        message color red/with
                        ""Nenhum registro encontrato."" 
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



/**************
def var varquivo as char.

varquivo = "/admcom/relat/rfatdes1." + string(time).


{mdad.i &Saida     = "value(varquivo)" 
                        &Page-Size = "64" 
                        &Cond-Var  = "80" 
                        &Page-Line = "64" 
                        &Nom-Rel   = ""tablan"" 
                        &Nom-Sis   = """SISTEMA CONTABILIDADE""" 
                        &Tit-Rel   = """LISTAGEM DESPESAS SETOR"""
                        &Width     = "80"  
                        &Form      = "frame f-cabcab"}
                        .
DISP WITH FRAME F1.                        
def var vtotal-tit as dec. 
for each fatudesp where 
         (if vsetcod > 0 then fatudesp.setcod = vsetcod else true) and
         (if vetbcod > 0 then fatudesp.etbcod = vetbcod else true) and
         (if vforcod > 0 then fatudesp.clicod = vforcod else true) and
         (if vfatnum > 0 then int(fatudesp.fatnum) = vfatnum else true) and
         (if vdti <> ? then fatudesp.inclusao >= vdti else true) and
         (if vdtf <> ? then fatudesp.inclusao <= vdtf else true)
         no-lock:
    find forne where forne.forcod = fatudesp.clicod no-lock.    
    find modal where modal.modcod = fatudesp.modcod no-lock. 
    
    vetbfun = int(acha("FILIAL", fatudesp.char1)).
    vfuncod = int(acha("FUNC", fatudesp.char1)). 
    find first func where 
                   func.etbcod = vetbfun and
                   func.funcod = vfuncod
                   no-lock no-error.

    disp fill("=",80) format "x(80)"
         
         fatudesp.etbcod to 40 label "Filial"
         fatudesp.setcod to 40
         func.funcod to 40 when avail func
         func.funnom no-label when avail func
         fatudesp.modcod to 40 label "Modalidade FIN"
         fatudesp.modctb to 40 label "Modalidade CTB"
         fatudesp.fatnum  to 40
         fatudesp.clicod  to 40
         forne.fornom    no-label
         fatudesp.emissao   to 40
         fatudesp.inclusao  to 40 label "Data Inclusao"
         fatudesp.val-total to 40 label "Valor Total"
         fatudesp.val-icms  to 40 label "Valor ICMS"
         fatudesp.val-ipi   to 40 label "Valor IPI"
         fatudesp.val-acr   to 40 label "Valor Acrescimo"
         fatudesp.val-des   to 40 label "Valor Desconto"
         fatudesp.val-ir    to 40 label "Valor IRRF"
         fatudesp.val-iss   to 40 label "Valor ISS" 
         fatudesp.val-inss  to 40 label "Valor INSS"
         fatudesp.val-pis   to 40 label "Valor PIS" 
         fatudesp.val-cofins to 40 label "Valor COFINS"
         fatudesp.val-csll   to 40  label "Valor CSLL"
         fatudesp.val-liquido to 40 label "Valor Liquido" 
         fatudesp.qtd-parcela to 40 label "Quantidade Parcelas"
         with frame f-disp  side-label
         width 100
             .
    vtotal-tit = 0.
    for each titulo where
             titulo.empcod = 19 and
             /*titulo.titnat = yes and
             titulo.modcod = fatudesp.modcod and*/
             titulo.etbcod = fatudesp.etbcod and
             titulo.clifor = fatudesp.clicod and
             titulo.titnum = string(fatudesp .fatnum) and
             titulo.titdtemi = fatudesp.inclusao
             no-lock break by titulo.titnum by titulo.titpar:
        vtotal-tit = vtotal-tit + titulo.titvlcob.
        if last-of(titulo.titpar)
        then do:
            for each titudesp where
                         titudesp.clifor = fatudesp.clicod and
                         titudesp.titnum = string(fatudesp.fatnum) and
                         titudesp.titpar = titulo.titpar
                         no-lock:
                    disp titudesp.titnum
                         titudesp.titpar
                         titudesp.titdtemi
                         titudesp.titdtven
                         titudesp.modcod
                         titudesp.titvlcob  format ">,>>>,>>9.99"
                         titudesp.etbcod column-label "Fil"
                         titudesp.titbanpag column-label "Set"
                    with frame ftit-t width 100 down
                    .
                    down with frame ftit-t.
            
                end.
                vtotal-tit = 0.
               /*
            disp titulo.titnum
             titulo.titpar
             titulo.titdtemi
             titulo.titdtven
             vtotal-tit  format ">,>>>,>>9.99"
             with frame ftit width 100 down
             .

            down with frame ftit.
            vtotal-tit = 0.
            */
        end.
    end.         
end.             

/*
put skip(60).

page.
*/
put skip(10).

if vfatnum > 0
then do:
    put skip(5).
    for each fatudesp where 
         (if vsetcod > 0 then fatudesp.setcod = vsetcod else true) and
         (if vetbcod > 0 then fatudesp.etbcod = vetbcod else true) and
         (if vforcod > 0 then fatudesp.clicod = vforcod else true) and
         (if vfatnum > 0 then int(fatudesp.fatnum) = vfatnum else true) and
         (if vdti <> ? then fatudesp.inclusao >= vdti else true) and
         (if vdtf <> ? then fatudesp.inclusao <= vdtf else true)
         no-lock:
        find forne where forne.forcod = fatudesp.clicod no-lock.    
        find modal where modal.modcod = fatudesp.modcod no-lock. 
    
    vetbfun = int(acha("FILIAL", fatudesp.char1)).
    vfuncod = int(acha("FUNC", fatudesp.char1)). 
    find first func where 
                   func.etbcod = vetbfun and
                   func.funcod = vfuncod
                   no-lock no-error.

    vtotal-tit = 0.
    for each titulo where
             titulo.empcod = 19 and
             /*titulo.titnat = yes and
             titulo.modcod = fatudesp.modcod and*/
             titulo.etbcod = fatudesp.etbcod and
             titulo.clifor = fatudesp.clicod and
             titulo.titnum = string(fatudesp .fatnum) and
             titulo.titdtemi = fatudesp.inclusao
             no-lock break by titulo.titnum by titulo.titpar:
        vtotal-tit = vtotal-tit + titulo.titvlcob.
        if last-of(titulo.titpar)
        then do:     
        disp 
         fatudesp.etbcod at 1 label "Filial"
         fatudesp.setcod
         func.funcod when avail func
         func.funnom no-label when avail func
         fatudesp.modcod
         modal.modnom no-label 
         fatudesp.fatnum format ">>>>>>>>9"
         fatudesp.clicod
         forne.fornom    no-label
         fatudesp.emissao   
         fatudesp.inclusao  
         with frame f-disp1  side-label
         width 100
             .
        disp titulo.titnum
             titulo.titpar
             titulo.titdtemi
             titulo.titdtven
             vtotal-tit  format ">,>>>,>>9.99"
             with frame ftit1 width 100 down
             .
        down with frame ftit1.
        vtotal-tit = 0.
        put skip(10).
        end.
    end.         
end.  
end.         
OUTPUT CLOSE.
run visurel.p(varquivo,"").
*****************/       
