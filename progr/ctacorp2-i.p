{admcab.i} 

{ajusta-rateio-venda-def.i new}

{setbrw.i}                                                                      
{seltpmo.i " " "PREMIO"}
def temp-table tt-contacor like contacor.

def var vsitbiss as char.

def temp-table tt-previa
    field etbcod like estab.etbcod
    field funcod like estab.etbcod
    field funnom as char
    field meta as dec
    field meta-31 as dec
    field meta-41 as dec
    field venda as dec
    field venda-31 as dec
    field venda-41 as dec
    field premio like titluc.titvlcob
    field libera as log format "Lib/Blo"
    index i1 etbcod funcod.

def buffer ztt-previa for tt-previa.

def temp-table tt-modal
    field modcod like foraut.modcod.

def buffer bmodgru for modgru.
def buffer bfunc for func.

find first modgru where modgru.modcod = "PEM" and
        modgru.mogsup = 0
        no-lock no-error.
if avail modgru
then for each bmodgru where 
              bmodgru.mogsup = modgru.mogcod  no-lock:
        create tt-modal.
        tt-modal.modcod = bmodgru.modcod.
    end.                        
/** 
for each foraut no-lock:
    find first tt-modal where
               tt-modal.modcod = foraut.modcod 
               no-error.
    if not avail modal
    then do:
        create tt-modal.
        tt-modal.modcod = foraut.modcod.
    end.           
end.
**/
find first tt-modal where tt-modal.modcod = "COM" no-error.
if not avail tt-modal
then do:
    create tt-modal.
    tt-modal.modcod = "COM".
end.
find first tt-modal where tt-modal.modcod = "PBM" no-error.
if not avail tt-modal
then do:
    create tt-modal.
    tt-modal.modcod = "PBM".
end. 
find first tt-modal where tt-modal.modcod = "PBC" no-error.
if not avail tt-modal
then do:
    create tt-modal.
    tt-modal.modcod = "PBC".
end.     

def buffer bestab    for estab.
def buffer bcontacor for contacor. 


def var v-tem-parc-atraso as logical. 
def var v-tem-cont-ativo  as logical.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  Inclui","  Altera","  Exclui",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","  Libera","  Previa","",""].
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
def var vfunnom like func.funnom.

form contacor.etbcod    column-label "Fil"
     contacor.funcod    column-label "Func"
     vfunnom        no-label  format "x(19)"
     contacor.setcod    column-label "Set"
     contacor.clifor    column-label "Forne" format ">>>>>>>>>9"
     contacor.datemi    column-label "Pagto" format "99/99/99"
     contacor.datven    no-label                 format "99/99/99"
     contacor.datpag    no-label                 format "99/99/99"
     contacor.sitcor    column-label "Sit"   format "x(3)"
     with frame f-linha 10 down color with/cyan /*no-box*/
         width 80.
                                                                                
disp space(20) "LIBERACAO PAGAMENTO DE PREMIOS" space(20)  
           with frame f1 1 down centered width 80                                         color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.
def var v-aux-numcor as int.

l1: repeat:
    clear frame f-com1 all.
    clear frame f-com2 all.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file =  contacor 
        &cfield = contacor.etbcod
        &noncharacter = /* 
        &ofield = " contacor.funcod
                    vfunnom  
                    contacor.setcod 
                    contacor.clifor
                    contacor.datemi
                    contacor.datven
                    contacor.datpag
                    contacor.sitcor    
                           "  
        &aftfnd1 = " find func where func.etbcod = contacor.etbcod and
                                     func.funcod = contacor.funcod
                        no-lock no-error. 
                     if avail func 
                     then vfunnom = func.funnom.
                     else vfunnom = acha(""PREMIO"",contacor.campo3[2]). 
                     if vfunnom = ? then vfunnom = "" "".
                     find setaut where setaut.setcod = contacor.setcod
                        no-lock no-error.
                        "
        &where  = " contacor.sitcor <> ""EXC"" and
                    contacor.natcor = yes and
                    contacor.clifor <> ? and
                    contacor.modcod = ""LPF""  "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  Exclui"" or
                           esqcom1[esqpos1] = ""  Altera""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " run inclui.
                if keyfunction(lastkey) = ""end-error""
                then leave l1. 
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
    if esqcom2[esqpos2] = "  Libera"
    THEN DO:
        run libera("libera").
    END.
    if esqcom2[esqpos2] = "  Previa"
    THEN DO:
        run libera("previa").
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

procedure inclui:
    def var setbcod-ant like estab.etbcod. 
    def var vmeta as log format "Sim/Nao".
    def var dti-venda as date format "99/99/9999".
    def var dtf-venda as date format "99/99/9999".
    for each tt-contacor.
        delete tt-contacor.
    end.    
    setbcod-ant = setbcod.
    do on error undo, retry:
        v-tipodes = "".
        run d-tipo-sel.
        if keyfunction(lastkey) = "END-ERROR"
        THEN v-tipodes = "". 
        if v-tipodes = ?
        then v-tipodes = "".
        hide frame f-inclui.
        create tt-contacor.
        update tt-contacor.etbcod at 1 label "Filial"
               with frame f-inclui 1 down centered row 09 
               /*color message*/ side-label overlay
               title "  Incluir  " + v-tipodes + " ".
        if tt-contacor.etbcod > 0
        then do:
            find bestab where bestab.etbcod = tt-contacor.etbcod
                    no-lock.
            setbcod = tt-contacor.etbcod.            
            update tt-contacor.funcod at 1 label "Consultor" 
                        with frame f-inclui.
            if tt-contacor.funcod > 0
            then do:
                find func where func.etbcod = tt-contacor.etbcod and
                        func.funcod = tt-contacor.funcod
                    no-lock.
                disp func.funnom no-label with frame f-inclui .
            end.
        end.
        setbcod = setbcod-ant.
        update tt-contacor.clifor at 1 label "Fornecedor" with frame f-inclui.
        if tt-contacor.clifor > 0
        then do:
            find first foraut where
                 foraut.forcod = tt-contacor.clifor no-lock .
            disp foraut.fornom no-label with frame f-inclui.     
            tt-contacor.setcod = foraut.setcod.     
        end.
        else update tt-contacor.setcod at 1 label "Setor" with frame f-inclui.
        if tt-contacor.setcod > 0
        then do:
            find setaut where setaut.setcod = tt-contacor.setcod
                    no-lock.
            disp setaut.setnom no-label with frame f-inclui.
        end.
        tt-contacor.datemi = today.
        update tt-contacor.datemi at 1 label "Data Inicio do pagamento"  
                format "99/99/9999"
                with frame f-inclui.
            
        update tt-contacor.datven at 1 label "Liberar Periodo de"
                    format "99/99/9999"
               tt-contacor.datpag      label "Ate"  format "99/99/9999"
                 with frame f-inclui. 
        
        find last contacor  use-index ndx-7 where 
                  contacor.etbcod = tt-contacor.etbcod 
                  no-lock no-error.
        if not avail contacor
        then tt-contacor.numcor = tt-contacor.etbcod * 10000000.
        /* antonio */
        else do:
             assign v-aux-numcor = contacor.numcor + 1.
             repeat:
                find first bcontacor where bcontacor.numcor = v-aux-numcor
                    no-lock no-error.
                if avail bcontacor
                then do:
                    v-aux-numcor = v-aux-numcor + 1.
                    next.
                end.
                tt-contacor.numcor = v-aux-numcor.
                leave.
             end.
        end.
        update vmeta at 1 label "Validar Meta?"
            with frame f-inclui.
        
        /**/
        tt-contacor.sitcor = "BLO".
        tt-contacor.natcor = yes.
        if tt-contacor.clifor = ? then tt-contacor.clifor = 0.
        tt-contacor.modcod = "LPF".
        if vmeta
        then tt-contacor.campo3[1] = "VALIDAR-META=SIM|".
        else tt-contacor.campo3[1] = "VALIDAR-META=NAO|". 
        
        if vmeta
        then do:
            update dti-venda at 1 label "Periodo de Venda de"
                   dtf-venda label "Ate"
                   with frame f-inclui.
            if dti-venda = ? or
                dtf-venda = ? or
                dti-venda > dtf-venda
            then do:
                message color red/with
                    "Periodo de venda incorreto."
                    view-as alert-box.
                undo, retry.    
            end.
        
            tt-contacor.campo3[1] = tt-contacor.campo3[1] +
              "DTI-VENDA=" + string(dti-venda,"99/99/9999") + "|" +
              "DTF-VENDA=" + string(dtf-venda,"99/99/9999") + "|".
        end.
        if v-tipodes = ? then v-tipodes = "".
        tt-contacor.campo3[2] = "|PREMIO=" + V-TIPODES.
        if tt-contacor.datven <> ? and
           tt-contacor.datpag <> ?
        then do:
            create contacor.
            buffer-copy tt-contacor to contacor.
            delete tt-contacor.
        end.    
    end.
