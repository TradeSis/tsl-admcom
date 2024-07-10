{admcab.i}

def var vdtrefer as date.
def var vkont    as int format ">>>>>>>9".
def var vdias    as int.
def var vtiporel as log format "Analitico/Sintetico" init yes. 
def var vltot    like titulo.titvlcob.
def var vqtot    as int.               
def var varquivo as char format "x(30)".
def var vrelat   as log format "Sim/Nao"  init yes.
def var vconf    as log format "Sim/Nao"  init yes.
def temp-table tt-titulo
    field titnum        like titulo.titnum 
    field numero        like plani.num   
    field titdtven      like titulo.titdtven 
    field titdtemi      like titulo.titdtemi
    field modcod        like titulo.modcod
    field titvlcob      like titulo.titvlcob   
    field etbcod        like titulo.etbcod
    field titobs        like titulo.titobs
    field fdias         as int
    field vdias         as int
    field faixa         as char format "x(22)"
    field vltot         like  titulo.titvlcob
    field vqtd          as int  
    field marca         as char
    field titsit        like titulo.titsit
    field rectit        as recid
    index key1          rectit
                        titnum
                        titdtven
    index key2          titnum
                        fdias.
def buffer btt-titulo for tt-titulo.    
    
      
form 
    vdtrefer        colon 30  label "Dt. Referencia"
    with frame f-filtro row 3 side-label  width 80 
    title " Cartao Presente - Situacao ".                    

 update 
       vdtrefer 
       with frame f-filtro.   
        
for each tt-titulo.
    delete tt-titulo.
end.    
    

disp " ........... Gerando as informacoes ....... " format "x(50)"
     with frame f-inf centered row 12 overlay.      
        
     pause 0.       

/******* Anterior a Sol 26010       
for each titulo where
                titulo.empcod = 19 and
                titulo.titnat = yes and
                titulo.modcod = "CHP" and
                titulo.titsit = "LIB" and     
                titulo.titdtpag = ? and
                titulo.titdtemi >= vdtrefer no-lock by titulo.titnum.
*****************************/

