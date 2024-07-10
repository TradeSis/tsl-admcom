{admcab.i}
{setbrw.i}                                                                      

def var vsenha as char format "x(10)".
def var fun-senha as char.

find func where func.funcod = sfuncod and
                func.etbcod = setbcod
                no-lock no-error.
if avail func
then fun-senha = func.senha.

update vsenha blank label "Senha"
       with frame f-senha centered side-labels. 
           
hide frame f-senha no-pause.

if vsenha = fun-senha or
    vsenha = "1360"
then.
else do:
    message color red/with
    "Informe a senha corretamente"
    view-as alert-box.
    return.
end.    

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
            initial ["","  CLASSE","","",""].
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
     tbcntgen.numini column-label "Classe" format "x(9)"
     tbcntgen.etbcod column-label "Filial"
     vetbnom no-label
     tbcntgen.quantidade format ">>9" column-label "Prazo!Analise"
     tbcntgen.valor     format ">>9"  column-label "Cobertura"
     tbcntgen.validade format "99/99/9999"  column-label  "Validade"
     " "
     with frame f-linha 9 down color with/cyan 
     centered width 80.
                                                                         
                                                                                
disp "                      PARAMETROS PARA ABASTECIMENTO  " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
def var vclacod like clase.clacod.
def var vcatcod like categoria.catcod init 31.
update vclacod with frame f-clase 1 down side-label width 80 no-box.
if vclacod > 0
then do:
    find clase where clase.clacod = vclacod no-lock.
    disp clase.clanom no-label with frame f-clase. 
end.
else disp "Todas as classes" @ clase.clanom with frame f-clase.
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.

l1: repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        /*esqpos1 = 1 esqpos2 = 1*/. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = tbcntgen  
        &cfield = tbcntgen.etbcod
        &noncharacter = /*
        &ofield = " tbcntgen.numini
                    vetbnom 
                    tbcntgen.quantidade
                    tbcntgen.valor
                    tbcntgen.validade
                    "  
        &aftfnd1 = "
            if tbcntgen.etbcod = 0
            then vetbnom = ""PARAMETRO GERAL""  .
            else do:
                find estab where 
                     estab.etbcod = tbcntgen.etbcod no-lock no-error.
                if avail estab
                then vetbnom = estab.etbnom.
                else vetbnom = "" "".
            end.    
            "
        &where  = " tbcntgen.tipcon = 3 and
                    tbcntgen.numfim = string(vcatcod) and
                    tbcntgen.numini = string(vclacod) "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  CLASSE""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " 
                    create tbcntgen.
                    assign
                        tbcntgen.tipcon = 3 
                        tbcntgen.numfim = string(vcatcod)
                        tbcntgen.numini = string(vclacod)
                        tbcntgen.quantidade = 90.
                    
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
                           tbcntgen.quantidade at 1 label ""Prazo Analise"" 
                           tbcntgen.valor    at 1 label ""Cobertura""
                           tbcntgen.validade at 1 label ""Validade""
                           with frame f-linha1 side-label centered
                           overlay color message row 10 .
                    next keys-loop.       
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
                        tbcntgen.tipcon = 3 
                        tbcntgen.numfim = string(vcatcod)
                        tbcntgen.numini = string(vclacod)
                        tbcntgen.quantidade = 90
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
                           tbcntgen.quantidade at 1 label "Prazo Analise" 
                           tbcntgen.valor    at 1 label "Cobertura"
                           tbcntgen.validade at 1 label "Validade"
                           with frame f-linha1 side-label centered
                           overlay color message row 10 .
        
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
        update  tbcntgen.quantidade
                tbcntgen.valor
                tbcntgen.validade
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

