{admcab.i}
{setbrw.i}

def var vanalitico      as log format "Analitico/Sintetico" init yes.
def var par-analitico   as char.

def var vdtfin as date.

def var vret like clitel.codcont.
def temp-table tt-liga 
    field telhor as char format "x(10)"  label "HoraLiga" 
    field clfcod like clifor.clfcod
    field clfnom like clifor.clfnom  format "x(31)"
    field matras as   date format "99/99/9999"  label "Maior Atraso"
    field diasat as   int format ">>>9"         label "Dias"
    field valdiv as   dec                       label "Divida"
    field telobs as char format "x(75)"
    field rec-clitel    as recid
    index i1 telhor.

def temp-table tt-sinte
    field codcont like clitel.codcont
    field funcod  like func.funcod
    field qtd     as   int
    field seq     as   int init ?
    field qtd-pag as   int
    field val-pag like titulo.titvlpag
    index funcod is primary unique funcod  asc
                                   codcont asc
    index seq    is unique codcont asc
                           seq     asc.
                                       

def var vttlig as int format ">>>>>9".
def var vttcli as int format ">>>>>9".    
def var vfuncod like func.funcod .
def var vdatlig as   date format "99/99/9999" label "Data Ligacao".
def var vdivida as dec.
def var vnumdias as int.
def var vdown as int.
def var vok as log.
form tt-liga.telhor 
     tt-liga.clfcod 
     tt-liga.clfnom format "x(25)" 
     tt-liga.matras 
     tt-liga.diasat 
     tt-liga.valdiv
     with frame frame-a 6 down centered row 6.