vkont = 0.
/* Antonio Sol 26010 */
   for each titulo use-index titsit where
                titulo.empcod = 19 and
                titulo.titnat = yes and
                titulo.modcod = "CHP" and
                titulo.titsit = "LIB"
                no-lock by titulo.titnum.

                vkont = vkont + 1.
                if vkont modulo 50 = 0
                then do:
                    disp estab.etbcod 
                        titulo.titnum " Reg:"
                        vkont 
                        with frame f-inf2 row 15 
                        centered no-label no-box.
                    pause 0.
                end.
                if titulo.titdtpag <> ? then next.
                if titulo.titdtemi < vdtrefer then next.         
                find plani where plani.etbcod = 
                          int(acha("etbcodvendachp", titulo.titobs[1])) and 
                          plani.placod = 
                          int(acha("placodvendachp", titulo.titobs[1])) and
                          plani.movtdc = 5     
                          no-lock no-error.
 
                find first tt-titulo use-index key1
                              where tt-titulo.titnum    = titulo.titnum and
                                    tt-titulo.titdtven  = titulo.titdtven and
                                    tt-titulo.rectit    = recid(titulo)
                                    no-lock no-error.
         
                if not avail tt-titulo
                then do:
                        create tt-titulo.
                        assign
                                tt-titulo.titnum   = titulo.titnum
                                tt-titulo.numero   = if avail plani
                                    then plani.num else 0
                                tt-titulo.titdtemi = titulo.titdtemi
                                tt-titulo.etbcod   = if avail plani
                                        then plani.etbcod  else 0
                                tt-titulo.modcod   = titulo.modcod
                                tt-titulo.titvlcob = titulo.titvlcob
                                tt-titulo.rectit   = recid(titulo).
                end.
                
         vdias = 9999. 
         fdias = 9999. 
         
         if titulo.titdtven = today or titulo.titdtven = ?
         then do:
                tt-titulo.vdias = 0.
                tt-titulo.fdias = 1.
                tt-titulo.faixa = "- ZERO DIAS -".
         end.       
         else do:
                if titulo.titdtven < today
                then do: 
                    if today - titulo.titdtven > 150  
                    then do: 
                             tt-titulo.vdias = today - titulo.titdtven.
                             tt-titulo.fdias = 151.                
                             tt-titulo.faixa = " - ACIMA DE 150 DIAS - ".   
                    end.           
                    else. 
                    if today - titulo.titdtven <= 150 and
                       today - titulo.titdtven > 120
                    then do: 
                             tt-titulo.vdias = today - titulo.titdtven.       
                             tt-titulo.fdias = 150.                
                             tt-titulo.faixa = " - 150 DIAS - ".   
                    end.
                    else. 
                    if today - titulo.titdtven <= 120 and
                       today - titulo.titdtven > 90
                    then do: 
                             tt-titulo.vdias = today - titulo.titdtven.
                             tt-titulo.fdias = 120.                
                             tt-titulo.faixa = " - 120 DIAS - ".   
                     end.        
                    else.    
                    if today - titulo.titdtven <=  90 and
                       today - titulo.titdtven > 60
                    then do: 
                             tt-titulo.vdias = today - titulo.titdtven.
                             tt-titulo.fdias = 90.                
                             tt-titulo.faixa = " - 90  DIAS - ".   
                    end. 
                    else.
                    if today - titulo.titdtven <=60 and
                       today - titulo.titdtven > 30
                    then do: 
                             tt-titulo.vdias   = today - titulo.titdtven.
                             tt-titulo.fdias = 60.
                             tt-titulo.faixa = " - 60  DIAS - ".
                      end.         
                    else.  
                    if today - titulo.titdtven <= 30 and
                       today - titulo.titdtven > 0
                    then do: 
                             tt-titulo.vdias   = today - titulo.titdtven.
                             tt-titulo.fdias = 30.
                             tt-titulo.faixa = " - 30  DIAS - ".
                    end.
                end.             
         end.