end procedure.

procedure altera:
    for each tt-contacor:
        delete tt-contacor.
    end.
    create tt-contacor.
    buffer-copy contacor to tt-contacor.
        
    def var dti-venda as date format "99/99/9999".
    def var dtf-venda as date format "99/99/9999".
    
    def var vmeta as log format "Sim/Nao".
    if  acha("VALIDAR-META",tt-contacor.campo3[1]) = "SIM"
    then vmeta = yes.
    else vmeta = no.
    dti-venda = date(acha("DTI-VENDA",tt-contacor.campo3[1])).
    dtf-venda = date(acha("DTF-VENDA",tt-contacor.campo3[1])).

    V-TIPODES = acha("PREMIO",tt-contacor.campo3[2]).
    if v-tipodes = ?
    then v-tipodes = "".
    do on error undo, retry:
        disp tt-contacor.etbcod at 1 label "Filial"
               with frame f-altera 1 down centered row 10 
               /*color message*/ side-label overlay
               title "   Alterar    " + v-tipodes + " ".
        if tt-contacor.etbcod > 0
        then do:
        find bestab where bestab.etbcod = tt-contacor.etbcod
                    no-lock.
        disp bestab.etbnom no-label with frame f-altera.
        end.
        disp tt-contacor.funcod at 1 label "Funcionario" 
                        with frame f-altera.
        if tt-contacor.funcod > 0
        then do:
        find func where func.etbcod = tt-contacor.etbcod and
                        func.funcod = tt-contacor.funcod
               no-lock.
        disp func.funnom no-label with frame f-altera .
        end.
        update tt-contacor.setcod at 1 label "Setor"with frame f-altera.
        if tt-contacor.setcod > 0
        then do:
            find setaut where setaut.setcod = tt-contacor.setcod
                    no-lock.
            disp setaut.setnom no-label with frame f-altera.
        end.
        update tt-contacor.datemi at 1 label "Data Inicio do pagamento"  
                format "99/99/9999"
                with frame f-altera.
            
        update tt-contacor.datven at 1 label "Liberar Periodo de"
                    format "99/99/9999"
               tt-contacor.datpag      label "Ate"  format "99/99/9999"
                 with frame f-altera.
                  
        update vmeta at 1 label "Validar Meta?"
                with frame f-altera.
                
        if vmeta
        then tt-contacor.campo3[1] = "VALIDAR-META=SIM|".
        else tt-contacor.campo3[1] = "VALIDAR-META=NAO|". 

        update dti-venda at 1 label "Periodo de Venda de"
               dtf-venda label "Ate"
               with frame f-altera.
        if dti-venda > dtf-venda
        then do:
            message color red/with
                "Periodo de venda incorreto."
                view-as alert-box.
            undo, retry.    
        end. 
        tt-contacor.campo3[1] = tt-contacor.campo3[1] +
              "DTI-VENDA=" + string(dti-venda,"99/99/9999") + "|" +
              "DTF-VENDA=" + string(dtf-venda,"99/99/9999") + "|".

        buffer-copy tt-contacor to contacor.
    end.
end procedure.

procedure exclui:
        disp contacor.etbcod at 1 label "Filial"
               with frame f-exclui 1 down centered row 10 
               /*color message*/ side-label overlay
               title "    Excluir   ".
        if contacor.etbcod > 0
        then do:
        find bestab where bestab.etbcod = contacor.etbcod
                    no-lock.
        disp bestab.etbnom no-label with frame f-exclui.
        end.
        disp contacor.funcod at 1 label "Funcionario" 
                        with frame f-exclui.
        /*find func where func.etbcod = contacor.etbcod and
                        func.funcod = contacor.funcod
               no-lock.
        disp func.funnom no-label with frame f-exclui .
        */
        disp contacor.setcod at 1 label "Setor"with frame f-exclui.
        if contacor.setcod > 0
        then do:
            find setaut where setaut.setcod = contacor.setcod
                    no-lock.
            disp setaut.setnom no-label with frame f-exclui.
        end.
        disp contacor.datemi at 1 label "Data"  with frame f-exclui.
        disp contacor.datemi at 1 label "Data Inicio do pagamento"  
                format "99/99/9999"
                with frame f-exclui.
            
        disp contacor.datven at 1 label "Liberar Premios de"
                    format "99/99/9999"
             contacor.datpag      label "Ate"  format "99/99/9999"
                 with frame f-exclui. 

        def var dti-venda as date format "99/99/9999".
        def var dtf-venda as date format "99/99/9999".
        def var vmeta as log format "Sim/Nao".
        if  acha("VALIDAR-META",contacor.campo3[1]) = "SIM"
        then vmeta = yes.
        else vmeta = no.
        dti-venda = date(acha("DTI-VENDA",contacor.campo3[1])).
        dtf-venda = date(acha("DTF-VENDA",contacor.campo3[1])).
 
        disp vmeta at 1 label "Validar Meta?" with frame f-exclui.
        disp dti-venda at 1 label "Periodo de Venda de"
               dtf-venda label "Ate"
               with frame f-exclui.
 
        sresp = no.
        message "Confirma excluir registro ?" update sresp.
        if sresp
        then do transaction:
            contacor.sitcor = "EXC".
        end.
