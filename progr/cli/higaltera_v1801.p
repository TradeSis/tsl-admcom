
{cabec.i}

def input parameter par-rec-tt-clien as recid.
def input parameter par-rec-tt-clicods as recid.

def var vtime as int.
def var par-rec-neuclien as recid.
 
def new shared temp-table PreAutorizacao
    field codigo_filial   as char
    field codigo_operador as char
    field numero_pdv      as char
    field codigo_cliente  as char
    field cpf             as char
    field tipo_pessoa     as char
    field nome_pessoa     as char
    field data_nascimento as char
    field mae             as char
    field codigo_mae      as char
    field categoria_profissional as char
    field tipo_cadastro as char.


def shared temp-table tt-clien no-undo
    field cpf like neuclien.cpf
    field NOVOCPF as char format "x(14)"  
    field CLICOD  like neuclien.clicod    init ?
    field DATEXP like clien.datexp format "99/99/9999"
    field reg as int    format ">>9"
    field regabe as int format ">>9"
    field regtit as int format ">>9"
    field zerar as log column-label "ZERAR"
    field duplo as log column-label "DUP"
    field caracter as log column-label "CARAC"
    field tamanho  as log column-label "TAM"
    field marca    as log column-label "*" format "*/ " init yes
    index cpf is unique primary cpf asc clicod asc
    index regabe regabe asc.

def shared temp-table tt-clicods no-undo
    field cpf like neuclien.cpf
    field clicod as int format ">>>>>>>>>>9" 
    field datexp like clien.datexp format "99/99/9999"
    field NOVOCPF as char format "x(14)"  
    field zerar as log column-label "ZERAR"
    field duplo as log column-label "DUP"
    field caracter as log column-label "CARAC"
    field tamanho  as log column-label "TAM"
    field sittit   as char format "x(03)" label "Tit"
    index cpf is unique primary cpf asc clicod asc.

find first tt-clien where recid(tt-clien) = par-rec-tt-clien.  
find clien where clien.clicod = tt-clien.clicod no-lock.

find neuclien where  
    neuclien.cpf = tt-clien.cpf no-lock no-error. 

par-rec-neuclien = recid(neuclien).
    
if not avail neuclien 
then do:  
    create PreAutorizacao. 
    preAutorizacao.codigo_filial   = string(setbcod).
    preAutorizacao.codigo_cliente  = string(clien.clicod).
    preautorizacao.cpf             = tt-clien.novocpf.
    preautorizacao.tipo_pessoa     = if clien.tippes
                                     then "J"
                                     else "F". 
    preAutorizacao.nome_pessoa     = clien.clinom.
    preautorizacao.data_nascimento = string(year(clien.dtnasc),"9999") +
                                                   ":" +                                                     string(month(clien.dtnasc),"99")  +
                                                       ":" + 
                                    string(day(clien.dtnasc),"99").
                 
    run neuro/gravaneuclien_06.p (tt-clien.NOVOCPF, 
                                  output par-rec-neuclien).
                                             
    vtime = time.
    run neuro/gravaneuclilog.p  
        (string(tt-clien.novocpf),  
         "HIG",  
         vtime,   
         0,  
         0,  
         "",  
         "Cadastrando NeuClien").
end. 
find neuclien where recid(neuclien) = par-rec-neuclien 
    no-lock no-error. 


if tt-clien.zerar
then do:
    find first tt-clicods where tt-clicods.clicod = tt-clien.clicod
        no-error.
    par-rec-tt-clicods = recid(tt-clicods).
end.
    
if tt-clien.marca = yes and tt-clien.zerar = no
then do:    
    for each tt-clicods where tt-clicods.cpf = tt-clien.cpf. 
        find clien where clien.clicod = tt-clicods.clicod no-lock. 
        if tt-clicods.clicod = tt-clien.clicod 
        then do:   
            find neuclien where neuclien.cpf = tt-clien.cpf no-lock no-error. 
            if avail neuclien  
            then do:  
                if neuclien.clicod <> tt-clien.clicod and 
                   tt-clien.zera = no 
                then do:  
                    run cli/neuclienloghigie.p  
                        (tt-clien.cpf,  
                         "NEUCLIEN",  
                         recid(neuclien),  
                         "CLICOD",  
                         string(tt-clien.clicod)).  
                end. 
            end.           
            if tt-clien.novocpf <> clien.ciccgc  
            then do:  
                run cli/neuclienloghigie.p  
                    (tt-clien.cpf,  
                     "CLIEN",  
                     recid(clien),  
                     "CICCGC",  
                     tt-clien.novocpf). 
            end. 
        end.        
        else do:   
            run cli/neuclienloghigie.p   
                (tt-clien.cpf,   
                 "CLIEN",   
                 recid(clien),  
                 "CICCGC",   
                 ""). 
        end.
    end.
end.            
else do:
    find tt-clicods where recid(tt-clicods) = par-rec-tt-clicods.  
    if tt-clicods.clicod = tt-clien.clicod 
    then do:   
        find neuclien where neuclien.cpf = tt-clien.cpf  no-lock no-error. 
        if avail neuclien  
        then do:  
            if neuclien.clicod <> tt-clien.clicod and 
                tt-clien.zera = no 
            then do:  
                run cli/neuclienloghigie.p  
                    (tt-clien.cpf,  
                     "NEUCLIEN",  
                     recid(neuclien),  
                     "CLICOD",  
                     string(tt-clien.clicod)).  
            end. 
        end.           
        if tt-clien.novocpf <> clien.ciccgc  
        then do:  
            run cli/neuclienloghigie.p  
                (tt-clien.cpf,  
                 "CLIEN",  
                 recid(clien),  
                 "CICCGC",  
                 tt-clien.novocpf). 
        end. 
    end.   
    else do:   
        run cli/neuclienloghigie.p   
            (tt-clien.cpf,   
                "CLIEN",   
                recid(clien),  
                "CICCGC",   
                ""). 
    end. 
end.    

