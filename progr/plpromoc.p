/*
*
*    Esqueletao de Programacao
*
*/

{admcab.i}
{difregtab.i new}
def input parameter p-rec as recid.

def var vmes as int.
def var vano as int.
def var vdesmes as char format "x(10)" extent 12
    init["Janeiro","Fevereiro","Marco","Abril","Maio","Junho",
         "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"].

def var vdti as date.
def var vdtf as date.
def var vdtauxi as date.
def var vdtauxf as date.           
def buffer bctpromoc for ctpromoc.
def buffer dctpromoc for ctpromoc.
find bctpromoc where recid(bctpromoc) = p-rec no-lock. 

form bctpromoc.defaultprevenda at 1 label "Default pre-venda"
     help "Informe se o plano aparecera como default na pre-venda"
     bctpromoc.fraseprevenda    no-label format "x(55)"
     help "Informe a frase promocional pra pre-venda"
     /*bctpromoc.dtentrada   at 1  label "Data da   entrada"*/
     /*bctpromoc.diasentrada at 1  label "Dias para entrada"*/
     bctpromoc.dataparcela at 1  label "Primeiro vencimento"
     /*bctpromoc.diasparcela at 1  label "Dias 1a   parcela"*/   
     /*bctpromoc.arredonda   at 1  label "   Arredondamento"*/
           with frame f-inqt 1 down side-label
            no-box row 6  overlay
            .

disp    bctpromoc.defaultprevenda
        bctpromoc.fraseprevenda
        /*bctpromoc.dtentrada */  
        /*bctpromoc.diasentrada*/
          bctpromoc.dataparcela
        /*bctpromoc.diasparcela*/
        /*bctpromoc.arredonda*/
          with frame f-inqt.

find first ctpromoc where 
                   ctpromoc.sequencia = bctpromoc.sequencia and
                   ctpromoc.fincod <> ?             and
                   ctpromoc.probrinde = 0        and
                   ctpromoc.produtovendacasada = 0
                   no-lock no-error.

if avail ctpromoc and bctpromoc.situacao = "M" 
then do:         

    update bctpromoc.defaultprevenda
            with frame f-inqt.
    
    update        
           bctpromoc.fraseprevenda   when bctpromoc.defaultprevenda = yes
           /*bctpromoc.dtentrada*/   
           /*bctpromoc.diasentrada*/
           bctpromoc.dataparcela
           /*bctpromoc.diasparcela*/
           /*bctpromoc.arredonda*/
           with frame f-inqt.
end.

form ctpromoc.fincod
        finan.finnom
        ctpromoc.situacao no-label format "!"
                validate(ctpromoc.situacao = "I" or
                                 ctpromoc.situacao = "A" or
                                 ctpromoc.situacao = "E"
                                 ,"Informe Corretamente")
        help "Informe:  A=Ativo  I=Inativo  E=Exceto"
        with frame f-linha.
        
{setbrw.i}

