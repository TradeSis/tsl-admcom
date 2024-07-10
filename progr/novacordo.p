{admcab.i}
{setbrw.i}                                                                      


def temp-table tt-cont
    field contnum as int format ">>>>>>>>>9" label "Contrato"
    field valor   as dec format ">>>,>>9.99" label "Divida"
    field parcela as char      label "Parcela"
    index i1 contnum
    .
    
def input parameter p-clicod like clien.clicod.
def input parameter p-situacao as char.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  FILTRAR","  CONSULTAR","  EFETIVAR","  CANCELAR"].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","  CONTRATOS","","",""].
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


form novacordo.id_acordo     column-label "Codigo!Acordo"
     help "Situacao: [P]endente [E]fetivado [C]ancelado"
     novacordo.dtinclu       column-label "Data!Inclusao"   format "99/99/99"
     novacordo.valor_ori     column-label "Valor!Origem"   format ">>,>>9.99"
     novacordo.valor_acordo  column-label "Valor!Acordo"   format ">>,>>9.99"
     novacordo.valor_entrada column-label "Valor!Entrada"  format ">>,>>9.99"
     novacordo.valor_liquido column-label "Valor!Parcelado"  format ">>,>>9.99"
     novacordo.qtd_parcelas      column-label "Par!celas"   format ">>>9"
     novacordo.situacao      column-label "St" format "x"
     with frame f-linha 11 down width 80.
                                                                         
                                                                                
disp "                       CONTROLE DE ACORDO PARA NOVACAO       " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
         
if p-clicod > 0
then do:
    find clien where clien.clicod = p-clicod no-lock.
    disp " " clien.clicod label "Clente"
             clien.clinom no-label when avail clien
             with frame f2 side-label.
end.                                  
else                
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                          
pause 0.               
def buffer btbcntgen for tbcntgen.                            
def var i as int.

def var efe-ok as log .
 
