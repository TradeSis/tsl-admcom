/*      bsfqtitsim.p                */
def var vtoday as date format "99/99/9999"  init today. 


def var /*input parameter*/ par-titnat  as char init "rec".
def new shared var vtitnat like titulo.titnat .
assign
    vtitnat = if par-titnat = "PAG" then yes else no.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqcom1         as char format "x(12)" extent 12
   initial [" Marca ",
            " Consulta ",
            " Data ",
            "Posicao",
            "Nota Fiscal","Sim.Novacao",""].
            
           
def var esqcom2         as char format "x(14)" extent 7
            initial [" Manutencao ",
                     " Cliente  ",
                     "          ",
                     "             ",
                     "   " ].


assign
    esqcom1[6] = if vtitnat = yes
                 then "Fornecedor"
                 else esqcom1[6].

def var vmanut     as char format "x(15)" extent 9
                initial [
                          " Alteracao     ",
                          " Manutencao    ",
                          " Inclusao      ",
                          "               ",
                          " P/ Especial   ",
                          " P/ Tesouraria ",
                          "               ",     
                          "               ",
                          " Competencia   " 
                          ].

def var valtera as char format "xxx" extent 9
                initial [ 
 "ALT" , "MANUTENCAO", "INC" ,  "EXCLUSAO", "",
 "PARATESOURARIA",   ""         , ""          , "COMPETENCIA"].

def var vparaespecial     as char format "x(15)" extent 18
                initial [
                          " "].


