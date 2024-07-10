/*     cli/cdhigienizag.p
*
*/
{cabec.i}
def var vconta as int.
def var vformato    as log format "Err/" label "FMT".
def var v2formato   as char format "x(05)" label "FMT".
def var vloop as int.

def var vbusca as char.
def var vtotal as int.
def var vcusto as dec.

def var par-busca       as   char.
def buffer xestab for estab.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial [" Detalhe ", " Seleciona  ", " Higieniza ", "", ""].
def var esqcom2         as char format "x(12)" extent 5
            initial ["Filtros","","","",""].
def var esqhel1         as char format "x(80)" extent 5.
    def var esqhel2         as char format "x(12)" extent 5.

def var vprimeiro as log.

def var vtime        as int.
def var vct          as int.

pause 0 before-hide.
form with frame f-proc.

def new shared temp-table tt-clien no-undo
    field CPF like neuclien.cpf
    field NOVOCPF as char format "x(14)"  
    field CLICOD  like neuclien.clicod    init ?
    field DATEXP like clien.datexp format "99/99/9999"
    field reg as int    format ">>9"
    field regabe as int format ">>9"
    field regtit as int format ">>9"
    field zerar as log column-label "ZERAR"
    field duplo as log column-label "DUP"
    field caracter as log column-label "CARAC"
    field tamanho  as log column-label "TAM"
    field marca    as log column-label "*" format "*/ " init yes
    index cpf is unique primary cpf asc clicod asc
    index regabe regabe asc.

def new shared temp-table tt-clicods no-undo
    field cpf like neuclien.cpf
    field clicod as int format ">>>>>>>>>>9" 
    field datexp like clien.datexp format "99/99/9999"
    field NOVOCPF as char format "x(14)"  
    field zerar as log column-label "ZERAR"
    field duplo as log column-label "DUP"
    field caracter as log column-label "CARAC"
    field tamanho  as log column-label "TAM"
    field sittit   as char format "x(03)" label "Tit"
    index cpf is unique primary cpf asc clicod asc.
    
def buffer xtt-clien for tt-clien.
    
form
    esqcom1
    with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.
    
def var vchoose as char format "x(40)"  extent 5
            init [" TODOS",
                  " Somente Erro Formato ",
                  " Somente Duplos Sem     Conta Aberta",
                  " Somente Duplos Com UMA Conta Aberta",
                  " Somente Duplos Com VARIAS contas Abertas"].
                  
def var tchoose as char format "x(15)"  extent 5
            init ["GER",
                  "FOR", 
                  "SEM",
                  "UMA",
                  "VAR"].
def var vindex as int.
def var ptitle as char.

def new shared var pchoose as char label "Situacao".
/*
def new shared var par-CPF like tt-clien.cpf label "CPF Cliente".
*/


def new shared var par-cadastramento as log format "Sim/Nao" label "Filtra Cadastramento" init yes.
def new shared var par-dtcadini as date format "99/99/9999" label "de".
def new shared var par-dtcadfim as date format "99/99/9999" label "ate".


def new shared var par-estab as log format "Sim/Nao" label "Filtra Estabel"
    init no.
    def new shared var par-etbcad as int format ">>>9" label "Estab".
    

    form
        with frame frame-a 
        07 down centered  row 4
                          title ptitle width 80.
                          

form with frame flinha 
                     row 16 3 down
                     no-box.
 .
form 
        /* par-CPF   colon 30  */
         par-cadastramento       colon 30
             par-dtcadini   
             par-dtcadfim

         par-estab        colon 30
             par-etbcad   
         pchoose    format "x(30)"      colon 30
             
         with frame fcab
            row 3 centered side-labels
            title "Filtros Higienizacao ".

repeat.    
    run pfiltros.
    if keyfunction(lastkey) = "end-error"
    then leave.

find first tt-clien no-lock no-error.
if not avail tt-clien
then do:
    message "Nao foram encontrados registros para esta selecao"
            view-as alert-box.
    next.
end.