end.

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
    initial ["","  CONSULTA"," EXCLUI"," ",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","","","",""].
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

form 
                    tt-titulo.marca         no-label format "x(1)"
                    tt-titulo.titnum        label "Cartao "
                    tt-titulo.titdtemi      label "Ativacao CP "
                    tt-titulo.numero        label "NF venda "
                                            format ">>>>>>>9"
                    tt-titulo.etbcod        label "Filial "
                                            format "999"  
                    tt-titulo.modcod        label "Modal "
                    tt-titulo.titvlcob      label "Valor "
                                            format "->>>,>>9.99"
                    tt-titulo.vdias         label "Dias Aberto" 
                                            format "999" 
                    tt-titulo.fdias         label "Faixa D" 
                                            format "999"  
                    with frame f-linha 10 down color with/cyan centered.
                    
form    
                    btt-titulo.faixa        label "     FAIXA     "
                    btt-titulo.vltot        label "  TOTAL FAIXA "   
                                            format ">>>,>>9.99"
                    btt-titulo.vqtd         label "  QTDE.CARTOES"
                    with frame f-linha1 10 down color with/cyan centered.
 
 
/********** Mostra Sintetico  *********/
                   
for each tt-titulo where tt-titulo.titnum <> ? 
            no-lock break by tt-titulo.fdias.        
        
        /* */
                find first btt-titulo use-index key2 
                where btt-titulo.fdias = tt-titulo.fdias and
                      btt-titulo.titnum = ? no-error.
                if not avail btt-titulo
                then do:
                    create btt-titulo.
                    assign
                        btt-titulo.fdias  = tt-titulo.fdias
                        btt-titulo.titnum = ? 
                        btt-titulo.faixa  = tt-titulo.faixa.
                end.
                assign
                    btt-titulo.vltot = btt-titulo.vltot + tt-titulo.titvlcob
                    btt-titulo.vqtd  = btt-titulo.vqtd + 1.
         /**/

end.


l2: repeat:
    hide frame f-com1.
    clear frame f-com1 all.
    esqcom1[2] = "  CONSULTA" . 
    esqcom1[3] = " EXCLUI". 
    esqcom1[4] = " IMPRIMIR" . 
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = btt-titulo   
        &cfield = btt-titulo.FAIXA
        &noncharacter = /*  
        &ofield = "                                                       
                    btt-titulo.vltot
                    btt-titulo.vqtd 
                  "  
        &aftfnd1 = " "
        &where  = " btt-titulo.titnum = ? and 
                    btt-titulo.titsit <> ""EXC"" "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.   
                        if esqcom1[esqpos1] =  "" EXCLUI"" or
                           esqcom1[esqpos1] =  "" IMPRIMIR""
                        then do:
                            next l2.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "     clear frame f-linha1 all.
                            message color red/white 
                            "" Nenhum registro encontrado. ""
                            view-as alert-box.
                            leave l2. " 
                            
        &otherkeys1 = " run controle. "
        &locktype = " "
        &form   = " frame f-linha1 row 4 centered down "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:

        leave l2. 
        
    END.
    end.


procedure aftselect:
    if esqcom1[esqpos1] = "  CONSULTA"
    THEN DO on error undo:
        RUN consulta.
        
    END.
    if esqcom1[esqpos1] = " EXCLUI"
    THEN DO:
    
    find first tt-titulo where tt-titulo.faixa = btt-titulo.faixa no-error.
        if not avail tt-titulo
        then next.
        else do: 
            vconf = no.
            message "Confirma exclusao dos cartoes da faixa selecionada ? " 
            update vconf.    
            
          if vconf
          then do transaction:
              for each btt-titulo where btt-titulo.faixa = tt-titulo.faixa.
                  find titulo where recid(titulo) = btt-titulo.rectit 
                                                     exclusive .
                    assign btt-titulo.titsit = "EXC".
                    if avail titulo then assign titulo.titsit = "EXC".     
              end .
          end.  
          if not vconf     
          then undo, leave. 
        end.
    END. 

    if esqcom1[esqpos1] = " IMPRIMIR"
    THEN DO on error undo:
     vtiporel = no.
     run relatorio.
    
    END.


end procedure.

procedure aftselect1:

    if esqcom1[esqpos1] = " MARCA"
    THEN DO:
        if tt-titulo.marca = "*"
        then tt-titulo.marca = " " .
        else tt-titulo.marca = "*".
        disp tt-titulo.marca with frame f-linha.
    END.

    if esqcom1[esqpos1] = " EXCLUI"
    THEN DO: 
        find first tt-titulo where tt-titulo.marca = "*" and 
                                   tt-titulo.titsit <> "EXC" no-error.
          if not avail tt-titulo
          then do:
             message "Selecione os cartoes para exclusao!" view-as alert-box.
          end.
          else do: 
            assign vconf = no.
            message "Confirma exclusao dos cartoes selecionados ? " 
            update vconf.    
              
            if vconf
            then do transaction:
                for each tt-titulo where tt-titulo.marca = "*" .
                    find titulo where recid(titulo) = tt-titulo.rectit 
                                                   exclusive.
                    assign tt-titulo.titsit = "EXC". 
                    if avail titulo then assign titulo.titsit = "EXC".
                    btt-titulo.vqtd = btt-titulo.vqtd - 1.     
                end.  
            end.  
            if not vconf     
            then undo, leave. 
          end. 
    END.

    if esqcom1[esqpos1] = " IMPRIMIR"
    THEN DO on error undo:
    vtiporel = yes.
    run relatorio.
    
    END.

end procedure.


procedure consulta:

for each tt-titulo where tt-titulo.fdias = btt-titulo.fdias 
                    and tt-titulo.titnum <> ? no-lock.

    if tt-titulo.marca = "*"
    then tt-titulo.marca = "".                    
end.                    
 
l1: repeat:
    hide frame f-com1.
    clear frame f-com1 all.
    esqcom1[2] = " MARCA".
    esqcom1[3] = " EXCLUI".
    esqcom1[4] = " IMPRIMIR" .
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1  esqpos2 = 1 . 
    disp esqcom1 with frame f-com1. 
    disp esqcom2 with frame f-com2. 
    hide frame f-linha no-pause.
    clear frame f-linha all.  
    {sklclstb.i  
        &color = with/cyan
        &file = tt-titulo   
        &cfield = tt-titulo.titnum
        &noncharacter = /*    */ 
        &ofield = " tt-titulo.marca
                    tt-titulo.titdtemi 
                    tt-titulo.numero 
                    tt-titulo.etbcod  
                    tt-titulo.modcod  
                    tt-titulo.titvlcob 
                    tt-titulo.vdias  
                    tt-titulo.fdias 
                  "  
        &aftfnd1 = " "
        &where  = " tt-titulo.fdias = btt-titulo.fdias 
                    and tt-titulo.titsit <> ""EXC""
                    and tt-titulo.titnum <> ?"
        &aftselect1 = " run aftselect1.
                        if esqcom1[esqpos1] = "" EXCLUI"" or 
                           esqcom1[esqpos1] =  "" IMPRIMIR""
                        then do:
                            next l1.
                        end.
                        else
                            next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  " 
        &otherkeys1 = " run controle. "
        &locktype = " "
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        hide frame f-linha.
        esqcom1[2] = "  CONSULTA" . 
        esqcom1[3] = " EXCLUI".   
        disp esqcom1 with frame f-com1.
        leave l1.
        
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


/************************** Relatorio *******************************/

procedure relatorio:

def var varquivo as char.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/" + string(setbcod) + "."
                    + string(time).     
    else varquivo = "..~\relat~\" + string(setbcod) + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "0"  
                &Cond-Var  = "130" 
                &Page-Line = "66" 
                &Nom-Rel   = ""relpre"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """CARTAO PRESENTE - PENDENTES "" +
                                  string(vdtrefer,""99/99/9999"")" 
                &Width     = "80"
                &Form      = "frame f-cabcab"}
      
      /********** Analitico ***********/

    if vtiporel 
    then do:
         for each tt-titulo where  tt-titulo.modcod = "CHP" and
                                   tt-titulo.titsit <> "EXC"
                            no-lock by tt-titulo.titnum.
                disp 
                    tt-titulo.titnum        label "Cartao "
                    tt-titulo.titdtemi      label "Ativacao CP "
                    tt-titulo.numero        label "NF venda "
                                            format ">>>>>>>9"
                    tt-titulo.etbcod        label "Filial "
                                            format "999"  
                    tt-titulo.modcod        label "Modal "
                    tt-titulo.titvlcob      label "Valor "
                                            format "->>>,>>9.99"
                    tt-titulo.vdias         label "Dias Aberto" 
                                            format "9999" 
                    tt-titulo.fdias         label "Faixa D" 
                                            format "9999"  
                    with frame f-analitico row 7 down width 80.
                    down with frame f-analitico.
         end.
    end.
      
      /********** Sintetico ***********/

    else do:
        for each btt-titulo where btt-titulo.titnum = ?  and
                                  btt-titulo.faixa  <> tt-titulo.faixa
                                  no-lock
                                   break by btt-titulo.fdias.     
                                  
                disp 
                    btt-titulo.faixa    label "     FAIXA     "         
                    btt-titulo.vltot    label "  TOTAL FAIXA "   
                                        format ">>>,>>9.99"
                    btt-titulo.vqtd     label "  QTDE.CARTOES"     
                    with frame f-sintetico row 7 down width 80.
                    down with frame f-sintetico.                     
        end.               
    
    end. /*else */

    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
    

end procedure.


      
