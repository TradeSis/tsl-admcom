{admcab.i}                           
{admcom_funcoes.i}  
            
def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.
def buffer fclase for clase.
def buffer gclase for clase.

def var vetccod  as char format "x(03)".
def var vforcod  like forne.forcod.
def var vmes2    as int format ">9".
def var vano2    as int format "9999".
def var vimp     as log format "Sim/Nao" initial no.
def var vmes     as int format ">9".
def var vetbcod  like estab.etbcod.
def var vclacod  like clase.clacod.
def var vcarcod  like caract.carcod.
def var vsubcod  like subcaract.subcod.
def var vdti     like pedid.peddat.
def var vdtf     like pedid.peddat.
def var varquivo as char.

def var vcla-cod like clase.clacod.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Imprime "," "," ", " "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Imprime ",
             " ",
             " ",
             " ",
             " "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].


form
    esqcom1
    with frame f-com1
                 row 8.5 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

def temp-table wped
    field pednum like pedid.pednum
    field forcod like pedid.clfcod
    field wvalor like pedid.pedtot
    field wabe   like pedid.pedtot format "->>>,>>9.99"
    field qtde   as int.
    
def var wacumabe as dec.

def temp-table tt-clase
    field clacod like clase.clacod
    field clanom like clase.clanom
    index iclase is primary unique clacod.

def var vacum like pedid.pedtot.

def var vordem as int.

def temp-table wcla
    field ord    as int
    /*
    field clacod like produ.clacod
    field clasup like clase.clasup
    */
    field prvenda like estoq.estvenda
    field pednum like pedid.pednum
    field forcod like pedid.clfcod
    field wvalor like pedid.pedtot
    field wabe   like pedid.pedtot format "->>>,>>9.99"
    field qtde   as int
    index wcla01 ord.
def buffer bwcla       for wcla.
def var vwcla         like wcla.forcod.

    
def var wacumabe1 as dec format "->>>,>>9.99".
def var vacum1 like pedid.pedtot format "->>>,>>9.99".
def var vacumqtd as int.
def var vacprvenda like estoq.estvenda.

def var vprvenda like estoq.estvenda.

def var vano as int format "9999".

repeat:
    for each tt-clase.
        delete tt-clase.
    end.

    for each wped.
        delete wped.
    end.
    
    assign vacum   = 0
           vforcod = 0
           wacumabe = 0
           vacumqtd = 0.

    for each wcla.
        delete wcla.
    end.
    
    vacum1 = 0.
    wacumabe1 = 0. 
    
    view frame f1.
    
    do on error undo:
        update vetbcod colon 16
            with frame f1 side-label width 80 color white/cyan.
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            message "Estabelecimento nao cadastrado" view-as alert-box.
            undo.
        end.
        find estab where estab.etbcod = vetbcod no-lock.
        display estab.etbnom format "x(15)" no-label with frame f1.
    end.
    
    do on error undo:
        update vforcod /*colon 16*/ with frame f1.
        if vforcod <> 0
        then do:
            find forne where forne.forcod = vforcod no-lock no-error.
            if not avail forne
            then do:
                message "Fornecedor nao Cadastrado.".
                undo.
            end.
            else disp forne.fornom format "x(15)" no-label with frame f1.
        end.
        else disp "GERAL" @ forne.fornom with frame f1.
    end.
    
     
    do on error undo. 
        update vcla-cod colon 16 with frame f1.
/*        vcla-cod = vclacod. */
        if vcla-cod <> 0
        then do:
            find clase where clase.clacod = vcla-cod no-lock no-error.
            if not avail clase
            then do:
                message "Classe nao cadastrada".
                undo.
            end.
            else display clase.clanom format "x(15)" no-label with frame f1.
        end.
        else disp "Todas" @ clase.clanom with frame f1.
    end.
    
    vclacod = vcla-cod.
    
    hide message no-pause.
    message "Aguarde... Filtrando Classes.".
    find first clase where clase.clasup = vclacod no-lock no-error.  
    if avail clase  
    then do: 
        run cria-tt-clase.
        hide message no-pause.
    end.  
    else do: 
        run cria-tt-clase.  
        hide message no-pause.