form with frame ff.
vdatlig = today.
repeat:
    clear frame f1 all.
    assign
        vfuncod = 0
        .                     
    update vanalitico no-label with frame f11 row 3.
    par-analitico = "".
    if vanalitico = no
    then par-analitico = "SINTETICO".
    update vdatlig validate(vdatlig <= today,"Data Invalida") with frame f11.
    vdtfin = vdatlig.
    if par-analitico = "SINTETICO"
    then                     
        update vdtfin colon 23 format "99/99/9999"
                    label "Data Final" with frame f111 row 4
                        no-box side-label.
    
    /***/
    def temp-table tt-func
        field codigo    like func.funcod
        field apelido    like func.funape
        index funape    is primary unique apelido asc
        index funcod    codigo asc.
    for each tt-liga .
        delete tt-liga .
    end.
    for each tt-sinte.
        delete tt-sinte. 
    end.
    for each tt-func.
        delete tt-func.
    end.
    if par-analitico = "SINTETICO"
    then do:
        for each clitel where clitel.teldat >= vdatlig and
                              clitel.teldat <= vdtfin  no-lock.
            if clitel.codcont = 0  
            then next.
            find tt-func where tt-func.codigo = clitel.funcod no-error.
            find func of clitel no-lock.
            if not avail tt-func
            then create tt-func.
            assign tt-func.codigo  = clitel.funcod
                   tt-func.apelido = func.funape.
            find tt-sinte where tt-sinte.funcod  = func.funcod and
                                tt-sinte.codcont = clitel.codcont
                                no-error.
            if not avail tt-sinte 
            then do:
                create tt-sinte.
            end.                
            assign tt-sinte.funcod   = func.funcod
                   tt-sinte.codcont  = clitel.codcont
                   tt-sinte.qtd      = tt-sinte.qtd + 1.
            /*
            find titulo where  titulo.titcod = clitel.titcod no-lock no-error.
            */
            find first titulo where titulo.titnat   = no            and
                                    titulo.clfcod   = clitel.clfcod and
                                   (titulo.modcod   = "GE" or
                                    titulo.modcod   = "CLI")        and
                                    titulo.titdtven < clitel.teldat and
                                    titulo.titdtpag <> ?            and
                                    titulo.titdtpag >= clitel.teldat
                                    no-lock no-error.
            if avail titulo
            then do:
                if titulo.titdtpag <> ? and (titulo.titdtpag >= vdatlig and
                                             titulo.titdtpag <= vdtfin)
                then 
                    assign tt-sinte.qtd-pag = tt-sinte.qtd-pag + 1
                           tt-sinte.val-pag = tt-sinte.val-pag +
                                                titulo.titvlpag.
            end.        
        end.
    end.
    else do:
        for each clitel where clitel.teldat = vdatlig  no-lock:
            if clitel.tiphis = "999"
            then next.
            if clitel.codcont = 0  then next.
            find tt-func where tt-func.codigo = clitel.funcod no-error.
            find func of clitel no-lock.
            if not avail tt-func
            then create tt-func.
            assign tt-func.codigo  = clitel.funcod
                   tt-func.apelido = func.funape.
        end.
    
    end.
    if par-analitico = "SINTETICO"
    then do:
        run sintetico.
        next.
    end.
    {zoomesq.i tt-func codigo apelido 30 Funcionarios.na.Data true}
    vfuncod = int(sretorno).
    /***/

    disp  vfuncod with frame f11 side-label width 81
                    no-box.
    find first func where 
               func.funcod = vfuncod no-lock no-error.
    if not avail func
    then do:
        bell.
        message "Funcionario nao cadastrado".
        pause. 
        undo.
    end.
    display func.funape no-label with frame f11.
    /*update vdatlig validate(vdatlig <= today,"Data Invalida") with frame f1.
    */
    repeat:
    run tt-tip.p(input func.funcod,
                 input vdatlig,
                 output vret).
    if keyfunction(lastkey) = "end-error" then leave.
    
    for each tt-liga:
        delete tt-liga.
    end.    
 
    for each clitel where             
             clitel.teldat  = vdatlig  and
             clitel.funcod  = func.funcod and
             if vret <> 0
             then clitel.codcont = vret 
             else true no-lock:
        if codcont = 0  then next.
        find first clifor where 
                  clifor.clfcod = clitel.clfcod no-lock.
        vdivida = 0.
        for each titulo where titulo.titnat = no and
                          titulo.clfcod = clifor.clfcod and
                          titulo.titdtpag = ? no-lock:
            vdivida = vdivida + titulo.titvlcob.
        end.
        vnumdias = today - clifor.dtven.
        create tt-liga.
        assign
            tt-liga.telhor = string(clitel.telhor,"HH:MM:SS")
            tt-liga.clfcod = clifor.clfcod
            tt-liga.clfnom = clifor.clfnom
            tt-liga.matras = clifor.dtven
            tt-liga.valdiv = vdivida
            tt-liga.diasat = vnumdias
            tt-liga.telobs = clitel.telobs[1] 
            tt-liga.rec-clitel = recid(clitel). 
    end.
    vdown  = 0.
    vttlig = 0.
    vttcli = 0.
         
    for each tt-liga break by tt-liga.clfcod:
        vdown = vdown + 1.
        vttlig = vttlig + 1.
        if last-of(tt-liga.clfcod)
        then vttcli = vttcli + 1.
    end.    
    display "       Total de Ligacoes: " vttlig
            "       Total de Clientes: " vttcli
            with frame f-tot 1 down no-box width 80 row screen-lines no-label
                        overlay.
            
    if vret = 0
    then display "TODAS AS LIGACOES" @ tipcont.desccont
            with frame f-title centered
                    color message no-box row 4 overlay.
    else do:
        find tipcont where tipcont.codcont = vret no-lock no-error.
        display tipcont.desccont no-label with frame f-title.
    end.

run esquema.
    
    end.
    hide frame f-linha no-pause. 
    hide frame ff no-pause.
    hide frame f-tot no-pause.
