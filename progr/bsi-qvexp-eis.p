{/admcom/progr/admcab-batch.i new}
{/admcom/progr/admcom_funcoes.i new}       

sparam = SESSION:PARAMETER.

def var vsp as char init ";".
def var i as int. 



def var vdt as date.
def var vdirsaida as char.
def var vtodosprodutos as log.
def var vmovdes as dec.
def var vmovacf as dec. 

def var val_fin  like plani.platot.                    
def var val_des  like plani.platot.   
def var val_dev  like plani.platot.   
def var val_acr  like plani.platot. 
def var val_com  like plani.platot.

def var v-valor like plani.platot.

def var v-val-venda-aux  as decimal.
def var v-val-compra-aux as decimal.
def var v-val-ped-aux    as decimal.

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
                                          
def var vint-total-dias-atraso as int.                                         
def var vdat-maior-atraso-aux as date. 

def var vidade as int.

def var vcalclim         as dec.
def var vpardias         as dec. 
def var limite-disponivel as dec.
                 
def var vopcnom as char.
def var vestab-fim as integer.

.

def var vdtini as date.
def var vdtfim as date.     

vdtini = date(int(substr(sparam,6,2)),int(substr(sparam,4,2)),
                int(substr(sparam,8,4))).

vdtfim = date(int(substr(sparam,14,2)),int(substr(sparam,12,2)),
             int(substr(sparam,16,4))).                       


/*
    vdtini = 03/31/2011.
    vdtfim = 03/31/2011.
*/

    vdirsaida = "/var/www/drebes/intranet/eis_nuvem/arquivos/". 
    vtodosprodutos = no.
    vestab-fim = 201.


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
def stream clien.
def stream meta.

def stream debug .

def stream log.
  




def temp-table tt-meta
    field etbcod          as integer
    field codSubClasse    as integer
    field mes             as integer
    field ano             as integer
    field meta            as dec
       index idx01 is primary unique etbcod codSubClasse mes ano.


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
                                


def temp-table tt-estoq                
    field etbcod   like estoq.etbcod   
    field procod   like estoq.procod   
    field estatual like estoq.estatual 
    field codsubclasse like produ.clacod
        index idx01 etbcod procod.         
                


def temp-table tt-subcaract                
    field caraccod like caract.carcod 
    field caracnom like caract.cardes 
        index idx01 caraccod.               
            


def temp-table tt-procarac                
    field caraccod like procaract.subcod 
    field procod   like procaract.procod   
        index idx01 procod caraccod.          
            

def temp-table tt-movim               
    field etbcod    like movim.etbcod 
    field pladat    like plani.pladat 
    field planum    like plani.placod 
    field procod    like movim.procod 
    field movqtm    like movim.movqtm 
    field movpc     like movim.movpc  
    field movdes    like movim.movdes 
    field movcust   like movim.movctm
    field movicm    like movim.movicm 
    field movtot    like plani.platot 
    field vencod    like func.funcod
    field vendedor  like func.funnom
    field tipmov    as char 
    field crecod    as integer
    field planobiz  as character
    field clicod    as integer
    field serie     as char
      index idx01 etbcod                
      index idx02 etbcod procod
      index idx03 etbcod asc planum asc movtot desc
      index idx_pk is primary unique etbcod planum procod.        
      

def temp-table tt-plani              
    field etbcod like plani.etbcod   
    field serie  like plani.serie
    field pladat like plani.pladat   
    field planum like plani.placod   
    field platot like plani.platot   
    field vencod as char  
    field tipmov as char   
    field clicod like plani.desti   
      index idx01 etbcod
      index idx_pk is primary unique etbcod planum serie.

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
    field limite-fx   as char
    field renda       as dec                    
    field renda-fx    as char
    field tem-email   as char
    field email       as char                     
  /*field residencia as char */                
  /*field tem-carro as char */                 
    field qtd-tit-pag    as integer
    field val-tit-pag    as dec
    field qtd-tit-venc-30   as int
    field val-tit-venc-30   as dec
    field qtd-tit-venc#30   as int
    field val-tit-venc#30   as dec
    field qtd-tit-a-venc as int
    field val-tit-a-venc as dec
    field novacao        as logical
    field atraso-med     as int
    field maior-atraso   as int
    field qtd-contratos  as int
    index iclicod is primary unique clicod.    

def buffer grupo for Clase.
def buffer sClase for Clase.

