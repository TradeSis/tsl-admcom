/*#4 11.09.2019 - helio.neto - ajustes regras */
/* #3 21.01.2019 - Helio - Alteração de Regras:
    Alterar regras de Balanco de clientes (calculabalanco.p)
        NOVOS COMPRA A PRAZO vira NOVOS COMPRA com as seguintes regras: 
            -> Não comprou há mais de um ano. 
               Não comprou no ano anterior.
            -> Comprou a prazo ou a vista no mês vigente.(Nota do tipo VVI ou FIN ou Nota do tipo CRE, CP1 ou CP0)
            ->Não se enquadrar no perfil Novos Prospect ou Prospect
        NOVOSCO?MPRA A VISTA vira NOVOS ATIVAÇÃO com as seguintes regras:
            ->Já tinha cadastro na empresa até o mês anterior, como Prospect ou Novo Prospect
            ->Não comprou há mais de um ano . Não comprou no ano anterior
            ->Comprou a prazo ou a vista no mês vigente. (Nota do tipo VVI ou FIN ou Nota do tipo CRE, CP1 ou CP0)
            ->Não se enquadra no perfil Novos Prospect, Prospect ou Novos Compra a Prazo
    */
/* #2 10.10.2018 - Helio - Inclusao de Novas regras para cliente Desativado */
/* #1 26.09.2018 - Helio - Revisao das regras */
/* # Conceitos:
    PERIODO_ATUAL    - Mes Corrente, ou se for dia primeiro, todo mes anterior 
    PERIODO_ANTERIOR - Mes Anterior ao Mes Corrente, ou se for dia primeiro, todo mes anterior 
    
    TEM_VENDA           - Registro na tabela PLANI, com MOVTDC = 5
    TEM_VENDACREDIARIO  - Registro na tabela PLANI, com MOVTDC = 5 e crecod = 2
    TEM_VENDAVISTA      - Registro na tabela PLANI, com MOVTDC = 5 e crecod = 1
    
    TEM_TITULO        - Registro na tabela TITULO, com titnat = no e empcod = 19. 
    
    TEM_VENDA_MES_ATUAL_VISTA     (mesatualvista)  
                    TEM_VENDAVISTA,
                        DENTRO DO PERIODO_ATUAL
                        COM CAMPO PLANI.MODCOD = (VVI ou FIN)
    
    TEM_VENDA_MES_ATUAL_PRAZO     (mesatualprazo)  
                    TEM_VENDAPRAZO,
                        DENTRO DO PERIODO_ATUAL
                        COM CAMPO PLANI.MODCOD = (CRE ou CP1 ou CP0)

    COMPROU_MAISDEUMANO      (comprouantigamente)
                    TEM VENDA
                        ANTERIOR A 365 DIAS DO INICIO DO PERIODO_ATUAL  
                OU
                    TEM TITULO
                        VENCIMENTO ANTERIOR a 365 DIAS DO INICIO DO PERIODO_ATUAL
                        COM CAMPO MODALIDADE = "VVI"
                        COM CAMPO SITUACAO   = "PAG"
                OU
                    TEM TITULO
                        CAMPO DATEXP ANTERIOR A 365 DIAS DO INICIO DO PERIODO_ATUAL
                        COM CAMPO MODALIDADE = "CRE"

    COMPROU_ANOANTERIOR      (comprouanoanterior)
                   TEM_VENDA
                        PERIODO ENTRE 365 DIAS ANTES DO INICIO DO PERIODO_ATUAL
                        ATE O FINAL DO PERIODO_ANTERIOR 
                        COM CAMPO PLANI.MODALIDADE = VVI ou FIN ou CRE ou CP1 ou CP0

    TEM_TITULO_CRE  (qtdtitulostodos)
                   TEM TITULO
                        COM CAMPO MODALIDADE = CRE
                           
    TEM_TITULO_CRE_MESANTERIOR (qtdtitulosmesanterior)
                    TEM TITULO
                        COM CAMPO MODALIDADE = CRE
                        VENCIMENTO DENTRO PERIODO_ANTERIOR
    PROSPECT_MES_ANTERIOR /* #3 */
            Se enquadra nos STATUS de NOVOS PROSPECT ou PROSPECT
            DTCAD <= FINAL PERIODO_ANTERIOR
