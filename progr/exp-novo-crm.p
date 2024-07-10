/*
#1 Projeto Rigth Now - Ricardo - 31.07.18
*/

{/admcom/progr/admcab-batch.i}
{/admcom/progr/def-var-bsi-qvexp.i}

FUNCTION f-trata returns character
    (input cpo as char).
    
    if cpo = ?
    then cpo = "".
    else do:
         cpo = replace(cpo,"@","").
         cpo = replace(cpo,";","").
         cpo = replace(cpo,",","").
         cpo = replace(cpo,".","").
         cpo = replace(cpo,"*","").
         cpo = replace(cpo,"/","").
         cpo = replace(cpo,"\\","").
         cpo = replace(cpo,"-","").
         cpo = replace(cpo,">","").
         cpo = replace(cpo,"<","").
         cpo = replace(cpo,"!","").
         cpo = replace(cpo,"~~","").
         cpo = replace(cpo,"#","").
         cpo = replace(cpo,"$","").
         cpo = replace(cpo,"%","").
         cpo = replace(cpo,"¨","").
         cpo = replace(cpo,"&","").
         cpo = replace(cpo,"[","").
         cpo = replace(cpo,"]","").
         cpo = replace(cpo,"ª","").
         cpo = replace(cpo,"º","").
         cpo = replace(cpo,"á","a").
         cpo = replace(cpo,"à","a").
         cpo = replace(cpo,"ã","a").
         cpo = replace(cpo,"â","a").
         cpo = replace(cpo,"é","e").
         cpo = replace(cpo,"ê","e").
         cpo = replace(cpo,"í","i").
         cpo = replace(cpo,"ó","o").
         cpo = replace(cpo,"ô","o").
         cpo = replace(cpo,"õ","o").
         cpo = replace(cpo,"ú","u").
         cpo = replace(cpo,"ü","u").
         cpo = replace(cpo,"ç","c").
         cpo = replace(cpo,"Á","A").
         cpo = replace(cpo,"À","A").
         cpo = replace(cpo,"Ã","A").
         cpo = replace(cpo,"Â","A").
         cpo = replace(cpo,"É","E").
         cpo = replace(cpo,"Ê","E").
         cpo = replace(cpo,"Í","I").
         cpo = replace(cpo,"Ó","O").
         cpo = replace(cpo,"Ô","O").
         cpo = replace(cpo,"Õ","O").
         cpo = replace(cpo,"Ú","U").
         cpo = replace(cpo,"Ü","U").
         cpo = replace(cpo,"Ç","C").
    end.

    /*** Jan.2017  TP 16928496 ***/
    def var mletrade   as int  extent 6 init [199, 195, 138, 142, 166, 186].
    def var mletrapara as char extent 6 init ["C", "A", "C", "A", "A", "O"].
    def var vtexto as char.
    def var vletra as char.
    def var vct    as int.
    def var vi     as int.

    do vi = 1 to length(cpo).
        vletra = substring(cpo, vi, 1).
        if asc(vletra) > 127
        then
            do vct = 1 to 6.
                if asc(vletra) = mletrade[vct]
                then vletra = mletrapara[vct].
            end.

            if length(vletra) = 1 and
               asc(vletra) >  31 and
               asc(vletra) < 127
            then vtexto = vtexto + vletra.
    end.
     
    return vtexto.
     
end FUNCTION.


FUNCTION f-limpa-email returns character
    (input cpo as char).
    
     def var vret as char.
        
     if cpo = ?
     then cpo = "".
     else do:
         cpo = replace(cpo,";","").
         cpo = replace(cpo,"*","").
         cpo = replace(cpo,"/","").
         cpo = replace(cpo,"\\","").
         cpo = replace(cpo,"%","").
     end.
     
     return cpo.
     
end FUNCTION.




def stream debug .

def stream control-cli.

def buffer b2-clien for clien.

if today < 09/06/2016
then assign v-gera-carga-clientes-full = yes.

def temp-table tt-controle
    field clicod as integer
    index idx01 clicod.

def var vgera-log as logical.
def var vconta-cli as integer.
def var i as int.
def var vsp as char init ";".
def var vcep         as char.

def stream clien.
def stream filial.
def stream int_compra.

def temp-table tt-titulo like fin.titulo
    index idx_dtven clifor titdtven
    index idx_titsit clifor titsit
    index idx_dtpag clifor titsit titdtpag.

def buffer bf2-estab for estab.
def buffer bf3-plani for plani.
def buffer bf3-estab for estab.

def var vidade as int.

def var vint-total-dias-atraso as int.
def var vdat-maior-atraso-aux as date.
def var vcalclim         as dec.
def var vpardias         as dec. 
def var limite-total      as dec.
def var limite-disponivel as dec.

def new shared temp-table tt-dados
    field parametro as char
    field valor     as dec
    field valoralt  as dec
    field percent   as dec
    field vcalclim  as dec
    field operacao  as char format "x(1)" column-label ""
    field numseq    as int
    index dado1 numseq.
    
def buffer btt-dados for tt-dados.

