/*
*   bsfqtitag.p
*/                                                                        
def var /*input parameter*/ par-titnat  as char init "REC".
def input param vetbcod     like estab.etbcod.
def input param vclfcod     like clien.clicod.
if vetbcod = ? then vetbcod = 0.

def new shared var vtitnat like titulo.titnat .
assign
    vtitnat = if par-titnat =  "PAG" then yes else no.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqcom1         as char format "x(12)" extent 12
   initial ["Consulta",
            
            "Posicao",
            "P/Contrato",
            
            "Nota Fiscal",
            "",
            "",
            "",
            "",
            "",""].
            
           
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

def var vmanut     as char format "x(16)" extent 10
                initial [
                          " Alteracao     ",
                          " Manutencao    ",
                          " Inclusao      ",
                          "               ",
                          " P/ Especial   ",
                          "               ",
                          "               ",     
                          "               ",
                          " Competencia   " ,
                          " P/Cobranca    "
                          ].

def var valtera as char format "xxx" extent 10
                initial [ 
 "ALT" , "MANUTENCAO", "INC" ,  "EXCLUSAO", "",
 "",   ""         , ""          , "COMPETENCIA",
    "PARATESOURARIA"].

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
def var vaux-tot as dec.
def var vesplica as char extent 5 format "x(64)"
     init [" Posicao ATUAL - Abertos Vencidos e a Vencer ",
           " Posicao VENCIDOS - Abertos Vencimento Anterior a Hoje",
           " Posicao VENCER - Abertos Vencimento Igual ou Superior a Hoje",
           " Posicao LIQUIDADO - Titulos Ja' Liquidados",
           " Posicao GERAL - Abertos e Liquidados "].

def var vtipo    as char extent 5 format "x(5)"
                                                 init ["atual",
                                                       "venci",
                                                       "vence",
                                                       "liqui",
                                                       "geral" ].
def var vchoose as char format "x(5)".
def var vhelp   as char format "x(62)".
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
                 row 12 no-box no-labels centered color message.
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
def var vjuros  as dec.
def var vsaldojuros      as dec.
def var vtotvencido  like titulo.titvlcob   label "Vencido".
def var vtotliquidado   like titulo.titvlcob.
def var vtotvencjur  like titulo.titvlcob   label "Vencido + Juros".
def var vlimite      like clien.limite.
def var vsaldo       like clien.limite.
def var vtotvencer   like titulo.titvlcob   label "A Vencer".
def var vtotjuro     like titulo.titvlcob   label "Juros".
def var vldevido     like titulo.titvlcob.
def var vtotal       like titulo.titvlcob column-label "Saldo c/Juro".
def var vtotalconta       like titulo.titvlcob.
def var vtotalori    like titulo.titvlcob.
def var vjuro        like titulo.titvlcob.
def var vnum        as   dec.
def var vdias as int   format "->>9".
do with side-label row 3 width 81 frame f1 1 down no-hide no-box
                            color message .
    hide frame border  no-pause.
    hide frame ftot3 no-pause.
    hide frame fescpos no-pause.
    hide frame f-com1  no-pause.
    hide frame f-com2  no-pause.
    hide frame fhelp   no-pause.
    clear frame finf    all.
    hide frame finf    no-pause.
    display vclfcod       @ clien.clicod colon 8 label "CLiente".  

    assign
        rectit = ?
        recag = ?
        recatu1 = ?.
    /*
    prompt-for clien.clicod colon 8  validate(true,"")
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
                                end.
    if input clien.clicod = "" or
       input clien.clicod = 0
    then undo.
    */
    if rectit = ?
    then do:
        /*if /*input clien.clicod = ? or*/ /*input clien.clicod = ""*/
        then undo.*/
        find clien where clien.clicod = input clien.clicod
                               no-lock no-error.
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
    /*if clien.clicod = ? or
       clien.clicod = 0
    then undo.*/

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
    run fin/bsfqtagle.p (input        vtitnat,
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
    /*
    run fcalabe.p (input  clien.clicod, 
                   input  no, 
                   output vaux-tot, 
                   output vaux-tot /*tot-vencer-mes*/, 
                   output vaux-tot /*tot-vencerapos*/, 
                   output vaux-tot /*total-vencido*/, 
                   output vaux-tot /*total-vencer*/, 
                   output vaux-tot /*total-juro*/, 
                   output vaux-tot /*total-geral*/, 
                   output vaux-tot /*total-vencido-jur*/, 
                   output vlimite /* vlimiteal*/, 
                   output vaux-tot /*vlimmensal*/, 
                   output vaux-tot, 
                   output vaux-tot /*vsaldo-mensal*/ ).
    */
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
                
    /*run fqconta.p (clien.clicod,
                    today,
                    "CONCO", /* modalidade */
                    output vtotalconta).
                    
    display
            vtotalconta label "Contas"       format "(>>>>,>>9.99)" colon 63
            with frame ftotconta side-label  width 81
                row 8 1 down no-box.
    */
                 
                 
                 
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