def var vsit as char extent 3 format "x(15)".
if p-situacao <> ""
then vsit[1] = p-situacao.
else assign
        vsit[1] = "PENDENTE" 
        vsit[2] = "EFETIVADO"
        vsit[3] = "CANCELADO"
        .

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
        &file = novacordo  
        &cfield = novacordo.id_acordo
        &noncharacter = /* 
        &ofield = " novacordo.dtinclu
                    /*novacordo.dtefetivacao*/
                    novacordo.valor_ori
                    novacordo.valor_acordo
                    novacordo.valor_entrada
                    novacordo.valor_liquido
                    novacordo.qtd_parcelas
                    novacordo.situacao
                    "  
        &aftfnd1 = " "
        &where  = " (if p-clicod > 0
                    then novacord.clicod = p-clicod else true) and 
                    (if p-situacao <> """"
                    then novacordo.situacao = p-situacao else true)
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
                        ""Nenhum ACORDO encontrado."" 
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

def var vjuro-ac as dec.
def var val-juro as dec.
def var valorparc as dec.
procedure aftselect:
    def var vi as int format ">9".
    clear frame f-linha1 all.
    def buffer bclien for clien.
    if esqcom1[esqpos1] = "  CONSULTAR"
    THEN DO:
        
        vjuro-ac = dec(acha("JUROATRASO",novacordo.motivo5)).
        val-juro = dec(acha("JUROACORDO",novacordo.motivo5)). 
        valorparc = dec(acha("VALORPARCELA",novacordo.motivo5)).                            
        find bclien where bclien.clicod = novacord.clicod no-lock no-error.
        
        disp novacordo.id_acordo    label "      Codigo do Acordo"
             novacordo.dtinclu      label "      Data de Inclusao"
             novacordo.dtvalidade     label "      Data de Validade"
             novacord.clicod        label "     Codigo do Cliente"
             bclien.clinom when avail bclien  format "x(30)"
                                    label "       Nome do Cliente"
            novacordo.valor_ori
            format "zzz,zzz,zz9.99" label "        Valor original"
        novacordo.qtd_parcelas
            format "zzzzzzzzzzzzz9" label "Quantidade de parcelas"
         vjuro-ac   format "zzz,zzz,zz9.99" label "        Juro do Atraso"   
         val-juro   format "zzz,zzz,zz9.99" label "        Juro do Acordo"
         novacordo.valor_acordo
         format "zzz,zzz,zz9.99" label "       Valor do Acordo"
         novacordo.valor_entrada
         format "zzz,zzz,zz9.99" label "      Valor da Entrada"
         valorparc  format "zzz,zzz,zz9.99" label "      Valor da Parcela"
         novacordo.valor_liquido
         format "zzz,zzz,zz9.99" label "         Valor Liquido"
         novacordo.dtvalidade
         format "99/99/9999" label "    Validade do acordo"
         with frame f-ef 1 down centered  row 6 width 60 side-label
         .
         pause.
    END.
    if esqcom1[esqpos1] = "  FILTRAR"
    THEN DO:
        update p-clicod with frame f-filtro 1 down side-label
                row 7 centered  overlay
                title "  filtro  ".
        disp vsit[1] at 1 label "Situacao"  
             vsit[2] at 11 no-label
             vsit[3] at 11 no-label
                with frame f-filtro.
        choose field vsit with frame f-filtro.
        
        p-situacao = vsit[frame-index].
        
        hide frame f-filtro.        
                

    END.
    if esqcom1[esqpos1] = "  EFETIVAR"
    THEN DO:
        if novacordo.situacao = "PENDENTE"
        THEN DO:
            sresp = no.
            message "Confirma EFETIVAR acordo " novacordo.id_acordo "?"
            update sresp.
            if sresp then
            run efetivar-novacordo.p(input recid(novacordo),
                                     output efe-ok).
        END.
        ELSE DO:
            bell.
            message color red/with
            "Situacao " novacordo.situacao "nao permite EFETIVAR."
            view-as alert-box.
        END.
    END.
    if esqcom1[esqpos1] = "  CANCELAR"
    THEN DO:
        if novacordo.situacao = "PENDENTE"
        THEN DO:
            bell.
            sresp = no.
            message "Confirma cancelar acordo " novacordo.id_acordo "?"
            update sresp.
            if sresp
            then do on error undo:
                repeat:
                    update novacordo.motivo1 format "x(60)"
                       novacordo.motivo2 format "x(60)"
                       with frame f-motivo no-label
                       width 62 overlay row 10 color message
                       title " Motivo " centered.
                    if novacordo.motivo1 = ""
                    then next.
                    hide frame f-motivo no-pause.
                    leave.
                end.
                if keyfunction(lastkey) <> "END-ERROR"
                then 
                assign
                    novacordo.situacao = "CANCELADO"
                    novacordo.dtalteracao = today
                    novacordo.horalteracao = time
                    novacordo.user_alteracao = sfuncod
                    .

            end.
        END.
        else do:
            bell.
            message color red/with
            "Situacao " novacordo.situacao "nao permite CANCELAR."
            view-as alert-box.
         end.
    end.
    if esqcom2[esqpos2] = "  CONTRATOS"
    THEN DO:
        for each tt-cont: delete tt-cont. end.
        DO vi = 1 to 20:

            if acha("CONTRATO" + string(vi), novacordo.char1) = ?
            then leave.
            create tt-cont.
            assign
                tt-cont.contnum = int(entry(1,acha("CONTRATO" + string(vi), novacordo.char1),";"))
                tt-cont.valor   = dec(entry(2,acha("CONTRATO" + string(vi), novacordo.char1),";"))
                tt-cont.parcela  = entry(3,acha("CONTRATO" + string(vi), novacordo.char1),";") + " a " +
                entry(4,acha("CONTRATO" + string(vi), novacordo.char1),";") 
                .
        end.
        for each tt-cont :
            disp tt-cont with frame f-ttcont 11 down
            title string(novacordo.id_acordo).
        end.    
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

procedure contratos:

    
end procedure.