/**************************
bl-princ:
repeat:
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?
        .
    {sklcls.i
        &help = "                   Enter=Altera I=Inclui F10 = Exclui"
        &file = ctpromoc
        &cfield = ctpromoc.fincod
        &noncharacter = /* */
        &ofield = " finan.finnom  
            ctpromoc.situacao "
        &where = " ctpromoc.sequencia = bctpromoc.sequencia and
                   ctpromoc.fincod >= 0   and
                   ctpromoc.probrinde = 0
                 "
        &aftfnd1 = " find finan where
                        finan.fincod = ctpromoc.fincod
                        no-lock no-error.
                  "
        &naoexiste1 = "
            /*    if bctpromoc.situacao = ""M""
            then.
            else do:
                message color red/with
                    ""Nenhum registro encontrado.""
                    view-as alert-box.
                leave bl-princ.
            end.
              */
                sresp = no.
                message
                ""Nenhum plano encontrado para Promocao. Deseja Incluir ?""
                update sresp.
                if not sresp 
                then leave bl-princ.
 
                update bctpromoc.defaultprevenda with frame f-inqt.
                update bctpromoc.fraseprevenda   
                        when bctpromoc.defaultprevenda = yes
                       /*bctpromoc.dtentrada*/   
                       /*bctpromoc.diasentrada*/
                       bctpromoc.dataparcela
                       /*bctpromoc.diasparcela*/
                       /*bctpromoc.arredonda*/
                            with frame f-inqt.
                run inclui.
                next bl-princ.
                "
         &aftselect1 = "
                    if keyfunction(lastkey) = ""RETURN""
                    THEN DO:
                    update ctpromoc.situacao with frame f-linha.
                    next keys-loop.
                    end.
                    "
         &otherkeys1 = "
            find ctpromoc where recid(ctpromoc) = a-seerec[frame-line].
            if keyfunction(lastkey) = ""i"" OR
               keyfunction(lastkey) = ""I""
            then do:
                color display normal
                      ctpromoc.fincod with frame f-linha.
                run inclui. 
                hide frame f-linha no-pause.
                next bl-princ.
            end.
            if keyfunction(lastkey) = ""DELETE-LINE"" or
               keyfunction(lastkey) = ""CUT""
            then do:
                if bctpromoc.situacao = ""M""
                then.
                else next keys-loop.
                sresp = no.
                message ""Confirma excluir da promocao o Plano"" 
                 ctpromoc.fincod ""?"" update sresp.
                if sresp 
                then do:
                    create table-raw.
                    raw-transfer ctpromoc to table-raw.registro2.
                    run grava-tablog.p (input 2, input setbcod, input sfuncod,
                                    input recid(ctpromoc), input ""ADM"",
                                    input ""ctpromoc"", 
                                    input ""EXCLUI-PLANOS"").

                    delete ctpromoc.
                    hide frame f-linha no-pause.
                    next bl-princ.
                end.
                next keys-loop.
            end.
            "
        &form   = " frame f-linha 10 down  row 7  overlay
                    title "" Planos da promocao "" 
                    color with/cyan width 48 no-label column 32"
    }                        
    if keyfunction(lastkey) = "end-error"
    then do:
        hide frame f-linha no-pause.
        leave bl-princ.
    end.    
end.
******************************/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","","","",""].
def var esqcom2         as char format "x(15)" extent 5
            initial [""," Altera"," Inclui"," Faixa Valor",""].
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
    esqregua = no
    esqpos1  = 1
    esqpos2  = 1.


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
        &file = ctpromoc  
        &cfield = ctpromoc.fincod
        &noncharacter = /* 
        &ofield = " finan.finnom
                    ctpromoc.situacao "  
        &where = " ctpromoc.sequencia = bctpromoc.sequencia and
                   ctpromoc.fincod >= 0   and
                   ctpromoc.probrinde = 0
                 "
        &aftfnd1 = " find finan where
                        finan.fincod = ctpromoc.fincod
                        no-lock no-error.
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
        &naoexiste1 = "  
                        sresp = no.
                message
                ""Nenhum plano encontrado para Promocao. Deseja Incluir ?""
                update sresp.
                if not sresp 
                then leave l1.
 
                update bctpromoc.defaultprevenda with frame f-inqt.
                update bctpromoc.fraseprevenda   
                        when bctpromoc.defaultprevenda = yes
                       /*bctpromoc.dtentrada*/   
                       /*bctpromoc.diasentrada*/
                       bctpromoc.dataparcela
                       /*bctpromoc.diasparcela*/
                       /*bctpromoc.arredonda*/
                            with frame f-inqt.
                run inclui.
                next l1.
                " 
        &otherkeys1 = " run controle. "
        &locktype = " "
        &form   = " frame f-linha 10 down  row 7  overlay
                    title "" Planos da promocao "" 
                    color with/cyan width 48 no-label column 32"
    }                        
    if keyfunction(lastkey) = "end-error"
    then do:
        hide frame f-linha no-pause.
        leave l1.
    end.        
end.

