/******************************************************************************
* Coanfecx.p    Consultas Analiticas de Caixas (Parte II - Analitico) 
*               Individuais ou por Estabelecimentos
* Data     :    13/05/2009
* Autor    :    Antonio Maranghello
*
******************************************************************************/
pause 0.

def input parameter p-descricao-ana as char format "x(75)".
def input parameter p-valor-anali   as dec .

def shared temp-table tt-dados
    field etbcod like estab.etbcod
    field data as date
    field vlpraz like plani.platot
    field vlvist like plani.platot
    field vlentr like plani.platot
    field vlpres like plani.platot
    field vljuro like plani.platot
    field vldesc like plani.platot
    field vldevolucao like plani.platot
    field vtotglo like plani.platot
    field vlnov like plani.platot
    field total-cheque-devolvido like plani.platot
    field ct-praz as int
    field ct-vist as int
    field ct-entr as int
    field ct-pres as int
    field ct-juro as int
    field ct-desc as int
    field ct-devolucao as int
    field gloqtd as int
    field ct-nov as int
    field conta-cheque-devolvido as int
    field vl-pagar like plani.platot
    field vchedia like plani.platot
    field vpredre like plani.platot
    field vdeposito like plani.platot
    field aux-vl-cart like plani.platot
    field vl-cart like plani.platot
    field qtd-cart as int
    field deposito like plani.platot
    field vlpagcartao like plani.platot
    field vljurpre like plani.platot
    field val-pago like plani.platot
    field ct-pagcartao as int
    field numtra as int
    field qtd-pagar as int
    field vlpagar like plani.platot
    field vlauxt like plani.platot
    field vdevolucao like plani.platot
    field vvalor-cartpre like plani.platot
    index ind01 etbcod data.
    
def var v-filcaixa      as int format ">>9".
def var v-soma-caixa    as dec.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var tipodocu        as int.
 
def var esqcom2         as char format "x(12)" extent 5
            initial ["F4-Retorna Resumo","","","",""].

def var esqcom1         as char format "x(12)" extent 5
            initial [""," Filtra Caixa ","","",""].

def var v-descri        as char format "x(70)".
def shared temp-table tt-caixa-anali no-undo
    field etbcod  like estab.etbcod
    field cxacod  like caixa.cxacod label "Caixa"
    field numdoc  as   char         label "Documento" format "x(25)"
    field data    as   date format "99/99/9999"
    field tpreg   as   int              
    field clifor  like titulo.clifor    
    field vlcob   like titulo.titvlcob
    field vltrans  like titulo.titvlcob        
    field ctaprazo as int
    field ctavista as int
    field parcela  like titulo.titpar    /* 0 - 999 (zero a Vista) */
    field modcod as char               /* CRE - VDV - VDP - ENT etc... */ 
    field qttrans as int
    field moecod like titulo.moecod
    field cxmhora as int
     index key1  etbcod 
                clifor
                data    
                cxmhora
                cxacod 
                numdoc 
                tpreg
    index key2  numdoc.  

def shared temp-table tt-aux-lis like tt-caixa-anali.
def buffer btt-aux-lis for tt-aux-lis.

{admcab.i}
{setbrw.i}

form
    esqcom1
    with frame f-com1
                 row 8 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.


form " " 
     " "
     with frame f-linha 10 down color with/cyan /*no-box*/
     centered.
                                                                         

disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     


/***** TELA ANALITICA *****/

v-filcaixa = 0.
v-soma-caixa = 0.
find first tt-aux-lis.
tipodocu = tt-aux-lis.tpreg.

l1: repeat:
    assign
    a-seeid = -1 a-recid = -1 a-seerec = ?
    esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    disp string(" Analitico " + p-descricao-ana) @ v-descri
            with frame f1 1 down width 80                                       
            color message no-box no-label row 7.
    pause 0.
    
    {sklclstb.i  
         &help = 
        "F4=Retorna Resumo F8=Filtra Caixa"
        &color = with/cyan
        &file  =  tt-aux-lis 
        &cfield = tt-aux-lis.numdoc 
        &noncharacter = /*
        &ofield = "
        tt-aux-lis.numdoc format ""x(15)""
        tt-aux-lis.clifor
        tt-aux-lis.etbcod tt-aux-lis.cxacod 
        tt-aux-lis.data column-label ""Dt.Caixa""  
        tt-aux-lis.parcela column-label ""Par"" 
        tt-aux-lis.vltrans format ""->>>,>>>,>>9.99""
        column-label ""Valor"" "    
        else 
        tt-aux-lis.etbcod tt-aux-lis.cxacod 
        tt-aux-lis.data column-label ""Dt.Caixa""
        tt-aux-lis.vltrans format ""->>>,>>>,>>9.99""
        column-label ""Valor"" " 
        &aftfnd1 = " "
        &where  = " tt-aux-lis.cxacod = 
                (if v-filcaixa <> 0 then v-filcaixa else tt-aux-lis.cxacod) 
                "
        &aftselect1 = " run aftselect.
                       a-seeid = -1.
                       if esqcom1[esqpos1] = ""  XXXX "" 
                       then do:
                          next l1.
                       end.
                       else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  " 
        &otherkeys1 = " run controle. "
        &locktype = " no-lock "
        &form   = " frame f-linha row 8 width 80"
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
    clear frame f-linha all.
    clear frame f-linha1 all.
    clear frame f-linha2 all.

    if esqcom1[esqpos1] = "  IMPRIME"
    then do:
        run relatorio.
    end.
    
    if esqcom1[esqpos1] = "  XXXX "
    THEN DO on error undo:
    end.
    
    
end procedure.

procedure controle:
        def var ve as int.
        
            if keyfunction(lastkey) = "CLEAR"
            then do:
                assign v-filcaixa = 0.
                update v-filcaixa label "Caixa Especifico"
                 with frame fpede side-labels no-box row 22 col 15 overlay.
                hide frame fpede no-pause.
                
                if v-filcaixa > 0 
                then do: 
                   find first tt-aux-lis where tt-aux-lis.cxacod = v-filcaixa                             no-error.
                   if not avail tt-aux-lis 
                   then v-filcaixa = 0. 
                   else do:
                        v-soma-caixa = 0.
                        for each btt-aux-lis 
                                where btt-aux-lis.cxacod = v-filcaixa:
                            assign 
                            v-soma-caixa = v-soma-caixa + btt-aux-lis.vltrans.
                        end.
                        disp "Total do Caixa" string(v-filcaixa,">>9") 
                        ": R$" v-soma-caixa format "->>>,>>>,>>9.99" no-label 
                        with frame f-caixa-esp row 22 col 15 overlay no-box.
                    end.
                end.
                else hide frame f-caixa-esp no-pause. 
                assign a-seeid = -1 a-recid = -1 a-seerec = ?.
                next.
            end.
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

