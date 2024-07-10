{/admcom/progr/admcab-batch.i}

{/admcom/progr/ajusta-rateio-venda-def.i new}

{/admcom/progr/def-var-bsi-qvexp.i}


def var lojaexport as int. 

def var valorvendaanunciado like estoq.estvenda.

def var statuscombo as char.

def var vsp as char init ";".               
def var i as int. 

def buffer bf2-estab for estab.
def buffer btitulo for fin.titulo.

def var vdt as date.
def var vtodosprodutos as log.
def var vmovdes as dec.
def var vmovacf as dec. 

def var vcodplano as int.

def buffer bpedid for pedid.
def buffer bliped for liped.
def buffer bcompr for compr.

def var v-val-venda-aux  as decimal.
def var v-val-compra-aux as decimal.
def var v-val-ped-aux    as decimal.

def var val-impostos as dec.
def var val-devolucao as dec.
def var receita-liquida as dec.
def var custo-medio-liquido as dec.
def var lucro-bruto as dec.
                             
def var vqtd-vend        as integer.    
def var vqtd-dev         as integer.    
def var vqtd-comp        as integer.    
def var vqtd-ped         as integer.    
                                                         
def var vval-vend        as decimal.    
def var vval-dev         as decimal.    
def var vval-comp        as decimal.    
def var vval-ped         as decimal.    
                                          
def var vcusto-vend      as decimal.    
def var vdesc-vend       as decimal.    
def var vcusto-comp      as decimal.    
def var vprc-unit-comp   as decimal.    
def var vprc-unit-vend   as decimal.    
def var vchav-vend-aux   as character.  
def var vdatav           as character.
def var valchpres        as decimal.
def var valbonus           as decimal.
                
def var vopcnom as char.
def var vestab-fim as integer.

FUNCTION mesfim returns date(input par-data as date).

     return ((DATE(MONTH(par-data),28,YEAR(par-data)) + 4) -                                 DAY(DATE(MONTH(par-data),28,YEAR(par-data)) + 4)).

end function.


def temp-table tt-periodo
    field cod as integer
    field ano as integer
    field mes as integer
    index idx01 cod ano mes.
 
def var vdti-aux as integer.
def var vdtf-aux as integer.
def var vcont-periodo    as integer.
def var vcont-aux        as integer.

def var vforcado as log.
vforcado = no.

def var vdt-aux  as date.
def var v-frame-texto as char.
                       /*
form

    v-frame-texto  skip
       
        with frame f-vendas. 
                         */


    /**  Se a execução é para exportar arquivos do CRM deve usar a data e  **/     /**  diretorios selecionados no programa anterior                      **/
    
    if not program-name(2) matches("*exp_crm2*")
    then do:
    

        if today = 11/16/2014
        then do:
            assign vforcado = no
                    vdtini = 10/01/2014
                    vdtfim = today.
        end.
        else assign vdtini = today - 31.    
                    vdtfim = today.
                        
        if vforcado = no and
           time > 21600 /* Após 6hs da manhã roda apenas com dia - 1 */
        then vdtini = today - 1.
         

        if today = 11/16/2014
        then vdirsaida = "/admcom/lebesintel/carga_crm/".
        else vdirsaida = "/admcom/lebesintel/".
        
        assign vexecucao-crm-menu = false.
    
    end.
    else assign vexecucao-crm-menu = true.
    
    assign vestab-fim = 999
           vtodosprodutos = no.
                                          
    assign vdti-aux = month(vdtini) + (year(vdtini) * 12)
           vdtf-aux = month(vdtfim) + (year(vdtfim) * 12) .

    assign vcont-periodo = vdtf-aux - vdti-aux + 1.           

def var vcep         as char.
def var vqtdped-aux  as integer.

def var sresp as log.
def buffer bcidade for cidade.
def buffer setClase for Clase.
def buffer bfestoq for estoq.

def buffer npedid for pedid.

def buffer bf-movim for movim.

def buffer bf-produ for produ.

def var vdescarta as logical.

/*
connect dragao -H "erp.lebes.com.br" -S sdragao -N tcp -ld dragao no-error.
*/                                           

def stream movim.
def stream str-csv.
def stream caract.
def stream estab.
def stream func.
def stream plani.
def stream grupo.
def stream subclasse.
def stream classe.
def stream procarac.
def stream estoq.
def stream produ.
def stream fabri.
def stream meta.
def stream titbsmoe.
def stream debug.
def stream log.

/*
message vdirsaida.
message "confirma?" update sresp.
if not sresp then return.
pause 0 before-hide.
*/
def temp-table tt-meta
    field etbcod          as integer
    field codSubClasse    as integer
    field mes             as integer
    field ano             as integer
    field meta            as dec
       index idx01 is primary unique etbcod codSubClasse mes ano.


def temp-table tt-estoq                
    field etbcod   like estoq.etbcod   
    field procod   like estoq.procod   
    field estatual like estoq.estatual 
    field estcusto like hiest.hiepcf
    field mes      as integer
    field ano      as integer
        index idx01 etbcod procod.         

def temp-table tt-subcaract                
    field caraccod like caract.carcod 
    field caracnom like caract.cardes 
        index idx01 caraccod.               
            
def temp-table tt-procarac                
    field caraccod like procaract.subcod 
    field procod   like procaract.procod   
        index idx01 procod caraccod.          
/*
def new shared temp-table tt-movim like movim
    field movtot    like plani.platot 
    field chpres    like plani.platot
    field bonus     like plani.platot
    field vencod    like func.funcod
    field vendedor  like func.funnom
    field acr-fin   as dec
    field tipmov    as char 
    field crecod    as integer
    field planobiz  as character
    field clicod    as integer
    field serie     as char
    field planumero as integer
      index idx01 etbcod                
      index idx02 etbcod procod
      index idx03 etbcod asc placod asc movtot desc
      index idx04 etbcod movdat
      index idx05 etbcod placod movdat movtdc
      index idx_pk is primary unique etbcod placod procod movdat tipmov.        

def new shared temp-table tt-plani like plani
    field chpres like plani.platot
    field bonus  like plani.platot
    field tipmov as char   
    field clicod like plani.desti   
    field qtd-total as int
      index idx01 etbcod
      index idx_pk is primary unique etbcod placod serie.
*/

def temp-table tt-regiao
    field regcod as int
    field regnom as char
    index c is unique primary regcod.
    
def temp-table tt-estab
    field etbcod as int
    field etbnom as char
    field codregiao as int
    field cidade as char
    field ufecod as char
    index x as unique primary etbcod.

def temp-table tt-func
    field etbcod as int
    field funcod as int
    field funnom as char
    index x is unique primary etbcod funcod.

def temp-table tt-cid
    field cidcod    as   char
    field cidnom    like estab.munic
    field bairro    as   char format "x(20)"
    field ufecod    like estab.ufecod
    index i-cid is primary unique cidnom bairro.

def buffer grupo for Clase.
def buffer sClase for Clase.

def temp-table tt-fabri
    field fabcod like fabri.fabcod
    field fabnom like fabri.fabnom.
    
def temp-table tt-subClase
    field clacod like Clase.clacod
    field clasup like Clase.clasup
    field clanom like Clase.clanom
    index x is unique primary clacod .

def temp-table tt-Clase
    field clacod like Clase.clacod
    field clasup like Clase.clasup
    field clanom like Clase.clanom
    index x is unique primary clacod.

def temp-table tt-grupo
    field clacod like Clase.clacod
    field setcod as int
    field clanom like Clase.clanom
    index x is unique primary clacod.

def temp-table tt-setor
    field setcod like Clase.clacod
    field setnom like Clase.clanom
    field setsup like Clase.clasup
    index x is unique primary setcod.

