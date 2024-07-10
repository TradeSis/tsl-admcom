/*  zresutel.p  */  
{admcab.i}
    def input  parameter p-clicod like clien.clicod.
    def output parameter p-fone   as   char.      
  
def var vdepen as char format "x(30)".
/*def var p-fone as char.*/
def buffer bclien for clien.

def temp-table tt-fone
    field fone    as char
    field tipo    as char
    field relacao as char
    field ordem   as int
    index ordem ordem asc.

def var v-titulo as char.

find clien where clien.clicod = p-clicod no-lock no-error.
/*find clicpl where clicpl.clicod = clien.clicod no-lock no-error.*/

v-titulo = "Resumo de Telefones - "
         + string(clien.clicod)
         + " "
         + clien.clinom.

create tt-fone.
assign tt-fone.fone = "T E L E F O N E S"
       tt-fone.tipo = "P E S S O A I S"
       tt-fone.relacao = ""
       tt-fone.ordem = 1.
create tt-fone.
assign tt-fone.fone = "TELEFONE"
       tt-fone.tipo = "LOCAL"
       tt-fone.relacao = "NOME"
       tt-fone.ordem = 2.
create tt-fone.
assign tt-fone.fone = ""
       tt-fone.tipo = ""
       tt-fone.relacao = ""
       tt-fone.ordem = 41.
create tt-fone.
assign tt-fone.fone = "R E F E R E N C I A S"
       tt-fone.tipo = "P E S S O A I S"
       tt-fone.relacao = ""
       tt-fone.ordem = 42.

create tt-fone.
assign tt-fone.fone = "TELEFONE"
       tt-fone.tipo = "RELACIONAMENTO"
       tt-fone.relacao = "NOME"
       tt-fone.ordem = 43.

CREATE tt-fone.
ASSIGN tt-fone.fone    = (IF AVAIL clien
                          THEN clien.fone
                          ELSE "") 
       tt-fone.tipo    = "RESIDENCIAL"
       tt-fone.relacao = ""
       tt-fone.ordem  = 10.

CREATE tt-fone.
ASSIGN tt-fone.fone    = (IF AVAIL clien
                          THEN clien.fax
                          ELSE "") 
       tt-fone.tipo    = "CELULAR"
       tt-fone.relacao = ""
       tt-fone.ordem  = 20.



CREATE tt-fone.
ASSIGN tt-fone.fone    = (IF AVAIL clien
                          THEN clien.protel[1]
                          ELSE "") 
       tt-fone.tipo    = "COMERCIAL"
       tt-fone.relacao = ""
       tt-fone.ordem   = 30.

CREATE tt-fone.
ASSIGN tt-fone.fone    = (IF AVAIL clien
                          THEN clien.protel[2]
                          ELSE "")
       tt-fone.tipo    = "EMPRESA"
       tt-fone.relacao = ""
       tt-fone.ordem   = 40.

CREATE tt-fone. 
ASSIGN tt-fone.fone    = if clien.entcep[1] <> ""
                         then clien.entcep[1]
                         else clien.entcidade[1]
       tt-fone.relacao = clien.entbairro[1]
       tt-fone.tipo    = clien.entcompl[1]
       tt-fone.ordem   = 50.

CREATE tt-fone. 
ASSIGN tt-fone.fone    = if clien.entcep[2] <> ""
                         then clien.entcep[2]
                         else clien.entcidade[2]
       tt-fone.relacao = clien.entbairro[2]
       tt-fone.tipo    = clien.entcompl[2]
       tt-fone.ordem   = 60.

CREATE tt-fone. 
ASSIGN tt-fone.fone    = if clien.entcep[3] <> ""
                         then clien.entcep[3]
                         else clien.entcidade[3]
       tt-fone.relacao = clien.entbairro[3]
       tt-fone.tipo    = clien.entcompl[3]
       tt-fone.ordem   = 60.
       
/***
create tt-fone.
assign tt-fone.fone = ""
       tt-fone.tipo = ""
       tt-fone.relacao = ""
       tt-fone.ordem = 61.

create tt-fone.
assign tt-fone.fone    = "F O N E"
       tt-fone.tipo    = "C O N T R A T O S"
       tt-fone.relacao = "D A T A   "
       tt-fone.ordem   = 62.
 
def var x as int.
def var contat as int.
x = 70.
contat = 0.
for each u_telcont where u_telcont.clicod = clien.clicod
    no-lock
    break by u_telcont.dtinclu descending
          by u_telcont.hrinclu descending.
    contat = contat +   1.
    if contat > 7
    then leave.
    find first titulo where titulo.titnat = no and
                            titulo.clicod = clien.clicod and
                            titulo.titdtemi = u_telcont.dtinclu 
                            no-lock no-error.
    vdepen = clien.clfnom.
    if avail titulo
    then do.
        for each depen of clien where depen.depseq = titulo.depseq no-lock.
            vdepen = depen.nome .
        end.
    end.
    CREATE tt-fone.
    ASSIGN tt-fone.fone    = u_telcont.fone
           tt-fone.relacao = string(u_telcont.dtinclu,"99/99/9999") + " " +
                             vdepen
           tt-fone.tipo    = if avail titulo
                             then titulo.titnum
                             else ""
                            /*"COMPRA EM " +
                            string(u_telcont.dtinclu,"99/99/9999")*/
           tt-fone.ordem   = x.
    x = x + 10.
