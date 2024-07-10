/*
*
*    estab.p    -    Esqueleto de Programacao    com esqvazio
*
Claudir - 19/07/2022 - Opo gerar arquivo CSV
*/

{admcab.i}

def var vsenha like func.senha.
def var vcep as int.
def var vbairro as char.
def buffer bestab       for estab.
def var vbloco-k as log format "Sim/Nao".

form estab.etbcod   colon 17
     estab.RegCod   colon 45
     estab.etbnom   colon 17
     estab.ufecod   colon 17
     estab.etbinsc  colon 17
     estab.etbcgc   colon 45
     estab.endereco colon 17
     vbairro        label "Bairro" format "x(40)"   colon 17
     estab.munic    format "x(45)"  colon 17
     vcep           label "CEP" format "99999999" 
/***
     estab.etbtofne colon 17
     estab.etbtoffe      
***/
     estab.etbserie colon 17 label "Fone" format "x(15)"
     estab.movndcfim colon 45
     estab.etbfluxo colon 17
     estab.estcota  colon 45 label "N.I.R.C" format "99999999999"
     estab.etbcon   colon 17 format ">,>>>,>>9.99"
     filialsup.supcod format ">>>9" label "Supervisor"   colon 45  
     supervisor.supnom no-label
     estab.etbmov   format ">,>>>,>>9.99"   colon 17
     estab.vencota  format "9999" label "N.Dias" colon 45
     estab.tamanho  colon 17
     estab.tipoloja colon 45
     estab.prazo    colon 17
     estab.vista    colon 45
     estab.usap2k   colon 17 
     estab.spc-etbcod colon 45 validate(estab.spc-etbcod > 0,"Informe o codigo")
     estab.spc-senha  validate(estab.spc-senha <> "","Informe a senha")
     vbloco-k       colon 17 label "Bloco K"
     
     with frame f-altera1 side-label overlay row 5 centered color white/cyan.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqvazio        as log.
def var esqregua      as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Consulta "," Pesquisa", "  IE ST"].
def var esqcom2         as char format "x(12)" extent 5
    initial ["Operacao"," Arquivo CSV","","",""]. 

form esqcom1 with frame f-com1 row 4 no-box no-labels column 1 centered.
form esqcom2 with frame f-com2 row screen-lines no-box no-labels column 1 centered.

assign
    esqpos1  = 1
    esqpos2  = 1
    .

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then run leitura (input "pri").
    else find estab where recid(estab) = recatu1 no-lock.
    if not available estab
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(estab).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available estab
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
            find estab where recid(estab) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field estab.etbcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return TAB) .
            run color-normal.
            status default "".
        end.
        
        if keyfunction(lastkey) = "TAB"
        then do:
            def var ve as int.
            if esqregua
            then do:
                esqpos1 = 1.
                do ve = 1 to 5:
                    color display normal esqcom1[ve] with frame f-com1.
                end.
                color display message esqcom2[esqpos2] with frame f-com2.
            end.
            else do:
                do ve = 1 to 5:
                    color display normal esqcom2[ve] with frame f-com2.
                end.
                esqpos2 = 1.
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
                    if not avail estab
                    then leave.
                    recatu1 = recid(estab).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail estab
                    then leave.
                    recatu1 = recid(estab).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail estab
                then next.
                color display white/red estab.etbcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
                run frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail estab
                then next.
                color display white/red estab.etbcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
                run frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if esqregua
        then do:
        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Inclusao " or esqvazio
            then do with frame f-altera1 on error undo.
                hide frame frame-a no-pause.
                vsenha = "".
                update vsenha blank with frame f-senh 
                            side-label centered row 10.
                if vsenha  <> "1951"
                then do:
                    message "Senha Invalido.".
                    undo, retry.
                end.

                create estab.
                assign
                    estab.tamanho  = ""
                    estab.tipoloja = "".
                update 
                    estab.etbcod 
                    estab.RegCod
                    estab.etbnom 
                    estab.ufecod 
                    estab.etbinsc
                    estab.etbcgc 
                    estab.endereco
                    vbairro 
                    estab.munic 
                    vcep 
                    estab.etbserie
                    estab.movndcfim
                    estab.etbfluxo   
                    estab.estcota 
                    estab.etbcon
                    estab.etbmov 
                    estab.vencota.

                if estab.etbcod = 0
                then do:
                    delete estab.
                    leave.
                end.
                
                prompt-for filialsup.supcod.
                find first filialsup where filialsup.etbcod = estab.etbcod
                                            exclusive-lock no-error.

                if not avail filialsup
                then do:
                    create filialsup.
                    FilialSup.etbcod = estab.etbcod.
                end.
                filialsup.supcod = input filialsup.supcod.
                
                estab.etbnom = caps(estab.etbnom).
                do on error undo.
                    update estab.tamanho
                           estab.tipoloja.
                    if estab.tamanho = "" then undo.
                    if estab.tipoloja = "" then undo.
                    find first atributo where 
                                     atributo.tipo = "tipo loja" and
                                     atributo.atribDes = estab.tipoloja
                                     no-lock no-error.
                    if not avail atributo 
                    then do.
                        message "Tipo de Estabelecimento invalido".
                        undo.
                    end.
                end.                

                run criarepexporta.p ("ESTAB",
                                      "INCLUSAO",
                                      recid(estab)).
                run email.
                recatu1 = recid(estab).
                leave.
            end.

            if esqcom1[esqpos1] = " Consulta " or
               esqcom1[esqpos1] = " Alteracao "
            then do.
                run consulta.
            end.

            if esqcom1[esqpos1] = " Alteracao "
            then do with frame f-altera1 on error undo.
                vsenha = "".
                update vsenha blank with frame f-senh 
                           side-label centered row 10.
                if vsenha <> "1951"
                then do:
                    message "Senha Invalido.".
                    undo, retry.
                end.

                find current estab exclusive.
                find tabaux where 
                     tabaux.tabela = "ESTAB-" + string(estab.etbcod,"999") and
                     tabaux.nome_campo = "CEP" no-error.
                if avail tabaux
                then vcep = int(tabaux.valor_campo).
                else vcep = 0.
                find tabaux where 
                     tabaux.tabela = "ESTAB-" + string(estab.etbcod,"999") and
                     tabaux.nome_campo = "BAIRRO" no-error.
                if avail tabaux
                then vbairro = tabaux.valor_campo.
                else vbairro = "".
    
                update estab.RegCod
                       estab.etbnom
                       estab.ufecod
                       estab.etbinsc
                       estab.etbcgc
                       estab.endereco
