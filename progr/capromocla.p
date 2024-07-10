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
     bctpromoc.qtdbrinde   at 1 label "Casado  " format ">>>"
           with frame f-inqt 1 down side-label
            row 8 title "Produtos"
            .

disp bctpromoc.qtdvenda
           bctpromoc.qtdbrinde
           with frame f-inqt.
pause 0.
            
def var val-tipo as char format "x".

def var vclacod like produ.clacod.

procedure selct-estac:
    def var vsel-estac as char.
    if acha("CESTACAO",bctpromoc.campochar2[1]) <> ?
    then vsel-estac = acha("CESTACAO",bctpromoc.campochar2[1]).
    {marcaestac.i}
    bctpromoc.campochar2[1] = "CESTACAO=" + vsel-estac + "|"
            + bctpromoc.campochar2[1].
end.

form ctpromoc.produtovendacasada format ">>>>>>>>9"
     clase.clanom format "x(20)"
     ctpromoc.valorprodutovendacasada
     val-tipo no-label
     with frame f-linha.
     
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
        &help = " ENTER=Preco inicial  I = Inclui  E = Exclui"
        &file = ctpromoc
        &cfield = ctpromoc.produtovendacasada
        &noncharacter = /*
        &ofield = " clase.clanom format ""x(20)"" 
                    ctpromoc.valorprodutovendacasada 
                    val-tipo no-label
                    "
                    
        &where = " ctpromoc.sequencia = bctpromoc.sequencia and
                   ctpromoc.produtovendacasada > 0 and
                   ctpromoc.tipo begins ""CLASSE"" and
                   ctpromoc.fincod = ?
                 "
        &aftfnd1 = " find clase where
                        clase.clacod = ctpromoc.produtovendacasada
                        no-lock no-error.
                     val-tipo = ""$"".
                     if acha(""PERCENTUAL"",ctpromoc.tipo) <> ?
                     then val-tipo = ""%"".
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
                ""Nenhuma classe venda casada para Promocao. Deseja Incluir ?""
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
                THEN DO :
                    find ctpromoc where recid(ctpromoc) = a-seerec[frame-line].
                    i-recid = recid(ctpromoc).
                    run preco-inicial.
                    a-seerec = ?.
                    a-recid = recid(ctpromoc).
                    a-seeid = -1. 

                    next keys-loop.
                end. "    
         &otherkeys1 = "
            find ctpromoc where recid(ctpromoc) = a-seerec[frame-line].
            if keyfunction(lastkey) = ""NEW-LINE"" OR
               keyfunction(lastkey) = ""INSERT-MODE"" or
               keyfunction(lastkey) = ""I"" or
               keyfunction(lastkey) = ""i""
            then do:
                if bctpromoc.situacao <> ""M""
                then next keys-loop.
                color display normal 
                    ctpromoc.produtovendacasada with frame f-linha.
                run inclui. 
                hide frame f-linha no-pause.
                next bl-princ.
            end.
            if keyfunction(lastkey) = ""DELETE-LINE"" or
               keyfunction(lastkey) = ""CUT"" or
               keyfunction(lastkey) = ""E"" or
               keyfunction(lastkey) = ""e""
            then do:
                if bctpromoc.situacao <> ""M""
                then next keys-loop.
                sresp = no.
                message ""Confirma excluir da promocao classe venda casada"" 
                 ctpromoc.produtovendacasada ""?"" update sresp.
                if sresp 
                then do:
                    delete ctpromoc.
                    hide frame f-linha no-pause.
                    next bl-princ.
                end.
                next keys-loop.
            end.
            "
        &form   = " frame f-linha 8 down row 9 column 25 
                    title "" Classe venda casada "" 
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
            ctpromoc.tipo = "CLASSE"
            .
        do on error undo:
            update  ctpromoc.produtovendacasada go-on(F7)
                with frame f-linha .
            if keyfunction(lastkey) = "HELP"
            THEN UNDO.
            find clase where clase.clacod = ctpromoc.produtovendacasada 
                                no-lock no-error.
            if not avail clase
            then do:
                message color red/with
                    "Classe " ctpromoc.produtovendacasada " nao cadastrada." 
                    view-as alert-box.
                undo.
            end.
            disp clase.clanom with frame f-linha.
        end.
   end.
   find first ctpromoc where 
                   ctpromoc.sequencia = bctpromoc.sequencia and
                   ctpromoc.produtovendacasada > 0 and
                   ctpromoc.tipo begins "CLASSE"
                   no-lock no-error.
    if not avail ctpromoc 
    then do:                   
        assign 
           bctpromoc.qtdbrinde     = 0
           .
    end.
end procedure.

procedure preco-inicial:
    def var tp-index as int.
    def var v-tp as char format "x(15)" extent 4
        init["  PLANO VALOR  ",
             " PLANO PARCELA ",
             " PRODUTO VALOR ",
             " PRODUTO % "].
             
    disp v-tp with frame f-tp 1 down row 10 no-box
             no-label overlay column 60 1 column.
    choose field v-tp with frame f-tp.
    tp-index = frame-index.
            
    hide frame f-tp no-pause.
    display v-tp[tp-index]
                with frame tp-mes row 8 column 60 no-box 1 down
                overlay no-label color message.
 
    if  tp-index = 4
    then do transaction:
        update ctpromoc.valorprodutovendacasada
            with frame f-linha.
        ctpromoc.tipo = "CLASSE=|PERCENTUAL=|".
    end.
    else if  tp-index = 3
    then do transaction:
        update ctpromoc.valorprodutovendacasada
            with frame f-linha.
        ctpromoc.tipo = "CLASSE=|VALOR=|".
    end.   
    else do:
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
        &ofield = " 
                    fctpromoc.valorprodutovendacasada  
                    when avail fctpromoc 
                        column-label ""Valor"" format "">>,>>9.99"" "
        &where = " ectpromoc.sequencia = bctpromoc.sequencia and
                   ectpromoc.produtovendacasada = 0  and
                   ectpromoc.fincod <> ? "
        &aftfnd1 = " find finan where finan.fincod = ectpromoc.fincod
                        no-lock no-error. 
                     find first fctpromoc where
                        fctpromoc.sequencia = ectpromoc.sequencia and
                        fctpromoc.produtovendacasada = 
                            ctpromoc.produtovendacasada and
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
                        fctpromoc.produtovendacasada = 
                            ctpromoc.produtovendacasada and
                        fctpromoc.fincod = ectpromoc.fincod
                           no-error.
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
                                fctpromoc.produtovendacasada = 
                                    ctpromoc.produtovendacasada.
                    end.
                    do transaction:
                        update fctpromoc.valorprodutovendacasada
                            with frame f-linha1.
                        fctpromoc.campolog2 = no.
                        if tp-index = 2
                        then fctpromoc.campolog2 = yes.
                    end.
                    next keys-loop.
            end. "
        &form   = " frame f-linha1 7 down row 10 column 57  
                    title "" Planos valor inicial "" 
                      color with/cyan  no-label"
    }                        
    if keyfunction(lastkey) = "end-error"
    then do:
        hide frame f-linha1 no-pause.
        hide frame tp-mes no-pause.
        leave bl-princ1.
    end.    
    end.
    end. 
end procedure.


