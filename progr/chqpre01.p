{admcab.i}

def var vsenha as char format "x(10)".

update vsenha blank label "Senha"
       with frame f-senha centered side-labels. 
           
hide frame f-senha no-pause.

if vsenha <> "crm-drebes"
then leave.

def var vnota-util as int format ">>>>>>>9".
def temp-table tt-cartpre
    field seq    as int
    field numero as int
    field valor as dec.

def var vtitulo as char.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial [" Alteracao "," Procura "," Consulta "," Cancela ",""].
def var esqcom2         as char format "x(17)" extent 5
            initial [" Geracao de CP ","Cancela Vencidos ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" ",
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


def buffer btitulo       for titulo.
def var vtitnum         like titulo.titnum.


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
        run leitura (input "pri").
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

    recatu1 = recid(titulo).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
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
        
        hide frame f-procura no-pause.
        
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
            run color-message.
            choose field titulo.titnum help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
            run color-normal.
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
                    if not avail titulo
                    then leave.
                    recatu1 = recid(titulo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail titulo
                    then leave.
                    recatu1 = recid(titulo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail titulo
                then next.
                color display white/red titulo.titnum with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail titulo
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
            form
                 with frame f-titulo overlay
                      centered side-label row 7 title vtitulo.
            
            /*hide frame frame-a no-pause.*/
            
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Procura "
                then do:  pause 0.
                    view frame f-procura. pause 0.
                    
                    update vtitnum label "Numero Cartao Presente"
                           with frame f-procura side-labels 
                               overlay 1 col centered row 7 title " Procura ".

                    find first btitulo  where btitulo.empcod = 19
                                         and btitulo.titnat = yes
                                         and btitulo.modcod = "CHP"
                                         and btitulo.etbcod = 999
                                         and btitulo.clifor = 110165
                                         and btitulo.titnum = vtitnum
                                         no-lock no-error.
                    
                    if avail titulo
                    then recatu1 = recid(btitulo).
                    else recatu1 = ?.
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta "
                then
                    vtitulo = " Consulta ".
                    

                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Cancela " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-titulo.
                    pause 0.

                    vnota-util = 0.
                    
                    
                    run p-venota-ant ( input  int(titulo.titnum),  
                                       input  titulo.etbcobra,  
                                       input  titulo.titdtpag,  
                                       output vnota-util ).
                    
                    
                    if vnota-util = 0 or vnota-util = ?
                    then run p-venota-new ( input  int(titulo.titnum), 
                                            input  titulo.etbcobra,
                                            input  titulo.titdtpag,
                                            output vnota-util ).

                    
                    display titulo.titnum   label "Cartao Presente No..."
                       skip titulo.titvlcob label "Valor do CP.........."
                       /*skip titulo.titdtdes label "Data Geracao do CP..."*/
                       skip titulo.titdtven label "Data de Venda do CP.."
                       skip titulo.titdtpag label "Data Utilizacao do CP"
                       skip titulo.titvlpag label "Valor Utilizado......"
                       skip titulo.etbcobra label "Utilizado na Filial.."
                       skip vnota-util      label "Utilizado na Nota...."
                       skip titulo.titsit   label "Situacao.............".
                end.
                
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-titulo on error undo.
                    vtitulo = " Alteracao ".
                    find titulo where
                            recid(titulo) = recatu1 
                        exclusive.

                    update  titulo.titvlcob label "Valor do CP.........."
                            /*titulo.titdtdes label "Data Geracao do CP..."*/
                            titulo.titdtven label "Data de Venda do CP.."
                            titulo.titdtpag label "Data Utilizacao do CP"
                            titulo.titvlpag label "Valor Utilizado......"
                            titulo.etbcobra label "Utilizado na Filial.."
                            titulo.titsit   label "Situacao............."
                            with no-validate.
                    
                    
                end.
                if esqcom1[esqpos1] = " Cancela "
                then do with frame f-titulo on error undo.

                    message "Confirma o cancelamento do CP numero "
                            titulo.titnum update sresp.
                    if not sresp
                    then undo, leave.
                    
                    find titulo where recid(titulo) = recatu1 exclusive.
                    
                    assign titulo.titsit = "EXC".
                    
                    find titulo where recid(titulo) = recatu1 no-lock no-error.
                                        
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
                    then run ltitulo.p (input 0).
                    else run ltitulo.p (input titulo.titnum).
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                        
                if esqcom2[esqpos2] = " Geracao de CP " or esqvazio
                then do:
                    pause 0.
                    run p-gera-cp.
                
                end.
      
                if esqcom2[esqpos2] = "Cancela Vencidos"
                then do with frame f-titulo on error undo.

                    run mensagem.p(input-output sresp,
               input "!Confirma o cancelamento de todos os Cartões Presentes " +
                     "emitidos a mais de 120 dias e não utilizados? ",
               input " Cancelamento de Cartao Presente ",
               input "   SIM",
               input "   NAO").

                    if not sresp
                    then undo, leave.
                   
                    for each titulo where titulo.empcod = 19
                            and titulo.titnat = yes
                            and titulo.modcod = "CHP"
                            and titulo.etbcod = 999
                            and titulo.titdtven < today - 120
                            and titulo.clifor = 110165 
                            and titulo.titsit = "LIB":
            
                        disp "Cancelando.... "
                             titulo.titnum   label "Numero"
                             titulo.titdtemi
                             titulo.cxmdata
                             with frame f-can
                             1 down centered row 10 no-box color message
                             overlay.
                        pause 0.     
                        titulo.titsit = "EXC".
                        titulo.cxmdata = today.
                        titulo.cxmhora = string(time).
                    
                    end.
                                        
                    leave.
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
        recatu1 = recid(titulo).
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
    display titulo.titnum   column-label "Cartao!Presente"
            titulo.modcod   column-label "Mod"
            titulo.titvlcob column-label "Valor"
            /*titulo.titdtdes column-label "Data!Geracao"*/
            titulo.titdtven column-label "Dt.Venda do!C.Presente"
            titulo.titdtpag column-label "Data!Utilizacao"
            titulo.titsit   column-label "Sit"
            
            with frame frame-a 10 down centered color white/red row 5.
end procedure.
procedure color-message.
    color display message
            titulo.titnum
            with frame frame-a.
end procedure.
procedure color-normal.
    color display normal
            titulo.titnum
            with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first titulo where titulo.empcod = 19
                            and titulo.titnat = yes
                            and titulo.modcod = "CHP"
                            and titulo.etbcod = 999
                            and titulo.clifor = 110165 no-lock no-error.
    else  
        find last titulo  where titulo.empcod = 19
                            and titulo.titnat = yes
                            and titulo.modcod = "CHP"
                            and titulo.etbcod = 999
                            and titulo.clifor = 110165  no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next titulo  where titulo.empcod = 19
                            and titulo.titnat = yes
                            and titulo.modcod = "CHP"
                            and titulo.etbcod = 999
                            and titulo.clifor = 110165  no-lock no-error.
    else  
        find prev titulo   where titulo.empcod = 19
                            and titulo.titnat = yes
                            and titulo.modcod = "CHP"
                            and titulo.etbcod = 999
                            and titulo.clifor = 110165  no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev titulo where titulo.empcod = 19
                            and titulo.titnat = yes
                            and titulo.modcod = "CHP"
                            and titulo.etbcod = 999
                            and titulo.clifor = 110165  no-lock no-error.
    else   
        find next titulo where titulo.empcod = 19
                            and titulo.titnat = yes
                            and titulo.modcod = "CHP"
                            and titulo.etbcod = 999
                            and titulo.clifor = 110165  no-lock no-error. 
end procedure.
         

procedure p-gera-cp:
    /*
    def var vnumchq as char.
    def var vqtdgera as int.
    def var vconf as log init no.
    def var vqtd as int.
    def var vqtdi as int.
    def var vqtdf as int.
    
    find last btitulo  where btitulo.empcod = 19 
                         and btitulo.titnat = yes 
                         and btitulo.modcod = "CHP" 
                         and btitulo.etbcod = 999 
                         and btitulo.clifor = 110165  no-lock no-error.
    if avail btitulo
    then vnumchq = btitulo.titnum.
    
    vtitulo = " Geracao de CP ".
    disp skip(1) 
         space(3) vnumchq    label "Ultimo CP Gerado." format "x(10)"
         skip(1)
         with frame f-gera overlay centered side-label row 7 title vtitulo.

    update skip
           space(3) vqtdgera label "Qtd de CP a gerar" format ">>>>>9"
           skip(1)
           with frame f-gera.
           
    vqtdi = (int(vnumchq) + 1).
    vqtdf = (int(vnumchq) + vqtdgera).
    
    disp space(3) vqtdi   label "CP Inicial" skip
         space(3) vqtdf   label "CP Final"
         skip(1)
         with frame f-gera.
         
    update space(3) vconf format "Sim/Nao" label "Confirma a Geracao"
           skip(1)
           with frame f-gera.

    if vconf
    then do:

        do vqtd = vqtdi to vqtdf:
        
            create titulo.
            assign titulo.empcod = 19 
                   titulo.titnat = yes 
                   titulo.modcod = "CHP" 
                   titulo.etbcod = 999 
                   titulo.clifor = 110165
                   titulo.titnum = string(vqtd)
                   titulo.titpar = 1 
                   titulo.titsit = "LIB" 
                   titulo.titvlcob = 0 
                   titulo.titdtven = ? 
                   titulo.titdtdes = today
                   titulo.titdtemi = today. 
        end.
        
        message "Os Cartoes Presentes foram gerados com Sucesso.".
        pause 2 no-message.
    end.
    */
    message "Em manutencao...". pause.
end procedure.

procedure p-venota-new:

    def input  parameter p-numerocart as int.
    def input  parameter p-etbcobra   as int.
    def input  parameter p-data       as date format "99/99/9999".
    def output parameter p-nota-util  like plani.numero.
    
    def var vqtdcart       as int.
    def var vconta         as int.
    def var vachatextonum  as char.
    def var vachatextoval  as char.
    def var vvalor-cartpre as dec.
    def var vlcartpres     as dec.

    for each tt-cartpre. delete tt-cartpre. end.

    assign vqtdcart = 0 
           vconta   = 0 
           vachatextonum = "" 
           vachatextoval = "" 
           vvalor-cartpre = 0. 
           
    for each plani where plani.movtdc = 5
                     and plani.etbcod = p-etbcobra
                     and plani.pladat = p-data no-lock:
                     
        if plani.notobs[3] <> "" 
        then do: 
            if acha("QTDCHQUTILIZADO",plani.notobs[3]) <> ?  
            then vqtdcart = int(acha("QTDCHQUTILIZADO",plani.notobs[3])).
                    
            if vqtdcart > 0  
            then do:  
                do vconta = 1 to vqtdcart:   
                    vachatextonum = "".  
                    vachatextonum = "NUMCHQPRESENTEUTILIZACAO"  
                                  + string(vconta).
        
                    vachatextoval = "".  
                    vachatextoval = "VALCHQPRESENTEUTILIZACAO"  
                                  + string(vconta).

                    if acha(vachatextonum,plani.notobs[3]) <> ? and
                       acha(vachatextoval,plani.notobs[3]) <> ? 
                    then do:  
                        if int(acha(vachatextonum,plani.notobs[3])) =
                           p-numerocart
                        then assign
                             p-nota-util = plani.numero.
                    end.
                end. 
            end.
        end.
    end.
end procedure.

procedure p-venota-ant:

    def input  parameter p-numerocart as int.
    def input  parameter p-etbcobra   as int.
    def input  parameter p-data       as date format "99/99/9999".
    def output parameter p-nota-util  like plani.numero.
    
    def var vqtdcart       as int.
    def var vconta         as int.
    def var vachatextonum  as char.
    def var vachatextoval  as char.
    def var vvalor-cartpre as dec.
    def var vlcartpres     as dec.

    for each tt-cartpre. delete tt-cartpre. end.

    assign vqtdcart = 0 
           vconta   = 0 
           vachatextonum = "" 
           vachatextoval = "" 
           vvalor-cartpre = 0. 
           
    for each plani where plani.movtdc = 5
                     and plani.etbcod = p-etbcobra
                     and plani.pladat = p-data no-lock:
                     
        if plani.notobs[3] <> "" 
        then do:  
            vachatextonum = "".   
            vachatextonum = "NUMCHQPRESENTEUTILIZACAO".
        
            if acha(vachatextonum,plani.notobs[3]) <> ?
            then do:   
                if int(acha(vachatextonum,plani.notobs[3])) = p-numerocart
                then assign 
                        p-nota-util = plani.numero.
            end.
        end.
    end.
end procedure.