find first titulo use-index iclicod where titulo.titnat = vtitnat and
                        titulo.clifor  = clien.clicod and
                        titulo.titdtpag = ? and
                        (if vetbcod <> 0
                         then titulo.etbcod = vetbcod
                         else true) no-lock no-error.
if avail titulo
then
    assign vchoose = "atual"
           vhelp   = vesplica[1].
else do:
    vposicao[1] = "            ".
    find first titulo use-index iclicod where titulo.titnat = vtitnat and
                            titulo.clifor  = clien.clicod and
                            titulo.titdtpag = ? and
                            titulo.titdtven < today and
                            (if vetbcod <> 0
                            then titulo.etbcod = vetbcod
                            else true)
                                        no-lock no-error.
    if avail titulo
    then
        assign vchoose = "venci"
               vhelp   = vesplica[2].
    else do:
        vposicao[2] = "            ".
        find first titulo use-index iclicod where titulo.titnat = vtitnat and
                                titulo.clifor  = clien.clicod and
                                titulo.titdtpag = ? and
                                titulo.titdtven >= today and
                                (if vetbcod <> 0
                                 then titulo.etbcod = vetbcod
                                 else true) no-lock no-error.
        if avail titulo
        then
            assign vchoose = "vence"
                   vhelp   = vesplica[3].
        else do:
            vposicao[3] = "            ".
            find first titulo use-index iclicod where titulo.titnat = vtitnat and
                                    titulo.clifor  = clien.clicod and
                                    titulo.titdtpag <> ? and
                                    (if vetbcod <> 0
                                     then titulo.etbcod = vetbcod
                                     else true)
                                    no-lock no-error.
            if avail titulo
            then
                assign vchoose = "liqui"
                       vhelp   = vesplica[4].
            else do:
                vposicao[4] = "            ".
                find first titulo use-index iclicod where titulo.titnat = vtitnat and
                                        titulo.clifor  = clien.clicod and
                                        (if vetbcod <> 0
                                         then titulo.etbcod = vetbcod
                                         else true)
                                        no-lock no-error.
                if avail titulo
                then
                    assign vchoose = "geral"
                           vhelp   = vesplica[5].
                else do on endkey undo:
                    assign
                        vposicao[5] = "            "
                        sresp = no.
                    run sys/message.p (input-output sresp,
                           input "Nenhum Titulo para este Agente" +
                                 " Comercial. Deseja Incluir Titulo ?",
                                   input " !! ATENCAO !! ",
                                   input "    SIM",
                                   input "    NAO").
                    if sresp = yes
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
                end.
            end.
        end.
    end.
end.

/***2014
assign vchoose = "venci"        
       vhelp   = vesplica[2].   
***/

find first titulo use-index iclicod where titulo.titnat = vtitnat and
                        titulo.clifor  = clien.clicod and
                        titulo.titdtpag = ? and
                        (if vetbcod <> 0
                         then titulo.etbcod = vetbcod
                         else true) no-lock no-error.
