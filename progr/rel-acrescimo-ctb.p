{admcab.i}

def var ii as int.
def var vtsint as logical format "Sim/Nao".
def var vvt1 as int init 0 format ">>>>9".
def var vvt2 as int init 0 format ">>>>9".
def var vvt3 like titulo.titvlcob init 0 format ">>,>>>,>>9.99".
def var vvt4 like titulo.titvlcob init 0 format ">>,>>>,>>9.99".
def var vvt5 like titulo.titvlcob init 0 format ">>>,>>9.99".

def buffer bstitulo for titulo.
def buffer bestab   for estab.

def var par-paga as int.
def var pag-atraso as log.
def buffer ctitulo for fin.titulo.

def temp-table tt-sint-cob
    field etbcod like estab.etbcod
    field cobcod like titulo.cobcod
    field qtdcli as int
    field qtdpar as int
    field vlrpar like titulo.titvlcob
    field vlrpri like titulo.titvlcob
    field vlracr like titulo.titvlcob
    field vlrseg like titulo.titvlcob
    index ind-1 etbcod
                cobcod.

def var vlmax like titulo.titvlcob.

def var vdtvenini as date format "99/99/9999".
def var vdtvenfim as date format "99/99/9999".
def var vsubtot  like titulo.titvlcob.
def var vetbcod  like estab.etbcod.
def var vetbcod1 like estab.etbcod.

def var valfa    as log.
def var varquivo as char.

def var varqsai as char.

def temp-table tt-titulo like titulo.

def var qtd-cli as int.
def var qtd-par as int.
def var val-cob as dec.

def var vdifer as dec.
def var tqtd-cli as int.
def var tqtd-par as int.
def var tval-cob as dec.
def var p-principal as dec.
def var p-acrescimo as dec.
def var p-seguro as dec.
def var p-juros as dec.
def var p-crepes as dec.
def var vdata as date.
 
form tt-sint-cob.etbcod column-label "Filial"
                 tt-sint-cob.cobcod cobra.cobnom 
                 tt-sint-cob.qtdpar  column-label "Parcelas"
                 tt-sint-cob.vlrpar  column-label "Valor!Parcelas" 
                 tt-sint-cob.vlrpri  column-label "Valor!Principal"
                 tt-sint-cob.vlracr  column-label "Valor!Acrescimo" 
                 with frame f-resumo down no-box.
                 down with frame f-resumo width 120.  
 
form "Aguarde processamento..."
    with frame f-disp row 10 1 down centered no-box color message width 80
    .
