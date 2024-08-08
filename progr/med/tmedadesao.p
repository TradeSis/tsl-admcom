/* helio 06122023 - RELATÓRIO DE VENDAS CHAMA DOUTOR - ID 563918 */
/* medico na tela 042022 - helio */

{admcab.i}

def input param psituacao   as char.
def input param ctitle      as char.
def input param pdtini      as date.
def input param pdtfim      as date.
def buffer bclien for clien.

def var pcpf        as dec format "99999999999".             

 
def temp-table ttadesao no-undo
    field rec as recid.
    
def var vhelp as char.
def var xtime as int.
def var vconta as int.
def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial ["conteudo",""," csv"," csv 2"].

form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def var vsel as int.
def var vabe as dec.

def var vtotservico   as dec.
def var vclinom       as char.        

def var vdtini as date format "99/99/9999" label "de".
def var vdtfim as date format "99/99/9999" label "ate".

    form  
        medadesao.etbcod column-label "fil" format ">>9"
        medadesao.cpf                         column-label "cpf" format "99999999999"
        vclinom  format "x(15)" column-label "cliente"
        medadesao.idAdesao  column-label "id" format ">>>>9"
        medadesao.valorServico  column-label "vlr" format ">>>>9.99"
        medadesao.dataTransacao column-label "dt venda" format "99999999"
        medadesao.contnum   format ">>>>>>>>9"
        medadesao.dtcanc      column-label "dt canc"   format "99999999"
 
        
        with frame frame-a 9 down centered row 7
        no-box.

if psituacao = "VENDAS" or psituacao = "CANCELAMENTOS"
then do:

    disp 
        ctitle format "x(70)" no-label
        with frame ftit
            side-labels
            row 3
            centered
            no-box
            color messages.



    update
        vdtini
        vdtfim
        with frame fperiodo
        centered row 5
        side-labels.
        
   ctitle = ctitle + " / periodo: " + string(vdtini,"99/99/9999") + " a " + string(vdtfim,"99/99/9999").
    disp 
    ctitle format "x(70)" no-label
        with frame ftit
            side-labels
            row 3
            centered
            no-box
            color messages.

end.    
if psituacao = "CLIENTE"
then do:
    disp 
        ctitle format "x(70)" no-label
        with frame ftit
            side-labels
            row 3
            centered
            no-box
            color messages.



      update pcpf label "cpf"
            with frame fremessa
            row 9 centered side-labels overlay.

    ctitle = ctitle + " / Cliente: " + string(pcpf).
    disp 
    ctitle format "x(70)" no-label
        with frame ftit
            side-labels
            row 3
            centered
            no-box
            color messages.
end.

if psituacao = "CSV2"
then do:
    vdtini = pdtini.
    vdtfim = vdtfim.
    empty temp-table ttadesao.
    run montatt.
    run geracsv2.
    return.    
end.
form 
    vtotservico    label "Filtrado"      format "zzzzzzzz9.99" colon 65
        with frame ftot
            side-labels
            row screen-lines - 2
            width 80
            no-box.

empty temp-table ttadesao.
run montatt.

