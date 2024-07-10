/*diSp searcH("tt-clifor.p") format "x(30)".*/

/*
*
*    tt-clifor.p    -    Esqueleto de Programacao    com esqvazio


            substituir    tt-clifor
                          <tab>
*
*/
 


def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial no.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Listagem "," Etiqueta "," Cadastro ",
            " ", ""].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

{admcab.i}

def var vdtini as date format "99/99/9999" column-label "Inicio".
def var vdtfim as date format "99/99/9999" column-label "Fim".


def shared temp-table tt-clifor
        field clfcod        like clien.clicod
        field ranking       as int
        field medven        as dec
        field maxven        as dec
        field freq          as int
        index freq     freq asc
                       medven asc
                       maxven asc 
        index clifor   clfcod asc
        index maxven   maxven desc
        index rankink ranking asc.

def workfile wfclifor
    field rec-clifor as recid.
    
find first tt-clifor no-lock no-error.
if not avail tt-clifor then do:
    message "Nenhum Agente Comercial Selecionado". 
    pause 2 no-message.
    leave.
end.
def var vcont as int.

for each tt-clifor. 
    vcont = vcont + 1.
end.
    
disp vcont label "Selecionados "
     "Periodo de " at 43 vdtini no-label " A " vdtfim no-label
        with frame fcab row 3 color messages no-box side-labels.


def var vdata           as date              initial today.
def var vmala           as char format "x(60)".
def var vdias           as integer.
def var vmes            as integer.
def var vconta3          as integer.
def var vconta4         as integer.
def var vclfnom           like clien.clinom         extent 4.
def var vendereco       like clien.endereco     extent 4.
def var vcompl          like clien.compl        extent 4.
def var vcidade         like clien.cidade        extent 4.
def var vcep            like clien.cep          extent 4 format "x(50)".
def var ii              as integer.
def var vcol            as integer.
def var vtam            as integer.                 /** TAMANHO DA ETIQUETA **/
def var vspace-col      as integer.                 /** COLUNAS ENTRE ETIQ. **/
def var vspace-lin      as integer.                 /** LINHAS  ENTRE ETIQ. **/
def var vetiq           as integer.                 /** NUMERO DE ETIQ.     **/

def var vfone-res       like clien.fone label "Fone Res.".
def var vfone-cel       like clien.fone label "Celular".
def var vfone           like clien.fone.
def var vemail          as   char format "x(50)" label "E-Mail".


/***/
   

def buffer btt-clifor       for tt-clifor.
def var vtt-clifor         like clien.clinom.


form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        if esqascend
        then
            find first tt-clifor use-index freq where
                                    true
                                        no-lock no-error.
        else
            find last tt-clifor use-index freq where
                                    true
                                        no-lock no-error.
    else
        find tt-clifor where recid(tt-clifor) = recatu1 no-lock.
    if not available tt-clifor
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        find clien where
                clien.clicod = tt-clifor.clfcod no-lock.
        display
            tt-clifor.ranking   column-label "Ranking" format ">>>>9"
            clien.clicod       column-label "Codigo"
            clien.clinom       column-label "Nome"  format "x(25)" 
            tt-clifor.maxven    column-label "Total"
            tt-clifor.freq      column-label "Freq"
            tt-clifor.medven    column-label "Media"
                with frame frame-a 10 down centered color white/red row 5.
    end.

    recatu1 = recid(tt-clifor).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next tt-clifor use-index freq where
                                    true
                                        no-lock.
        else
            find prev tt-clifor use-index freq where
                                    true
                                        no-lock.
        if not available tt-clifor
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        find clien where
                clien.clicod = tt-clifor.clfcod no-lock.
        display
            tt-clifor.ranking
            clien.clicod       
            clien.clinom        
            tt-clifor.medven
            tt-clifor.maxven
            tt-clifor.freq
 
                with frame frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find tt-clifor where recid(tt-clifor) = recatu1 no-lock.
            find clien where
                clien.clicod = tt-clifor.clfcod no-lock.
                            
            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(clien.clinom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(clien.clinom)
                                        else "".

            /*find cpfis of clifor no-lock no-error.  */
            vfone      = clien.fone.
            .
            /*
            disp
                clifor.endereco colon 10 format "x(30)"
                clifor.numero 
                clifor.bairro format "x(20)" colon 10
                 clifor.cidade   format "x(20)"
                clifor.uf
                vfone       colon 10
                cpfis.dtnasc when avail cpfis 
                tt-clifor.data  label "Ultima Compra"
                with frame fdados
                row 15 side-labels centered overlay no-box
                    width 81.
            */
            
            choose field clien.clinom help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) color white/black.

            status default "".

        end.
        {esquema.i &tabela = "tt-clifor"
                   &campo  = "clien.clinom"
                   &index  = "use-index freq"
                   &where  = "true"
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave:
            form tt-clifor
                 with frame f-tt-clifor color black/cyan
                      centered side-label row 5 .
            /*hide frame frame-a no-pause.*/
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                if esqcom1[esqpos1] = " Listagem "
                then do:
                    run mktlis.p.
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    hide frame frame-a no-pause.
/*                    return.*/
                end.
                if esqcom1[esqpos1] = " Etiqueta "
                then do:
                    input from ../gener/malapar.txt no-echo.
                    repeat:
                        set vtam vspace-col vspace-lin vetiq.
                    end.
                    input close.
                    for each tt-clifor.
                        find clien where
                                clien.clicod = tt-clifor.clfcod
                                no-lock.
                        create wfclifor.
                        assign wfclifor.rec-clifor = recid(clien).
                    end. 
                    {etq.i &tabela   = "wfclifor"
                           &campo    = "rec-clifor"
                           &where    = " "
                           &compacta = yes
                           &teste    = 2
                           &tamanho  = vtam
                           &spc-col  = vspace-col
                           &spc-row  = vspace-lin
                           &colunas  = vetiq }
                    recatu1 = ?.
                    leave.
                end.
                
                /*
                if esqcom1[esqpos1] = " Classes "
                then do:
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    run mktclcli.p (input tt-clifor.rec-clifor).
                    view frame fcab.
                    view frame f-com1.
                    view frame f-com2.
                end.
                */
                
                if esqcom1[esqpos1] = " Cadastro "
                then do:
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause. 
                if clifor.tippes
                then 
                    run cpfis.p ( input clifor.clfcod,
                                  input 1,
                                  input "c"). 
                else 
                    run cpjur.p (input clifor.clfcod, 
                                 input 1, 
                                 input "c").   
                    view frame fcab.
                    view frame f-com1.
                    view frame f-com2.
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
        find clifor where
                clifor.clfcod = tt-clifor.clfcod no-lock.
        display
            tt-clifor.ranking
            clifor.clfcod 
            clifor.clfnom   
            tt-clifor.medven
            tt-clifor.maxven
            tt-clifor.freq
                 with frame frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-clifor).
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
