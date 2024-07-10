{admcab.i new}

def var vdti         as date.
def var vdtf         as date.
def var vlog-tipo    as logical format "Criação/Exclusão" initial yes.
def var vcont        as integer.
def var vsit-aux     as char.
def var vdat-aux     as date.

def var varquivo     as char.

def temp-table tt-liped  
    field etbcod      like liped.etbcod
    field pedtdc      like liped.pedtdc
    field pednum      like liped.pednum
    field peddat      like pedid.peddat
    field procod      like liped.procod
    field pronom      like produ.pronom
    field lipqtd      like liped.lipqtd
    field sitped      like pedid.sitped
    field DATA_EXCLUSAO        as date
    field HORA_EXCLUSAO        as char   
    field ETB_EXCLUSAO         as integer 
    field USUARIO_EXCLUSAO     as integer
    field funnom               as char
    field PROG_EXCLUSAO        as char
    
    .

assign vdti = today - 30
       vdtf = today.

update vdti label "Periodo"
                  "a"
       vdtf no-label 
                               skip(1)
       
       "Deseja pesquisar por data de Criação ou Exclusão dos Pedidos?" skip
       vlog-tipo label "Tipo" help "Aperte C ou E para trocar o tipo"
       with frame f-dat centered color blue/cyan row 8
                 title " Periodo " side-label.
         

                                    
                                    
if vlog-tipo = yes /* DATA DE CRIAÇÃO */                                    
then do:

do vdat-aux = vdti to vdtf:

for each pedid where pedid.peddat = vdat-aux
                 and (pedid.sitped = "R" or pedid.sitped = "C")  no-lock,
                                            
    each liped of pedid no-lock,
          
    first produ of liped no-lock.

    run p-comum.                 
                 
end.                 

end.

end.
else do:   /* DATA DE EXCLUSÃO */

do vcont = 1 to 2:                                    

if vcont = 1
then vsit-aux = "R".                                    
else if vcont = 2
     then vsit-aux = "C".
     else leave.
                                    
for 
    each pedid where pedid.sitped = vsit-aux
                            no-lock,
                 
    each liped of pedid no-lock,
          
    first produ of liped no-lock.

    if acha("DATA_EXCLUSAO",pedid.pedobs[3]) = ?
    then next.
    
    if date(acha("DATA_EXCLUSAO",pedid.pedobs[3])) < vdti
        or date(acha("DATA_EXCLUSAO",pedid.pedobs[3])) > vdtf
    then next.    
    
    run p-comum.                 
                 
end.                 

end.

end.

    if opsys = "UNIX"
    then varquivo = "/admcom/relat/lped-exc" + string(time).
    else varquivo = "l:\relat\lped-exc" + string(time).
    
    {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "187"
            &Page-Line = "66"
            &Nom-Rel   = ""lped-exc.p""
            &Nom-Sis   = """SISTEMA DE PEDIDOS"""
            &Tit-Rel   = """LISTAGEM DE PEDIDOS EXCLUÍDOS -
                           PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "187"
            &Form      = "frame f-cabcab"}

 
    
    
for each tt-liped no-lock.

    display tt-liped.etbcod   label "FIL"      
            tt-liped.pedtdc   label "MOV"      
            tt-liped.pednum   label "PED"       
            tt-liped.peddat   label "DATA"      
            tt-liped.procod   label "COD"      
            tt-liped.pronom   label "PRODUTO" format "x(50)"     
            tt-liped.lipqtd   label "QTD" format ">,>>9"     
            tt-liped.sitped   label "SIT"          
            tt-liped.DATA_EXCLUSAO  label "DAT EXC" 
            tt-liped.HORA_EXCLUSAO  label "HORA EXC" 
            tt-liped.ETB_EXCLUSAO   label "ETB EXC" format ">>9"
            tt-liped.USUARIO_EXCLUSAO   label "USU EXC"  format ">>>>>>9"
            tt-liped.funnom             label "NOME" format "x(22)"
            tt-liped.PROG_EXCLUSAO      label "PROG." format "x(20)"
                    skip with frame f01 width 190 down.

end.

    output close.
                                    

    if opsys = "UNIX"
    then do:
        message "Arquivo gerado: " varquivo. pause.
                                           
        run visurel.p (input varquivo, input "").
        
    end.    
    else do:
        {mrod.i}
    end.    
    
                                    
                                    
                                    
procedure p-comum:
                                    
   create tt-liped.
   assign
   tt-liped.etbcod = pedid.etbcod
   tt-liped.pedtdc = pedid.pedtdc
   tt-liped.pednum = pedid.pednum
   tt-liped.peddat = pedid.peddat
   tt-liped.procod = liped.procod
   tt-liped.pronom = produ.pronom
   tt-liped.lipqtd = liped.lipqtd
   tt-liped.sitped = pedid.sitped
   tt-liped.DATA_EXCLUSAO    = date(acha("DATA_EXCLUSAO",pedid.pedobs[3]))
   tt-liped.HORA_EXCLUSAO    = acha("HORA_EXCLUSAO",pedid.pedobs[3])
   tt-liped.ETB_EXCLUSAO     = int(acha("ETB_EXCLUSAO",pedid.pedobs[3]))
   tt-liped.USUARIO_EXCLUSAO = int(acha("USUARIO_EXCLUSAO",pedid.pedobs[3])).
   
   if tt-liped.USUARIO_EXCLUSAO <> ?
   then do:
   
       find first func where func.etbcod = tt-liped.ETB_EXCLUSAO
                         and func.funcod = tt-liped.USUARIO_EXCLUSAO
                                        no-lock no-error.
                                        
       tt-liped.funnom           = func.funnom.
   
   end.
   
   tt-liped.PROG_EXCLUSAO    = acha("PROG_EXCLUSAO",pedid.pedobs[3])
          .

end procedure.                                    
                                                                                    