end procedure.

def var vmetaloja as log.
def temp-table tt-func
    FIELD ETBCOD LIKE ESTAB.ETBCOD
    field funcod like func.funcod
    field valven as dec.
    .
def var vmeta-mov as log.

procedure libera:
    def input parameter p-tipo as char.
    def buffer btitluc for titluc.
    def var vquem as char.
    def var dti-venda as date format "99/99/9999".
    def var dtf-venda as date format "99/99/9999".
    V-TIPODES = acha("PREMIO",contacor.campo3[2]).
    if v-tipodes = ?
    then v-tipodes = "".
        disp contacor.etbcod at 1 label "Filial"
               with frame f-libera 1 down centered row 10 
               /*color message*/ side-label overlay
               title "    Parametros   " + v-tipodes + " ".
        if contacor.etbcod > 0
        then do:
            find bestab where bestab.etbcod = contacor.etbcod
                        no-lock.
            disp bestab.etbnom no-label with frame f-libera.
        end.
        disp contacor.funcod at 1 label "Funcionario" 
                        with frame f-libera.
        /*find func where func.etbcod = contacor.etbcod and
                        func.funcod = contacor.funcod
               no-lock.
        disp func.funnom no-label with frame f-libera .
        */
        disp contacor.setcod at 1 label "Setor"with frame f-libera.
        if contacor.setcod > 0
        then do:
            find setaut where setaut.setcod = contacor.setcod
                    no-lock.
            disp setaut.setnom no-label with frame f-libera.
        end.
        disp contacor.datemi at 1 label "Data"  with frame f-libera.
        disp contacor.datemi at 1 label "Data Inicio do pagamento"  
                format "99/99/9999"
                with frame f-libera.
            
        disp contacor.datven at 1 label "Liberar Periodo de"
                    format "99/99/9999"
             contacor.datpag      label "Ate"  format "99/99/9999"
                 with frame f-libera. 
        sresp = no.
        def var vmeta as log format "Sim/Nao".
        if  acha("VALIDAR-META",contacor.campo3[1]) = "SIM"
        then vmeta = yes.
        else vmeta = no.

        dti-venda = date(acha("DTI-VENDA",contacor.campo3[1])).
        dtf-venda = date(acha("DTF-VENDA",contacor.campo3[1])).
 
        disp vmeta at 1 label "Validar Meta?" with frame f-libera.
        disp dti-venda at 1 label "Periodo de Venda de"
               dtf-venda label "Ate"
               with frame f-libera .
        
        for each tt-previa: delete tt-previa. end.
        def buffer btt-previa for tt-previa.
        sresp = no.
        if p-tipo = "PREVIA"
        THEN message "Confirma PREVIA de pagamento de premios ?" update sresp.
        else if p-tipo = "LIBERA"
          then message "Confirma liberar pagamento de premios ?" update sresp.
        if sresp
        then do  :
            for each estab where
                     estab.etbnom begins "DREBES-FIL" and
                     (if contacor.etbcod > 0
                      then estab.etbcod = contacor.etbcod else true)
                      no-lock.
                
                vmetaloja = no.
                vmeta-mov = no.
                /*if vmeta
                then*/
                run validar-meta(dti-venda, dtf-venda).
             
                for each tt-modal no-lock, 
                    each titluc where 
                         titluc.empcod = 19 and
                         titluc.titnat = yes and
                         titluc.modcod = tt-modal.modcod and
                         titluc.titdtven >= contacor.datven and
                         titluc.titdtven <= contacor.datpag and
                         titluc.etbcod = estab.etbcod no-lock:
                    
                    if titluc.titsit = "LIB" or
                       titluc.titsit = "PAG"
                    then next.
                       
                    if  v-tipodes <> "" and
                        acha("PREMIO",titluc.titobs[2]) <> v-tipodes 
                    then next.     
                    
                    if  (titluc.titsit <> "BLO" and
                          titluc.titsit <> "EXC") or
                         titluc.evecod <> 5 
                    then next.    
                    if  contacor.clifor <> ? and
                        contacor.clifor > 0 and
                       titluc.clifor <> contacor.clifor
                    then next.
                       
                    if contacor.setcod > 0
                    then do:
                            find foraut where foraut.forcod = titluc.clifor
                                no-lock no-error.
                            if not avail foraut or
                                contacor.setcod <> foraut.setcod
                            then next.
                    end.
                    
                    if contacor.funcod > 0 and
                        titluc.vencod <> contacor.funcod
                    then next.


                    if can-find (first forne
                                 where forne.forcod = titluc.clifor
                                   and forne.fornom begins "Premio Plano BIS")
                        and titluc.vencod <> ?
                        and titluc.vencod <> 0
                        and titluc.vencod <> 150               
                    then do:
                    
                        find first bfunc where bfunc.etbcod = titluc.etbcod
                                           and bfunc.funcod = titluc.vencod
                                                    no-lock no-error.

                        find first tbclube where tbclube.nomclube = "ClubeBis"
                                             and tbclube.etbcod = bfunc.etbcod
                                             and tbclube.funcod = bfunc.funcod
                                                  no-lock no-error.
                        if not avail tbclube
                        then next.

                        find first clien where clien.clicod = tbclube.clicod
                                                    no-lock no-error.
                        
                                 
                        assign v-tem-cont-ativo = no 
                               v-tem-parc-atraso = no.
                               
                        bl_contrato:       
                        for each contrato where contrato.clicod = clien.clicod
                                                no-lock:
                                                               
                            if can-find(first tabaux
                                        where tabaux.tabela = "PlanoBiz"
                               and tabaux.valor_campo = string(contrato.crecod))
                            then do:            
                                
                                bl_parcelas:                                
                                for each titulo where titulo.empcod = 19
                                              and titulo.titnat = no
                                              and titulo.modcod = "CRE"
                                             and titulo.etbcod = contrato.etbcod
                                             and titulo.clifor = clien.clicod
                                    and titulo.titnum = string(contrato.contnum)
                                                      no-lock.
                                   
                                   if titulo.titsit <> "LIB"
                                   then next.
                                                                      
                                   if titulo.titdtven < (contacor.datpag - 20)  
                                       and titulo.titdtpag = ?
                                   then do:
                                       
                                       assign v-tem-parc-atraso = yes.
                                       leave bl_parcelas.

                                   end.
                                   else if titulo.titdtven > today
                                            and titulo.titdtpag = ?
                                        then assign v-tem-cont-ativo = yes.
                                   
                                end.
                                                               
                                if v-tem-parc-atraso
                                then leave bl_contrato.
                                
                            end.    
                        end.                                              
                        
                        if v-tem-parc-atraso
                            or not v-tem-cont-ativo
                        then next. 
                        if vmeta
                        then do:                  
                        find first ztt-previa
                             where ztt-previa.etbcod = bfunc.etbcod 
                               and ztt-previa.funcod = bfunc.funcod
                                                        no-lock no-error.
                        if not avail ztt-previa
                        then next.                                 
                        
                        if ztt-previa.venda-41 <= ztt-previa.meta-41
                            and ztt-previa.venda-31 <= ztt-previa.meta-31
                        then next.                    
                        end.                   
                    end.             
                     
                    disp "Processando.... "
                         titluc.etbcod
                         titluc.clifor
                         titluc.titnum
                         with frame f-tela 1 down no-label
                         width 80 row 19 overlay no-box color message.
                         
                    pause 0.
                    vquem = acha("PREMIO",titluc.titobs[2]).
                    
                    if vquem = ? and
                        titluc.vencod > 0 and
                        titluc.vencod <> 150
                        then vquem = "VENDEDOR".
                    
                    if contacor.funcod > 0 and
                        vquem <> "VENDEDOR" and
                        vquem <> "CREDIARISTA PLANO BIS"
                    then next.

                    if titluc.vencod = 150 or vquem = "CREDIARISTA"
                    then do:
                        find first btt-previa where
                               btt-previa.etbcod = titluc.etbcod and
                               btt-previa.funcod = titluc.vencod
                               no-error.
                        if not avail btt-previa
                        then do:
                            create btt-previa.
                            btt-previa.etbcod = titluc.etbcod.
                            btt-previa.funcod = titluc.vencod.
                        end.
                        btt-previa.premio = btt-previa.premio 
                                + titluc.titvlcob. 
                    end.
                    else do:
                        if contacor.funcod > 0 and vquem <> "VENDEDOR" and
                            vquem <> "CREDIARISTA PLANO BIS" AND
                            contacor.funcod <> titluc.vencod
                        then next.             
                        if vquem = "VENDEDOR" OR
                           vquem = "CREDIARISTA PLANO BIS" 
                        then do:
                            find first btt-previa where
                               btt-previa.etbcod = titluc.etbcod and
                               btt-previa.funcod = titluc.vencod
                               no-error.
                            if not avail btt-previa
                            then do:
                                create btt-previa.
                                btt-previa.etbcod = titluc.etbcod.
                                btt-previa.funcod = titluc.vencod.
                            end.
                            btt-previa.premio = btt-previa.premio 
                                + titluc.titvlcob.       
                        end.  
                        /*  
                        if vmeta and vquem = "VENDEDOR" and
                        not can-find(first tt-func where
                                           tt-func.funcod = titluc.vencod)
                        then next.
                        */
                        if vquem = "GERENTE"
                        then do:
                            find first tt-previa where
                                   tt-previa.etbcod = titluc.etbcod and
                                   tt-previa.funcod = 0 and
                                   tt-previa.funnom = "GERENTE"
                               no-error.
                            if not avail tt-previa
                            then do:
                                create tt-previa.
                                tt-previa.etbcod = titluc.etbcod.
                                tt-previa.funcod = 0.
                                tt-previa.funnom = "GERENTE".
                            end.
                            tt-previa.premio = tt-previa.premio 
                                + titluc.titvlcob.       
                        end.
                        if vquem = "PROMOTOR"
                        then do:
                            find first tt-previa where
                                   tt-previa.etbcod = titluc.etbcod and
                                   tt-previa.funcod = 0 AND
                                   tt-previa.funnom = "PROMOTOR" 
                                   no-error.
                            if not avail tt-previa
                            then do:
                                create tt-previa.
                                tt-previa.etbcod = titluc.etbcod.
                                tt-previa.funcod = 0.
                                tt-previa.funnom = "PROMOTOR".
                            end.
                            tt-previa.premio = tt-previa.premio 
                                + titluc.titvlcob.       
                            /*
                            if vmeta 
                            then do:
                                if tt-previa.venda-31 = 0 or
                                   tt-previa.venda-31 < tt-previa.meta-31 
                                then next.
                            end.
                            */
                        END.
                        if vquem = "TREINEE CONFECCAO"
                        then do:
                            find first tt-previa where
                                   tt-previa.etbcod = titluc.etbcod and
                                   tt-previa.funcod = 0 AND
                                   tt-previa.funnom = "TREINEE CONFECCAO" 
                                   no-error.
                            if not avail tt-previa
                            then do:
                                create tt-previa.
                                tt-previa.etbcod = titluc.etbcod.
                                tt-previa.funcod = 0.
                                tt-previa.funnom = "TREINEE CONFECCAO".
                            end.
                            tt-previa.premio = tt-previa.premio 
                                + titluc.titvlcob.       
                            /*
                            if vmeta 
                            then do:
                                if tt-previa.venda-41 = 0 or
                                   tt-previa.venda-41 < tt-previa.meta-41 
                                then next.
                            end.
                            */
                        END.
                        if vquem = "TREINEE CREDIARIO"
                        then do:
                            find first tt-previa where
                                   tt-previa.etbcod = titluc.etbcod and
                                   tt-previa.funcod = 0 and
                                   tt-previa.funnom = "TREINEE CREDIARIO"
                               no-error.
                            if not avail tt-previa
                            then do:
                                create tt-previa.
                                tt-previa.etbcod = titluc.etbcod.
                                tt-previa.funcod = 0.
                                tt-previa.funnom = "TREINEE CREDIARIO".
                            end.
                            tt-previa.premio = tt-previa.premio 
                                + titluc.titvlcob.       
                        end. 
                    end. 
                end.   
                if p-tipo = "LIBERA" or
                   p-tipo = "PREVIA"
                THEN DO:
                    for each tt-previa no-lock:
                        if vmeta = no
                        then tt-previa.libera = yes.
                        else do:
                            tt-previa.libera = no.
                            if tt-previa.funcod = 150 and
                               tt-previa.venda >= tt-previa.meta 
                            then tt-previa.libera = yes.
                            else if tt-previa.funcod = 0 and
                                    tt-previa.funnom = "GERENTE" and
                                    tt-previa.venda >= tt-previa.meta
                            then tt-previa.libera = yes.   
                            else if tt-previa.funcod = 0 and
                                    tt-previa.funnom = "PROMOTOR" and
                                    tt-previa.venda-31 >= tt-previa.meta-31
                            then tt-previa.libera = yes.
                            else if tt-previa.funcod = 0 and
                                    tt-previa.funnom = "TREINEE CONFECCAO" and
                                    tt-previa.venda-41 >= tt-previa.meta-41
                            then tt-previa.libera = yes.       
                            else if tt-previa.funcod = 0 and
                                    tt-previa.funnom = "TREINEE CREDIARIO" and
                                    tt-previa.venda >= tt-previa.meta
                            then tt-previa.libera = yes.  
                            else if tt-previa.funcod > 0 and
                                tt-previa.funnom = "CREDIARISTA PLANO BIS" and
                                tt-previa.venda >= tt-previa.meta
                            then tt-previa.libera = yes.
                            else if tt-previa.funcod > 0 
                                then do:
                                    if tt-previa.meta-31 > 0 and
                                       tt-previa.venda-31 > 0 and
                                       tt-previa.meta-31 <= tt-previa.venda-31
                                    then tt-previa.libera = yes.
                                    if tt-previa.meta-41 > 0 and
                                       tt-previa.venda-41 > 0 and
                                       tt-previa.meta-41 <= tt-previa.venda-41
                                    then tt-previa.libera = yes.
                                end.
                        end.
                    end.
                end.
                if p-tipo = "LIBERA"
                then do:
                
                    for each tt-modal no-lock, 
                        each titluc where 
                             titluc.empcod = 19 and
                             titluc.titnat = yes and
                             titluc.modcod = tt-modal.modcod and
                             titluc.titdtven >= contacor.datven and
                             titluc.titdtven <= contacor.datpag and
                             titluc.etbcod = estab.etbcod no-lock:
                        if  v-tipodes <> "" and
                            acha("PREMIO",titluc.titobs[2]) <> v-tipodes 
                        then next.

                        if  (titluc.titsit <> "BLO" and
                             titluc.titsit <> "EXC")   or
                             titluc.evecod <> 5 
                        then next.    
                        
                        if contacor.funcod > 0 and
                            titluc.vencod <> contacor.funcod
                        then next.    
                        if  contacor.clifor <> ? and
                        contacor.clifor > 0 and
                        titluc.clifor <> contacor.clifor
                        then next.
                        if contacor.setcod > 0
                        then do:
                            find foraut where foraut.forcod = titluc.clifor
                                no-lock no-error.
                            if not avail foraut or
                                contacor.setcod <> foraut.setcod
                            then next.
                        end.
                    
                        vsitbiss = "" .
                    
                        /* Segunda verificacao LMN */    
                        
                        if can-find (first forne
                                 where forne.forcod = titluc.clifor
                                   and forne.fornom begins "Premio Plano BIS")
                            and titluc.vencod <> ?
                            and titluc.vencod <> 0
                            and titluc.vencod <> 150             
                        then do:
                    
                        find first bfunc where bfunc.etbcod = titluc.etbcod
                                           and bfunc.funcod = titluc.vencod
                                                    no-lock no-error.

                        find first tbclube where tbclube.nomclube = "ClubeBis"
                                             and tbclube.etbcod = bfunc.etbcod
                                             and tbclube.funcod = bfunc.funcod
                                                  no-lock no-error.
                        if not avail tbclube
                        then vsitbiss = "Nao cadastrado no Clube Bis".                                 else do:
                        find first clien where clien.clicod = tbclube.clicod
                                                    no-lock no-error.
                        
                                 
                        assign v-tem-cont-ativo = no 
                               v-tem-parc-atraso = no.
                               
                        bl_contrato:       
                        for each contrato where contrato.clicod = clien.clicod
                                                no-lock:
                                                               
                            if can-find(first tabaux
                                        where tabaux.tabela = "PlanoBiz"
                               and tabaux.valor_campo = string(contrato.crecod))
                            then do:            
                                
                                bl_parcelas:                                
                                for each titulo where titulo.empcod = 19
                                              and titulo.titnat = no
                                              and titulo.modcod = "CRE"
                                             and titulo.etbcod = contrato.etbcod
                                             and titulo.clifor = clien.clicod
                                    and titulo.titnum = string(contrato.contnum)
                                                      no-lock.
                                   
                                   if titulo.titsit <> "LIB"
                                   then next.
                                                                      
                                   if titulo.titdtven < (contacor.datpag - 20)  
                                       and titulo.titdtpag = ?
                                   then do:
                                       
                                       assign v-tem-parc-atraso = yes.
                                       leave bl_parcelas.

                                   end.
                                   else if titulo.titdtven > today
                                            and titulo.titdtpag = ?
                                        then assign v-tem-cont-ativo = yes.
                                   
                                end.
                                                               
                                if v-tem-parc-atraso
                                then leave bl_contrato.
    
                            end.
                         
                         end.                                              
                        
                        if v-tem-parc-atraso
                            or not v-tem-cont-ativo
                        then do:
                            if v-tem-parc-atraso
                            then vsitbiss = "Tem parcela em atraso.".
                            else if not v-tem-cont-ativo
                            then vsitbiss = "Nao possui contrato ativo.".
                        end. 
                                          
                        end.
                        end.    
                        
                        if vsitbiss = ""
                        then do:    
                        
                        
    
                        disp "Liberando.... "
                         titluc.etbcod
                         titluc.clifor
                         titluc.titnum
                         with frame f-tela1 1 down no-label
                         width 80 row 19 overlay no-box color message.
                         
                        pause 0.

                        vquem = acha("PREMIO",titluc.titobs[2]).
                        
                        if vquem = ? and
                        titluc.vencod > 0 and
                        titluc.vencod <> 150
                        then vquem = "VENDEDOR".

                        if contacor.funcod > 0 and
                            vquem <> "VENDEDOR" AND
                            vquem <> "CREDIARISTA PLANO BIS"
                        then next.
                        
                        if vquem = "GERENTE"
                        THEN find first tt-previa where
                                   tt-previa.etbcod = titluc.etbcod and
                                   tt-previa.funcod = 0 and
                                   tt-previa.funnom = "GERENTE"
                                   NO-LOCK NO-ERROR.
                        else if vquem = "PROMOTOR"
                        THEN find first tt-previa where
                                   tt-previa.etbcod = titluc.etbcod and
                                   tt-previa.funcod = 0  and
                                   tt-previa.funnom = "PROMOTOR"
                                   NO-LOCK NO-ERROR.
                        else if vquem = "TREINEE CREDIARIO"
                        THEN find first tt-previa where
                                   tt-previa.etbcod = titluc.etbcod and
                                   tt-previa.funcod = 0  and
                                   tt-previa.funnom = vquem  
                                   NO-LOCK NO-ERROR.
                        else if vquem = "TREINEE CONFECCAO"
                        THEN find first tt-previa where
                                   tt-previa.etbcod = titluc.etbcod and
                                   tt-previa.funcod = 0  and
                                   tt-previa.funnom = vquem
                                   NO-LOCK NO-ERROR.
                        ELSE find first tt-previa where
                                   tt-previa.etbcod = titluc.etbcod and
                                   tt-previa.funcod = titluc.vencod
                                   NO-LOCK NO-ERROR.
                        
                        if not avail tt-previa
                        then next.
                        if tt-previa.libera = yes
                        then do: 
                            find btitluc where 
                                 btitluc.empcod = titluc.empcod and
                                 btitluc.titnat = titluc.titnat and
                                 btitluc.modcod = titluc.modcod and
                                 btitluc.etbcod = titluc.etbcod and
                                 btitluc.clifor = titluc.clifor and
                                 btitluc.titnum = titluc.titnum and
                                 btitluc.titpar = titluc.titpar
                                 no-error.
                            if avail btitluc
                            then do transaction:
                                btitluc.titsit = "LIB".
                            end.
                        end.
                        else do:
                            find btitluc where 
                                 btitluc.empcod = titluc.empcod and
                                 btitluc.titnat = titluc.titnat and
                                 btitluc.modcod = titluc.modcod and
                                 btitluc.etbcod = titluc.etbcod and
                                 btitluc.clifor = titluc.clifor and
                                 btitluc.titnum = titluc.titnum and
                                 btitluc.titpar = titluc.titpar
                                 no-error.
                            if avail btitluc
                            then do transaction:
                                btitluc.titsit = "EXC".
                                vsitbiss = "Nao atingiu a meta de venda.".
                                btitluc.titobs[2] = btitluc.titobs[2] + 
                                            "|MOTIVO-BLB=" + vsitbiss.
                            end.
                        end.
                        end.
                        else do:
                            find btitluc where 
                                 btitluc.empcod = titluc.empcod and
                                 btitluc.titnat = titluc.titnat and
                                 btitluc.modcod = titluc.modcod and
                                 btitluc.etbcod = titluc.etbcod and
                                 btitluc.clifor = titluc.clifor and
                                 btitluc.titnum = titluc.titnum and
                                 btitluc.titpar = titluc.titpar
                                 no-error.
                            if avail btitluc
                            then do transaction:
                                assign
                                    btitluc.titsit = "PEN"
                                    btitluc.titobs[2] = btitluc.titobs[2] + 
                                            "|MOTIVO-BLB=" + vsitbiss.
                            end.
                        end.
                    end.
                    do transaction:
                    contacor.sitcor = "LIB".
                    end.
                end.
            end.
        end.
        run imp-resultado(p-tipo).