/*
        find clase where clase.clacod = vclacod no-lock no-error. 
        if not avail clase 
        then do: 
            message "Classe nao Cadastrada". 
            undo.
        end.
        create tt-clase. 
        assign tt-clase.clacod = clase.clacod
               tt-clase.clanom = clase.clanom.
*/               
    end.
    hide message no-pause.
    
    do on error undo:
        update vetccod /*colon 16*/ label "Estacao" with frame f1.
        if vetccod = "" or vetccod = "0"
        then do:
            vetccod = "G".
            disp vetccod with frame f1.
        end.
        if vetccod <> "G"  
        then do:
            find estac where estac.etccod = int(vetccod) no-lock no-error.
            if not avail estac
            then do:
                message "Estacao nao Cadastrado.".
                undo.
            end.
            else disp estac.etcnom format "x(15)" no-label with frame f1.
        end.
        else disp "GERAL" @ estac.etcnom with frame f1.
    end.
    
    do on error undo:
        update vcarcod colon 16 with frame f1.
        if vcarcod <> 0
        then do:
            find caract where caract.carcod = vcarcod no-lock no-error.
            if not avail caract
            then do:
                message "Caracteristica nao Cadastrado.".
                undo.
            end.
            else disp caract.cardes format "x(15)" no-label with frame f1.
        end.
        else disp "GERAL" @ caract.cardes with frame f1.
    end.

    scopias = ?.
    do on error undo:
        if avail caract
        then scopias = caract.carcod.
        if scopias <> ?
        then do:
            update vsubcod label "Sub-Caract" /*colon 16*/ with frame f1.
            if vsubcod <> 0
            then do:
                find subcaract where 
                        subcaract.carcod = caract.carcod and
                        subcaract.subcar = vsubcod no-lock no-error.
                if not avail subcaract
                then do:
                    message "Sub-Caracteristica nao Cadastrado.".
                    undo.
                end.
                else disp subcaract.subdes format "x(15)" no-label with frame f1.
            end.
            else disp "GERAL" @ subcaract.subdes with frame f1.
        end.
        else do:
            vsubcod = 0.
            disp vsubcod with frame f1.
        end.
    end.
    
    update vdti colon 16 label "Data Inicial"
           vdtf label "Data Final"
/*           vimp label "Deseja Imprimir ?" /* Solic 20797 - 25/04/08 */*/
           with frame f1.
           