if avail titulo
then.
else vposicao[1] = "            ".
find first titulo use-index iclicod where titulo.titnat = vtitnat and
                        titulo.clifor  = clien.clicod and
                        titulo.titdtpag = ? and
                        titulo.titdtven < today and
                        (if vetbcod <> 0
                         then titulo.etbcod = vetbcod
                        else true) no-lock no-error.
if avail titulo
then.
else vposicao[2] = "            ".
find first titulo use-index iclicod where titulo.titnat = vtitnat and
                        titulo.clifor  = clien.clicod and
                        titulo.titdtpag = ? and
                        titulo.titdtven >= today and
                        (if vetbcod <> 0
                         then titulo.etbcod = vetbcod
                         else true) no-lock no-error.
if avail titulo
then.
else vposicao[3] = "            ".
find first titulo use-index iclicod where titulo.titnat = vtitnat and
                        titulo.clifor  = clien.clicod and
                        titulo.titdtpag <> ? and
                        titulo.titdtpag <> 01/01/1111 and
                        (if vetbcod <> 0
                        then titulo.etbcod = vetbcod
                        else true)                        
                        no-lock no-error.
if avail titulo
then.
else vposicao[4] = "            ".
find first titulo use-index iclicod where titulo.titnat = vtitnat and
                        titulo.clifor  = clien.clicod and
                        (if vetbcod <> 0
                         then titulo.etbcod = vetbcod
                         else true) no-lock no-error.
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
                          titulo.titdtpag = ? and
                          (if vetbcod <> 0
                           then titulo.etbcod = vetbcod
                           else true)                            
                                        no-lock no-error.
            else
                if vchoose = "venci"
                then
                    find first titulo use-index iclicod where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod and
                          titulo.titdtpag = ? and
                          titulo.titdtven < today and
                          (if vetbcod <> 0
                           then titulo.etbcod = vetbcod
                           else true)                          
                                        no-lock no-error.
                else
                if vchoose = "vence"
                then
                    find first titulo use-index iclicod where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod and
                          titulo.titdtpag = ? and
                          titulo.titdtven >= today and
                          (if vetbcod <> 0
                           then titulo.etbcod = vetbcod
                           else true)                          
                                        no-lock no-error.
                else
                if vchoose = "liqui"
                then
                    find last  titulo use-index iclicod  where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod and
                          titulo.titdtpag <>? and
                          (if vetbcod <> 0
                           then titulo.etbcod = vetbcod
                           else true)                          
                                        no-lock no-error.
                else
                    find last  titulo use-index iclicod where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod and
                          (if vetbcod <> 0
                           then titulo.etbcod = vetbcod
                           else true)                          
                                        no-lock no-error.

    else
        find titulo where recid(titulo) = recatu1 no-lock.
    if not available titulo
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
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
        then vdias = today - titulo.titdtven.
        else vdias = titulo.titdtpag - titulo.titdtven.
        find estab where /*estab.empcod = wempre.empcod and*/ estab.etbcod = titulo.etbcod no-lock.
        if titulo.titdtpag <> ?
        then
            vcartcobra = "Liqui " + string(titdtpag,"99/99/9999").
        if vtotal < 0
        then vtotal = 0.
        run bstitjuro.p (input  recid(titulo), 
                         input  today, 
                         output vjuros, 
                         output vsaldojuros).
        display
            estab.etbcod  column-label "Fil" format ">>9"
            titulo.modcod column-label "Modal"
            {titnum.i}
            titulo.titdtemi format "99/99/99"
            titulo.titdtven format "99/99/99"
            vdias           when vdias > 0 column-label "Dias"