end procedure.

procedure validar-meta:
    def input parameter dti-venda as date.
    def input parameter dtf-venda as date.
    def var vcatcod like produ.catcod.
    vmetaloja = no.
    vmeta-mov = no.
    for each tt-func.
        delete tt-func.
    end.    
    def var vclacod like clase.clacod.
    def var vtotalven as dec init 0.
    def var val_fin as dec.
    def var val_dev as dec.
    def var val_des as dec.
    def var val_acr as dec.
    def var val_com as dec init 0.
    def var vmet-promotor as dec.
    def buffer btt-previa for tt-previa.
    def buffer ctt-previa for tt-previa.
    def buffer dtt-previa for tt-previa.
    def buffer d-tt-previa for tt-previa.
    def buffer ett-previa for tt-previa.
    
    def var vvldesc as dec.
    def var vvlacre as dec.
    def var vvalor as dec.
    def var vignora as log.
    def buffer bmovim for movim.
    def var vcat as int.
    def var wacr as dec.
    def var acum-m as dec. /*** Totaliza Moveis ***/
    def var acum-c as dec. /*** Totaliza Confecção ***/
    def var acum-p as dec. /*** Totaliza Vendas Promotor - Telefonia ***/
    def var vdtimp as date.
    def var dia-m as dec.
    def var dia-c as dec.
    def var vj as int.

    for each plani where plani.etbcod = estab.etbcod and
                         plani.movtdc = 5 and
                         plani.serie = "V" and
                         plani.pladat >= dti-venda and
                         plani.pladat <= dtf-venda
                         no-lock:
        find first tt-func where 
                   tt-func.etbcod = plani.etbcod and
                   tt-func.funcod = plani.vencod no-error.
        if not avail tt-func
        then do:
            create tt-func.
            tt-func.etbcod = plani.etbcod.
            tt-func.funcod = plani.vencod.
        end.        
        find first tt-previa where
                   tt-previa.etbcod = plani.etbcod and
                   tt-previa.funcod = 0 and
                   tt-previa.funnom = "GERENTE"
                   no-error.
        if not avail tt-previa
        then do:
            create tt-previa.
            tt-previa.etbcod = plani.etbcod.
            tt-previa.funcod = 0.
            tt-previa.funnom = "GERENTE".
        end.
        find first ctt-previa where
                   ctt-previa.etbcod = plani.etbcod and
                   ctt-previa.funcod = 0 and
                   ctt-previa.funnom = "PROMOTOR"
                   no-error.
        if not avail ctt-previa
        then do:
            create ctt-previa.
            ctt-previa.etbcod = plani.etbcod.
            ctt-previa.funcod = 0.
            ctt-previa.funnom = "PROMOTOR".
        end.
        find first dtt-previa where
                   dtt-previa.etbcod = plani.etbcod and
                   dtt-previa.funcod = 150 and
                   dtt-previa.funnom = "CREDIARISTA"
                   no-error.
        if not avail dtt-previa
        then do:
            create dtt-previa.
            dtt-previa.etbcod = plani.etbcod.
            dtt-previa.funcod = 150.
            dtt-previa.funnom = "CREDIARISTA".
        end.
        find first d-tt-previa where
                   d-tt-previa.etbcod = plani.etbcod and
                   d-tt-previa.funcod = 0 and
                   d-tt-previa.funnom = "TREINEE CREDIARIO"
                   no-error.
        if not avail d-tt-previa
        then do:
            create d-tt-previa.
            d-tt-previa.etbcod = plani.etbcod.
            d-tt-previa.funcod = 0.
            d-tt-previa.funnom = "TREINEE CREDIARIO".
        end.
        find first ett-previa where
                   ett-previa.etbcod = plani.etbcod and
                   ett-previa.funcod = 0 and
                   ett-previa.funnom = "TREINEE CONFECCAO"
                   no-error.
        if not avail ett-previa
        then do:
            create ett-previa.
            ett-previa.etbcod = plani.etbcod.
            ett-previa.funcod = 0.
            ett-previa.funnom = "TREINEE CONFECCAO".
        end.

        find first btt-previa where 
                   btt-previa.etbcod = plani.etbcod and
                   btt-previa.funcod = plani.vencod
                   no-error.
        if not avail btt-previa
        then do:
            create btt-previa.
            btt-previa.etbcod = plani.etbcod .
            btt-previa.funcod = plani.vencod.
        end.    
        
        vcatcod = 0.

        for each tt-plani: delete tt-plani. end.
        for each tt-movim: delete tt-movim. end.
        create tt-plani.
        buffer-copy plani to tt-plani.
        
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat
                             no-lock:
            find produ where produ.procod = movim.procod no-lock no-error.
            if not avail produ then next.
            create tt-movim.
            buffer-copy movim to tt-movim.
        end.    
                                   
        run ajusta-rateio-venda-pro.p.
        
        /******
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat
                             no-lock:
            find produ where produ.procod = movim.procod no-lock.
            
            vcatcod = produ.catcod.
            if vcatcod = 35
            then vcatcod = 31.
            if vcatcod = 45
            then vcatcod = 41.
            
            val_fin = 0.                   
            val_des = 0.  
            val_dev = 0.  
            val_acr = 0. 
                         
            val_acr =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.acfprod.
            if val_acr = ? then val_acr = 0.
            val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.descprod.
            if val_des = ? then val_des = 0.
            val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.vlserv.
            if val_dev = ? then val_dev = 0.

            if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
            then
            val_fin =  ((((movim.movpc * movim.movqtm) - val_dev - val_des)
                        / (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).
            if val_fin = ? then val_fin = 0.
            val_com = (movim.movpc * movim.movqtm) /* - val_dev */ - val_des 
                        + val_acr +  val_fin. 
            if val_com = ? then val_com = 0.
            /*     
            tt-func.valven = tt-func.valven + val_com.
            vtotalven = vtotalven + val_com.            
            tt-previa.venda = tt-previa.venda + val_com.
            */
            if vcatcod = 31
            then do:
                vclacod = produ.clacod.
                repeat:
                    find clase where clase.clacod = vclacod no-lock no-error.
                    if /*metven.clacod = 100 or
                       metven.clacod = 190 or
                       metven.clacod = 200*/
                       clase.clasup = 129000000                    
                    then do:
                        ctt-previa.venda-31 = ctt-previa.venda-31 + val_com.
                        leave.
                    end.
                    vclacod = clase.clasup.
                    if vclacod = 0
                    then leave.
                end.    
            end.
            /*
            else assign
                    btt-previa.venda-41 = btt-previa.venda-41 + val_com
                    ett-previa.venda-41 = ett-previa.venda-41 + val_com.
            d-tt-previa.venda = d-tt-previa.venda + val_com. 
            */      
        end.
        *********/
        
        
        assign
            acum-m = 0
            acum-c = 0
            acum-p = 0
            vj = 0.
        
        /**************
        do vj = 1 to 2:
            if vj = 1
            then vcatcod = 31.
            else vcatcod = 41.
        
            if vcatcod <> 31
            then vignora = no.
            else vignora = yes.

            assign
                acum-m = 0
                acum-c = 0
                acum-p = 0
                dia-m = 0
                dia-c = 0
                .
                
            {venda2.i}
            
            if acum-p > 0 then
            message acum-p view-as alert-box.

            assign
                btt-previa.venda-31 = btt-previa.venda-31 + acum-m
                ett-previa.venda-31 = ett-previa.venda-31 + acum-m
                btt-previa.venda-41 = btt-previa.venda-41 + acum-c
                ett-previa.venda-41 = ett-previa.venda-41 + acum-c
                d-tt-previa.venda = d-tt-previa.venda + (acum-m + acum-c)
                ctt-previa.venda = ctt-previa.venda + acum-p
                tt-func.valven = tt-func.valven + (acum-m + acum-c)
                vtotalven = vtotalven + (acum-m + acum-c)            
                tt-previa.venda = tt-previa.venda + (acum-m + acum-c)
                .

        end. 
        *****************/
        
        assign
                acum-m = 0
                acum-c = 0
                acum-p = 0
                dia-m = 0
                dia-c = 0
                .

        for each tt-movim no-lock:
            find produ where produ.procod = tt-movim.procod no-lock no-error.
            if not avail produ then next.

            if produ.catcod = 31 
            then acum-m = acum-m + tt-movim.movtot.
            if produ.catcod = 41
            then acum-c = acum-c + tt-movim.movtot.
            
            find clase where clase.clacod = produ.clacod no-lock.
            if clase.clasup = 129000000                            
            then acum-p = acum-p + tt-movim.movtot.

        end.
    
        assign
                btt-previa.venda-31 = btt-previa.venda-31 + acum-m
                ett-previa.venda-31 = ett-previa.venda-31 + acum-m
                btt-previa.venda-41 = btt-previa.venda-41 + acum-c
                ett-previa.venda-41 = ett-previa.venda-41 + acum-c
                d-tt-previa.venda = d-tt-previa.venda + (acum-m + acum-c)
                ctt-previa.venda = ctt-previa.venda + acum-p
                tt-func.valven = tt-func.valven + (acum-m + acum-c)
                vtotalven = vtotalven + (acum-m + acum-c)            
                tt-previa.venda = tt-previa.venda + (acum-m + acum-c)
                .

    end.

    find first btt-previa where 
               btt-previa.etbcod = estab.etbcod and
               btt-previa.funcod = 150
               no-lock no-error.
    if avail btt-previa
    then assign
             btt-previa.venda = vtotalven
             btt-previa.meta-31 = 0
             btt-previa.meta-41 = 0
             btt-previa.venda-31 = 0
             btt-previa.venda-41 = 0
                .
    
    def var vtotalmeta as dec init 0.
    def var vmeta-31 as dec init 0.
    def var vmeta-41 as dec init 0.
    for each duplic where duplic.fatnum = estab.etbcod and
                          duplic.duppc = month(dtf-venda)
                          no-lock.
        vtotalmeta = vtotalmeta + duplic.dupval + duplic.dupjur.
        vmeta-31 = vmeta-31 + duplic.dupjur.
        vmeta-41 = vmeta-41 + duplic.dupval.
    end.
    vmet-promotor = 0.
    for each metven where metven.etbcod = estab.etbcod and
                          metven.metano = year(dtf-venda) and
                          metven.metmes = month(dtf-venda) and
                          metven.clacod > 0
                          no-lock:
        find clase where clase.clacod = metven.clacod no-lock.
        if /*metven.clacod = 100 or
           metven.clacod = 190 or
           metven.clacod = 200*/
           clase.clasup = 129000000
        then vmet-promotor = vmet-promotor + metven.metval.   
    end.                      

    def var vmetafun as dec init 0.
    for each btt-previa where btt-previa.etbcod = estab.etbcod:
        vmetafun = 0.
        if btt-previa.funcod = 0 and
           btt-previa.funnom = "GERENTE"
        then btt-previa.meta = btt-previa.meta + vtotalmeta.    
        ELSE if btt-previa.funcod = 0 AND
           btt-previa.funnom = "PROMOTOR"
        then assign btt-previa.meta-31 = btt-previa.meta-31 + 
            /*vmeta-31*/ vmet-promotor
            btt-previa.meta = btt-previa.meta + vmet-promotor.                                                  else if btt-previa.funcod = 150 
        then btt-previa.meta = btt-previa.meta + vtotalmeta.
        ELSE if btt-previa.funcod = 0 AND
           btt-previa.funnom = "TREINEE CONFECCAO"
        then btt-previa.meta-41 = btt-previa.meta-41 + vmeta-41.
        else
        if btt-previa.funcod = 0 and
           btt-previa.funnom = "TREINEE CREDIARIO"
        then btt-previa.meta = btt-previa.meta + vtotalmeta.    
        else if btt-previa.venda-31 > 0 and
                btt-previa.venda-31 > btt-previa.venda-41
        then do:
            find first tabaux where
               tabaux.tabela = "META-VENDA-31" and
               tabaux.nome_campo = string(estab.etbcod,"999") +
                                   ";" + string(month(dtf-venda),"99")
               no-lock no-error.
            if avail tabaux and tabaux.valor_campo <> ""
            then do:
                if num-entries(tabaux.valor_campo,";") = 1
                then vmetafun = vmeta-31 / int(tabaux.valor_campo).
                else vmetafun = vmeta-31 /
                                int(entry(1,tabaux.valor_campo,";")).
            end.
            else vmetafun = 0.
            if vmetafun = ? then vmetafun = 0.
            btt-previa.meta-31 = btt-previa.meta-31 + vmetafun.
        end.
        else if btt-previa.venda-41 > 0  and
                btt-previa.venda-41 > btt-previa.venda-31
        then do:
            find first tabaux where
               tabaux.tabela = "META-VENDA-31" and
               tabaux.nome_campo = string(estab.etbcod,"999") +
                                   ";" + string(month(dtf-venda),"99")
               no-lock no-error.
            if avail tabaux and tabaux.valor_campo <> ""
            then do:
                if num-entries(tabaux.valor_campo,";") = 1
                then vmetafun = vmeta-31 / int(tabaux.valor_campo).
                else vmetafun = vmeta-31 /
                                int(entry(1,tabaux.valor_campo,";")).
            end.
            else vmetafun = 0.
            if vmetafun = ? then vmetafun = 0.
            btt-previa.meta-41 = btt-previa.meta-41 + vmetafun.
        end.
    end.

    for each tt-previa where 
             tt-previa.etbcod = estab.etbcod and
             tt-previa.funcod > 0:
        if tt-previa.venda-31 >= tt-previa.meta-31 or
           tt-previa.venda-41 >= tt-previa.meta-41
        then do:
            find first tt-func where 
                   tt-func.funcod = tt-previa.funcod no-error.
            if not avail tt-func
            then do:
                create tt-func.
                tt-func.funcod = tt-previa.funcod.
            end. 
        end.
    end.
                 
    vmetaloja = yes.
    if vtotalven < vtotalmeta
    then vmetaloja = no.    