/*
    if vimp = no
    then do:
        esqcom1[esqpos1] = "".
    end.
    else do:
        esqcom1[esqpos1] = " Imprime ".
    end.
*/    
 /********* Luciane */
 
        for each pedid where pedid.pedtdc = 1            and
                             pedid.etbcod = estab.etbcod and
                             pedid.peddti >= vdti         and
                             pedid.peddtf <= vdtf         no-lock:
            for each liped of pedid no-lock.
                find produ where produ.procod = liped.procod no-lock no-error.
                if not avail produ
                then next.
                /***
                find clase where clase.clacod = produ.clacod no-lock no-error.
                if not avail clase
                then next.
                ***/
                find first tt-clase where tt-clase.clacod = produ.clacod
                                no-lock no-error.
                if not avail tt-clase
                then next.                
                
                if vetccod <> "G"
                then if produ.etccod <> int(vetccod)
                     then next.
                     
                if vforcod <> 0
                then if produ.fabcod <> vforcod
                     then next.
                                if vcarcod = 0 and 
                   vsubcod = 0
                then.
                else do:
                    if vsubcod <> 0
                    then do:
                        find procaract where 
                             procaract.procod = produ.procod and
                             procaract.subcod = vsubcod      no-lock no-error.
                        if not avail procaract
                        then next.
                    end.   
                    else do:
                        find caract where caract.carcod = vcarcod no-lock.
                        for each subcaract where
                                 subcaract.carcod = caract.carcod no-lock:
                             find procaract where 
                                  procaract.procod = produ.procod and
                                  procaract.subcod = subcaract.subcod 
                                    no-lock no-error.
                             if not avail procaract
                             then next.
                        end.
                    end.
                end.
                
                find estoq where estoq.etbcod = estab.etbcod
                             and estoq.procod = produ.procod no-lock no-error.
                /*
                vprvenda = if avail estoq then estoq.estvenda else 0.
                */
                vprvenda = hispreco-venda-ant(produ.procod, pedid.peddat). 

                /* Antonio - situacao anterior Sol. 26152 */
                /*
                if liped.lipsep > 0
                then vprvenda = liped.lipsep.
                */
                /**/
                
                if vprvenda = 0 or vprvenda = ?
                then vprvenda = estoq.estvenda.
                
                find first wcla where wcla.prvenda = vprvenda and
                                      /*clacod = clase.clacod and
                                      wcla.clasup = clase.clasup and*/
                                      wcla.pednum = pedid.pednum and
                                      wcla.forcod = pedid.clfcod no-error.
            /*    if not avail wcla
                then leave.
                */
                /* */
                do:
                    create wcla.
                    assign /*wcla.clacod = clase.clacod
                           wcla.clasup = clase.clasup*/
                           wcla.prvenda = vprvenda
                           wcla.pednum = pedid.pednum
                           wcla.forcod = pedid.clfcod.
                end.
                wcla.wvalor = wcla.wvalor + (liped.lipqtd * vprvenda).
                wcla.wabe  = wcla.wabe + ((liped.lipqtd - liped.lipent)
                                 * vprvenda).
                wcla.qtde = wcla.qtde + liped.lipqtd.
               /* */
            end.
        end. 
        /***
        if vimp = yes /* Solic 20797 - 25/04/08 */ 
        then do.
            if opsys = "UNIX"
            then varquivo = "../relat/geral" + string(time).
            else varquivo = "..\relat\geral" + string(time).

            {mdad_l.i
              &Saida     = "value(varquivo)"
             &Page-Size = "0"
             &Cond-Var  = "130"
             &Page-Line = "66"
             &Nom-Rel   = ""GERAL""
             &Nom-Sis   = """SISTEMA DE ESTOQUE"""
             &Tit-Rel   = """MOVIMENTACAO GERAL FILIAL PERIODO DE """
            &Width     = "130"
            &Form      = "frame f-cabcab"}
        end.
             
        else do.
        /*** solic 19710 ***/
        for each wcla:     
               assign
                vacprvenda = vacprvenda + wcla.prvenda
                wacumabe1 = wacumabe1 + wcla.wabe.
                vacum = vacum + wcla.wvalor.                                   
                vacumqtd = vacumqtd + wcla.qtde.
        end.                                                                  
        display "VALOR TOTAL    " at 17
        vacprvenda
        vacumqtd format ">>>>>9"
        vacum 
        wacumabe1 at 64     
                with frame f6 width 80 no-box no-label
                       row 22 color message. 
        end.
            /*** solic 19710 ***/        
                                                  
        for each wcla break by wcla.forcod
                            by wcla.prvenda:
            /***                                
            if first-of(wcla.clacod)
            then do:
                find clase where clase.clacod = wcla.clacod no-lock.
                display clase.clacod column-label "Cod" format ">>>9"
                        clase.clanom format "x(15)" with frame f3.
            end.
            ***/
            if first-of(wcla.forcod)
            then do:
                find forne where forne.forcod = wcla.forcod no-lock.
                disp forne.forcod column-label "Cod" format ">>>>>>9"
                     forne.fornom format "x(15)" with frame f3.
            end.

            vacum1 = vacum1 + wcla.wvalor.

            display wcla.pednum  column-label "Pedido" 
                    wcla.prvenda (total by wcla.prvenda) column-label "Pr.Venda"
                    wcla.qtde(total by wcla.prvenda)
                        column-label "Qtde" format ">>>>>9"
                    wcla.wvalor(total by wcla.prvenda) column-label "Valor"
                    wcla.wabe(total by wcla.prvenda)   column-label "Em Aberto"
                                with frame f3 
                                            8 down width 80 row 8.5.
        end. 

        if vimp = yes    /* Solic 20797 - 25/04/08 */
        then do.
            output close.
            if opsys = "UNIX"
            then run visurel.p (input varquivo, input "").
            else do:
                {mrod.i}.
            end.
        end.
        */
    /*********/


