/* helio 23052023 Orquestra 497885 - Relatório Histórico ADMCOM. */
{admcab.i}
def var vdtini as date format "99/99/9999" label "de".
def var vdtfim as date format "99/99/9999" label "ate".

    
def new shared temp-table ttcampos no-undo
    field campo as char format "x(20)"     
    field campoLabel as char format "x(20)"
    field marca     as log format "*/ " column-label "*"
    index x is unique primary campo asc.
    
update vdtini colon 20 vdtfim    
    with frame f-altera
               with color white/cyan
               centered OVERLAY
               side-label width 80 row 3 
                              title "CONSULTA HISTORICO DE ALTERACOES DE CLIENTES".

                   
def temp-table tt-hist no-undo
    field clicod like clien.clicod
    field dtalt like clienhist.dtalt column-label "Data"
    field hralt as char format "x(5)" column-label "Hora"
    field hora as int
    field funcod as int
    field etbcod as int
    field cxacod as int
    field programa like clienhist.programa format "x(10)"
    field Campo as char format "x(10)"
    field Antes as char format "x(30)"
    field Depois as char format "x(30)"
    index x clicod asc dtalt desc hora desc.

run campossel.p.

def var vcamposantes as char.
def var vcamposdepois as char.
def var vi as int.
for each clienhist where clienhist.dtalt >= vdtini and clienhist.dtalt <= vdtfim no-lock.
    if num-entries(clienhist.camposdif) = 0
    then next.
    do vi = 1 to num-entries(clienhist.camposdif).
        
        find ttcampos where ttcampos.campo =  entry(vi,clienhist.camposdif) no-error.
        if not avail ttcampos or
          (avail ttcampos and ttcampos.marca = no)
        then next.
        
        vcamposantes = entry(vi,clienhist.camposantes) no-error.
        if vcamposantes = ? or vcamposantes = "-" then next.
        vcamposdepois = entry(vi,clienhist.camposdepois) no-error.
        if vcamposdepois = ? then vcamposdepois = vcamposantes.

        if vcamposantes = vcamposdepois then next.
        
        
        create tt-hist.
        tt-hist.clicod = clienhist.clicod.
        tt-hist.dtalt   = clienhist.dtalt.
        tt-hist.hralt   = string(clienhist.hralt,"HH:MM").
        tt-hist.hora = clienhist.hralt.
        tt-hist.programa = clienhist.programa.
        tt-hist.funcod = clienhist.funcod.
        tt-hist.campo = entry(vi,clienhist.camposdif).
        tt-hist.Antes = vcamposantes.
        tt-hist.Depois = vcamposdepois.
        tt-hist.etbcod        = clienhist.etbcod.
        tt-hist.cxacod  = clienhist.cxacod.
    end.
end.    

/*
*
*    tt-hist.p    -    Esqueleto de Programacao    com esqvazio
*
*/

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 5.

esqcom1[1] = " csv ".

    form 
        tt-hist.clicod
        tt-hist.dtalt  
        tt-hist.hralt  
        tt-hist.funcod 
        tt-hist.programa format "x(30)" skip space(4)
        tt-hist.campo 
        tt-hist.antes space(0) "->" space(0)
        tt-hist.depois 
        with frame frame-a 6 down centered color white/red row 7 no-labels
        title " Historico ".

form
    esqcom1
    with frame f-com1
                 row 6 no-box no-labels side-labels column 1 centered.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find tt-hist where recid(tt-hist) = recatu1 no-lock.
    if not available tt-hist
    then do.
        message "Sem registros" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(tt-hist).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available tt-hist
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:
            find tt-hist where recid(tt-hist) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field tt-hist.Campo help ""
                go-on(cursor-down cursor-up
                      page-down   page-up
                      PF4 F4 ESC return) .
            run color-normal.
            status default "".

            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-hist
                    then leave.
                    recatu1 = recid(tt-hist).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-hist
                    then leave.
                    recatu1 = recid(tt-hist).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-hist
                then next.
                color display white/red tt-hist.Campo with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-hist
                then next.
                color display white/red tt-hist.Campo with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
            if  keyfunction(lastkey) = "return"
            then do:
                if esqcom1[esqpos1] = " csv"
                then do:
                    hide frame frame-a no-pause.
                    run geracsv.
                    recatu1 = ?.
                    leave.
                end.    
                
            end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-hist).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.


procedure frame-a.
    display 
        tt-hist.clicod
            tt-hist.dtalt  
        tt-hist.hralt  
        tt-hist.funcod 
        tt-hist.programa
        tt-hist.campo tt-hist.antes tt-hist.depois 
        with frame frame-a.
end procedure.


procedure color-message.
    color display message
        tt-hist.campo tt-hist.antes tt-hist.depois 
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        tt-hist.campo tt-hist.antes tt-hist.depois 
        with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first tt-hist where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next tt-hist  where true no-lock no-error.
             
if par-tipo = "up" 
then find prev tt-hist where true   no-lock no-error.
        
end procedure.




procedure geracsv.

def var varqcsv as char format "x(65)".
    varqcsv = "/admcom/relat/clienhist_" + 
                string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".csv".
    
    update varqcsv no-label colon 12
                            with side-labels width 80 frame f1
                            row 15 title "historico de alteracoes"
                            overlay.


message "Aguarde...". 
pause 1 no-message.

output to value(varqcsv).
put unformatted  
    "Codigo;Nome;CPF;RG;E-mail;Rua;Numero;Complemento;Bairro;Cidade;Estado;Cep;Telefone;Celular;Data cadastro;"
    "Data alteração;Filial;Matricula do funcionario;Horario;PDV;Campo Alterado;Dado antigo;Dado alterado;Programa"
    skip.

    for each tt-hist        
        no-lock
            by tt-hist.dtalt by tt-hist.hora.
            run pcsvimp.
    end.

    
output close.
message "relatorio csv gerado" varqcsv.
pause 2 no-message.
end procedure.

procedure pcsvimp.
    
    find clien where clien.clicod = tt-hist.clicod no-lock.

    put unformatted skip
        tt-hist.clicod ";"
        clien.clinom  ";"
        clien.ciccgc ";"
        clien.ciinsc ";"
        clien.zona  ";"
        clien.endereco[1]  ";"
        clien.numero[1]  ";"
        clien.compl[1] ";"
        clien.bairro[1]  ";"
        clien.cidade[1]  ";"
        clien.ufecod[1] ";"
        clien.cep[1]  ";"
        clien.fone  ";"
        clien.fax  ";"
        clien.dtcad  ";"
        tt-hist.dtalt  format "99/99/9999" ";"
        tt-hist.etbcod ";"
        tt-hist.funcod ";"  
        string(tt-hist.hralt,"HH:MM:SS") ";"
        tt-hist.cxacod ";"
        tt-hist.campo ";"
        tt-hist.antes ";"
        tt-hist.depois ";"
        tt-hist.programa ";"
        skip.


end procedure.