/***
                       estab.etbtofne
                       estab.etbtoffe
***/
                       vbairro
                       estab.munic
                       vcep
                       estab.etbserie
                       estab.movndcfim
                       estab.etbfluxo
                       estab.estcota
                       estab.etbcon
                       estab.etbmov
                       estab.vencota
                       estab.prazo
                       estab.vista with no-validate.
                estab.etbnom = caps(estab.etbnom).
                find tabaux where 
                     tabaux.tabela = "ESTAB-" + string(estab.etbcod,"999") and
                     tabaux.nome_campo = "CEP" no-error.
                if avail tabaux and
                    tabaux.valor_campo <> string(vcep)
                then tabaux.valor_campo = string(vcep).
                else if not avail tabaux and
                    vcep > 0
                then do:
                    create tabaux.
                    assign
                        tabaux.tabela  = "ESTAB-" + string(estab.etbcod,"999") 
                        tabaux.nome_campo  = "CEP" 
                        tabaux.valor_campo = string(vcep)
                        tabaux.tipo_campo  = "Int"
                        tabaux.datexp  = today
                        tabaux.exporta = yes.
                end.
                find tabaux where 
                     tabaux.tabela = "ESTAB-" + string(estab.etbcod,"999") and
                     tabaux.nome_campo = "BAIRRO" no-error.
                if avail tabaux and
                    tabaux.valor_campo <> vbairro
                then tabaux.valor_campo = vbairro.
                else if not avail tabaux and
                    vbairro <> ""
                then do:
                    create tabaux.
                    assign
                        tabaux.tabela  = "ESTAB-" + string(estab.etbcod,"999") 
                        tabaux.nome_campo  = "BAIRRO" 
                        tabaux.valor_campo = vbairro
                        tabaux.tipo_campo  = "char"
                        tabaux.datexp  = today
                        tabaux.exporta = yes.
                end.
                
                find first filialsup where filialsup.etbcod = estab.etbcod
                                            exclusive-lock no-error.

                if not avail filialsup
                then do:
                    create filialsup.
                    filialsup.etbcod = estab.etbcod.
                end.
                
                update filialsup.supcod.
                do on error undo.
                    update estab.tamanho
                           estab.tipoloja.
                    if estab.tamanho = "" then undo.
                    if estab.tipoloja = "" then undo.
                    find first atributo where 
                                     atributo.tipo = "tipo loja" and
                                     atributo.atribDes = estab.tipoloja
                                     no-lock no-error.
                    if not avail atributo 
                    then do.
                        message "Tipo de Estabelecimento invalido".
                        undo.
                    end.
                end.

                run manutencao (output sresp).
                if not sresp
                then undo.
                run criarepexporta.p ("ESTAB",
                                      "ALTERACAO",
                                      recid(estab)).
                run email.
            end.
            if esqcom1[esqpos1] = " Pesquisa "
            then do on error undo with frame f-pes side-label.
                prompt-for estab.etbcod.
                find bestab where bestab.etbcod = input estab.etbcod
                            no-lock no-error.
                if avail bestab
                then recatu1 = recid(bestab).
                leave.
            end.
            if esqcom1[esqpos1] = " Listagem "
            then do with frame f-Lista:
                    leave.
            end.
            if esqcom1[esqpos1] = "  IE ST "
            then do:
                run cad_iest.p(input estab.etbcod).
            end.
        end.
        if not esqvazio
        then run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        end.
        else do:
            if esqcom2[esqpos2] = " Arquivo CSV"
            then do:
                run arquivo-csv.
            end.
            if esqcom2[esqpos2] = "Operacao"
            then do on error undo:
                find current estab exclusive.
                    display
                        estab.etbcod column-label "Etb" format ">>9"
                        estab.etbnom  format "x(15)"
                        estab.etbinsc format "x(13)"
                        estab.etbcgc
                        estab.munic   format "x(10)"
                        estab.ufecod
                        estab.usap2k column-label "P2k"
                        estab.emoperacao column-label "oper"
                        with frame frame-a .
                update estab.emoperacao
                    with frame frame-a.
            end.
                
        end.
        
        recatu1 = recid(estab).
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
        estab.etbcod column-label "Etb" format ">>9"
        estab.etbnom  format "x(15)"
        estab.etbinsc format "x(13)"
        estab.etbcgc
        estab.munic   format "x(10)"
        estab.ufecod
        estab.usap2k column-label "P2k"
        estab.emoperacao column-label "oper"
        
        with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
