/*                                                                  
*       crclitel.p
*/
def new global shared var tetbcod like estab.etbcod.
def new global shared var tfuncod like func.funcod.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial no.
def var esqcom1         as char format "x(15)" extent 5
    initial [" Novo "," ",""].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5
   initial [" ",
            " ",
            " ",
            " ",
            " "].

{admcab.i}

form 
     clitel.codcont validate(can-find(first tipcont where
                                        tipcont.codcont = clitel.codcont),
                                        "Tipo nao cadastrado")
                label "Hist"
     tipcont.desccont no-label
     clitel.dtpagcont label "Data" at 55 skip
     clitel.fonecont label "Fone"
     clitel.tiphis label "Melhor Horario" format "99:99"
     clitel.telobs[1] label "Obs"
     clitel.telobs[2] no-label at 6
     clitel.telobs[3] no-label at 6
     with frame f-clitel1 centered row 12 color message side-label
     width 75 overlay.

def input parameter par-clien as recid.
def input parameter par-rec as recid.

find clien where recid(clien) = par-clien no-lock.
find clilig where recid(clilig) = par-rec no-lock no-error.
def var    vobs       like clitel.telobs.
def var vdatahora as char.
form   vdatahora        column-label "Data" format "x(11)"
       clitel.funcod
       clitel.etbcobra
       with frame frame-a.

def temp-table ttabertos
    field etbcod    like titulo.etbcod
    field titnum    like titulo.titnum
    field modcod    like modal.modcod
    index abe   is  primary unique  etbcod  asc
                                    titnum  asc
                                    modcod  asc.

def var vtitnum like titulo.titnum.
def var vsaldo  like titulo.titvlcob.
form
    esqcom1
    with frame f-com1
                 row 7 no-box no-labels side-labels column 1 centered
                            overlay.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered overlay.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        if esqascend
        then
            find first clitel  use-index clitel where
                                    clitel.clicod = clien.clicod
                                        no-lock no-error.
        else
            find last clitel use-index clitel where
                                    clitel.clicod = clien.clicod
                                        no-lock no-error.
    else
        find clitel where recid(clitel) = recatu1 no-lock.
    if not available clitel
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then
        run frame-a.

    recatu1 = recid(clitel).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next clitel use-index clitel where
                                    clitel.clicod = clien.clicod
                                        no-lock.
        else
            find prev clitel use-index clitel where
                                    clitel.clicod = clien.clicod
                                        no-lock.
        if not available clitel
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
            find clitel where recid(clitel) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(clitel.clicod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(clitel.clicod)
                                        else "".
            color display message   
/***                  clitel.teldat ***/
                  clitel.funcod format ">>>>>9"
                  clitel.codcont 
                  tipcont.desccont format "x(18)"
                  clitel.dtpagcont
                  clitel.fonecont
                  clitel.tiphis
                  with frame frame-a.

            disp clitel.telobs[1] label "OBS" skip
                 space(5) clitel.telobs[2]  no-label skip
                 space(5) clitel.telobs[3] no-label skip
                with frame f-obs row 19 side-labels no-box.
            
            choose field clitel.codcont help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                       PF4 F4 ESC return) color white/black.
            color display normal   
