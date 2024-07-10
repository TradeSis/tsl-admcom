/* 11102022 helio ID 149575 - Geração de arquivos de Empréstimos Loja de hora em hora */
/* 18022022 helio carteira FIDC FINANCEIRA */


{admcab.i}
def var coperacao as char.
def var cpropriedade as char.
def var cstatus   as char.
def var cnatureza as char.
def var soperacao as char extent 7 format "x(10)"
    initial ["Contrato",
             "Novacao",
             "Emprestimo", /* #11102022 */
             "Pagamento",
             "Desenrola",
             "Estorno",
             "Cancelam"].

def var sstatus as char extent 5 format "x(14)"
    initial ["  Enviar",
             "  Enviado",
             "  Transferir",
             "  Lote",
             "  Erros"].
def var spropriedade as char extent 5 format "x(14)"
    initial [/*"  FIDC", helio 18022022*/
             "  Reenviar",
             "  p/Financeira",
             "  ",
             "  "].
             
def var snatureza as char extent 3 format "x(19)"
    initial ["  Emissoes",
             "  Pagamentos",
             "  "].
             
    
def var vtitle as char init "Operacoes Sicred".
def new shared var vdtini as date format "99/99/9999" label "De".
def new shared var vdtfin as date format "99/99/9999" label "Ate".             
form 
     vdtini
     vdtfin 
         with frame fcab
        no-labels
        row 3 no-box width 80
        color messages.
repeat:
        
disp vtitle  @ cobra.cobnom format "x(18)"
    with frame fcab.
    

def var vmes as int.
def var vano as int.
def var vdata as date.
def var vmesext         as char format "x(10)"  extent 12
                        initial ["Janeiro" ,"Fevereiro","Marco"   ,"Abril",
                                 "Maio"    ,"Junho"    ,"Julho"   ,"Agosto",
                                 "Setembro","Outubro"  ,"Novembro","Dezembro"] .


                  pause 0.
    assign 
           vmes   = 0
           vano   = 0
           vdtini = ?
           vdtfin = ?
           vdata  = ?.
    form
        space(5) vmesext[01] space(5) skip
        space(5) vmesext[02] space(5) skip
        space(5) vmesext[03] space(5) skip
        space(5) vmesext[04] space(5) skip
        space(5) vmesext[05] space(5) skip
        space(5) vmesext[06] space(5) skip
        space(5) vmesext[07] space(5) skip
        space(5) vmesext[08] space(5) skip
        space(5) vmesext[09] space(5) skip
        space(5) vmesext[10] space(5) skip
        space(5) vmesext[11] space(5) skip
        space(5) vmesext[12] space(5) skip
         with frame fmes
         row 7
         title "Periodo".



         
    disp sstatus
        with frame fstatus
                no-labels side-labels
                width 80
                no-box.
.
        
    choose field sstatus
        with frame fstatus.
    cstatus = trim(sstatus[frame-index]).

    if cstatus = "Transferir"  or cstatus = "Lote"
    then do:
        
        disp spropriedade
            with frame fpropriedade
            width 80
            no-labels side-labels 
            title "   ..PROPRIEDADE..   ".
        
        choose field spropriedade
            with frame fpropriedade.
        
        cpropriedade = trim(spropriedade[frame-index]).
    
    end.
    else
    if cstatus = "Erros" 
    then do:
        
        disp snatureza
            with frame fnatureza
            width 80
            no-labels side-labels 
            title "   ..OPERACAO..   ".
        
        choose field snatureza
            with frame fnatureza.
        
        cnatureza = trim(snatureza[frame-index]).
    
    end.
    else do:
    
        disp soperacao
        with frame foperacao
        width 80
        no-labels side-labels 
        title "   ..ERROS POR OPERACAO..   ".
        
        choose field soperacao
            with frame foperacao.
    
        coperacao = trim(soperacao[frame-index]).
    end.
    

    if cstatus = "ENVIAR"
    then do:
        vdtini = ?.
        vdtfin = ?.
                     disp 
         vdtini 
         vdtfin 
         with frame fcab.
    
    end.
    if cstatus = "ENVIADO"
    then do:
        /*
        display "Informe o Mes e Ano / Estabelecimento " at 23
            with frame fdad row 8  no-box width 81 color message.
          */
        pause 0.
        display vmesext
            with frame fmes no-label /*column 14*/ row 8.


        choose field vmesext
                help "Selecione o Mes"
               with frame fmes.
        vmes = frame-index.
        vano = year(today).
        update vano label "Ano" format "9999" colon 16
            help "Informe o Ano"
            validate (vano > 0,"Ano Invalido")
            with frame fano 
            side-label column 23 width 55 .
        assign
            vdtini   = date(vmes,01,vano)
            vano     = year(vdtini) + if month(vdtini) = 12 then 1 else 0
            vmes     = if month(vdtini) = 12 then 1 else month(vdtini) + 1
            vdata    = date(vmes,01,vano) - 1
            vdtfin   = vdata.
                     disp 
         vdtini 
         vdtfin 
         with frame fcab.

        disp
        vdtini no-labels
        vdtfin no-labels
        with frame fano.

    end.


    hide frame fmes no-pause.
    hide frame fdad  no-pause.
    hide frame fano no-pause.
    hide frame fstatus no-pause.
     hide frame foperacao no-pause.
    
    if cstatus = "ENVIAR" or
      cstatus = "ENVIADO"
    then do:   
        if coperacao = "CONTRATO" or
           coperacao = "NOVACAO" or
           coperacao = "EMPRESTIMO" /* #11102022 */
        then do:
            run fin/opesicemi.p (coperacao, cstatus).
        end.

        if coperacao = "PAGAMENTO" or
           coperacao = "DESENROLA" or /* Helio 13112023 - Desenrola Separado */
           coperacao = "CANCELAMENTO" or
           coperacao = "ESTORNO"
        then do:
            run fin/opesicpag.p (coperacao, cstatus).
        end.   
    end.    
    if cstatus = "Transferir" 
    then do: 
        if cpropriedade = "P/Financeira"
        then run fin/opesicemi.p ("TRANSFERE", cstatus).
        /** helio 18022022 else run fidc-importa.p.**/
    end.
    if cstatus = "Lote"
    then do:
        /** helio 18022022 if cpropriedade = "FDIC" then run cdlotefidc.p. **/
        if cpropriedade = "REENVIAR"
        then run fin/opesicemilotenvia.p.
    end.
    if cstatus = "Erros"
    then do:
        if cnatureza = "Emissoes" 
        then do:
            run fin/opesicemictrerrores.p ("ERRO").
        end.

        if cnatureza = "PAGAMENTOs"
        then do:
            run fin/opesicpagdocerrores.p ("ERRO").
        end.   
    
    end.
end.

 
