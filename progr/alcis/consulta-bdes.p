/*    alcis/bdes_bloq.p                 */
{admcab.i}
{alcis/tpalcis.i}

def input parameter par-arq as char.

def var varquivo as char.
def var varq-dep as char.
def var varq-ant as char.

varquivo = alcis-diretorio + "/" + par-arq.
varq-ant = varquivo.
varq-dep = "/admcom/tmp/alcis/bkp/" + par-arq.

unix silent value("quoter " + varquivo + " > ./consulta-bdes_bloq.arq" ). 

def temp-table ttheader
    field Remetente         as char format "x(10)"
    field Nome_arquivo      as char format "x(4)"
    field Nome_interface    as char format "x(8)"
    field Site              as char format "xxx"
    field Proprietario      as char format "x(12)"
    field Procod            as char format "x(40)"
    field Qtd               as char format "x(18)"
    field Indicador         as char format "x(2)"
    field Motivo            as char format "x(30)"
    .

def var vlinha as char.
input from ./consulta-bdes_bloq.arq.
repeat.
    import vlinha.
    if substr(vlinha,15,8 ) = "BLOQ"    
    then do.
        create ttheader.
        assign ttheader.Remetente      = substr(vlinha,1 ,10)
               ttheader.Nome_arquivo   = substr(vlinha,11,4 )
               ttheader.Nome_interface = substr(vlinha,15,8 )
               ttheader.Site           = substr(vlinha,23,3 )
               ttheader.Proprietario   = substr(vlinha,26,12)
               ttheader.procod         = substr(vlinha,38,40)
               ttheader.qtd            = substr(vlinha,78,18)
               ttheader.indicador      = substr(vlinha,96,2)   
               ttheader.motivo         = substr(vlinha,98,30)
               .        
    end.
end.
input close.

varquivo = "../relat/consulta-inve." + string(time).
    
        {mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""BDES""
            &Nom-Sis   = """INTEGRACAO WMS ALCIS"""
            &Tit-Rel   = """BLOQUEIO/DESBLOQUEIO - ARQUIVO : "" + 
                            par-arq
                            "
            &Width     = "130"
            &Form      = "frame f-cabcab"}


    for each ttheader.
        display 
            remetente 
            ttheader.Nome_arquivo
            ttheader.Nome_interface
            ttheader.Site
            ttheader.Proprietario
            int(ttheader.procod) column-label "Produto"
            ttheader.indicador column-label "Ind"
            (if ttheader.indicador = "00" 
             then "LIBERA"
             else "BLOQUEIO") format "x(10)" no-label
            dec(ttheader.qtd) / 1000000000 format ">>>,>>>,>>9" 
                                label "Quantidade"
            motivo
            with frame ffff width 200.
    end.            

output close.

    
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end.
  