/***                         clitel.teldat***/
                         clitel.funcod
                         clitel.codcont 
                         tipcont.desccont
                         clitel.fonecont
                         clitel.tiphis
                         clitel.dtpagcont
                         with frame frame-a.

            status default "".

        end.
        {esquema.i &tabela = "clitel"
                   &campo  = "vdatahora"
                   &indice = "use-index clitel"
                   &where  = "clitel.clicod = clien.clicod"
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave:
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                if esqcom1[esqpos1] = " Novo "
                then do:
                    /***/
                    pause 0.
                    find clien where recid(clien) = par-clien no-error.
                    do on error undo with frame f-clitel:

/*                         clien.dtlig = today.*/

                         create clitel.
                         assign
                            clitel.clicod = clien.clicod
                            clitel.titcod =   ?
                            clitel.teldat = today 
                            clitel.telhor = time
                            clitel.fonecont = clien.fone
                            clitel.codcont = 0
                            clitel.funcod = tfuncod
                            clitel.etbcobra = tetbcod.
                         if avail clilig
                         then do.
                                assign clitel.titpar = clilig.titpar  
                                       clitel.titnum = clilig.titnum  
                                       clitel.titnat = clilig.titnat 
                                       clitel.empcod = clilig.empcod 
                                       clitel.modcod = clilig.modcod 
                                       clitel.etbcod = clilig.etbcod 
                                       clitel.clicod = clilig.clicod      .
                         end.

                         do on error undo, retry:
                                update clitel.codcont format ">>9"
                                       with frame f-clitel1.
                            find tipcont where tipcont.codcont =
                                               clitel.codcont no-lock no-error.
                            if not avail tipcont
                            then do.
                                message "Codigo invalido" view-as alert-box.
                                undo.
                            end.
                            disp tipcont.desccont with frame f-clitel1.

                            if tipcont.mdata                        
                            then update clitel.dtpagcont            
                                              with frame f-clitel1. 

                            if clitel.codcont = 10
                            and avail cpfis
                            then clitel.fonecont = clien.fone.
                            else clitel.fonecont = clien.fone.
                            update clitel.fonecont with frame f-clitel1.
                            /*
                            clien.dtacor = if clitel.codcont = 9
                                        then (today + 90)
                                        else clitel.dtpagcont.
                            */
                            
                            update clitel.tiphis format "99:99" label "Melhor Horario" with frame f-clitel1.
                            update clitel.telobs[1]
                                   clitel.telobs[2]
                                   clitel.telobs[3]
                                   with frame f-clitel1.
                    
                            /*** historico observacao Crediario 
                            create sitcli.
                            assign sitcli.LCreCod = ?                   
                                   sitcli.sitdata    = today            
                                   sitcli.sithora    = time             
                                   sitcli.clicod= clien.clicod      
                                   sitcli.Valor   = 0                   
                                   sitcli.funcod  = sfuncod             
                                   sitcli.etbcod  = setbcod             
                                   sitcli.Credito = ?                   
                                   sitcli.LCreTip = "CRM".              
                                   sitcli.motivo  = tipcont.desccont + " " +
                                                    clitel.telobs[1] + " " +
                                                    clitel.telobs[2] + " " +
                                                    clitel.telobs[3].
                            ********/
                            /***********************
                            if tipcont.cobrataxa
                            then do.
                                /* DCT */
                                for each ttabertos.
                                    delete ttabertos.
                                end.
                                run abertos.
                                for each ttabertos.
                                    vsaldo = 0.
                                    for each titulo where titulo.titnat = no
                                           and titulo.clifor = clien.clicod
                                           and titulo.titdtpag = ?
                                           and titulo.titnum = ttabertos.titnum
                                           and titulo.etbcod = ttabertos.etbcod
                                           and titulo.tdfcod = "CON"
                                           and titulo.modcod = "DCT"
                                        no-lock.
                                      vsaldo = vsaldo + titulo.titvlcob.
                                    end.
                                    if vsaldo < vvl-dct * 4
                                    then do.
                                        vtitnum = string(ttabertos.titnum).
                
                                        {busnum.i TITULO}
                                        create titulo.
                                        assign
                                          titulo.titcod    = snumcod
                                         /*titulo.fatcod    = fatura.fatcod  */
                                          titulo.titnat    = no
                                          titulo.clifor    = clien.clicod  
                                         /*titulo.placod     = plani.placod  */
                                          titulo.etbcod    = ttabertos.etbcod
                                          titulo.titdtven  = today
                                          titulo.modcod    = "DCT"
                                          titulo.titpar    = 0
                                          titulo.titsit    = "LIB"  
                                          titulo.titvlcob  = vvl-dct
                                          titulo.titnum    = vtitnum
                                          titulo.titdtemi  = today
                                          titulo.titdtprog = today
                                          titulo.tdfcod    = "CON"
                                          titulo.cobcod    = 1
                                          titulo.carcod    = 2. /* Sem juros */
                                    end.
                                end.
                            end.
                            ************************/
                            /*
        

                            */
                            /*************** antonio *************/
                            clear frame f-clitel1 all.
                            hide frame f-clitel1 no-pause.

                            vobs[1] = clitel.telobs[1].
                            vobs[2] = clitel.telobs[2].
                            vobs[3] = clitel.telobs[3].

                         end.
                    end.
                    hide frame f-clitel1 no-pause.            
                    /***/
                    recatu1 = ?.
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta "
                then do:
                    recatu1 = ?.
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                leave.
            end.
        end.
        if not esqvazio
        then
           run frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(clitel).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.

hide frame f-com1 no-pause.
hide frame f-com2 no-pause.
hide frame frame-a no-pause.
hide frame f-obs no-pause.

procedure frame-a.

   vdatahora = substr(string(clitel.teldat,"99/99/99"),1,5) + " " +
                      string(clitel.telhor,"HH:MM").

   find tipcont of clitel  no-lock no-error.
   disp vdatahora        column-label "Data" format "x(11)"
        clitel.funcod    format ">>>>>9"
        clitel.etbcobra  format ">>>" label "Etb"
        clitel.codcont   column-label "Tipo" format ">>9"
        tipcont.desccont column-label "Historico"  when avail tipcont format "x(18)"
        clitel.dtpagcont column-label "Prev.Pgt" format "99/99/99"
        clitel.fonecont  column-label "Fone"     format "x(12)"
        clitel.tiphis    column-label "M.H."     format "99:99"
        with frame frame-a 7 down centered color white/red row 8 overlay 
                width 80.

end procedure.


procedure abertos.
def buffer btitulo for titulo.
for each btitulo where btitulo.titnat   = no                and
                       btitulo.clifor   = clien.clicod     and
                       btitulo.titdtpag = ?                 and
                       btitulo.titdtven < today - 11
                 no-lock.
    if btitulo.modcod = "cli"
    then do.
        find ttabertos where ttabertos.etbcod = btitulo.etbcod and
                             ttabertos.titnum = btitulo.titnum and
                             ttabertos.modcod = btitulo.modcod no-error.
        if not avail ttabertos 
        then create ttabertos.
        assign ttabertos.etbcod = btitulo.etbcod 
               ttabertos.titnum = btitulo.titnum 
               ttabertos.modcod = btitulo.modcod.
    end.
end.
end procedure.