/*
cod_estab   nome_estab  endereco    bairro  municipio   fone

*/

def temp-table tt-filial
    field etbcod like estab.etbcod
    field etbnom like estab.etbnom
    field endereco like estab.endereco
    field bairro as char
    field munic like estab.munic
    field etbserie like estab.etbserie.

def temp-table tt-cli
    field tt-01 as integer               
    field clicod    like clien.clicod   
    field clinom like clien.clinom      
    field dtnasc    as date                 
    field idade-fx as char
 /* field depen  as char */              
    field tem-cel as char                
    field sexo as character                
  /*field spc    as char */              
    field estciv as char                 
    field cidade as char      
    field prof   as   char               
    field tem-celular as char
    field celular as char format "x(30)" 
    field rua as char                    
    field num as char                    
    field cep as char                    
    field compl   as char                
    field bairro  as char                      
    field ufecod      as char format "x(2)"    
  /*field mesaniver as int */                  
    field limite      as dec                        
    field renda       as dec                    
    field email       as char                     
  /*field residencia        as char */                
  /*field tem-carro         as char */                 
    field cpf               as char
    field rg_ie             as char
    field data_cadastro     as date
    field limite-disp       as dec
    field fone-resid        as char format "x(30)"
    field spc-lebes         as char
    field status_contratos  as char
    field dt_quit_ult_contrato as char
    field pontualidade      as char
    field conjuge_nome      as char
    field conjuge_cpf       as char
    field conjuge_dt_nasc   as char
    field datexp            as date
    field nome_pai          like clien.pai
    field nome_mae          like clien.mae
    field etbcad            as int  
       index iclicod is primary unique clicod
       index icpf cpf.

def temp-table tt-intven
    field etbcod like estab.etbcod
    field clacod like clase.clacod
    field clicod like clien.clicod
    field peddat like pedid.peddat
    field peddti like pedid.peddti
    field qtdint like liped.lipqtd
    field vencod like pedid.vencod
          index i1 etbcod clacod clicod peddti.
                                
def var vdt         as date.
def var qtd-abaixo-15 as integer.
def var qtd-entre-16-45 as integer.
def var qtd-acima-46 as integer.
def var vtime as char.

assign vexecucao-crm-menu = false.

if program-name(2) matches("*exp_crm2*")
then assign vexecucao-crm-menu = true.

run p-carrega-tt-controle.

assign vtime = string(time,"HH:MM:SS").
assign vtime = replace(vtime,":","-").

assign vtime = string(year(today),"9999")
                 + "-" + string(month(today),"99")
                 + "-" + string(day(today),"99")
                 + "-" + vtime.

output stream debug to value(vdirsaida + "debug-cli-" + vtime + ".csv").

output stream control-cli to value(vdirsaida + "controle-cli-exp.csv") append.

assign vgera-log = yes
       vconta-cli = 0.

if not vexecucao-crm-menu
then assign vdtini = today - 3
            vdtfim = today.

    if v-gera-filiais
    then run p-gera-estab.

    if v-gera-int-compra
    then run p-gera-intven.
                      
    if v-gera-clientes
    then run p-gera-clientes-crm.
                      
    run p-gera-arquivos.


procedure p-gera-estab:

    if vexecucao-crm-menu
    then display "Exportando Filiais " colon 8
                 string(time,"HH:MM:SS") colon 60
                      with frame f-cli no-box side-label.

    for each estab where (estab.tipoLoja = "Normal" or
                          estab.tipoLoja = "Outlet" or
                          estab.tipoLoja = "E-commerce") no-lock  .
    
        find first tabaux
             where tabaux.tabela = "ESTAB-" + string(estab.etbcod,"999")
               and tabaux.nome_campo = "BAIRRO" no-lock no-error.
        
        create tt-filial.
        assign tt-filial.etbcod   = estab.etbcod
               tt-filial.etbnom   = estab.etbnom
               tt-filial.endereco = estab.endereco
               tt-filial.munic    = estab.munic
               tt-filial.etbserie = estab.etbserie.

        if avail tabaux
        then tt-filial.bairro = tabaux.valor_campo.
        else tt-filial.bairro = "".
    end.

end procedure.


procedure p-gera-intven:

    if vexecucao-crm-menu
    then display "Exportando Intencoes de Compra " colon 8
                 string(time,"HH:MM:SS") colon 60
                        with frame f-cli no-box side-label.

    for each estab where (estab.tipoLoja = "Normal" or
                          estab.tipoLoja = "Outlet" or
                          estab.tipoLoja = "E-commerce") no-lock,
    
        each pedid where pedid.pedtdc = 21 and
                         pedid.etbcod = estab.etbcod and
                         pedid.peddat >= vdtini and
                         pedid.peddat <= vdtfim
                         no-lock,
        
        each liped of pedid no-lock:
        
        find first tt-intven where tt-intven.etbcod = pedid.etbcod and
                   tt-intven.clacod = liped.procod and
                   tt-intven.clicod = pedid.clfcod and
                   tt-intven.peddti = pedid.peddti no-lock no-error.
        if not avail tt-intven
        then do:
            create tt-intven.
            assign tt-intven.etbcod = pedid.etbcod
                   tt-intven.clacod = liped.procod
                   tt-intven.clicod = pedid.clfcod
                   tt-intven.peddti = pedid.peddti
                   tt-intven.vencod = pedid.vencod
                                        .
        end.
        assign tt-intven.peddat = pedid.peddat
               tt-intven.qtdint = tt-intven.qtdint + 1.
    end.