*/     
/* # Status Possiveis

    /*#2*/
    "DESATIVADO"      - CLIENTE SEM CPF
                     OU NOME (clien.clinom) = TESTE, DESATIVADO ou DESATIVADA
    /*#2*/                 
    "NAO SE ENQUADRA" - DEFAULT, QUANDO NAO PEGAR NENHUMA REGRA
    
    "NOVOS PROSPECT"  - DATA_CADASTRO DENTRO MES ATUAL
                      e NAO TEM_VENDA_MES_ATUAL_VISTA
                      e NAO TEM_VENDA_MES_ATUAL_PRAZO
    
    "PROSPECT"        - NAO COMPROU_MAISDEUMANO
                        NAO COMPROU_ANOANTERIOR
                        NAO TEM_TITULO_CRE
                        NAO TEM_VENDA_MES_ATUAL_VISTA
                        NAO TEM_VENDA_MES_ATUAL_PRAZO 
                          
    "NOVOS COMPRA" - /* #3 "NOVO COMPRA A VISTA" */
                            NAO COMPROU_MAISDEUMANO
                            NAO COMPROU_ANOANTERIOR
                            TEM_VENDA_MES_ATUAL_PRAZO
                            TEM_VENDA_MES_ATUAL_VISTA /* #3 */
                            
    "NOVOS ATIVACAO" - /* #3 "NOVO COMPRA A VISTA" - */
                            PROSPECT_MES_ANTERIOR /* #3 */
                            NAO COMPROU_MAISDEUMANO
                            NAO COMPROU_ANOANTERIOR
                            TEM_VENDA_MES_ATUAL_PRAZO /* #3 */
                            TEM_VENDA_MES_ATUAL_VISTA
                            
    "ATIVO COMPRA A PRAZO" - TEM_VENDAPRAZO
                                DENTRO PERIODO_ATUAL
                                CAMPOS PLANI.MODALIDADE =  CRE ou CP0 ou CP1
                             COMPROU_ANOANTERIOR
                         OU
                            TEM_VENDAPRAZO
                                DENTRO PERIODO INICIO PERIODO_ATUAL - 365 DIAS ATE FINAL PERIODO_ANTERIOR
                                CAMPO  PLANI.MODALIDADE = CRE ou CP0 ou CP1
                         OU
                            APOS VALIDAR RECUPERADO, TEM NOVO TESTE
                                    

    "ATIVO COMPRA A VISTA" - TEM_VENDAVISTA
                                DENTRO PERIODO_ATUAL
                                CAMPOS PLANI.MODALIDADE =  VVI ou FIN
                             COMPROU_ANOANTERIOR
                         OU
                            TEM_VENDAVISTA
                                DENTRO PERIODO INICIO PERIODO_ATUAL - 365 DIAS ATE FINAL PERIODO_ANTERIOR
                                CAMPO  PLANI.MODALIDADE = VVI ou FIN
                         OU 
                            APOS VALIDAR RECUPERADO, TEM NOVO TESTE
                                

    "RECUPERADO COMPRA A PRAZO" - COMPROU_MAISDEUMANO
                                  NAO COMPROU_ANOANTERIOR
                                  TEM_VENDA_MES_ATUAL_PRAZO  
                                  NAO TEM_TITULO_CRE_MESANTERIOR

    "RECUPERADO COMPRA A VISTA" - COMPROU_MAISDEUMANO
                                  NAO COMPROU_ANOANTERIOR
                                  TEM_VENDA_MES_ATUAL_VISTA  
                                  NAO TEM_TITULO_CRE_MESANTERIOR                                   

                        
    "ATIVO COMPRA A PRAZO" -  TEM_VENDAPRAZO

    "ATIVO COMPRA A VISTA" -  TEM_VENDAVISTA

 
    "INADIMPLENTE"          - TEM_TITULO
                                MODALIDADE  = CRE
                                VENCIMENTO ANTERIOR AO FINAL DO PERIODO_ANTERIOR - 90 DIAS
                                SITUACAO        = LIB
                                DATA_PAGAMENTO  = NAO_PREENCHIDA
                          OU 
                              TEM_TITULO
                                MODALIDADE = CP0
                                VENCIMENTO ANTERIOR AO FINAL DO PERIODO_ANTERIOR - 90 DIAS
                                SITUACAO        = LIB
                                DATA_PAGAMENTO  = NAO_PREENCHIDA
                          OU 
                              TEM_TITULO
                                MODALIDADE = CP1
                                VENCIMENTO ANTERIOR AO FINAL DO PERIODO_ANTERIOR - 90 DIAS
                                SITUACAO        = LIB
                                DATA_PAGAMENTO  = NAO_PREENCHIDA
                          
    "ATIVO CONTRATO"        - TEM_TITULO
                                MODALIDADE = CRE
                                SITUACAO   = LIB
                                DATA_PAGAMENTO = NAO_PREENCHIDA
                           OU
                              TEM_TITULO
                                MODALIDADE = CP1
                                SITUACAO   = LIB
                                DATA_PAGAMENTO = NAO_PREENCHIDA
                           OU
                              TEM_TITULO
                                MODALIDADE = CP0
                                SITUACAO   = LIB
                                DATA_PAGAMENTO = NAO_PREENCHIDA

    "INATIVO"               - NAO COMPROU_ANOANTERIOR
                              NAO TEM_VENDA_MES_ATUAL_PRAZO
                              NAO TEM_VENDA_MES_ATUAL_VISTA
                              

    "INATIVOO"              - NAO SE ENQUADROU EM NENHUMA DAS SITUACAO ACIMA                 
    

