def input param p-arquivo   as char.
def input param p-diretorio as char.

def var p-recid as recid.

def var p-saida as char.
def var p-entrada as char.
def var p-dircsv as char init "/admcom/tmp/edi/csv/".
def var p-excel  as char.
  
p-saida   = entry(1,p-arquivo,".") + ".csv".
p-entrada = p-diretorio + "/" + p-arquivo.
p-excel   = p-dircsv          + p-saida.


def var pforcnpj    as char format "x(14)".
def var ppednum     as int format ">>>>>>>>9".

def temp-table ttexcel  no-undo
    field tr    as char
    field seq   as int
    field nome  as char  format "x(40)"
    field tpdado    as char
    field tam       as int
    field decima    as int
    index idx is unique primary tr asc seq asc .
def var vseq as int.

input from /admcom/progr/edi/ordrsp.txt .
repeat transaction:
    vseq = vseq + 1.
    create ttexcel.
    import delimiter ";" ttexcel.tr ttexcel.nome ttexcel.tpdado ttexcel.tam ttexcel.decima.
    ttexcel.seq = vseq.
end.
input close.
    
for each ttexcel where ttexcel.tr = "".
    delete ttexcel.
end.
    
def var vpos    as int.
def var vtam    as int.
def var vlinha  as char.

def temp-table ttrsp no-undo
    field tr     as char format "x(03)"
    field saida  as char       format "x(150)".

function atu returns char
    (input ptam as int,
     input pdec as int).

    def var vchar as char.
    vchar = trim(substring(vlinha,vpos,ptam)).
    if pdec > 0 and pdec <> ?
    then do:
        vchar = replace(string(dec(vchar) / exp(10,pdec)),".",",").
    end.
    if vpos = 1
    then do:
        ttrsp.saida   =                       vchar.
    end.            
    else ttrsp.saida   = ttrsp.saida  + ";" + vchar.
    
    vpos = vpos + ptam.
    if ttexcel.seq = 7 and ttexcel.tr = "01"
    then do:
        ppednum = int(vchar).
    end.
    if ttexcel.seq = 12 and ttexcel.tr = "01"
    then do:
        pforcnpj = vchar.
    end.
    
    
end function.    

input from value(p-entrada).
repeat.
    release ttrsp.    
    import unformatted 
        vlinha.
    find first ttexcel where ttexcel.tr = substr(vlinha,1,2) no-error.
    if not avail ttexcel
    then next.
        
        vpos = 1. create ttrsp. ttrsp.tr = substr(vlinha,1,2).
        for each ttexcel where ttexcel.tr = ttrsp.tr:
            atu(ttexcel.tam,ttexcel.decima).            
        end.
       
end.
input close.


find forne where forne.forcgc = pforcnpj no-lock no-error.


if avail forne
then do:
    
    find pedid where 
            pedid.pedsit = yes and 
            pedid.clfcod = forne.forcod and  
            pedid.pednum = ppednum 
       no-lock no-error.
    if not avail pedid then
    find pedid where 
            pedid.pedsit = no and 
            pedid.clfcod = forne.forcod and  
            pedid.pednum = ppednum 
       no-lock no-error.
       
    p-recid = recid(pedid).

end.

output to value(p-excel)
    CONVERT  SOURCE "UTF-8"  TARGET "ISO8859-1" .
for each ttrsp
    break by ttrsp.tr.
    if first-of(ttrsp.tr)
    then do:
        for each ttexcel where ttexcel.tr = ttrsp.tr.
            put unformatted
                (if ttexcel.seq = 1
                 then ""
                 else ";")
                 +
                ttexcel.nome.
        end.
        put unformatted skip.
    end. 
    put unformatted 
        ttrsp.saida
        skip.

end.    
output close.



                       
find pedid where recid(pedid) = p-recid no-lock no-error.
if avail pedid
then do on error undo:

    find edipedid where edipedid.clfcod = pedid.clfcod and
                       edipedid.pedtdc = pedid.pedtdc and
                       edipedid.etbcod = pedid.etbcod and
                       edipedid.pednum = pedid.pednum
        exclusive no-error.                        
    if avail edipedid
    then do:
        edipedid.rsparquivo = p-arquivo.
        edipedid.rspdiretorio = p-diretorio.
        edipedid.rspdiretoriocsv = p-dircsv.
        edipedid.rsparquivocsv = p-saida.
        edipedid.rspdtarq   = today.
        edipedid.rsphrarq   = time.
    end.            
    
end.
 