procedure aftselect:
    clear frame f-linha1 all.
    if esqcom2[esqpos2] = " INCLUI"
    THEN DO on error undo:
        run inclui.
    END.
    if esqcom2[esqpos2] = " ALTERA"
    THEN DO:
        update ctpromoc.situacao with frame f-linha.
    END.
    if esqcom2[esqpos2] = " EXCLUI"
    THEN DO:
        
    END.
    if esqcom2[esqpos2] = " FAIXA VALOR"
    THEN DO on error undo:
        run faixa-valor.    
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

procedure inclui.
    repeat on endkey undo, leave:
        find last dctpromoc where
                    dctpromoc.sequencia = bctpromoc.sequencia 
                    no-lock no-error.

        scroll from-current down with frame f-linha.
        create ctpromoc.
        assign
            ctpromoc.promocod = bctpromoc.promocod
            ctpromoc.sequencia = bctpromoc.sequencia
            ctpromoc.linha     = dctpromoc.linha + 1
            ctpromoc.fincod = ?
            ctpromoc.situacao = "A"
            .
        do on error undo:
            update  ctpromoc.fincod 
                with frame f-linha .
            find finan where finan.fincod = ctpromoc.fincod no-lock no-error.
            if not avail finan
            then do:
                message color red/with
                    "Plano " ctpromoc.fincod " nao cadastrado." 
                    view-as alert-box.
                undo.
            end.
            disp finan.finnom with frame f-linha.
            update ctpromoc.situacao with frame f-linha.
        end.
        create table-raw.
        raw-transfer ctpromoc to table-raw.registro2.
        run grava-tablog.p (input 2, input setbcod, input sfuncod,
                                    input recid(ctpromoc), input "ADM",
                                    input "ctpromoc", 
                                    input "INCLUI-PLANOS").
   end.
   find first ctpromoc where 
                   ctpromoc.sequencia = bctpromoc.sequencia and
                   ctpromoc.probrinde > 0 and
                   ctpromoc.probrinde = 0
                   no-lock no-error.

    if not avail ctpromoc 
    then do:         
        assign bctpromoc.dtentrada = ?  
               bctpromoc.diasentrada = 0
               bctpromoc.arredonda = 0
               .
    end.
end procedure.

procedure faixa-valor.
    def var val-faixa1 as dec.
    def var val-faixa2 as dec.
    def var par-faixa1 as dec.
    def var par-faixa2 as dec.
    find finan where finan.fincod = ctpromoc.fincod no-lock no-error.
    if avail finan
    then do:
        if ctpromoc.vendaacimade > 0 
        then do:
            if ctpromoc.tipo = "VALORTOTAL"
            then assign
                val-faixa1 = ctpromoc.vendaacimade
                val-faixa2 = ctpromoc.campodec2[3]
                .
            if ctpromoc.tipo = "VALORPARCELA"
            then assign
                par-faixa1 = ctpromoc.vendaacimade
                par-faixa2 = ctpromoc.campodec2[3]
                .
        end.
        disp val-faixa1
             val-faixa2
             par-faixa1
             par-faixa2
             with frame f-faixav.
        if par-faixa1 = 0 and par-faixa2 = 0
        then
        update val-faixa1 format ">>>,>>9.99" label "Faixa Valor   de"
           val-faixa2 format ">>>,>>9.99" label "Ate"
           with frame f-faixav side-label row 15 centered overlay
           title " " + string(finan.fincod) + " - " + finan.finnom + " ".
        if val-faixa1 = 0 and val-faixa2 = 0
        then
        update par-faixa1 at 1 format ">>>,>>9.99" label "Faixa Parcela de"
           par-faixa2 format ">>>,>>9.99" label "Ate"
           with frame f-faixav .
        if val-faixa1 > 0
        then assign
            ctpromoc.vendaacimade = val-faixa1
            ctpromoc.campodec2[3] = val-faixa2
            ctpromoc.tipo = "VALORTOTAL"
            .
        else if par-faixa1 > 0
            then assign
                ctpromoc.vendaacimade = par-faixa1
                ctpromoc.campodec2[3] = par-faixa2
                ctpromoc.tipo = "VALORPARCELA"
                .
        if par-faixa1 = 0 and
           val-faixa1 = 0
        then ctpromoc.tipo = "".   
        hide frame f-faixav.
    end.
end procedure.