vacprvenda = 0.
wacumabe1 = 0.
vacum = 0.
vacumqtd = 0.
            for each wcla:     
               assign
                vacprvenda = vacprvenda + wcla.prvenda
                wacumabe1 = wacumabe1 + wcla.wabe.
                vacum = vacum + wcla.wvalor.                                   
                vacumqtd = vacumqtd + wcla.qtde.
        end. 
vordem = 0.
def buffer buffwcla for wcla.
def var vqtde as int.
def var tvprvenda like estoq.estvenda.
def var tvqtde as int.
def var twvalor like pedid.pedtot.
def var twabe like pedid.pedtot.
def var vwvalor like pedid.pedtot.
def var vwabe like pedid.pedtot.

vprvenda = 0.
vqtde = 0.
vwvalor = 0.
vwabe = 0.
tvprvenda = 0.
tvqtde = 0.
twvalor = 0.
twabe = 0.

for each wcla
    break by wcla.forcod
          by wcla.prvenda.
    vordem = vordem + 1.
    wcla.ord = vordem.
    
    if not first-of(wcla.forcod)
    then assign wcla.forcod = ?.
    
    vprvenda = vprvenda + wcla.prvenda.
    vqtde = vqtde + wcla.qtde.
    vwvalor = vwvalor + wcla.wvalor.
    vwabe = vwabe + wcla.wabe.

    tvprvenda = tvprvenda + wcla.prvenda.
    tvqtde = tvqtde + wcla.qtde.
    twvalor = twvalor + wcla.wvalor.
    twabe = twabe + wcla.wabe.
        
    if last-of(wcla.prvenda)
    then do:
        vordem = vordem + 1.
        create buffwcla.
        buffwcla.ord = vordem.
        buffwcla.forcod = ?.
/*        buffwcla.pednum = ?.*/
        buffwcla.prvenda = buffwcla.prvenda + vprvenda.
        buffwcla.qtde = buffwcla.qtde + vqtde.
        buffwcla.wvalor = buffwcla.wvalor + vwvalor.
        buffwcla.wabe = buffwcla.wabe + vwabe.

        vprvenda = 0.
        vqtde = 0.
        vwvalor = 0.
        vwabe = 0.
        
    end.
    /*
    if last(wcla.prvenda)
    then do:
        vordem = vordem + 1.
        create buffwcla.
        buffwcla.ord = vordem.
        buffwcla.forcod = ?.
        buffwcla.pednum = ?.
        buffwcla.prvenda = buffwcla.prvenda + tvprvenda.
        buffwcla.qtde = buffwcla.qtde + tvqtde.
        buffwcla.wvalor = buffwcla.wvalor + twvalor.
        buffwcla.wabe = buffwcla.wabe + twabe.
    end.
    */
    
end.    

/***
for each wcla by wcla.ord.
    disp wcla. pause.
end.        
***/        display "VALOR TOTAL    " at 17
        vacprvenda
        vacumqtd format ">>>>>9"
        vacum 
        wacumabe1 at 64     
                with frame f6 width 80 no-box no-label
                       row 22 color message.

find first wcla no-error.
if avail wcla
then do:

bl-princ:
repeat:

    pause 0.
    
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    pause 0.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find wcla where recid(wcla) = recatu1 no-lock no-error.
    if not available wcla
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(wcla).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available wcla
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find wcla where recid(wcla) = recatu1 no-lock no-error.
            if not avail wcla then leave.
                       
                status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(wcla.forcod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(wcla.forcod)
                                        else "".
            run color-message.
            choose field wcla.forcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return)/* color white/black*/ .
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "TAB"
            then do:
        display "VALOR TOTAL    " at 17
        vacprvenda
        vacumqtd format ">>>>>9"
        vacum 
        wacumabe1 at 64     
                with frame f6 width 80 no-box no-label
                       row 22 color message.
            end.
            /***
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            ***/
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
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail wcla
                    then leave.
                    recatu1 = recid(wcla).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail wcla
                    then leave.
                    recatu1 = recid(wcla).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail wcla
                then next.
                color display white/red wcla.forcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail wcla
                then next.
                color display white/red wcla.forcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form wcla
                 with frame f-wcla color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-wcla on error undo.
                    create wcla.
                    update wcla.
                    recatu1 = recid(wcla).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-wcla.
                    disp wcla.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-wcla on error undo.
                    find wcla where
                            recid(wcla) = recatu1 
                        exclusive.
                    update wcla.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" wcla.forcod
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next wcla where true no-error.
                    if not available wcla
                    then do:
                        find wcla where recid(wcla) = recatu1.
                        find prev wcla where true no-error.
                    end.
                    recatu2 = if available wcla
                              then recid(wcla)
                              else ?.
                    find wcla where recid(wcla) = recatu1
                            exclusive.
                    delete wcla.
                    recatu1 = recatu2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Imprime "
                then do:
                    run p-imprime.
                    leave.
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    update "Deseja Imprimir todas ou a selecionada "
                           sresp format "Todas/Selecionada"
                                 help "Todas/Selecionadas"
                           with frame f-lista row 15 centered color black/cyan
                                 no-label.
                    if sresp
                    then run lwcla.p (input 0).
                    else run lwcla.p (input wcla.forcod).
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
                end.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(wcla).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.
end.
end.

procedure cria-tt-clase.

 for each clase where (if vclacod <> 0 then clase.clacod = vclacod
                                       else true) no-lock:
   find first bclase where bclase.clasup = clase.clacod no-lock no-error.
   if not avail bclase
   then do: 
     find tt-clase where tt-clase.clacod = clase.clacod no-error. 
     if not avail tt-clase 
     then do: 
       create tt-clase. 
       assign tt-clase.clacod = clase.clacod 
              tt-clase.clanom = clase.clanom.
     end.
   end.
   else do: 
     for each bclase where bclase.clasup = clase.clacod no-lock: 
         find first cclase where cclase.clasup = bclase.clacod no-lock no-error.
         if not avail cclase
         then do: 
           find tt-clase where tt-clase.clacod = bclase.clacod no-error. 
           if not avail tt-clase 
           then do: 
             create tt-clase. 
             assign tt-clase.clacod = bclase.clacod 
                    tt-clase.clanom = bclase.clanom.
           end.
         end.
         else do: 
           for each cclase where cclase.clasup = bclase.clacod no-lock: 
             find first dclase where dclase.clasup = cclase.clacod 
                                                     no-lock no-error. 
             if not avail dclase 
             then do: 
               find tt-clase where tt-clase.clacod = cclase.clacod no-error. 
               if not avail tt-clase 
               then do: 
                 create tt-clase. 
                 assign tt-clase.clacod = cclase.clacod 
                        tt-clase.clanom = cclase.clanom.
               end.                          
             end.
             else do: 
               for each dclase where dclase.clasup = cclase.clacod no-lock: 
                 find first eclase where eclase.clasup = dclase.clacod 
                                                         no-lock no-error. 
                 if not avail eclase 
                 then do: 
                   find tt-clase where tt-clase.clacod = dclase.clacod no-error.
                   if not avail tt-clase 
                   then do: 
                     create tt-clase. 
                     assign tt-clase.clacod = dclase.clacod 
                            tt-clase.clanom = dclase.clanom. 
                   end.       
                 end. 
                 else do:  
                   for each eclase where eclase.clasup = dclase.clacod no-lock:
                     find first fclase where fclase.clasup = eclase.clacod 
                                                             no-lock no-error.
                     if not avail fclase 
                     then do: 
                       find tt-clase where tt-clase.clacod = eclase.clacod
                                                             no-error.
                       if not avail tt-clase 
                       then do: 
                         create tt-clase. 
                         assign tt-clase.clacod = eclase.clacod 
                                tt-clase.clanom = eclase.clanom.
                       end.
                     end.
                     else do:
                     
                       for each fclase where fclase.clasup = eclase.clacod
                                    no-lock:
                         find first gclase where gclase.clasup = fclase.clacod 
                                                             no-lock no-error.
                         if not avail gclase 
                         then do: 
                           find tt-clase where tt-clase.clacod = fclase.clacod
                                                                 no-error.
                           if not avail tt-clase 
                           then do: 
                             create tt-clase. 
                             assign tt-clase.clacod = fclase.clacod 
                                    tt-clase.clanom = fclase.clanom.
                           end.
                         end.
                         else do:
                             find tt-clase where tt-clase.clacod =
                                            gclase.clacod no-error.
                             if not avail tt-clase
                             then do:
                                 create tt-clase. 
                                 assign tt-clase.clacod = gclase.clacod 
                                        tt-clase.clanom = gclase.clanom.
                             end.  
                         end.
                       end.
                     end.
                   end.
                 end.
               end.
             end.
           end.                                  
         end.
     end.
   end.
 end.