end procedure.


procedure p-gera-clientes-crm:

def var voper as char format "x(40)".
def var vhora as char.
def buffer bclispc for clispc.

form
    voper
    vdt
    vhora colon 60
    with frame f-cli no-box no-label down.
    
if v-gera-carga-clientes-full
then do:
        put stream debug unformatted
           skip(3)
           "======== GERAÇÃO DE CARGA COMPLETA DE CLIENTES ====== "
           skip .
        
        if vexecucao-crm-menu
        then display vdt label "Exportando Carga Completa de Clientes" colon 43
                        with frame f-cli-carga no-box side-label.      
                        
        for each clien no-lock:
            message. pause 0.
            
            run pre-geracao.
            
            if vconta-cli >= 500000
            then leave.
        end.
        
        output stream debug close.
end.
else do:          
    put stream debug unformatted
       skip(3)
       "======== ATUALIZACAO DE CLIENTES COM DATA DE ALTERAÇÃO RECENTE ====== "
       skip .

    do vdt = vdtini to vdtfim:
        if vexecucao-crm-menu
        then do:
            display "Exportando Clientes alterados em" @ voper
                    vdt
                    string(time,"HH:MM:SS") @ vhora
                    with frame f-cli.
            down 1 with frame f-cli.
        end.

        if vgera-log then
            put stream debug
            skip
            "##################################"
            "   FASE 1  -  Exporta Clientes alterados nos últimos dias  "
            "##################################   "
            "Hora: " string(time,"HH:MM:SS").
        
        /* Exporta Clientes alterados nos últimos dias */            
        for each clien where clien.datexp = vdt no-lock:
            message. pause 0.
            run pre-geracao.
        end.

        if vexecucao-crm-menu
        then do.
            display "Exportando Clientes que comparam em" @ voper
                    vdt
                    string(time,"HH:MM:SS") @ vhora
                    with frame f-cli.
            down 1 with frame f-cli.
        end.            

        if vgera-log
        then put stream debug
            skip
            "##################################"
            "   FASE 2  -  Exporta Clientes que compraram nos últimos dias  "
            "##################################   "
            "Hora: " string(time,"HH:MM:SS").
        
        /* Exporta Clientes que compraram nos últimos dias */
        for each estab where (estab.tipoLoja = "Normal" or
                              estab.tipoLoja = "Outlet" or
                              estab.tipoLoja = "E-commerce") no-lock,
                      
            each plani where plani.etbcod = estab.etbcod
                         and plani.movtdc = 5
                         and plani.desti > 3
                         and plani.pladat = vdt no-lock,
                 
            first clien where clien.clicod = plani.desti no-lock.

            message. pause 0.
            
            run pre-geracao.
        end.

        if vexecucao-crm-menu
        then do.
            display "Exportando Clientes que pagaram em" @ voper
                    vdt
                    string(time,"HH:MM:SS") @ vhora
                    with frame f-cli.
            down 1 with frame f-cli.
        end.

        if vgera-log
        then put stream debug
         skip
         "##################################"
         "   FASE 3  -  Exporta clientes que pagaram parcelas nos últimos dias "
         "##################################"
         "Hora: " string(time,"HH:MM:SS").

        /* Exporta clientes que pagaram parcelas nos últimos dias */
        /* #1 Refeito for each */
        for each titulo where titulo.titnat = no /* Titulos a Receber*/
                          and titulo.titdtpag = vdt 
                          /***and titulo.modcod = titulo.modcod***/
                                        /* Qualquer modalidade */
                          no-lock.
            find estab of titulo no-lock.
            if estab.tipoLoja = "Normal" or
               estab.tipoLoja = "Outlet" or
               estab.tipoLoja = "E-commerce"
            then do.
                find clien where clien.clicod = fin.titulo.clifor no-lock.
                message. pause 0. 
                run pre-geracao.
            end.
        end.

        /* #1 */
        if vexecucao-crm-menu
        then do.
            display "Exportando Clientes com movimentacao no SPC em" @ voper
                    vdt
                    string(time,"HH:MM:SS") @ vhora
                    with frame f-cli.
            down 1 with frame f-cli.
        end.

        for each bclispc where bclispc.datexp = vdt no-lock.
            find clien of bclispc no-lock no-error.
            if avail clien
            then run pre-geracao.
        end.
    end.

    /* #1 Titulos vencidos ate 16 dias */
    do i = 1 to 3.
        if i = 1
        then vdt = vdtini - 1.
        else if i = 2
        then vdt = vdtini - 16.
        else vdt = vdtini - 46.

        if vexecucao-crm-menu
        then do.
            display "Exportando Clientes com vencimento em" @ voper
                    vdt
                    string(time,"HH:MM:SS") @ vhora
                    with frame f-cli.
            down 1 with frame f-cli.
        end.

        for each titulo where titulo.titnat   = no
                          and titulo.titdtpag = ?
                          and titulo.titdtven = vdt
                        no-lock.
            find clien where clien.clicod = titulo.clifor no-lock no-error.
            if avail clien
            then run pre-geracao.
        end.
    end.
      
    output stream debug close.