/*            vcartcobra      format "x(12)"*/
            vtotal         format ">>>>,>>9.99" column-label "Saldo"
            vjuros         format ">>>9.99" column-label "Juros"
            vsaldojuros    format ">>>>,>>9.99" column-label "Saldo C/Jur"  
                with frame frame-a 8 down centered 
                /*color white/red*/ row 13
                                no-box width 80.
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
                          titulo.titdtpag = ? and
                          (if vetbcod <> 0
                           then titulo.etbcod = vetbcod
                           else true)                          
                                        no-lock no-error.
            else
                if vchoose = "venci"
                then
                    find next  titulo use-index iclicod where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod and
                          titulo.titdtpag = ? and
                          titulo.titdtven < today and
                          (if vetbcod <> 0
                           then titulo.etbcod = vetbcod
                           else true)                          
                                        no-lock no-error.
                else
                if vchoose = "vence"
                then
                    find next  titulo use-index iclicod where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod and
                          titulo.titdtpag = ? and
                          titulo.titdtven >= today and
                          (if vetbcod <> 0
                           then titulo.etbcod = vetbcod
                           else true)                          
                                        no-lock no-error.
                else
                if vchoose = "liqui"
                then
                    find prev  titulo  use-index iclicod where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod and
                          titulo.titdtpag <>?
                                        no-lock no-error.
                else
                    find prev  titulo use-index iclicod where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod and
                          (if vetbcod <> 0
                           then titulo.etbcod = vetbcod
                           else true)                          
                                        no-lock no-error.
        if not available titulo
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
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
        then vdias = today - titulo.titdtven.
        else vdias = titulo.titdtpag - titulo.titdtven.
        find estab where /*estab.empcod = wempre.empcod and*/ estab.etbcod = titulo.etbcod no-lock.
        if titulo.titdtpag <> ?
        then
            vcartcobra = "Liqui " + string(titdtpag,"99/99/9999").
        if vtotal < 0
        then vtotal = 0.
        run bstitjuro.p (input  recid(titulo), 
                         input  today, 
                         output vjuros, 
                         output vsaldojuros).
        display
            estab.etbcod
            titulo.modcod
            {titnum.i}
            titulo.titdtemi
            titulo.titdtven
            vdias           when vdias > 0
