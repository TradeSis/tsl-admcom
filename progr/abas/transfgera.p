/*
#12 21.05.19  - Helio.neto - Projeto Planejamento Neogrid - Create abastransf (Pedido de Transferencia)
*/

def input param par-recmovim as recid.

/*#12*/
def var pabtcod     like abastransf.abtcod.
/*#12*/

/* 04.07.19 */
def var vestatual like estoq.estatual.
 
def buffer sclase   for clase.
def buffer grupo    for clase.
def buffer setclase for clase.
def buffer depto    for clase.

def var vcria       as log.

def var vgrade as int.

    find movim where recid(movim) = par-recmovim no-lock.

    /* Ver se tem criado transf anteriormente */
    find first abastransf where 
                 abastransf.orietbcod = movim.etbcod and
                 abastransf.oriplacod = movim.placod and
                 abastransf.procod    = movim.procod 
           no-lock no-error.
    if avail abastransf
    then return.

    /* 02.07.19 nao gerar para tipmov <> 5 */
    if movim.movtdc <> 5
    then return.        
    
    find produ of movim no-lock.
    if produ.proipival = 1
    then next.
    
        vcria =           produ.catcod = 31 or        
                          produ.catcod = 41.


        if vcria = no /* teste categoria */
        then return.
        
        find sClase     where sClase.clacod   = produ.clacod    no-lock no-error.
                if avail sclase
                then do:
                    find Clase      where Clase.clacod    = sClase.clasup   no-lock no-error.
                    if avail clase
                    then do:
                        find grupo      where grupo.clacod    = Clase.clasup    no-lock no-error.
                        if avail grupo
                        then do:
                            if grupo.clacod = 129110000 /* RECARGA */
                            then vcria = no.
        
                            find setClase   where setClase.clacod = grupo.clasup    no-lock no-error.  
                            if avail setclase
                            then do:
                                if setclase.clacod = 116000000 or /* FRETES */
                                   setclase.clacod = 141000000    /* SERVICOS FINANCEIROS */
                                then vcria = no.
                            
                                find depto   where depto.clacod = setclase.clasup    no-lock no-error.   
                                
                            end.
                        end.
                    end.
                end.              
                      
    if vcria = no /* teste setor */
    then return.

    find  estoq where estoq.etbcod = movim.etbcod and 
                      estoq.procod = movim.procod
                        no-lock no-error.

    vestatual =  (if avail estoq then estoq.estatual else 0) .
    
    /* TESTE TIPO TRANSF MOSTRUARIO */
    find first abastipo where abastipo.abatipo = "MOS" no-lock.
    find abastcla where abastcla.abatipo = abastipo.abatipo and
                        abastcla.clacod  = produ.clacod 
         no-lock no-error.
    if avail abastcla
    then do:
        if abastcla.situacao = yes /* ativo */
        then do:
            if abastcla.testagrade = yes
            then do:
                find abasgrade where 
                        abasgrade.etbcod = movim.etbcod and
                        abasgrade.procod = produ.procod
                        no-lock no-error.
                    vgrade = if avail abasgrade
                             then abasgrade.abgqtd
                             else 0.
            end.
            else vgrade = 1. /* Caso nao testa fixa em 1 */
            
            if vgrade >= 1  /* tem mostruario */
            then do:    
                
                /* CRIA Ped.TRANSF para MOSTRUARIO */
                if vestatual < vgrade /* 04.07.19 soh quando ficar abaixo da grade */
                then do:
                    run abas/transfcreate.p  
                                (abastipo.abatipo,   
                                 movim.etbcod, 
                                 movim.procod, 
                                 movim.movqtm, 
                                 "", 
                                 movim.movdat, 
                                 "MOVIM=" + string(recid(movim)), 
                                 "", 
                                 output pabtcod).
                end.
                vcria = no.    
                return. /* tem mostruario , entao mesmo que nao crie, nao deixa criar neg */
                
            end.
        end.            
    end.
           
    /* Testa Novamente pois pode ter criado MOS */
    find first abastransf where 
                 abastransf.orietbcod = movim.etbcod and
                 abastransf.oriplacod = movim.placod and
                 abastransf.procod    = movim.procod 
           no-lock no-error.
    if avail abastransf
    then return.  
    
    find first abastipo where abastipo.abatipo = "NEG" no-lock.  
    
    if vestatual < 0 and 
        vcria = yes /* testes anteriores */
    then do:   
        /* 06.06.19 */
        vcria =           produ.catcod = 31 or         /* Moveis */
                         (produ.catcod = 41 and       /* Moda VEX */
                          produ.ind_vex = yes).

        if vcria                          
        then do:    
            run abas/transfcreate.p  
                    (abastipo.abatipo,   
                     movim.etbcod, 
                     movim.procod, 
                     movim.movqtm, 
                     "", 
                     movim.movdat, 
                     "MOVIM=" + string(recid(movim)), 
                     "", 
                     output pabtcod).
        end.
        
    end.
