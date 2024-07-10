/* Definicoes Parametros -------------------------------------------------*/

def  var vetbcod    like estab.etbcod.

assign vetbcod = 0.  /* Processo para todas filiais  */

/* Definicoes ------------------------------------------------------------*/

def        var iseq       as inte  form ">>>>>>>9"     init 0   no-undo.
 
def        var w1         as inte                               no-undo.
def        var w2         as inte                               no-undo.
def        var w3         as inte                               no-undo.
def        var iqtd-ori   as inte                      init 0   no-undo.
def        var icontar    as inte                      init 0   no-undo.
def        var irgs       as inte                      init 0   no-undo.
def        var vpcod      as char                               no-undo.
def        var vfcod      as char                               no-undo.
def        var vccod      as char                               no-undo.
def        var vdescricao as char                      init ""  no-undo.
def        var icont      as inte form ">>>>>>>9"      init 0   no-undo.
def        var i1a        as inte form ">>>>>>>9"      init 0   no-undo.
def        var tInicio    as char                      init ""  no-undo.
def        var tFinal     as char                      init ""  no-undo.
def        var cNomArq    as char  form "x(120)"       init ""  no-undo.
def        var ict        as inte                      init 0   no-undo.

def temp-table tt-quantias      no-undo
    field etbcod    like estab.etbcod
    field rfv       like ncrm.rfv
    field qtd-ger   like medias.medfil
    field med-ger   like medias.sequencia
    index ch-etbcod   is unique etbcod rfv.
    
def buffer crm for ncrm.

/* ------------------------------------------------------------------------- */
if opsys = "UNIX"
then do:
        assign cNomArq = "/admcom/relat-crm/" +
                         "grvcrm" + 
                         substring(string(today),1,2) +
                         substring(string(today),4,2) +
                         substring(string(today),7,4) +
                         ".txt".
end.
else do:
        assign cNomArq = "c:~\temp\grvcrm" + 
                         substring(string(today),1,2) +
                         substring(string(today),4,2) +
                         substring(string(today),7,4) +
                         ".txt".
end.

output to value(cNomArq).
   
   put string(today,"99/99/9999") form "99/99/9999"
       skip
       string(time,"HH:MM:SS")
       skip
       "========================================"
       skip.

output close.

/* EXCLUSAO TABELAS---------------------------------------------------------- */

assign ict = 0.
/*
if vetbcod = 0
then do: 
      
        for each crm exclusive-lock 
                     use-index ch03crm:
            assign ict = ict + 1.

            disp crm.clicod label "Cliente"
                 ict        Label "RG"
                 with side-label  1 down
                 title "EXCLUSAO CRM"
                 col 25  row 10 frame f-a1x.

            pause 0 no-message.

            delete crm.
    
        end.
        for each crmprodutos use-index i-prip:
        
            disp crmprodutos.procod label "Produto"
                 with side-label  1 down
                 title "CRM Produtos"
                 col 25  row 10 frame f-a2x.

            pause 0 no-message.

            delete crmprodutos.
            
        end.          
        for each crmclasses use-index i-pric:

            disp crmclasses.clacod label "Classe"
                 with side-label  1 down
                 title "CRM Classes"
                 col 25  row 10 frame f-a3x.

            pause 0 no-message.
 
            delete crmclasses.
        end.
        for each crmfabricantes use-index i-prif:

            disp crmfabricantes.fabcod label "Fabricante"
                 with side-label  1 down
                 title "CRM Fabricantes"
                 col 25  row 10 frame f-a4x.

            pause 0 no-message.
 
            delete crmfabricantes.
        end. 
end.

hide frame f-a1.
hide frame f-a1x.
hide frame f-a2x.
hide frame f-a3x.
hide frame f-a4x.
    
for each medias where
         medias.etbcod = (if vetbcod <> 0
                          then vetbcod                 
                          else medias.etbcod) exclusive-lock use-index ietbcod:

    disp medias.rfv label "RFV"
         with side-label  1 down
              title "EXCLUSAO MEDIAS"
              col 25  row 10 frame f-a2.

    pause 0 no-message.

    delete medias.

end.
*/
hide frame f-a2.

/* FINAL EXCLUSAO TABELAS--------------------------------------------------- */

find rfvparam where rfvparam.setor = 0 no-lock no-error.
if not avail rfvparam then undo.

assign iseq = 0.