color display message
        estab.etbcod
        estab.etbnom
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        estab.etbcod
        estab.etbnom
        with frame frame-a.
end procedure.


procedure manutencao.

    def output parameter par-ok as log init no.

    do on error undo with frame f-altera1.

        update estab.usap2k when estab.tipoloja = "normal" or 
                                 estab.tipoloja = "Outlet".
        if estab.usap2k
        then do on error undo.
            update
                estab.spc-etbcod
                estab.spc-senha.
        end.

        if estab.usap2k
        then do.
            find first tab_ini where tab_ini.parametro = "NFE - SERIE"
                                 and tab_ini.etbcod    = estab.etbcod
                               no-error.
            if not avail tab_ini
            then do.
                create tab_ini.
                assign
                    tab_ini.etbcod    = estab.etbcod
                    tab_ini.parametro = "NFE - SERIE"
                    tab_ini.dtinclu   = today.
            end.
            tab_ini.valor = "2".
        end.
        par-ok = yes.
    
        find tabaux where 
             tabaux.tabela = "ESTAB-" + string(estab.etbcod,"999") and
             tabaux.nome_campo = "BLOCOK" no-error.
        if avail tabaux
        then vbloco-k = (tabaux.valor_campo = "SIM").
        else vbloco-k = no.

        update vbloco-k.
        
        if avail tabaux
        then do:
            if vbloco-k  <> (tabaux.valor_campo = "SIM")
            then if vbloco-k then tabaux.valor_campo = "SIM".
                             else tabaux.valor_campo = "NAO".
        end.
        else if vbloco-k
        then do:
            create tabaux.
            assign
                    tabaux.tabela = "ESTAB-" + string(estab.etbcod,"999")
                    tabaux.nome_campo = "BLOCOK"
                    .
            if vbloco-k then tabaux.valor_campo = "SIM".
                        else tabaux.valor_campo = "NAO".
        end.
    end.
end procedure.


procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  find first estab where true no-lock no-error.
    else  find last estab  where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  find next estab  where true no-lock no-error.
    else  find prev estab   where true no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then  find prev estab where true   no-lock no-error.
    else  find next estab where true  no-lock no-error.
        
end procedure.