def var esqhel1         as char format "x(80)" extent 12
    initial [" ",
             " "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ", " ", " ", " ", " "].

def buffer btitulo       for titulo.
def buffer xtitulo for titulo.
def buffer bclien for clien.
def var vtitulo         like titulo.titnum.
def var vcartcobra  as char column-label "Carteira".
def var vposicao as char extent 5 format "x(12)"
                                                 init [" Atual      ",
                                                       " Vencidos   ",
                                                       " A Vencer   ",
                                                       " Liquidados ",
                                                       " Geral      " ].

def var vesplica as char extent 5 format "x(50)"
     init [" ATUAL - Abertos Vencidos e a Vencer ",
           " VENCIDOS - Abertos Vencimento Anterior a Hoje",
           " VENCER - Abertos Vencimento Igual ou Superior a Hoje",
           " LIQUIDADO - Titulos Ja' Liquidados",
           " GERAL - Abertos e Liquidados "].

def var vtipo    as char extent 5 format "x(5)"
                                                 init ["atual",
                                                       "venci",
                                                       "vence",
                                                       "liqui",
                                                       "geral" ].
def var vchoose as char format "x(5)".
def var vhelp   as char format "x(50)".
def var v-tipo as char.
def var primeiro as log.
def var vbusca          like titulo.titnum.
def var vtitpar         as char format "xxx" init "" label "Parcela".

def var vinf    like cpfis.infoad extent 0 format "x(64)" .
def new shared frame finf.
form vinf label "Inf.Adicionais" at 1
     with frame finf row 5 overlay  width 81 no-box color input
                        side-label no-hide.
def var vcont as int.

form
    esqcom1
    with frame f-com1
                 row 10 no-box no-labels side-labels column 1 centered.
form
    vhelp
    with frame fhelp 
                 row 12 no-box no-labels color message.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-labels side-labels column 1
                 centered no-box.

{admcab.i}


def var recatu1 as recid.
def var recag   as recid.
def var rectit  as recid.
def var recatu2 as recid.
def var vtotvencido  like titulo.titvlcob   label "Vencido".
def var vtotliquidado   like titulo.titvlcob.
def input parameter vclfcod     like clien.clicod.
def var vtotvencjur  like titulo.titvlcob   label "Vencido + Juros".
def var vlimite      like clien.limite.
def var vsaldo       like clien.limite column-label "C/Jur+Multa".
def var vtotvencer   like titulo.titvlcob   label "A Vencer".
def var vtotjuro     like titulo.titvlcob   label "Juros".
def var vldevido     like titulo.titvlcob.
def var vtotal       like titulo.titvlcob column-label "Saldo c/Juro".
def var vtotalconta       like titulo.titvlcob.
def var vtotalori    like titulo.titvlcob.
def var vjuro        like titulo.titvlcob.
def var vnum        as   dec.
def var vdias as int   format "->>9".
def var vperc           as dec.
bl-princ:
do with side-label row 3 width 81 frame f1 1 down no-hide no-box
                            color message .
    vtoday = today.
    hide frame border  no-pause.
    hide frame ftot3 no-pause.
    hide frame fescpos no-pause.
    hide frame f-com1  no-pause.
    hide frame f-com2  no-pause.
    hide frame fhelp   no-pause.
    clear frame finf    all.
    hide frame finf    no-pause.
    display vclfcod       @ clien.clicod colon 8. 

    assign
        rectit = ?
        recag = ?
        recatu1 = ?.
    disp vclfcod @ clien.clicod colon 8  validate(true,"") label "Cliente"
                                /*  
                                editing.
                                    readkey pause 500.
                                    if lastkey = -1
                                    then return.
                                    if (lastkey = keycode("F7") or
                                        lastkey = keycode("PF7"))
                                    then do:
                                        run zfqtit.p (input  vtitnat,
                                                      output recag,
                                                      output rectit).
                                        find bclien where recid(bclien) =
                                                              recag
                                                              no-lock no-error.
                                        if avail bclien
                                        then
                                            display bclien.clicod
                                                            @ clien.clicod.
                                        else
                                            display 0 @ clien.clicod.
                                        pause 0.
                                        leave.
                                    end.
                                    apply lastkey.
                                end.     */ .
    if input clien.clicod = ""
    then undo.
    if rectit = ?
    then do:
        /*if /*input clien.clicod = ? or*/ /*input clien.clicod = ""*/
        then undo.*/
        find clien where clien.clicod = input clien.clicod
                               no-lock no-error.
        if scliente = "OBI" and
           vtitnat = no and
           not avail clien 
        then do. 
            hide message no-pause.
            sresp = no.
            message "Cliente nao cadastrado na loja. Buscar na MATRIZ ?"
                        update sresp.
            if sresp 
            then do.
                hide message no-pause.
                message "Conectando na MATRIZ.  Aguarde ...".
                run agil/lr-busclien.p (input input clien.clicod).
                hide message no-pause.
            end.
            find clien where clien.clicod = input clien.clicod 
                                no-lock no-error.
        end.
        
        if not avail clien
        then do:
            message "Agente Comercial Invalido".
            undo.
        end.
        recatu1 = recid(clien).
    end.
    else
        recatu1 = recag.
    assign
        vposicao[1] = " Atual      "
        vposicao[2] = " Vencidos   "
        vposicao[3] = " A Vencer   "
        vposicao[4] = " Liquidados "
        vposicao[5] = " Geral      ".
    find clien where recid(clien) = recatu1 no-lock.
    display
        vtoday  label "Data a Pagar " 
            with frame ffff 
            row 12 side-label column 55 
            no-box overlay
                                        .
    def var vatraso         as   int        label "Atraso Medio".
    def var vmaior          as   int        label "Maior Atraso".
    def var v-cont          as   int.
    assign
        v-cont = 0
        vdias = 0
        vmaior = 0
        vatraso = 0
        vatraso = vdias / v-cont
        vclfcod = clien.clicod.
  /*  clear frame f1 all. */
    display clien.clicod
            clien.clinom no-label
            clien.situacao format "Ativo/BLOQUEADO" no-label.
    
    
    assign
        vtotvencido = 0
        vtotvencer = 0
        vtotjuro = 0
        vtotvencido = 0
        vtotal = 0
        vtotvencjur = 0
        vtotliquidado = 0.
    run verinfad.p (input recid(clien)).
    run bsfqtagle.p (input        vtitnat,
                   input        clien.clicod,
                   input        "ABERTO",
                   input-output vtotvencido,
                   input-output vtotvencer,
                   input-output vtotjuro,
                   input-output vtotal,
                   input-output vtotvencjur,
                   input-output vtotliquidado).
    assign
        vtotal = vtotvencido /*jur*/ + vtotvencer
        vlimite = 0.
    assign
        vtotalori = vtotal /*vtotvencido + vtotvencer.*/
        vsaldo = vlimite - vtotalori.

    if vtitnat = no
    then
    display vlimite         label "Limite"      format  ">>>>,>>9.99" colon 10
            vsaldo          label "Saldo"       format "(>>>>,>>9.99)" colon 30
            with frame flim side-label column 34 color input
                row 7 1 down  no-box.

    if vtotvencido > 0
    then
        display
            vtotvencido     label "Vencido"     format "zzzz,zz9.99" colon 10
            /*
            vtotjuro        label "Juros"       format "zzz,zz9.99" colon 30
            vtotvencjur   label "Vencido + Juro" format "zzzz,zz9.99" colon 63
            */
            with frame ftot1 side-label color message width 81
                row 6 1 down  no-box.
    display
            vtotvencer      label "A Vencer"    format "zzzz,zz9.99" colon 36
            vtotal          label "Total"       format "zzzz,zz9.99" colon 63
            with frame ftot1 side-label  width 81
                row 6 1 down no-box.
                
    color display normal esqcom1[2] with frame f-com1.
/*    color display normal esqcom2[2] with frame f-com2. */
    color display normal esqcom1[3] with frame f-com1.
/*    color display normal esqcom2[3] with frame f-com2. */
    color display normal esqcom1[4] with frame f-com1.
/*    color display normal esqcom2[4] with frame f-com2. */
    color display normal esqcom1[5] with frame f-com1.
/*    color display normal esqcom2[5] with frame f-com2. */
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1
    recatu1  = ?
    vchoose  = vtipo[1]
    vhelp    = vesplica[1].

def temp-table ttmarc 
    field rec as recid
    index rec is primary unique rec  asc .
    vtoday = today.
    for each ttmarc.
        delete ttmarc.
    end.
    
def var vaster as log format "*/".
form
            vaster        no-label 
            estab.etbcod  column-label "Fil" format ">>9"
            titulo.modcod column-label "Modal"
            titulo.titnum   format "x(13)"
            titulo.titdtemi format "99/99/99"
            titulo.titdtven format "99/99/99" column-label "Vecto"
            vdias           column-label "Dias"
            vtotal         format ">>>>,>>9.99" column-label "Saldo"
            vsaldo  column-label "C/Jur+Multa"
                with frame frame-a .

find first titulo use-index iclicod where titulo.titnat = vtitnat and
                        titulo.clifor  = clien.clicod and
                        titulo.titsit = "LIB" no-lock no-error.
if avail titulo
then
    assign vchoose = "atual"
           vhelp   = vesplica[1].
else do:
    vposicao[1] = "            ".
    find first titulo use-index iclicod where titulo.titnat = vtitnat and
                            titulo.clifor  = clien.clicod and
                            titulo.titsit = "LIB" and
                            titulo.titdtven < today
                                        no-lock no-error.
    if avail titulo
    then
        assign vchoose = "venci"
               vhelp   = vesplica[2].
    else do:
        vposicao[2] = "            ".
        find first titulo use-index iclicod where titulo.titnat = vtitnat and
                                titulo.clifor  = clien.clicod and
                                titulo.titsit = "LIB" and
                                titulo.titdtven >= today no-lock no-error.
        if avail titulo
        then
            assign vchoose = "vence"
                   vhelp   = vesplica[3].
        else do:
            vposicao[3] = "            ".
            find first titulo use-index iclicod 
                        where titulo.titnat = vtitnat and
                                    titulo.clifor  = clien.clicod and
                                    titulo.titsit = "PAG"
                                    no-lock no-error.
            if avail titulo
            then
                assign vchoose = "liqui"
                       vhelp   = vesplica[4].
            else do:
                vposicao[4] = "            ".
                find first titulo use-index iclicod 
                                where titulo.titnat = vtitnat and
                                        titulo.clifor  = clien.clicod 
                                        no-lock no-error.
                if avail titulo
                then
                    assign vchoose = "geral"
                           vhelp   = vesplica[5].
                else do on endkey undo:
                    assign
                        vposicao[5] = "            "
                        sresp = no.
                    run message.p (input-output sresp,
                           input "Nenhum Titulo para este Cliente " ,
                                   input " !! ATENCAO !! ",
                                   input "    OK",
                                   input "    OK").
                    return.
/***
                    if sresp
                    then do:
                        run fmtitulo.p (input recid(clien),
                                        input valtera[3]).
                        assign vchoose = "geral"
                               vhelp   = vesplica[5]
                               recatu1 = ?.
                    end.
                    else do:
                        run fqtagcad.p (input recid(clien)).
                        next.
                    end.
***/
                end.
            end.
        end.
    end.
end.

assign vchoose = "atual"        
       vhelp   = vesplica[1].   

find first titulo use-index iclicod  where titulo.titnat = vtitnat and
                        titulo.clifor  = clien.clicod and
                        titulo.titsit = "LIB" no-lock no-error.
if avail titulo
then.
else vposicao[1] = "            ".
find first titulo use-index iclicod where titulo.titnat = vtitnat and
                        titulo.clifor  = clien.clicod and
                        titulo.titsit = "LIB" and
                        titulo.titdtven < today no-lock no-error.
if avail titulo
then.
else vposicao[2] = "            ".
find first titulo use-index iclicod where titulo.titnat = vtitnat and
                        titulo.clifor  = clien.clicod and
                        titulo.titsit = "LIB" and
                        titulo.titdtven >= today no-lock no-error.
if avail titulo
then.
else vposicao[3] = "            ".
find first titulo use-index iclicod where titulo.titnat = vtitnat and
                        titulo.clifor  = clien.clicod and
                        titulo.titdtpag <> ? and
                        titulo.titdtpag <> 01/01/1111
                        
                        no-lock no-error.
if avail titulo
then.
else vposicao[4] = "            ".
find first titulo use-index iclicod where titulo.titnat = vtitnat and
                        titulo.clifor  = clien.clicod no-lock no-error.
if avail titulo
then.
else vposicao[5] = "            ".
if rectit <> ?
then
    assign recatu1 = rectit
           vchoose = "geral"
           vhelp   = vesplica[5].

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
/*    disp esqcom2 with frame f-com2. */
    display vhelp
            with frame fhelp.
    if vchoose = "liqui" or
       vchoose = "geral"
    then
        display
            vtotliquidado label "Liquidado" format "zz,zzz,zz9.99" colon 10
            with frame ftot3 side-label color message
                row 7 1 down no-box .
    else
        hide frame ftot3 no-pause.

    if recatu1 = ?
    then
            if vchoose = "atual"
            then
                find first titulo use-index iclicod where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod and
                          titulo.titsit = "LIB"
                          
                                        no-lock no-error.
            else
                if vchoose = "venci"
                then
                    find first titulo use-index iclicod where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod and
                          titulo.titsit = "LIB" and
                          titulo.titdtven < today
                                        no-lock no-error.
                else
                if vchoose = "vence"
                then
                    find first titulo use-index iclicod where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod and
                          titulo.titsit = "LIB" and
                          titulo.titdtven >= today
                                        no-lock no-error.
                else
                if vchoose = "liqui"
                then
                    find last  titulo use-index iclicod where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod and
                          titulo.titsit = "PAG"
                                        no-lock no-error.
                else
                    find last  titulo use-index iclicod where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod 
                                        no-lock no-error.

    else
        find titulo where recid(titulo) = recatu1 no-lock.
    if not available titulo
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.
    else do on endkey undo:
        message "Nenhum titulo".
        leave.
    end.

    recatu1 = recid(titulo).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
/*    else color display message esqcom2[esqpos2] with frame f-com2. */
    if not esqvazio
    then repeat:
             if vchoose = "atual"
            then
                find next titulo use-index iclicod where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod and
                          titulo.titsit = "LIB"
                                        no-lock no-error.
            else
                if vchoose = "venci"
                then
                    find next  titulo use-index iclicod where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod and
                          titulo.titsit = "LIB" and
                          titulo.titdtven < today
                                        no-lock no-error.
                else
                if vchoose = "vence"
                then
                    find next  titulo use-index iclicod where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod and
                          titulo.titsit = "LIB" and
                          titulo.titdtven >= today
                                        no-lock no-error.
                else
                if vchoose = "liqui"
                then
                    find prev  titulo  use-index iclicod where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod and
                          titulo.titsit = "PAG"
                                        no-lock no-error.
                else
                    find prev  titulo use-index iclicod where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod 
                                        no-lock no-error.

        if not available titulo
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
            find titulo where recid(titulo) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(titulo.titnum)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(titulo.titnum)
                                        else "".
    color disp messages
            estab.etbcod
            titulo.modcod
            titulo.titnum
            titulo.titdtemi
            titulo.titdtven
            vdias                  vsaldo
            vtotal.
    
            find ttmarc where ttmarc.rec = recid(titulo) no-error.
            esqcom1[1] = if avail ttmarc
                         then " Desmarca "
                         else " Marca ".
            display esqcom1 with frame f-com1.            
           
            choose field titulo.titnum help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      1 2 3 4 5 6 7 8 9 0
                      q w e r t y u i o p l k j h g f d s a z x c v b n m
                      Q W E R T Y U I O P L K J H G F D S A Z X C V B N M
                      tab PF4 F4 ESC return) /*color white/black*/ .
    color disp normal
            estab.etbcod
            titulo.modcod
            titulo.titnum
            titulo.titdtemi
            titulo.titdtven  vsaldo
            vdias                  
            vtotal.
 
            status default "".
            if keyfunction(lastkey) = "0" or keyfunction(lastkey) = "1" or
               keyfunction(lastkey) = "2" or keyfunction(lastkey) = "3" or
               keyfunction(lastkey) = "4" or keyfunction(lastkey) = "5" or
               keyfunction(lastkey) = "6" or keyfunction(lastkey) = "7" or
               keyfunction(lastkey) = "8" or keyfunction(lastkey) = "9" or

                keyfunction(lastkey) = "q" or
                keyfunction(lastkey) = "w" or
                keyfunction(lastkey) = "e" or
                keyfunction(lastkey) = "r" or
                keyfunction(lastkey) = "t" or
               keyfunction(lastkey) = "y" or
               keyfunction(lastkey) = "u" or
                keyfunction(lastkey) = "i" or
                keyfunction(lastkey) = "o" or
                keyfunction(lastkey) = "p" or
                keyfunction(lastkey) = "a" or
                keyfunction(lastkey) = "s" or
                keyfunction(lastkey) = "d" or
                keyfunction(lastkey) = "f" or
                keyfunction(lastkey) = "g" or
                keyfunction(lastkey) = "h" or
                keyfunction(lastkey) = "j" or
                keyfunction(lastkey) = "k" or
                keyfunction(lastkey) = "l" or
                keyfunction(lastkey) = "z" or
                keyfunction(lastkey) = "x" or
                keyfunction(lastkey) = "c" or
                keyfunction(lastkey) = "v" or
                keyfunction(lastkey) = "b" or
                keyfunction(lastkey) = "n" or
                keyfunction(lastkey) = "m"
            then do with centered row 13 color message
                                frame f-procura side-label overlay.
                vbusca = keyfunction(lastkey).
                pause 0.
                primeiro = yes.
                update vbusca
                    editing:
                        if primeiro
                        then do:
                            apply keycode("cursor-right").
                            primeiro = no.
                        end.
                    readkey.
                    apply lastkey.
                end.
                vtitpar = "".
                update vtitpar.
                    recatu2  = recatu1.
             if vchoose = "atual"
            then
                find first titulo where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod and
                          titulo.titsit = "LIB"
                                            and titulo.titnum = vbusca
                                            and (if vtitpar <> ""
                                             then titulo.titpar = int(vtitpar)
                                                 else true)
                                        no-lock no-error.
            else
                if vchoose = "venci"
                then
                    find first titulo where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod and
                          titulo.titsit = "LIB" and
                          titulo.titdtven < today
                                            and titulo.titnum = vbusca
                                            and (if vtitpar <> ""
                                             then titulo.titpar = int(vtitpar)
                                                 else true)
                                        no-lock no-error.
                else
                if vchoose = "vence"
                then
                    find first titulo where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod and
                          titulo.titsit = "LIB" and
                          titulo.titdtven >= today
                                            and titulo.titnum = vbusca
                                            and (if vtitpar <> ""
                                             then titulo.titpar = int(vtitpar)
                                                 else true)
                                        no-lock no-error.
                else
                if vchoose = "liqui"
                then
                    find last  titulo  where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod and
                          titulo.titsit = "PAG" 
                                            and titulo.titnum = vbusca
                                            and (if vtitpar <> ""
                                             then titulo.titpar = int(vtitpar)
                                                 else true)
                                        no-lock no-error.
                else
                    find last  titulo where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod 
                                            and titulo.titnum = vbusca
                                            and (if vtitpar <> ""
                                             then titulo.titpar = int(vtitpar)
                                                 else true)
                                        no-lock no-error.
                    if avail titulo
                    then recatu1 = recid(titulo).
                    else recatu1 = recatu2.
                    leave.
            end.

        end.
                   /***/
        do:
            
            if keyfunction(lastkey) = "TABDESATIVADO"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
