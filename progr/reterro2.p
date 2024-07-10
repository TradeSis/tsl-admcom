{admcab.i}
def var vdtemi like titulo.titdtemi.
def var vdtven like titulo.titdtven.
def var varquivo as char.
def var vdata like plani.pladat.
def var varq as char format "x(20)".
def temp-table tt-arq
    field arq as char format "X(20)".
def temp-table tt-spc
    field cod   as char
    field reg   as char
    field dtnas as char format "x(10)"
    field nome  as char format "x(50)"
    field mens  as char format "x(50)".
    
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
    
    update vdata label "Data" 
            with frame f1 side-label width 80.
            
    dos silent dir value("i:\spc\DR??" + string(day(vdata),"99") +
                          string(month(vdata),"99") + ".R??") 
                          /s/b > value("i:\spc\arq.txt").
    
                            
    input from i:\spc\arq.txt.
    repeat:
        import warq.
        dos silent c:\dlc\bin\quoter value(warq) > 
                      value("i:\spc\qq" + substring(warq,10,10)). 
    end.
    input close.
            
    dos silent dir value("i:\spc\qq??" + string(day(vdata),"99") +
                          string(month(vdata),"99") + ".R??") 
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
                         
            end.    
                 
            if substring(vtexto,1,2) = "29"
            then assign tt-spc.cod  = string(substring(vtexto,9,2))
                        tt-spc.mens = string(substring(vtexto,11,60)).
    
        end.
        input close.

    end.
    
    {mdadmcab.i &Saida = "printer"
             &Page-Size = "64"
             &Cond-Var  = "160"
             &Page-Line = "66"
             &Nom-Rel   = """"
             &Nom-Sis   = """SISTEMA CREDIARIO""  +
                          ""                                                "" +
                          ""                    AO SPC DE SAO JERONIMO      """
             &Tit-Rel   = """ LISTAGEM DE CLIENTES PARA INCLUSAO""  +
                          "" EM "" + string(vdata) + "" - CODIGO : 160 "" "
             &Width     = "160"
             &Form      = "with frame f-cab1"}
    
    for each tt-spc where tt-spc.reg = "INCLUSAO" break by tt-spc.reg 
                                                        by tt-spc.nome:  
       
       if first-of(tt-spc.reg)
       then display tt-spc.reg no-label with frame f-tipo centered.
       if tt-spc.cod = "00" or
          tt-spc.cod = "01" or
          tt-spc.cod = "14" or
          tt-spc.cod = "47"
       then next.
       find first clien where clien.clinom = tt-spc.nome and
                              clien.dtnas  = date(
                                           int(substring(tt-spc.dtnas,4,2)),
                                           int(substring(tt-spc.dtnas,1,2)),
                                           int(substring(tt-spc.dtnas,7,4)))
                                    no-lock no-error.
       if avail clien
       then do:
            if tt-spc.reg = "inclusao"
            then do:
                find first clispc where clispc.clicod = clien.clicod and
                                         clispc.dtcanc = ? no-lock no-error.
                if avail clispc
                then do:
                    find contrato where contrato.contnum = clispc.contnum 
                                                    no-lock no-error.
                    for each titulo where titulo.empcod = 19 and
                                          titulo.titnat = no and
                                          titulo.modcod = "CRE" and
                                          titulo.etbcod = contrato.etbcod and
                                          titulo.clifor = clien.clicod and
                                      titulo.titnum = string(contrato.contnum)
                                          no-lock use-index titnum:
                        if titulo.titsit = "LIB"
                        then do:  
                            vdtemi = titulo.titdtemi. 
                            vdtven = titulo.titdtven. 
                            leave. 
                        end. 
                   end.
                end.   
            end.
            else do:
                find last clispc where clispc.clicod = clien.clicod and
                                       clispc.dtcanc <> ? no-lock no-error.
                find contrato where contrato.contnum = clispc.contnum 
                                                    no-lock no-error.
            end.           
                   
       end.
       
        display contrato.etbcod when avail contrato
               clien.clicod when avail clien label "Codigo"
               contrato.contnum when avail contrato
               tt-spc.nome       format "x(40)"
               clien.endereco[1] when avail clien
                                 format "x(20)"  label "Endereco"
               vdtemi when tt-spc.reg = "inclusao" format "99/99/9999" 
               tt-spc.dtnas
               clien.numero[1] when avail clien label "Numero"
               contrato.vltotal  when avail contrato 
               clien.mae format "x(30)" label "Mae" when avail clien
               clien.pai format "x(30)" label "Pai" when avail clien
               clien.compl[1] when avail clien format "x(5)"   label "Compl."
               clien.cep[1] when avail clien label "CEP"
               vdtven  when tt-spc.reg = "inclusao" 
               clien.cidade[1] when avail clien format "x(20)"  label "Cidade"
               clien.ciccgc when avail clien       label "CPF"
               clien.ciinsc when avail clien       label "CI"
                 with width 160 3 column with frame ff1.

        display skip
                fill("-",140)      format "x(140)" with width 160 3 column
                with frame ff4.

    end.
            
    output close.
            
    dos silent del i:\spc\qq*.*.
    dos silent del i:\spc\arq.txt.
    
end.                 

 