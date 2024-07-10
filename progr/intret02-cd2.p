/* ---------------------------------------------------------------------------
*  Nome.....: invret01.p
*  Funcao...: integracao ADMCOM e AUTOMATEC  RET999AAAAMMDD.TXT   - GERACAO
*  Data.....: 07/03/2006
*  Autor....: Gerson Mathias
--------------------------------------------------------------------------- */

{admcab.i}

pause 0 no-message.

/* ------------------------------------------------------------------------- */

def temp-table tt-coletor   like coletor.

def buffer cmovim for movim.

def var vetbcod     like estab.etbcod.
def var vcatcod     like categoria.catcod.
def var vquan       like estoq.estatual.
def var vqtd        like estoq.estinvctm format "->,>>9.99".

def var vcod        as i       form "9999999".
def var vdata       as date    form "99/99/9999"    init today      no-undo.
def var varquivo    as char    form "x(50)"         init ""         no-undo.
def var varq        as char.
def var vlinha      as char.

def var vest like estoq.estatual.
def var vant like estoq.estatual.

def stream stela.
/* ------------------------------------------------------------------------- */

def var seta-arq as char extent 2 format "x(20)"
    init["ARQUIVO LEBES","ARQUIVO CONTROLLER"].
def var vindex as int.    
disp seta-arq with frame ff1 1 down no-label centered.
choose field seta-arq with frame ff1.
vindex = frame-index.
 
repeat:

for each tt-coletor no-lock:
    delete tt-coletor.
end.

    update vetbcod colon 20 label "Filial"
                with frame f1 side-label centered width 80.
                
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.
    /*
    update vcatcod colon 20 label "Departamento" with frame f1.
    
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f1.
    */ 
    update vdata label "Data da Coleta" colon 20 with frame f1.

if vindex = 1
then do:
if opsys = "UNIX"
then do:
        assign varquivo = "/admcom/coletor-aud/RET" + trim(string(vetbcod,"999")) +
                          substring(string(vdata,"99/99/9999"),7,4)  +
                          substring(string(vdata,"99/99/9999"),4,2)  +
                          substring(string(vdata,"99/99/9999"),1,2)  +
                          ".TXT".
end.
else do:
        assign varquivo = "c:~\temp~\RET" + trim(string(vetbcod,"999")) +
                          substring(string(vdata,"99/99/9999"),7,4)  +
                          substring(string(vdata,"99/99/9999"),4,2)  +
                          substring(string(vdata,"99/99/9999"),1,2)  +
                          ".TXT".

end.                                 
end.
                   
update varquivo label "Arquivo" at 13 with frame f1.                  
if substr(string(varquivo),1,3) = "c:~\"   and
        opsys = "UNIX"
then do:
    scabrel = varquivo.
    schave = "ftp".
    varquivo = "/admcom/relat/".
    run editarqr.p(varquivo).
    varquivo = sparam.
    sparam = "".
end.
assign varq = search(varquivo).
if varq = ?
then do:
        message "Arquivo nao foi encontrado, favor verificar!"
                view-as alert-box.
        undo, retry.
