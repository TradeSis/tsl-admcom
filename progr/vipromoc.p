/*
*
*    Esqueletao de Programacao
*
*/

{admcab.i}

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
def var v-vinc as char format "x(15)"   extent 2
    init["   PRODUTO  ","  FAIXA-PRECO "].

def buffer bctpromoc for ctpromoc.
def buffer dctpromoc for ctpromoc.
def buffer ectpromoc for ctpromoc.
def buffer fctpromoc for ctpromoc.

find bctpromoc where recid(bctpromoc) = p-rec .
 
form bctpromoc.qtdvenda    at 1 label "Comprado " format ">>>"
     bctpromoc.campodec1[1]   at 1 label "Vinculado" format ">>>"
           with frame f-inqt 1 down side-label
            row 8 title "Produtos"
            .

disp bctpromoc.qtdvenda
           bctpromoc.campodec1[1]
           with frame f-inqt.

def var vindex as int init 0.
find first ctpromoc where 
                   ctpromoc.sequencia = bctpromoc.sequencia and
                   ctpromoc.probrinde = 0 and
                   (ctpromoc.campodec1[2] > 0 or
                    ctpromoc.campodec1[3] > 0)
                   no-lock no-error.
if avail ctpromoc
then do:
    if bctpromoc.campodec1[1] = 0
    then vindex = 2.
    else vindex = 1.
end.

if vindex = 0
then do:
    disp v-vinc with frame f-vinc 1 down no-label centered.
    choose field v-vinc with frame f-vinc.
    vindex = frame-index.
end.


if vindex = 2
then do:
    run faixa-preco.
    find first ctpromoc where 
                   ctpromoc.sequencia = bctpromoc.sequencia and
                   ctpromoc.campodec1[3] > 0
                   no-lock no-error.
    if not avail ctpromoc 
    then do:                   
        assign 
           bctpromoc.campodec1[1] = 0
           .
    end.

end.
else do:

{setbrw.i}
bl-princ:
repeat:
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?
        .
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklcls.i
        &help = " F9 = Inclui  F10 = Exclui"
        &file = ctpromoc
        &cfield = ctpromoc.campodec1[2]
        &noncharacter = /*
        &ofield = "     ctpromoc.campodec1[2] format "">>>>>>9""
                        produ.pronom format ""x(30)"" "
        &where = " ctpromoc.sequencia = bctpromoc.sequencia and
                   ctpromoc.campodec1[2] > 0 and
                   ctpromoc.fincod = ?
                 "
        &aftfnd1 = " find produ where
                        produ.procod = int(ctpromoc.campodec1[2])
                        no-lock no-error.
                  "
        &naoexiste1 = "
                if bctpromoc.situacao <> ""M""
                then do:
                    message color red/with ""Nenhum registro encontrado.""
                    view-as alert-box.
                    leave bl-PRINC.
                end.
                sresp = no.
                message
                ""Nenhum produto VINCULADO para Promocao. Deseja Incluir ?""
                update sresp.
                if not sresp
                then leave bl-princ.
                
                assign
                    bctpromoc.campodec1[1] = 1.
                /*
                update 
                       bctpromoc.campodec1[1]  with frame f-inqt .
                */
                run selct-estac.
                run inclui.
                next bl-princ.
                "
         &aftselect1 = "
                if keyfunction(lastkey) = ""RETURN""
                THEN DO:
                    /*un preco-inicial.
                    next keys-loop.
                    */
                end. "    
         &otherkeys1 = "
            find ctpromoc where recid(ctpromoc) = a-seerec[frame-line].
            if keyfunction(lastkey) = ""NEW-LINE"" OR
               keyfunction(lastkey) = ""INSERT-MODE""
            then do:
                if bctpromoc.situacao <> ""M"" and sfuncod <> 101
                then next keys-loop.
                color display normal 
                    ctpromoc.campodec1[2] with frame f-linha.
                run inclui. 
                hide frame f-linha no-pause.
                next bl-princ.
            end.
            if keyfunction(lastkey) = ""DELETE-LINE"" or
               keyfunction(lastkey) = ""CUT""
            then do:
                if bctpromoc.situacao <> ""M""
                then next keys-loop.
                sresp = no.
                message ""Confirma excluir da promocao produto vinculado"" 
                 int(ctpromoc.campodec1[2]) ""?"" update sresp.
                if sresp 
                then do:
                    delete ctpromoc.
                    hide frame f-linha no-pause.
                    next bl-princ.
                end.
                next keys-loop.
            end.
            "
        &form   = " frame f-linha 10 down row 7  column 30
                    title "" Vinculados a promocao "" 
                    color with/cyan  no-label"
    }                        
    if keyfunction(lastkey) = "end-error"
    then do:
        hide frame f-linha no-pause.
        leave bl-princ.
    end.    
end.
end.
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
            .
        do on error undo:
            update  ctpromoc.campodec1[2] 
                with frame f-linha .
            find produ where produ.procod = int(ctpromoc.campodec1[2])
                            no-lock no-error.
            if not avail produ
            then do:
                message color red/with
                    "Produto " int(ctpromoc.campodec1[2])
                        " nao cadastrado." 
                    view-as alert-box.
                undo.
            end.
            disp produ.pronom with frame f-linha.
        end.
   end.
   find first ctpromoc where 
                   ctpromoc.sequencia = bctpromoc.sequencia and
                   ctpromoc.campodec1[2] > 0
                   no-lock no-error.
    if not avail ctpromoc 
    then do:                   
        assign 
           bctpromoc.campodec1[1] = 0
           .
    end.
