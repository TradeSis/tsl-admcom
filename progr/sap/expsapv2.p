/* Exportador SAP */
/*#1 - helio.neto - Exportacao Planilha CSV , produtos com Regra de Negocio igual abas/expabasneogrid.p */
/*#2 - helio.neto - 07.2019 - Mais Campos */

def var par-dataCadastramento as date label "Cadastrados desde" format "99/99/9999".
def var vdir-arquivo as char format "x(50)" init "/admcom/tmp/expsap/".

par-dataCadastramento = today - (15 * 30).
 
def var vconta  as int.
def var vproindice like produ.proindice. 
def var vcaract      as char.
def var vsubcar   as char.
def var vcor    as char.

def var vvoltagem   as char.
def var vtot as int.
def var vtemcompra as log.
def var vtemvenda  as log.
def var vtemestoq  as log.
def var vtemtempo  as log.
def var vtemtransf as log.

def var xtime as int.
xtime = time.


def var tmp-arquivo  as char extent 1.
def var nome-arquivo as char extent 1 format "x(70)" .

    
def var vsysdata     as char.  
vsysdata = string(year(today) ,"9999") 
         + string(month(today),"99")
         + string(day(today)  ,"99")
         + string(time,"HH:MM").
vsysdata = replace(vsysdata,":","").

def var cdata     as char.  
cdata = string(year(par-datacadastramento) ,"9999") 
         + string(month(par-dataCadastramento),"99")
         + string(day(par-dataCadastramento)  ,"99").

tmp-arquivo[1] = vdir-arquivo  + "tmp1".

nome-arquivo[1] = vdir-arquivo + "lebes-" + cdata + "-sap-" + vsysdata + "_itens.csv".

if SESSION:BATCH-MODE = no
then do:
    disp
        par-dataCadastramento skip
        nome-arquivo no-label
        with side-labels
        1 down
        centered
        frame farquivo
        width 80.
    update
        par-dataCadastramento
        with frame farquivo.

    cdata = string(year(par-datacadastramento) ,"9999") 
             + string(month(par-dataCadastramento),"99")
             + string(day(par-dataCadastramento)  ,"99").
    nome-arquivo[1] = vdir-arquivo + "lebes-" + cdata + "-sap-" + vsysdata + "_itens.csv".
    update
        nome-arquivo
        with frame farquivo.
end.    

IF NOME-ARQUIVO[1] <> ""
THEN DO:
    def stream produ.
    output stream produ to value(tmp-arquivo[1]).
END.
    
def var vloop as int.
def var vCNPJ as char.
 
def var vcp     as char no-undo init ";".

function retira-acento returns character(input texto as character):

    define variable c-retorno as character no-undo.
    define variable c-letra   as character no-undo case-sensitive.
    define variable i-conta         as integer   no-undo.
    def var i-asc as int.
    def var c-caracter as char.

    do i-conta = 1 to length(texto):
        
        c-letra = substring(texto,i-conta,1).
        i-asc = asc(c-letra).

        if c-letra = ";"                       then c-caracter = ",". /* csv */
        else
        if i-asc <= 160                         then c-caracter = c-letra.
        else if i-asc >= 161 and i-asc <= 191  or
                i-asc >= 215 and i-asc <= 216  or
                i-asc >= 222 and i-asc <= 223  or
                i-asc >= 247 and i-asc <= 248       then c-caracter = " ".
        else if i-asc >= 192 and i-asc <= 198       then c-caracter = "A".
        else if i-asc = 199                     then c-caracter = "C".
        else if i-asc >= 200 and i-asc <= 203       then c-caracter = "E".
        else if i-asc >= 204 and i-asc <= 207       then c-caracter = "I".
        else if i-asc =  208                     then c-caracter = "D".
        else if i-asc = 209                     then c-caracter = "N".
        else if i-asc >= 210 and i-asc <= 214       then c-caracter = "O".
        else if i-asc >= 217 and i-asc <= 220       then c-caracter = "U".
        else if i-asc = 221                     then c-caracter = "Y".
        else if i-asc >= 192 and i-asc <= 198       then c-caracter = "A".
        else if i-asc >= 224 and i-asc <= 230       then c-caracter = "a".
        else if i-asc = 231                     then c-caracter = "c".
        else if i-asc >= 223 and i-asc <= 235       then c-caracter = "e".
        else if i-asc >= 236 and i-asc <= 239       then c-caracter = "i".
        else if i-asc = 240                     then c-caracter = "o".
        else if i-asc = 241                     then c-caracter = "n".
        else if i-asc >= 242 and i-asc <= 246       then c-caracter = "o".
        else if i-asc >= 249 and i-asc <= 252       then c-caracter = "u".
        else if i-asc >= 253 and i-asc <= 255       then c-caracter = "y".
        else c-caracter = c-letra.
        c-retorno = c-retorno + c-caracter.

    end.
    if c-retorno = "" or c-retorno = ? then c-retorno = "NULO".
    return trim(c-retorno).
