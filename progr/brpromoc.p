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
def buffer bctpromoc for ctpromoc.
def buffer dctpromoc for ctpromoc.
def buffer ectpromoc for ctpromoc.
def buffer fctpromoc for ctpromoc.
find bctpromoc where recid(bctpromoc) = p-rec .
 
form bctpromoc.qtdvenda    at 1 label "Comprado" format ">>>"
     bctpromoc.qtdbrinde   at 1 label "Brinde  " format ">>>"
           with frame f-inqt 1 down side-label
            row 8 title "Produtos"
            .

disp bctpromoc.qtdvenda
           bctpromoc.qtdbrinde
           with frame f-inqt.

find first ctpromoc where 
                   ctpromoc.sequencia = bctpromoc.sequencia and
                   ctpromoc.probrinde > 0
                   no-lock no-error.
if avail ctpromoc and bctpromoc.situacao = "M"
then do:                   
    update  bctpromoc.qtdbrinde
           with frame f-inqt.
    run selct-estac.
end.
procedure selct-estac:
    def var vsel-estac as char.
    if acha("BESTACAO",bctpromoc.campochar2[1]) <> ?
    then vsel-estac = acha("BESTACAO",bctpromoc.campochar2[1]).
    {marcaestac.i}
    bctpromoc.campochar2[1] = "BESTACAO=" + vsel-estac + "|"
            + bctpromoc.campochar2[1].
end.


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
        &help = " I = Inclui  E = Exclui"
        &file = ctpromoc
        &cfield = ctpromoc.probrinde
        &noncharacter = /*
        &ofield = " produ.pronom format ""x(30)"" "
        &where = " ctpromoc.sequencia = bctpromoc.sequencia and
                   ctpromoc.probrinde > 0 and
                   ctpromoc.fincod = ?
                 "
        &aftfnd1 = " find produ where
                        produ.procod = ctpromoc.probrinde
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
                ""Nenhum brinde encontrado para Promocao. Deseja Incluir ?""
                update sresp.
                if not sresp
                then leave bl-princ.
                
                assign
                    bctpromoc.qtdbrinde = 1.
                update 
                       bctpromoc.qtdbrinde  with frame f-inqt .

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
               keyfunction(lastkey) = ""INSERT-MODE"" OR
               keyfunction(lastkey) = ""I""
            then do:
                /*
                if bctpromoc.situacao <> ""M""
                then next keys-loop.
                */
                color display normal 
                    ctpromoc.probrinde with frame f-linha.
                run inclui. 
                hide frame f-linha no-pause.
                next bl-princ.
            end.
            if keyfunction(lastkey) = ""DELETE-LINE"" or
               keyfunction(lastkey) = ""CUT"" or
               keyfunction(lastkey) = ""E""
            then do:
                if bctpromoc.situacao <> ""M""
                then next keys-loop.
                sresp = no.
                message ""Confirma excluir da promocao o produto brinde"" 
                 ctpromoc.probrinde ""?"" update sresp.
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
                    title "" Brindes da promocao "" 
                    color with/cyan  no-label"
    }                        
    if keyfunction(lastkey) = "end-error"
    then do:
        hide frame f-linha no-pause.
        leave bl-princ.
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
            update  ctpromoc.probrinde 
                with frame f-linha .
            find produ where produ.procod = ctpromoc.probrinde no-lock no-error.
            if not avail produ
            then do:
                message color red/with
                    "Produto " ctpromoc.probrinde " nao cadastrado." 
                    view-as alert-box.
                undo.
            end.
            disp produ.pronom with frame f-linha.
        end.
   end.
   find first ctpromoc where 
                   ctpromoc.sequencia = bctpromoc.sequencia and
                   ctpromoc.probrinde > 0
                   no-lock no-error.
    if not avail ctpromoc 
    then do:                   
        assign 
           bctpromoc.qtdbrinde     = 0
           .
    end.
end procedure.

procedure preco-inicial:
bl-princ1:
repeat:
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?
        .
    hide frame f-linha1 no-pause.
    clear frame f-linha1 all.
    {sklcls.i
        &file = ectpromoc
        &cfield = ectpromoc.fincod
        &noncharacter = /*
        &ofield = " finan.finnom format ""x(15)""
                    fctpromoc.valorprodutovendacasada  
                    when avail fctpromoc 
                        column-label ""Valor"" format "">>,>>9.99"" "
        &where = " ectpromoc.sequencia = bctpromoc.sequencia and
                   ectpromoc.probrinde = 0  and
                   ectpromoc.fincod <> ? "
        &aftfnd1 = " find finan where finan.fincod = ectpromoc.fincod
                        no-lock no-error. 
                     find first fctpromoc where
                        fctpromoc.sequencia = ectpromoc.sequencia and
                        fctpromoc.probrinde = ctpromoc.probrinde and
                        fctpromoc.fincod = ectpromoc.fincod
                          no-lock no-error.
                        "
        &naoexiste1 = "
                if bctpromoc.situacao <> ""M""
                then do:
                    message color red/with ""Nenhum registro encontrado.""
                    view-as alert-box. leave bl-PRINC1.
                end.
                message
                ""Nenhum plano encontrado para promocao. ""    .
                leave bl-princ1. "
         &aftselect1 = "
                if keyfunction(lastkey) = ""RETURN""
                then do :
                    find first fctpromoc where
                        fctpromoc.sequencia = ectpromoc.sequencia and
                        fctpromoc.probrinde = ctpromoc.probrinde and
                        fctpromoc.fincod = ectpromoc.fincod
                          no-lock no-error.
                    if not avail fctpromoc
                    then do transaction:
                         find last dctpromoc where 
                            dctpromoc.sequencia = bctpromoc.sequencia 
                            no-lock no-error.
                            create fctpromoc.
                            assign fctpromoc.promocod = bctpromoc.promocod
                                fctpromoc.sequencia = bctpromoc.sequencia
                                fctpromoc.linha     = dctpromoc.linha + 1 
                                fctpromoc.fincod    = ectpromoc.fincod
                                fctpromoc.probrinde = ctpromoc.probrinde.
                    end.
                    do transaction:
                    update fctpromoc.valorprodutovendacasada
                        with frame f-linha1.
                    end.
                        next keys-loop.
            end. "
        &form   = " frame f-linha1 down row 10  column 45 width 35 
                    title "" Brindes da promocao ""                                   color with/cyan  no-label"
    }                        
    if keyfunction(lastkey) = "end-error"
    then do:
        hide frame f-linha1 no-pause.
        leave bl-princ1.
    end.    
end.
end procedure.