end procedure.


procedure faixa-preco:
bl-princ1:
repeat:
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?
        .
    form ectpromoc.campodec1[2] column-label "Preco de"
         ectpromoc.campodec1[3] column-label "Ate"
         with frame f-preco .
         
    hide frame f-preco no-pause.
    clear frame f-preco all.
    {sklcls.i
        &file = ectpromoc
        &cfield = ectpromoc.campodec1[2]
        &noncharacter = /*  */
        &ofield = "  ectpromoc.campodec1[3] "
        &where = " ectpromoc.sequencia = bctpromoc.sequencia and
                   ectpromoc.probrinde = 0  and
                   ectpromoc.fincod = ? and
                   ectpromoc.campodec1[2] > 0 "
        &naoexiste1 = "
                if bctpromoc.situacao <> ""M""
                then do:
                    message color red/with ""Nenhum registro encontrado.""
                    view-as alert-box.
                    leave bl-PRINC1.
                end.
                sresp = no.
                message
                ""Nenhum preco VINCULADO para Promocao. Deseja Incluir ?""
                update sresp.
                if not sresp
                then leave bl-princ1.
                
                bctpromoc.campodec1[1] = 0.
                repeat on endkey undo, leave:
                    find last dctpromoc where
                        dctpromoc.sequencia = bctpromoc.sequencia 
                        no-lock no-error.

                    scroll from-current down with frame f-preco.
                    create ectpromoc.
                    assign
                        ectpromoc.promocod = bctpromoc.promocod
                        ectpromoc.sequencia = bctpromoc.sequencia
                        ectpromoc.linha     = dctpromoc.linha + 1
                        ectpromoc.fincod = ?
                        .
                    do on error undo:
                        update  ectpromoc.campodec1[2] 
                                ectpromoc.campodec1[3] 
                                with frame f-preco.
                        if  ectpromoc.campodec1[2] >
                            ectpromoc.campodec1[3]
                        then undo.
                    end.
                end.
                next bl-princ1.
                "
        &aftselect1 = "
                    do on error undo:
                        update  ectpromoc.campodec1[2] 
                                ectpromoc.campodec1[3] 
                                with frame f-preco.
                        if  ectpromoc.campodec1[2] >
                            ectpromoc.campodec1[3]
                        then undo.
                    end.
               "
        &otherkeys1 = "
            find ectpromoc where recid(ectpromoc) = a-seerec[frame-line].
            if keyfunction(lastkey) = ""NEW-LINE"" OR
               keyfunction(lastkey) = ""INSERT-MODE""
            then do:
                if bctpromoc.situacao <> ""M"" and sfuncod <> 101
                then next keys-loop.
                color display normal 
                    ectpromoc.campodec1[2] with frame f-preco.
                do with frame f-preco:
                run preco-inclui.
                end.
                hide frame f-preco no-pause.
                next bl-princ1.
            end.
            if keyfunction(lastkey) = ""DELETE-LINE"" or
               keyfunction(lastkey) = ""CUT""
            then do:
                if bctpromoc.situacao <> ""M""
                then next keys-loop.
                sresp = no.
                message ""Confirma excluir da promocao precos vinculados ?"" 
                 update sresp.
                if sresp 
                then do:
                    delete ectpromoc.
                    hide frame f-preco no-pause.
                    clear frame f-preco all.
                    next bl-princ1.
                end.
                next keys-loop.
            end.
            "
        &form   = " frame f-preco down row 10  column 25  
                    title "" Precos vinculado a promocao ""              
                    color with/cyan "
    }                        
    if keyfunction(lastkey) = "end-error"
    then do:
        hide frame f-preco no-pause.
        leave bl-princ1.
    end.    
end.
end procedure.
procedure preco-inclui:
    repeat on endkey undo, leave:
                    find last dctpromoc where
                        dctpromoc.sequencia = bctpromoc.sequencia 
                        no-lock no-error.

                    scroll from-current down with frame f-preco.
                    create ectpromoc.
                    assign
                        ectpromoc.promocod = bctpromoc.promocod
                        ectpromoc.sequencia = bctpromoc.sequencia
                        ectpromoc.linha     = dctpromoc.linha + 1
                        ectpromoc.fincod = ?
                        .
                    do on error undo:
                        update  ectpromoc.campodec1[2] 
                                ectpromoc.campodec1[3] 
                                with frame f-preco.
                        if  ectpromoc.campodec1[2] >
                            ectpromoc.campodec1[3]
                        then undo.
                    end.
                end.

end procedure.

procedure selct-estac:
    def var vsel-estac as char.
    if acha("VESTACAO",bctpromoc.campochar2[1]) <> ?
    then vsel-estac = acha("VESTACAO",bctpromoc.campochar2[1]).
    {marcaestac.i}
    bctpromoc.campochar2[1] = "VESTACAO=" + vsel-estac + "|"
            + bctpromoc.campochar2[1].
end.