*/

def var prospectmesanterior as int.
def var vetbcod_aux as char.     
def var contacliente as int.
def var qtdtitulostodos as int.
def var arquivodestino as char.


def var vmes as int.
def var vano as int.                                                             

def var vantini as date.
def var vantfim as date.
def var vatuini as date.
def var vatufim as date.
def var vdata   as date.
def var vtoday as date.


    vtoday = today.
  
    /* #1 Regra - Fecha o mes atual e o mes anterior. Quando for dia Primeiro fecha mes atual como o mes passado ainda */ 
    if day(vtoday) = 01
    then do:
        vatufim = vtoday - 1.
        vatuini = date(month(vatufim),01,year(vatufim)).
        vantfim = vatuini - 1.
        vantini = date(month(vantfim),01,year(vantfim)).
    end.
    else do:
        vdata = vtoday.
        repeat.
            vdata = vdata + 1.
            if month(vdata) <> month(vtoday)
            then leave.
        end.
        vatufim = vdata - 1.
        vatuini = date(month(vatufim),01,year(vatufim)).
        vantfim = vatuini - 1.
        vantini = date(month(vantfim),01,year(vantfim)).
    end.
    vmes = month(vatuini).
    vano =  year(vatuini).

arquivodestino =  "/admcom/lebesintel/balanco/bi_balanco.csv".

output to value(arquivodestino).

contacliente = 0.

def var statuscliente as char format "x(30)".
def var comprouantigamente as int.
def var comprouanoanterior as int.
def var qtdtitulosmesanterior as int.
def var mesatualprazo as int.
def var mesatualvista as int.

def var vcpf as dec.
def var p-cpfok as log.