bl-princ:
repeat:
    
   vtotservico = 0.
    for each ttadesao.

        find medadesao where recid(medadesao) = ttadesao.rec no-lock. 
        vtotservico = vtotservico + medadesao.valorServico.
    end.
           
    disp
        vtotservico
        with frame ftot.

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttadesao where recid(ttadesao) = recatu1 no-lock.
    if not available ttadesao
    then do.
        message "nenhum registro encontrato".
        pause.
        return.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttadesao).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttadesao
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttadesao where recid(ttadesao) = recatu1 no-lock.
        find medadesao where recid(medadesao) = ttadesao.rec no-lock.

        esqcom1[2] = if medadesao.dtcanc = ? then "cancela" else "".
        esqcom1[5] = " csv". 
        esqcom1[6] = " csv 2". 
        
        esqcom1[3] = "repasses". 
        esqcom1[4] = "historico".

        status default "".
        
                        
        /*             
        def var vx as int.
        def var va as int.
        va = 1.
        do vx = 1 to 6.
            if esqcom1[vx] = ""
            then next.
            esqcom1[va] = esqcom1[vx].
            va = va + 1.  
        end.
        vx = va.
        do vx = va to 6.
            esqcom1[vx] = "".
        end.     
        */
    hide message no-pause.
    /*    
    if medadesao.titdescjur <> 0
    then do:
        if medadesao.titdescjur > 0
        then do:
                message color normal 
            "juros calculado em" medadesao.dtinc "de R$" trim(string(medadesao.titvljur + medadesao.titdescjur,">>>>>>>>>>>>>>>>>9.99"))    
            " dispensa de juros de R$"  trim(string(medadesao.titdescjur,">>>>>>>>>>>>>>>>>9.99")).
        end.
        else do:
            message color normal 
            "juros calculado em" medadesao.dtinc "de R$" trim(string(medadesao.titvljur + medadesao.titdescjur,">>>>>>>>>>>>>>>>>9.99"))    

            " juros cobrados a maior R$"  trim(string(medadesao.titdescjur * -1 ,">>>>>>>>>>>>>>>>>9.99")).
        
        end.
        
    end.
    */    
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
        vhelp = "".
        
        
        status default vhelp.
        choose field medadesao.idAdesao
                      help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      L l
                      tab PF4 F4 ESC return).

        if keyfunction(lastkey) <> "return"
        then run color-normal.

        hide message no-pause.
                 
        pause 0. 

                                                                
            if keyfunction(lastkey) = "cursor-right"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 6 then 6 else esqpos1 + 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail ttadesao
                    then leave.
                    recatu1 = recid(ttadesao).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttadesao
                    then leave.
                    recatu1 = recid(ttadesao).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttadesao
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttadesao
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            
            
             if esqcom1[esqpos1] = "cancela"
             then do: 
                hide message no-pause.
                sresp = no.
                    message "este procedimento nao esta fazendo chamada a api de cancelamento, apenas cancela no admcom"
                        view-as alert-box. 
                
                message "Confirma cancelamento adesao numero " medadesao.idadesao "?"
                    update sresp.
                if sresp
                then do:
                    /* HELIO 21032024 cancela adesao por api, desativado
                    *run api/medcancelaadesao.p (recid(medadesao)).
                    */
                    run med/cancelaadesao.p (recid(medadesao)). /* cancela direto */
                    leave.
                end.
            end.
             if esqcom1[esqpos1] = " csv "
             then do: 
                run geraCSV.
            end.
             if esqcom1[esqpos1] = " csv 2 "
             then do: 
                run geracsv2.
            end.
            
            
            if esqcom1[esqpos1] = "conteudo"
            then do:
                pause 0.
                run med/tmedadedados.p (recid(medadesao)).

                disp 
                    ctitle 
                        with frame ftit.
                
            end.
            if esqcom1[esqpos1] = "repasses"
            then do:
                pause 0.
                run med/tmedaderepasse.p (recid(medadesao)).

                disp 
                    ctitle 
                        with frame ftit.
                
            end.

            if esqcom1[esqpos1] = "historico"
            then do:
                pause 0.
                run  med/tmedadecanc.p (recid(medadesao)).

                disp 
                    ctitle 
                        with frame ftit.
                
            end.
        end.        
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttadesao).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame ftit no-pause.
hide frame ftot no-pause.
return.
 
procedure frame-a.
    find medadesao where recid(medadesao) = ttadesao.rec no-lock.
    find first medadedados of medadesao where medadedados.idcampo = "proposta.cliente.nome" no-lock no-error.
    vclinom = if avail medadedados then medadedados.conteudo else "-".
    display  
        vclinom
        medadesao.cpf  

        medadesao.idAdesao
        medadesao.valorServico 
        medadesao.dataTransacao
        medadesao.contnum        when contnum <> 0
        medadesao.dtcanc  
        medadesao.etbcod


        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        vclinom
        medadesao.cpf  

        medadesao.idAdesao
        medadesao.valorServico 
        medadesao.dataTransacao
        
        medadesao.dtcanc  
        medadesao.etbcod
        medadesao.contnum        


                    
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        vclinom
        medadesao.cpf  

        medadesao.idAdesao
        medadesao.valorServico 
        medadesao.dataTransacao
        
        medadesao.dtcanc  
        medadesao.etbcod
        medadesao.contnum        

                     
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        vclinom
        medadesao.cpf  

        medadesao.idAdesao
        medadesao.valorServico 
        medadesao.dataTransacao
        
        medadesao.dtcanc  
        medadesao.etbcod

        medadesao.contnum        
 
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.

    if par-tipo = "pri" 
    then do:
        find last ttadesao 
            no-lock no-error.
    end.    
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        find prev ttadesao 
            no-lock no-error.
    end.    
             
    if par-tipo = "up" 
    then do:
        find next ttadesao
            no-lock no-error.

    end.  
        
end procedure.







procedure geraCSV.
def var pordem as int.
 