end.
***/
            /*
for each tt-fone  where tt-fone.fone = "".
    delete tt-fone.  
end.          */


def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.

/*def var esqcom1         as char format "x(12)" extent 1
    initial [" Selecionar "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].*/


def buffer btt-fone       for tt-fone.
def var vtt-fone         like tt-fone.fone.

/*form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.                                             */
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

run mostra-contratos.

bl-princ:
repeat:

/*  disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.*/
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-fone where recid(tt-fone) = recatu1 no-lock.
    if not available tt-fone
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-fone).
/*  if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.*/
    
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-fone
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
            find tt-fone where recid(tt-fone) = recatu1 no-lock.

            choose field tt-fone.fone
                         tt-fone.tipo 
                         tt-fone.relacao
                         help "" go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).

            status default "".

        end.
/*            if keyfunction(lastkey) = "cursor-right"
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
*/            
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-fone
                    then leave.
                    recatu1 = recid(tt-fone).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-fone
                    then leave.
                    recatu1 = recid(tt-fone).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-fone
                then next.
                color display white/red
                              tt-fone.fone
                              tt-fone.tipo
                              tt-fone.relacao
                              with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-fone
                then next.
                color display white/red
                              tt-fone.fone
                              tt-fone.tipo
                              tt-fone.relacao
                              with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            if tt-fone.ordem = 10 or
               tt-fone.ordem = 20 or
               tt-fone.ordem = 30 or
               tt-fone.ordem = 40 or
               tt-fone.ordem = 50 or
               tt-fone.ordem = 60 or
               tt-fone.ordem = 70 or
               tt-fone.ordem = 80 or
               tt-fone.ordem = 90 or
               tt-fone.ordem = 100 or
               tt-fone.ordem = 110
            then do: 
                p-fone = tt-fone.fone.
                sretorno = tt-fone.fone.
                leave bl-princ.
            end.
            
            
            form tt-fone
                 with frame f-tt-fone color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
/*                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-tt-fone on error undo.
                    create tt-fone.
                    update tt-fone.
                    recatu1 = recid(tt-fone).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-fone.
                    disp tt-fone.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-fone on error undo.
                    find tt-fone where
                            recid(tt-fone) = recatu1 
                        exclusive.
                    update tt-fone.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" tt-fone.fone
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next tt-fone where true no-error.
                    if not available tt-fone
                    then do:
                        find tt-fone where recid(tt-fone) = recatu1.
                        find prev tt-fone where true no-error.
                    end.
                    recatu2 = if available tt-fone
                              then recid(tt-fone)
                              else ?.
                    find tt-fone where recid(tt-fone) = recatu1
                            exclusive.
                    delete tt-fone.
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
                    then run ltt-fone.p (input 0).
                    else run ltt-fone.p (input tt-fone.fone).
                    leave.
                end.*/
            end.
            else do:
/*                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
                end.*/
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
/*        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.*/
        recatu1 = recid(tt-fone).
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

    display tt-fone.fone     format "x(22)" column-label "Fone"
            tt-fone.tipo     format "x(20)" column-label "Tipo / Local"
            tt-fone.relacao  format "x(33)" column-label "Relacionamento"
            with frame frame-a 18 down color white/red row 3
                    overlay  width 80
                title v-titulo no-labels.
                
end procedure.



procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-fone where true
                                                no-lock no-error.
    else  
        find last tt-fone  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-fone  where true
                                                no-lock no-error.
    else  
        find prev tt-fone   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-fone where true  
                                        no-lock no-error.
    else   
        find next tt-fone where true 
                                        no-lock no-error.
        
end procedure.


procedure mostra-contratos:
    def var cont as int.
    def var vordem as int.
    vordem = 60.
        
    /*
    for each titulo where titulo.titnat = no
                      and titulo.clicod = clien.clicod no-lock
                      break by titdtemi desc by titulo.titnum:

        if cont >= 5
        then leave.

        if first-of(titulo.titnum)
        then do:

            cont = cont + 1.
            vordem = vordem + 10.
            
            find bclien where bclien.clicod = titulo.titdep no-lock no-error.
            find plani where plani.etbcod = titulo.etbcod
                         and plani.placod = titulo.placod no-lock no-error.
                         
            create tt-fone.
            assign tt-fone.fone    = string(plani.hiccod,"(999)999-9999-9999")
                                     when avail plani
                   tt-fone.tipo    = titulo.titnum
                   tt-fone.relacao = string(plani.pladat)
                                     when avail plani
                   tt-fone.ordem   = vordem.

            if avail bclien
            then do:
                if tt-fone.relacao <> ""
                then 
                    tt-fone.relacao = tt-fone.relacao + "   " + bclien.clfnom.
                else
                    tt-fone.relacao = tt-fone.relacao + "           "
                                    + bclien.clfnom.
            end.
            
            

/*            disp string(plani.hiccod) format "(999)999-9999-9999"
                                      column-label "Telefone" when avail plani
                 titulo.titnum        column-label "Numero"
                 bclien.clfnom       column-label "Nome" format "x(21)"
                                      when avail bclien
                 plani.pladat         column-label "Data" when avail plani
                 with frame frame-b 5 down centered 
                                     color white/red row 14 title " Contratos ".
  */                                                                            
        end.                    
   end.
   */
end procedure.