for each rfvcli where 
         rfvcli.setor  =  rfvparam.setor  and
         rfvcli.etbcod = (if vetbcod <> 0
                          then vetbcod                 
                          else rfvcli.etbcod) no-lock use-index i-setetb:
   find clien where 
        clien.clicod = rfvcli.clicod use-index clien no-lock no-error.
        find first crm where 
                   crm.clicod = rfvcli.clicod use-index ch01crm
                   exclusive-lock no-error.
        if not avail crm
        then do:
        
                assign iseq = iseq + 1.

                create crm. 
                assign crm.etbcod      = rfvcli.etbcod
                       crm.clicod      = clien.clicod 
                       crm.nome        = clien.clinom 
                       crm.limite      = clien.limcrd 
                       crm.bairro      = clien.bairro[1] 
                       crm.cidade      = clien.cidade[1] 
                       crm.profissao   = clien.proprof[1] 
                       crm.mostra      = yes
                       crm.mes-ani     = month(clien.dtnas)
                       crm.renda-mes   = clien.prorenda[1]
                       crm.produtos    = rfvcli.produtos
                       crm.classes     = rfvcli.classes
                       crm.fabricantes = rfvcli.fabricantes
                       crm.regis       = iseq.
                
                disp iseq label "Registro"
                     crm.etbcod 
                     crm.clicod
                     with side-label  1 down
                          title "CRM"
                          col 25  row 10 frame f-1.

                pause 0 no-message.
                
                /***spc***/
                find first clispc where 
                           clispc.clicod = clien.clicod and 
                           clispc.contnum = clispc.contnum and
                           clispc.dtcanc = ? no-lock no-error.
                if avail clispc
                then crm.spc = yes.
                else crm.spc = no.

                /*********/
            
                if clien.zona matches "*@*"
                then crm.email = yes.
                else crm.email = no.

                assign crm.sexo       = clien.sexo
                       crm.est-civil  = clien.estciv
                       crm.residencia = clien.tipres.
                       
                if clien.dtnasc <> ?
                then crm.idade = (year(today) - year(clien.dtnasc)).
                                
                if clien.numdep <> 0
                then crm.dep = yes.
                else crm.dep = no.
                
                if clien.fax begins "9" or
                   clien.fax begins "8"
                then crm.celular = yes.
                else crm.celular = no.  
                
                find carro where 
                     carro.clicod = clien.clicod use-index clicod
                     no-lock no-error.
                if avail carro
                then crm.carro = yes.
                else crm.carro = no.
                
                assign crm.valor      = rfvcli.valor
                       crm.frequencia = rfvcli.frequencia 
                       crm.recencia   = rfvcli.recencia
                       crm.rfv        = int(rfvcli.nota).

                assign crm.dataProces = today
                       crm.horaProces = string(time,"HH:MM:SS").

                find first medias where
                           medias.etbcod = crm.etbcod   and
                           medias.clicod = clien.clicod use-index irfv-asc
                           no-error.
                if not avail medias
                then  do:
                create medias.
                assign medias.rfv        = int(rfvcli.nota)
                       medias.clicod     = rfvcli.clicod
                       medias.recencia   = substring(string(medias.rfv),1,1) 
                       medias.frequencia = substring(string(medias.rfv),2,1)
                       medias.valor      = substring(string(medias.rfv),3,1)
                       medias.etbcod     = rfvcli.etbcod.
                end.
                /***** Informaçoes para agilizar o filtro dos produtos *******/
                /*Fabricantes*/
                w1 = 0. vfcod = "".
                do w1 = 1 to length(rfvcli.fabricantes).
                   if substring(rfvcli.fabricantes,w1,1) = "|"
                   then do:
                           find crmFabricantes where
                                crmFabricantes.clicod = rfvcli.clicod and 
                                crmFabricantes.fabcod = int(vfcod) 
                                use-index i-prif no-error.
                           if not avail crmFabricantes
                           then do:
                                   create crmFabricantes.
                                   assign crmFabricantes.clicod = rfvcli.clicod
                                          crmFabricantes.fabcod = int(vfcod). 
                           end.
                           vfcod = "".
                   end.
        
                   if substring(rfvcli.fabricantes,w1,1) <> "|"
                   then vfcod = vfcod + substring(rfvcli.fabricantes,w1,1).
         
                end. 
                /*Fabricantes*/
    
                /*Produtos*/
                w2 = 0. vpcod = "".
                do w2 = 1 to length(rfvcli.produtos).
                   if substring(rfvcli.produtos,w2,1) = "|"
                   then do:
                           find crmProdutos where 
                                crmProdutos.clicod = rfvcli.clicod and
                                crmProdutos.procod = int(vpcod) 
                                use-index i-prip no-error.
                           if not avail crmProdutos
                           then do:
                                   create crmProdutos.
                                   assign crmProdutos.clicod = rfvcli.clicod
                                          crmProdutos.procod = int(vpcod).
                           end.
                           vpcod = "".
                   end.
        
                   if substring(rfvcli.produtos,w2,1) <> "|"
                   then vpcod = vpcod + substring(rfvcli.produtos,w2,1).

                end. 
                /*Produtos*/

                /*Classes*/
                w3 = 0. vccod = "".
                do w3 = 1 to length(rfvcli.classes).
                   if substring(rfvcli.classes,w3,1) = "|"
                   then do:
                           find crmClasses where 
                                crmClasses.clicod = rfvcli.clicod and 
                                crmClasses.clacod = int(vccod) 
                                use-index i-pric no-error.
                           if not avail crmClasses
                           then do:
                                   create crmClasses.
                                   assign crmClasses.clicod = rfvcli.clicod
                                          crmClasses.clacod = int(vccod). 
                           end.
                           vccod = "".
                   end.
        
                   if substring(rfvcli.classes,w3,1) <> "|"
                   then vccod = vccod + substring(rfvcli.classes,w3,1).
         
                end. 
                /*Classes*/
                /*******************************************/
                end.