def var varqcsv as char format "x(65)".
    varqcsv = "/admcom/relat/medadesao_" + lc(psituacao) + "_" + 
                string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".csv".
    
    
    disp varqcsv no-label colon 12
                            with side-labels width 80 frame f1
                            row 15 title "csv protestos ativos"
                            overlay.


message "Aguarde...". 
pause 1 no-message.

output to value(varqcsv).

put unformatted 
        "CPF PACIENTE;NOME PACIENTE;CPF CLIENTE LEBES;NOME CLIENTE LEBES;NUMERO_CONTRATO;DATA VENDA;DATA INICIO VIGENCIA;DATA FIM VIGENCIA;PLANO PGTO;STATUS VENDA;"   
        "DATA CANCELAMENTO;CERTIFICADO;LOJA;VALOR VENDA;VALOR REPASSE;VENDEDOR;PDV;NSU;" /* helio 06122023 563918 */
        skip.
    for each ttadesao.
        find medadesao where recid(medadesao) = ttadesao.rec no-lock.
        run geraCsvImp.
    end.  


output close.

        hide message no-pause.
        message "Arquivo csv gerado " varqcsv.
        hide frame f1 no-pause.
        pause.    
end procedure.

procedure geraCsvImp.
def var vlrcobradocustas as dec.
def var vlrcobrado as dec.
def var vcp as char init ";".

        
def var vnomecliente    as char.        
def var vnomepaciente   as char.
def var vstatus         as char.
def var vvlrrepasse     as dec.
def var vvendedor       as char.
def var vcxacod         as int.
def var vdtinivig       as date.
def var vdtfimvig       as date.

    find medadedados of medadesao where medadedados.idcampo = "proposta.dataInicioVigencia" no-lock no-error.
    vdtinivig   = if avail medadedados 
        then date(int(entry(2,medadedados.conteudo,"-")), int(entry(3,medadedados.conteudo,"-")),int(entry(1,medadedados.conteudo,"-")))
        else ?.
    find medadedados of medadesao where medadedados.idcampo = "proposta.dataFimVigencia" no-lock no-error.
    vdtfimvig   = if avail medadedados 
        then date(int(entry(2,medadedados.conteudo,"-")), int(entry(3,medadedados.conteudo,"-")),int(entry(1,medadedados.conteudo,"-")))
        else ?.

    find medadedados of medadesao where medadedados.idcampo = "proposta.cliente.nome" no-lock no-error.
    vnomepaciente   = if avail medadedados then medadedados.conteudo else "".

    release clien.
    if medadesao.clicod <> 0 and medadesao.clicod <> ?
    then do:
        find clien where clien.clicod = medadesao.clicod no-lock no-error.    
    end.        
    vnomecliente =  if avail clien then clien.clinom else vnomepaciente.
    
    vstatus = if medadesao.dtcanc = ? then "ATIVA" else if medadesao.dtcanc - medadesao.datatransacao <= 8 then "ANULADO" else "CANCELADA". 
    
    find medadedados of medadesao where medadedados.idcampo = "proposta.codigoVendedor" no-lock no-error.
    vvendedor = (if avail medadedados then medadedados.conteudo else "") + "-" .
    if avail medadedados
    then do:
        find func where func.etbcod = medadesao.etbcod and func.funcod = int(medadedados.conteudo) no-lock no-error.
        if avail func then vvendedor = vvendedor + func.funnom.
    end.
    find cmon of medadesao no-lock no-error.
    vcxacod = if avail cmon then cmon.cxacod else 0.

    /*****
    /* helio 06122023 */
    vnomecliente = vnomepaciente. 
    release bclien.
    find contrato of medadesao no-lock no-error.
    if avail contrato
    then do:
        find bclien of contrato no-lock.
        vnomecliente = if avail bclien then bclien.clinom  else "".
    end.
    ***/
    
    put unformatted 
        string(medadesao.cpf,"99999999999")       vcp
        vnomepaciente   vcp
        /* helio 06122023 */
        if avail clien then clien.ciccgc  else ""     vcp
        vnomecliente    vcp
        medadesao.contnum vcp
        string(medadesao.dataTransacao,"99/99/9999") vcp
        if vdtinivig = ? then "" else string(vdtinivig,"99/99/9999")       vcp
        if vdtfimvig = ? then "" else string(vdtfimvig,"99/99/9999")       vcp
        medadesao.fincod         vcp
        vstatus         vcp
        if medadesao.dtcanc = ? then "" else string(medadesao.dtcanc,"99/99/9999") vcp
        medadesao.idAdesao vcp
        medadesao.etbcod            vcp
        
        trim(replace(string(medadesao.valorServico,"->>>>>>>>>>>>>>>>>>>>>>9.99"),".",","))      vcp
        trim(replace(string(vvlrrepasse,"->>>>>>>>>>>>>>>>>>>>>>9.99"),".",","))                 vcp
        
        vvendedor                   vcp
        vcxacod                    vcp
        medadesao.nsuTransacao      vcp
        skip.
            

