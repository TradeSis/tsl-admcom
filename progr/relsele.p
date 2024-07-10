/****************************** Programa : RelClien.p
** Data ....: 07/05/1999
** Autor ...: Andre Baldini
** Descricao: Relatorio de Clientes por Loja
****************************/

{admcab.i }.
{anset.i}.

def buffer ctitulo      for titulo.
def buffer bplani       for plani.
def var v-funcod        like func.funcod.
def var v-compras       as dec.
def var v-totcmp        as dec.
def var v-ok            as log.
def var v-senha         like func.senha.
def buffer btitulo      for titulo.
def var bestab          like estab.etbcod.    
def var vd              as log.  
def var d               as date.
def var vp              as dec.
def var vdias           as int.
def var v-etbcod        like estab.etbcod.
def var v-param1        as int format ">>9" label "Ultima Compra(em Dias)".
def var v-param2        as int format ">>9" label "Maximo Dias Atraso". 
def var v-param3        as log format "Sim/Nao" label "Pode Estar no SPC".
def var v-param4        as dec format ">>9.99" label "Limite de Compras".
def var v-param5        as dec format ">,>>9.99" label "Media p/Valor". 
def var v-param6        like produ.procod label "Codigo Classe".
def var v-param7        like plani.pladat label "Dt.Aniv Inic".
def var v-param8        like plani.pladat label "Dt.Aniv Final".
def var v-param9        as int label "Sexo" format "9" initial 3.
def var snomcaixa       like estab.etbnom.
def var varqsai         as char.

form
    v-param1            colon 25
        help "Informe a Quantid de Dias desde Ultima Compra, 0 = Hoje"
    skip
    v-param2            colon 25
        help "Informe o Maximo de Media de Atraso, 0 = Nunca Atrasou"
    skip
    v-param3            colon 25
        help "Informe se o Cliente pode estar no SPC"
    skip
    v-param4            colon 25
        help "Informe o Minimo de Compras do Cliente, 0 = Nenhuma"
    skip
    v-param5            colon 25
        help "Informe a Media de Compra por Cupom , 0 = Todos"
    skip
    v-param6            colon 25
    skip
    v-param7            colon 25
    skip
    v-param8            colon 25
    skip
    v-param9            colon 25
    help "Informe o Sexo 1=Masculino 2=Feminino 0 = Todos"    with frame f-param
        centered
        title " DADOS PARA PESQUISA "
        1 down 
        side-labels.

def var vlidos as int label "Clientes Pesquisados".
def var vselec as int label "Clientes Selecionados".
def var vnaoclasse as int label "Descartados pela Classe".
def var vnaocompras as int label "Descartados pelas Compras".                   
def var vnaomedia as int label "Descartados pela Media Cmp".
def var vnaoatraso as int label "Descartados pelo Atraso".


def temp-table ttclien
    field clicod like clien.clicod
    field clinom like clien.clinom
    index nome clinom.
    
form
    ttclien.clicod
    ttclien.clinom format "x(32)" 
        help "F4=Encerra   F8=Imprime " 
    with frame f-clien
        down
        title " CLIENTES SELECIONADOS "
        centered.

form
    bestab 
    estab.etbnom no-label
    with frame f-estab
        centered
        1 down side-labels.

form
    clien.clicod
    clien.clinom format "x(38)" 
    clien.endereco[1] format "x(33)" 
    clien.numero[1]
    clien.compl[1]
    clien.cep[1]
    clien.cidade[1] format "x(18)"  column-label  "Cidade" 
    clien.fone   column-label "Fone" 
    with frame f-implin
        down
        width 150
        centered
        no-box.

form
    v-funcod
    v-senha
    with frame f-mat
        centered
        overlay
        title " FUNCIONARIO "
        1 down
        side-labels.