bl-princ:
repeat:    
    run ptotal.
    
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then run leitura (input "pri").
    else find tt-clien where recid(tt-clien) = recatu1 no-lock.
    if not available tt-clien
    then return.
            
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(tt-clien).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-clien
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find tt-clien where recid(tt-clien) = recatu1 no-lock.

            clear frame flinha all no-pause.
            vloop = 0.
            for each tt-clicods where tt-clicods.cpf =  tt-clien.cpf
                    and
                    (if tt-clien.zerar
                    then (tt-clicods.clicod = tt-clien.clicod)
                    else true )
                break by tt-clicods.datexp desc
                with frame flinha.
                
                vloop = vloop + 1.
                if vloop > 3
                then leave.
                find clien where clien.clicod = tt-clicods.clicod no-lock.
        
                disp clien.ciccgc format "x(14)"
                     clien.clicod column-label "CODIGO"
                     clien.clinom format  "x(15)"
                     clien.etbcad format ">>9" column-label "Etb"
                     clien.dtcad format "99/99/9999".
        
                disp tt-clicods.datexp column-label "Alter" .
                v2formato = if tt-clicods.zerar
                            then "ZERAR"
                            else if tt-clicods.caracter
                                 then "CARACTER"
                                 else if tt-clicods.tamanho
                                      then "TAMANHO"
                                      else "".
                disp v2formato
                     tt-clicods.sittit.
                down.                     
           end.
                
            disp esqcom1 with frame f-com1.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-clien.novocpf)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-clien.novocpf)
                                        else "".

            choose field tt-clien.novocpf help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      1 2 3 4 5 6 7 8 9 0 F8 PF8 I i
                      tab PF4 F4 ESC return).
            
            if keyfunction(lastkey) = "CLEAR"     or
               keyfunction(lastkey) = "I"
            then do: 
                recatu2 = ?.                
                hide frame frame-a no-pause.
            end.
 
            if keyfunction(lastkey) >= "0" and 
               keyfunction(lastkey) <= "9"
            then do with centered row 8 color message
                                frame f-procura side-label overlay.
                vbusca = keyfunction(lastkey).
                pause 0.
                vprimeiro = yes.
                update vbusca label "Busca"
                    editing:
                        if vprimeiro
                        then do:
                            apply keycode("cursor-right").
                            vprimeiro = no.
                        end.
                    readkey.
                    apply lastkey.
                end.
                recatu2 = recatu1.
                leave.                
            end.

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
                    if not avail tt-clien
                    then leave.
                    recatu1 = recid(tt-clien).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-clien
                    then leave.
                    recatu1 = recid(tt-clien).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-clien
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-clien
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form with frame f-etiqest color black/cyan
                      centered side-label row 5 .
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Detalhe "
                then do:
                    hide frame frame-a no-pause.
                    hide frame f-com1  no-pause.
                    hide message no-pause. 
                    hide frame f-com2 no-pause.
                    hide frame ftotal no-pause.
                    hide frame flinha no-pause.
                    recatu2 = recid(tt-clien).

                    if connected ("finloja") then disconnect finloja. 
                    
                    run cli/manhigieniza_v1902.p (input-output recatu2).
                    view frame f-com1.
                    view frame f-com2.
                    run ptotal.
                    view frame ftotal.
                end.
                if esqcom1[esqpos1] = " Seleciona "
                then do:
                    if tt-clien.regabe <= 1
                    then do:
                        tt-clien.marca = not tt-clien.marca.
                        disp tt-clien.marca
                            with frame frame-a.
                    end.
                    else do:
                        message "Mais de Uma Conta com CONTRATOS ASSOCIADOS" 
                        skip
                         "em ABERTO, Use a Opção DETALHE " 
                        skip 
                         "e Execute a Transferencia"
                         view-as alert-box.
                    end.
                end.
                if esqcom1[esqpos1] = " Higieniza "
                then do:
                    vconta = 0.
                    for each tt-clien where
                        tt-clien.marca = yes.
                        vconta = vconta + 1.
                    end.    
                    message "Confirma Higienizar o Cadastro de"
                        vconta "CPFs" update sresp.
                    if sresp
                    then do:
                        hide message no-pause.
                        message color message "Aguarde Processo...".
                        for each tt-clien
                            where tt-clien.marca = yes.
                            run cli/higaltera_v1801.p (recid(tt-clien),
                                                       ?).
                            tt-clien.marca = ?.
                        end. 
                        hide message no-pause.
                        message "Processo Encerrado!"
                            view-as alert-box.
                           
                    end.
                    recatu1 = ?.
                    leave.
                end.
                
                

            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                
                if esqcom2[esqpos2] = "Filtros" 
                then do.
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run pfiltros.
                    recatu1 = ?.
                    leave.
                end.
                if esqcom2[esqpos2] = "Relatorio" 
                then do.
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run relatorio.
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
        recatu1 = recid(tt-clien).
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