end function.


def buffer sclase   for clase.
def buffer grupo    for clase.
def buffer setclase for clase.
def buffer depto    for clase.


def var vestatual as dec.
def var vestcusto as dec.
def var vestvenda as dec.
pause 0 before-hide.

vconta = 0.
vtot = 0.
IF NOME-ARQUIVO[1] <> ""
THEN do:
hide message no-pause.
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Calculando Produtos...".


        put  stream produ unformatted 
           "Codigo" vcp
           "Descricao"   vcp
           /*#2*/
           "Descrição Abreviada" vcp
           "Unidade de Venda" vcp
           "Departamento (Cod e Desc)" vcp
           "Setor (Cod e Desc)" vcp
           "Grupo (Cod e Desc)" vcp 
           "Classe (Cod e Desc)" vcp 
           "Subclasse (Cod e Desc)" vcp 
           "Cod. Barras" vcp
           "Cod Fornecedor" vcp 
           "Desc Fornecedor" vcp 
           "CNPJ Fornecedor" vcp 
           "Características (separadas com vírgula)" vcp
           "Subcaracterísticas (separadas com vírgula)" vcp 
           "estação" vcp
           "temporada" vcp 
           "voltagem" vcp 
           "cor" vcp 
           "NCM" vcp
           "Data Cadastro"
           /*#2*/
           skip.