def temp-table tt-departamento
    field catcod like categoria.catcod
    field catnom like categoria.catnom
    index x is unique primary catcod.
    

def temp-table tt-produ
    field procod like produ.procod
    field pronom like produ.pronom
    field codfis like produ.codfis
    field clacod like Clase.clacod
    field catcod like produ.catcod
    
    field fabcod like produ.fabcod
    field estcusto like estoq.estcusto
    field etccod as int
    field subcod as char
    field etcnom as character
    
    field precocusto like estoq.estcusto
    field precovenda like estoq.estvenda
    
    field comcod      like compr.comcod  /* Cód Comprador */
    field comnom      like compr.comnom  /* Nome do Comprador */


    field temp-cod    like temporada.temp-cod /* Cod temporada */
    field temp-nom    like temporada.tempnom  /* Nome temporada */  
    field dt-ult-ven  as char
    field dt-cad      as char
    field ativo       as logical format "Sim/Nao"
    field datexp      as char
    field vimposto as int

    index iprodu is primary unique procod.

/*
def new shared temp-table tt-planobiz
    field crecod as integer
    index idx01 crecod.
*/

for each tabaux where tabaux.tabela = "PlanoBiz" no-lock:

    create tt-planobiz.
    assign tt-planobiz.crecod = integer(tabaux.valor_campo).    
      
end.

output stream debug to value(vdirsaida + "debug.csv").

put stream debug unformatted
    "========== INICIO DA GERAÇÃO: " string(today,"99/99/9999")
    " as " string(time,"HH:MM:SS")
    " ===== Período gerado: " string(vdtini,"99/99/9999")
    " a " string(vdtfim,"99/99/9999")
    " ==========" skip(1).

run p-carrega-tt.

if vexecucao-crm-menu then do:

    Display "Gerando Arquivos " colon 8
            string(time,"HH:MM:SS") colon 60 skip
    with frame f-gera-arq no-box .
    pause 0.
end.

run p-gera-arquivos.