end procedure.
 



procedure montatt.

    if psituacao = "VENDAS" or psituacao = "CSV2"
    then do:
        for each medadesao where  medadesao.dataTransacao >= vdtini and
                                  medadesao.dataTransacao <= vdtfim
            no-lock.
            create ttadesao.
            ttadesao.rec = recid(medadesao).
        end.    
    end.
    if psituacao = "CANCELAMENTOS"
    then do:
       for each medadesao where  medadesao.dtcanc >= vdtini and
                                 medadesao.dtcanc<= vdtfim
                no-lock.
                create ttadesao.
                ttadesao.rec = recid(medadesao).
        end.                                                    
    end.    
    if psituacao = "CLIENTE"
    then do:    
        for each medadesao where medadesao.cpf   = pcpf       
            no-lock. 
            create ttadesao. 
            ttadesao.rec = recid(medadesao).
        end.    
    end.    

end procedure.


procedure geraCSV2.
def var pordem as int.
 
def var varqcsv as char format "x(65)".
    varqcsv = "/admcom/relat/medadesao2_" + lc(psituacao) + "_" + 
                string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".csv".
    
/*    
    disp varqcsv no-label colon 12
                            with side-labels width 80 frame f1
                            row 15 title "csv protestos ativos"
                            overlay.
*/
if psituacao <> "CSV2"
then do:
    message "Aguarde...". 
    pause 1 no-message.
end.

output to value(varqcsv).

put unformatted 
"ID_CONTRATO_PLANO;ID_BENEFICIARIO_TIPO;NOME;CODIGO_EXTERNO;ID_CLIENTE;CPF_TITULAR;CPF;"
"RG;DATA_NASCIMENTO;SEXO;ESTADO_CIVIL;NOME_MAE;TELEFONE_FIXO;TELEFONE_COMERCIAL;CELULAR;EMAIL;CEP;LOGRADOURO;NUMERO;COMPLEMENTO;BAIRRO;CIDADE;UF;"
"TIPO_PLANO;TIPO_OPERACAO;DATA_ADESAO;CAP_NUM_SERIE;CAP_NUM_SORTE;DATA_FIM_VIGENCIA"
skip.
    for each ttadesao.
        find medadesao where recid(medadesao) = ttadesao.rec no-lock.
        run geraCsvImp2.
    end.  

output close.
if psituacao <> "CSV2"
then do:
        hide message no-pause.
        message "Arquivo csv gerado " varqcsv.
        hide frame f1 no-pause.
        pause.    
end.        
end procedure.

