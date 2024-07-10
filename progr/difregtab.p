def input param pvez   as int. /* 1- primeira entrada  2- segunda entrada */
def input param precid as recid. /* recid do registro lido */
def input Param pDb    As Char No-undo. /* Banco */
def input Param pTb    as char no-undo. /* Tabela */ 
def output param  p-retorno as logical. /* Diferença sim/nao */

{difregtab.i}
 
def buffer btww-retorno-dif for tww-retorno-dif.
def var vaux as char.
p-retorno = no.

if pvez = 1
then for each tww-retorno-dif : delete tww-retorno-dif. end.
    
Def var pCp      As Char No-undo. 
Def Var vi-kon   As Int           No-undo.
Def var vj       as int.
Def Var qh       As Widget-handle No-undo.
Def Var bhFile   As Widget-handle No-undo.
Def Var bhField  As Widget-handle No-undo.
Def var bhTabela AS widget-handle no-undo.
def var vhaux    AS widget-handle no-undo.
def var vauxh   as char.
Def Var fh       As Widget-handle No-undo Extent 3.
def var fhh      As Widget-handle No-undo.
Def Var cQuery   As Char          No-undo.
def var i-cont   AS INTEGER       NO-UNDO.

Assign 
    cQuery = "For each " + pDb + "." + pTb + 
        " no-lock Where Recid(" + pDb + "." + ptb + ") = " + string(precid).
    cQuery = cquery + ", Each " + pDb + "._File No-lock ".
    cQuery = cQuery + "Where " + pDb + "._File._File-Name Begins '" + 
                ptb + "' " .
    cQuery = cQuery + ", each " + pDb + "._Field No-lock Where Recid(" + 
            pDb + "._File) = " + pDb + "._Field._File-recid.". 
    
    Create Buffer bhTabela for table pDb + "." + ptb.
    Create Buffer bhFile   For Table pDb + "._File".
    Create Buffer bhField  For Table pDb + "._Field".
    
    Create Query qh.
    
    qh:Set-buffers(bhTabela,bhFile, bhField). 
    qh:Query-prepare(cQuery).
    qh:Query-open.
    
    Assign fh[1] = bhField:Buffer-field('_Field-name').
           
    /* Status Input 'Pesquisando: ' + pDb. */
    
    qh:get-first(). 
    i-cont = 1.
    do while i-cont < bhTabela:num-fields:
        i-cont = i-cont + 1.
        vi-kon = bhTabela:buffer-field(i-cont):extent.
        
        /* Sem Extent */ 
        if vi-kon = 0 
        then do:
        
            find first tww-retorno-dif where 
                       tww-retorno-dif.vez  = pvez and
                       tww-retorno-dif.ban  = pDb  and
                       tww-retorno-dif.tabe = ptb  and
                       tww-retorno-dif.lab  = 
                                STRING(bhTabela:buffer-field(i-cont):name)
                                               no-error .

            if not avail tww-retorno-dif then do:
                    create tww-retorno-dif.
                    assign tww-retorno-dif.vez  = pvez
                           tww-retorno-dif.ban  = pdB
                           tww-retorno-dif.tabe = ptb
                           tww-retorno-dif.lab  = 
                           STRING(bhTabela:buffer-field(i-cont):name)
                           tww-retorno-dif.val  = 
                           STRING(bhTabela:buffer-field(i-cont):buffer-value).
                
            end.
        end. 
        /* Com Extent */
        else do:
          do vj = 1 to vi-kon:

            find first tww-retorno-dif where tww-retorno-dif.vez  = pvez and
                                               tww-retorno-dif.ban  = pDb  and
                                               tww-retorno-dif.tabe = ptb  and
                                               tww-retorno-dif.lab  = 
                                STRING(bhTabela:buffer-field(i-cont):name) + 
                                "[" + string(vj) + "]"
                                no-error .
            if not avail tww-retorno-dif 
            then do:
                    create tww-retorno-dif.
                    assign tww-retorno-dif.vez  = pvez
                           tww-retorno-dif.ban  = pdB
                           tww-retorno-dif.tabe = ptb
                           tww-retorno-dif.lab  = 
                                STRING(bhTabela:buffer-field(i-cont):name) + 
                                "[" + string(vj) + "]"
                           tww-retorno-dif.val = 
                    STRING(bhTabela:buffer-field(i-cont):buffer-value[vj]).
                
            end.
          end.
        end.

    end.

    Status Input ''.
    
    qh:Query-close().
    
    Delete Object qh.  
    Delete Object bhFile.  
    Delete Object bhField. 

    assign p-retorno = no.
    
    if pvez = 2  /* Apos Gravar */
    then do:
       for each tww-retorno-dif where 
                tww-retorno-dif.vez = 2 by tww-retorno-dif.vez:
           find first btww-retorno-dif where btww-retorno-dif.vez = 1 and
                      btww-retorno-dif.ban   = tww-retorno-dif.ban   and
                      btww-retorno-dif.tabe  = tww-retorno-dif.tabe  and
                      btww-retorno-dif.val   = tww-retorno-dif.val   and
                      btww-retorno-dif.lab   = tww-retorno-dif.lab   
                   no-error.
           if not avail btww-retorno-dif 
           then assign p-retorno = yes 
                       tww-retorno-dif.alterado = yes.
       end.

    end.
 