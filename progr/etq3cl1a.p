/* ---------------------------------------------------------------------------
*  Nome.....: etq3cl1a.p
*  Funcao...: Monta etiquetas produto em 3 colunas
*  Data.....: 20/02/2006
*  Autor....: Gerson Mathias
--------------------------------------------------------------------------- */

def var c-campo1        as char form 'x(42)' extent 3       no-undo.
def var c-campo2        as char form 'x(42)' extent 3       no-undo.
def var c-campo3        as char form 'x(42)' extent 3       no-undo.
def var varqsai         as char form 'x(150)'               no-undo.            
def var vqtd            as inte                             no-undo.
def var vquant          as inte                             no-undo.
def var vi              as inte                             no-undo.
def var ct-cont         as inte                             no-undo.
def var i-qtd-1a        as inte form ">>>>9"    init 0      no-undo.    
def var i-col1          as inte form "999"      init 005    no-undo.
def var i-col2          as inte form "999"      init 032    no-undo.
def var i-col3          as inte form "999"      init 060    no-undo.
def var varqbat         as char form "x(100)"   init ""     no-undo.
def var vcaminho        as char form "x(80)"    init ""     no-undo.
def var vporta          as char form "x(80)"    init ""     no-undo.
def var i-cont          as inte form ">>>9"     init 0      no-undo. 
def var pag01           as logi                 init yes    no-undo.

def var varquivo as char.
def var lEtiqueta       as logi form "Sim/Nao"       init no         no-undo.
def var iContEtq        as inte form ">>>>>9"        init 0          no-undo.   
def var iEtq            as inte form ">>>>>9"        init 0          no-undo.   
def var lEntrada        as logi                      init yes        no-undo.
def var cexten          as char form "x(03)"         init ""         no-undo.
def var cpath           as char form "x(30)"         init ""         no-undo.

def temp-table tt-etiqueta                 no-undo
    field rProdu    as recid
    field qtd-etq   as inte  form ">>>>>9"
    field procod    like produ.procod
    field pronom    like produ.pronom
    field qtdest    like estoq.estatual.

def input param table for tt-etiqueta.
def input param p-nomarq  as char. 

def temp-table tt-impr       no-undo
    field procod    like produ.procod   extent 3
    field pronom    like produ.pronom   extent 3
    field comple    like produ.pronom   extent 3 
    field qtdest    like estoq.estatual extent 3
    field nroetq    as inte form ">>9"  extent 3.
     
/* ------------------------------------------------------------------------ */
assign cexten    = ".rp"
       cpath     = "c:~\temp~\". 

/* DREBES */
if opsys = "UNIX"
then do:
        assign varqsai   = "/admcom/relat/" + trim(p-nomarq) + ".rp"
               varqbat   = "/admcom/relat/etique"
               vcaminho  = "type /admcom/relat/" + trim(p-nomarq) + ".rp >"
               vporta    = "//192.168.0.2/laser".
end. 
else do:
        assign varqsai   = trim(cpath) + trim(p-nomarq) + trim(cexten)
               varqbat   = trim(cpath) + "etique.bat"
               vcaminho  = "type " + trim(cpath) + trim(p-nomarq) + ".rp > "
               vporta    = "//192.168.0.2/laser".
end.

for each tt-etiqueta where
         tt-etiqueta.qtdest > 0 no-lock:
        
        assign i-cont   = if i-cont = 3 then 0
                                        else i-cont.
        assign ietq     = tt-etiqueta.qtdest
               lentrada = yes.
        
        repeat:
        
            assign i-cont = i-cont + 1.
            
            if  i-cont    = 1 and
                lentrada = yes                
            then create tt-impr.
            
            assign tt-impr.procod[i-cont] = tt-etiqueta.procod
                   tt-impr.pronom[i-cont] = substring(tt-etiqueta.pronom,01,18)
                   tt-impr.comple[i-cont] = substring(tt-etiqueta.pronom,19,45)
                   tt-impr.qtdest[i-cont] = tt-etiqueta.qtdest
                   tt-impr.nroetq[i-cont] = ietq.
                   
            assign ietq = ietq - 1.
            /*
            message string(tt-etiqueta.procod) + " Procod" skip
                    string(ietq) + " Etiquetas" skip
                    string(i-cont) + " Contador" skip
                    string(tt-etiqueta.qtdest) + " Qtde Est"
                    view-as alert-box.
            */
            if i-cont = 3 and
               ietq   > 0
            then do:
                    create tt-impr.
            end.
            if ietq   = 0 and
               i-cont = 3
            then do:
                    leave.   
            end.
            if ietq   = 0
            then leave.  
            if i-cont = 3 
            then do:
                    assign i-cont   = 0
                           lentrada = no.
            end.                
        end.     