procedure consulta.

    do with frame f-altera1.
        find tabaux where 
                     tabaux.tabela = "ESTAB-" + string(estab.etbcod,"999") and
                     tabaux.nome_campo = "CEP" no-lock no-error.
        if avail tabaux
        then vcep = int(tabaux.valor_campo).
        else vcep = 0.

        find tabaux where  tabaux.tabela = "ESTAB-" +                                 string(estab.etbcod,"999") and
                             tabaux.nome_campo = "BAIRRO" no-lock no-error.
        if avail tabaux 
        then vbairro = tabaux.valor_campo.
        else vbairro = "".

        find tabaux where 
                     tabaux.tabela = "ESTAB-" + string(estab.etbcod,"999") and
                     tabaux.nome_campo = "BLOCOK" no-lock no-error.
        if avail tabaux and tabaux.valor_campo = "SIM"
        then vbloco-k = yes.
        else vbloco-k = no.
        
        disp estab.etbcod
              estab.RegCod
              estab.etbnom
              estab.ufecod
              estab.etbinsc
                       estab.etbcgc
                       estab.endereco
/***
                       estab.etbtofne
                       estab.etbtoffe
***/
                       vbairro
                       estab.munic
                       vcep
                       estab.etbserie
                       estab.movndcfim
                       estab.etbfluxo
                       estab.estcota
                       estab.etbcon
                       estab.etbmov
                       estab.vencota
                       estab.prazo
                       estab.vista
              estab.usap2k
              estab.spc-etbcod
              estab.spc-senha
              vbloco-k.
                       
                find first filialsup where filialsup.etbcod = estab.etbcod
                                                    no-lock no-error.
                                                    
                find first supervisor
                     where supervisor.supcod = filialsup.supcod
                                    no-lock no-error.
                                                    
                display filialsup.supcod when avail filialsup
                        supervisor.supnom when avail supervisor.

        disp estab.tamanho
            estab.tipoloja.
        disp estab.usap2k.
    end.
end procedure.

procedure email.

    def var varqmail as char.
    def var vassunto as char.
    def var varquivo as char.
    def var vdestino as char.
    
    assign
        vassunto = "Manutencao de Estabelecimentos" 
        vdestino = "sistema@lebes.com.br;sustentacao@lebes.com.br;" /*ricardo.mascarello@linx.com.br*/
        varquivo = "/admcom/relat/email" + string(time) + ".html".

    output to value(varquivo).
    put "<html>" skip
        "<head>" skip
        "<meta http-equiv=~"Content-Languag~" content=~"pt-br~">" skip
        "<meta name=~"GENERATOR~" content=~"Microsoft FrontPage 5.0~">" skip
        "<meta name=~"ProgId~" content=~"FrontPage.Editor.Document~">" skip
        "<meta http-equiv=~"Content-Type~" content=~"text/html; ".
    put "charset=windows-1252~">" skip
        "<title>Nova pagina</title>" skip
        "</head>" skip
        "<body>" skip.
    put unformatted
        "<h1>Sistema Admcom</h1></p>"
        "<b>Operacao:</b> " esqcom1[esqpos1] "</p>"
        "<b>Estabelecimento:</b> " estab.etbcod " - " estab.etbnom "</p>"
        "<b>Funcionario:</b> " sfuncod "</p></p>". 
    put "</body>" skip.
    put "</html>" skip.
    
    output close.
        
    varqmail = "/admcom/progr/mail.sh " +
                        " ~"" + vassunto + "~"" +
                        " ~"" + varquivo + "~"" +
                        " ~"" + vdestino + "~"" +
                        " ~"" + vdestino + "~"" +
                        " ~"text/html~"". 
    unix silent value(varqmail).

end procedure.
         
procedure arquivo-csv:

    def var varquivo as char.
    varquivo = "/admcom/relat/filiais-" + string(time) + ".csv".
    
    output to value(varquivo) page-size 0.
    
    put unformatted
    "Codigo;Nome;CNPJ;InscEst;Municipo;UF;Bairro;Endereco" skip.

    for each bestab no-lock by bestab.etbcod:
       
        find tabaux where tabaux.tabela = "ESTAB-" +
                   string(estab.etbcod,"999") and
                   tabaux.nome_campo = "BAIRRO" no-lock no-error.
        if avail tabaux
        then vbairro = tabaux.valor_campo.
        else vbairro = "".

        put unformatted bestab.etbcod ";"   
                        bestab.etbnom ";"
                        bestab.etbcgc ";"
                        bestab.etbinsc ";"
                        bestab.munic ";"
                        bestab.ufecod ";"
                        vbairro ";"
                        bestab.endereco
                        skip.
    end.
    output close.

    varquivo = replace(varquivo,"admcom","L:~\").
    varquivo = replace(varquivo,"relat","relat~\").
    varquivo = replace(varquivo,"/","").

    message color red/with
        "Arquivo gerado"
        varquivo
        view-as alert-box.

end procedure.


