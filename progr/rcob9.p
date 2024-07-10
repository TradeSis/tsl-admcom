{admcab.i}

def var varquivo as char.

def var vcobertura as int format ">>>9" label "Cobertura".
def var vqtdped as int.
def var v as int format ">>>>>>>>>>9".
def var vestdep  like estoq.estatual.
def var totven   like movim.movqtm.
def var totpcven like movim.movpc.
def var vdata    as   date format "99/99/9999".
def var vdata1   as   date format "99/99/9999".
def var vdata2   as   date format "99/99/9999".
def var vdias as int format ">>>9" label "Dias de Analise".

vcobertura = 15.
vdata1 = ((today - 1) - 30).
vdias  = 30.

message "Confirma emissao do Relatorio? " update sresp.
if not sresp then undo.

message "Gerando relatorio...".
    
if opsys = "UNIX"
then 
    varquivo = "/admcom/relat/rcob9" + string(time).
else 
    varquivo = "l:\relat\rcob9" + string(time).

{mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "115"
        &Page-Line = "0"
        &Nom-Rel   = ""rcob9""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """RELATORIO DE COBERTURA - MOVEIS"""
        &Width     = "115"
        &Form      = "frame f-cabcab"}


def var v-cont as int .
for each categoria where categoria.catcod = 31 /*or
                         categoria.catcod = 35 */ no-lock:
                         
  for each produ use-index icatcod where produ.catcod = categoria.catcod no-lock
                                      by produ.fabcod:
    find fabri where fabri.fabcod = produ.fabcod no-lock no-error.
    find clase where clase.clacod = produ.clacod no-lock no-error.
    if not avail clase then next.
  /*  
    if clase.clasup = 10 or
       clase.clasup = 20 or
       clase.clasup = 30 or
       clase.clasup = 100
    then next.
    */
    vestdep = 0.
    for each estoq where estoq.etbcod >= 900 and
                         estoq.procod = produ.procod no-lock:
     
        vestdep = vestdep + estoq.estatual. 
     
    end.
    
    repeat v-cont = 91 to 99:
        for each estoq where estoq.etbcod = v-cont and
                         estoq.procod = produ.procod no-lock:
     
        vestdep = vestdep + estoq.estatual. 
     
     end.
    end.

    

    totven = 0.                        
     
    do vdata = vdata1 to today:
        for each movim where movim.procod = produ.procod
                         and movim.movtdc = 05
                         and movim.movdat = vdata no-lock:

            assign totven = totven + movim.movqtm 
                   totpcven = totpcven + (movim.movqtm * movim.movpc).

        end.
    end.

    vqtdped = 0.
    
    do vdata = today - 60 to today + 60: 
        for each liped where liped.pedtdc = 1 
                         and liped.procod = produ.procod 
                         and liped.predtf  = vdata no-lock: 
            
            find pedid of liped no-lock no-error.
            
            if (today - pedid.peddtf) > 30 
            then next.
         
            if pedid.sitped = "F" then next.
                    
            vqtdped = vqtdped + (liped.lipqtd - liped.lipent).
                    
        end.
    end.                 

    if totven <= 0 or
       (vestdep + vqtdped) <= 0
    then next.

    if int(((vestdep + vqtdped) * vdias) / totven) > vcobertura
    then next. 

    v = v + 1.
    
    disp produ.procod column-label "Produto"
         produ.pronom column-label "Descricao" 
         fabri.fabfan column-label "Fabricante"
         vestdep format "->>>>>>>>9" column-label "Est. Dep"
         vqtdped      column-label "Qtd.Ped" 
         totven       column-label "Tot.Ven"
        int(((vestdep + vqtdped) * vdias) / totven)
            column-label "Cobertura"
            with frame f-dadosm width 115 down.
    down with frame f-dadosm.

  end.
  
end.

output close.
    
if opsys = "UNIX"
then do:
    run visurel.p (input varquivo, input "").
end.
else do:
    {mrod.i}.
end.    

