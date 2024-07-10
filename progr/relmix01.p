/***************************************************************************** 
 * relmix01.p                                                                *
 * 27/01/2015 - Luciano - Distribuicao versao 2                              *
 *                        acrescentada uma coluna com a informacao de pedidos*
 *                        por loja                                           *  
 *                                                                           *
 *****************************************************************************/
{admcab.i}
def var vetbcod like estab.etbcod.
def var vclacod like clase.clacod.
def var vclasup like clase.clasup.
def var vcomcod     like compr.comcod.

def temp-table tt-mix
    field etbcod like estab.etbcod
    field data   as date
    field clacod like clase.clacod
    field clanom like clase.clanom
    field clasup like clase.clasup
    field supnom like clase.clanom
    field procod like produ.procod
    field pronom like produ.pronom
    field mostruario like tabmix.mostruario
    field qtdmix like tabmix.qtdmix
    field qtdest as int
    field venfil as int
    field venred as int
    field estdep as int
    field promix as log init no
    field pedidos_lojas like liped.lipqtd
    index i1 etbcod procod
    index i2 procod
    .
      

def buffer bclase for clase.
{selestab.i vetbcod f1}.

disp vetbcod at 5 label "Filial"
        with frame f1.
pause 0.
/**
if vetbcod > 0
then do:
find estab where estab.etbcod = vetbcod no-lock.

disp estab.etbnom no-label with frame f1.
end.
else do:
    pause 0.
end.
**/
update vclasup at 5 label "Classe" with frame f1.
if vclasup > 0
then do:
find clase where clase.clacod = vclasup no-lock.
disp clase.clanom no-label with frame f1.
end.
def buffer sclase for clase.

update vclacod at 1 label "Sub-classe" with frame f1.
if vclacod > 0
then do:
find sclase where sclase.clacod = vclacod no-lock.
disp sclase.clanom no-label with frame f1
    with 1 down side-label width 80.
end.

update vcomcod at 2 label "Comprador" format ">>>9"
        with frame f1.
        
find first compr where compr.comcod = vcomcod
                   and vcomcod > 0  no-lock no-error.
                           
if avail compr then display compr.comnom format "x(27)" no-label
                      with frame f1.
else if vcomcod = 0 then display "TODOS" @ compr.comnom no-label
                           with frame f1.
else do:
                    
     message "Comprador não encontrado!" view-as alert-box.
     undo, retry.
     
end.
     

def var vmostruario like tabmix.mostruario.
def var com-mostruario as log format "Sim/Nao".
def var com-estoque as log format "Sim/Nao".

update com-mostruario at 1 label "Somente produtos com mostruario?"
       help "Nao=Todos os produtos do mix com ou sem msotruario."
       com-estoque at 1 label "Somente produtos com estoque?   "
       help "Nao=Todos os produtos do mix com ou sem estoque."
       with frame f1.

def temp-table tt-estab like estab.
def temp-table tt-clase like clase.
def buffer bestab for estab.
def buffer p-tabmix for tabmix.

if vetbcod > 0
then do:
    for each bestab where bestab.etbcod = vetbcod no-lock:
        create tt-estab.
        buffer-copy bestab to tt-estab.
    end.    
end.
else do:
    find first tt-lj where tt-lj.etbcod > 0 no-error.
    if not avail tt-lj
    then  for each bestab no-lock:
        create tt-estab.
        buffer-copy bestab to tt-estab.
    end. 
    else for each tt-lj where tt-lj.etbcod > 0 no-lock:
        create tt-estab.
        buffer-copy tt-lj to tt-estab.
    end.
end.
def buffer cclasse for clase.
def buffer bclasse for clase.
def buffer dclasse for clase.
if vclacod > 0
then do:
    for each bclase where bclase.clacod = vclacod no-lock:
        create tt-clase.
        buffer-copy bclase to tt-clase.
    end.    
end.    
else if vclasup > 0
then do:
    for each bclase where bclase.clasup = vclasup no-lock:
        create tt-clase.
        buffer-copy bclase to tt-clase.
    end.  
end.
else do:
    for each dclasse where dclasse.clasup = 100000000 
                            no-lock:
        for each cclasse where cclasse.clasup = dclasse.clacod no-lock.
            for each bclasse where 
                     bclasse.clasup = cclasse.clacod no-lock:
                /*create tt-clase.
                buffer-copy bclasse to tt-clase.
                */
                for each clase where clase.clasup = bclasse.clacod no-lock:
                    create tt-clase.
                    buffer-copy clase to tt-clase.         
                end.
            end.
        end.
    end.
end.                            

def temp-table tt-dep like estab.
for each bestab no-lock:
    if bestab.etbnom begins "DREBES-FIL"
    THEN NEXT.
    create tt-dep.
    buffer-copy bestab to tt-dep.