repeat:
    
    update vetbcod colon 20 vetbcod1 label 'até' with frame f2.
    find estab where 
         estab.etbcod = vetbcod 
         no-lock no-error.
    if not avail estab
    then do:
        message "Primeiro estabelecimento invalido.".
        undo.
    end.
    find bestab where
         bestab.etbcod = vetbcod1
         no-lock no-error.
    if not avail bestab then do:
        message "Segundo estabelecimento inválido.". 
    end.      
    if vetbcod > vetbcod1 then do:
        message "Primeiro estabelecimento deve ser menor que o segundo.".
        undo.
    end. 
    display  skip estab.etbnom  no-label at 22 ' - ' 
        bestab.etbnom no-label with frame f2.
    update vdtvenini label "Vencimento Inicial" colon 20
           vdtvenfim label "Final"
                with row 4 side-labels width 80 
                 frame f2.

    vlmax = 0.
    
    assign
        qtd-cli = 0
        qtd-par = 0
        val-cob = 0
        tqtd-cli = 0
        tqtd-par = 0
        tval-cob = 0
        .
         
    for each tt-sint-cob : delete tt-sint-cob. end.
    
    for each estab where  estab.etbcod >= vetbcod
                      and estab.etbcod <= vetbcod1
                       no-lock:
        disp estab.etbcod column-label "Filial" with frame f-disp .
        pause 0.   
        do vdata = vdtvenini to vdtvenfim:
            disp vdata column-label "Data" with frame f-disp.
            pause 0.                
            for each titulo  
                             where    titulo.empcod = 19 and
                                      titulo.titnat = no and
                                      titulo.modcod = "CRE" and
                                      titulo.etbcod = estab.etbcod and
                                      titulo.titdtven = vdata  and
                                      titulo.titsit <> "EXC"  
                                      no-lock:

                find first clien where clien.clicod = titulo.clifor 
                            no-lock no-error.
                if not avail clien then next.            

                assign
                    p-principal = 0
                    p-acrescimo = 0
                    p-seguro = 0
                    p-juros = titulo.titjuro
                    .

                if titulo.cobcod = 1
                then assign
                        p-principal = titulo.titvlcob
                        p-acrescimo = 0.
                else do:   
                    run retorna-principal-acrescimo-titulo.p
                                        (input recid(titulo),
                                            output p-principal, 
                                            output p-acrescimo,
                                            output p-seguro,
                                            output p-crepes).
                    if p-acrescimo < 0
                    then assign
                         p-principal = titulo.titvlcob
                         p-acrescimo = 0.
                    vdifer = 0.
                    vdifer = (p-principal + p-acrescimo) - titulo.titvlcob.
                    if vdifer <> 0
                    then assign
                            p-principal = titulo.titvlcob
                            p-acrescimo = 0
                             .

                end.
                
                find first  tt-sint-cob where 
                            tt-sint-cob.etbcod = estab.etbcod and
                            tt-sint-cob.cobcod = titulo.cobcod 
                            no-error.

                if not avail tt-sint-cob
                then do :
                    create tt-sint-cob.
                    assign  tt-sint-cob.etbcod = estab.etbcod
                            tt-sint-cob.cobcod = titulo.cobcod.
                end.
                assign 
                    tt-sint-cob.vlrpar = tt-sint-cob.vlrpar + titulo.titvlcob
                    tt-sint-cob.qtdpar = tt-sint-cob.qtdpar + 1
                    tt-sint-cob.vlrpri = 
                            tt-sint-cob.vlrpri + p-principal /*+ p-seguro*/
                    tt-sint-cob.vlracr = tt-sint-cob.vlracr + p-acrescimo
                    tt-sint-cob.vlrseg = tt-sint-cob.vlrseg + p-seguro
                    .
            end.
        end.
    end.

    varquivo = "/admcom/relat/rel-acrescimo-ctb." + string(time).
    
        /* Sintetico */
        assign vvt1 = 0
               vvt2 = 0
               vvt3 = 0
               vvt4 = 0
               vvt5 = 0.

    {mdadmcab.i 
        &Saida     = "value(varquivo)"
        &Page-Size = "63"
        &Cond-Var  = "100"
        &Page-Line = "66"
        &Nom-Rel   = ""rel-acrescimo-ctb""
        &Nom-Sis   = """SISTEMA CONTABILIDADE"""  
        &Tit-Rel   = """RELATORIO DE CONTAS A RECEBER""" 
        &Width     = "100"
        &Form      = "frame f-cabcab"}

        view frame fcabs.
        
        for each tt-sint-cob break by tt-sint-cob.etbcod
                                   by tt-sint-cob.cobcod :
            find first cobra where cobra.cobcod = tt-sint-cob.cobcod
                    no-lock no-error.
            
            disp tt-sint-cob.etbcod column-label "Filial"
                 when first-of(tt-sint-cob.etbcod)
                 tt-sint-cob.cobcod cobra.cobnom 
                 tt-sint-cob.qtdpar  column-label "Parcelas"
                 tt-sint-cob.vlrpar  column-label "Valor!Parcelas" 
                 tt-sint-cob.vlrpri  column-label "Valor!Principal"
                 tt-sint-cob.vlracr  column-label "Valor!Acrescimo" 
                 with frame f-resumo .
                 down with frame f-resumo .  
            
            assign  vvt1 = vvt1 + tt-sint-cob.qtdcli
                    vvt2 = vvt2 + tt-sint-cob.qtdpar 
                    vvt3 = vvt3 + tt-sint-cob.vlrpar
                    vvt4 = vvt4 + tt-sint-cob.vlrpri
                    vvt5 = vvt5 + tt-sint-cob.vlracr
                    . 
        end.
        put skip(1).
        disp "      "  @ tt-sint-cob.etbcod
             "   "  @ tt-sint-cob.cobcod 
             "Total Geral -> " @ cobra.cobnom
             vvt2 @ tt-sint-cob.qtdpar
             vvt3 @ tt-sint-cob.vlrpar
             vvt4 @ tt-sint-cob.vlrpri
             vvt5 @ tt-sint-cob.vlracr
             with frame f-resumo .
             down with frame f-resumo.      

    output close.
    
    run visurel.p(varquivo,"").
    
end.