def temp-table tt-fabri
    field fabcod like fabri.fabcod
    field fabnom like fabri.fabnom
    index idx01 fabcod.
    
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
    field clacod like Clase.clacod
    field catcod like produ.catcod
    
    field fabcod like produ.fabcod
    field estcusto like estoq.estcusto
    field etccod as int
    field subcod as char
    
    field precocusto like estoq.estcusto
    field precovenda like estoq.estvenda
    
    index iprodu is primary unique procod.


def temp-table tt-planobiz
    field crecod as integer
    index idx01 crecod.


for each tabaux where tabaux.tabela = "PlanoBiz" no-lock:

    create tt-planobiz.
    assign tt-planobiz.crecod = integer(tabaux.valor_campo).    

end.


run p-carrega-tt.

run p-gera-arquivos.




procedure p-carrega-tt:
    
  /*  run estoque.*/
    
    
    run notas.
    
    /***********************  SOMENTE DREBES   **************************/
    /* Ajustar diferençdo rateio de valores entre o Plani e Movim  */
    
    run p-ajusta-diferenca.
    
    run produtos.
    
    run p-compras.
    /*  
    run p-meta.
    */
end procedure.

procedure notas.


hide message no-pause.



output stream log   to value("/var/www/drebes/progress/log.txt").

def var vmovctm as dec.    
def var vi as int.
def var vtipo-nota as character.