end procedure.

procedure frame-a.
    if not avail wcla then return.
    
    if wcla.forcod <> ?
    then do:
    find forne where forne.forcod = wcla.forcod no-lock.
    disp wcla.forcod column-label "Cod" format ">>>>>>9"
                     forne.fornom format "x(15)"
                      with frame frame-a 7 down width 80 row 10 centered color white/red.

     end.
     disp wcla.pednum  when wcla.pednum <> 0 column-label "Pedido" 
                with frame frame-a.

     if wcla.forcod = ? and wcla.pednum = 0
     then disp "-----Total-----" @ forne.fornom with frame frame-a.
vacum1 = vacum1 + wcla.wvalor.

            display wcla.prvenda column-label "Pr.Venda"
                    wcla.qtde
                        column-label "Qtde" format ">>>>>9"
                    wcla.wvalor column-label "Valor"
                    wcla.wabe   column-label "Em Aberto"
                                with frame frame-a
                                             7 down width 80 row 10.



end procedure.
procedure color-message.
color display message
        wcla.forcod
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        wcla.forcod
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first wcla use-index wcla01 where true
                                                no-lock no-error.
    else  
        find last wcla  use-index wcla01 where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next wcla  use-index wcla01 where true
                                                no-lock no-error.
    else  
        find prev wcla  use-index wcla01  where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev wcla use-index wcla01 where true  
                                        no-lock no-error.
    else   
        find next wcla use-index wcla01 where true 
                                        no-lock no-error.
        
end procedure.


procedure p-imprime.

            if opsys = "UNIX"
            then varquivo = "../relat/geral" + string(time).
            else varquivo = "..\relat\geral" + string(time).

            {mdad_l.i
              &Saida     = "value(varquivo)"
             &Page-Size = "0"
             &Cond-Var  = "130"
             &Page-Line = "66"
             &Nom-Rel   = ""GERAL""
             &Nom-Sis   = """SISTEMA DE ESTOQUE"""
             &Tit-Rel   = """MOVIMENTACAO GERAL FILIAL PERIODO DE """
            &Width     = "130"
            &Form      = "frame f-cabcab"}

            for each wcla use-index wcla01.
                run frame-a.
                down with frame frame-a.
            end.
        display "VALOR TOTAL    " at 17
        vacprvenda
        vacumqtd format ">>>>>9"
        vacum 
        wacumabe1 at 64     
                with frame f6 width 80 no-box no-label
                       row 22 color message.
            

            output close.
            if opsys = "UNIX"
            then run visurel.p (input varquivo, input "").
            else do:
                {mrod.i}.
            end.
end procedure.