unix silent(sudo chmod 777 /admcom/lebesintel/*.csv).

unix silent(sudo chmod 777 /admcom/carga_admcom/*.csv).

run p-copia-arquivos-crm-oracle.


if time > 4000 and time < 10000  
then do:                                                                   
run /admcom/progr/visao_devol_export.p.      
run /admcom/progr/calculalimite-ultimos1.p.
end.                                                                       
                                                                           



                                                                           
                                                                                                                                                      







/**********************************************************************
***********************************************************************
********      Inicio da Sessão de Procedures                   ********
********      Coloque o código e todas as chamadas             ********
********      de procedure acima desse ponto.                  ********
***********************************************************************         **********************************************************************/

                                           
                                           

procedure p-carrega-tt:
    /*
    if today > 06/26/2012
    then
    run estoque.
    */
    /*
    display "p-carrega-tt em " string(time,"HH:MM:SS") skip
                    with frame f01 down centered row 3 .
    */                     
    
    if v-gera-vendas = true
    then do:
    
        run notas.
    

        /***********************  SOMENTE DREBES   ***********************/
        /* Ajustar diferença do rateio de valores entre o Plani e Movim  */
              
        output stream debug close.        
                   
        sretorno =  vdirsaida + "debug.csv".
                     
        /*run /admcom/progr/ajusta-rateio-venda-x.p.
        */

        if vexecucao-crm-menu
        then do:
             Display "Ajustando rateio das Vendas " colon 8                             string(time,"HH:MM:SS")  colon 60 skip 
                 with frame f-rateio no-box .
                pause 0.
        end.
                              
        run /admcom/progr/ajusta-rateio-venda-pro.p
        sretorno = "".
        
        output stream debug to value(vdirsaida + "debug.csv") append.

    end.                                            

    if v-gera-produtos = true
    then do:

        if vexecucao-crm-menu
        then do:
            Display "Exportando Produtos " colon 8
                    string(time,"HH:MM:SS") colon 60 skip
                      with frame f-processa-prod  no-box.
            pause 0.
        end.

        run produtos.
   
    
        if today > 11/27/2011
        then do:
            for each produ /* where
                 can-find (first movim
                      where movim.procod = produ.procod
                        and movim.movdat >= 01/01/2009) */ no-lock.
        
                run p-carrega-tt-produtos.        
                                                           
            end.                                                   
            run produtos. 
    
        end.

    end.

    if not vexecucao-crm-menu
    then do:
        if time <= 21600 /* Antes das 6hs da manhã gera compras */
        then do:
            run p-compras. 
                
        end.  
    end.
        
    if vexecucao-crm-menu
    then do:
        Display "Exportando Lojas " colon 8
         string(time,"HH:MM:SS") colon 60 skip
        with frame f-processa-lojas no-box .
        
        pause 0.
    end.
                               
    
    for each bf2-estab no-lock.
    
        run montalojas (bf2-estab.etbcod).    
    
    end.


    /*  
    run p-meta.
    */
end procedure.

procedure notas.

/*
display "procedure notas em " string(time,"HH:MM:SS") skip
          with frame f01 down centered row 3 .
*/                    

put stream debug unformatted
    "====================================================================="         skip
    "====================================================================="
       skip
    "====================================================================="
       skip
    "Procedure notas: " string(time,"HH:MM:SS") skip
    .

hide message no-pause.
/*
message "Notas".
pause 0. 

output stream log   to value(vdirsaida + "log.txt").
*/ 
def var vi as int.
def var vtipo-nota as character.
def var var-orderna-movseq as integer.
def var vqtd-total-plani as integer.

for each wf-plani: delete wf-plani. end.
for each wf-movim: delete wf-movim. end.

for each estab where estab.etbcod <= vestab-fim
                  or estab.etbcod >= 900    no-lock.

                                    
/*                                    
for each estab where estab.etbcod = 1  no-lock.  
  */                                    
                                      
                                      
    if estab.etbcod = 22 then next.
    
    output stream debug close.
    output stream debug to value(vdirsaida + "debug.csv") append.                           
    put stream debug unformatted
        "    Filial: " estab.etbcod " Hora: " string(time,"HH:MM:SS") skip.
            
       
       if vexecucao-crm-menu
       then do:
           display estab.etbcod label "Exportando Vendas da Filial"                               colon 37
                   string(time,"HH:MM:SS") colon 60 skip
               with fram f-vendas no-box side-label.
           pause 0.
       end.    
               
                  



      for each tipmov where tipmov.movtdc = 5 no-lock.  


        put stream debug unformatted
                "        Movtdc: " tipmov.movtdc
                " Hora: " string(time,"HH:MM:SS") skip.
                                                  .
        do vdt = vdtini to vdtfim:
        

            for each plani where 
                 plani.movtdc = tipmov.movtdc and
                 plani.etbcod = estab.etbcod and
                 plani.pladat = vdt 
                         no-lock:
                
             
                         
                find last clien where clien.clicod = plani.desti
                                    no-lock no-error.
                         
                find first func  where func.etbcod = plani.etbcod
                                   and func.funcod = plani.vencod
                                            no-lock no-error.
                
                vopcnom = tipmov.movtnom.
            
                run montalojas (plani.etbcod).
                            
                vi = vi + 1.
            
                vtipo-nota = "".
            
                if tipmov.movtdc = 4
                then vtipo-nota = "E".
                else if tipmov.movtdc = 5
                    then vtipo-nota = "V".
            
                
                if vtipo-nota = "V" 
                then do:
                    run /admcom/progr/pis-cofins-pm.p(input recid(plani)).
                end.
                
                create tt-plani.
                buffer-copy plani to tt-plani.                       
            
                assign tt-plani.chpres = 
                        dec(acha("VALCHQPRESENTEUTILIZACAO1",plani.notobs[3]))
                   tt-plani.tipmov = vtipo-nota
                   tt-plani.clicod = plani.desti
                   tt-plani.serie  = plani.serie.
                   tt-plani.bonus = 0.


                release fin.btitulo.
                if plani.descprod > 0
                then do:
                
                
                
                find last fin.btitulo where fin.btitulo.empcod = 19
                                    and fin.btitulo.modcod = "BON"
                                    and fin.btitulo.clifor = plani.desti
                                    and fin.btitulo.titnat   = yes
                                    and fin.btitulo.titdtpag = plani.pladat
                                    and fin.btitulo.titvlpag = plani.descprod
                                     no-lock no-error.
                                         
                                        
                if avail btitulo
                then assign tt-plani.bonus = plani.descprod
                        tt-plani.descprod = 0.
                end.
                else do:
                if acha("BONUSCRM",plani.notobs[1]) <> ?            
                then do: 
                     tt-plani.bonus = dec(acha("BONUSCRM",plani.notobs[1])).
                     tt-plani.descprod = 0.
                end.
                end.

                if tt-plani.bonus = ? then tt-plani.bonus = 0. 
                
                find clien where clien.clicod = plani.desti no-lock no-error.
                if not avail clien
                then /* next */ .
                else do:
                
                    find tt-cid where tt-cid.cidnom = clien.cidade[1] 
                              and tt-cid.bairro = clien.bairro[1] no-error.
                    if not avail tt-cid
                    then do:
                        find first cidade where 
                                   cidade.cidnom = clien.cidade[1] 
                                                            no-lock no-error.
                        if not avail cidade
                        then do:
                            find last bcidade no-lock no-error.
                            create cidade.
                            assign cidade.cidcod = (if avail bcidade
                                                then bcidade.cidcod + 1
                                                else 1)
                               cidade.cidnom = clien.cidade[1]
                               cidade.ufecod = clien.ufecod[1].
                
                        end. 

                        create tt-cid. 
                        assign tt-cid.cidcod = string(cidade.cidcod )
                           tt-cid.cidnom = cidade.cidnom 
                           tt-cid.bairro = clien.bairro[1]
                           tt-cid.ufecod = cidade.ufecod.
                           
                    end.
                end.
                
                assign var-orderna-movseq = 0
                   vqtd-total-plani = 0.
            
                for each movim where
                    movim.etbcod = plani.etbcod and
                    movim.placod = plani.placod and
                    movim.movtdc = plani.movtdc and
                    movim.movdat = plani.pladat
                    no-lock.
                
                    assign var-orderna-movseq = var-orderna-movseq + 1
                       vqtd-total-plani = vqtd-total-plani + movim.movqtm.
                              
                    find last produ of movim no-lock no-error.
                
                    if not avail produ
                    then next.
                
                    find last Clase of produ no-lock no-error.
                
                    find first tt-movim where
                           tt-movim.etbcod = movim.etbcod and
                           tt-movim.placod = movim.placod and
                           tt-movim.procod = movim.procod and
                           tt-movim.movdat = movim.movdat and
                           tt-movim.tipmov = vtipo-nota
                           no-error.
                    if not avail tt-movim
                    then  create tt-movim.
    
                    buffer-copy movim to tt-movim.
                    assign tt-movim.tipmov = vtipo-nota
                       tt-movim.vencod = plani.vencod
                       tt-movim.planumero = plani.numero
                       tt-movim.movseq = var-orderna-movseq.
                
                    run p-carrega-tt-produtos.
                    
                end.
            
                assign tt-plani.qtd-total = vqtd-total-plani.
            
            end.

        end.
        
    end.
    
    output stream debug close.
    output stream debug to value(vdirsaida + "debug.csv") append.    

end.            
/*
output stream plani close.
output stream movim close.
*/
end procedure.
/*
message "FIM".
pause.
*/


procedure produtos.
    /*
    hide message no-pause.
    message "Produtos ".
    pause 0. 
    */
    
        put stream debug unformatted
                "====================================================================="
           skip
                   "====================================================================="
           skip
                   "====================================================================="
           skip
                   "Procedure : produtos" string(time,"HH:MM:SS") skip
               .
               
    
    for each produ no-lock.
        
        for each procaract where procaract.procod = produ.procod no-lock.
        
            create tt-procarac.                                
            assign tt-procarac.caraccod = procaract.subcod
                   tt-procarac.procod   = procaract.procod. 

        end.    
    end.
    
    run caracteristicas.
    
end procedure.

procedure monta-Clase-desconhecida.
    /*
    hide message no-pause.
    message "Monta Classe desconhecida ".
    pause 0.
    */            
    find first tt-Clase where tt-Clase.clacod = -1 no-error.
    if not avail tt-Clase
    then do:
        create tt-Clase.
        tt-Clase.clacod = -1.
        tt-Clase.clanom = "Clase DESCONHECIDA".
        tt-Clase.clasup = -2.
    end. 
    find first tt-grupo where tt-grupo.clacod = -2 no-error.
    if not avail tt-grupo
    then do:
        create tt-grupo.
        tt-grupo.clacod = -2.
        tt-grupo.clanom = "GRUPO DESCONHECIDO".
        tt-grupo.setcod = -3.
    end. 
    find first tt-setor where tt-setor.setcod = -3 no-error.
    if not avail tt-setor
    then do:
        create tt-setor.
        tt-setor.setcod = -3.
        tt-setor.setnom = "SETOR DESCONHECIDO".
    end. 

    
 
end procedure. 

procedure montaprodutos.
    /*
    hide message no-pause.
    message "montaprodutos ".
    pause 0.
    */
        find tt-subClase where tt-subClase.clacod = tt-produ.clacod no-error.
        find sClase      where sClase.clacod      = tt-produ.clacod no-lock
                                                                    no-error.
        if not avail tt-subClase
        then do:
            create tt-subClase.
            tt-subClase.clacod = tt-produ.clacod.
            tt-subClase.clasup = if avail sClase
                                 then sClase.clasup
                                 else -1.
            tt-subClase.clanom = if avail sClase
                                 then sClase.clanom
                                 else "SUB Clase DESCONHECIDA". 
        end.
        find tt-Clase    where tt-Clase.clacod    = tt-subClase.clasup no-error.
        find Clase       where Clase.clacod       = tt-subClase.clasup no-lock
                                                                       no-error.
        if not avail tt-Clase
        then do:
            create tt-Clase.
            tt-Clase.clacod = tt-subClase.clasup.
            tt-Clase.clasup = if avail Clase
                              then Clase.clasup
                              else -2.
            tt-Clase.clanom = if avail Clase
                              then Clase.clanom
                              else "Clase DESCONHECIDA".
        end.
        find tt-grupo    where tt-grupo.clacod    = tt-Clase.clasup no-error.
        find grupo       where grupo.clacod       = tt-Clase.clasup no-lock
                                                                       no-error.
        if not avail tt-grupo
        then do:
            create tt-grupo.
            tt-grupo.clacod = tt-Clase.clasup.
            tt-grupo.setcod = if avail grupo
                              then grupo.clasup
                              else -2.
            tt-grupo.clanom = if avail grupo
                              then grupo.clanom
                              else "GRUPO DESCONHECIDO".
        end.
        find tt-setor    where tt-setor.setcod    = tt-grupo.setcod no-error.
        find setClase    where setClase.clacod    = tt-grupo.setcod no-lock
                                                               no-error.
        if not avail tt-setor
        then do:
            create tt-setor.
            tt-setor.setcod = tt-grupo.setcod.
            tt-setor.setsup = if avail setClase
                              then setClase.claper
                              else tt-produ.catcod.
            tt-setor.setnom = if avail setClase
                              then setClase.clanom
                              else "SETOR DESCONHECIDO".
        end.
        
        find last categoria where categoria.catcod = integer(tt-produ.catcod)
                            no-lock no-error.
                            
        find last tt-departamento where tt-departamento.catcod = integer(tt-produ.catcod)
                            no-lock no-error.
                            
        if not avail tt-departamento
        then do:
        
           create tt-departamento.
           assign tt-departamento.catcod = integer(tt-produ.catcod)
                  tt-departamento.catnom = if avail categoria
                                  then categoria.catnom
                                  else "DEPTO DESCONHECIDO".

        
        end.

            find produ where produ.procod = tt-produ.procod no-lock.
            find fabri of produ no-lock no-error.
            find first tt-fabri where tt-fabri.fabcod = produ.fabcod 
                    no-lock no-error.
            if not avail tt-fabri
            then do:
                create tt-fabri.
                tt-fabri.fabcod = produ.fabcod.
                tt-fabri.fabnom = if avail fabri
                                  then fabri.fabfant
                                  else "FABRICANTE DESCONHECIDO".
            end.

         
end procedure.

procedure caracteristicas.
    /*
    hide message no-pause.
    message "Caracteristicas ".
    pause 0.
    */            
    
    /*
    
    output to value(vdirsaida + "Caracteristicas.csv") .
    put unformatted
        "CodCaracteristica;Caracteristica" skip.     
    put unformatted
        "ESTACAO" vsp
        "ESTACAO" vsp
        "0" skip.
    output close.

    output to value(vdirsaida + "Subcaracteristicas.csv").
    put unformatted
        "CodSubCaracteristica;SubCaracteristica" skip.     

    for each estac no-lock:
        put unformatted
            "ESTACAO" + string(estac.etccod)
            vsp
            estac.etcnom 
            vsp
            "ESTACAO" skip.
    end.
    */
    for each subcaract no-lock:

        create tt-subcaract.                             
        assign tt-subcaract.caraccod = subcaract.subcar   
               tt-subcaract.caracnom = subcaract.subdes.  

    end.
    
end procedure.

procedure montalojas.
    /*
    hide message no-pause.
    message "MontaLojas ".
    pause 0.
    */            
    def input parameter par-etbcod as int.
    find first tt-estab where tt-estab.etbcod = par-etbcod no-lock no-error.
    if avail tt-estab
    then.
    else do:

        find last estab where estab.etbcod = par-etbcod no-lock.
        
        create tt-estab.
        assign
            tt-estab.etbcod = estab.etbcod.
            tt-estab.etbnom = estab.etbnom.

        assign
            tt-estab.codregiao = estab.regcod
            tt-estab.cidade    = estab.munic
            tt-estab.ufecod    = estab.ufecod.
        find first tt-regiao where tt-regiao.regcod = estab.regcod
            no-lock no-error.
        if not avail tt-regiao
        then do:
            find regiao where regiao.regcod = estab.regcod no-lock no-error.
            create tt-regiao.
            assign
                tt-regiao.regcod = estab.regcod
                tt-regiao.regnom = if avail regiao
                                   then regiao.regnom
                                   else "REGIAO DESCONHECIDA".
        end.

    end.

end procedure.

procedure montavendedores.

    /*
    hide message no-pause.
    message "MontaVendedores ".
    pause 0.
    */            
    
    def input parameter par-etbcod as int.
    def input parameter par-funcod as int.
    
    find first tt-func where tt-func.etbcod = par-etbcod
                         and tt-func.funcod = par-funcod no-lock no-error.
    if avail tt-func
    then .
    else do:

        find first func  where func.etbcod = par-etbcod
                           and func.funcod = par-funcod no-lock no-error.
        create tt-func.
        assign
            tt-func.etbcod = par-etbcod    
            tt-func.funcod = par-funcod.
            tt-func.funnom = if avail func
                             then func.funnom
                             else "VENDEDOR DESCONHECIDO".

    end.
end procedure.

procedure estoque:

    hide message no-pause.
    
    assign vdt-aux = vdtini.

    do vcont-aux = 1 to vcont-periodo:

        create tt-periodo.
        assign tt-periodo.cod = vcont-aux
               tt-periodo.ano = year(vdt-aux)
               tt-periodo.mes = month(vdt-aux). 
    
        assign vdt-aux = mesfim(vdt-aux).
    
        assign vdt-aux = vdt-aux + 1.

    end.            
    
    for each estab use-index estab no-lock:
    
        /*
        if estab.etbcod >= vestab-fim
            and estab.etbcod <= 900
        then next.    
        */
        /*
        put stream debug unformatted
            estab.etbcod
            vsp
            string(time,"HH:MM:SS")
            vsp   skip.
        */
    for each produ use-index iprodu no-lock:
    
        if produ.catcod = 91
        then next.

    for each tt-periodo use-index idx01 no-lock: 
    
        bl_hiest:
        for each hiest where hiest.etbcod = estab.etbcod
                     and hiest.procod = produ.procod
                     and hiest.hieano <= tt-periodo.ano
                     and hiest.hiemes <= tt-periodo.mes
                                    no-lock break by hiest.hieano desc
                                                  by hiest.hiemes desc.
                       
            if first(hiest.hiemes) and first(hiest.hieano)
            then.
            else leave bl_hiest.
    
            if today <> 07/14/2011
            then do:
                run p-carrega-tt-produtos.

                run montalojas (estab.etbcod).
            end.
            
            create tt-estoq.
            assign tt-estoq.etbcod   = hiest.etbcod
                   tt-estoq.procod   = hiest.procod
                   tt-estoq.estatual = hiest.hiestf
                   tt-estoq.estcusto = hiest.hiepcf
                   tt-estoq.ano      = tt-periodo.ano
                   tt-estoq.mes      = tt-periodo.mes.


        end.
        
    end.
    end.
    end.
    
    /*
    output stream debug close.
    */
end procedure.

procedure p-compras:

    def var vcont  as integer.
    
    def var vmovctm as decimal.
    
    assign vmovctm = 0.
    
    assign
     vmovdes = dec(0).
    /*
    output stream plani to value(vdirsaida + "Notas.csv").
    output stream movim to value(vdirsaida + "NotasXProdutos.csv").
    */
    
    bl_pedid:
    for each estab where estab.etbcod >= 900 no-lock,
    
        each pedid where pedid.pedtdc = 1 and
             pedid.etbcod = estab.etbcod and 
             pedid.sitped = "A" and pedid.peddat >= 01/01/08
                   no-lock:
        
        if pedid.peddti <= 01/01/2009 then next.
                                       
        find first npedid where
                   npedid.etbcod = pedid.etbcod and
                  (npedid.pedtdc = 4 or
                   npedid.pedtdc = 6) and
                /* npedid.pedsit = yes and*/
                   npedid.comcod = pedid.pednum
                      no-lock no-error.
        if avail npedid
            then next.
            
        run montalojas (input pedid.etbcod).
            
        
        bl_liped:                                                    
        for each liped of pedid no-lock:
    
            if liped.lipent >= liped.lipqtd  
            then next bl_liped.   
            else if liped.lipent < liped.lipqtd
                 then assign vqtdped-aux = liped.lipqtd - liped.lipent.
                   
            release tt-movim.
            find first tt-movim where tt-movim.etbcod = liped.etbcod
                                  and tt-movim.placod = pedid.pednum
                                  and tt-movim.procod = liped.procod
                                  and tt-movim.movdat = pedid.peddtf
                                  and tt-movim.tipmov = "P"
                                     exclusive-lock no-error.
            
            if not avail tt-movim
            then create tt-movim.
            
            assign tt-movim.etbcod = liped.etbcod
                   tt-movim.movdat = pedid.peddtf
                   tt-movim.placod = pedid.pednum
                   tt-movim.procod = liped.procod
                   tt-movim.movicms = 0
                   tt-movim.movqtm = tt-movim.movqtm + vqtdped-aux
                   tt-movim.movtot = tt-movim.movtot + 
                                        (vqtdped-aux * liped.lippreco)
                   tt-movim.movctm = 0
                   tt-movim.movdes  = 0
                   tt-movim.movpc   = 0
                   tt-movim.tipmov  = "P".
                          
        end.

        create tt-plani.
        assign tt-plani.etbcod = pedid.etbcod
               tt-plani.pladat = pedid.peddtf
               tt-plani.placod = pedid.pednum
               tt-plani.platot = pedid.pedtot
               tt-plani.vencod = pedid.comcod
               tt-plani.tipmov = "P".
    
         
    end.

end procedure.




/*
#######################################################################################################################
#######################################################################################################################

*/



procedure p-gera-arquivos:

    /*
    hide message no-pause.
    message "Gerando arquivos".
    pause 0.
    */
    /*****************************  Estab  ******************************************/
    
    output stream estab to value(vdirsaida + "bi_lojas.csv").
    put stream estab unformatted skip
         "CodLoja;Loja;CidadeLoja;EstadoLoja;CodRegiao;Regiao;NomeRed"
                   skip.  

    for each tt-estab,
    
        first tt-regiao where tt-regiao.regcod = tt-estab.codregiao no-lock:  

        put stream estab unformatted
            tt-estab.etbcod vsp
            trim(tt-estab.etbnom) " Fil. " tt-estab.etbcod  vsp
            tt-estab.cidade vsp
            tt-estab.ufecod vsp
            tt-estab.codregiao vsp
            tt-regiao.regnom vsp
            "Filial " tt-estab.etbcod skip.

    end.
    
    output stream estab close.
         
    /*
    /*************************  Func  *************************************/

    output stream func to value(vdirsaida + "bi_vendedores.csv").
    put stream func unformatted skip
         "CodVendedor;Vendedor"
              skip.  

    for each tt-func:  
    
        put stream func unformatted
            string(tt-func.etbcod)  "|" string(tt-func.funcod) vsp
            tt-func.funnom 
            skip.

    end.
    
    output stream func close.
    */
    
    if v-gera-vendas = true
    then do:
    
    /**********************  Plani  ****************************/

    output stream plani to value(vdirsaida + "bi_nota.csv").
    put stream plani unformatted
       "CodLoja;DataVenda;Nota;Cliente;Vendas;CodVendedor;TipoMovimento;"
       "NumeroNota;"
        skip.
    /*
    hide message no-pause.
    message "Gerando arquivo de notas".
    pause 0.
    */
    for each tt-plani no-lock:

        case (tt-plani.tipmov):
        when "V" then assign v-val-venda-aux  = tt-plani.platot
                             v-val-compra-aux = 0
                             v-val-ped-aux    = 0.
                             
        when "E" then assign v-val-venda-aux  = 0
                             v-val-compra-aux = tt-plani.platot
                             v-val-ped-aux    = 0.
   
        when "P" then assign v-val-venda-aux  = 0
                             v-val-compra-aux = 0
                             v-val-ped-aux    = tt-plani.platot.
                             
        end case. 
        
        put stream plani unformatted
            tt-plani.etbcod vsp
            tt-plani.pladat vsp
            tt-plani.placod vsp
            tt-plani.clicod vsp
            tt-plani.platot vsp
            tt-plani.vencod vsp
            tt-plani.tipmov vsp
            tt-plani.numero vsp
            skip.

    end.

    output stream plani close.
    

    /************************  Movim  *************************************/
    
    output stream movim to value(vdirsaida + "bi_notaprod.csv").
    put stream movim unformatted
        "CodLoja;DataVenda;Nota;CodProduto;"  
        "QuantidadeVenda;PrecoUnitario;ValorProdutos;Descontos;"  
        "Custo;ICMS;QtdDevolucao;Devolucao;QtdPedidos;ValPedidos;" 
        "QuantidadeCompra_c;PrecoUnitario_c;ValorProdutos_c;Custo_c;"
        "ChVendaaux;CodVendedor;Vendedor;Plano;PlanoBiz;Cliente;Serie;" 
        "AcrFin;tipmov;ValChequePresente;ValBonus;DataV;NumeroNota;HoraNota;"
        "SequencialItem;TotalVendaPlani;TotalQtdPlani;TotalDescontoPlani;"
        "Impostos;DevolucoesCalculadas;ReceitaLiquida;CustoMedioLiquido;"
        "LucroBruto;ValorVendaAnunciado;StatusCombo;"
           skip. 
    
    assign vqtd-dev       = 0
           vqtd-comp      = 0
           vqtd-ped       = 0
           vval-dev       = 0
           vval-comp      = 0
           vval-ped       = 0
           vcusto-comp    = 0
           vprc-unit-comp = 0
           vprc-unit-vend = 0
           valchpres      = 0
           valbonus       = 0
           vchav-vend-aux = ""
           vdatav         = ""           
           .
    /*
    hide message no-pause.       
    message "Gerando arquivo de itens de notas".
    pause 0.
    */

    for each tt-movim use-index idx04 no-lock,
    
        first tt-plani where tt-plani.etbcod = tt-movim.etbcod and
                             tt-plani.placod = tt-movim.placod and
                             tt-plani.movtdc = tt-movim.movtdc and
                             tt-plani.pladat = tt-movim.movdat
                                      no-lock by tt-movim.etbcod
                                              by tt-movim.movdat:
                                              
        find produ where produ.procod = tt-movim.procod no-lock no-error.
        
        /*
        message "Movim: " tt-movim.procod.
        pause 0.
        */
        assign vchav-vend-aux = ""
               vdatav         = "".

        case (tt-movim.tipmov):
        
        when "V" then do:
                      assign vqtd-vend      = tt-movim.movqtm
                             vqtd-dev       = 0
                             vqtd-comp      = 0
                             vqtd-ped       = 0
                             vval-vend      = tt-movim.movtot
                             vval-dev       = 0
                             vval-comp      = 0
                             vval-ped       = 0
                             vcusto-vend    = tt-movim.movctm
                             vdesc-vend     = tt-movim.movdes
                             vcusto-comp    = 0
                             vprc-unit-comp = 0
                             vprc-unit-vend = (tt-movim.movpc - tt-movim.movdes
                                    - tt-movim.bonus)
                             valchpres      = tt-movim.chpres
                             valbonus       = tt-movim.bonus * tt-movim.movqtm
                             vdatav      = string(tt-movim.movdat,"99/99/9999")
                             vchav-vend-aux = string(tt-movim.etbcod)
                                               + "|" + string(tt-movim.movdat) 
                                               + "|" + string(tt-movim.placod)
                             .
                             
       if tt-plani.pladat >= 12/01/2016 then do:
       vprc-unit-vend = (tt-movim.movpc - tt-movim.movdes).                                                                  end.
                                            else do:
       vprc-unit-vend = (tt-movim.movpc - tt-movim.movdes - tt-movim.bonus).
                                            end.
                             
                             
               find first wf-movim where
                       wf-movim.etbcod = tt-movim.etbcod and
                       wf-movim.placod = tt-movim.placod and
                       wf-movim.procod = tt-movim.procod and
                       wf-movim.movtdc = tt-movim.movtdc
                       no-error.
               if avail wf-movim
               then do:
                     assign
                             val-impostos = wf-movim.movicms +
                                           wf-movim.movpis +
                                           wf-movim.movcofins
                             val-devolucao = wf-movim.movdev
                             receita-liquida = vval-vend - val-impostos
                                    - val-devolucao
                             custo-medio-liquido = 
                                if avail produ and produ.fabcod = 50275027
                                then wf-movim.movctm -
                                   ((wf-movim.movctm /* / 2*/) * (14.05 / 100))
                                else wf-movim.movctm.   
                             lucro-bruto = receita-liquida - 
                                        custo-medio-liquido
                             .   
               end.                              
        end.
        when "E" then assign vqtd-vend      = 0
                             vqtd-dev       = 0
                             vqtd-comp      = tt-movim.movqtm
                             vqtd-ped       = 0
                             vval-vend      = 0
                             vval-dev       = 0
                             vval-comp      = tt-movim.movtot
                             vval-ped       = 0
                             vcusto-vend    = 0
                             vdesc-vend     = 0
                             vcusto-comp    = tt-movim.movctm
                             vprc-unit-comp = tt-movim.movpc
                             vprc-unit-vend = 0
                             valchpres      = 0
                             valbonus       = 0
                             vdatav         = ""
                             vchav-vend-aux = "".
        
        when "P" then assign vqtd-vend      = 0
                             vqtd-dev       = 0
                             vqtd-comp      = 0
                             vqtd-ped       = tt-movim.movqtm
                             vval-vend      = 0
                             vval-dev       = 0
                             vval-comp      = 0
                             vval-ped       = tt-movim.movtot
                             vcusto-vend    = 0
                             vdesc-vend     = 0
                             vcusto-comp    = 0
                             vprc-unit-comp = 0
                             vprc-unit-vend = 0
                             valchpres      = 0
                             valbonus       = 0
                             vdatav         = ""
                             vchav-vend-aux = "".
        
        when "D" then assign vqtd-vend      = 0
                             vqtd-dev       = tt-movim.movqtm
                             vqtd-comp      = 0
                             vqtd-ped       = 0
                             vval-vend      = 0
                             vval-dev       = tt-movim.movtot
                             vval-comp      = 0
                             vval-ped       = 0 
                             vcusto-vend    = 0
                             vdesc-vend     = 0
                             vcusto-comp    = 0
                             vprc-unit-comp = 0
                             vprc-unit-vend = 0
                             valchpres      = 0
                             valbonus       = 0
                             vdatav         = ""
                             vchav-vend-aux = "".
                             
        end case.

    find first estoq where estoq.procod = tt-movim.procod
         and estoq.etbcod = tt-movim.etbcod no-lock
no-error. 

if avail estoq then do:

if today >= estbaldat and today <= estprodat
then do:
   valorvendaanunciado = estproper * tt-movim.movqtm.
   end.
   else do:
     valorvendaanunciado = estvenda * tt-movim.movqtm.  
   end.

end.
else do:
     valorvendaanunciado = tt-movim.movpc * tt-movim.movqtm.
end.


        lojaexport = tt-movim.etbcod.

        
        if lojaexport = 988 then do:
                    lojaexport = 128.
        end.

/*
     
         if tt-plani.bonus <> ? and tt-plani.bonus > 0
                then valbonus = round(((tt-movim.movpc * tt-movim.movqtm)
                       / plani.platot) * tt-plani.bonus,2).
                    if valbonus = ? then valbonus = 0.
                    
                 
                 valbonus = tt-plani.bonus.
       
  */
        
        
              statuscombo = "0".
              
               if acha("COMBO",tt-plani.notobs[1]) <> ?
                then do:
                 statuscombo = "1".
                end.
              
             if produ.proipiper = 98 then do:
                   val-impostos = 0.
             end.
        
        
        /*
        if avail produ and produ.fabcod = 50275027
        then vcusto-vend = vcusto-vend -
                           ((vcusto-vend /* / 2*/) * (14.05 / 100)).
        */                 
        put stream movim unformatted
             lojaexport   vsp
             tt-movim.movdat   vsp
             tt-movim.placod   vsp
             tt-movim.procod   vsp
             vqtd-vend                                           vsp
             vprc-unit-vend                                      vsp
          /*(tt-movim.movpc * tt-movim.movqtm) - tt-movim.movdes vsp */
             vval-vend                  vsp
             vdesc-vend                 vsp
             vcusto-vend                vsp
             tt-movim.movicms           vsp
             vqtd-dev                   vsp
             vval-dev                   vsp
             vqtd-ped                   vsp
             vval-ped                   vsp
             vqtd-comp                  vsp
             vprc-unit-comp             vsp
             vval-comp                  vsp
             vcusto-comp                vsp
             vchav-vend-aux             vsp
             tt-movim.vencod            vsp
             tt-movim.vendedor          vsp 
             tt-movim.crecod            vsp
             tt-movim.planobiz          vsp
             tt-movim.clicod            vsp
             tt-movim.serie             vsp
             tt-movim.acr-fin           vsp
             tt-movim.tipmov            vsp
             valchpres                  vsp
             valbonus                   vsp
             vdatav                     vsp
             tt-movim.planumero         vsp
             string(tt-movim.MovHr,"hh:mm")                 vsp
             tt-movim.movseq                                vsp
             tt-plani.platot                                vsp
             tt-plani.qtd-total                             vsp
             round((tt-plani.descprod + tt-plani.bonus),2)  vsp
             val-impostos vsp
             val-devolucao vsp
             receita-liquida vsp
             custo-medio-liquido vsp
             lucro-bruto vsp
             valorvendaanunciado vsp
             statuscombo vsp
             skip.
    end.
    output stream movim close.

    /* P2K - Cartoes */