/*            vcartcobra*/
            vtotal
            vjuros
            vsaldojuros
                with frame frame-a.
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
            vdias                    /*vcartcobra*/ vjuros vsaldojuros
            vtotal.
        
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
            titulo.titdtven
            vdias                    /*vcartcobra*/ vjuros vsaldojuros
            vtotal.
 
            status default "".
            if keyfunction(lastkey) = "p" or keyfunction(lastkey) = "P" 
            then do.
                color display normal esqcom1 with frame f-com1.
                esqpos1 = 9.
                color display message esqcom1[esqpos1] with frame f-com1.
            end.

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
            then do with centered row 8 color message
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
                find first titulo use-index iclicod where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod and
                          titulo.titdtpag = ?
                                            and titulo.titnum = vbusca
                                            and (if vtitpar <> ""
                                             then titulo.titpar = int(vtitpar)
                                                 else true) and
                          (if vetbcod <> 0
                           then titulo.etbcod = vetbcod
                           else true)                                                                                    no-lock no-error.
            else
                if vchoose = "venci"
                then
                    find first titulo use-index iclicod where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod and
                          titulo.titdtpag = ? and
                          titulo.titdtven < today
                                            and titulo.titnum = vbusca
                                            and (if vtitpar <> ""
                                             then titulo.titpar = int(vtitpar)
                                                 else true) and
                         (if vetbcod <> 0
                          then titulo.etbcod = vetbcod
                          else true)                                                 
                                        no-lock no-error.
                else
                if vchoose = "vence"
                then
                    find first titulo use-index iclicod where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod and
                          titulo.titdtpag = ? and
                          titulo.titdtven >= today
                                            and titulo.titnum = vbusca
                                            and (if vtitpar <> ""
                                             then titulo.titpar = int(vtitpar)
                                                 else true) and
                          (if vetbcod <> 0
                           then titulo.etbcod = vetbcod
                           else true)                                                 
                                        no-lock no-error.
                else
                if vchoose = "liqui"
                then
                    find last  titulo  use-index iclicod where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod and
                          titulo.titdtpag <>? 
                                            and titulo.titnum = vbusca
                                            and (if vtitpar <> ""
                                             then titulo.titpar = int(vtitpar)
                                                 else true) and
                         (if vetbcod <> 0                        
                          then titulo.etbcod = vetbcod
                          else true)                                                 
                                        no-lock no-error.
                else
                    find last  titulo use-index iclicod where
                          titulo.titnat = vtitnat and
                          titulo.clifor  = clien.clicod 
                                            and titulo.titnum = vbusca
                                            and (if vtitpar <> ""
                                             then titulo.titpar = int(vtitpar)
                                                 else true) and
                          (if vetbcod <> 0
                           then titulo.etbcod = vetbcod
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
                            find next titulo  use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            titulo.titdtpag = ?
                                            no-lock no-error.
                        else
                            if vchoose = "venci"
                            then
                                find next  titulo use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            titulo.titdtpag = ? and
                                            titulo.titdtven < today and
                                           (if vetbcod <> 0
                                            then titulo.etbcod = vetbcod
                                            else true)                                                                     no-lock no-error.
                            else
                            if vchoose = "vence"
                            then
                                find next  titulo use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            titulo.titdtpag = ? and
                                            titulo.titdtven >= today and
                                            (if vetbcod <> 0
                                             then titulo.etbcod = vetbcod
                                             else true)                                                                     no-lock no-error.
                            else
                            if vchoose = "liqui"
                            then
                                find prev  titulo  use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            titulo.titdtpag <>? and
                                            (if vetbcod <> 0
                                             then titulo.etbcod = vetbcod
                                             else true)                                                                     no-lock no-error.
                            else
                                find prev  titulo use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            (if vetbcod <> 0
                                             then titulo.etbcod = vetbcod
                                             else true)                                                                     no-lock no-error.
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
                            find prev titulo  use-index iclicod where
                                          titulo.titnat = vtitnat and
                                          titulo.clifor  = clien.clicod and
                                          titulo.titdtpag = ? and
                                          (if vetbcod <> 0
                                           then titulo.etbcod = vetbcod
                                           else true)                                                                   no-lock no-error.
                        else
                            if vchoose = "venci"
                            then
                                find prev  titulo use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            titulo.titdtpag = ? and
                                            titulo.titdtven < today and
                                            (if vetbcod <> 0
                                             then titulo.etbcod = vetbcod
                                             else true)                                                                     no-lock no-error.
                            else
                            if vchoose = "vence"
                            then
                                find prev  titulo use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            titulo.titdtpag = ? and
                                            titulo.titdtven >= today and
                                            (if vetbcod <> 0
                                             then titulo.etbcod = vetbcod
                                             else true)                                                                     no-lock no-error.
                            else
                            if vchoose = "liqui"
                            then
                                find next  titulo  use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            titulo.titdtpag <>? and
                                            (if vetbcod <> 0
                                             then titulo.etbcod = vetbcod
                                             else true)                                                                     no-lock no-error.
                            else
                                find next  titulo use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            (if vetbcod <> 0
                                             then titulo.etbcod = vetbcod
                                             else true)                                                                     no-lock no-error.
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
                        find next titulo  use-index iclicod where
                              titulo.titnat = vtitnat and
                              titulo.clifor  = clien.clicod and
                              titulo.titdtpag = ? and
                              (if vetbcod <> 0
                               then titulo.etbcod = vetbcod
                               else true)                              
                                    no-lock no-error.
                    else
                        if vchoose = "venci"
                        then
                            find next  titulo use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            titulo.titdtpag = ? and
                                            titulo.titdtven < today and
                                            (if vetbcod <> 0
                                             then titulo.etbcod = vetbcod
                                             else true)                                                                     no-lock no-error.
                        else
                        if vchoose = "vence"
                        then
                            find next  titulo use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            titulo.titdtpag = ? and
                                            titulo.titdtven >= today and
                                            (if vetbcod <> 0
                                             then titulo.etbcod = vetbcod
                                             else true)                                                                     no-lock no-error.
                        else
                        if vchoose = "liqui"
                        then
                            find prev  titulo  use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            titulo.titdtpag <>? and
                                            (if vetbcod <> 0
                                             then titulo.etbcod = vetbcod
                                             else true)                                                                     no-lock no-error.
                        else
                            find prev  titulo use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            (if vetbcod <> 0
                                             then titulo.etbcod = vetbcod
                                             else true)                                                                     no-lock no-error.
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
                              titulo.titdtpag = ? and
                              (if vetbcod <> 0
                               then titulo.etbcod = vetbcod
                               else true)                              
                                    no-lock no-error.
                    else
                        if vchoose = "venci"
                        then
                            find prev  titulo use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            titulo.titdtpag = ? and
                                            titulo.titdtven < today and
                                            (if vetbcod <> 0
                                             then titulo.etbcod = vetbcod
                                             else true)                                                                     no-lock no-error.
                        else
                        if vchoose = "vence"
                        then
                            find prev  titulo use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            titulo.titdtpag = ? and
                                            titulo.titdtven >= today and
                                            (if vetbcod <> 0
                                             then titulo.etbcod = vetbcod
                                             else true)                                                                     no-lock no-error.
                        else
                        if vchoose = "liqui"
                        then
                            find next  titulo  use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            titulo.titdtpag <>? and
                                            (if vetbcod <> 0
                                             then titulo.etbcod = vetbcod
                                             else true)                                                                     no-lock no-error.
                        else
                            find next  titulo use-index iclicod where
                                            titulo.titnat = vtitnat and
                                            titulo.clifor  = clien.clicod and
                                            (if vetbcod <> 0
                                             then titulo.etbcod = vetbcod
                                             else true)                                                                     no-lock no-error.
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

                if esqcom1[esqpos1] = "Notas Fiscais "
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
                    if clien.situacao = no
                    then do:
                    end.
                    else do:
                        hide frame fbloq no-pause.
                        color display message clien.situacao with frame f1.
                    end.
                    view frame f-com2.
                    view frame f-com1.
                    hide frame fbloq no-pause.
                    view frame fhelp.
/*                    view frame f-com2. */
                    view frame f-com1.

                end.
                if esqcom1[esqpos1] = "p/contrato "
                then do.
                    hide frame frame-a no-pause.
                    hide frame f-com1 no-pause.
                    run fin/fqcontrato.p (input titulo.clifor).
 
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

               end.
                if esqcom1[esqpos1] = "Nota Fiscal"
                then do.
                    run nota-fiscal.
                end.                
                if esqcom1[esqpos1] = "Consulta "
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
                    hide frame fbloq no-pause.
                    /***/
                    if (vchoose = "liqui" or
                            vchoose = "geral") and
                            vtotliquidado = 0
                    then do:
                        message color normal
                                    "Aguarde, Calculando o Total Liquidado...".
                        vtotliquidado = 0.
                        run fin/bsfqtagle.p (input        vtitnat, 
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
            assign
                vtotal = if titulo.titdtpag = ?
                         then titulo.titvlcob - titulo.titvlpag
                         else 0.
        find cobra    of titulo no-lock.
        vcartcobra = trim(substr(cobra.cobnom,1,5) + "/").
        find banco of titulo no-lock no-error.
        if avail banco
        then
            substr(vcartcobra,1,5) = banco.banfan.
        if titulo.titdtpag = ?
        then vdias = today - titulo.titdtven.
        else vdias = titulo.titdtpag - titulo.titdtven.
        find estab where /*estab.empcod = wempre.empcod and*/ estab.etbcod = titulo.etbcod no-lock.
        if titulo.titdtpag <> ?
        then
            vcartcobra = "Liqui " + string(titdtpag,"99/99/9999").
        if vtotal < 0
        then vtotal = 0.
        run bstitjuro.p (input  recid(titulo), 
                         input  today, 
                         output vjuros, 
                         output vsaldojuros).
        display
            estab.etbcod
            titulo.modcod
            {titnum.i}
            titulo.titdtemi
            titulo.titdtven
            vdias           when vdias > 0
/*            vcartcobra*/
            vtotal
            vjuros
            vsaldojuros
                    with frame frame-a.
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