end.
    
end procedure.


procedure pre-geracao:

    if clien.clicod <= 3 or
       clien.estciv = 6  or    /* Descarta clientes falecidos */
       clien.tippes = false or /* Descarta clientes Pessoa Juridica*/
       clien.clinom matches("*DESATIVA*")
      /*Descarta clientes com a palavra "DESATIVA" em qualquer parte do nome */
    then next.

   if clien.datexp = ?
      and not v-gera-carga-clientes-full
   then next.
            
   sresp = yes.
   run cpf.p(input clien.ciccgc, output sresp).
           
   if clien.ciccgc = ?
       or sresp = false
       or length(clien.ciccgc) <> 11
   then next.

   if not can-find(first tt-cli where tt-cli.clicod = clien.clicod)
       and not can-find(first b2-clien where b2-clien.ciccgc = clien.ciccgc
                                         and b2-clien.clicod <> clien.clicod
                                         and b2-clien.dtcad >= clien.dtcad)
       and not can-find(first tt-controle
                        where tt-controle.clicod = clien.clicod)
   then do:
       run p-cliente.
   end.
   
   /*
   find first tt-cli where tt-cli.clicod = clien.clicod no-lock no-error.
   
   if not avail tt-cli
   then find first tt-cli where tt-cli.cpf = clien.ciccgc no-lock no-error.
   
   if not avail tt-cli
   then do:
        find first tt-controle where tt-controle.clicod = clien.clicod
                                          no-lock no-error.
        if not avail tt-controle
        then do:
           run p-cliente.                             
        end.
   end.
   */
                                            
end procedure.