def var vtitvlmer   as dec.
def var vtaxa       like moetaxa.taxa.
def var vvlrtaxa    as dec format "->>,>>9.99" decimals 2.
def var vvlrliquido as dec.

    output stream titbsmoe to value(vdirsaida + "bi_notacartao.csv").
    put stream titbsmoe unformatted
        "CodLoja;DataVenda;Nota;Cliente;"
        "NSU;Vencimento;Moeda;Merc;Juro;Valor;Taxa;Liquido;"
        skip.
    for each tt-plani where tt-plani.tipmov = "V" no-lock:

        find plani where plani.etbcod = tt-plani.etbcod
                     and plani.placod = tt-plani.placod
                     and plani.serie  = tt-plani.serie
                   no-lock.
        find pdvdoc where pdvdoc.etbcod = plani.etbcod
                      and pdvdoc.placod = plani.placod
                    no-lock no-error.
        if not avail pdvdoc
        then next.
        find pdvmov of pdvdoc no-lock.

        for each pdvmoeda of pdvmov no-lock.
            find titbsmoe of pdvmoeda no-lock no-error.
            if not avail titbsmoe
            then next.
            if titbsmoe.modcod <> "CAR"
            then next.

            find moeda of titbsmoe no-lock.
            
            vtitvlmer = titbsmoe.titvlcob - titbsmoe.titvljur.
            find last moetaxa where 
                        moetaxa.moecod = titbsmoe.moecod and
                        moetaxa.qtd_parcelas <= titbsmoe.qtd_parcelas and
                        moetaxa.dativig <= titbsmoe.titdtemi
                        no-lock no-error.
            vtaxa = if not avail moetaxa then 2 else moetaxa.taxa.
            vvlrtaxa = round(titbsmoe.titvlcob * vtaxa / 100,2).
            vvlrliquido = titbsmoe.titvlcob - vvlrtaxa.

            put stream titbsmoe unformatted
                plani.etbcod
                vsp plani.pladat
                vsp plani.placod
                vsp plani.desti
                vsp titbsmoe.titnum
                vsp titbsmoe.titdtven
                vsp titbsmoe.moecod
                vsp vtitvlmer
                vsp titbsmoe.titvljur
                vsp titbsmoe.titvlcob
                vsp vvlrtaxa
                vsp vvlrliquido
                vsp
                skip.
        end.
    end.
    output stream titbsmoe close.
    
