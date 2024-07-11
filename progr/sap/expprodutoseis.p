def var vi as int.
def var vcp as char init ";".

def var vproindice like produ.proindice. 
def var vcaract      as char.
def var vsubcar   as char.
def var vestcusto as dec.
def var vestvenda as dec.
 
def temp-table tt no-undo
    field procod like produ.procod.

input from /admcom/helio/produtoseis.csv.
repeat transaction.
    create tt.    
    import delimiter ";" tt.procod.
    vi = vi + 1.
end.
input close.

message vi.

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



output to /admcom/tmp/expsap/produtoseis_saida.csv.
put unformatted skip
        "ativo" vcp
        "dataCadastro" vcp
        "codigoProduto" vcp
        "descricaoCompleta" vcp
        "descricaoCompacta" vcp
        "codMercadologico" vcp
        "codigoFabricante" vcp
        "descricaoFabricante" vcp
        "codigoFornecedor" vcp
        "descricaoFornecedor" vcp
        "ean" vcp
        "caracteristica.codigoEstacao" vcp
        "aracteristica.codigoTemporada" vcp
        "caracteristica.caracteristicaGenerica.descricao" vcp
        "caracteristica.caracteristicaGenerica.valor" vcp
        "comercial.precoCusto" vcp
        "comercial.precoVenda" vcp
        "comercial.pedidoEspecial" vcp
        "comercial.vex" vcp
        "comercial.descontinuado" vcp
        "comercial.unidadeVenda" vcp
        "contabil.ncm" vcp.

for each tt.

    find produ where produ.procod = tt.procod no-lock no-error.
    if not avail produ
    then do:
        put unformatted skip
            "" vcp
            "" vcp
            tt.procod vcp
            "NAO CADASTRADO" vcp
            "" vcp
            "" vcp
            "" vcp
            "" vcp
            "" vcp
            "" vcp
            "" vcp
            "" vcp
            "" vcp
            "" vcp
            "" vcp
            "" vcp
            "" vcp
                "" vcp
            "" vcp
            "" vcp
            "" vcp
            "" vcp.

        next.
    end.    
    
    find fabri of produ no-lock no-error.

    vproindice = retira-acento(produ.proindice).
        vcaract = "". 
        vsubcar = "". 
        for each procaract of produ no-lock.  
            find subcaract of procaract no-lock.  
            find caract of subcaract no-lock.  
            vcaract = vcaract + (if vcaract = "" then "" else ",") + caract.cardes. 
            vsubcar = vsubcar + (if vsubcar = "" then "" else ",") + subcar.subdes. 
        end.

    find estac where estac.etccod = produ.etccod no-lock no-error.
    find temporada where temporada.temp-cod = produ.temp-cod 
            /**and temporada.dtini <= today and
               (temporada.dtfim >= today or
                temporada.dtfim = ?)**/
            no-lock no-error.
    find first estoq where estoq.etbcod = 900 and estoq.procod = produ.procod no-lock no-error.
    vestcusto = if avail estoq
                 then estoq.estcusto
                 else 0.
    find first estoq where estoq.etbcod = 1 and estoq.procod = produ.procod no-lock no-error.
    vestvenda = if avail estoq
                 then estoq.estcusto
                 else 0.
                 
    put unformatted skip
        string(produ.proseq = 0,"true/false") vcp
        produ.prodtcad vcp
        produ.procod        vcp
        produ.pronom        vcp
        produ.pronom        vcp
        produ.clacod        vcp
        produ.fabcod        vcp
        if avail fabri then fabri.fabnom  else "-"      vcp
        produ.fabcod        vcp
        if avail fabri then fabri.fabnom  else "-"      vcp
        
           (if vproindice <> ? 
            then if trim(vproindice) = "SEM GTIN" 
                then "" 
                else vproindice                                
            else "" ) vcp
        string(produ.etccod) + "-" + (if avail estac then  retira-acento(estac.etcnom) else "NULO") vcp
        string(produ.temp-cod)  + "-" + (if avail temporada then retira-acento(temporada.tempnom) else "NULO") vcp
        
        vcaract     vcp
        vsubcar     vcp
        vestcusto           vcp
        vestvenda           vcp
        trim(string(produ.proipival = 1,"true/false"))         vcp
         trim(string(produ.ind_vex,"true/false"))                 vcp
         trim(string(produ.descontinuado,"true/false"))      vcp 
        "UN"                vcp   
        trim(produ.proclafis) vcp.

    
    
end.

output close.