procedure p-cliente:
    
    if not avail clien
    then next.
    
    if clien.clicod <= 3
    then return.        
    
    /*********************************************
    ***** Controla os clientes já exportados *****
    *********************************************/ 
      
    put stream control-cli unformatted clien.clicod skip.
    
    assign vconta-cli = vconta-cli + 1.
    
    if vgera-log then        
    put stream debug
        skip
        "Hora: " string(time,"HH:MM:SS")
        "  -  Adicionando Cliente: "
        clien.clicod format ">>>>>>>>>>>9"
        " - "
        clien.clinom format "x(40)"
        " a lista de exportação. "
        "Data de Alteração do Cadastro: "
        clien.datexp.

    empty temp-table tt-titulo.        

    assign vint-total-dias-atraso = 0
           vcalclim               = 0
           vpardias               = 0
           limite-total           = 0.
    
    create tt-cli.
    assign tt-cli.clicod        = clien.clicod
           tt-cli.clinom        = f-trata(clien.clinom)
           tt-cli.cidade        = f-trata(clien.cidade[1])
           tt-cli.cpf           = clien.ciccgc
           tt-cli.rg_ie         = f-trata(clien.ciinsc)
           tt-cli.data_cadastro = clien.dtcad
           tt-cli.conjuge_nome  = f-trata(substr(clien.conjuge,1,50))
           tt-cli.conjuge_cpf   = trim(substr(clien.conjuge,51,20))
           tt-cli.datexp   = clien.datexp
           tt-cli.nome_pai = f-trata(clien.pai)
           tt-cli.nome_mae = f-trata(clien.mae).
           
           if clien.etbcad > 0
           then do:            
               assign tt-cli.etbcad = clien.etbcad. 
           end.
           else if length(string(clien.clicod)) < 10
           then do:               
               assign tt-cli.etbcad = int(substring(string(clien.clicod),
                       length(string(clien.clicod)) - 1,2)). 
           end.
           else do:
               assign tt-cli.etbcad = int(substring(string(clien.clicod),2,3)).
           end.

           assign tt-cli.conjuge_dt_nasc =
                            string(clien.nascon,"99/99/9999") no-error. 

           if error-status:error
           then tt-cli.conjuge_dt_nasc = "".

           if tt-cli.conjuge_nome = ?
           then assign tt-cli.conjuge_nome = "".
           
           sresp = yes.
           run cpf.p(input tt-cli.conjuge_cpf, output sresp).
           
           if tt-cli.conjuge_cpf = ?
               or sresp = false
               or length(tt-cli.conjuge_cpf) <> 11
           then assign tt-cli.conjuge_cpf = "".
              /*
                       if length(tt-cli.conjuge_cpf) > 0 then do:
                       message length(tt-cli.conjuge_cpf). pause.
                        end.
              */                                                  
                          
           if tt-cli.conjuge_dt_nasc = ?
           then assign tt-cli.conjuge_dt_nasc = "".

    assign tt-cli.cidade = replace(tt-cli.cidade,";","").

    if clien.dtnasc = ?
    then tt-cli.dtnasc = 01/01/1970.
    else tt-cli.dtnasc = clien.dtnasc.

    if clien.dtnasc <> ? 
    then vidade = (today - clien.dtnasc) / 365.

      if vidade <= 21
      then assign tt-cli.idade-fx = "14 a 21".
      else if vidade >= 22 and vidade <= 30
        then assign tt-cli.idade-fx = "22 a 30".
        else if vidade >= 31 and vidade <= 40
          then assign tt-cli.idade-fx = "31 a 40".
          else if vidade >= 41 and vidade <= 55
            then assign tt-cli.idade-fx = "41 a 55".
            else if vidade >= 56 and vidade <= 65
              then assign tt-cli.idade-fx = "56 a 65".
              else if vidade >= 66 and vidade <= 99
                then assign tt-cli.idade-fx = "66 a 99".
                else assign tt-cli.idade-fx = "Outros".

                    tt-cli.prof = (if clien.proprof[1] = ?
                                   then " "
                                   else f-trata(clien.proprof[1])).
                    
                    if clien.fax begins "9" or
                       clien.fax begins "8" or
                       clien.fax begins "7" or
                       clien.fax begins "5" or
                       clien.fax begins "4" or
                       
                       clien.fax begins "519" or
                       clien.fax begins "518" or
                       clien.fax begins "517" or
                       
                       clien.fax begins "549" or 
                       clien.fax begins "548" or
                       clien.fax begins "547" or
                       
                       clien.fax begins "539" or
                       clien.fax begins "538" or
                       clien.fax begins "537" or
                       
                       clien.fax begins "559" or
                       clien.fax begins "558" or
                       clien.fax begins "557" or
                       
                       clien.fax begins "469" or
                       clien.fax begins "468" or
                       clien.fax begins "467" or
                       
                       clien.fax begins "479" or
                       clien.fax begins "478" or
                       clien.fax begins "477" or
                       
                       clien.fax begins "489" or
                       clien.fax begins "488" or
                       clien.fax begins "487" 
                    then do:
                        tt-cli.celular = "".
                        
                        do i = 1 to length(clien.fax):   
                            if substring(clien.fax,i,1) = "0" or
                               substring(clien.fax,i,1) = "1" or
                               substring(clien.fax,i,1) = "2" or
                               substring(clien.fax,i,1) = "3" or
                               substring(clien.fax,i,1) = "4" or
                               substring(clien.fax,i,1) = "5" or
                               substring(clien.fax,i,1) = "6" or
                               substring(clien.fax,i,1) = "7" or
                               substring(clien.fax,i,1) = "8" or
                               substring(clien.fax,i,1) = "9" 
                            then tt-cli.celular = tt-cli.celular
                                                + substring(clien.fax,i,1).
                        end.    
                    end.
                    else tt-cli.celular = "".
                    
                    if length(clien.fone) >= 7
                    then do:
                        tt-cli.fone-resid = "".
                        
                        do i = 1 to length(clien.fone):   
                            if substring(clien.fone,i,1) = "0" or
                               substring(clien.fone,i,1) = "1" or
                               substring(clien.fone,i,1) = "2" or
                               substring(clien.fone,i,1) = "3" or
                               substring(clien.fone,i,1) = "4" or
                               substring(clien.fone,i,1) = "5" or
                               substring(clien.fone,i,1) = "6" or
                               substring(clien.fone,i,1) = "7" or
                               substring(clien.fone,i,1) = "8" or
                               substring(clien.fone,i,1) = "9" 
                            then tt-cli.fone-resid = tt-cli.fone-resid
                                                + substring(clien.fone,i,1).
                        end.    
                    end.
                    else tt-cli.fone-resid = "".
                    
                    if tt-cli.celular = ""
                    then tt-cli.tem-cel = "N".
                    else tt-cli.tem-cel = "S".
            
                    /*
                    if clien.numdep <> 0
                    then tt-cli.depen = "S".
                    else tt-cli.depen = "N".
                    */
                    tt-cli.sexo = if clien.sexo
                                  then "Masculino" else "Feminino".
                    /*
                    find first clispc where clispc.clicod = clien.clicod 
                                        and clispc.dtcanc = ? no-lock no-error. 
                    if avail clispc 
                    then tt-cli.spc = "S". 
                    else tt-cli.spc = "N".
                    */
                    tt-cli.ufecod = f-trata(clien.ufecod[1]).
                    
                    case clien.estciv:
                        when 1 then assign tt-cli.estciv = "Solteiro".
                        when 2 then assign tt-cli.estciv = "Casado".
                        when 3 then assign tt-cli.estciv = "Viuvo".
                        when 4 then assign tt-cli.estciv = "Desquitado".
                        when 5 then assign tt-cli.estciv = "Divorciado".
                        when 6 then assign tt-cli.estciv = "Falecido".
                        otherwise assign tt-cli.estciv = "Outros".
                    end case.

                    tt-cli.rua = if clien.endereco[1] <> ?
                                 then f-trata(clien.endereco[1])
                                 else "".
                
                    tt-cli.num = if (string(clien.numero[1])) <> ? 
                                 then (trim(string(clien.numero[1])))
                                 else "".
                
                    tt-cli.compl = if (string(clien.compl[1])) <> ? 
                                   then f-trata(string(clien.compl[1])) 
                                   else "".
                    
                    tt-cli.bairro = f-trata(clien.bairro[1]).
                                   
                    if  clien.cep[1] <> ?
                    then do:
                    
                        i = 0.
                        vcep = "".
                        do i = 1 to length(clien.cep[1]):   
                            if substring(clien.cep[1],i,1) = "0" or
                               substring(clien.cep[1],i,1) = "1" or
                               substring(clien.cep[1],i,1) = "2" or
                               substring(clien.cep[1],i,1) = "3" or
                               substring(clien.cep[1],i,1) = "4" or
                               substring(clien.cep[1],i,1) = "5" or
                               substring(clien.cep[1],i,1) = "6" or
                               substring(clien.cep[1],i,1) = "7" or
                               substring(clien.cep[1],i,1) = "8" or
                               substring(clien.cep[1],i,1) = "9" 
                            then vcep = vcep + substring(clien.cep[1],i,1).
                        end.
                    
                        tt-cli.cep = vcep.
                
                    end.
                    else tt-cli.cep = "".
    
                    if tt-cli.rua = ""
                        or tt-cli.num = ""
                        or tt-cli.num = "0"
                        or tt-cli.bairro = ""
                        or tt-cli.cep = ""
                        or tt-cli.cidade = ""
                        or tt-cli.bairro matches("*RURAL*")
                        or tt-cli.bairro matches("*INTERIOR*")
                        or tt-cli.compl matches("*RURAL*")
                        or tt-cli.compl matches("*INTERIOR*")
                    then assign tt-cli.rua = ""
                                tt-cli.num = ""
                                tt-cli.bairro = ""
                                tt-cli.cep = ""
                                tt-cli.cidade = ""
                                tt-cli.compl = "".

    assign tt-cli.email = f-limpa-email(clien.zona).
            
    if tt-cli.celular <> ""
    then tt-cli.tem-celular = "Sim".
    else tt-cli.tem-celular = "Nao".

    assign qtd-abaixo-15 = 0
           qtd-entre-16-45 = 0
           qtd-acima-46 = 0.

    if vgera-log then
    put stream debug unformatted
          "  Iniciando leitura de titulos: " string(time,"HH:MM:SS").

    for each fin.titulo where titulo.empcod = 19
                          and titulo.titnat = no
                          and fin.titulo.clifor = clien.clicod no-lock:
    
        if fin.titulo.modcod = "DEV" or
           fin.titulo.modcod = "BON" or
           fin.titulo.modcod = "CHP"
        then next.
        
        if fin.titulo.modcod = "CRE"
        then do:
            create tt-titulo.
            buffer-copy fin.titulo to tt-titulo no-error.
        end.
        
        if titulo.titpar <> 0
            and titulo.titdtpag <> ?
        then do:
            if (titulo.titdtpag - titulo.titdtven) <= 15
            then qtd-abaixo-15 = qtd-abaixo-15 + 1.

            if (titulo.titdtpag - titulo.titdtven) >= 16 and
               (titulo.titdtpag - titulo.titdtven) <= 45
            then qtd-entre-16-45 = qtd-entre-16-45 + 1.

            if (titulo.titdtpag - titulo.titdtven) >= 46
            then qtd-acima-46 = qtd-acima-46 + 1.
        end.
    end.
    
    find first credscor where credscor.clicod = clien.clicod no-lock no-error.
    if avail credscor
    then do:
        qtd-abaixo-15 = qtd-abaixo-15 + credscor.numa15.
        qtd-entre-16-45 = qtd-entre-16-45 + credscor.numa16.
        qtd-acima-46 = qtd-acima-46 + credscor.numa45.
    end.
    
    if vgera-log then
    put stream debug unformatted
         " Concluindo leitura de titulos: " string(time,"HH:MM:SS")
         " Iniciando leitura de Flag.".
                  
    find first flag where flag.clicod = clien.clicod no-lock no-error.
    if avail flag and flag.flag1 = yes
    then assign tt-cli.pontualidade = "Desclassificado".
    else if qtd-abaixo-15 > qtd-entre-16-45
             and qtd-abaixo-15 > qtd-acima-46     
             then assign tt-cli.pontualidade = "Pontual".
         else if qtd-entre-16-45 >= qtd-abaixo-15
                  and qtd-entre-16-45 > qtd-acima-46
                  then assign tt-cli.pontualidade = "Atrasa pouco".
              else if qtd-acima-46 >= qtd-abaixo-15
                       and qtd-acima-46 >= qtd-entre-16-45
                       then assign tt-cli.pontualidade = "Atrasa muito".
                   else if qtd-abaixo-15 = 0 
                            and qtd-entre-16-45 = 0
                            and qtd-acima-46 = 0
                            then assign tt-cli.pontualidade = "Pontual".

    if vgera-log then
    put stream debug unformatted
        " Concluindo leitura de Flag   : " string(time,"HH:MM:SS") "  ".

    if vgera-log then                        
    put stream debug unformatted
      " Pontualidade do cliente: "
      tt-cli.clicod format ">>>>>>>>>>9"
      " Qtd abaixo 15: "
      qtd-abaixo-15 format ">>>>9"
      " Qtd entre 16 e 45: "
      qtd-entre-16-45 format ">>>>9"
      " Qtd acima 46: "
      qtd-acima-46 format ">>>>9"
      " Pontualidade: " 
      tt-cli.pontualidade format "x(16)"
       "  ".

    if vgera-log then
    put stream debug unformatted
        "  Iniciando leitura de tt-titu : " string(time,"HH:MM:SS").

    release tt-titulo.
    
    find last tt-titulo where tt-titulo.clifor = clien.clicod
                          and tt-titulo.titsit = "LIB"
                             no-lock use-index idx_titsit no-error.
    if avail tt-titulo
    then assign tt-cli.dt_quit_ult_contrato = ""
                tt-cli.status_contratos = "ATIVO".
    else do:
        find last tt-titulo where tt-titulo.clifor = clien.clicod
                              and tt-titulo.titsit = "PAG"
                            no-lock use-index idx_dtpag no-error.
        if avail tt-titulo
        then do:
            assign tt-cli.dt_quit_ult_contrato =
                            string(tt-titulo.titdtpag,"99/99/9999") no-error.
            if error-status:error
            then assign tt-cli.dt_quit_ult_contrato = "".
        end.                    
        else assign tt-cli.dt_quit_ult_contrato = "".
        
        assign tt-cli.status_contratos = "FECHADO".
    end.
             /*
    message "Cli: " tt-cli.clicod
            " Dt-Nasc: " tt-cli.conjuge_dt_nasc
            " Ult-Cont: " tt-cli.dt_quit_ult_contrato.
            pause.
               */
    
    if vgera-log then                                                    
    put stream debug unformatted
        " Concluindo leitura de tt-titu : " string(time,"HH:MM:SS").

    /* Joao alterou o BI para buscar cadastro de clientes do MYSQL / EIS */
    /*
    for each fin.titulo where fin.titulo.clifor = clien.clicod no-lock:
 
        if fin.titulo.titnat = yes
        then next.
        if fin.titulo.titpar <> 0
        then do:
            if fin.titulo.titsit = "LIB"
            then do:
                assign vdat-maior-atraso-aux = today.
                
                if fin.titulo.titdtven < today
                then do:
                    if fin.titulo.titdtven < vdat-maior-atraso-aux
                    then vdat-maior-atraso-aux = fin.titulo.titdtven.
                end.
                
                if fin.titulo.titdtven <= today and fin.titulo.titdtpag = ?
                then do:
                    assign vint-total-dias-atraso = vint-total-dias-atraso
                                                + today - fin.titulo.titdtven.
                                                
                    if fin.titulo.titdtven <= (today - 30)
                    then
                      assign tt-cli.qtd-tit-venc#30 = tt-cli.qtd-tit-venc#30 + 1
                             tt-cli.val-tit-venc#30 = tt-cli.val-tit-venc#30 
                                                      + fin.titulo.titvlcob.
                    else
                      assign tt-cli.qtd-tit-venc-30 = tt-cli.qtd-tit-venc-30 + 1
                             tt-cli.val-tit-venc-30 = tt-cli.val-tit-venc-30
                                                      + fin.titulo.titvlcob.
                                
                end.
                else if fin.titulo.titdtven > today and fin.titulo.titdtpag = ?
                then do:
                    assign tt-cli.qtd-tit-a-venc = tt-cli.qtd-tit-a-venc + 1
                           tt-cli.val-tit-a-venc = tt-cli.val-tit-a-venc
                                                     + fin.titulo.titvlcob.   
                end.
            end.
            else if fin.titulo.titsit = "PAG"
            then assign tt-cli.qtd-tit-pag = tt-cli.qtd-tit-pag + 1
                        tt-cli.val-tit-pag = tt-cli.val-tit-pag
                                                  + fin.titulo.titvlpag.
        end.
    end.
    */
    
    /*
    assign tt-cli.maior-atraso = today - vdat-maior-atraso-aux.
    
    tt-cli.atraso-med = vint-total-dias-atraso / tt-cli.qtd-tit-venc#30.
    
    if tt-cli.atraso-med = ?
    then assign tt-cli.atraso-med = 0.
    */
    
    assign tt-cli.limite-disp = 0.
    assign limite-total = 0.

        run calccredscore.p(input "Tela",
                            input recid(clien),
                            output vcalclim,
                            output vpardias,
                            output limite-disponivel) no-error.

        if vgera-log then
        put stream debug unformatted
            " Limite Credscore: " vcalclim format "->>,>>>,>>>,>>9.99"
            " Limite Cadastro: " clien.limcrd format "->>,>>>,>>>,>>9.99"
            " Limite Disponivel: " limite-disponivel format "->>,>>>,>>>,>>9.99"
            .

        assign tt-cli.limite-disp = limite-disponivel.
        assign limite-total = vcalclim.
    
    if clien.prorenda[1] > clien.prorenda[2]
    then assign tt-cli.renda = clien.prorenda[1].
    else assign tt-cli.renda = clien.prorenda[2].
           
    tt-cli.limite      = limite-total.
    
    find last fin.clispc where fin.clispc.clicod = clien.clicod 
                         no-lock no-error.
    if avail fin.clispc and
             fin.clispc.dtcanc = ?
    then tt-cli.spc-lebes = "Sim".
    else tt-cli.spc-lebes = "Nao".
    
