{admcab.i}
def var vcod as int format "99".
def var vseq as int format "99".
def var varquivo as char.
def var vdata like plani.pladat.
def var varq as char format "x(20)".
def temp-table tt-arq
    field arq as char format "X(20)".
def temp-table tt-spc
    field clicod like clien.clicod
    field cod   as char
    field reg   as char
    field dtnas as char format "x(10)"
    field nome  as char format "x(50)"
    field mens  as char format "x(150)".
    
def var warq as char format "x(50)".    
def var vtexto as char format "x(150)".
def var vreg   as char format "x(12)".
repeat:

    for each tt-spc:
        delete tt-spc.
    end.
    
    for each tt-arq.
        delete tt-arq.
    end.

    vseq = 0.
    
    update vdata label "Data" 
           vseq  label "Sequencia"
           vcod  label "Cod.Retorno"
            with frame f1 side-label width 80.
            
    dos silent dir value("i:\spc\DFIN" + string(day(vdata),"99") +
                          string(month(vdata),"99") + ".R" +
                          string(vseq,"99") )               
                          /s/b > value("i:\spc\arq.txt").
    
                            
    input from i:\spc\arq.txt.
    repeat:
        import warq.
        dos silent c:\dlc\bin\quoter value(warq) > 
                      value("i:\spc\qq" + substring(warq,10,10)). 
    end.
    input close.
            
    dos silent dir value("i:\spc\qq??" + string(day(vdata),"99") +
                          string(month(vdata),"99") + ".R" + 
                          string(vseq,"99") ) 
                          /s/b > value("i:\spc\arq.txt").
                          
    
    input from i:\spc\arq.txt.                   
    repeat:
        create tt-arq.
        import tt-arq.
    end.
    input close.
    
    vreg = "".
    for each tt-arq where tt-arq.arq <> "":
        input from value(tt-arq.arq).
        repeat:
            import vtexto.
            if substring(vtexto,1,2) = "00"
            then do:
                 if substring(vtexto,5,2) = "EX"
                 then vreg = "EXCLUSAO".
                 else vreg = "INCLUSAO".
            end.     
            if substring(vtexto,1,2) = "02"
            then do:
                create tt-spc.
                tt-spc.dtnas = string(substring(vtexto,35,2) + "/" + 
                                      substring(vtexto,37,2) + "/" + 
                                      substring(vtexto,39,4)).
                tt-spc.nome  = substring(vtexto,43,50).       
                tt-spc.reg   = vreg.
                
                find first clien where clien.clinom = substring(vtexto,43,50)
                                        no-lock no-error.
                if avail clien
                then tt-spc.clicod = clien.clicod.

                         
            end.    
                 
            if substring(vtexto,1,2) = "29"
            then assign tt-spc.cod  = string(substring(vtexto,9,2))
                        tt-spc.mens = string(substring(vtexto,11,150)).
    
        end.
        input close.

    end.
        
    varquivo = "..\relat\spc" + string(day(today)).
    {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""ret_inc""
            &Nom-Sis   = """SISTEMA DE COBRANCA"""
            &Tit-Rel   = """RETORNO DE SPC INCLUSAO FINANCEIRA DO DIA "" +
                          string(vdata,""99/99/9999"")"
            &Width     = "130"
            &Form      = "frame f-cabcab"}
    
    for each tt-spc break by tt-spc.reg 
                          by tt-spc.nome:  
       
       if first-of(tt-spc.reg)
       then disp "REGISTRO DE" 
            tt-spc.reg no-label with frame f2 width 80.
       
       if tt-spc.cod = "00" or
          tt-spc.cod = "01" or
          tt-spc.cod = "14" or
          tt-spc.cod = "47"
       then next.
       
       if vcod = 0
       then.
       else if vcod <> int(tt-spc.cod)
            then next. 
           
       
       disp tt-spc.clicod column-label "Codigo"    
            tt-spc.nome format "x(30)" column-label "Cliente"
           /* tt-spc.dtnas column-label "Data Nasc." */
           /* tt-spc.cod  column-label "Flag" format "x(02)" */
            tt-spc.mens format "x(100)" column-label "Mensagem"
                with frame f3 width 200 down.
    end.
    
    output close.
    /*
    dos silent value("type " + varquivo + "  > prn").
    */
    {mrod.i}
    
    dos silent del i:\spc\qq*.*.
    dos silent del i:\spc\arq.txt.
    
end.                 

 