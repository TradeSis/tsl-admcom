/*
*           fqconttit.p
*
*/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Consulta "," Pagamentos "," Dt.Lanc ", " "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].
{cabec.i}

def input parameter par-titnum  like titulo.titnum.

def shared temp-table ttparc
     field titnum    like titulo.titnum
    field titpar    like titulo.titpar
    field modcod    like titulo.modcod
    field titdtemi  like titulo.titdtemi
    field rec       as   recid
    index titnum    is   primary       titnum asc
                                       titpar asc
                                       modcod asc
                                       titdtemi asc
    index rec is unique  rec asc.                                      

def buffer bttparc       for ttparc.
def var vttparc         like ttparc.titnum.


form
    esqcom1
    with frame f-com1
                 row 10 no-box no-labels side-labels column 1 centered.

form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

def var vast as char format "x".
form
    estab.etbcod
    with frame frame-a.
    
bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find ttparc where recid(ttparc) = recatu1 no-lock.
    if not available ttparc
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(ttparc).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available ttparc
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
            find ttparc where recid(ttparc) = recatu1 no-lock.
            find titulo where recid(titulo) = ttparc.rec no-lock.

             esqcom1[4] = "".
            if sfuncod = 99999
               and titulo.titdtpag = ?
            then do. 
                esqcom1[4] = " Deleta ".
            end.
            display esqcom1 with frame f-com1.
            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(ttparc.titnum)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(ttparc.titnum)
                                        else "".

            choose field titulo.titnum help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) .

            status default "".

        end.
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
                    if not avail ttparc
                    then leave.
                    recatu1 = recid(ttparc).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttparc
                    then leave.
                    recatu1 = recid(ttparc).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttparc
                then next.
                color display white/red titulo.titnum with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttparc
                then next.
                color display white/red titulo.titnum with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form ttparc
                 with frame f-ttparc color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " consulta "
                then do with frame f-Lista:
                    hide frame f-com1 no-pause. 
                    find ttparc where recid(ttparc) = recatu1 no-lock. 
                    find titulo where recid(titulo) = ttparc.rec no-lock.
                    run bsfqtitulo.p (input recid(titulo)).
                    view frame f-com1.
                end.
                if esqcom1[esqpos1] = " pagamentos "
                then do with frame f-Listda:
                    hide frame f-com1 no-pause. 
                    run pagamentos.
                    view frame f-com1.
                    recatu1 = ?.
                    leave.
                end.
                if esqcom1[esqpos1] = " Dt.Lanc "
                then do with frame f-Listdddd:
                    hide frame f-com1 no-pause. 
                    run dtlancamento.
                    view frame f-com1.
                    recatu1 = ?.
                    leave.
                end.
                
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    view frame f-com1.
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
        recatu1 = recid(ttparc).
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

procedure frame-a.
find titulo where recid(titulo) = ttparc.rec no-lock.
def var vcartcobra  as char column-label "Carteira".
def var vdias as int   format "->>9".
def var vsaldo          like titulo.titvlcob    column-label "Saldo".
def var vjur            like titulo.titjuro     column-label "Encargos".
def var vsaldojur      like titulo.titvlcob    column-label "Saldo c/Juro".
def var vsaldobase like titulo.titvlcob.
def var vsaldoatualizado like titulo.titvlcob.
def var vperc as dec.
def var vvalormulta as dec.
assign vsaldo = if titulo.titdtpag = ? 
                then titulo.titvlcob - titulo.titvlpag 
                else 0.

    if today > titulo.titdtven  and 
       titulo.modcod <> "conv"  and
       titulo.titdtpag = ?
    then do:
        do.
            vsaldobase = vsaldo.
            /**
            run fbjuro.p (input titulo.cobcod, 
                      input titulo.carcod, 
                      input titulo.titnat, 
                      input vsaldo,
                      input titulo.titdtven, 
                      input today, 
                      output vsaldoatualizado, 
                      output vperc) .
                      **/
        end.
        /**
        run fbmulta.p (input titulo.cobcod,  
                       input titulo.carcod,  
                       input titulo.titnat,  
                       input vsaldobase,
                       input titulo.titdtven,  
                       input today,  
                       output vvalormulta).
                       **/
    end.
    else vsaldoatualizado = vsaldo.

assign
                vsaldo = if titulo.titdtpag = ?
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
        find estab where estab.etbcod = titulo.etbcod no-lock.
        if titulo.titdtpag <> ?
        then
            vcartcobra = "Liqui " + string(titdtpag,"99/99/9999").
        if vsaldo < 0
        then vsaldo = 0.
        vjur = vsaldoatualizado - vsaldo .
        if titulo.titdtpag <> ?
        then assign vsaldoatualizado = titulo.titvlpag
                    vjur = 0.
        display
            estab.etbcod  column-label "Fil" format ">>9"
            titulo.modcod column-label "Modal"
            {titnum.i}                         
            titulo.titdtven format "99/99/99" column-label "Vecto"  
            vdias           when vdias > 0 and titulo.titdtpag = ?
                                    column-label "Atr"
                                    
            titulo.titdtpag   format "99/99/9999"
            vsaldo            format ">>>,>>9.99"
            vjur              format ">>>>9.99"  
            vsaldoatualizado  format ">>>,>>9.99"  column-label "Total"
                with frame frame-a 8 down centered /*attr-space*/
                /*color white/red*/ row 13
                                no-box width 80.

end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first ttparc where ttparc.titnum = par-titnum
                                                no-lock no-error.
    else  
        find last ttparc  where ttparc.titnum = par-titnum
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next ttparc  where ttparc.titnum = par-titnum
                                                no-lock no-error.
    else  
        find prev ttparc   where ttparc.titnum = par-titnum
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev ttparc where ttparc.titnum = par-titnum  
                                        no-lock no-error.
    else   
        find next ttparc where ttparc.titnum = par-titnum 
                                        no-lock no-error.
        
end procedure.
         

procedure pagamentos.

/**for each ttparc where ttparc.titnum = par-titnum
,
    titulo where recid(titulo) = ttparc.rec no-lock,
    each titpag of titulo where titpag.cmopenat <> ?  no-lock
                                by titulo.titnum
                                by titulo.titpar
                                by titpag.titdtpag
                                .
    disp titulo.titnum
         titulo.titpar
         titpag.titdtpag
         cmopenat
         titpag.titvlpag.
end.
**/
end procedure.

