{admcab.i}
def var vcont as int.
def var varq as char format "x(200)".
def var vtip as char format "x(01)".
def var vcon as char format "x(30)".
def var vend as char format "x(30)".
def var vcom as char format "x(20)".
def var vbai as char format "x(20)".
def var vcid as char format "x(30)".
def var vcep as char format "x(09)".
def var vgru as char format "x(04)".
def var vsub as char format "x(05)".
def var vetb as char format "x(06)".
def var vpar as char format "x(03)".
def var vass as date format "99/99/9999".
def var vven as date format "99/99/9999".
def var vval as char format "x(12)".
def var varquivo as char format "x(20)".

do:
    message "Confirma emissao de extrato" update sresp.
    if not sresp
    then leave.

        
    varquivo = "i:\admcom\relat\cnp" + string(day(today)).


    vcont = 0.
    
    dos silent quoter ..\work\c6939.txt > ..\work\teste2.
    input from ..\work\teste2.
    output to value(varquivo) page-size 0.

    repeat:

        import varq.
        assign vtip = substring(varq,1,1).
    

        if vtip = "1" 
        then do:
            if vcont <> 0
            then put skip(37 - vcont).
            else put skip(5).
        end.
        if vtip = "1"
        then do:
            vcont = 0.
            assign
               vcon = substring(varq,3,30)
               vend = substring(varq,34,30)
               vcom = substring(varq,65,20)
               vbai = substring(varq,86,20)
               vcid = substring(varq,107,30)
               vcep = substring(varq,138,09)
               vgru = substring(varq,148,04)
               vsub = substring(varq,153,05)
               vetb = substring(varq,159,06).
        
            put skip(5) 
                "Nome    : "  at 10  vcon
                "Endereco   : "  at 60  vend
                "Compl   : "  at 10  vcom
                "Bairro     : "  at 60  vbai
                "Cidade  : "  at 10  vcid
                "Cep        : "  at 60  vcep
                "Grupo   : "  at 10  vgru
                "Consorciado: " at 60     vsub
                "Filial  : "  at 10  vetb   skip(3)

               "Parcela   Assembleia   Vencimento   Valor Parcela"  at 30 skip
               "-------   ----------   ----------   -------------"  at 30 skip.
        
            next.

        end.
        else do:
            assign vpar = substring(varq,3,3)

                   vass = date(int(substring(varq,10,2)),
                               int(substring(varq,07,2)),
                               int(substring(varq,13,4))).
                
                   vven = date(int(substring(varq,21,2)),
                               int(substring(varq,18,2)),
                               int(substring(varq,24,4))).
            if vcont = 0
            then vval = substring(varq,29,12).
            else vval = "".
            vcont = vcont + 1.
            put  vpar at 34 
                 vass to 49
                 vven to 62
                 vval to 78. 
        end.
    end.
    output close.
    dos silent value("type " + varquivo + "  > prn").
end.


