{admcab.i}
{setbrw.i}


def stream tela.
output stream tela to terminal.

def var v-ok as logical .
def var varqexpo as char format "x(45)".
def var vretorno as logical init no.
def var vqtd-lj  as int.
def var vnumero  like plani.numero init 0.
def var j      as int.
def var vdt    as date.
def var v-kont as int.
def var vetbcod like estab.etbcod.
def var vdtini  as date format "99/99/9999".
def var vdtfin  as date format "99/99/9999".
def var vdata   like plani.pladat.
def var v-descri as char format "x(50)".
def var v-vlote-che as dec format ">,>>>,>>9.99" .
def var v-vbate-che  as dec format ">,>>>,>>9.99" initial 0.

def buffer bprodu for produ.

def var esqcom1         as char format "x(15)" extent 5
    initial ["INCLUI ","  MARCA ", "DESMARCA", "  INVERTE TUDO ","   "].
def var esqcom2        as char format "x(15)" extent 5          
            initial ["F4- Retorna","F1- Confirma","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["",
             "",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial [" ",
            " ",
            " ",
            " ",
            " "].
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.

form
    esqcom1
    with frame f-com1
                 row 6 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2   
                 row 18 no-box no-labels side-labels column 1
                 centered.

assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

form " " 
     " "                
     with frame f-linha 6 down color with/cyan /*no-box*/
     centered.                              
                                                 
disp " " with frame f2 1 down width 80 color message 
        no-box no-label                row 20.             

def temp-table tw-plani
    field etbcod     like plani.etbcod 
    field platot     like plani.platot
    field numero     like plani.numero
    field placod     like plani.placod
    field pladat     like plani.pladat 
    field marca      as logical format "********/" label "Seleciona"
    field desti      like plani.desti
    field vrecid     as recid .

def temp-table tt-lj
    field etbcod like estab.etbcod.
l2:
repeat:
    vetbcod = 0.
    vnumero = 0.
    hide frame f2 no-pause.
    hide frame f-com1 no-pause.
    hide frame f-com2 no-pause.
    hide frame f-linha no-pause.
    clear frame f1 no-pause.
    update vetbcod label "Estab.Desti " with frame f1.
    find tt-lj where tt-lj.etbcod = vetbcod no-lock no-error.
    if not avail tt-lj then do:
        create tt-lj.
        assign tt-lj.etbcod = vetbcod.
    end.
    vqtd-lj = 0.
    for each tt-lj where
             tt-lj.etbcod > 0 no-lock:
        vqtd-lj = vqtd-lj + 1.
    end.        
    if vqtd-lj = 1
    then do:
        find first tt-lj where tt-lj.etbcod > 0 no-error.
        vetbcod = tt-lj.etbcod.
        disp vetbcod label "Estab.Desti"  with frame f1 side-labels.
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if avail estab
        then display estab.etbnom no-label format "x(50)"  with frame f1.
    end.
    else do:
        vetbcod = 0.
        disp "Selecionadas " + STRING(VQTD-LJ) + 
             " filiais"
              @ estab.etbnom 
              with frame f1.
    end. 
    
    assign vdtini = today
           vdtfin = today.
    
    update vdtini   label "Data Inicial " format "99/99/9999" 
           vdtfin   label "Data Final   " format "99/99/9999"
           with frame f1.

    assign vretorno = no.
    run Pi-notas-transf.
    if vretorno = yes then do:
        sresp = no.
        message "Confirma gerar arquivo?" update sresp.
        if sresp 
        then do:
            run Pi-Gera-Arquivo.
        end.
        leave l2.
    end.
end.


procedure Pi-notas-transf.

    for each tw-plani:
        delete tw-plani.
    end.

    do vdt = vdtini to vdtfin:
        for each estab where estab.etbcod < 900 no-lock.
            if vetbcod > 0
            then do.
                find first tt-lj where tt-lj.etbcod = estab.etbcod
                           no-lock no-error.
                if not avail tt-lj
                then next.
            end.
            for each plani where plani.movtdc = 6            and
                                  plani.desti = estab.etbcod  and
                                  plani.pladat = vdt and
                                  (plani.emit = 993 or
                                   plani.emit = 995 or
                                   plani.emit = 998) no-lock.

                find first tw-plani where tw-plani.etbcod = plani.etbcod and
                            tw-plani.pladat = plani.pladat and 
                            tw-plani.numero = plani.numero no-error.
                
                if not avail tw-plani then create tw-plani.
                assign tw-plani.numero  = plani.numero
                        tw-plani.etbcod  = plani.etbcod
                        tw-plani.placod  = plani.placod 
                        tw-plani.platot  = plani.platot
                        tw-plani.desti   = plani.desti
                        tw-plani.marca   = no
                        tw-plani.pladat  = plani.pladat 
                        tw-plani.vrecid  =  recid(plani).
            end.
        end.
    end.
    find first tw-plani no-lock no-error.
    if not avail tw-plani
    then do:
        message "Nada Gerado com parametros informados" view-as alert-box.
        undo, retry.
    end.

    do j = 1 to 5:
        color display normal esqcom1[j] with frame f-com1.
    end.

    assign esqpos1 = 1.
    disp esqcom1 with frame f-com1 overlay.
    color display message esqcom1[1] with frame f-com1.
    disp esqcom2 with frame f-com2 overlay.   


    assign  a-seeid = -1 a-recid = -1 a-seerec = ?
            esqpos1 = 1 esqpos2 = 1
            vretorno = no. 
  
    l1: repeat:

        disp esqcom1 with frame f-com1 overlay.
        disp esqcom2 with frame f-com2 overlay.
        clear frame f-linha all.
        hide frame f-linha no-pause.
/***
        hide frame f1 no-pause.
        clear frame f1 no-pause.
***/   
        pause 0.
        assign v-descri = " NOTAS FISCAIS DE TRANSFERENCIA - ESTAB. "  + 
        string(vetbcod).
        disp v-descri with frame f10 width 60                                            color message no-box no-label row 7 centered.
        {sklclstb.i  
            &color = with/cyan
            &file  =  tw-plani 
            &cfield = tw-plani.marca
            &noncharacter = /* 
            &ofield = "tw-plani.numero tw-plani.etbcod tw-plani.pladat
                       tw-plani.platot tw-plani.desti " 
            &aftfnd1 = " "
            &where   = " "
            &aftselect1 = " run aftselect.
                        a-seeid = -1.
                       /*
                       if esqcom1[esqpos1] = ""  MARCA "" or
                          esqcom1[esqpos1] = ""DESMARCA"" or
                          esqcom1[esqpos1] = ""  INVERTE TUDO ""
                       then next l1.
                       else */
                     next l1. "
            &go-on = TAB 
            &naoexiste1 = "  " 
            &otherkeys1 = " run controle.
                            if keyfunction(lastkey) = ""GO"" 
                            then leave l1." 
            &locktype = " "
            &form   = " frame f-linha overlay"
         }   

         if keyfunction(lastkey) = "end-error"  or keyfunction(lastkey) = "GO"
         then DO:
            leave l1.       
         END.
    end.
    
    hide frame f-com1 no-pause.
    hide frame f-com2 no-pause.
    hide frame f10 no-pause.
    hide frame f11 no-pause.
    hide frame ff2 no-pause.
    hide frame f-linha no-pause.
    hide frame f1 no-pause.
end procedure.

procedure Aftselect.
  clear frame f-linha1 all.
    if esqcom1[esqpos1] = "INCLUI  "
    then do on error undo:
        run p-inclui.
    end.
    if esqcom1[esqpos1] = "  MARCA   "
    then do on error undo:
       find current tw-plani no-error. 
       if avail tw-plani then do:
           assign tw-plani.marca = yes.
       end. 
    end.
    if esqcom1[esqpos1] = "DESMARCA"
    then do on error undo:
       find current tw-plani no-error.
       if avail tw-plani then do:
           assign  tw-plani.marca = no.
       end.    
    end.
    if esqcom1[esqpos1] = "  INVERTE TUDO "
    then do on error undo:
        for each tw-plani :
           if tw-plani.marca = yes 
           then assign tw-plani.marca = no.
           else assign tw-plani.marca = yes.
        end.
    end.
end procedure.

Procedure Controle.

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
                    do ve = 1 to 5:
                    color display normal esqcom1[ve] with frame f-com1.
                    end.
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
            if keyfunction(lastkey) = "GO"
            then do:
                    vretorno = yes .
                    leave.
            end. 

 end procedure.

Procedure Pi-Gera-Arquivo.
def var vgera AS INT INIT 0.
def var vean as char.

do /*for each estab where /*estab.etbcod < 900 or
                     estab.etbcod > 990*/ no-lock*/ .  
 
    /*
    if vetbcod > 0
    then do.
        find first tt-lj where tt-lj.etbcod = estab.etbcod no-lock no-error.
        if not avail tt-lj
        then next.
    end.
    */
    
    find first tw-plani where /*tw-plani.etbcod = estab.etbcod*/
                          tw-plani.marca
                        no-lock no-error.
    if not avail tw-plani
    then next.
        
    varqexpo = "/admcom/confer_android/" +
            "CONF" + string(vetbcod,"999") + ".txt".
/*
varqexpo =  "/admcom/custom/nede/arquivos/" +
            "CONF" + string(vetbcod,"999") + ".txt".
*/

/***
message varqexpo. pause.
***/                            /*
    output to value(varqexpo).    */

    for each tw-plani where 
                    /*tw-plani.etbcod = estab.etbcod and*/
                            tw-plani.marca,
        first plani where recid(plani) = tw-plani.vrecid no-lock 
                        break by plani.desti
                        :
        if first-of(plani.desti)
        then do.
            varqexpo = "/admcom/confer_android/" +
                "CONF" + string(plani.desti,"999") + ".txt".
            output to value(varqexpo).
        end.
/***
    pause 1 no-message.
***/    /*
        find first plani where recid(plani) = tw-plani.vrecid no-lock no-error.
        if not avail plani then next.*/
    
        for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat  no-lock:

            find produ where produ.procod = movim.procod no-lock no-error.
            find clase where clase.clacod = produ.clacod no-lock no-error.

            assign vean = "".
        
            if avail clase and
               (clase.clasup = 100
                 or clase.clasup = 190
                 or clase.clasup = 200)
            then do:
                vean = "".
                if length(produ.proindice) = 13
                then vean = produ.proindice.   
            end.
        
            if not can-find( first kit where kit.procod = produ.procod)
            then do:
                put plani.desti  format "999"
                    plani.numero format "999999999" 
                    movim.procod format "99999999"
                    vean         format "x(14)" 
                    produ.pronom format "x(26)" 
                    movim.movqtm format "9999"
                    "00000"
                    skip.                
            end.
            else do:        
                for each kit where kit.procod = produ.procod no-lock
                             by kit.itecod:            
                    find first bprodu where bprodu.procod = kit.itecod
                                                    no-lock no-error.
            
                    put plani.desti  format "999"
                        plani.numero format "999999999"
                        movim.procod format "99999999"
                        vean         format "x(14)"
                        produ.pronom format "x(26)"
                        movim.movqtm format "9999"
                        "00000"
                        kit.itecod     format "99999999".
                    
                    if avail bprodu
                    then put bprodu.pronom  format "x(26)".
                
                    put skip.

                end.
            end.
        
            vgera = 1.
        end.
        if last-of(plani.desti)
        then do.
            varqexpo = "/admcom/confer_android/" +
                "CONF" + string(plani.desti,"999") + ".txt".
            output close.
            pause 0.
            display stream tela
                    "Enviando Estab" plani.desti
                    with frame ftela side-label 1 down centered 
                                row 10 color message .     
        output to trcolnot.log.    
        unix silent value("chmod 777 " + varqexpo).
        unix silent 
value("wget \http://desenv.lebes.com.br/confdescarga/importa_conf.php?filial=" ~ +  string(plani.desti,"999")).
        output close.
                                       
        end.
    end.
    /*
    output close. /* tw-plani */
    unix silent 
value("wget \http://desenv.lebes.com.br/confdescarga/importa_conf.php?filial=" +  string(estab.etbcod,"999")). */

end. /* estab */

end procedure.

procedure p-inclui:

    /*vetbcod = 0.   */
    vnumero = 0.
    hide frame f2 no-pause.
    hide frame f-com1 no-pause.
    hide frame f-com2 no-pause.
    hide frame f-linha no-pause.
    unix silent 
 value("wget \http://desenv.lebes.com.br/confdescarga/importa_conf.php?filial="
+ string(vetbcod,"999")).
    hide frame f1 no-pause.
    clear frame f1 no-pause.
    disp vetbcod label "Estab.Desti " with frame f1.
    find tt-lj where tt-lj.etbcod = vetbcod no-lock no-error.
    if not avail tt-lj then do:
        create tt-lj.
        assign tt-lj.etbcod = vetbcod.
    end.
    vqtd-lj = 0.
    for each tt-lj where
             tt-lj.etbcod > 0 no-lock:
        vqtd-lj = vqtd-lj + 1.
    end.        
    if vqtd-lj = 1
    then do:
        find first tt-lj where tt-lj.etbcod > 0 no-error.
        vetbcod = tt-lj.etbcod.
        disp vetbcod label "Estab.Desti"  with frame f1.
        find estab where estab.etbcod = vetbcod no-error.
        if avail estab
        then display estab.etbnom no-label format "x(50)" with frame f1.
    end.
    else do:
        vetbcod = 0.
        disp "Selecionadas " + STRING(VQTD-LJ) + 
             " filiais"
              @ estab.etbnom 
              with frame f1.
    end.
    update vdtini   label "Data Inicial " format "99/99/9999" 
           vdtfin   label "Data Final   " format "99/99/9999"
           with frame f1.
    assign vretorno = no.
    do vdt = vdtini to vdtfin:
        for each tt-lj :
             for each plani where plani.movtdc = 6            and
                                  plani.desti = tt-lj.etbcod  and
                                  plani.pladat = vdt          and
                                  (plani.emit = 993 or
                                  plani.emit  = 995 or
                                  plani.emit  = 998)
                                  no-lock:
                find first tw-plani where tw-plani.etbcod = plani.etbcod and
                            tw-plani.pladat = plani.pladat and 
                            tw-plani.numero = plani.numero no-error.
                if not avail tw-plani then create tw-plani.
                assign tw-plani.numero  = plani.numero
                        tw-plani.etbcod  = plani.etbcod
                        tw-plani.placod  = plani.placod 
                        tw-plani.platot  = plani.platot
                        tw-plani.desti   = plani.desti
                        tw-plani.marca   = no
                        tw-plani.pladat  = plani.pladat 
                        tw-plani.vrecid  =  recid(plani).
             end.
        end.
    end.

end procedure.
