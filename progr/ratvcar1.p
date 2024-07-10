{admcab.i}

def var vetbcod like estab.etbcod.
def var vdti as date.
def var vdtf as date.

def temp-table tt-cartao
    field etbcod like estab.etbcod
    field clicod like clien.clicod
    field data  as date
    field valor as dec
    index i1 clicod.
    
def var vhorincl like plani.horincl.    
 def buffer btbcartao for tbcartao.
    
{selestab.i vetbcod f1}

disp vetbcod label "Filial"
     with frame f1 1 down side-label width 80.

update vdti label "Periodo de" format "99/99/9999"
       vdtf label "Ate" format "99/99/9999"
       with frame f1.
      
for each tt-lj no-lock:
    disp "Processando... " tt-lj.etbcod
        with frame ff 1 down no-label side-label centered
        row 12 color message no-box.
    pause 0.    

      for each tbcartao where
         tbcartao.datexp >= vdti and
         tbcartao.datexp <= vdtf and
         tbcartao.situacao = "L"
         no-lock:
         
         find first plani where plani.etbcod = tt-lj.etbcod
                            and plani.movtdc = 5
                            and plani.pladat = tbcartao.datexp
                            and plani.desti = tbcartao.clicod no-lock no-error.
                                     

     if acha("FILIAL",tbcartao.trilha[5]) <> ? 
     then if int(acha("FILIAL",tbcartao.trilha[5])) <> tt-lj.etbcod
          then next.
          else .
     else if not avail plani
          then next.
        
disp tbcartao.clicod format ">>>>>>>>>>9" with frame ff.
        pause 0.
    vhorincl = 0.
    for each plani where plani.etbcod = tt-lj.etbcod and
                         plani.movtdc = 5 and
                         plani.pladat >= vdti and
                         plani.pladat <= vdtf and
                         plani.desti = tbcartao.clicod
                         no-lock:
        disp plani.pladat plani.numero format ">>>>>>>>9" with frame ff.
        pause 0.
        if acha("CARTAO-LEBES",plani.notobs[1]) = ?
        then next.
        /*find first btbcartao where 
             btbcartao.clicod = plani.desti and
             btbcartao.situacao = "L" and
             btbcartao.datexp = plani.pladat
             no-lock no-error.
        if avail btbcartao
        then do:    */
        if plani.etbcod <> tt-lj.etbcod
        then next.
        find first tt-cartao where 
                   tt-cartao.clicod = plani.desti no-error.
        if not avail tt-cartao
        then do:
            create tt-cartao.
            tt-cartao.clicod = plani.desti.
        end.
        
disp plani.pladat string(plani.horinc,"HH:MM:SS")  with frame ff.
pause 0.

        if tt-cartao.data = ? or
           tt-cartao.data > plani.pladat
        then assign
                 tt-cartao.data = plani.pladat
                 tt-cartao.etbcod = plani.etbcod
                 tt-cartao.valor = if plani.biss > plani.platot
                                   then plani.biss else plani.platot
                 vhorincl = plani.horincl                                   
                 .
        if tt-cartao.data = plani.pladat and
           vhorincl > plani.horincl
        then assign
                 tt-cartao.data = plani.pladat
                 tt-cartao.etbcod = plani.etbcod
                 tt-cartao.valor = if plani.biss > plani.platot
                                   then plani.biss else plani.platot
                 vhorincl = plani.horinc                                   
                 .                 
        end.            
   /* end.*/
    end.
end.

def var varquivo as char.
def var vqtd as int.    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/Lcartao" + string(setbcod) + "."
                    + string(time).
    else varquivo = "..~\relat~\Lcartao" + string(setbcod) + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""programa"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """ CARTOES LEBES - PRIMEIRA COMPRA """ 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

    disp with frame f1.
    for each tt-cartao:
        find clien where clien.clicod = tt-cartao.clicod
                    no-lock no-error.
        if not avail clien then next.
        disp tt-cartao.clicod column-label "Cliente"
             clien.clinom column-label "Nome"
             tt-cartao.data column-label "Data Libera"
             tt-cartao.valor column-label "Valor Venda"
             with frame f-disp down width 100.
        vqtd = vqtd + 1.
    end.                
    put skip(1)
        "       Total de Clientes: "
        vqtd skip.
        
    vqtd = 0.
    for each tt-cartao break by tt-cartao.etbcod:
        vqtd = vqtd + 1.
        if last-of(tt-cartao.etbcod)
        then do:
             put skip
                     "       Total Filial " tt-cartao.etbcod ": "
                             vqtd skip.
            vqtd = 0.
        end.
    end.    
    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.