end. /* if v-gera-vendas = true then do:*/ 
    
    if v-gera-produtos
    then do:
    
    /*************************  Produ  ***********************************/

    output stream produ to value(vdirsaida + "bi_produtos.csv").
    put stream produ unformatted skip
         "CodProduto;Produto;PrecoCusto;PrecoVenda;"
        "CodSubClasse;SubClasse;CodClasse;Classe;CodGrupo;Grupo;CodSetor;Setor;"
        "CodFabricante;Fabricante;CodDepto;Depto;CodEstac;Estacao;"
        "ComCod;ComNome;CodTemporada;NomeTemporada;StatusPE;StatusMontagem;"
        "DataUltimaVenda;DataCadastro;Ativo;DataAlteracao;StatusImposto;Aliquota;Clafis;Monofasico;MPdoBem;vIPI;MVAe;MVAo;Referencia;"    skip.

    for each tt-produ no-lock:
    
        find first tt-subClase where tt-subClase.clacod = tt-produ.clacod
                           /*  and tt-subClase.nivel = 1 */ no-lock.
                             
        find first tt-Clase where tt-Clase.clacod = tt-subClase.clasup
                        /* and tt-Clase.nivel = 2 */ no-lock.
                          
        find first tt-grupo where tt-grupo.clacod   = tt-Clase.clasup
                       /* and tt-grupo.nivel   = 3 */ no-lock.
                         
        find first tt-fabri where tt-fabri.fabcod = tt-produ.fabcod no-lock.
        
        find first tt-setor where tt-setor.setcod = tt-grupo.setcod
                        /* and tt-setor.nivel  = 4 */ no-lock.
                         
        find first tt-departamento
                  where tt-departamento.catcod = tt-produ.catcod
                                         no-lock no-error.
        /*
        if tt-produ.catcod <> 31
        and tt-produ.catcod <> 41 then next.
        */
        /*
        message "Produtos: " tt-produ.pronom.
        pause 0.
        */
                              
        put stream produ unformatted 
             tt-produ.procod     vsp
             tt-produ.pronom     vsp
             tt-produ.precocusto vsp
             tt-produ.precovenda vsp.
             
       if avail tt-subClase
       then put stream produ unformatted      
             tt-subClase.clacod vsp
             tt-subClase.clanom vsp.
       else put stream produ unformatted
            vsp vsp.
             
       if avail tt-Clase
       then put stream produ unformatted      
             tt-Clase.clacod    vsp
             tt-Clase.clanom    vsp.
       else put stream produ unformatted
            vsp vsp.
             
        if avail tt-grupo
        then put stream produ unformatted     
             tt-grupo.clacod     vsp
             tt-grupo.clanom     vsp.
        else put stream produ unformatted
             vsp vsp.
             
             
        if avail tt-setor
        then put stream produ unformatted     
             tt-setor.setcod     vsp
             tt-setor.setnom     vsp.
        else put stream produ unformatted
             vsp vsp.
             
        if avail tt-fabri
        then put stream produ unformatted
             tt-fabri.fabcod     vsp
             tt-fabri.fabnom     vsp.          
        else put stream produ unformatted
             vsp vsp.

        if avail tt-departamento
        then put stream produ unformatted     
             tt-departamento.catcod vsp
             tt-departamento.catcod " - "
             tt-departamento.catnom vsp.
        else put stream produ unformatted
             vsp vsp.   
             
        put stream produ unformatted
            tt-produ.etccod
            vsp
            tt-produ.etcnom
            vsp.


        put stream produ unformatted
            tt-produ.comcod
            vsp
            tt-produ.comnom
            vsp.

                 

        put stream produ unformatted
            tt-produ.temp-cod
            vsp
            tt-produ.temp-nom
            vsp.


        find first produ where produ.procod = tt-produ.procod
        no-lock no-error.
        if produ.proipival = 1 then
            put stream produ unformatted
               "PE-SIM" vsp.                      
        else
            put stream produ unformatted
               "PE-NAO" vsp.

         
        if produ.protam = "SIM" then       
            put stream produ unformatted  
               "MONTAGEM-SIM" vsp.         
        else                              
            put stream produ unformatted  
               "MONTAGEM-NAO" vsp.         
        
        put stream produ unformatted
           tt-produ.dt-ult-ven
           vsp
           tt-produ.dt-cad
           vsp.
           
       put stream produ    
           tt-produ.ativo vsp
           tt-produ.datexp
           vsp.


 if produ.proipiper = 99 then            
      put stream produ unformatted       
              "COM-SUBSTITUICAO" vsp
               produ.proipiper   vsp.                  
               else                                   
                    put stream produ unformatted       
               "SEM-SUBSTITUICAO" vsp
                  produ.proipiper vsp.

                      
   find first clafis where clafis.codfis = produ.codfis no-lock no-error. 
     
        
        put stream produ unformatted 
           produ.codfis  vsp.  

                        

      if avail clafis and clafis.log1 = yes then                     
          put stream produ unformatted            
                      "MONOFASICO-SIM" vsp.         
                                else                     
           put stream produ unformatted             
                      "MONOFASICO-NAO" vsp.         


       if avail clafis and clafis.log2 = yes then         
               put stream produ unformatted     
                          "MP DO BEM-SIM" vsp.           
                              else                                 
              put stream produ unformatted     
                          "MP DO BEM-NAO" vsp.           
                
          if avail clafis then       
                     put stream produ unformatted             
                         clafis.peripi vsp.          
                       else                      
                         put stream produ unformatted              
                       "0" vsp.          
       
       
       
             if avail clafis then                        
                           put stream produ unformatted     
                          clafis.mva_estado1 vsp.           
                             else                                                                      put stream produ unformatted 
                                              "0" vsp.     
                                                                
          
                         if avail clafis then                                                            put stream produ unformatted              
                              clafis.mva_oestado1 vsp. 
                                 else                                                                       put stream produ unformatted           
                                     "0" vsp.               
       
       
       
                       put stream produ unformatted  
                             produ.prorefter vsp.  
       
       
        put stream produ unformatted 
           skip.
             
     end.

    output stream produ close.    

    end. /* if v-gera-produtos then do:*/

    if today = 10/25/2011
    then
    output stream estoq
        to value(vdirsaida + "temp/" + "bi_estpro.csv").
    else
    output stream estoq
        to value(vdirsaida + "bi_estpro.csv").
                
    put stream estoq unformatted
        "CodLoja"
        vsp
        "CodProduto"
        vsp
        "Estoque"
        vsp
        "EstCusto"
        vsp
        "Ano"
        vsp
        "Mes"
        vsp
         skip.

        
    for each tt-estoq no-lock:

        put stream estoq unformatted    
            tt-estoq.etbcod   vsp
            tt-estoq.procod   vsp
            tt-estoq.estatual vsp
            tt-estoq.estcusto vsp
            tt-estoq.ano      vsp
            tt-estoq.mes      vsp skip.

    end.               

    output stream estoq close.
    
    /*******************   SubCarPro  **********************/

    output to value(vdirsaida + "bi_subcarpro.csv") .
    put unformatted
        "CodProduto;CodSubCaracteristica;" skip.     

    for each tt-procarac no-lock:
    
        put unformatted
            tt-procarac.procod
            vsp
            tt-procarac.caraccod
            vsp    skip.
        
    end.
    
    output close.


    /*******************   SubCaracterísticas **********************/

    output to value(vdirsaida + "bi_subcaracteristicas.csv") .
    put unformatted
        "CodSubCaracteristica;SubCaracteristica" skip.     


    for each tt-subcaract no-lock:
    
        put unformatted
            tt-subcaract.caraccod
            vsp
            tt-subcaract.caracnom
            vsp    skip.
        
    end.
    
    output close.






    /**************  Metas  **************/

    output stream meta
              to value(vdirsaida + "bi_metas.csv").

    put stream meta unformatted
        "codLojaMeta;codSubClasseMeta;mes;ano;meta;" skip.

    for each tt-meta no-lock.
    
        assign tt-meta.meta = (tt-meta.meta * 1.1).

        put stream meta unformatted
            tt-meta.etbcod      
            vsp
            tt-meta.codSubClasse
            vsp
            tt-meta.mes         
            vsp
            tt-meta.ano         
            vsp
            tt-meta.meta        
            vsp skip.
    
    end.

    output stream meta close.    
                                     /*
    unix silent value("/admcom/progr/script-bi2.ftp").
                                     */