repeat :
    vnaomedia = 0. vnaoclasse = 0. vnaocompras = 0.
    vnaoatraso = 0. vlidos = 0. vselec = 0.
    clear frame f-estab all.
    hide frame f-estab.
    clear frame f-param all.
    hide frame f-param.
    clear frame f-mat all.
    hide frame f-mat.
        
    sfuncod = 48.

    find first func where func.funcod = sfuncod no-error.
    if not avail func
    then do :
        bell. bell.
        message "Matricula incorreta ".
        pause. clear frame f-mat all.
        next.
    end.
        
    update bestab with frame f-estab.
    if bestab <> 0
    then do:
       find first estab where estab.etbcod = bestab
                       no-error.
       if not avail estab
       then  do :
           bell. message "Estabelecimento digitado invalido".
           pause. clear frame f-estab all.
           next.
       end.
       disp estab.etbnom with frame f-estab.
    end.
       else disp "Todas as Lojas" with frame f-estab.
 
    v-param7 = ?.
    v-param8 = ?.
    update 
        v-param1
        v-param2
        v-param3
        v-param4
        v-param5
        v-param6
        v-param7
        v-param8
        v-param9
        with frame f-param.

    if v-param1 <= 0 and
       v-param2 <= 0
    then do :
        bell. bell. message "Dados para Pesquisa invalidos".
        pause. clear frame f-param all.
        next.
    end.
       
    if v-param7 <> ?  and v-param8 <> ? and
       v-param7 > v-param8
    then do :
        bell. bell. message "Datas de Aniversario informadas invalidas".
        pause. clear frame f-param all.
        next.
    end.    
    clear frame f-param all.
    hide frame f-param.

    for each ttclien :
        delete ttclien.
    end.    

    do d = (today - v-param1) to today : 
        for each plani where plani.datexp = d 
                         and plani.etbcod = (if bestab = 0 
                                             then plani.etbcod
                                             else bestab)
                         and plani.movtdc = 5 
                         and plani.desti <> 1 
                       no-lock.
            find first clien where clien.clicod = plani.desti no-lock no-error.
            if not avail clien then next.
            
            find first contnf where contnf.etbcod = plani.etbcod
                               and contnf.placod = plani.placod
                             no-lock no-error.
            find first contrato where contrato.contnum = contnf.contnum
                                no-lock no-error.
                           
            for each titulo where titulo.etbcod = plani.etbcod
                              and titulo.clifor = plani.desti
                              and titulo.empcod = 19
                              and titulo.titnum = string(contrato.contnum)
                              and titulo.titnat = no
                            no-lock: 
    
                disp titulo.titnum titulo.titpar with 1 down
                     centered row 19 no-labels overlay. pause 0.

                vlidos = vlidos + 1.        
         
                disp vlidos with frame f-mostr. pause 0.        
                    
                if v-param9 = 1 and clien.sexo = no
                then next.
        
                if v-param9 = 2 and clien.sexo = yes
                then next.
        
                find first ttclien where ttclien.clicod = clien.clicod 
                                   no-error.
                if avail ttclien
                then next.
        
                disp 
                    "          Aguarde, Gerando Consulta e Relatorio ..... "
                    clien.clinom   no-label colon 20 skip
                    vlidos          colon 35 skip                    
                    vselec          colon 35  
                    (vselec * 100 / vlidos) format ">>9.99%" no-label  skip
                    vnaoatraso      colon 35 skip
                    vnaocompras     colon 35 skip
                    vnaomedia       colon 35 skip
                    vnaoclasse      colon 35
                    with frame f-mostr  
                        centered 1 down side-labels row 8 overlay. pause 0.
                            
                assign vd = no vdias = 0. 
                for each btitulo where btitulo.titnat = no and
                              btitulo.clifor = clien.clicod and
                                  btitulo.titsit = "PAG" no-lock.
                    vdias = btitulo.titdtpag - btitulo.titdtven.
                    if vdias > v-param2 
                    then do :
                        vd = yes.
                    end.
                end.
        
                if vd = yes 
                then do :
                    vnaoatraso = vnaoatraso + 1.
                    next.     
                end.        
        
                v-compras = 0.
                v-totcmp = 0.
                if v-param6 > 0 
                then v-ok = no. 
                else v-ok = yes.

                for each bplani where bplani.desti = clien.clicod 
                                 and bplani.movtdc = 5 
                               no-lock :
                    if v-param6 > 0 
                    then do :
                        for each movim where movim.etbcod = bplani.etbcod
                                     and movim.placod = bplani.placod 
                                       no-lock : 
                            find first produ where produ.procod = movim.procod 
                                         no-error.
                            if v-param6 = produ.clacod 
                            then do : 
                                v-ok = yes.
                                leave.
                            end.        
                        end.
                    end.        
                    v-compras = v-compras + 1.
                    v-totcmp = v-totcmp + bplani.platot.
                end.    
                if v-ok = no 
                then do :
                    vnaoclasse = vnaoclasse + 1.
                    pause 0.  next. 
                end.        
              
                if v-param4 > v-compras
                then do :
                    vnaocompras = vnaocompras + 1.
                    pause 0.  next.
                end.

                if v-param5 > (v-totcmp / v-compras)
                then do :
                    vnaomedia = vnaomedia + 1.
                    pause 0. next.
                end.    

                if v-param7 <> ? and v-param8 <> ? 
                then do :
                    if clien.dtnasc < v-param7 and
                       clien.dtnasc > v-param8 
                    then do :
                        next.
                    end.    
                end.       
        
                find first ttclien where 
                           ttclien.clicod = clien.clicod no-error.
                if not avail ttclien
                then do :
                    create ttclien.
                    ttclien.clicod = clien.clicod.
                    ttclien.clinom = clien.clinom.
                end. 
                vselec = vselec + 1.
                pause 0.    
            end.      
        end.
    end.
    
    hide frame f-mostr.   
      
    assign
        an-seeid = -1
        an-recid = -1
        an-seerec = ?.
    
    {anbrowse.i
        &file = ttclien
        &CField = ttclien.clinom
        &Ofield = "ttclien.clicod clien.fone " 
        &Where = " true"
        &AftSelect1 = " next keys-loop. " 
        &AftFnd = " find first clien where clien.clicod = ttclien.clicod
                                no-error. " 
        &Otherkeys1 = "relclien.ok" 
        &Form = " frame f-clien " 
    }.
end.                                
                   
                     
    
