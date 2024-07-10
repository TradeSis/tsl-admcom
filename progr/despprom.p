{admcab.i}
def var vdti as date.
def var vdtf as date.
def var vforcod like forne.forcod.
def temp-table tt-titluc like titluc.
def var vetbcod like estab.etbcod.

update vetbcod at 5 label "Filial" with frame f-data.
if vetbcod > 0
then do:
find estab where estab.etbcod = vetbcod no-lock.
disp estab.etbnom no-label with frame f-data.
end.
update vforcod at 1 label "Fornecedor"
       with frame f-data 1 down width 80 side-label.
       
find first foraut where foraut.forcod = vforcod no-lock.
disp foraut.fornom no-label with frame f-data.

update vdti label "Periodo de" format "99/99/9999"
       vdtf label "Ate"        format "99/99/9999"
       with frame f-data.

def temp-table tt-estab
    field etbcod like estab.etbcod
    field data   as date
    field valor  as dec
    index i1 etbcod data.
    
def var vcatcod like produ.catcod.
def var vvalor as dec.
def var vdata as date.
do vdata = vdti to vdtf:
    for each titluc where  titluc.empcod = 19 and
                           titluc.titnat = yes and
                           titluc.modcod = "COM" and
                           titluc.titdtemi = vdata and
                           (if vetbcod > 0
                            then titluc.etbcod = vetbcod else true)
                           no-lock.
        vvalor = titluc.titvlcob.
        disp "Processando ... ==>> " vdata titluc.etbcod titluc.titnum no-label
            with frame f-proc 1 down centered row 10
            no-box no-label.
        pause 0.    
        if titluc.clifor = 110657
        then do:
            find plani where plani.etbcod = titluc.etbcod and
                         plani.emite  = titluc.etbcod and
                         plani.serie  = "V" and
                         plani.numero = int(titluc.titnum)
                         no-lock no-error.
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat
                                 no-lock:
                find produ where produ.procod = movim.procod no-lock.
                vcatcod = produ.catcod.
            end.                         
        end. 
        if vforcod = 110839 and vcatcod <> 31
        then vvalor = 0.
        if vvalor > 0
        then do:
            find first tt-estab where 
                       (if vetbcod = 0 
                        then tt-estab.etbcod = titluc.etbcod
                        else tt-estab.data   = titluc.titdtven
                        ) no-error.
            if not avail tt-estab
            then do:
                create tt-estab.
                if vetbcod = 0
                then tt-estab.etbcod = titluc.etbcod.
                else do:
                    tt-estab.etbcod = vetbcod.
                    tt-estab.data   = titluc.titdtven.
                end.
            end.
            tt-estab.valor = tt-estab.valor + vvalor.     
                        
            create tt-titluc.
            buffer-copy titluc to tt-titluc.
        end.                        
    end.
end.

hide frame f-proc no-pause.

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
    initial [""," IMPRESSAO","","",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["teste teste",
             "",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial [" ",
            " ",
            " ",
            " ",
            " "].

form
    esqcom1
    with frame f-com1
                 row 8 no-box no-labels side-labels column 1 centered.
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
     tt-estab.etbcod
     estab.etbnom no-label
     tt-estab.data
     tt-estab.valor
     with frame f-linha row 9 9 down color with/cyan /*no-box*/
     centered.
                                                                                
def buffer btbcntgen for tbcntgen.                            
def var i as int.
def var vtotal as dec.
for each tt-estab:
    vtotal = vtotal + tt-estab.valor.
end.    
disp "Total .... ==>>"  vtotal 
with frame f-tot row 22 no-label column 40 no-box.
l1: repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    pause 0.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = tt-estab  
        &cfield = tt-estab.etbcod
        &noncharacter = /* 
        &ofield = "     estab.etbnom  when avail estab
                        tt-estab.data when tt-estab.data <> ?
                        tt-estab.valor "  
        &aftfnd1 = " 
                    find estab where estab.etbcod = tt-estab.etbcod
                                no-lock no-error.
                    "
        &where  = " "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  CLASSE""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " message color red/with
                        ""Nenhum registro encontrado. ""
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
    if esqcom1[esqpos1] = " IMPRESSAO"
    THEN DO on error undo:
        message "Confirma Imprimir ? " update sresp.
        if sresp then RUN impressao.
        
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

procedure impressao:
    def var varquivo as char.
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/despprom." + string(time).
    else varquivo = "l:\relat\despprom." + string(time).

    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""despprom"" 
                &Nom-Sis   = """SISTEMA FINANCEIRO""" 
                &Tit-Rel   = """ DESPESAS FINANCEIRAS """ 
                &Width     = "80"
                &Form      = "frame f-cabcab"}
    disp with frame f-data.
    for each tt-estab use-index i1:
        find estab where estab.etbcod = tt-estab.etbcod no-lock.
        disp tt-estab.etbcod
             estab.etbnom no-label
             tt-estab.data
             tt-estab.valor(total)
             with frame f-disp down.
        down with frame f-disp.
    end.
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    elsE do:
       {mrod.i}
    end.
end.