for each produ no-lock on error undo , next.
    
        vtot = vtot + 1.
    /* filtros */
    if produ.catcod = 31 or
       produ.catcod = 41
    then.
    else next.
    if produ.proseq = 0
    then.
    else next.

    
                   
    vconta = vconta + 1.
    if vconta mod 1000 = 0 or vconta <= 10
    then do:
        hide message no-pause.
        message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Exportando Produtos..." produ.procod vtot vconta.
    end.    

         
    release sclase.
    release clase.
    release grupo.
    release setclase.
    release depto. 
    find sClase     where sClase.clacod   = produ.clacod    no-lock no-error. 
    if avail sclase 
    then do: 
        find Clase      where Clase.clacod    = sClase.clasup   no-lock no-error. 
        if avail clase 
        then do: 
            find grupo      where grupo.clacod    = Clase.clasup    no-lock no-error. 
            if avail grupo 
            then do: 
                find setClase   where setClase.clacod = grupo.clasup    no-lock no-error.   
                if avail setClase 
                then do: 
                    find depto   where depto.clacod = setclase.clasup    no-lock no-error.    
                end. 
            end. 
        end. 
    end.                    
        
    vtemtempo = produ.prodtcad >= par-dataCadastramento.    
    vtemestoq = no.
    vtemvenda = no.
    vtemcompra = no.
    vtemtransf = no.
    for each estab no-lock.
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod
                    no-lock no-error.
        vestatual   = if avail estoq and estoq.estatual > 0
                      then estoq.estatual
                      else 0.
        vtemestoq   = avail estoq and estoq.estatual <> 0.
    
        find last movim use-index icurva
            where movim.etbcod = estab.etbcod and
                  movim.procod = produ.procod and
                  movim.movtdc = 5            and
                  movim.movdat >= today - (15 * 30)
                  no-lock no-error.
        vtemvenda = avail movim.
        find last movim use-index icurva
                where movim.etbcod = estab.etbcod and
                      movim.procod = produ.procod and
                      movim.movtdc = 4            and
                      movim.movdat >= today - (15 * 30)
                      no-lock no-error.
        vtemcompra = avail movim.
        /*30.05.2019 Nova regra */
        find last movim use-index icurva
            where movim.etbcod = estab.etbcod and
                  movim.procod = produ.procod and
                  movim.movtdc = 6            and
                  movim.movdat >= today - (15 * 30)
                  no-lock no-error.
        vtemtransf = avail movim.
        if vtemestoq or
           vtemvenda or
           vtemcompra or
           vtemtransf
        then leave.   
    end.
    
    if not vtemtempo and
       not vtemestoq and
       not vtemcompra and
       not vtemvenda and
       not vtemtransf
    then next.    
        
    
    find categoria of produ no-lock no-error.
    release fabri.
    release forne.
    
    find fabri of produ no-lock no-error.
    if avail fabri
    then find forne where forne.forcod = fabri.fabcod no-lock no-error.
    find estac where estac.etccod = produ.etccod no-lock no-error.
    find temporada where temporada.temp-cod = produ.temp-cod 
            /**and temporada.dtini <= today and
               (temporada.dtfim >= today or
                temporada.dtfim = ?)**/
            no-lock no-error.
    

        /* CRIA TEMP PARA COMPATIBILIDADE  COM PROGRAMA ANTERIOR */
        
    vproindice = retira-acento(produ.proindice).

        vvoltagem = "".
        find caract where caract.cardes = "VOLTAGEM" no-lock no-error.
        if avail caract
        then do:
            for each subcaract of caract no-lock.
                find procaract of produ where
                    procarac.subcod = subcaract.subcod
                    no-lock no-error.
                if avail procaract
                then vvoltagem = retira-acento(subcaract.subdes).
            end.
        end.

        vcaract = "". 
        vsubcar = "". 
        for each procaract of produ no-lock.  
            find subcaract of procaract no-lock.  
            find caract of subcaract no-lock.  
            vcaract = vcaract + (if vcaract = "" then "" else ",") + caract.cardes. 
            vsubcar = vsubcar + (if vsubcar = "" then "" else ",") + subcar.subdes. 
        end.

        vcor = "".
        find cor of produ no-lock no-error.
        if avail cor
        then vcor = cor.cornom.
                                                                  
           
        /*
        Layout em CSV: Código - Nome - Departamento - Grupo - Data Cadastro
        */
        put stream produ unformatted 
           string(produ.procod) vcp
           retira-acento(produ.pronom)  vcp
           /*#2*/
           retira-acento(produ.pronomc)  vcp
           "UN" vcp
           (if avail depto then string(depto.clacod) else "NULO" ) + 
            (if avail depto then ("-" + retira-acento(depto.clanom)) else "") vcp
           
           (if avail setclase then string(setclase.clacod) else "NULO" ) + 
            (if avail setclase then ("-" + retira-acento(setclase.clanom)) else "") vcp

           (if avail grupo then string(grupo.clacod) else "") + "-" +
            (if avail grupo then retira-acento(grupo.clanom) else "") vcp
            
           (if avail clase then string(clase.clacod) else "") + "-" +
            (if avail clase then retira-acento(clase.clanom) else "") vcp

           (if avail sclase then string(sclase.clacod) else "") + "-" +
            (if avail sclase then retira-acento(sclase.clanom) else "") vcp

           (if vproindice <> ? 
            then if trim(vproindice) = "SEM GTIN" 
                then "" 
                else vproindice                                
            else "" ) vcp
            
           produ.fabcod     vcp
           if avail fabri then fabri.fabnom else ""    vcp
           if avail forne then forne.forcgc else ""   format "x(14)" vcp
           vcaract vcp
           vsubcar vcp
           string(produ.etccod) + "-" + (if avail estac then  retira-acento(estac.etcnom) else "NULO") vcp
           string(produ.temp-cod)  + "-" + (if avail temporada then retira-acento(temporada.tempnom) else "NULO") vcp
           vvoltagem    vcp
           vcor         vcp

           trim(produ.proclafis) vcp
           
           /*#2*/
            
           produ.prodtcad format "99/99/9999"           
               
        skip .
    
end.
END.

IF NOME-ARQUIVO[1] <> ""
THEN DO:
    output stream produ close.
END.
    

hide message no-pause.

message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Encerrando...".

do vloop = 1 to 1:
    IF NOME-ARQUIVO[VLOOP] = "" THEN NEXT.
    unix silent value ("unix2dos -q " + tmp-arquivo[vloop]).
    unix silent value ("mv -f " + tmp-arquivo[vloop] + " " + nome-arquivo[vloop]).
    
end.    

 
hide message no-pause.
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "FIM".

