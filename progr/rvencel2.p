{admcab.i}

def var vetbcod like estab.etbcod.
def var vdti as date.
def var vdtf as date.
def var vtmovqtm as dec.
def var vtvalven as dec.
def var vtctoven as dec.
def var vtctocmp as dec.
def var vtprice as dec.
def var vnum-cel-aux as char.

def new shared temp-table tt-proprice 
    field etbcod like plani.etbcod
    field movdat like movim.movdat
    field procod like produ.procod
    field numero like plani.numero
    field pronom like produ.pronom
    field movqtm like movim.movqtm
    field movpc  like movim.movpc
    field valcmp like movim.movpc
    field totven  as dec
    field plano  as char
    field promocao as char
    field cel-num  as char
    field funcod   as integer
    field funnom   as char
    index i1 etbcod movdat procod.


def temp-table tt-estab
    field etbcod like estab.etbcod
    index i1 etbcod
    .

def var vplano as char.
def var vpromo as char.
def var vfuncod as integer.

def var setbcod-aux as integer.    
    
def buffer bestab for estab.
def buffer bfunc for func.

update vetbcod label "Filial" with frame f1 
        width 80 side-label.
if vetbcod > 0
then do:        
    find bestab where bestab.etbcod = vetbcod no-lock.
    disp bestab.etbnom no-label with frame f1.
    create tt-estab.
    tt-estab.etbcod = bestab.etbcod.        
end.
else do:
    for each bestab no-lock:
        create tt-estab.
        tt-estab.etbcod = bestab.etbcod
         .
    end.     
end.

assign setbcod-aux = setbcod.

assign setbcod = vetbcod.

update vdti at 1 label "Periodo de" format "99/99/9999"
       vdtf label "Ate"             format "99/99/9999" skip
       vfuncod label "Vendedor" format ">>>>>9"
            help "Para usar o Zoom(Tecla F7) selecione antes a Filial desejada."        with frame f1.

if vfuncod > 0
then do:

    find last bfunc where bfunc.etbcod = setbcod
                      and bfunc.funcod = vfuncod  no-lock no-error.
                      
    disp bfunc.funnom no-label with frame f1.      

end.
       
assign setbcod = setbcod-aux.

def buffer bmovim for movim.
def var vprice as dec.

def var vindex as int.
def temp-table tt-classe like clase.
def var vesp as char extent 3 format "x(15)"
        init["VIVO","CLARO","TIM"].
disp vesp with frame f-esp 1 down no-label 1 column.
choose field vesp with frame f-esp.
vindex = frame-index.
if frame-index = 1
then do:
    create tt-classe.
    tt-classe.clacod = 101.
    create tt-classe.
    tt-classe.clacod = 102.
    create tt-classe.
    tt-classe.clacod = 107.
    create tt-classe.
    tt-classe.clacod = 109.
end.
if frame-index = 2 
then do:
    create tt-classe.
    tt-classe.clacod = 201.
end.
if frame-index = 3
then do:
    create tt-classe.
    tt-classe.clacod = 191.
end.    
disp  vesp[frame-index] at 60 no-label with frame f1.

hide frame f-esp no-pause.

update vplano label "Plano" vpromo label "Promocao"
            with frame f01 overlay row 11 side-labels. 

for each tt-estab where tt-estab.etbcod = 0 :
    delete tt-estab.
end.    
for each tt-proprice:
    delete tt-proprice.
end.
def var vi as int.    
for each tt-classe:
for each produ where produ.clacod = tt-classe.clacod no-lock.
    disp "Processando... Aguarde! ..-->"
         produ.procod
         with frame f-tela 1 down centered row 10 no-label.
    pause 0.     
    for each movim where movim.procod = produ.procod and
                         movim.movtdc = 5 and
                         movim.movdat >= vdti and
                         movim.movdat <= vdtf
                         no-lock:
        find first tt-estab where tt-estab.etbcod = movim.etbcod no-error.
        if not avail tt-estab
        then next.
        find first plani where 
                   plani.etbcod = movim.etbcod and
                   plani.placod = movim.placod and
                   plani.movtdc = movim.movtdc and
                   plani.pladat = movim.movdat
                   no-lock no-error.
        if not avail plani
        then next.           
        disp movim.etbcod movim.movdat with frame f-tela.
        pause 0.
        
        if vfuncod > 0
            and plani.vencod <> vfuncod
        then next.    
        
        if integer(vplano) > 0
            and acha("CODVIV" + string(produ.procod),plani.notobs[3])
                        <> vplano
        then next.
                                        
        if integer(vpromo) > 0
            and acha("TIPVIV" + string(produ.procod),plani.notobs[3])
                        <> vpromo
        then next.
        
        find last func where func.etbcod = plani.etbcod
                         and func.funcod = plani.vencod no-lock no-error.
        
        find last tbprice where tbprice.etb_venda = movim.etbcod
                            and tbprice.data_venda = plani.pladat
                            and tbprice.nota_venda = plani.numero
                                        no-lock no-error.
        
        find last bmovim where bmovim.procod = produ.procod and
                         bmovim.movtdc = 4 and
                         bmovim.movdat < movim.movdat
                         no-lock no-error.
                         
         do vi = 1 to movim.movqtm:
         
            create tt-proprice.
            assign
                tt-proprice.etbcod   = movim.etbcod 
                tt-proprice.numero   = plani.numero
                tt-proprice.procod   = movim.procod
                tt-proprice.pronom   = produ.pronom
                tt-proprice.movdat   = movim.movdat
                tt-proprice.movqtm   = 1
                tt-proprice.movpc    = movim.movpc 
                tt-proprice.totven   = movim.movpc 
                tt-proprice.funcod   = plani.vencod.
                
            if avail func
            then assign tt-proprice.funnom = func.funnom.   
                
            if avail tbprice    
            then assign tt-proprice.cel-num = acha("CEL-NUMERO",tbprice.char2)
            .

            if tt-proprice.cel-num = ?
            then assign tt-proprice.cel-num = "".
            
            tt-proprice.plano = 
                acha("CODVIV" + string(produ.procod),plani.notobs[3]).
            tt-proprice.promocao =
                acha("TIPVIV"  + string(produ.procod),plani.notobs[3]).
            if avail bmovim
            then tt-proprice.valcmp = bmovim.movpc - bmovim.movdes.
        end.
    end.
