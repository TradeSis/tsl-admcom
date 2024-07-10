{admcab.i}
{alcis/tpalcis.i}
def input parameter par-arq as char.

def var varquivo as char.
varquivo = alcis-diretorio + "/" + par-arq.
unix silent value("quoter " + varquivo + " > ./consulta-inve.arq" ). 
def temp-table ttarq
    field Remetente         as char format "x(10)"
    field nome_arquivo      as char format "x(4)"
    field Nome_interface    as char format "x(8)"
    field Site              as char format "xxx"
    field Prop_estoq        as char format "x(12)"  
    field Produto           as char format "x(40)"
    field unidade           as char format "x(6)"
    field Quantidade        as char format "x(18)"
    field Indicador         as char format "xx"
    field Motivo            as char format "x(30)".

def var vlinha as char.
input from ./consulta-inve.arq.
repeat.
    import vlinha.
    create ttarq.
    assign ttarq.Remetente      = substr(vlinha,1 ,10)
           ttarq.Nome_arquivo   = substr(vlinha,11,4 )
           ttarq.Nome_interface = substr(vlinha,15,8 )
           ttarq.Site           = substr(vlinha,23,3 )
           ttarq.Prop_estoq     = substr(vlinha,26,12)
           ttarq.Produto        = substr(vlinha,38,40)
           ttarq.unidade        = substr(vlinha,78,6)
           /*
           ttarq.Quantidade     = substr(vlinha,78,18)
           ttarq.Indicador      = substr(vlinha,96,2 )
           ttarq.Motivo         = substr(vlinha,98,30)
           */
           ttarq.Quantidade     = substr(vlinha,84,18)
           ttarq.Indicador      = substr(vlinha,102,10 )
           ttarq.Motivo         = substr(vlinha,112,30)
           .
    if ttarq.REMETENTE = "REMETENTE" then delete ttarq.
end.
input close.

for each estoq where estoq.etbcod = 900 no-lock.
    if estoq.estatual = 0
    then next.
    find first ttarq where ttarq.produto = string(estoq.procod)
        no-lock no-error.
    if not avail ttarq
    then do:
        create ttarq.
        ttarq.Produto       = string(estoq.procod).
        ttarq.Quantidade    = "".
        ttarq.Prop_estoq    = string(estoq.etbcod).
    end.
end.                  

varquivo = "../relat/consulta-inve." + string(time).
    
        {mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "157"
            &Page-Line = "66"
            &Nom-Rel   = ""INVE""
            &Nom-Sis   = """INTEGRACAO WMS ALCIS"""
            &Tit-Rel   = """BATIMENTO DE ESTOQUE - ARQUIVO : "" + par-arq "
            &Width     = "157"
            &Form      = "frame f-cabcab"}
for each ttarq.
    find estoq where estoq.procod = int(ttarq.Produto) and
                     estoq.etbcod = int(ttarq.Prop_estoq)
                     no-lock no-error.
    disp ttarq.Remetente
        /* ttarq.Nome_arquivo */
        /* ttarq.Nome_interface */
         ttarq.Site
         ttarq.Prop_estoq
         int(ttarq.Produto) format ">>>>>>>9"
         dec(ttarq.Quantidade) / 1000000000 column-label "ESTOQUE!WMS"
         format "->>>>>9"         
         estoq.estatual when avail estoq column-label "ESTOQUE!ERP"
         format "->>>>>9"
         ttarq.Indicador
         ttarq.Motivo
            with frame flin width 250
                    down.
    down with frame flin.
end.                        
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end.
    