end.    
def temp-table tt-pro
    field procod like produ.procod
    field venred as int
    field estdep as int
    index i1 procod.

disp "Processando.... " no-label
    with frame f-dd 1 down no-box centered row 12
    color message.
pause 0.    
for each tt-estab:
    disp tt-estab.etbcod no-label
        with frame f-dd.
    pause 0.    
    for each tt-clase:
        disp tt-clase.clacod no-label
            with frame f-dd.
        pause 0.    
        find first tabmix where tabmix.tipomix = "F" and
                          tabmix.codmix  <> 99 and
                          tabmix.promix  = tt-clase.clacod and
                          tabmix.etbcod  = tt-estab.etbcod
                          no-lock no-error.
        if not avail tabmix
        then find first tabmix where tabmix.tipomix = "F" and
                          tabmix.codmix  <> 99 and
                          tabmix.promix  = tt-clase.clasup and
                          tabmix.etbcod  = tt-estab.etbcod
                          no-lock no-error.
        if not avail tabmix
        then next.
        if tabmix.campodat1 > today
        then next.
        find clase where clase.clacod = tt-clase.clacod no-lock.
        for each produ where produ.clacod = tt-clase.clacod no-lock:
            disp produ.procod format ">>>>>>>>>9" no-label
                with frame f-dd.
            pause 0.    
            
        
            if vcomcod > 0
            then do:
                release liped.
                release pedid.
                find last liped where liped.procod = produ.procod
                                  and liped.pedtdc = 1
                                   no-lock use-index liped2 no-error.

                find first pedid of liped no-lock no-error.
    
                if (avail pedid and pedid.comcod <> vcomcod)
                    or not avail pedid
                then next.
                    
            end.
                    
                    
            
            
            find p-tabmix where p-tabmix.tipomix = "P" and
                             p-tabmix.codmix  = tabmix.codmix and
                             p-tabmix.promix  = produ.procod
                             no-lock no-error.
            if com-mostruario = yes and
               p-tabmix.mostruario = no
            then next.   
            find estoq where estoq.etbcod = tt-estab.etbcod and
                             estoq.procod = produ.procod
                             no-lock no-error.
            if com-estoque = yes and
               (not avail estoq or estoq.estatual = 0)
            then next.
                             
            
            find cclasse where cclasse.clacod = clase.clasup no-lock.
            
            create tt-mix.
            assign
                tt-mix.etbcod = tt-estab.etbcod
                tt-mix.procod = produ.procod
                tt-mix.clacod = clase.clacod
                tt-mix.clanom = clase.clanom
                tt-mix.clasup = clase.clasup
                tt-mix.supnom = cclasse.clanom
                tt-mix.data   = today
                tt-mix.pronom = produ.pronom
                .

            if avail p-tabmix
            then assign    
                tt-mix.mostruario = p-tabmix.mostruario
                tt-mix.qtdmix = p-tabmix.qtdmix .
            else tt-mix.mostruario = no.
            if avail estoq
            then  tt-mix.qtdest = estoq.estatual.
            
            if avail p-tabmix
            then tt-mix.promix = yes.
            else tt-mix.promix = no.
            /*
            for each tt-dep:
                find destoq where destoq.etbcod = tt-dep.etbcod and
                                  destab.procod = produ.procod
                                  no-lock no-error:
                if avail destoq
                then tt-mix.estdep = tt-mix.estdep + destoq.estatual.
            end.                      
            */
            
            for each movim where movim.procod = produ.procod and
                                 movim.etbcod = tt-estab.etbcod and
                                 movim.movdat >= today - 90 and
                                 movim.movtdc = 5
                                 no-lock:
                tt-mix.venfil = tt-mix.venfil + movim.movqtm.
            end.        
            find first tt-pro where tt-pro.procod = produ.procod
                         no-error.
            if not avail tt-pro
            then do:
                create tt-pro.
                tt-pro.procod = produ.procod.
            end.               
        end.
    end.
end.

for each tt-pro:
    disp tt-pro.procod format ">>>>>>>>>9" no-label
        with frame f-dd.
    pause 0.    
    for each movim where movim.procod = tt-pro.procod and
                         movim.movdat >= today - 90 and
                         movim.movtdc = 5
                         no-lock:
        tt-pro.venred = tt-pro.venred + movim.movqtm.
    end.
    for each tt-dep:
        find estoq where estoq.etbcod = tt-dep.etbcod and
                         estoq.procod = tt-pro.procod
                         no-lock no-error.
        if avail estoq
        then tt-pro.estdep = tt-pro.estdep + estoq.estatual.                        end.
end.

