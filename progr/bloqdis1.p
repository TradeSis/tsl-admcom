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
    initial ["","  INCLUI","  ALTERA","  EXCLUI",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","  CLASSE","  RELATORIO","",""].
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


def var vetbnom like estab.etbnom.

form " " 
     tbcntgen.numini column-label "Classe"
     tbcntgen.numfim column-label "Produto"
     tbcntgen.etbcod column-label "Filial"
     vetbnom no-label
     tbcntgen.datini column-label "Inicio"
     tbcntgen.datfim column-label "Final"
     " "
     with frame f-linha 9 down color with/cyan 
     centered width 80.
                                                                         
                                                                                
disp "                      BLOQUEIO DE DISTRIBUICAO " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
def var vprocod like produ.procod.
def var vclacod like clase.clacod.
def var vcatcod like categoria.catcod init 31.
update vclacod with frame f-clase 1 down side-label width 80 no-box.
if vclacod > 0
then do:
    find clase where clase.clacod = vclacod no-lock.
    disp clase.clanom no-label format "x(20)" with frame f-clase. 
end.
else do:
    disp "Todas as classes" @ clase.clanom with frame f-clase.
    update vprocod with frame f-clase.
    if vprocod > 0
    then do:
        find produ where produ.procod = vprocod no-lock.
        disp produ.pronom no-label format "x(20)" with frame f-clase.
    end.
    else do:
        sresp = no.
        message "Deseja imprimir parametros de bloqueio? " update sresp.
        if sresp
        then do:
            run relatorio.
            return.
        end. 
    end.
end.
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.

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
        &file = tbcntgen  
        &cfield = tbcntgen.etbcod
        &noncharacter = /*
        &ofield = " tbcntgen.numini
                    tbcntgen.numfim
                    vetbnom 
                    tbcntgen.datini
                    tbcntgen.datfim
                    "  
        &aftfnd1 = "
            if tbcntgen.etbcod = 0
            then vetbnom = ""PARAMETRO GERAL""  .
            else do:
                find estab where 
                     estab.etbcod = tbcntgen.etbcod no-lock no-error.
                if avail estab
                then vetbnom = estab.etbnom.
                else estab.etbnom = "" "".
            end.    
            "
        &where  = " tbcntgen.tipcon = 6 and
                    tbcntgen.numfim = string(vprocod) and
                    tbcntgen.numini = string(vclacod) "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  RELATORIO"" or
                           esqcom2[esqpos2] = ""  CLASSE""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " 
                    create tbcntgen.
                    assign
                        tbcntgen.tipcon = 6 
                        tbcntgen.numfim = string(vprocod)
                        tbcntgen.numini = string(vclacod)
                        .
                    
                    update tbcntgen.etbcod at 1 label ""Filial""
                        with frame f-linha1 no-validate.
                    if tbcntgen.etbcod = 0
                    then vetbnom = ""PARAMETRO GERAL"".
                    ELSE DO:
                    find estab where 
                         estab.etbcod = tbcntgen.etbcod no-lock no-error.
                    if not avail estab
                    then do:
                        message   ""Filial nao cadastrada."".
                        pause.
                        undo, next l1.
                    end.
                    VETBNOM = ESTAB.ETBNOM.
                    END.
                    disp Vetbnom no-label with frame f-linha1.
                    update 
                           tbcntgen.datini at 1 label ""Inicio"" 
                           tbcntgen.datfim at 1 label ""Final""
                           with frame f-linha1 side-label centered
                           overlay color message row 10 .
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
    if esqregua
    then do:
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo:
            create tbcntgen.
                    assign
                        tbcntgen.tipcon = 6 
                        tbcntgen.numfim = string(vprocod)
                        tbcntgen.numini = string(vclacod)
                        . 
                    
                    update tbcntgen.etbcod at 1 label "Filial"
                        with frame f-linha1 no-validate.
                    IF TBCNTGEN.ETBCOD = 0
                    then vetbnom = "PARAMETRO GERAL".
                    else do:
                    find estab where 
                         estab.etbcod = tbcntgen.etbcod no-lock no-error.
                    if not avail estab
                    then do:
                        message   "Filial nao cadastrada.".
                        pause.
                        undo.
                    end.
                    vetbnom = estab.etbnom.
                    end.
                    disp vetbnom no-label with frame f-linha1.
                    update 
                           tbcntgen.datini at 1 label "Inicio" 
                           tbcntgen.datfim at 1 label "Final"
                           with frame f-linha1 side-label centered
                           overlay color message row 10 .
        
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
        update  tbcntgen.datini
                tbcntgen.datfim
                        with frame f-linha. 
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        sresp = no.
        message "Confirma EXCLUIR regsitro? " update sresp.
        if sresp
        then delete tbcntgen. 
        
    END.
    end.
    else do:
    if esqcom2[esqpos2] = "  CLASSE"
    THEN DO on error undo:
        update vclacod with frame f-clase.
        if vclacod > 0
        then do:
            find clase where clase.clacod = vclacod no-lock.
            disp clase.clanom no-label with frame f-clase. 
            find first produ where 
                       produ.clacod = clase.clacod 
                       no-lock no-error.
            if not avail produ or produ.catcod <> 31
            then do:
                bell.
                message color red/with
                    "Controle permitido somente para classe" skip
                    "a nivel de produto para o setor 31"
                    view-as alert-box.
                undo.    
            end.           
        end.
        else disp "Todas as classes" @ clase.clanom with frame f-clase.
    END.
    if esqcom2[esqpos2] = "  RELATORIO"
    THEN DO on error undo:
        run relatorio.
    END.
    end.
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
    def buffer btbcntgen for tbcntgen.
    def var varquivo as char.
    if opsys = "UNIX" 
    then  varquivo = "/admcom/relat/bloqdis1" + string(time).
    else  varquivo = "l:\relat\blqdis1" + string(time).
            
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "80"
        &Page-Line = "66"
        &Nom-Rel   = ""bloqdis1""
        &Nom-Sis   = """SISTEMA COMERCIA"""
        &Tit-Rel   = """    BLOQUEIOS DE DISTRIBUICAO """
        &Width     = "80"
        &Form      = "frame f-cabcab"}
    
    FOR EACH btbcntgen where btbcntgen.tipcon = 6 no-lock:
        disp btbcntgen.numini column-label "Classe"
             btbcntgen.numfim column-label "Produto"
             btbcntgen.etbcod column-label "Filial"
             btbcntgen.datini column-label "Inicio"
             btbcntgen.datfim column-label "Final"
             with frame f-disp down width 80.
        down with frame f-disp.     
    end.
    
    output close.
    if opsys = "UNIX"
    then do: 
        run visurel.p (input varquivo, 
                   input "").     
    end. 
    else do: 
        {mrod.i} 
    end.
 
end procedure.