procedure geraCsvImp2.
def var vlrcobradocustas as dec.
def var vlrcobrado as dec.
def var vcp as char init ";".

        
def var vnomecliente    as char.        
def var vnomepaciente   as char.
def var vstatus         as char.
def var vvlrrepasse     as dec.
def var vvendedor       as char.
def var vcxacod         as int.
def var vdtinivig       as date.
def var vdtfimvig       as date.
def var vtipoplano as char.
def var vcelular as char.
def var vdtnasc as char.
def var vgenero as char.
def var         vemail as char.
def var         vcep as char.
def var         vrua as char.
def var         vnumero as char.
def var         vcompl as char.
def var         vbairro as char.
def var         vcidade as char.
def var         vuf as char.

    find medadedados of medadesao where medadedados.idcampo = "proposta.dataInicioVigencia" no-lock no-error.
    vdtinivig   = if avail medadedados 
        then date(int(entry(2,medadedados.conteudo,"-")), int(entry(3,medadedados.conteudo,"-")),int(entry(1,medadedados.conteudo,"-")))
        else ?.
    find medadedados of medadesao where medadedados.idcampo = "proposta.dataFimVigencia" no-lock no-error.
    vdtfimvig   = if avail medadedados 
        then date(int(entry(2,medadedados.conteudo,"-")), int(entry(3,medadedados.conteudo,"-")),int(entry(1,medadedados.conteudo,"-")))
        else ?.

    find medadedados of medadesao where medadedados.idcampo = "proposta.cliente.nome" no-lock no-error.
    vnomepaciente   = if avail medadedados then medadedados.conteudo else "".

    release clien.
    if medadesao.clicod <> 0 and medadesao.clicod <> ?
    then do:
        find clien where clien.clicod = medadesao.clicod no-lock no-error.    
    end.        
    vnomecliente =  if avail clien then clien.clinom else vnomepaciente.
    
    vstatus = if medadesao.dtcanc = ? then "ATIVA" else if medadesao.dtcanc - medadesao.datatransacao <= 8 then "ANULADO" else "CANCELADA". 
    
    find medadedados of medadesao where medadedados.idcampo = "proposta.codigoVendedor" no-lock no-error.
    vvendedor = (if avail medadedados then medadedados.conteudo else "") + "-" .
    if avail medadedados
    then do:
        find func where func.etbcod = medadesao.etbcod and func.funcod = int(medadedados.conteudo) no-lock no-error.
        if avail func then vvendedor = vvendedor + func.funnom.
    end.
    find cmon of medadesao no-lock no-error.
    vcxacod = if avail cmon then cmon.cxacod else 0.

    /*****
    /* helio 06122023 */
    vnomecliente = vnomepaciente. 
    release bclien.
    find contrato of medadesao no-lock no-error.
    if avail contrato
    then do:
        find bclien of contrato no-lock.
        vnomecliente = if avail bclien then bclien.clinom  else "".
    end.
    ***/

    vtipoplano = "101530".
    if medadesao.idmedico = "DOC24_57" then vtipoplano = "101299".
    if medadesao.idmedico = "DOC24_58" then vtipoplano = "101300".

    find medadedados of medadesao where medadedados.idcampo = "proposta.cliente.dataNascimento" no-lock no-error.
    vdtnasc  = if avail medadedados then medadedados.conteudo else "".
    find medadedados of medadesao where medadedados.idcampo = "proposta.cliente.genero" no-lock no-error.
    vgenero  = if avail medadedados then medadedados.conteudo else "".

    find medadedados of medadesao where medadedados.idcampo = "proposta.cliente.celular" no-lock no-error.
    vcelular   = if avail medadedados then medadedados.conteudo else "".
    find medadedados of medadesao where medadedados.idcampo = "proposta.cliente.email" no-lock no-error.
    vemail  = if avail medadedados then medadedados.conteudo else "".
    find medadedados of medadesao where medadedados.idcampo = "proposta.cliente.endereco.cep" no-lock no-error.
    vcep   = if avail medadedados then medadedados.conteudo else "".
    find medadedados of medadesao where medadedados.idcampo = "proposta.cliente.endereco.rua" no-lock no-error.
    vrua   = if avail medadedados then medadedados.conteudo else "".
    find medadedados of medadesao where medadedados.idcampo = "proposta.cliente.endereco.numero" no-lock no-error.
    vnumero   = if avail medadedados then medadedados.conteudo else "".
    find medadedados of medadesao where medadedados.idcampo = "proposta.cliente.endereco.complemento" no-lock no-error.
    vcompl   = if avail medadedados then medadedados.conteudo else "".
    find medadedados of medadesao where medadedados.idcampo = "proposta.cliente.endereco.bairro" no-lock no-error.
    vbairro  = if avail medadedados then medadedados.conteudo else "".
    find medadedados of medadesao where medadedados.idcampo = "proposta.cliente.endereco.cidade" no-lock no-error.
    vcidade   = if avail medadedados then medadedados.conteudo else "".
    find medadedados of medadesao where medadedados.idcampo = "proposta.cliente.endereco.uf" no-lock no-error.
    vuf   = if avail medadedados then medadedados.conteudo else "".
    
                
    put unformatted 
        "100578037;" /* ID_CONTRATO_PLANO */
        "1;"        /* ID_BENEFICIARIO_TIPO */
        vnomepaciente    vcp    /* NOME*/
        ";"
        "10159;"
        string(medadesao.cpf,"99999999999")       vcp
        ";"
        ";"
        vdtnasc vcp
        vgenero vcp
        ";"
        ";"
        ";"
        ";"
        vcelular vcp
        vemail vcp
        vcep vcp
        vrua vcp
        vnumero vcp
        vcompl vcp
        vbairro vcp
        vcidade vcp
        vuf vcp
        vtipoplano vcp
        if medadesao.dtcanc = ? then "ADESAO" else "CANCELAMENTO" vcp
        string(medadesao.dataTransacao,"99/99/9999") vcp
        ";"
        ";"
        if vdtfimvig = ? then "" else string(vdtfimvig,"99/99/9999")       vcp
        skip.        
        

end procedure.
 