end procedure.


procedure p-carrega-tt-produtos:
        
        if not can-find(first tt-produ
                        where tt-produ.procod = produ.procod)
        then do:

            release bfestoq.
            find first bfestoq where bfestoq.etbcod = 993
                                 and bfestoq.procod = produ.procod
                                        no-lock no-error.

            if not avail bfestoq
            then find first bfestoq where (bfestoq.etbcod >= 1
                                                or bfestoq.etbcod <= 900)
                                      and bfestoq.procod = produ.procod
                                            no-lock no-error.
                                            
            find last movim where movim.procod = produ.procod 
                              and movim.movtdc = 5 
                              use-index datsai no-lock no-error .
            
            find first estac where estac.etccod = produ.etccod
                            no-lock no-error. 
           
            find first temporada where temporada.temp-cod = produ.temp-cod
                          no-lock no-error.                   

            
                                    
            release bliped.
            release bpedid.
            release bcompr.
            find last bliped where bliped.procod = produ.procod
                               and bliped.pedtdc = 1
                              no-lock use-index liped2 no-error.

            if avail bliped
            then
            find first bpedid of bliped no-lock no-error.

            if avail bpedid
            then 
            find first bcompr where bcompr.comcod = bpedid.comcod
                                no-lock no-error.
                                
            create tt-produ.
            assign tt-produ.procod = produ.procod
                   tt-produ.codfis = produ.codfis
                   tt-produ.pronom = produ.pronom
                   tt-produ.clacod = produ.clacod.
                   tt-produ.etccod = if produ.etccod = ?
                                     then 0
                                     else produ.etccod.
                   tt-produ.fabcod = produ.fabcod.
                   tt-produ.estcusto = if avail bfestoq then bfestoq.estcusto
                                                        else 0.
            assign tt-produ.catcod   = produ.catcod
                   tt-produ.datexp   = string(produ.datexp,"99/99/9999").
                   
            if avail movim
            then assign tt-produ.dt-ult-ven = string(movim.movdat,"99/99/9999").
            
            assign tt-produ.dt-cad = string(produ.prodtcad,"99/99/9999").
            
            if produ.proseq = 0
            then tt-produ.ativo = yes.
            else tt-produ.ativo = no.
                               
            if avail estac
            then assign tt-produ.etcnom = estac.etcnom.
            
            if avail bfestoq
            then assign
                   tt-produ.precocusto = bfestoq.estcusto
                   tt-produ.precovenda = bfestoq.estvenda.
            
            if avail bcompr
            then assign tt-produ.comcod = bcompr.comcod
                        tt-produ.comnom = bcompr.comnom.
            else assign tt-produ.comcod = 999                
                        tt-produ.comnom = "Desconhecido".
            
   
        if avail temporada
            then assign tt-produ.temp-cod = temporada.temp-cod
                        tt-produ.temp-nom = temporada.tempnom.
            else assign tt-produ.temp-cod = 0
                        tt-produ.temp-nom = "Desconhecido".
        
   
            run montaprodutos.       
                   
        end.