/*                  color display message esqcom2[esqpos2] with frame f-com2.*/
                end.
                else do:
/*                  color display normal esqcom2[esqpos2] with frame f-com2. */
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 12 then 12 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    /*
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                    */
                    
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
                    /*
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                    */
                end.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                         if vchoose = "atual"
                        then
                            find next titulo use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            titulo.titsit = "LIB"
                                            no-lock no-error.
                        else
                            if vchoose = "venci"
                            then
                                find next  titulo use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            titulo.titsit = "LIB" and
                                            titulo.titdtven < today
                                            no-lock no-error.
                            else
                            if vchoose = "vence"
                            then
                                find next  titulo use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            titulo.titsit = "LIB" and
                                            titulo.titdtven >= today
                                            no-lock no-error.
                            else
                            if vchoose = "liqui"
                            then
                                find prev  titulo use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            titulo.titsit = "PAG"
                                            no-lock no-error.
                            else
                                find prev  titulo use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod 
                                            no-lock no-error.
                    if not avail titulo
                    then leave.
                    recatu1 = recid(titulo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                        if vchoose = "atual"
                        then
                            find prev titulo use-index iclicod where
                                          titulo.titnat = vtitnat and
                                          titulo.clifor  = clien.clicod and
                                          titulo.titsit = "LIB"
                                        no-lock no-error.
                        else
                            if vchoose = "venci"
                            then
                                find prev  titulo use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            titulo.titsit = "LIB" and
                                            titulo.titdtven < today
                                            no-lock no-error.
                            else
                            if vchoose = "vence"
                            then
                                find prev  titulo use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            titulo.titsit = "LIB" and
                                            titulo.titdtven >= today
                                            no-lock no-error.
                            else
                            if vchoose = "liqui"
                            then
                                find next  titulo  use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            titulo.titsit = "PAG"
                                            no-lock no-error.
                            else
                                find next  titulo use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod 
                                            no-lock no-error.

                    if not avail titulo
                    then leave.
                    recatu1 = recid(titulo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                    if vchoose = "atual"
                    then
                        find next titulo use-index iclicod  where
                              titulo.titnat = vtitnat and
                              titulo.clifor  = clien.clicod and
                              titulo.titsit = "LIB"
                                    no-lock no-error.
                    else
                        if vchoose = "venci"
                        then
                            find next  titulo use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            titulo.titsit = "LIB" and
                                            titulo.titdtven < today
                                            no-lock no-error.
                        else
                        if vchoose = "vence"
                        then
                            find next  titulo use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            titulo.titsit = "LIB" and
                                            titulo.titdtven >= today
                                            no-lock no-error.
                        else
                        if vchoose = "liqui"
                        then
                            find prev  titulo  use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            titulo.titsit = "PAG" 
                                            no-lock no-error.
                        else
                            find prev  titulo use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod 
                                            no-lock no-error.

                if not avail titulo
                then next.
/*                color display white/red titulo.titnum.*/
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                    if vchoose = "atual"
                    then
                        find prev titulo  use-index iclicod where
                              titulo.titnat = vtitnat and
                              titulo.clifor  = clien.clicod and
                              titulo.titsit = "LIB"
                                    no-lock no-error.
                    else
                        if vchoose = "venci"
                        then
                            find prev  titulo use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            titulo.titsit = "LIB" and
                                            titulo.titdtven < today
                                            no-lock no-error.
                        else
                        if vchoose = "vence"
                        then
                            find prev  titulo use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            titulo.titsit = "LIB" and
                                            titulo.titdtven >= today
                                            no-lock no-error.
                        else
                        if vchoose = "liqui"
                        then
                            find next  titulo use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            titulo.titsit = "PAG" 
                                            no-lock no-error.
                        else
                            find next  titulo use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod 
                                            no-lock no-error.

                if not avail titulo
                then next.
/*                color display white/red titulo.titnum.*/
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
        end.
                    /***/

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave:
            if esqcom1[esqpos1] <> "Posicao" and
               esqcom1[esqpos1] <> "Historicos" and
               esqcom1[esqpos1] <> "Cadastro" and
               esqcom1[esqpos1] <> "Cliente" and
               esqcom1[esqpos1] <> "Fornecedor" and
               esqcom1[esqpos1] <> "Manutencao"
            then hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Data "
                then do.
                    update vtoday  label "Data a Pagar "
                                with frame ffff
                            row 12 side-label column 55
                                        no-box         color message 
                                        overlay
                                        .
                    run marcados.
                    recatu1 = ?.
                    next bl-princ.
                end.
                if esqcom1[esqpos1] = " Novacao "
                then do.
                    sretorno = "".
                    run marcados.
                    run novacao (input dec(sretorno)).
                    run marcados.

                    hide frame fbloq no-pause.
/*                    view frame f-com2. */
                    view frame f-com1.
                    if vtotvencido > 0
                    then
                        view frame ftot1.
/*                    view frame ftot2. */
                    if vtitnat = no then view frame flim.
                    view frame fhelp.
                    view frame f1.

                    recatu1 = ?.
                    next bl-princ.
                end.
                
                if esqcom1[esqpos1] = "Nota Fiscal"
                then do.
                    run nota-fiscal.
                end.                
                
                if esqcom1[esqpos1] = "Sim.Novacao"
                then do on error undo:
                   hide frame f-com1 no-pause.
                   hide frame telobs no-pause.
                   hide frame frame-a no-pause.
                   pause 0.
                    sretorno = "CLICOD=" + string(clien.clicod).
                    run novacao2.p.
                    sretorno = "".
                    pause 0.
                   view frame frame-a.   pause 0.
                   view frame f-com1.    pause 0.
                   view frame telobs.    pause 0.
                end.                
                
                if esqcom1[esqpos1] = " marca " or
                   esqcom1[esqpos1] = " desmarca "
                then do.
                    find titulo where recid(titulo) = recatu1 no-lock.
                    find ttmarc where ttmarc.rec =  recid(titulo)
                                            no-error.
                    if avail ttmarc
                    then delete ttmarc.
                    else do.
                        create ttmarc.
                        ttmarc.rec =  recid(titulo).
                    end.
                    run marcados.
                    leave.
                end.

                if esqcom1[esqpos1] = " Nota Fiscal "
                then do.
                    hide frame frame-a no-pause.
                    hide frame f-com1 no-pause.
                    run fqnottit.p (input recid(titulo)).
        pause 0.
                    view frame fhelp.
/*                    view frame f-com2. */
pause 0.
                    view frame f-com1.
                    pause 0.
                    view frame frame-a.
                    pause 0.
                    display clien.situacao
                            with frame f1.
                    view frame f-com2.
                    view frame f-com1.
                    view frame fhelp.
/*                    view frame f-com2. */
                    view frame f-com1.

                end.
                if esqcom1[esqpos1] = "p/contrato "
                then do.
                    hide frame frame-a no-pause.
                    hide frame f-com1 no-pause.
                    run fqcontrato.p (input titulo.clifor).
 
/*                    view frame f-com2. */
                    view frame f-com1.
                    if vtotvencido > 0
                    then
                        view frame ftot1.
/*                    view frame ftot2. */
                    if vtitnat = no then view frame flim.
                    view frame fhelp.
                    view frame f1.

               end.
                
                if esqcom1[esqpos1] = " Consulta "
                then do.
                    hide frame ftotconta no-pause.
                    hide frame border   no-pause.
                    hide frame fescpos  no-pause.
                    hide frame f-com1   no-pause.
/*                    hide frame f-com2   no-pause. */
                    hide frame fhelp    no-pause.
                    hide frame ftot1    no-pause.
                    hide frame ftot2    no-pause.
                    hide frame flim     no-pause.
                    hide frame ftot3    no-pause.
/*                    hide frame f-com2   no-pause.*/
                    hide frame f-com1   no-pause.
                    hide frame f1       no-pause.
                    hide frame fbloq    no-pause.
                    hide frame fhelp    no-pause.
                    hide frame frame-a  no-pause.
                    run bsfqtitulo.p (input recid(titulo)).

/*                    view frame f-com2. */
                    view frame f-com1.
                    if vtotvencido > 0
                    then
                        view frame ftot1.
/*                    view frame ftot2. */
                    if vtitnat = no then view frame flim.
                    view frame fhelp.
                    view frame f1.

                end.
                if esqcom1[esqpos1] = "Posicao "
                then do on error undo.
                    
                    hide frame border  no-pause.
                    hide frame fescpos no-pause.
                    FORM
                    SPACE(3)
                    SKIP(8)
                        WITH FRAME border
                                ROW 11 column 17
                                WIDTH 19 NO-BOX OVERLAY COLOR MESSAGES.
                    pause 0.
                    view frame border.
                    pause 0.
                    display vposicao
                            with frame fescpos no-label 1 column
                                    column 19 row 12 overlay.
                    choose field vposicao with frame fescpos.
                    if vposicao[frame-index] = ""
                    then undo.
                    assign
                        vchoose = vtipo[frame-index]
                        vhelp   = vesplica[frame-index]
                        recatu1 = ?.
                    hide frame border  no-pause.
                    hide frame fescpos no-pause.
                    /***/
                    if (vchoose = "liqui" or
                            vchoose = "geral") and
                            vtotliquidado = 0
                    then do:
                        message color normal
                                    "Aguarde, Calculando o Total Liquidado...".
                        vtotliquidado = 0.
                        run bsfqtagle.p (input        vtitnat,
                                       input        clien.clicod,
                                       input        "LIQUIDADO",
                                       input-output vtotvencido,
                                       input-output vtotvencer,
                                       input-output vtotjuro,
                                       input-output vtotal,
                                       input-output vtotvencjur,
                                       input-output vtotliquidado).
                        hide message no-pause.
                    end.
                    /***/
                    pause 0.
                    view frame fhelp.
/*                    view frame f-com2. */
                    view frame f-com1.
                    leave.
                end.

                if esqcom1[esqpos1] = "Listagem "
                then do.
                    hide frame f-com1 no-pause.
/*                    hide frame f-com2 no-pause. */
                    run frtitag.p (input recid(clien),
                                   input vtitnat,
                                   input vchoose,
                                   input vhelp).
/*                    view frame f-com2. */
                    view frame f-com1.
                end.
                if esqcom1[esqpos1] = "Contas "
                then do.
                    hide frame f-com1 no-pause.
/*                    hide frame f-com2 no-pause. */
                    run fmconta.p (
                                "CLFCOD=" + string(clien.clicod) + "|" +
                                "MODAL=CONCO").                    
/*                    view frame f-com2. */
                    view frame f-com1.
                    leave.
                end.

                if esqcom1[esqpos1] = "Dossie"
                then do.
                    run clificha.p ( recid(clien)).
                end.

                if esqcom1[esqpos2] = "Cliente " or
                   esqcom1[esqpos2] = "Fornecedor "
                then do on error undo.
                    run fqtagcad.p (input recid(clien)).
                    vlimite = 0.
                    vsaldo = vlimite - vtotalori.
                    if vtitnat = no
                    then
                    display vlimite
                            vsaldo
                            with frame flim.

                    view frame f-com2.
                    view frame f-com1.
                    display clien.situacao
                            with frame f1.
                    view frame f-com2.
                    view frame f-com1.
                    view frame fhelp.
                    view frame f-com2.
                    view frame f-com1.
                    run verinfad.p (input recid(clien)).
                    pause 0.
                    leave.
                end.
            end.
            else do:
                /*
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                */
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a. 
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
/*        else display esqcom2[esqpos2] with frame f-com2.*/
        recatu1 = recid(titulo).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
                    hide frame border   no-pause.
                    hide frame fescpos  no-pause.
                    hide frame f-com1   no-pause.
                    hide frame f-com2   no-pause.
                    hide frame fhelp    no-pause.
                    hide frame ftot3    no-pause.
                    hide frame f-com2   no-pause.
                    hide frame f-com1   no-pause.
                    hide frame f1       no-pause.
                    hide frame fbloq    no-pause.
                    hide frame fhelp    no-pause.
                    hide frame frame-a  no-pause.



end.
                    hide frame border   no-pause.
                    hide frame fescpos  no-pause.
                    hide frame f-com1   no-pause.
                    hide frame f-com2   no-pause.
                    hide frame fhelp    no-pause.
                    hide frame ftot3    no-pause.
                    hide frame f-com2   no-pause.
                    hide frame f-com1   no-pause.
                    hide frame f1       no-pause.
                    hide frame fbloq    no-pause.
                    hide frame fhelp    no-pause.
                    hide frame frame-a  no-pause.


procedure frame-a.
    /*def var vsaldo           like titulo.titvlcob.*/
    def var vsaldoatualizado like titulo.titvlcob.
    def var vperc            as   dec.
    def var vvalordesc       as   dec.
    def var vsaldobase    as dec.
    def var vvalormulta as dec format ">>>>9.99".

            assign
                vtotal = if titulo.titdtpag = ?
                         then titulo.titvlcob - titulo.titvlpag
                         else 0.
        find cobra    of titulo no-lock.
        vcartcobra = trim(substr(cobra.cobnom,1,5)).
        find banco of titulo no-lock no-error.
        if avail banco
        then
            substr(vcartcobra,1,5) = banco.banfan.
        if titulo.titdtpag = ?
        then vdias = vtoday - titulo.titdtven.
        else vdias = titulo.titdtpag - titulo.titdtven.
        find estab where
                        estab.etbcod = titulo.etbcod no-lock.
        if titulo.titdtpag <> ?
        then
            vcartcobra = "Liqui " + string(titdtpag,"99/99/9999").
        if vtotal < 0
        then vtotal = 0.
        vsaldo              = titulo.titvlcob - titulo.titvlpag.
        vsaldoatualizado    = titulo.titvlcob - titulo.titvlpag.
        if vtoday > titulo.titdtven
        then do:
            if titulo.modcod = "GE"
            then do.
            end.
            else do.
                vsaldobase = vsaldo.
                /*
                run fbjuro.p (input titulo.cobcod, 
                          input titulo.carcod, 
                          input titulo.titnat, 
                          input vsaldo,
                          input titulo.titdtven, 
                          input vtoday, 
                          output vsaldoatualizado, 
                          output vperc) .
                */
            end.  /*
            run fbmulta.p (input titulo.cobcod,  
                       input titulo.carcod,  
                       input titulo.titnat,  
                       input vsaldobase,
                       input titulo.titdtven,  
                       input vtoday,  
                       output vvalormulta).*/
        end.
        def var vjuros as dec.
        run bstitjuro.p (input  recid(titulo), 
                         input  vtoday,         
                         output vjuros,        
                         output vsaldoatualizado).   
        vvalormulta = 0.
        find ttmarc where ttmarc.rec = recid(titulo) no-error.
        vaster = avail ttmarc .
                
        display
            vaster
            estab.etbcod  column-label "Fil" format ">>9"
            titulo.modcod column-label "Modal"
            {titnum.i}
            titulo.titdtemi format "99/99/99"
            titulo.titdtven format "99/99/99"
            vdias           when vdias > 0 column-label "Dias"
            vtotal         format ">>>>,>>9.99" column-label "Saldo"
/*            vsaldobase*/
            vsaldoatualizado + vvalormulta @ vsaldo 
                        column-label "C/Jur+Multa"
                with frame frame-a 5 /*8*/ down centered 
                /*color white/red*/ row 13
                                no-box width 80.



end procedure.


procedure marcados.
def var vmarcsaldo   like titulo.titvlcob.
def var vmarctotal   like titulo.titvlcob.
    def var vsaldoatualizado like titulo.titvlcob.
    def var vperc            as   dec.
    def var vvalordesc       as   dec.
    def var vsaldobase    as dec.
    def var vvalormulta as dec format ">>>>9.99".

vmarcsaldo = 0.
vmarctotal = 0.

for each ttmarc.
    find titulo where recid(titulo) = ttmarc.rec no-lock.
    vtotal = if titulo.titdtpag = ? 
             then titulo.titvlcob - titulo.titvlpag 
             else 0.
    do.
        vsaldo              = titulo.titvlcob - titulo.titvlpag.
        vsaldoatualizado    = titulo.titvlcob - titulo.titvlpag.
        if vtoday > titulo.titdtven
        then do:
            if titulo.modcod = "GE"
            then do.
            end.
            else do.
                vsaldobase = vsaldo.    /*
                run fbjuro.p (input titulo.cobcod, 
                          input titulo.carcod, 
                          input titulo.titnat, 
                          input vsaldo,
                          input titulo.titdtven, 
                          input vtoday, 
                          output vsaldoatualizado, 
                          output vperc) . */
            end.
                /*
            run fbmulta.p (input titulo.cobcod,  
                       input titulo.carcod,  
                       input titulo.titnat,  
                       input vsaldobase,
                       input titulo.titdtven,  
                       input vtoday,  
                       output vvalormulta).  */
        end.    
    end. 
    def var vjuros as dec.
    vvalormulta = 0.
    run bstitjuro.p (input  recid(titulo),  
                     input  vtoday,          
                     output vjuros,         
                     output vsaldoatualizado).   
    vmarcsaldo = vmarcsaldo + (vtotal).
    vmarctotal = vmarctotal + vsaldoatualizado + vvalormulta. 
end.
sretorno = string(vmarctotal).
display "** MARCADOS **"
        vmarcsaldo   at 17  label "Principal"
        vmarctotal   to 79  label "Total Juros e Multa"
        with frame fmarcados
                row 20
                            no-box color message side-label
                                    width 81.        


end procedure.


procedure novacao.
/*
def input parameter par-valor   like plani.platot.

def var  recid-cupom as recid. 
def var vopccod like opcom.opccod.
def var vcrecod like crepl.crecod.
def buffer testab for estab.
def var aux-rec as recid.
recid-cupom = ?.
run pdv/pdvgcup.p (input-output recid-cupom,
                   output aux-rec,
                   input  "TOTALIZA", 
                   input  ?,  
                   input  ?,  
                   input  sfuncod,  
                   input  "NOVACAO",  
                   input  ?, 
                   input  ?).
do on error undo.                   
    find cupom where recid(cupom) = RECID-CUPOM exclusive. 
    cupom.protot = par-valor.
    cupom.platot = par-valor.
end.
find current cupom no-lock. 
find testab where testab.etbcod = setbcod no-lock.
run pdv/pdveopc.p ( input "RECID-CUPOM=" + string(RECID(CUPOM)), 
                    input-output vopccod , 
                    input-output vcrecod). 
def var vok as log.      
run pdv/pdvcupt.p (input recid(cupom),  
                   output vok).   


*/
end procedure.

procedure nota-fiscal.

        pause 0.
            do:

                for each contnf where contnf.etbcod  = titulo.etbcod and
                                      contnf.contnum = int(titulo.titnum) 
                                                    no-lock:
                    for each plani where plani.etbcod = titulo.etbcod and
                                         plani.placod = contnf.placod no-lock.
                        display plani.numero label "Numero" format ">>>>>>9"
                                             colon 20
                                plani.serie  label "Serie"
                                plani.pladat label "Data"
                                plani.platot label "Valor da Nota"   colon 20
                                plani.vlserv label "Valor Devolucao" colon 20
                                plani.biss   label "Valor C/ Acrescimo"
                                                        colon 20
                                    with frame fnota side-label centered
                                            color message row 4
                                                        overlay
                                                                width 80.
                        find finan where finan.fincod = plani.pedcod no-lock
                                                        no-error.
                        display plani.pedcod label "Plano" colon 20
                                finan.finnom no-label when avail finan
                                        with frame fnota.
                        find func where func.etbcod = plani.etbcod and
                                        func.funcod = plani.vencod 
                                                no-lock no-error.
                        display plani.vencod label "Vendedor"colon 20
                                func.funnom no-label when avail func 
                                        with frame fnota side-label.
                        for each movim where movim.etbcod = plani.etbcod and
                                             movim.placod = plani.placod and
                                             movim.movtdc = plani.movtdc and
                                             movim.movdat = plani.pladat
                                                        no-lock:
                            find produ where produ.procod = movim.procod 
                                                        no-lock no-error.
                            display movim.procod
                                    produ.pronom when avail produ 
                                            format "x(21)"
                                    movim.movqtm column-label "Qtd" 
                                            format ">>>>9"
                                    movim.movpc format ">>,>>9.99" 
                                            column-label "Preco" 
                                    (movim.movqtm * movim.movpc)
                                            column-label "Total"
                                        with frame fmov down centered
                                                        color blue/message
                                                  overlay width 80
                                                      row 12.
                        
                        end.                                
                    end.                     
                end.                                
            end.     



end procedure.