end.
end.
hide frame f-tela no-pause.

    def var varquivo as char.
    
    sresp = no.
    message "Gerar arquivo para EXCEL ? " update sresp.
    if sresp
    then do:
        if opsys = "UNIX"
        then varquivo = "/admcom/price/venda_" + string(vetbcod,"999") 
                        + "_" +
                        vesp[vindex] + "_" +
                        string(day(vdti),"99") + 
                        string(month(vdti),"99") + 
                        string(year(vdti),"9999") +
                        "a" +
                        string(day(vdtf),"99") + 
                        string(month(vdtf),"99") + 
                        string(year(vdtf),"9999") +
                        "h" + string(time) +
                        ".csv" .
        else varquivo = "l:~\price~\venda_" + string(vetbcod,"999") 
                        + "_" +
                        vesp[vindex] + "_" +
                        string(day(vdti),"99") + 
                        string(month(vdti),"99") + 
                        string(year(vdti),"9999") +
                        "a" +
                        string(day(vdtf),"99") + 
                        string(month(vdtf),"99") + 
                        string(year(vdtf),"9999") +
                        "h" + string(time) +
                        ".csv" .

        output to value(varquivo) page-size 0.
        
        put unformatted 
            "Fil;"
            "NF.Venda;" 
            "Dt.Venda;"  
            "Produto;"
            "Descricao;" 
            "Qtd;"
            "Val.Venda;"
            "Val.Compra;"
            "Plano;"
            "Promocao"
            skip.
        for each tt-proprice:
            put unformatted
            tt-proprice.etbcod  format ">>9"
            ";"
            tt-proprice.numero  format ">>>>>>>9"
            ";"
            tt-proprice.movdat  format "99/99/99"
            ";"
            tt-proprice.procod  format ">>>>>>>9"
            ";"
            tt-proprice.pronom  format "x(40)"
            ";"
            tt-proprice.movqtm  format ">>>>9"
            ";"
            tt-proprice.cel-num format "99999999999"
            ";"
            tt-proprice.plano   format "x(6)"
            ";"
            tt-proprice.promocao format "x(10)"
            ";"
            tt-proprice.funcod
            ";"
            tt-proprice.funnom
            ";"
            skip.
        end.

        output close.

        message color red/with
            "Arquivo gerado: " varquivo
            view-as alert-box .
     
    end.
    
    varquivo = "".
 
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/price"  + string(time).
    else varquivo = "l:\relat\price" + string(time).
                                    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "130" 
                &Page-Line = "66" 
                &Nom-Rel   = ""promtitl"" 
                &Nom-Sis   = """SISTEMA COMERCIAL""" 
                &Tit-Rel   = """RELATORIO DE VENDA DE CELULAR""" 
                &Width     = "140"
                &Form      = "frame f-cabcab"}
    disp with frame f1.
    for each tt-proprice:
    
        /********Ajusta o Format do Telefone de acordo com o tamanho**********/
        
        if length(tt-proprice.cel-num) = 11
        then
        assign vnum-cel-aux = string(tt-proprice.cel-num,"(999)9999-9999").
        else if length(tt-proprice.cel-num) = 10
        then 
        assign vnum-cel-aux = string(tt-proprice.cel-num,"(99)9999-9999").
        else assign vnum-cel-aux = string(tt-proprice.cel-num).


        display tt-proprice.etbcod column-label "Fil"  format ">>9"
            tt-proprice.numero column-label "NF.Venda" format ">>>>>>>9"
            tt-proprice.movdat column-label "Dt.Venda" format "99/99/99"
            tt-proprice.procod column-label "Produto"  format ">>>>>>>9"
            tt-proprice.pronom column-label "Descricao" format "x(37)"
            tt-proprice.movqtm(total) column-label "Qtd" format ">>>>9"
            vnum-cel-aux  column-label "Celular" format "x(14)"
            tt-proprice.plano  column-label "Plano"  format "x(6)"
            tt-proprice.promocao column-label "Promocao" format "x(8)"
            tt-proprice.funcod column-label "Cod" format ">>>>9"
            tt-proprice.funnom column-label "Vendedor" format "x(28)"
            with frame f-disp down width 150.
        down with frame f-disp.    
    end.
    
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.     