end.
def var v as int.
def var vetbcod1 like estab.etbcod.
def var vdata1 as date. 
input from value(varquivo).

       repeat:
            import vcod vqtd.
            /*
            vqtd = 0.
            import unformatted vlinha. 
            v = v + 1.
            if vindex = 1
            then do:
                assign vcod = int(substring(string(vlinha),1,14))
                       vqtd = int(substring(string(vlinha),27,6)).
            
            end.
            else do:
                if v = 1
                then do:
                     
                    vetbcod1 = int(substr(string(vlinha),2,3)). /*2,11*/
                    vdata1   = date(int(substr(string(vlinha),13,2)), /*16,2*/
                               int(substr(string(vlinha),10,2)), /*13,2*/
                               int(substr(string(vlinha),16,2)) + 2000) /*19,2*/.
              
                    
                    if vetbcod1 <> vetbcod
                    then do:
                        bell.
                        message color red/with
                        "Arquivo de outra filial"
                        view-as alert-box title " Atencao! "
                        .
                        leave.    
                    end.
                    if vdata1 <> vdata
                    then do:
                        bell.
                        message color red/with
                        "Arquivo de outra data"
                        view-as alert-box title " Atencao! "
                        .
                        leave.    
                    end.
 
                end.
                else do:
                    vcod = int(substr(string(vlinha),2,14)).
                    vqtd = int(substr(string(vlinha),15,20)).
                end.
            end.
            */
            if vcod <> ? and
                vcod > 0
            then do:    
                find produ where produ.procod = vcod no-lock no-error.
                if avail produ
                then do:
           
            assign vcatcod = produ.catcod.
            find categoria where categoria.catcod = vcatcod no-lock.
                        
            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = produ.procod no-lock no-error.
            if not avail estoq
            then next.
            
            
            find coletor where coletor.etbcod = estab.etbcod and
                               coletor.procod = produ.procod and
                               coletor.coldat = vdata no-error.
            if not avail coletor
            then do transaction:
                
                create coletor.
                assign coletor.etbcod   = estab.etbcod
                       coletor.procod   = produ.procod
                       coletor.coldat   = vdata
                       coletor.pronom   = produ.pronom
                       coletor.catcod   = vcatcod  
                       coletor.estatual = estoq.estatual
                       coletor.estcusto = estoq.estcusto
                       coletor.estvenda = estoq.estvenda.
                       
            end.
            
            do transaction:
               coletor.colqtd = vqtd.  

               if coletor.estatual > coletor.colqtd
               then coletor.coldec = coletor.estatual - coletor.colqtd.

               if coletor.estatual < coletor.colqtd
               then coletor.colacr = coletor.colqtd - coletor.estatual.
            
                disp vqtd label "Quantidade" with 1 col 1 down.
               pause 0 no-message.
            end.
            end.
            end. 
       end.
        
    input close.
    
    if vindex = 2 and
       (vetbcod1 <> vetbcod  or
        vdata1 <> vdata)
    then return.    

    message "Deseja Processar" update sresp.
    if sresp = no
    then next.
    
    output stream stela to terminal.
    
    for each produ where produ.catcod = categoria.catcod no-lock:
    
        display stream stela produ.procod with 1 down. pause 0.
    
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-error.

        if not avail estoq
        then next.

        vest = estoq.estatual.
        
        for each movim where movim.procod = produ.procod and
                             movim.emite  = estab.etbcod and
                             movim.datexp > vdata no-lock:

            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat use-index plani
                                                     no-lock no-error.

            if not avail plani
            then next.
            
            if plani.etbcod <> estab.etbcod and
               plani.desti  <> estab.etbcod
            then next.

            if plani.emite = 22 and
               plani.serie = "m1"
            then next.

            if plani.movtdc = 5 and
               plani.emite  <> estab.etbcod
            then next.

            find tipmov of movim no-lock.
            if movim.movtdc = 5 or
               movim.movtdc = 13 or
               movim.movtdc = 14 or
               movim.movtdc = 16 or
               movim.movtdc = 8  or
               movim.movtdc = 18
               then do:
                   if movim.datexp >= vdata
                   then vest = vest + movim.movqtm.
               end.

            if movim.movtdc = 4 or
               movim.movtdc = 1 or
               movim.movtdc = 7 or
               movim.movtdc = 12 or
               movim.movtdc = 15 or
               movim.movtdc = 17
            then do:
                if movim.datexp >= vdata
                then vest = vest - movim.movqtm.
            end.

            if movim.movtdc = 6
            then do:
                if plani.etbcod = estab.etbcod
                then do:
                    if movim.datexp >= vdata
                    then vest = vest + movim.movqtm.
                end.
                if plani.desti = estab.etbcod
                then do:
                    if movim.datexp >= vdata
                    then vest = vest - movim.movqtm.
                end.
            end.
        end.
        
        for each movim where movim.procod = produ.procod and
                             movim.desti  = estab.etbcod and
                             movim.datexp > vdata no-lock:


            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat
                                                     no-lock no-error.

            if not avail plani
            then next.
            
            if avail plani
            then do:
                if plani.emite = 22 and desti = 996
                then next.
                
            end.
            
            if movim.movtdc = 5  or 
               movim.movtdc = 12 or 
               movim.movtdc = 13 or 
               movim.movtdc = 14 or 
               movim.movtdc = 16 
            then next.
            
            if plani.etbcod <> estab.etbcod and
               plani.desti  <> estab.etbcod
            then next.

            if plani.emite = 22 and
               plani.serie = "m1"
            then next.

            if plani.movtdc = 5 and
               plani.emite  <> estab.etbcod
            then next.
            find tipmov of movim no-lock.
            if movim.movtdc = 5 or
               movim.movtdc = 13 or
               movim.movtdc = 14 or
               movim.movtdc = 16 or
               movim.movtdc = 8  
               then do:
                   if movim.datexp >= vdata
                   then vest = vest + movim.movqtm.
               end.

            if movim.movtdc = 4 or
               movim.movtdc = 1 or
               movim.movtdc = 7 or
               movim.movtdc = 12 or
               movim.movtdc = 15 
            then do:
                if movim.datexp >= vdata
                then vest = vest - movim.movqtm.
            end.

            if movim.movtdc = 6
            then do:
                if plani.etbcod = estab.etbcod
                then do:
                    if movim.datexp >= vdata
                    then vest = vest + movim.movqtm.
                end.
                if plani.desti = estab.etbcod
                then do:
                    if movim.datexp >= vdata
                    then vest = vest - movim.movqtm.
                end.
            end.
        end.
        
        find coletor where coletor.etbcod = estab.etbcod and
                           coletor.procod = produ.procod and
                           coletor.coldat = vdata no-error.
        if not avail coletor
        then do transaction:
            create coletor.
            assign coletor.etbcod   = estab.etbcod
                   coletor.coldat   = vdata
                   coletor.procod   = produ.procod
                   coletor.catcod   = vcatcod
                   coletor.colqtd   = 0
                   coletor.pronom   = produ.pronom
                   coletor.estcusto = estoq.estcusto
                   coletor.estvenda = estoq.estvenda
                   coletor.estatual = vest.
        
            if vest > coletor.colqtd
            then coletor.coldec = vest - coletor.colqtd.

            if vest < coletor.colqtd
            then coletor.colacr = coletor.colqtd - vest.
            
        end.
    end.
    output stream stela close.
end.