end.

output to value(varqbat).
       put "net use lpt1:" + trim(vporta) form "x(60)"
           skip.
       put trim(vcaminho) + " " + trim(vporta) form "x(60)" 
           skip.
       put "net use lpt1:/delete"
           skip.
output close.
 

run mod1a.  /* Procedure impressao */

      assign lEtiqueta = no.

    update lEtiqueta label "Imprime Etiqueta "
           with frame f-2 side-labels 1 col width 40
                row 15 col 10 title "CONFIRMA IMPRESSAO".
    if lEtiqueta = yes
    then do:
            dos silent value(varqbat).
    end. 

/* TESTE CUSTOM
run visurel.p (input "/admcom/trab/gerson/relinv.rp","").
*/

/* ------------------------------------------------------------------------ */

procedure mod1a:

output to value(varqsai).
           
assign ct-cont    = 0.

     for each tt-impr no-lock:
                
                assign ct-cont = ct-cont + 1.
                
                if ct-cont = 1
                then do:
                        if pag01 = yes
                        then do:
                                put skip(4). /* 4 */
                                assign pag01 = no.
                        end.
                        else do:
                                put skip(6).
                        end.            
                end.
                /*
                put 
                    tt-impr.procod[1] form ">>>>>>>>>9"  at i-col1
                    tt-impr.procod[2] form ">>>>>>>>>9"  at i-col2
                    tt-impr.procod[3] form ">>>>>>>>>9"  at i-col3
                    tt-impr.pronom[1] form "x(22)"       at i-col1
                    tt-impr.pronom[2] form "x(22)"       at i-col2
                    tt-impr.pronom[3] form "x(22)"       at i-col3
                    tt-impr.comple[1] form "x(22)"       at i-col1
                    tt-impr.comple[2] form "x(22)"       at i-col2
                    tt-impr.comple[3] form "x(22)"       at i-col3   
                    tt-impr.qtdest[1] form ">>>>>>>>>9"  at i-col1
                    tt-impr.qtdest[2] form ">>>>>>>>>9"  at i-col2
                    tt-impr.qtdest[3] form ">>>>>>>>>9"  at i-col3 
                    skip(2).
                */
                put 
                    "Cod:"                               at i-col1    
                    tt-impr.procod[1] form ">>>>>>>>>9"  at i-col1 + 6
                    "Cod:"                               at i-col2 
                    tt-impr.procod[2] form ">>>>>>>>>9"  at i-col2 + 6
                    "Cod:"                               at i-col3
                    tt-impr.procod[3] form ">>>>>>>>>9"  at i-col3 + 6
                    "Desc: "                             at i-col1 
                    tt-impr.pronom[1] form "x(18)"       at i-col1 + 6
                    "Desc: "                             at i-col2
                    tt-impr.pronom[2] form "x(18)"       at i-col2 + 6
                    "Desc: "                             at i-col3
                    tt-impr.pronom[3] form "x(18)"       at i-col3 + 6
                    tt-impr.comple[1] form "x(22)"       at i-col1
                    tt-impr.comple[2] form "x(22)"       at i-col2
                    tt-impr.comple[3] form "x(22)"       at i-col3   
                    "Qtd: "                              at i-col1
                    tt-impr.qtdest[1] form ">>>>>>9"     at i-col1 + 6
                    "N.: "                               at i-col1 + 15
                    tt-impr.nroetq[1]                    at i-col1 + 20
                    "Qtd: "                              at i-col2  
                    tt-impr.qtdest[2] form ">>>>>>9"     at i-col2 + 6
                    "N.: "                               at i-col2 + 15
                     tt-impr.nroetq[2]                   at i-col2 + 20
                    "Qtd: "                              at i-col3
                    tt-impr.qtdest[3] form ">>>>>>9"     at i-col3 + 6
                    "N.: "                               at i-col3 + 15
                     tt-impr.nroetq[3]                   at i-col3 + 20
                    skip(4).
                    

                if ct-cont = 10
                then do:
                        assign ct-cont = 0.
                        page.
                        put control chr(27) + 'E'.
                end.
      end.
     
    output close.

end procedure.

/* ------------------------------------------------------------------------ */
