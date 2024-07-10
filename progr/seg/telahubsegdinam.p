{admcab.i}                                                   
def output param pseguevenda as log.
pseguevenda = no.
{seg/defhubperfildin.i}
def buffer bttcampos for ttcampos.
                    DEF VAR hObj AS HANDLE.

def buffer tipo-ttatributos for ttatributos.
def buffer obri-ttatributos for ttatributos.
def buffer min-ttatributos for ttatributos.
def buffer max-ttatributos for ttatributos.

def buffer vlrmin-ttatributos for ttatributos.
def buffer vlrmax-ttatributos for ttatributos.

def var vtem as log.

def var aux-format as char.
def var aux-texto as char.
def var vdata as date. 
def var vinteirodata as dec. 
def var vtexto as char.

def var vlabel as char.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Digita"," ","  ","  ",""].
def var esqcom2         as char format "x(12)" extent 5.

def var esqhel1         as char format "x(80)" extent 5
    initial [" Enter para digitar ",
             " Dados completos, Pode seguir com a venda","",
             " "].
def var esqhel2         as char format "x(12)" extent 5.


form
    esqcom1
    with frame f-com1
                 row 7 no-box no-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels column 1 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

find first ttsegprodu where ttsegprodu.procod = pprocod no-lock.
find first ttseguro   where ttseguro.id       = ttsegprodu.idseguro. 
find first ttperfil where ttperfil.id = ttseguro.PerfilTitularId no-error.

/*
find first ttcampos where ttcampos.codigo =  "contratante.dadosPessoais.cpf" no-error.
if avail ttcampos then vcpf = dec(ttcampos.conteudo).
find first ttcampos where ttcampos.codigo =  "contratante.dadosPessoais.nome" no-error.
if avail ttcampos then vnome = ttcampos.conteudo.

disp vcpf format "99999999999" label "CPF" colon 15
     vnome no-label
    with frame fcab row 4 no-box color messages side-labels
    width 80.
*/

 
def var vobri as log format "*/ " column-label "*".
    form vobri
            ttcampos.nome      format "x(25)" column-label "Campo"
         ttcampos.Conteudo  format "x(50)" column-label "Conteudo"
            with frame frame-a 10 down centered row 9 no-box
            no-labels. 

    /*form vdata format "99/99/9999" no-label
                        with frame fdata
                            centered row vrow overlay. */
FORM
    skip(1)
  space(10) vlabel format "x(35)" no-label skip
  skip(1)
  SPACE(10) vdata format "99/99/9999" no-label SPACE(6) 
  SKIP(1)
  WITH FRAME fdata OVERLAY NO-LABELS ATTR-SPACE
  WIDTH 40 CENTERED ROW 9
  COLOR messages .
FORM
    skip(1)
  space(10) vlabel format "x(35)" no-label skip
  skip(1)
  SPACE(10) vinteirodata no-label SPACE(6) 
  SKIP(1)
  WITH FRAME finteirodata OVERLAY NO-LABELS ATTR-SPACE
  WIDTH 40 CENTERED ROW 9
  COLOR messages .
FORM
    skip(1)
  space(10) vlabel format "x(35)" no-label skip
  skip(1)
  SPACE(1) vtexto no-label SPACE(1) 
  SKIP(1)
  WITH FRAME ftextodata OVERLAY NO-LABELS ATTR-SPACE
  WIDTH 80 CENTERED ROW 9
  COLOR messages .
  
  



bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttcampos where recid(ttcampos) = recatu1 no-lock.

    if not available ttcampos
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(ttcampos).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available ttcampos
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
            find ttcampos where recid(ttcampos) = recatu1 no-lock.
                if ttcampos.codigo =  "contratante.dadosPessoais.cpf" or
                   ttcampos.codigo =  "vendedor.id" or
                   ttcampos.codigo =  "vendedor.nome" or
                   ttcampos.codigo =  "origemComercial.id" or
                   ttcampos.codigo =  "origemComercial.nome" 
                then do:
                    esqcom1[1] = "".
                end.    
                else esqcom1[1] = " Digita".
            
            find first tipo-ttatributos where tipo-ttatributos.idpai = ttcampos.id and
                                              tipo-ttatributos.propriedade = "TIPO".
            find first min-ttatributos where min-ttatributos.idpai = ttcampos.id and
                                             min-ttatributos.propriedade = "MINIMO"
                                             no-error.
            find first max-ttatributos where max-ttatributos.idpai = ttcampos.id and
                                             max-ttatributos.propriedade = "MAXIMO"
                                             no-error.
            find first vlrmin-ttatributos where vlrmin-ttatributos.idpai = ttcampos.id and
                                             vlrmin-ttatributos.propriedade = "VALOR_MINIMO"
                                             no-error.
            find first vlrmax-ttatributos where vlrmax-ttatributos.idpai = ttcampos.id and
                                             vlrmax-ttatributos.propriedade = "VALOR_MAXIMO"
                                             no-error.
                                             
            sresp = yes.
            
            vtem = no.
            for each bttcampos where bttcampos.conteudo = ? or bttcampos.conteudo = "".
                find first obri-ttatributos where obri-ttatributos.idpai = bttcampos.id and
                                                  obri-ttatributos.propriedade = "OBRIGATORIEDADE" and
                                                  obri-ttatributos.valor = "true"
                                                  no-error.
                if avail obri-ttatributos
                then vtem = yes.
            end. 
            esqcom1[2] = " Segue Venda".     
            if vtem
            then do:
                esqcom1[2] = "".
            end.
                                                
                /*                                
  for each ttopcoes where ttopcoes.idpai = ttcampos.id.
        disp ttopcoes
            with row 12 4 down.
    end.          
                  */
            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 = 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(ttcampos.nome)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(ttcampos.nome)
                                        else "".
            run color-message.
            
                
                disp esqcom1 with frame f-com1.
                choose field
                    ttcampos.conteudo
                        help ""
                    go-on(cursor-down cursor-up
                          cursor-left cursor-right
                          page-down   page-up
                          tab PF4 F4 ESC return) /*color white/black*/ .

                         
            run color-normal.
            status default "".
            hide message no-pause.
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
                    if not avail ttcampos
                    then leave.
                    recatu1 = recid(ttcampos).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttcampos
                    then leave.
                    recatu1 = recid(ttcampos).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down" 
            then do:
                run leitura (input "down").
                if not avail ttcampos
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttcampos
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then do:
            sresp = yes.
            vtem = no.
            for each ttcampos where ttcampos.conteudo = ? or ttcampos.conteudo = "".
                find first obri-ttatributos where obri-ttatributos.idpai = ttcampos.id and
                                                  obri-ttatributos.propriedade = "OBRIGATORIEDADE" and
                                                  obri-ttatributos.valor = "true"
                                                  no-error.
                if avail obri-ttatributos
                then vtem = yes.
            end.      
            if vtem
            then do:
                sresp = no.
                run seg/telamensagem.p (INPUT-OUTPUT sresp,
                                   input "Existem campos OBRIGATORIOS nao preenchidos!" + 
                                            chr(10) + chr(10) + "Deseja sair?" ,
                                   input "",
                                   input "Sair",
                                   input "Ajustar").  
                if sresp
                then do:
                    recatu1 = ?.
                end.
            end.
                  
            if sresp
            then leave bl-princ.
            else next.
        end.    

        if keyfunction(lastkey) = "return" or esqvazio
        then do:    
            if esqcom1[esqpos1] = " Segue Venda"
            then do:
                pseguevenda = yes.  
                leave bl-princ.
            end.                         
            if esqcom1[esqpos1] = " Digita"
            then do:
                
                find first ttopcoes where ttopcoes.idpai = ttcampos.id no-error.
                if avail ttopcoes
                then do:
                    run seg/telahubopcoes.p (ttcampos.id, 
                                                input ttcampos.nome,
                                                output ttcampos.conteudo).
                    run frame-a.
                    next.
                end.    

                
                if tipo-ttatributos.valor = "NUMERICO" or
                   tipo-ttatributos.valor = "INTEIRO"
                then do:
                    

                    vinteirodata = dec(ttcampos.conteudo).
                    /*vrow = frame-line + 2.*/
                    vlabel = ttcampos.nome.
                    pause 0.
                    disp vlabel 
                            vinteirodata
                            with frame finteirodata.
                    hObj = vinteirodata:HANDLE.
                    hObj:format = fill("9",if avail max-ttatributos then int(max-ttatributos.valor) else 
                                    if avail vlrmax-ttatributos then length(vlrmax-ttatributos.valor) else 16).
                             
                    update vinteirodata 
                        with frame finteirodata.
                
                    ttcampos.conteudo = string(vinteirodata).
                    if avail vlrmin-ttatributos or avail vlrmax-ttatributos
                    then do:
                        if avail vlrmin-ttatributos
                        then do:
                            if dec(ttcampos.conteudo) < int(vlrmin-ttatributos.valor)
                            then do:
                                message "Valor MENOR que o minimo Permitido"
                                    view-as alert-box.
                                undo.
                            end.
                        end.
                        if avail vlrmax-ttatributos
                        then do:
                            if dec(ttcampos.conteudo) > int(vlrmax-ttatributos.valor)
                            then do:
                                message "Valor MAIOR que o maximo Permitido"
                                    view-as alert-box.
                                undo.
                            end.
                        end.
                        
                    end.
                    /*
                    if ttcampos.codigo =  "contratante.dadosPessoais.cpf" 
                    then do:
                        run cpf.p (ttcampos.conteudo, output sresp).
                        if not sresp
                        then do:
                            message "CPF INVALIDO"
                                    view-as alert-box.
                            undo.
                        end.
                        pcpf = dec(ttcampos.conteudo).
                    end.    
                    */
                    
                    /*
                    if ttcampos.codigo =  "contratante.dadosPessoais.nome" 
                    then vnome = ttcampos.conteudo.
                    */
                    /*
                    disp vcpf format "99999999999" label "CPF" colon 15
                         vnome no-label
                        with frame fcab row 4 no-box color messages side-labels
                            width 80.
                    */
                    
                end.
                
                if tipo-ttatributos.valor = "TEXTO" 
                then do on error undo, retry on endkey undo, retry:
                    if retry and keyfunction(lastkey) = "END-ERROR"
                    then do:
                        ttcampos.conteudo = aux-texto.
                        leave.
                    end.    
                    if not retry then do:
                        vtexto    = ttcampos.conteudo.
                        aux-texto = ttcampos.conteudo.
                    end.    
                     
                    /*vrow = frame-line + 2.*/
                    vlabel = ttcampos.nome.
                    pause 0.
                    if avail max-ttatributos  and int(max-ttatributos.valor) > 50
                    then do:
                        disp vlabel 
                            vtexto
                            with frame ftextodata.
                        hObj = vtexto:HANDLE.
                        hObj:format = "x(" + ( if avail max-ttatributos then trim(
                                                                if int(max-ttatributos.valor) > 76 then "76" else max-ttatributos.valor)
                                                                        else "76" ) + ")".
                             
                        update vtexto with frame ftextodata .
                        ttcampos.conteudo = string(caps(vtexto)).
                        vtexto = "".
                    end.
                    else do:
                        hObj = ttcampos.conteudo:HANDLE.
                        aux-format = hObj:format.
                        hObj:format = "x(" + ( if avail max-ttatributos then trim(
                                                                if int(max-ttatributos.valor) > 50 then "50" else max-ttatributos.valor)
                                                                        else "50" ) + ")".
                             
                        update ttcampos.conteudo
                            with frame frame-a /*ftextodata*/ .
                        ttcampos.conteudo = caps(ttcampos.conteudo).    
                        hObj:format = aux-format.
                    end.

                    if avail min-ttatributos
                    then do:
                        if length(ttcampos.conteudo) < int(min-ttatributos.valor)
                        then do:
                            message "Conteudo MENOR que o minumo Permitido"
                                view-as alert-box.
                            undo.
                        end.
                    end.
                    
                    /*if ttcampos.codigo =  "contratante.dadosPessoais.cpf" 
                    then vcpf = dec(ttcampos.conteudo).
                    if ttcampos.codigo =  "contratante.dadosPessoais.nome" 
                    then vnome = ttcampos.conteudo.
                    disp vcpf format "99999999999" label "CPF" colon 15
                         vnome no-label
                        with frame fcab row 4 no-box color messages side-labels
                            width 80.

                    */
                    
                                        
                end.
                
                if tipo-ttatributos.valor = "DATA" 
                then do:
                    /*vrow = frame-line + 2.*/
                    vdata = date(int(entry(2,ttcampos.conteudo,"-")) , 
                                 int(entry(3,ttcampos.conteudo,"-")) ,
                                 int(entry(1,ttcampos.conteudo,"-")))
                                    no-error.
                    vlabel = ttcampos.nome.
                    pause 0.
                    disp vlabel with frame fdata.
                    update vdata 
                        with frame fdata.
                
                    ttcampos.conteudo =  string(year(vdata),"9999") + "-" +
                                  string(month(vdata),"99") + "-" +
                                  string(day(vdata),"99").
                end.
            
                    run frame-a.
                    run leitura (input "down").
                    if not avail ttcampos
                    then next.
                    if frame-line(frame-a) = frame-down(frame-a)
                    then scroll with frame frame-a.
                    else down with frame frame-a.
            
            
            end.
            
            

        end.
        /*            
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = "Montadores" 
                then do with frame f-cons-mont.
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    hide frame frame-a no-pause.
                    
                    run cons-mont.p.
                    
                    view frame f-com1. pause 0.
                    view frame f-com2. pause 0.
                    view frame frame-a. pause 0. 
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
        */
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(ttcampos).
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

            find first obri-ttatributos where obri-ttatributos.idpai = ttcampos.id and
                                              obri-ttatributos.propriedade = "OBRIGATORIEDADE" and
                                              obri-ttatributos.valor = "true"
                                              no-error.
         
    display avail obri-ttatributos @ vobri
            ttcampos.nome
            ttcampos.conteudo
            with frame frame-a.
            
end procedure.
procedure color-message.

    color display message
            ttcampos.nome
            ttcampos.conteudo
            with frame frame-a.
end procedure.

procedure color-normal.

    color display normal
            ttcampos.nome
            ttcampos.conteudo
            with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
    if par-tipo = "pri" 
    then  
        if esqascend  
        then      
            find first ttcampos where
                true
                       no-lock no-error.
        else  
            find last ttcampos  where
                true
                      no-lock no-error.
    if par-tipo = "seg" or par-tipo = "down" 
    then      
        if esqascend  
        then  
            find next ttcampos  where
                      no-lock no-error.
        else  
            find prev ttcampos  where
                      no-lock no-error.
    if par-tipo = "up" 
    then                  
        if esqascend   
        then   
            find prev ttcampos  where
                      no-lock no-error.
        else   
            find next ttcampos  where 
                  no-lock no-error.
 
end procedure.
         