for each estab where estab.etbcod <= vestab-fim
                  or estab.etbcod >= 1000    no-lock.
        /*
        if estab.etbcod = 55 or
           estab.etbcod = 14
        then next.    
         */
         
    for each tipmov where tipmov.movtdc = 5
                   /*  or tipmov.movtdc = 4 */  no-lock.
            /*
            if tipmov.movtdc = 5 /* or
               tipmov.movtdc = 4 */
            then.
            else next.   
            */
        do vdt = vdtini to vdtfim:

                
            /*
             put stream log
                "Estab: "
                 estab.etbcod
                " Data da nota: "
                 vdt
               " Hora: "
                 string(time,"HH:MM:SS") skip.

            */

        for each plani where 
                plani.movtdc = tipmov.movtdc and
                plani.etbcod = estab.etbcod and
                plani.pladat = vdt   
                         no-lock:
                         
                find last clien where clien.clicod = plani.desti
                                    no-lock no-error.
                         
                find first func  where func.etbcod = plani.etbcod                                                  and func.funcod = plani.vencod
                                            no-lock no-error.
                
                /*
                assign vdescarta = no.
                
                bl_testa_categ:
                for each bf-movim where bf-movim.etbcod = plani.etbcod
                                    and bf-movim.placod = plani.placod
                                    and bf-movim.movtdc = plani.movtdc
                                    and bf-movim.movdat = plani.pladat no-lock,
                                    
                    first bf-produ where bf-produ.procod = bf-movim.procod
                                                    no-lock:      
                    
                               
                    if bf-produ.catcod <> 31
                        and bf-produ.catcod <> 35
                        and bf-produ.catcod <> 41
                        and bf-produ.catcod <> 45
                    then do:
                        
                        assign vdescarta = yes.                                
                        leave bl_testa_categ.
                        
                    end.
                                                    
                end.                                    
                
                
                if vdescarta
                then next.
                */
                vopcnom = tipmov.movtnom.
                /*
                if plani.movtdc = 5 and
                   (plani.serie <> "V" and
                     plani.serie <> "U" )
                then next.
                */
            run montalojas (plani.etbcod).
            /*
            run montavendedores (plani.etbcod,plani.vencod).
            */
                            
            vi = vi + 1.
            
            vtipo-nota = "".
            
            if tipmov.movtdc = 4
            then vtipo-nota = "E".
            else if tipmov.movtdc = 5
                 then vtipo-nota = "V".
            /*     
            assign val_acr = 0
                   val_des = 0
                   v-valor = 0.
                 
            if plani.biss > (plani.platot - plani.vlserv)
            then assign val_acr = plani.biss -
                                     (plani.platot - plani.vlserv).
            else val_acr = plani.acfprod.

            if val_acr < 0 or val_acr = ?
            then val_acr = 0.
                        
            assign val_des = plani.descprod.
                                    
            assign
                 v-valor = (plani.platot - /* plani.vlserv -*/
                                    val_des + val_acr).
                                    
            */
            
            if plani.biss > 0
            then v-valor = plani.biss.
            else v-valor = plani.platot - plani.vlserv.
            
            create tt-plani.
            assign tt-plani.etbcod = plani.etbcod
                   tt-plani.pladat = plani.pladat
                   tt-plani.planum = plani.placod
                   tt-plani.platot = v-valor
                   tt-plani.vencod = string(plani.etbcod) + "|"
                                         + string(plani.vencod)
                   tt-plani.tipmov = vtipo-nota
                   tt-plani.clicod = plani.desti
                   tt-plani.serie  = plani.serie.

                
                find clien where clien.clicod = plani.desti no-lock no-error.
                if not avail clien
                then /* next */ .
                else do:
                
                find tt-cid where tt-cid.cidnom = clien.cidade[1] 
                              and tt-cid.bairro = clien.bairro[1] no-error.
                if not avail tt-cid
                then do:
                    find first cidade where cidade.cidnom = clien.cidade[1] 
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
               
                find first tt-cli where tt-cli.clicod = plani.desti
                                    no-lock no-error.
                if not avail tt-cli and plani.desti > 3
                then do:
                    /*
                    if not avail clien
                    then find last clien where clien.clicod = plani.desti
                                    no-lock no-error.
                    */
                    run p-cliente.
            
                end.
               

            for each movim where
                movim.etbcod = plani.etbcod and
                movim.placod = plani.placod and
		movim.movdat = plani.pladat 
                no-lock.
                
                find last produ of movim no-lock.
                find last Clase of produ no-lock.
                /*
                if produ.catcod <> 31
                   and produ.catcod <> 35
                   and produ.catcod <> 41
                   and produ.catcod <> 45
                then next.
                */                            
                assign vmovdes = 0
                       vmovacf = 0. 
                 
                if movim.movctm = ?
                then do:
                        find estoq where estoq.etbcod = plani.etbcod and
                                         estoq.procod = movim.procod no-lock no-error.
                        if avail estoq
                        then vmovctm = estoq.estcusto.
                        else vmovctm = 0.
                                            
                end.
                else vmovctm = movim.movctm.
                /***********
                    vmovdes = (if plani.descprod <> 0
                             then (if (((movim.movqtm * movim.movpc) / plani.platot) *
                                      (plani.descprod)) > 0
                                   then (((movim.movqtm * movim.movpc) / plani.platot) *
                                        (plani.descprod))
                                   else 0)
                             else 0).
                    
                    vmovacf = (if (plani.biss - plani.platot) > 0
                               then ((movim.movqtm * movim.movpc) /                                                   plani.platot) * (plani.biss -                                                     plani.platot)
                               else 0).
                             
                *******/        
                /*
                val_fin = 0.                    
                val_des = 0.   
                val_dev = 0.   
                val_acr = 0. 
                         
                val_acr =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                                plani.acfprod.
                if val_acr = ? then val_acr = 0.
            
                val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                                plani.descprod.
                if val_des = ? then val_des = 0.
                val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                                plani.vlserv.
                if val_dev = ? then val_dev = 0.
                if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
                then
                       val_fin =  ((((movim.movpc * movim.movqtm) - val_dev -                                         val_des)/
                            (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).
                if val_fin = ? then val_fin = 0.
            
                val_com = (movim.movpc * movim.movqtm) - val_dev - val_des
                            + val_acr + val_fin. 

                if val_com = ? then val_com = 0.
             
             */   
    
            val_fin = 0.                   
            val_des = 0.  
            val_dev = 0.  
            val_acr = 0. 
            val_com = 0.
                         
            val_acr =  round(((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.acfprod,2).
            if val_acr = ? then val_acr = 0.
            
            val_des =  round(((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.descprod,2).
            if val_des = ? then val_des = 0.
            
            val_dev =  round(((movim.movpc * movim.movqtm) / plani.platot) * 
                           plani.vlserv,2).
            if val_dev = ? then val_dev = 0.
                
            if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
            then
             val_fin =  round(((((movim.movpc * movim.movqtm) - val_dev - val_des) /
                            (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des),2).
            if val_fin = ? then val_fin = 0.
                val_com = round((movim.movpc * movim.movqtm) - val_dev - val_des
                            + val_acr + val_fin,2). 

            if val_com = ? then val_com = 0.
             
               
                create tt-movim.
                assign tt-movim.etbcod = plani.etbcod
                       tt-movim.pladat = plani.pladat
                       tt-movim.planum = plani.placod
                       tt-movim.procod = movim.procod
                       tt-movim.movicm = movim.movicm
                       tt-movim.movqtm = movim.movqtm
                       tt-movim.movtot = val_com
                       tt-movim.movcust = vmovctm
                       tt-movim.movdes = val_des
                       tt-movim.movpc  = movim.movpc
                       tt-movim.vencod = plani.vencod
                       tt-movim.crecod = plani.pedcod
                       tt-movim.serie  = plani.serie.
                       
                       if can-find(first tt-planobiz
                                   where tt-planobiz.crecod = tt-movim.crecod)
                       then assign tt-movim.planobiz = "Sim".
                       else assign tt-movim.planobiz = "Nao".
                                  
                       if avail func                               
                       then assign tt-movim.vendedor = func.funnom.
                                                                          
                       assign                                      
                       tt-movim.tipmov = vtipo-nota
                       tt-movim.clicod = plani.desti.

                run p-carrega-tt-produtos.
                    
            end.
            
            end.
            
            
        end.
    end.
end.            
/*
output stream plani close.
output stream movim close.
*/
end procedure.




procedure produtos.

   
     
    
    for each tt-produ where tt-produ.procod > 0 use-index iprodu no-lock.
        
        for each procaract where procaract.procod = tt-produ.procod no-lock.
        
            create tt-procarac.                                
            assign tt-procarac.caraccod = procaract.subcod
                   tt-procarac.procod   = procaract.procod. 

        end.    
    end.
    
end procedure.
          /*
procedure monta-Clase-desconhecida.
  
        
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
            */
procedure montaprodutos.
  
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
    
                 

    for each subcaract where subcaract.subcod > 0 use-index subcod no-lock:

        create tt-subcaract.                             
        assign tt-subcaract.caraccod = subcaract.subcar   
               tt-subcaract.caracnom = subcaract.subdes.  

    end.
    
end procedure.

procedure montalojas.
      
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

/*
procedure estoque:

 
    for each estab where estab.etbcod <= vestab-fim no-lock,
 
        each estoq where estoq.etbcod = estab.etbcod no-lock,
        
        first produ where produ.procod = estoq.procod
                      and produ.catcod <> 91  no-lock:
        
        run p-carrega-tt-produtos.

        run montalojas (estab.etbcod).

        create tt-estoq.
        assign tt-estoq.etbcod   = estoq.etbcod
               tt-estoq.procod   = estoq.procod
               tt-estoq.estatual = estoq.estatual
               tt-estoq.codsubclasse = produ.clacod.

 
    end.

end procedure.
*/


procedure p-compras:

    def var vcont  as integer.
    
    def var vmovctm as decimal.
    
    assign vmovctm = 0.
    
    assign
     vmovdes = dec(0).
   
    
    bl_pedid:
    for each estab where estab.etbcod >= 9995 no-lock,
    
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
                       
            create tt-movim.
            assign tt-movim.etbcod = liped.etbcod
                   tt-movim.pladat = pedid.peddtf
                   tt-movim.planum = pedid.pednum
                   tt-movim.procod = liped.procod
                   tt-movim.movicm = 0
                   tt-movim.movqtm = vqtdped-aux
                   tt-movim.movtot = (vqtdped-aux * liped.lippreco)
                   tt-movim.movcust = 0
                   tt-movim.movdes  = 0
                   tt-movim.movpc   = 0
                   tt-movim.tipmov  = "P".
                          
        end.

        create tt-plani.
        assign tt-plani.etbcod = pedid.etbcod
               tt-plani.pladat = pedid.peddtf
               tt-plani.planum = pedid.pednum
               tt-plani.platot = pedid.pedtot
               tt-plani.vencod = string(pedid.comcod)
               tt-plani.tipmov = "P".
    
         
    end.

end procedure.







/*
#######################################################################################################################
#######################################################################################################################

*/



procedure p-gera-arquivos:
    
 
    
    /*****************************  Estab  ******************************************/
    
    output stream estab to value(vdirsaida + "bi_lojas.csv").
    put stream estab unformatted skip
         "CodLoja;Loja;CidadeLoja;EstadoLoja;CodRegiao;Regiao;NomeRed"
                   skip.  

    for each tt-estab where tt-estab.etbcod > 0 use-index x,
    
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
    
    /*****************************  Plani  ******************************************/

/*
    output stream plani to value(vdirsaida + "bi_nota.csv").
    put stream plani unformatted
        "CodLoja;DataVenda;Nota;Cliente;Vendas;CodVendedor;TipoMovimento"
        skip.

 
    
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
            tt-plani.planum vsp
            tt-plani.clicod vsp
            tt-plani.platot vsp
            tt-plani.vencod vsp
            tt-plani.tipmov skip.

    end.

    output stream plani close.
    */
    

    /************************  Movim  *************************************/
    
    output stream movim to value(vdirsaida + "bi_notaprod.csv").
    put stream movim unformatted
        "CodLoja;DataVenda;Nota;CodProduto;"  
        "QuantidadeVenda;PrecoUnitario;ValorProdutos;Descontos;"  
        "Custo;ICMS;QtdDevolucao;Devolucao;QtdPedidos;ValPedidos;" 
        "QuantidadeCompra_c;PrecoUnitario_c;ValorProdutos_c;Custo_c;"
        "ChVendaaux;CodVendedor;Vendedor;Plano;PlanoBiz;Cliente;Serie" skip. 
    
    assign vqtd-dev       = 0
           vqtd-comp      = 0
           vqtd-ped       = 0
           vval-dev       = 0
           vval-comp      = 0
           vval-ped       = 0
           vcusto-comp    = 0
           vprc-unit-comp = 0
           vprc-unit-vend = 0
           vchav-vend-aux = "".


  
    

    for each tt-movim where tt-movim.etbcod > 0 use-index idx_pk no-lock:
      
        assign vchav-vend-aux = "".

        case (tt-movim.tipmov):
        
        when "V" then assign vqtd-vend      = tt-movim.movqtm
                             vqtd-dev       = 0
                             vqtd-comp      = 0
                             vqtd-ped       = 0
                             vval-vend      = tt-movim.movtot
                             vval-dev       = 0
                             vval-comp      = 0
                             vval-ped       = 0
                             vcusto-vend    = tt-movim.movcust
                             vdesc-vend     = tt-movim.movdes
                             vcusto-comp    = 0
                             vprc-unit-comp = 0
                             vprc-unit-vend = tt-movim.movpc
                             vchav-vend-aux = string(tt-movim.etbcod)
                                               + "|" + string(tt-movim.pladat) 
                                               + "|" + string(tt-movim.planum).
        
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
                             vcusto-comp    = tt-movim.movcust
                             vprc-unit-comp = tt-movim.movpc
                             vprc-unit-vend = 0
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
                             vchav-vend-aux = "".
                             
        end case.
        
        put stream movim unformatted
             tt-movim.etbcod   vsp
             tt-movim.pladat   vsp
             tt-movim.planum   vsp
             tt-movim.procod   vsp
             vqtd-vend                                           vsp
             vprc-unit-vend                                      vsp
          /*(tt-movim.movpc * tt-movim.movqtm) - tt-movim.movdes vsp */
             vval-vend                  vsp
             vdesc-vend                 vsp
             vcusto-vend                vsp
             tt-movim.movicm            vsp
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
               skip.
        
    end.

    output stream movim close.
    
    /*************************  Produ  ***********************************/

/*

    output stream produ to value(vdirsaida + "bi_produtos.csv").
    put stream produ unformatted skip
         "CodProduto;Produto;PrecoCusto;PrecoVenda;"
        "CodSubClasse;SubClasse;CodClasse;Classe;CodGrupo;Grupo;CodSetor;Setor;"
         "CodFabricante;Fabricante;CodDepto;Depto;CodSubCaracteristica;SubCaracteristica;"
               skip.

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
                  where tt-departamento.catcod = tt-setor.setsup
                                         no-lock no-error.
        
        find first tt-procarac where tt-procarac.procod = tt-produ.procod
                                         no-lock no-error.
        
        if avail tt-procarac
        then 
        find first tt-subcaract where tt-subcaract.caraccod = tt-procarac.caraccod
                            no-lock no-error.
     
                              
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
             
        if avail tt-subcaract
        then
             put stream produ unformatted
             tt-subcaract.caraccod  vsp
             tt-subcaract.caracnom  vsp.
        else put stream produ unformatted
             vsp vsp.
             
        put stream produ unformatted
             skip.
             
    end.

    output stream produ close.   
    
    */
    
    
    

    /*****************************  Estoq  ******************************************/

    /*
    output stream estoq
        to value(vdirsaida + "bi_estpro.csv").

    put stream estoq unformatted
        "CodLoja"
        vsp
        "CodProduto"
        vsp
        "Estoque"
        vsp
        "CodSubClasseMeta"
         skip.

        
    for each tt-estoq no-lock:

        put stream estoq unformatted    
            tt-estoq.etbcod   vsp
            tt-estoq.procod   vsp
            tt-estoq.estatual  vsp
            tt-estoq.codsubclasse skip.


    end.               

    output stream estoq close.
    */
    
    
    
    
    output stream clien
          to value(vdirsaida + "bi_clientes.csv").
    
    put stream clien unformatted
        "clicod;clinom;sexo;estadocivil;profissao;cidade;"
        "bairro;datanascimento;email;celular;endereco;"
        "num;complemento;uf;cep;renda;limite;"
        "limite_fx;renda_fx;qtd_titulos_pagos;val_titulos_pagos;"
        "qtd_titulos_vencidos_menos_30;val_titulos_vencidos_menos_30;"
        "qtd_titulos_vencidos_mais_30;val_titulos_vencidos_mais_30;"
        "qtd_tit_a_vencer;val_tit_a_vencer;"
        "novacao;atraso_medio;maior_atraso;qtd_contratos;"
        "tem_email;tem_celular;idade_fx;" skip.
    
    for each tt-cli where tt-cli.clicod > 0 use-index iclicod no-lock:
    
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
            tt-cli.dtnasc 
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
            tt-cli.limite-fx     
            vsp
            tt-cli.renda-fx      
            vsp
            tt-cli.qtd-tit-pag   
            vsp
            tt-cli.val-tit-pag   
            vsp
            tt-cli.qtd-tit-venc-30  
            vsp
            tt-cli.val-tit-venc-30  
            vsp
            tt-cli.qtd-tit-venc#30
            vsp
            tt-cli.val-tit-venc#30
            vsp
            tt-cli.qtd-tit-a-venc
            vsp
            tt-cli.val-tit-a-venc
            vsp
            tt-cli.novacao       
            vsp
            tt-cli.atraso-med    
            vsp
            tt-cli.maior-atraso  
            vsp
            tt-cli.qtd-contratos 
            vsp
            tt-cli.tem-email
            vsp
            tt-cli.tem-celular
            vsp
            tt-cli.idade-fx
            vsp
            skip.
            
    end.
    
    output stream clien close.
    
  

    
end procedure.



procedure p-cliente:
    
    if clien.clicod <= 3
    then return.        
            
    assign vint-total-dias-atraso = 0
           vcalclim               = 0
           vpardias               = 0
           limite-disponivel      = 0.
    
                    create tt-cli.
                    assign tt-cli.clicod = clien.clicod
                           tt-cli.clinom = clien.clinom
                           tt-cli.cidade = clien.cidade[1].

                    assign tt-cli.cidade = replace(tt-cli.cidade,";","").

                    if clien.dtnasc = ?
                    then tt-cli.dtnasc = 01/01/1970.
                    else tt-cli.dtnasc = clien.dtnasc.

      vidade = (today - clien.dtnasc) / 365.

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
                                   else clien.proprof[1]).
                    
                    tt-cli.prof = replace(tt-cli.prof,";","").
                    
                    if clien.fax begins "9" or
                       clien.fax begins "8" or
                       clien.fax begins "519" or
                       clien.fax begins "518" or
                       clien.fax begins "549" or 
                       clien.fax begins "548" 
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
                 
                    if tt-cli.celular = ""
                    then tt-cli.tem-cel = "N".
                    else tt-cli.tem-cel = "S".
            
                    tt-cli.bairro = clien.bairro[1].
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
                    tt-cli.ufecod = clien.ufecod[1].
                    
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
                                 then clien.endereco[1]
                                 else "".
                
                    tt-cli.num = if (string(clien.numero[1])) <> ? 
                                 then (string(clien.numero[1]))
                                 else "".
                
                    tt-cli.compl = if (string(clien.compl[1])) <> ? 
                                   then (string(clien.compl[1])) 
                                   else "".
                
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
    
    assign tt-cli.email = clien.zona.
            
    if tt-cli.email <> ""
    then tt-cli.tem-email = "Sim".
    else tt-cli.tem-email = "Nao".       
    
    if tt-cli.celular <> ""
    then tt-cli.tem-celular = "Sim".
    else tt-cli.tem-celular = "Nao".

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
    
    assign tt-cli.maior-atraso = today - vdat-maior-atraso-aux.
    
    tt-cli.atraso-med = vint-total-dias-atraso / tt-cli.qtd-tit-venc#30.
    
    if tt-cli.atraso-med = ?
    then assign tt-cli.atraso-med = 0.
    
    /*
    if connected("dragao")
    then do:
        run /var/www/drebes/progress/calccredscore.p(input "Tela",
                            input recid(clien),
                            output vcalclim,
                            output vpardias,
                            output limite-disponivel).

    end.
    */
    
    assign limite-disponivel = clien.limcrd.
    
    if clien.prorenda[1] > clien.prorenda[2]
    then assign tt-cli.renda = clien.prorenda[1].
    else assign tt-cli.renda = clien.prorenda[2].
    
    if tt-cli.renda <= 500
    then assign tt-cli.renda-fx = "Até00".
    else if tt-cli.renda > 500 and tt-cli.renda <= 1000
      then assign tt-cli.renda-fx = "501 a 1.000".
      else if tt-cli.renda > 1000 and tt-cli.renda <= 1500
        then assign tt-cli.renda-fx = "1.001 a 1.500".
        else if tt-cli.renda > 1500 and tt-cli.renda <= 2000
          then assign tt-cli.renda-fx = "1.501 a 2.000".
          else if tt-cli.renda > 2000 and tt-cli.renda <= 3000
            then assign tt-cli.renda-fx = "2.001 a 3.000".
            else if tt-cli.renda > 3000 and tt-cli.renda <= 4000
              then assign tt-cli.renda-fx = "3.001 a 4.000".
              else if tt-cli.renda > 4000 and tt-cli.renda <= 5000
                then assign tt-cli.renda-fx = "4.001 a 5.000".
                else if tt-cli.renda > 5000
                  then assign tt-cli.renda-fx = "Mais de 5.001".
           
    tt-cli.limite      = limite-disponivel.
    
    if limite-disponivel <= 500
       then assign tt-cli.limite-fx = "Até00".
       else if limite-disponivel > 500 and limite-disponivel <= 1000
         then assign tt-cli.limite-fx = "501 a 1.000".
         else if limite-disponivel > 1000 and limite-disponivel <= 1500
           then assign tt-cli.limite-fx = "1.001 a 1.500".
           else if limite-disponivel > 1500 and limite-disponivel <= 2000
             then assign tt-cli.limite-fx = "1.501 a 2.000".
             else if limite-disponivel > 2000 and limite-disponivel <= 3000
               then assign tt-cli.limite-fx = "2.001 a 3.000".
               else if limite-disponivel > 3000 and limite-disponivel <= 4000
                 then assign tt-cli.limite-fx = "3.001 a 4.000".
                 else if limite-disponivel > 4000 and limite-disponivel <= 5000
                   then assign tt-cli.limite-fx = "4.001 a 5.000".
                   else if limite-disponivel > 5000
                     then assign tt-cli.limite-fx = "Mais de 5.001".

    
    for each fin.contrato where fin.contrato.clicod = clien.clicod
                                       no-lock.
        
        tt-cli.qtd-contratos = tt-cli.qtd-contratos + 1.

    end.

end procedure.


procedure p-carrega-tt-produtos:
        
        if not can-find(first tt-produ
                        where tt-produ.procod = produ.procod)
        then do:

            release bfestoq.
            find first bfestoq where bfestoq.etbcod = 993
                                 and bfestoq.procod = produ.procod
                                        no-lock no-error.

            create tt-produ.
            assign tt-produ.procod = produ.procod
                   tt-produ.pronom = produ.pronom
                   tt-produ.clacod = produ.clacod.
                   tt-produ.etccod = if produ.etccod = ?
                                     then 0
                                     else produ.etccod.
                   tt-produ.fabcod = produ.fabcod.
                   tt-produ.estcusto = estoq.estcusto.
                   tt-produ.catcod   = produ.catcod.
            if avail bfestoq
            then assign
                   tt-produ.precocusto = bfestoq.estcusto
                   tt-produ.precovenda = bfestoq.estvenda.
            
            run montaprodutos.       
                   
        end.

end procedure.


procedure p-ajusta-diferenca:

    def var v-total-movims   like plani.platot.
    def var v-diferenca      like plani.platot.
    def var v-diferenca-aux  like plani.platot.
    def var v-diferenca-aux2 like plani.platot.

    def var vperc          as decimal.

    def buffer btt-movim for tt-movim.
    def buffer ctt-movim for tt-movim.
    def buffer dtt-movim for tt-movim.

    def var vsoma-plani-aux like plani.platot.
    def var vsoma-movim-aux like plani.platot.

    assign vsoma-plani-aux = 0
           vsoma-movim-aux = 0.

    for each tt-plani where tt-plani.etbcod > 0 use-index idx_pk no-lock:

        assign v-total-movims  = 0
               v-diferenca     = 0
               v-diferenca-aux = 0
               vperc           = 0.
        
      /*  put stream debug unformatted
        tt-plani.etbcod
        vsp
        tt-plani.planum
        vsp
        tt-plani.platot
        vsp.
        */
        
        assign vsoma-plani-aux = vsoma-plani-aux + tt-plani.platot.

      

        for each tt-movim where tt-movim.etbcod = tt-plani.etbcod
                            and tt-movim.planum = tt-plani.planum no-lock:
                            
            assign v-total-movims = v-total-movims + tt-movim.movtot.

        end.
        
        assign v-total-movims = round(v-total-movims,2).
        
        /* put stream debug unformatted
        v-total-movims vsp.*/
    

        if tt-plani.platot <> v-total-movims
        then do:
        
            assign v-diferenca     = tt-plani.platot - v-total-movims
                   v-diferenca-aux = tt-plani.platot - v-total-movims
                   vsoma-movim-aux = 0.
        
            for each btt-movim where btt-movim.etbcod = tt-plani.etbcod
                                 and btt-movim.planum = tt-plani.planum                                                     exclusive-lock:

              assign vperc = round((btt-movim.movtot * 100) / v-total-movims,2).
              if vperc = 0 or vperc = ?
              then vperc = 100.

          assign btt-movim.movtot = round(((vperc * tt-plani.platot) / 100),2).              
              if btt-movim.movtot <> ?
              then   
              assign vsoma-movim-aux = vsoma-movim-aux + btt-movim.movtot. 
              
              /*
              assign v-diferenca-aux = round(v-diferenca -
                                        ((vperc * v-diferenca) / 100),2).
              */
              
            end.
            
            
            if vsoma-movim-aux <> tt-plani.platot /*and v-diferenca-aux < 1*/
            then do:
            
                assign v-diferenca-aux2 = 0.
                
                find first ctt-movim where ctt-movim.etbcod = tt-plani.etbcod
                                       and ctt-movim.planum = tt-plani.planum
                                    /*   and ctt-movim.movtot > 0 */
                                                    use-index idx03
                                                    exclusive-lock no-error .                                                    
                if avail ctt-movim then do:
                
                    if vsoma-movim-aux > tt-plani.platot
                    then do:
                       assign v-diferenca-aux2 = round(vsoma-movim-aux
                                                    - tt-plani.platot,2).
                        
                        assign ctt-movim.movtot = round(ctt-movim.movtot
                                      - (v-diferenca-aux2),2).
                                      
                    end.                  
                    else do:
                    
                        assign v-diferenca-aux2 = round(tt-plani.platot
                                                        - vsoma-movim-aux,2).
                    
                        assign ctt-movim.movtot = round(ctt-movim.movtot
                                                    + (v-diferenca-aux2),2).
                                     
                    end.
                    
                end.

            end.
            
        end.

        
  

        assign v-total-movims = 0.

        for each dtt-movim where dtt-movim.etbcod = tt-plani.etbcod
                             and dtt-movim.planum = tt-plani.planum no-lock:

            /*
            assign vsoma-movim-aux = vsoma-movim-aux + dtt-movim.movtot.
            */
            assign v-total-movims = v-total-movims + dtt-movim.movtot.
            
        end.
        
      /*  put stream debug unformatted
          v-total-movims vsp .*/
        
        assign v-total-movims = round(v-total-movims,2).
        
   /* put stream debug unformatted
            v-total-movims skip.*/
        
        


    end.

end procedure.


procedure p-meta:

    def var vdtini-aux as date.
    def var vdtfim-aux as date.

    assign vdtini-aux = vdtini - 365
           vdtfim-aux = vdtfim - 365. 

    for each estab where estab.etbcod <= vestab-fim
                      or estab.etbcod >= 1000    no-lock.

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