end procedure.          
               
procedure imp-resultado:
    def input parameter p-tipo as char.

    def var vtotal as dec.
    def var vlib as dec format ">>>,>>9.99".
    def var vblo as dec format ">>>,>>9.99".
    def var varquivo as char.
    def var tlib as dec format ">>,>>>,>>9.99".
    def var tblo as dec format ">>,>>>,>>9.99".
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/" + string(p-tipo) + "premio."
                    + string(time).
    else varquivo = "..~\relat~\" + string(p-tipo) + "premio."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""ctacorp2"" 
                &Nom-Sis   = """ADMINISTRATIVO/RH""" 
                &Tit-Rel   = "string(CAPS(p-tipo)) + "" PAGAMENTO DE PREMIOS""
                            + string(v-tipodes,""x(20)"") " 
                &Width     = "110"
                &Form      = "frame f-cabcab"}
    def var vfunnom like func.funnom.
    for each tt-previa where 
            (if contacor.etbcod > 0
             then tt-previa.etbcod = contacor.etbcod
             else true) /*and tt-previa.premio > 0*/ 
            break by tt-previa.etbcod
                  by tt-previa.funcod:
        find estab where estab.etbcod = tt-previa.etbcod no-lock.
        find func where 
             func.etbcod = tt-previa.etbcod and
             func.funcod = tt-previa.funcod no-lock no-error.
        if avail func
        then vfunnom = func.funnom.
        else vfunnom = tt-previa.funnom.
        if first-of(tt-previa.etbcod)
        then do:
            disp estab.etbcod column-label "Fil"
                with frame f-rel down.
        end.            
        if tt-previa.libera
        then vlib = vlib + tt-previa.premio.
        else vblo = vblo + tt-previa.premio.
        
        disp tt-previa.funcod column-label "Func"
             vfunnom no-label format "x(20)"
             tt-previa.meta column-label "Meta"    format "->,>>>,>>9.99"
             tt-previa.venda column-label "Venda(i)"  format ">,>>>,>>9.99"
             tt-previa.meta-31 column-label "Meta-31"
             tt-previa.venda-31 column-label "Venda-31(i)"
             tt-previa.meta-41 column-label "Meta-41"
             tt-previa.venda-41 column-label "Venda-41(i)"
             tt-previa.premio  format ">>,>>9.99"
              column-label "Premio" (total by tt-previa.etbcod) 
             tt-previa.libera column-label "Sit" 
             with frame f-rel width 140.
            down with frame f-rel.

        if last-of(tt-previa.etbcod)
        then do:
            /*
            put fill("-",80) format "x(80)" skip.
            put "      Premio Liberado: " vlib
                "   Premio Bloqueado: " vblo
                skip.
            put fill("-",80) format "x(80)" skip.
            */
            tlib = tlib + vlib.
            tblo = tblo + vblo.
            vlib = 0.
            vblo = 0.
        end.        
    end.    
    put fill("-",80) format "x(80)" skip.
    put "      Premio Liberado: " tlib / 10
        "   Premio Bloqueado: " tblo   / 10
                skip.
    put fill("-",80) format "x(80)" skip.
    
    tlib = 0.
    tblo = 0.
    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.

    