procedure frame-a.


    vformato = tt-clien.zerar or
               tt-clien.caracter or
               tt-clien.tamanho. 
    find clien where clien.clicod = tt-clien.clicod no-lock no-error.

    disp 
        tt-clien.marca
        tt-clien.NOVOCPF column-label "CPF"
        tt-clien.CLICOD  column-label "CODIGO"
        clien.clinom     format "x(28)" when avail clien
        tt-clien.REG     column-label "Regs"
        tt-clien.regtit column-label "Parc"
        tt-clien.REGABE  column-label "Parc!Abe"
        vformato
        tt-clien.zerar format "Z/ " column-label "Z"
 
        with frame frame-a.

end procedure.

procedure leitura . 
def input parameter par-tipo as char.

if par-tipo = "pri" 
then  
    find first tt-clien  no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    find next tt-clien  no-error.
if par-tipo = "up" 
then                  
    find prev tt-clien no-error.

end procedure.
         

procedure ptotal. 
    vtotal = 0.
    
    for each xtt-clien no-lock.
        vtotal = vtotal + 1.
    end.
    pause 0 before-hide.
    disp vtotal label "Total"  to 80
         with frame ftotal row screen-lines - 1 no-box side-labels column 1
                 centered.
end procedure.

procedure montatt.

for each tt-clien.
    delete tt-clien.
end.
for each tt-clicods.
    delete tt-clicods.
end.         

run cli/higieniza_v1801.p.


end procedure.


form with frame flinha no-box width 140.
    def var vtotpc  as dec.

procedure pfiltros.