end procedure.


procedure p-meta:

    def var vdtini-aux as date.
    def var vdtfim-aux as date.

    assign vdtini-aux = vdtini - 365
           vdtfim-aux = vdtfim - 365. 

    for each estab where estab.etbcod <= vestab-fim
                      or estab.etbcod >= 900    no-lock.

        if estab.etbcod = 22 then next.
        
        do vdt = vdtini-aux to vdtfim-aux:                            
  
            for each plani where
                     plani.movtdc = 5 and
                     plani.etbcod = estab.etbcod and
                     plani.pladat = vdt
                                no-lock:
     
                for each movim where
                         movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod
                                      no-lock.
                         
                    release produ.                                        
                    find first produ of movim no-lock no-error.
                    
                    release tt-meta.
                    find first tt-meta where tt-meta.etbcod = movim.etbcod
                                        and tt-meta.codSubClasse = produ.clacod
                                        and tt-meta.mes     = month(vdt)
                                        and tt-meta.ano     = year(vdt) + 1
                                                        no-lock no-error.
                    
                    if not avail tt-meta
                    then create tt-meta.
                   
                    assign tt-meta.etbcod       = movim.etbcod
                           tt-meta.codSubClasse = produ.clacod
                           tt-meta.mes          = month(vdt)
                           tt-meta.ano          = year(vdt) + 1
                           tt-meta.meta         = tt-meta.meta
                                                + (movim.movpc * movim.movqtm).
                
                end.
                
            end.
            
        end.

    end.      