end procedure.


procedure p-gera-arquivos.

        if v-gera-clientes
        then do:
            output stream clien
                to value(vdirsaida + "bi_clientes-" + vtime + ".csv" ).
    
            put stream clien unformatted
            "clicod;clinom;sexo;estadocivil;profissao;cidade;"
            "bairro;datanascimento;email;celular;endereco;"
            "num;complemento;uf;cep;renda;limite;"
            "idade_fx;cpf;rg_ie;data_cadastro;"
            "LimiteDisponivel;FoneResidencial;spc_lebes;data_quit_ult_contr;"
            "conjuge_nome;conjuge_cpf;conjuge_dt_nasc;pontualidade;"
            "status_contratos;datexp;nom_pai;nom_mae;etbcad"
                    skip.
    
            for each tt-cli no-lock:
                put stream clien unformatted
                tt-cli.clicod
                vsp 
                tt-cli.clinom 
                vsp
                tt-cli.sexo   
                vsp
                tt-cli.estciv 
                vsp
                tt-cli.prof   
                vsp                                
                tt-cli.cidade 
                vsp
                tt-cli.bairro 
                vsp
                tt-cli.dtnasc format "99/99/9999"
                vsp
                tt-cli.email  
                vsp
                tt-cli.celular
                vsp
                tt-cli.rua    
                vsp
                tt-cli.num    
                vsp
                tt-cli.compl  
                vsp
                tt-cli.ufecod 
                vsp
                tt-cli.cep    
                vsp
                tt-cli.renda
                vsp
                round(tt-cli.limite,2) 
                vsp
                tt-cli.idade-fx
                vsp
                tt-cli.cpf
                vsp
                tt-cli.rg_ie
                vsp
                tt-cli.data_cadastro format "99/99/9999"
                vsp
                round(tt-cli.limite-disp,2)
                vsp
                tt-cli.fone-resid
                vsp
                tt-cli.spc-lebes
                vsp
                tt-cli.dt_quit_ult_contrato
                vsp
                tt-cli.conjuge_nome   
                vsp
                tt-cli.conjuge_cpf    
                vsp
                tt-cli.conjuge_dt_nasc 
                vsp
                tt-cli.pontualidade
                vsp
                tt-cli.status_contratos
                vsp
                tt-cli.datexp format "99/99/9999"
                vsp
                tt-cli.nome_pai
                vsp
                tt-cli.nome_mae
                vsp
                tt-cli.etbcad
                skip.
            
            end.
    
            output stream clien close.
        end.
        
        if v-gera-filiais
        then do:
            output stream filial
            to value(vdirsaida + "filiais.csv" ).
    
            put stream filial unformatted
             "cod_estab;nome_estab;endereco;bairro;municipio;fone;"
                    skip.
    
            for each tt-filial no-lock:
        
                put stream filial unformatted
                    tt-filial.etbcod
                    vsp
                    tt-filial.etbnom
                    vsp
                    tt-filial.endereco
                    vsp
                    tt-filial.bairro
                    vsp
                    tt-filial.munic
                    vsp
                    tt-filial.etbserie
                    vsp skip.
                                    
            end.
        
            output stream filial close.

        end.

        if v-gera-int-compra
        then do:

            output stream int_compra
            to value(vdirsaida + "intensao_compras.csv" ).
                       
            put stream int_compra unformatted
            "filial;cod_vendedor;conta_cliente;classe_produto;data_inclusao;"
            "intensao_mes_ano;" skip.
                    
            for each tt-intven no-lock:
        
                put stream int_compra unformatted
                    tt-intven.etbcod                                
                    vsp
                    tt-intven.vencod
                    vsp
                    tt-intven.clicod
                    vsp
                    tt-intven.clacod
                    vsp
                    tt-intven.peddat
                    vsp                
                    string(month(tt-intven.peddti))
                    + "/"
                    + string(year(tt-intven.peddti))
                    vsp skip.
                            
            end.

            output stream int_compra close.
        
        end.
        
end procedure.


procedure p-carrega-tt-controle:

def var vlinha as char.
def var varquivo as char.
    
assign varquivo = vdirsaida + "controle-cli-exp.csv".

if search(varquivo) <> ?
then do:

    input from value(varquivo).
    REPEAT:
        
        import unformatted vlinha.
        create tt-controle.
        assign tt-controle.clicod = integer(trim(vlinha)).

    end.        
    input close.
                
end.


end procedure.