end.

/* ---------------------------------Medias Processo------------------------- */
hide frame f-1.

assign iseq = 0.

for each crm exclusive-lock:

     assign iseq = iseq + 1.

     assign crm.regis       = iseq.

end.

output to value(cNomArq) append.
 
   put  skip(1)
        "ENCERROU GRAVACAO CRM"
        skip
        string(time,"HH:MM:SS")
        skip
        "------------------------------"
        Skip.
output close.

find last crm where
          crm.etbcod = (if vetbcod <> 0
                        then vetbcod                 
                        else crm.etbcod) use-index ch03crm
                        no-lock no-error.
if avail crm
then do:
         assign irgs = crm.regis.
end.
                        
for each medias where
         medias.etbcod = (if vetbcod <> 0
                          then vetbcod                 
                          else medias.etbcod) use-index ietbcod
                          exclusive-lock  
                          break by medias.etbcod
                                by medias.rfv:    

      if first-of(medias.etbcod)
      then do:
              assign i1a = 0.
      end.

      assign i1a = i1a + 1.

      disp medias.clicod label "Cliente"
           with side-label  1 down
                title "MEDIAS QTD ORIGINAL"
                col 25  row 10 frame f-2.
      pause 0 no-message.
      
      if first-of(medias.rfv)
      then do:
              assign iqtd-ori = 0.
      end.
      
      assign iqtd-ori = iqtd-ori + 1.
    
      if last-of(medias.rfv)
      then do:
              assign medias.qtd-ori         = iqtd-ori.
              assign medias.qtd-tot         = ((medias.qtd-ori * 100) / irgs).
              
              create tt-quantias.
              assign tt-quantias.etbcod     = medias.etbcod
                     tt-quantias.rfv        = medias.rfv
                     tt-quantias.med-ger    = iqtd-ori
                     tt-quantias.qtd-ger    = i1a.
      end.
end.

hide frame f-3.

for each tt-quantias where
         tt-quantias.etbcod = (if vetbcod <> 0
                               then vetbcod                 
                               else tt-quantias.etbcod) use-index ch-etbcod 
                               exclusive-lock  
                               break by tt-quantias.etbcod:
     if first-of(tt-quantias.etbcod)
     then do:
             assign icont = 0
                    i1a   = 0.
     end.
     
     assign icont = icont + tt-quantias.med-ger
            i1a   = i1a   + tt-quantias.qtd-ger.
     
     if last-of(tt-quantias.etbcod)
     then do:
     
            for each medias where
                     medias.etbcod = tt-quantias.etbcod use-index ietbcod
                     exclusive-lock:
                     
                     assign medias.medfil    = icont
                            medias.sequencia = i1a.
                             
            end.
     end.      
end.

for each medias where
         medias.etbcod = (if vetbcod <> 0
                          then vetbcod                 
                          else medias.etbcod) use-index irfv-des  
                          exclusive-lock  
                          break by medias.etbcod
                                by medias.qtd-ori descending:    

    disp medias.clicod label "Cliente"
         with side-label  1 down
              title "MEDIAS EXCLUSAO"
              col 25  row 10 frame f-3.
              
    pause 0 no-message.
    
    if first-of(medias.etbcod)
    then do:
            assign icontar = 1.
    end.
    
    if icontar > 5
    then delete medias.

    assign icontar = icontar + 1.
       
end.

hide all.

output to value(cNomArq) append.
 
   put  skip(1)
        string(time,"HH:MM:SS")
        string(today,"99/99/9999") form "99/99/9999"
        skip
        "ENCERRADO PROCESSO!"
        Skip.
output close.

/* ---------------------------------Final Programa-------------------------- */