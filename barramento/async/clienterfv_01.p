DEFINE INPUT  PARAMETER lcJsonEntrada      AS LONGCHAR.
def    output param     vok as char no-undo.
vok = "".

def var hEntrada as handle.

def temp-table ttentrada no-undo serialize-name "clienteRFVEntrada" 
    field cpf               as char
    field codigoCliente     as char
    field rfv               as char
    field classificacao     as char
    field dataCalculo       as char.
def var vdata as char.
def var vdate as date.
def var vhora as char.                                                                    
hentrada = temp-table ttentrada:handle.

hentrada:READ-JSON("longchar",lcJsonEntrada, "EMPTY").


for each ttentrada.

    find clirfv where clirfv.clicod = int(ttentrada.codigoCliente) exclusive no-wait no-error.
    if not avail clirfv
    then do:
        if not locked clirfv
        then do:
            create clirfv.
            clirfv.clicod =  int(ttentrada.codigoCliente).
        end.
        else do:
            vok = "clirfv LOCKED para cliente=" + ttentrada.codigoCliente. 
            return.
        end.
    end.      
    clirfv.cpf           = ttentrada.cpf. 
    clirfv.rfv           = ttentrada.rfv. 
    clirfv.classificacao = ttentrada.classificacao. 
    
    vdata = entry(1,trim(ttentrada.dataCalculo)," ").
    vdata = entry(3,vdata,"-") + "/" + entry(2,vdata,"-") + "/" + entry(1,vdata,"-").
    vhora = entry(2,trim(ttentrada.dataCalculo)," ").
    
    clirfv.dataCalculo   = datetime(vdata + " " + vhora).
    clirfv.datexp        = ?.
        
end.    