end.

    procedure imprime.
    do:
        bell.
        sresp = no.
        message "Confirma emissao do relatorio? " update sresp.
        if not sresp
        then next.
        
        varqsai = "../impress/funtel.txt".

        {mdadmcab.i
            &Saida     = "value(varqsai)"
            &Page-Size = "63"
            &Cond-Var  = "115"
            &Page-Line = "66"
            &Nom-Rel   = ""FUNTEL""
            &Nom-Sis   = """SISTEMA COMERCIAL"""
            &Tit-Rel   = """CONTROLE DE COBRANCA * "" + STRING(FUNC.FUNCOD) +
                        "" "" + FUNC.FUNNOM + "" EM "" + 
                                STRING(VDATLIG,""99/99/9999"")"
            &Width     = "130"
            &Form      = "frame f-cabcab"}
        for each tt-liga use-index i1:
            
            display tt-liga.telhor                  column-label "HORA"
                    tt-liga.clfcod                  column-label "CONTA"
                    tt-liga.clfnom  FORMAT "X(35)"  column-label "CLIENTE"
                    tt-liga.matras                  column-label "M ATRASO"
                    tt-liga.valdiv                  column-label "V DIVIDA"
                    tt-liga.diasat when diasat > 0  column-label "D ATRASO"
                    tt-liga.telobs format "x(40)"   colUmn-label "RECADO"
                    with frame f-disp down width 130.
                    
        end.
        put skip(1)
            "Total de Ligacoes: " vttlig 
            "    Total de Clientes: " vttcli.
        {mdadmrod.i
            &Saida     = "value(varqsai)"
            &NomRel    = """FUNTEL"""
            &Page-Size = "63"
            &Width     = "130"
            &Traco     = "32"
            &Form      = "frame f-rod3"}.

    end.
    end procedure.
    

procedure esquema.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Consulta ","  "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

def buffer btt-liga       for tt-liga.
def var vtt-liga         like tt-liga.telhor. 

form
    esqcom1
    with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered 
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
    /*
    disp esqcom1 with frame f-com1.*/
    if recatu1 = ?
    then
        if esqascend
        then
            find first tt-liga where
                                    true
                                        no-lock no-error.
        else
            find last tt-liga where
                                    true
                                        no-lock no-error.
    else
        find tt-liga where recid(tt-liga) = recatu1 no-lock.
    if not available tt-liga
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.
    else leave.

    recatu1 = recid(tt-liga).
    /*
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    */
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next tt-liga where
                                    true
                                        no-lock.
        else
            find prev tt-liga where
                                    true
                                        no-lock.
        if not available tt-liga
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
            find tt-liga where recid(tt-liga) = recatu1 no-lock.
            find clitel where recid(clitel) = tt-liga.rec-clitel no-lock.
            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-liga.telhor)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-liga.telhor)
                                        else "".
            display 
                    clitel.datac   
                    clitel.dtpagcont 
                    clitel.telobs[1]    label "Obs"
                    clitel.telobs[2]    label ""
                    clitel.telobs[3]    label ""
                    clitel.titnum  
                    with frame fffff 3 column side-label
                        row 16 overlay no-box width 81 color message.
            
            choose field tt-liga.telhor help ""
                go-on(cursor-down cursor-up
                      /*cursor-left cursor-right*/
                      page-down   page-up
                      PF4 F4 ESC return) .

            status default "".

        end.
        {esquema.i &tabela = "tt-liga"
                   &campo  = "tt-liga.telhor"
                   &where  = "true"
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave:
            form 
                with frame f-tt-liga color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-tt-liga on error undo.
                    recatu1 = recid(tt-liga).
                    leave.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered.
                    message "Confirma Exclusao de" tt-liga.telhor
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next tt-liga where true no-error.
                    if not available tt-liga
                    then do:
                        find tt-liga where recid(tt-liga) = recatu1.
                        find prev tt-liga where true no-error.
                    end.
                    recatu2 = if available tt-liga
                              then recid(tt-liga)
                              else ?.
                    find tt-liga where recid(tt-liga) = recatu1.
                    delete tt-liga.
                    recatu1 = recatu2.
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
                    then run ltt-liga.p (input 0).
                    else run ltt-liga.p (input tt-liga.telhor).
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
        /*
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        */
        recatu1 = recid(tt-liga).
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
end procedure.

procedure frame-a. 
    display 
            tt-liga.telhor
            tt-liga.clfcod 
            tt-liga.clfnom 
            tt-liga.matras  
            tt-liga.valdiv 
            tt-liga.diasat   when tt-liga.diasat > 0
            with frame frame-a overlay.
end procedure.

def temp-table tt
    field seq  as int
    field funcod as int.
def temp-table tt-linha
    field codcont like clitel.codcont      format " zzzz |"
    field qtd     like tt-sinte.qtd  extent 19 format "zzzzzz|".
def temp-table tt-perc
    field codcont like tt-linha.codcont
    field perc    as   dec format "zz9.99%" extent 19.
def buffer btt-linha for tt-linha.
 

procedure sintetico.

def var i as int.    
for each tt-sinte break by funcod.
    find tt where tt.funcod = tt-sinte.funcod no-error.
    if avail tt then next.
    i = i + 1.
    create tt.
    assign tt.funcod = tt-sinte.funcod
           tt.seq    = i.
end.
for each tt.
    for each tt-sinte where tt-sinte.funcod = tt.funcod.
        tt-sinte.seq = tt.seq.
    end.
end.    
def var vtotlig as int.
def var vqtdpag as int.
def var vvalpag as int.
vtotlig = 0.
for each tt-sinte break by tt-sinte.codcont.
    find tt-linha where tt-linha.codcont = tt-sinte.codcont no-error.
    if not avail tt-linha
    then create tt-linha.
    assign tt-linha.codcont           = tt-sinte.codcont
           tt-linha.qtd[tt-sinte.seq] = tt-sinte.qtd.
    find tt-linha where tt-linha.codcont = ? no-error.
    if not avail tt-linha
    then create tt-linha.
    assign tt-linha.codcont           = ?
           tt-linha.qtd[tt-sinte.seq] = tt-linha.qtd[tt-sinte.seq] +
                                        tt-sinte.qtd.
    vtotlig = vtotlig + tt-sinte.qtd.
end.    
for each tt-linha.
    do i = 1 to 18.
        tt-linha.qtd[19] = tt-linha.qtd[19] + tt-linha.qtd[i].
    end.
end.


/*******     colocar na abertura do relatorio    ******/

def var vtitulo as char format "x(40)".
vtitulo = "SINTETICO DE SITUACAO DE COBRANCA - PERIODO DE " +
            string(vdatlig) + " A " + string(vdtfin) .
            
varqsai = "../impress/funtel" + string(time).
{mdadmcab.i &saida     = "value(varqsai)"
            &page-size = "64"
            &cond-var  = "160"
            &page-line = "66"
            &nom-rel   = ""FUNTEL""
            &nom-sis   = """CREDIARIO"""
            &tit-rel   = " vtitulo "
            &width     = "160"
            &form      = "frame f-cab"}

put unformatted vtitulo skip.
put "Sit  . ".
for each tt by tt.seq.
    put tt.funcod format "zzzzzzz" space(1) .
    
end.    
put unformatted 
    skip
    fill("-",160) skip.
form with frame flin.     
for each tt-linha where tt-linha.codcont <> ?.
    disp tt-linha
         with no-label width 200 no-box frame flin.
    down with frame flin.         
    put unformatted 
        fill("-",160) skip.
end.    

for each tt-linha where tt-linha.codcont = ?.
    disp "Tot" @ tt-linha.codcont
         tt-linha.qtd
         with no-label width 200 no-box frame flin down.
    down with frame flin.          
    put unformatted 
        fill("-",160) skip.
    def var vlinha-qtd as char extent 19 format "xxxxxxx".
    display "" @ tt-linha.codcont
            string(tt-linha.qtd[01] / vtotlig * 100," zzz% |") @ vlinha-qtd[01]
            string(tt-linha.qtd[02] / vtotlig * 100," zzz% |") @ vlinha-qtd[02]
            string(tt-linha.qtd[03] / vtotlig * 100," zzz% |") @ vlinha-qtd[03]
            string(tt-linha.qtd[04] / vtotlig * 100," zzz% |") @ vlinha-qtd[04]
            string(tt-linha.qtd[05] / vtotlig * 100," zzz% |") @ vlinha-qtd[05]
            string(tt-linha.qtd[06] / vtotlig * 100," zzz% |") @ vlinha-qtd[06]
            string(tt-linha.qtd[07] / vtotlig * 100," zzz% |") @ vlinha-qtd[07]
            string(tt-linha.qtd[08] / vtotlig * 100," zzz% |") @ vlinha-qtd[08]
            string(tt-linha.qtd[09] / vtotlig * 100," zzz% |") @ vlinha-qtd[09]
            string(tt-linha.qtd[10] / vtotlig * 100," zzz% |") @ vlinha-qtd[10]
            string(tt-linha.qtd[11] / vtotlig * 100," zzz% |") @ vlinha-qtd[11]
            string(tt-linha.qtd[12] / vtotlig * 100," zzz% |") @ vlinha-qtd[12]
            string(tt-linha.qtd[13] / vtotlig * 100," zzz% |") @ vlinha-qtd[13]
            string(tt-linha.qtd[14] / vtotlig * 100," zzz% |") @ vlinha-qtd[14]
            string(tt-linha.qtd[15] / vtotlig * 100," zzz% |") @ vlinha-qtd[15]
            string(tt-linha.qtd[16] / vtotlig * 100," zzz% |") @ vlinha-qtd[16]
            string(tt-linha.qtd[17] / vtotlig * 100," zzz% |") @ vlinha-qtd[17]
            string(tt-linha.qtd[18] / vtotlig * 100," zzz% |") @ vlinha-qtd[18]
            string(tt-linha.qtd[19] / vtotlig * 100," zzz% |") @ vlinha-qtd[19]
            with frame flin1 down width 200 no-box no-label.
    down with frame flin1.            
            
end.    

vtitulo = "SINTETICO DE SITUACAO DE COBRANCA - PERIODO DE " +
            string(vdatlig) + " A " + string(vdtfin) + 
            " PERCENTUAL DA SITUACAO SOBRE AS LIGACOES ".
 
put unformatted skip(1) vtitulo skip(1).
page.
for each tt-linha where tt-linha.codcont <> ? by tt-linha.codcont.
    create tt-perc.
    assign tt-perc.codcont = tt-linha.codcont.
    find btt-linha where btt-linha.codcont = ?.
    do i = 1 to 19.
        tt-perc.perc[i] = tt-linha.qtd[i] / btt-linha.qtd[i] * 100.
    end.           
end.
for each tt-linha where tt-linha.codcont = ? by tt-linha.codcont.
    create tt-perc.
    assign tt-perc.codcont = tt-linha.codcont.
    find btt-linha where btt-linha.codcont = ?.
    do i = 1 to 19.
        tt-perc.perc[i] = tt-linha.qtd[i] / btt-linha.qtd[i] * 100.
    end.           
end.


/***/

 put "Sit  . ".
for each tt by tt.seq.
    put tt.funcod format "zzzzzzz" space(1) .
    
end.    
put unformatted 
    skip
    fill("-",160) skip.
form with frame glin.     
for each tt-perc.
    disp tt-perc
         with no-label width 200 no-box frame glin.
    down with frame glin.         
    put unformatted 
        fill("-",160) skip.
end.    

vtitulo = "SINTETICO DE SITUACAO DE COBRANCA - PERIODO DE " +
            string(vdatlig) + " A " + string(vdtfin) + 
 " PERCENTUAL DE CADA SITUACAO DO USUARIO SOBRE TOTAL DE TODOS ".
 
put unformatted skip(1) vtitulo skip(1).
page.
for each tt-perc.
    delete tt-perc.
end.    
for each tt-linha where tt-linha.codcont <> ? by tt-linha.codcont.
    create tt-perc.
    assign tt-perc.codcont = tt-linha.codcont.
    find btt-linha where btt-linha.codcont = ?.
    do i = 1 to 19.
        tt-perc.perc[i] = tt-linha.qtd[i] / tt-linha.qtd[19] * 100.
    end.           
end.
for each tt-linha where tt-linha.codcont = ? by tt-linha.codcont.
    create tt-perc.
    assign tt-perc.codcont = tt-linha.codcont.
    find btt-linha where btt-linha.codcont = ?.
    do i = 1 to 19.
        tt-perc.perc[i] = tt-linha.qtd[i] / tt-linha.qtd[19] * 100.
    end.           
end.
/***/

put "Sit  . ".
for each tt by tt.seq.
    put tt.funcod format "zzzzzzz" space(1) .
end.    
put unformatted 
    skip
    fill("-",160) skip.
form with frame hlin.     
for each tt-perc.
    disp tt-perc
         with no-label width 200 no-box frame hlin.
    down with frame hlin.         
    put unformatted 
        fill("-",160) skip.
end.    

/***/
vtitulo = "SINTETICO DE SITUACAO DE COBRANCA - PERIODO DE " +
            string(vdatlig) + " A " + string(vdtfin) + 
 " QUANTIDADE DE PAGAMENTOS EFETUADOS APOS CONTATO REALIZADO ".
put unformatted skip(1) vtitulo skip(1).
page.
for each tt-linha.
    delete tt-linha.
end.    
for each tt-sinte break by tt-sinte.codcont.
    find tt-linha where tt-linha.codcont = tt-sinte.codcont no-error.
    if not avail tt-linha
    then create tt-linha.
    assign tt-linha.codcont           = tt-sinte.codcont
           tt-linha.qtd[tt-sinte.seq] = tt-sinte.qtd-pag.
    find tt-linha where tt-linha.codcont = ? no-error.
    if not avail tt-linha
    then create tt-linha.
    assign tt-linha.codcont           = ?
           tt-linha.qtd[tt-sinte.seq] = tt-linha.qtd[tt-sinte.seq] +
                                        tt-sinte.qtd-pag.
    vqtdpag = vqtdpag + tt-sinte.qtd-pag.
end.    
for each tt-linha.
    do i = 1 to 18.
        tt-linha.qtd[19] = tt-linha.qtd[19] + tt-linha.qtd[i].
    end.
end.

 put "Sit  . ".
for each tt by tt.seq.
    put tt.funcod format "zzzzzzz" space(1) .
    
end.    
put unformatted 
    skip
    fill("-",160) skip.
form with frame wlin.     
for each tt-linha where tt-linha.codcont <> ?.
    disp tt-linha
         with no-label width 200 no-box frame wlin.
    down with frame wlin.         
    put unformatted 
        fill("-",160) skip.
end.    

for each tt-linha where tt-linha.codcont = ?.
    disp "Tot" @ tt-linha.codcont
         tt-linha.qtd
         with no-label width 200 no-box frame wlin down.
    down with frame wlin.          
    put unformatted 
        fill("-",160) skip.
    def var wlinha-qtd as char extent 19 format "xxxxxxx".
    display "" @ tt-linha.codcont
            string(tt-linha.qtd[01] / vqtdpag * 100," zzz% |") @ wlinha-qtd[01]
            string(tt-linha.qtd[02] / vqtdpag * 100," zzz% |") @ wlinha-qtd[02]
            string(tt-linha.qtd[03] / vqtdpag * 100," zzz% |") @ wlinha-qtd[03]
            string(tt-linha.qtd[04] / vqtdpag * 100," zzz% |") @ wlinha-qtd[04]
            string(tt-linha.qtd[05] / vqtdpag * 100," zzz% |") @ wlinha-qtd[05]
            string(tt-linha.qtd[06] / vqtdpag * 100," zzz% |") @ wlinha-qtd[06]
            string(tt-linha.qtd[07] / vqtdpag * 100," zzz% |") @ wlinha-qtd[07]
            string(tt-linha.qtd[08] / vqtdpag * 100," zzz% |") @ wlinha-qtd[08]
            string(tt-linha.qtd[09] / vqtdpag * 100," zzz% |") @ wlinha-qtd[09]
            string(tt-linha.qtd[10] / vqtdpag * 100," zzz% |") @ wlinha-qtd[10]
            string(tt-linha.qtd[11] / vqtdpag * 100," zzz% |") @ wlinha-qtd[11]
            string(tt-linha.qtd[12] / vqtdpag * 100," zzz% |") @ wlinha-qtd[12]
            string(tt-linha.qtd[13] / vqtdpag * 100," zzz% |") @ wlinha-qtd[13]
            string(tt-linha.qtd[14] / vqtdpag * 100," zzz% |") @ wlinha-qtd[14]
            string(tt-linha.qtd[15] / vqtdpag * 100," zzz% |") @ wlinha-qtd[15]
            string(tt-linha.qtd[16] / vqtdpag * 100," zzz% |") @ wlinha-qtd[16]
            string(tt-linha.qtd[17] / vqtdpag * 100," zzz% |") @ wlinha-qtd[17]
            string(tt-linha.qtd[18] / vqtdpag * 100," zzz% |") @ wlinha-qtd[18]
            string(tt-linha.qtd[19] / vqtdpag * 100," zzz% |") @ wlinha-qtd[19]
            with frame wlin1 down width 200 no-box no-label.
    down with frame wlin1.            
end.    



/***/
/***/
vtitulo = "SINTETICO DE SITUACAO DE COBRANCA - PERIODO DE " +
            string(vdatlig) + " A " + string(vdtfin) + 
 " VALOR DE PAGAMENTOS EFETUADOS APOS CONTATO REALIZADO ".
put unformatted skip(1) vtitulo skip(1).
page.
for each tt-linha.
    delete tt-linha.
end.    
for each tt-sinte break by tt-sinte.codcont.
    find tt-linha where tt-linha.codcont = tt-sinte.codcont no-error.
    if not avail tt-linha
    then create tt-linha.
    assign tt-linha.codcont           = tt-sinte.codcont
           tt-linha.qtd[tt-sinte.seq] = tt-sinte.val-pag.
    find tt-linha where tt-linha.codcont = ? no-error.
    if not avail tt-linha
    then create tt-linha.
    assign tt-linha.codcont           = ?
           tt-linha.qtd[tt-sinte.seq] = tt-linha.qtd[tt-sinte.seq] +
                                        tt-sinte.val-pag.
    vvalpag = vvalpag + tt-sinte.val-pag.
end.    
for each tt-linha.
    do i = 1 to 18.
        tt-linha.qtd[19] = tt-linha.qtd[19] + tt-linha.qtd[i].
    end.
end.

 put "Sit  . ".
for each tt by tt.seq.
    put tt.funcod format "zzzzzzz" space(1) .
    
end.    
put unformatted 
    skip
    fill("-",160) skip.
form with frame vlin.     
for each tt-linha where tt-linha.codcont <> ?.
    disp tt-linha
         with no-label width 200 no-box frame vlin.
    down with frame vlin.         
    put unformatted 
        fill("-",160) skip.
end.    

for each tt-linha where tt-linha.codcont = ?.
    disp "Tot" @ tt-linha.codcont
         tt-linha.qtd
         with no-label width 200 no-box frame vlin down.
    down with frame vlin.          
    put unformatted 
        fill("-",160) skip.
    def var v-linha-qtd as char extent 19 format "xxxxxxx".
    display "" @ tt-linha.codcont
            string(tt-linha.qtd[01] / vvalpag * 100," zzz% |") @ v-linha-qtd[01]
            string(tt-linha.qtd[02] / vvalpag * 100," zzz% |") @ v-linha-qtd[02]
            string(tt-linha.qtd[03] / vvalpag * 100," zzz% |") @ v-linha-qtd[03]
            string(tt-linha.qtd[04] / vvalpag * 100," zzz% |") @ v-linha-qtd[04]
            string(tt-linha.qtd[05] / vvalpag * 100," zzz% |") @ v-linha-qtd[05]
            string(tt-linha.qtd[06] / vvalpag * 100," zzz% |") @ v-linha-qtd[06]
            string(tt-linha.qtd[07] / vvalpag * 100," zzz% |") @ v-linha-qtd[07]
            string(tt-linha.qtd[08] / vvalpag * 100," zzz% |") @ v-linha-qtd[08]
            string(tt-linha.qtd[09] / vvalpag * 100," zzz% |") @ v-linha-qtd[09]
            string(tt-linha.qtd[10] / vvalpag * 100," zzz% |") @ v-linha-qtd[10]
            string(tt-linha.qtd[11] / vvalpag * 100," zzz% |") @ v-linha-qtd[11]
            string(tt-linha.qtd[12] / vvalpag * 100," zzz% |") @ v-linha-qtd[12]
            string(tt-linha.qtd[13] / vvalpag * 100," zzz% |") @ v-linha-qtd[13]
            string(tt-linha.qtd[14] / vvalpag * 100," zzz% |") @ v-linha-qtd[14]
            string(tt-linha.qtd[15] / vvalpag * 100," zzz% |") @ v-linha-qtd[15]
            string(tt-linha.qtd[16] / vvalpag * 100," zzz% |") @ v-linha-qtd[16]
            string(tt-linha.qtd[17] / vvalpag * 100," zzz% |") @ v-linha-qtd[17]
            string(tt-linha.qtd[18] / vvalpag * 100," zzz% |") @ v-linha-qtd[18]
            string(tt-linha.qtd[19] / vvalpag * 100," zzz% |") @ v-linha-qtd[19]
with frame vlin1 down width 200 no-box no-label.
    down with frame vlin1.            
end.    


/*******     colocar no final do relatorio    ******/

{mdadmrod.i
    &saida     = "value(varqsai)"
    &nomrel    = """FUNTEL"""
    &page-size = "64"
    &width     = "80"
    &traco     = "40"             /***     width - 31   ****/
    &form      = "frame f-rod"}


end procedure.




 