for each clien /* Use-Index clien */
    where clicod > 10
    no-lock
        by clien.clicod desc. 
    
    /* #Regra - Se a data de Cadastramento for maior que o Mes Atual, desconsidera */
    if clien.dtcad > vatufim  
    then next.

    /*#2*/
        find neuclien where neuclien.clicod = clien.clicod no-lock no-error.
        if not avail neuclien
        then do:
            vcpf = dec(clien.ciccgc) no-error.
            if vcpf = ? or vcpf = 0
            then do:
                statuscliente = "DESATIVADO".
                run rundisp.
                next.                                                               
            end.    
            else do:
                run /admcom/progr/cpf.p (clien.ciccgc, output p-cpfok).
                if not p-cpfok
                then do:
                    statuscliente = "DESATIVADO".
                    run rundisp.
                    next.                                                               
                end.
            end.
        end.
        if clien.clinom = "TESTE" or
           clien.clinom = "DESATIVADO" or
           clien.clinom = "DESATIVADA"
        then do:   
            statuscliente = "DESATIVADO".
            run rundisp.
            next.                                                               
        end.           
    /*#2*/

    statuscliente = "NAO SE ENQUADRA".
    
    /* LOJA DO CLIENTE */

    comprouantigamente = 0.

    /* #Regra - Marca se Cliente Comprou a mais de um ano atras. Independente se comprou no ultimo ano */     
    find first plani where     /* Use-Index plasai */         
        plani.pladat < vatuini - 365 and     
        plani.movtdc = 5 and                
        plani.Desti = clien.clicod              
        no-lock no-error.          
    if avail plani then do: 
        comprouantigamente = 1.                         
    end. 
    else do: 
        comprouantigamente = 0.  
    end.

    /* #Regra - Marca se Cliente Comprou a mais de um ano atras. Independente se comprou no ultimo ano 
                utilizando para isto a verificacao se tem titulo PAGO na modalidade VVI, com vencimento MAIOR que um ano */     
    find first fin.titulo  use-index iclicod 
            where    
          fin.titulo.clifor = clien.clicod and          
          fin.titulo.empcod = 19                        
      and fin.titulo.titnat = no                        
      and fin.titulo.modcod = "VVI"
      and fin.titulo.titsit = "PAG"                                          
      and fin.titulo.titdtven < vatuini - 365                                
                no-lock no-error.                                                                                                                                          if avail titulo then do:                    
        comprouantigamente = 1.                   
    end. 

    /* #Regra - Marca se Cliente Comprou a mais de um ano atras. Independente se comprou no ultimo ano 
                utilizando para isto a verificacao se tem titulo na modalidade CRE, com DATEXP (?) MAIOR que um ano */     
    find first fin.titulo use-index iclicod where      
                       fin.titulo.clifor = clien.clicod and             
                       fin.titulo.empcod = 19                                     
                   and fin.titulo.titnat = no                            
                   and fin.titulo.modcod = "CRE"                         
                   and fin.titulo.datexp < vatuini - 365                
                          no-lock no-error.                          
    if avail titulo then do:                      
        comprouantigamente = 1.                       
    end.                                           
    
    /*comprou ano anterior ao mes */ 
    /* #Regra - Marca se Cliente Comprou ANO ANTERIOR. 
                utilizando para isto a verificacao se tem 
                    PLANI (VENDA) Tipo = 5 no PERIODO de um ano
                    nas MODALIDADES VVI FIN CRE CP1 CP0 eriotitulo na modalidade CRE, com DATEXP (?) MAIOR que um ano */     
    
    comprouanoanterior = 0. 
    
    find first plani where /* use-index plasai */                            
            plani.pladat >= vatuini - 365 and 
            plani.pladat <= vantfim 
            and plani.movtdc = 5 and                       
            plani.Desti = clien.clicod and 
           (   plani.modcod = "VVI"  
            or plani.modcod = "FIN" 
            or plani.modcod = "CRE" 
            or plani.modcod = "CP1"     
            or plani.modcod = "CP0")     
    no-lock no-error.                       
    if avail plani then do:            
        comprouanoanterior = 1.                                                        
    end.                               
    else do:                          
        comprouanoanterior = 0.            
    end.                              
                               
    qtdtitulosmesanterior = 0. 
    
    /* titulos mes anterior */ 
        find first fin.titulo use-index iclicod 
            where                                   
            fin.titulo.clifor = clien.clicod and                      
            fin.titulo.empcod = 19           and 
            fin.titulo.titnat = no           and 
            fin.titulo.modcod = "CRE"        and 
            fin.titulo.titdtven >= vantini and 
            fin.titulo.titdtven <= vantfim
    no-lock no-error.
    if avail titulo 
    then do:                                                          
        qtdtitulosmesanterior = 1. 
    end. 
    else do:   
        qtdtitulosmesanterior = 0.                                                               
    end.                                                           
    
    qtdtitulostodos = 0.                                      
    
    /* titulos todos */                                     
    find first fin.titulo use-index iclicod where                                    
            fin.titulo.clifor = clien.clicod and              
            fin.titulo.empcod = 19 and 
            fin.titulo.titnat = no and 
            fin.titulo.modcod = "CRE"                      
        no-lock no-error.                                                             
    if avail titulo 
    then do:                                                  
        qtdtitulostodos = 1. 
    end. 
    else do: 
        qtdtitulostodos = 0. 
    end.                                                   

    mesatualprazo = 0. 
    /* VENDA MES ATUAL A PRAZO */
    
    find first plani where    /* use-idex plasai */                     
           plani.pladat >= vatuini and                
           plani.pladat <= vatufim and       
           plani.movtdc = 5 and                           
           plani.crecod = 2 and                           
           (plani.modcod = "CRE"
         or plani.modcod = "CP1"
         or plani.modcod = "CP0"
         )  
                    and                       
           plani.Dest = clien.clicod                      
             no-lock no-error.                        
                                                     
    if avail plani then do:                         
        mesatualprazo = 1. 
    end. 
    else do: 
        mesatualprazo = 0.
    end.

        
    mesatualvista = 0. 
    /* VENDA MES ATUAL A VISTA */                               
    find first plani where  /* use-index plasai */                                        
        plani.pladat >= vatuini and       
        plani.pladat <= vatufim and                                  
        plani.movtdc = 5 and                                       
        plani.crecod = 1 and                                       
        (plani.modcod = "VVI" or plani.modcod = "FIN") and  
        plani.Dest = clien.clicod                                   
        no-lock no-error.                                          
    if avail plani then do:                             
        mesatualvista = 1.                                                        
    end.                                               
    else do:                                          
        mesatualvista = 0.                                
    end.
                                                 
    prospectmesanterior = if clien.dtcad <= vantfim
                          then 1
                          else 0.  
                                                     
                                                 
            
    /*CLIENTES NOVOS PROSPECT */                                           
    
    if clien.dtcad >= vatuini and
      clien.dtcad <= vatufim and       
      (mesatualvista = 0 AND mesatualprazo = 0) 
    then do:
        statuscliente = "NOVOS PROSPECT".                      
        run rundisp.
        next.                                                   
    end.   

    /* CLIENTES PROSPECT */                                                             
    if ((comprouantigamente = 0) and 
        (comprouanoanterior = 0) and
        (qtdtitulostodos = 0)    and 
        (mesatualvista = 0 and mesatualprazo  = 0) 
       )  
    then do:                                                                  
        statuscliente = "PROSPECT".                   
        run rundisp.
        next.                                                               
    end.                                               
                                                                                    
    /* CLIENTES NOVOS COMPRA /* #3 A PRAZO*/  */  
    if (prospectmesanterior = 0 and
        comprouantigamente = 0 and 
        comprouanoanterior = 0 and
        (mesatualprazo = 1 or
         mesatualvista = 1)) /* #3 */
    then do: 
        statuscliente = "NOVOS COMPRA". /* #3  "NOVO COMPRA A PRAZO". */                  
        run rundisp.
        next.                                                               
    end.

    /* #3 */
    /*CLIENTES NOVOS ATIVACAO /* #3 COMPRA A VISTA*/ */  
    if  (prospectmesanterior = 1 and /* #3 */ 
         comprouantigamente = 0 and 
         comprouanoanterior = 0 and  
         (mesatualvista = 1 or
          mesatualprazo = 1)) /* #3 */           
    then do: 
        statuscliente = "NOVOS ATIVACAO". /* #3  "NOVO COMPRA A VISTA". */                      
        run rundisp.
        next. 
    end.                                               

    /* CLIENTES ATIVOS COMPRA PRAZO */

    find first plani where  /* use-index plasai */
            plani.pladat >= vatuini and                           
            plani.pladat <=  vatufim and  
            plani.movtdc = 5 and 
            plani.crecod = 2 and 
            (   plani.modcod = "CRE" 
             or plani.modcod = "CP0" 
             or plani.modcod = "CP1" )   and
            plani.Dest = clien.clicod 
            no-lock no-error.
    if avail plani and comprouanoanterior = 1 
    then do: 
        statuscliente = "ATIVO COMPRA A PRAZO". 
        run rundisp.
        next. 
    end.

    /* se comprou a prazo nos ultimos 12 meses */
    find first plani where  /* use-index plasai */                 
        plani.pladat >= vatuini - 365 and   
        plani.pladat <= vantfim and           
        plani.movtdc = 5 and                     
        plani.crecod = 2 and                     
        (plani.modcod = "CRE"                    
        or plani.modcod = "CP0"                    
        or plani.modcod = "CP1" )                   and                                   
        plani.Dest = clien.clicod                
        no-lock no-error.                 
    if avail plani then do:  
        statuscliente = "ATIVO COMPRA A PRAZO".
        run rundisp.
        next.                                                                         
    end.                                                         

    /* CLIENTES ATIVOS COMPRA A VISTA */                                              
    find first plani where   /* use-index plasai */                                         
            plani.pladat >= vatuini and
            plani.pladat <=  vatufim and      
            plani.movtdc = 5 and 
            plani.crecod = 1 and 
           (plani.modcod = "VVI"  or plani.modcod = "FIN") and
           plani.Dest = clien.clicod 
         no-lock no-error.                                                                              
    if avail plani AND comprouanoanterior = 1 
    then do:                              
        statuscliente = "ATIVO COMPRA A VISTA".  
        run rundisp. 
        next.  
    end.                                                         

    /*COMPROU A VISTA NOS ULTIMOS 12 MESES */  
    find first plani where   /* use-index plasai */                           
            plani.pladat >= vatuini - 365 and   
            plani.pladat <=  vantfim and        
            plani.movtdc = 5 and                           
            plani.crecod = 1 and                               
           (plani.modcod = "VVI"  or plani.modcod = "FIN") and   
           plani.Dest = clien.clicod                  
        no-lock no-error.                                      
    if avail plani 
    then do:                 
        statuscliente = "ATIVO COMPRA A VISTA". 
        run rundisp.
        next. 
    end.                                                    

    /* RECUPERADOS A PRAZO */
    if ((comprouantigamente = 1) and 
        (comprouanoanterior = 0) and  
        (mesatualprazo = 1)      and 
        (qtdtitulosmesanterior = 0)  
        )  
    then do:  
        statuscliente = "RECUPERADO COMPRA A PRAZO". 
        run rundisp.
        next.                                                                          
    end.

    /* RECUPERADOS A VISTA */                                                         
    if ( (comprouantigamente = 1) and 
         (comprouanoanterior = 0) and  
         (mesatualvista = 1)      and  
         (qtdtitulosmesanterior = 0 )  
       )  
    then do:                                                                 
        statuscliente = "RECUPERADO COMPRA A VISTA". 
        run rundisp.
        next. 
    end.                                                         
    
    if (mesatualprazo = 1)  
    then do:  
        statuscliente = "ATIVO COMPRA A PRAZO". 
        run rundisp.
        next. 
    end.                                                                     
    
    if (mesatualvista = 1) 
    then do: 
        statuscliente = "ATIVO COMPRA A VISTA". 
        run rundisp.
        next. 
    end. 

    /* INADIMPLENTE */  
    find first fin.titulo use-index iclicod where                 
            fin.titulo.clifor = clien.clicod and                                
            fin.titulo.titsit = "LIB"        and 
            fin.titulo.empcod = 19           and 
            fin.titulo.titnat = no           and 
            fin.titulo.modcod = "CRE"        and 
            fin.titulo.titdtpag = ?          and 
            fin.titulo.titdtven <= vantfim - 90 
       no-lock no-error. 
    if avail fin.titulo 
    then do: 
        statuscliente = "INADIMPLENTE". 
        run rundisp.
        next. 
    end.

    
    find first fin.titulo use-index iclicod where                   
            fin.titulo.clifor = clien.clicod and                     
            fin.titulo.titsit = "LIB"        and 
            fin.titulo.empcod = 19           and 
            fin.titulo.titnat = no           and 
            fin.titulo.modcod = "CP0"        and 
            fin.titulo.titdtpag = ?          and 
            fin.titulo.titdtven <= vantfim - 90       
                     no-lock no-error.                                        
    if avail fin.titulo 
    then do:                                               
        statuscliente = "INADIMPLENTE". 
        run rundisp.
        next. 
    end.                                               

    find first fin.titulo use-index iclicod where                    
            fin.titulo.clifor = clien.clicod and 
            fin.titulo.titsit = "LIB"        and 
            fin.titulo.empcod = 19           and 
            fin.titulo.titnat = no           and 
            fin.titulo.modcod = "CP1"        and 
            fin.titulo.titdtpag = ?          and 
            fin.titulo.titdtven <= vantfim - 90 
         no-lock no-error.                                          
    if avail fin.titulo 
    then do:   
        statuscliente = "INADIMPLENTE".   
        run rundisp.
        next. 
    end.   
    
    /* CLIENTES ATIVO CONTRATO */                                              
    find first fin.titulo use-index iclicod 
        where 
        fin.titulo.clifor = clien.clicod and 
        fin.titulo.titsit = "LIB"        and 
        fin.titulo.empcod = 19           and 
        fin.titulo.titnat = no           and 
        fin.titulo.modcod = "CRE"        and 
        fin.titulo.titdtpag = ? 
        no-lock no-error.                                  
    if avail fin.titulo
    then do:  
        statuscliente = "ATIVO CONTRATO".   
        run rundisp.
        next.
    end.      

    find first fin.titulo use-index iclicod 
            where                           
            fin.titulo.clifor = clien.clicod and  
            fin.titulo.titsit = "LIB"        and 
            fin.titulo.empcod = 19           and  
            fin.titulo.titnat = no           and 
            fin.titulo.modcod = "CP1"        and 
            fin.titulo.titdtpag = ? 
       no-lock no-error.  
    if avail fin.titulo  
    then do:  
        statuscliente = "ATIVO CONTRATO". 
        run rundisp.
        next.    
    end.

    find first fin.titulo use-index iclicod where  
              fin.titulo.clifor = clien.clicod and                                    
              fin.titulo.titsit = "LIB" and 
              fin.titulo.empcod = 19    and 
              fin.titulo.titnat = no    and 
              fin.titulo.modcod = "CP0" and  
              fin.titulo.titdtpag = ?  
              no-lock no-error.  
    if avail fin.titulo   
    then do:  
        statuscliente = "ATIVO CONTRATO".  
        run rundisp.
        next.  
    end.                                                          

    /* inativo v2 */   
    if ((comprouanoanterior = 0) and 
        (mesatualprazo = 0)      and 
        (mesatualvista = 0)   
       ) 
    then do:  
        statuscliente = "INATIVO".  
        run rundisp.
        next. 
    end.                                                      
                   
    /* NAO SE ENQUADROU EM NADA... */ 
       
    statuscliente = "INATIVOO".  
    run rundisp.

end. /* For each Clien */

output close.



procedure rundisp.

        put  vano format "9999" ";" 
             vmes format "99" ";" 
             clien.clicod ";" 
             clien.clinom ";" 
             statuscliente format "x(30)" ";" 
             skip.   
        
end procedure.