repeat.
    hide frame flinha no-pause.
    
    ptitle = "".

   
        
   /* par-CPF = 0.
    hide message no-pause.
    message color normal 
        "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
 
    update par-CPF when keyfunction(lastkey) <> "I" and
                      keyfunction(lastkey) <> "CLEAR"
        go-on(F8 PF8)
    with frame fcab.
    if keyfunction(lastkey) = "CLEAR" or 
       keyfunction(lastkey) = "I"
    then     do: 
        recatu2 = ?. 
        /*
        find banavisopag where recid(banavisopag) = recatu2 no-lock no-error.
        if avail banavisopag
        then do:
            par-cdoperacao = tt-clien.novocpf.
            return.
        end.
        else do:
            undo.
        end.
        **/
        
    end.
   */ 
    /**
    find banavisopag where tt-clien.novocpf = par-cdoperacao 
        no-lock no-error.
    if par-cdoperacao <> ""
    then do:
        if not avail banavisopag
        then do:
            message "avisopag Inexistente".
            undo.
        end.
        else do.
            if avail banavisopag
            then do:
                
                ptitle = string(tt-clien.novocpf).
                
                recatu1 = ?.
                run montatt.
                return.
            end.        
        end.
    end.
    **/
    hide message no-pause.
    message color normal 
        "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
 
    do:
        update par-cadastramento with frame fcab.
        /**
        if keyfunction(lastkey) = "GO" and 
           par-vencimento = no and
           pchoose <> "LIQ" and
           pchoose <> "BAI"
        then do:
            recatu1 = ?.
            run montatt.
            return.
        end.
        **/
        
        if par-cadastramento
        then do:
            hide message no-pause.
            message color normal 
            "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
            if par-dtcadini = ?
            then assign
                    par-dtcadini = date(01,01,year(today))
                    par-dtcadfim = today.
            
            update par-dtcadini
                   par-dtcadfim
                with frame fcab.
            if par-dtcadini = ? or 
               par-dtcadfim = ? or
               par-dtcadfim < par-dtcadini
            then     do:
                message "Datas Invalidas".
                undo.
            end.
        end.
        /**
        if keyfunction(lastkey) = "GO" and
           pchoose <> "LIQ" and
           pchoose <> "BAI"
 
        then do:
            recatu1 = ?.
            run montatt.
            return.
        end.
        **/
        
    end.
    
     hide message no-pause.
    message color normal 
        "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
    
    update par-estab  with frame fcab.
    /**
    if keyfunction(lastkey) = "GO" and 
       par-emissao = no and
           pchoose <> "LIQ" and
           pchoose <> "BAI"
 
    then do:
        recatu1 = ?.
        run montatt.
        return.
    end.
    **/
    
    if par-estab
    then do:
        hide message no-pause.
        message color normal 
        "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
        if par-etbcad = ?
        then assign
                par-etbcad = 0.
        
        update par-etbcad
            with frame fcab.
    end.
    /**
    if keyfunction(lastkey) = "GO" and
           pchoose <> "LIQ" and
           pchoose <> "BAI"
 
    then do:
        recatu1 = ?.
        run montatt.
        return.
    end.
    **/
    

    display vchoose
        with frame fff centered row 8 no-label overlay 1 col
        title " Escolha Filtro Situacao ".
    choose field vchoose with frame fff.                         
    pchoose =  tchoose[frame-index].
    vindex = frame-index.
    
    hide frame fff no-pause.
    ptitle =  pchoose + "-" + vchoose[vindex] .
    
    disp pchoose + "-" + vchoose[vindex] @ pchoose with frame fcab.

    /**
     hide message no-pause.
    message color normal 
        "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
    
    if pchoose = "PEN"
    then par-envio = no.
    else do:
        update par-envio with frame fcab.
        /**
        if keyfunction(lastkey) = "GO" and 
           par-envio = no and
           pchoose <> "LIQ" and
           pchoose <> "BAI"
 
        then do:
            recatu1 = ?.
            run montatt.
            return.
        end.
        **/
        
        if par-envio
        then do:
            hide message no-pause.
            message color normal 
            "Pressionando~ F1 EH o mesmo que dar . ENTER ate o ultimo campo".
            if par-dtenvini = ?
            then assign
                    par-dtenvini = today
                    par-dtenvfim = today.
            
            update par-dtenvini
                   par-dtenvfim
                with frame fcab.
            if par-dtenvini = ? or 
               par-dtenvfim = ? or
               par-dtenvfim < par-dtenvini
            then     do:
                message "Datas Invalidas".
                undo.
            end.
        end.
        /**
        if keyfunction(lastkey) = "GO" and
           pchoose <> "LIQ" and
           pchoose <> "BAI"
 
        then do:
            recatu1 = ?.
            run montatt.
            return.
        end.
        **/
        
    end.
    
    hide message no-pause.
    message color normal 
        "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
     
    if pchoose = "PEN" or
       pchoose = "ENV"
    then par-pagamento = no.
    else do:
        if pchoose = "LIQ"
        then do:
            par-pagamento = yes.
            disp par-pagamento with frame fcab.
        end.
        else update par-pagamento with frame fcab.
        
        /**
        if keyfunction(lastkey) = "GO" and 
           par-pagamento = no and
           pchoose <> "BAI"
        then do:
            recatu1 = ?.
            run montatt.
            return.
        end.
        **/
        
        if par-pagamento
        then do:
            hide message no-pause.
            message color normal 
            "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
            if par-dtpagini = ?
            then assign
                    par-dtpagini = today
                    par-dtpagfim = today.
            update par-dtpagini
                   par-dtpagfim
                with frame fcab.
            if par-dtpagini = ? or 
               par-dtpagfim = ? or
               par-dtpagfim < par-dtpagini
            then     do:
                message "Datas Invalidas".
                undo.
            end.
        end.
        /**
        if keyfunction(lastkey) = "GO" and
           pchoose <> "BAI"
 
        then do:
            recatu1 = ?.
            run montatt.
            return.
        end.
        **/
        
    end.
    
     hide message no-pause.
    message color normal 
        "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
     if pchoose = "PEN" or
       pchoose = "ENV" or
       pchoose = "LIQ"
    then par-baixa = no.
    else do:
        if pchoose = "BAI"
        then do:
            par-baixa = yes.
            disp par-baixa with frame fcab.
        end.    
        else
            update par-baixa with frame fcab.
        /**
        if keyfunction(lastkey) = "GO" and 
           par-baixa = no
        then do:
            recatu1 = ?.
            run montatt.
            return.
        end.
        **/
        
        if par-baixa
        then do:
            hide message no-pause.
            message color normal 
            "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
            if par-dtbaiini = ?
            then assign
                    par-dtbaiini = today
                    par-dtbaifim = today.
            
            update par-dtbaiini
                   par-dtbaifim
                with frame fcab.
            if par-dtbaiini = ? or 
               par-dtbaifim = ? or
               par-dtbaifim < par-dtbaiini
            then     do:
                message "Datas Invalidas".
                undo.
            end.
        end.
        /**
        if keyfunction(lastkey) = "GO"
        then do:
            recatu1 = ?.
            run montatt.
            return.
        end.
        **/
        
    end.
    **/
    
    run montatt.
    /**
    find first tt-clien no-error.
    if avail tt-clien
    then **/ leave.

end.
recatu1 = ?.

/**
run montatt.
**/

hide frame flinha no-pause.


end procedure.