/* leitura para ler os pedidos de loja reservados           */
/* variaveis e temp-table utilizada no corte_disponivel.p   */
def var vestoq_depos    like estoq.estatual. 
def var vreservas       as dec. 
def var vdisponivel     like estoq.estatual.
def new global shared temp-table tt-reservas
    field sequencia    as dec
    field rec_liped     as recid
    field tipo          as char
    field atende        as int
    field dispo         as int 
    field prioridade    as int format "->>>>" label "Pri"
    field regra         as int
    index sequencia   is primary prioridade
    index rec_liped is unique rec_liped .

for each tt-pro.
    for each tt-reservas.
        delete tt-reservas.
    end.
    run corte_disponivel.p (input  tt-pro.procod,
                            output vestoq_depos, 
                            output vreservas, 
                            output vdisponivel).
    for each tt-mix where tt-mix.procod = tt-pro.procod.
        tt-mix.pedidos_lojas = 0.
    end.
    for each tt-reservas.
        find liped where recid(liped) = tt-reservas.rec_liped no-lock.
        find pedid of liped no-lock.
        find first tt-mix where tt-mix.etbcod = pedid.etbcod and
                                tt-mix.procod = tt-pro.procod
                                no-error.
        if avail tt-mix
        then tt-mix.pedidos_lojas = tt-mix.pedidos_lojas + liped.lipqtd.
    end.
end. 

def var varquivo as char.
if opsys = "UNIX"
then varquivo = "/admcom/relat/relmix01." + string(time).
else varquivo = "l:~\relat~\relmix01." + string(time).

{mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "80"
            &Page-Line = "64"
            &Nom-Rel   = ""PAG4""
            &Nom-Sis   = """SISTEMA COMERCIAL"""
            &Tit-Rel   = """ CONTROLE DE MIX """
            &Width     = "155"
            &Form      = "frame f-cabcab"}

disp with frame f1.

for each tt-mix:
    find first tt-pro where tt-pro.procod = tt-mix.procod .
    if tt-mix.qtdmix = 0 and
       tt-mix.qtdest = 0
    then next.
       
    disp tt-mix.etbcod column-label "Fil"
         tt-mix.data   column-label "Data"
         tt-mix.clasup column-label "Classe"
         tt-mix.supnom no-label format "x(15)"
         tt-mix.clacod column-label "SubClasse"
         tt-mix.clanom no-label format "x(15)"
         tt-mix.procod column-label "Produto" format ">>>>>>>>>9"
         tt-mix.pronom column-label "Descricao" format "x(25)"
         tt-mix.mostruario column-label "Most" 
         tt-mix.qtdmix column-label "QtdMix" when tt-mix.promix
                 format ">>>9"   
         tt-mix.qtdest column-label "QtdEst" format "->>>9"
         tt-mix.venfil column-label "VenFil" format "->>>9"
         tt-pro.venred column-label "VenRede" format "->>>9"
         tt-pro.estdep column-label "EstDep"  format "->>>9"
         tt-mix.pedidos_lojas column-label "Pedidos!Lojas" format "->>>>9"
         with frame f-disp down width 250.
end.
output close.

run arquivo-csv.

if opsys = "UNIX"
then do:
    run visurel.p(varquivo,"").
end.
else do:
    {mrod.i}
end.    

procedure arquivo-csv:

def var varquivo-csv as char.
if opsys = "UNIX"
then varquivo-csv = "/admcom/relat/relmix" + string(time) + ".csv".
else varquivo-csv = "l:~\relat~\relmix" + string(time) + ".csv".


output to value(varquivo-csv) page-size 0.

put "Fil;Data;Classe;;Sub-Classe;;Produto;Descricao;Most;QtdMix;QtdEst;VenFil;VenRede;EstDep;PedidosLojas" skip. 
for each tt-mix:
    find first tt-pro where tt-pro.procod = tt-mix.procod .
    if tt-mix.qtdmix = 0 and
       tt-mix.qtdest = 0
    then next.
       
    put  tt-mix.etbcod ";"
         tt-mix.data   ";"
         tt-mix.clasup " "
         tt-mix.supnom ";"
         tt-mix.clacod " "
         tt-mix.clanom ";"
         tt-mix.procod format ">>>>>>>>9" ";"
         tt-mix.pronom ";"
         tt-mix.mostruario ";"
         .
    if tt-mix.promix
    then put tt-mix.qtdmix.
    else put "NAO".
    put ";".     
    put tt-mix.qtdest ";"
        tt-mix.venfil ";"
        tt-pro.venred ";"
        tt-pro.estdep ";"
        tt-mix.pedidos_lojas format ">>>>>>>>9".
    put skip.     
        
end.
output close.

message color red/with
    "Arquivo CSV gerado: "
    varquivo-csv
    view-as alert-box.

end procedure.

    