end procedure.

procedure p-copia-arquivos-crm-oracle:

    def var vdircrm as char.
    def var v-comando  as char.

    output stream debug close.
    output stream debug to value(vdirsaida + "debug.csv") append.          

    assign vdircrm = "/admcom/carga_admcom/".

    assign v-comando = "cp " + vdirsaida + "bi_notaprod.csv "
                               + vdircrm + "bi_notaprod.csv -f".

    put stream debug unformatted
    v-comando skip.
    
    unix silent value(v-comando).

    assign v-comando = "cp " + vdirsaida + "bi_nota.csv "
                               + vdircrm + "bi_nota.csv -f".
          
    put stream debug unformatted
        v-comando skip.
              
          
    unix silent value(v-comando).
                         
                 
    assign v-comando = "cp " + vdirsaida + "bi_produtos.csv "
                               + vdircrm + "bi_produtos.csv -f".

    
    put stream debug unformatted
         v-comando skip.
                
    unix silent value(v-comando).
        
    output stream debug close.

end procedure.



/*************************************************************
**************************************************************
****  Geração de Títulos e chmod passaram para a parte    ****
****  de cima do programa mas continuam sendo executados  ****
****  no final do processo.                               ****
**************************************************************
**************************************************************/



output to "/admcom/lebesintel/bi_canceladas.csv".                              
                                                                               
                                                                               for each estab no-lock.                                                        
for each plani where plani.etbcod = estab.etbcod and plani.movtdc= 45 
and plani.pladat >= today - 357 no-lock.                                                           
                                                                                  for each movim where movim.etbcod = plani.etbcod and                                                   movim.movtdc = plani.movtdc and                                                 movim.placod = plani.placod no-lock.                      

put  movim.etbcod ";" YEAR(plani.pladat) format "9999" "-" MONTH(plani.pladat) 
format "99" "-" DAY(plani.pladat) format "99" ";" plani.placod format          
">>>>>>>>>9" ";"  movim.procod ";0;0;0;0;0;0;0;0;0;0;0;0;0;0;" skip .          
                                                                               
                                                                               end.                                                                           
end.                                                                           
end. 
                                                                        
                                                                                                                                               
                                                                        
 run /admcom/progr/bsi-eiscob-diario.p.
 

 
                                                                 
                                                                
 
 
 
