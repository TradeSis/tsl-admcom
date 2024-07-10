def input parameter parq-onde as char.
def input parameter parq-oque as char.
def output parameter p-resultado as char.

def var vlinha as char format "x(300)" extent 300.

def var vretorno as longchar.
def var par-root as char.
def var par-banco as char.
def var par-item as char.

def temp-table tt-tablexml no-undo
    field root   as char
    field banco  as char
    field tabela as char
    field campo  as char
    field valor  as char
    .


FUNCTION pega returns character
    (input par-oque as char,
     input par-onde as char).
         
    def var vx as int.
    def var vret as char.  
    
    vret = ?.  
    
    do vx = 1 to num-entries(par-onde,"<"). 
        if entry(1,entry(vx,par-onde,"<"),">") = par-oque 
        then do: 
            vret = entry(2,entry(vx,par-onde,"<"),">"). 
            leave. 
        end. 
    end.
    return vret. 
END FUNCTION.
def var vi as int. 

def var hXDoc as handle.
create x-document hXDoc.
hXDoc:LOAD("FILE", parq-onde, FALSE).
hXDoc:ENCODING= "UTF-8".
hXDoc:SAVE("LONGCHAR", vretorno).

/****
def var vcha-arquivo-aux as char.

assign vcha-arquivo-aux = "/usr/dlc/bin/quoter -c 1-3000,3001-4000 " 
+ parq-onde + " > " + parq-onde + ".2".
                        
unix silent value(vcha-arquivo-aux).
                        
input from value(parq-onde + ".2").

repeat:

    import  vlinha.

    message vlinha[1]. pause.
    do vi = 1 to 100:
        if vlinha[vi] = "" then leave.
        if pega(parq-oque,vlinha[vi]) <> ?
        then  p-resultado =  pega(parq-oque,vlinha[vi]) .
        /*
        if p-resultado <> ?
        then leave.
        */
    end.
    
end.
input close. 
***/

run p-retorno.

find first tt-tablexml where
           tt-tablexml.campo = parq-oque no-error.
if avail tt-tablexml
then p-resultado = tt-tablexml.valor.            

procedure p-retorno.

    def var Hdoc  as handle.
    def var Hroot as handle.
    def var vb      as memptr.
    set-size(vb) = 200001.
        
    if index(vretorno, "<") = 0
    then return.

    vretorno = substr(vretorno, index(vretorno, "<") ).
    vretorno = replace(vretorno, "&lt;", "<").
    vretorno = replace(vretorno, "&gt;", ">").
    vretorno = replace(vretorno, "&amp;","&").
    vretorno = replace(vretorno, "det nitem=~"","det><nitem>").
    vretorno = replace(vretorno, "~"><prod>","</nitem><prod>").
    vretorno = replace(vretorno, "<infNFe versao=","<infNFe><versao>").
    vretorno = replace(vretorno, "<infNFe Id=","<infNFe><Id>").
    vretorno = replace(vretorno, " Id=","</versao><Id>").
    vretorno = replace(vretorno, "><ide","</Id><ide").

    put-string(vb, 1) = vretorno.

    create x-document HDoc.
    Hdoc:load("MEMPTR", vb, false). /* load do XML */
    create x-noderef hroot.
    hDoc:get-document-element(hroot). 

    if hroot:num-children > 1
    then run obtemroot(hroot:name, input "", input hroot).
    else run obtemcampo(hroot:name, input "", input hroot).

    set-size(vb) = 0.
    
end procedure.

procedure obtemroot.

    def input parameter p-root  as char.
    def input parameter p-tabela as char.
    def input parameter vh      as handle.
    def var p-campo as char.
    def var vitem as int.
    def var hc   as handle.
    def var loop as int.
    vitem = 0.
    create x-noderef hc.
    do loop = 1 to vh:num-children: /*faz o loop até o numero total de filhos*/
        par-root = vh:name.
        vh:get-child(hc,loop).
        /*
        if hc:name = "numitem"
        then vitem = int(hc:node-value).
        */
        par-item = "" .
        if hc:num-children > 1
        then run obtemroot(vh:name, hc:name, input hc:handle).
        else do:
            if hc:name <> "#text"
            then run obtemcampo(vh:name, hc:name, input hc:handle).
            else do:
                create tt-tablexml.
                tt-tablexml.root    = par-root.
                tt-tablexml.tabela  = "". 
                tt-tablexml.campo   = "".
                tt-tablexml.valor   = trim(hc:node-value).
                if tt-tablexml.root = "IPI"
                then tt-tablexml.root = "Imposto".
                if tt-tablexml.tabela = "Fat"
                then tt-tablexml.tabela = "Dup".
                if tt-tablexml.campo = "CSOSN"
                then assign
                        tt-tablexml.campo = "CST"
                        tt-tablexml.valor = "90"
                        .
            end.
        end. 
    end.                       
end procedure.

procedure obtembanco.

    def input parameter p-root  as char.
    def input parameter p-tabela as char.
    def input parameter vh      as handle.
    def var p-campo as char.
    def var vitem as int.
    def var hc   as handle.
    def var loop as int.
    vitem = 0.
    par-banco = p-tabela.
    create x-noderef hc.
    do loop = 1 to vh:num-children: /*faz o loop até o numero total de filhos*/
        vh:get-child(hc,loop).
        /*
        if hc:name = "numitem"
        then vitem = int(hc:node-value).
        */
        par-item = "" .
        if hc:num-children > 1
        then run obtemtable(vh:name, hc:name, input hc:handle).
        else do:
            if hc:name <> "#text"
            then run obtemcampo(vh:name, hc:name, input hc:handle).
            else do:
                create tt-tablexml.
                tt-tablexml.root    = par-root.
                tt-tablexml.banco    = par-banco.
                tt-tablexml.tabela  = "". 
                tt-tablexml.campo   = "".
                tt-tablexml.valor   = trim(hc:node-value).
                if tt-tablexml.root = "IPI"
                then tt-tablexml.root = "Imposto".
                if tt-tablexml.tabela = "Fat"
                then tt-tablexml.tabela = "Dup".
                if tt-tablexml.campo = "CSOSN"
                then assign
                        tt-tablexml.campo = "CST"
                        tt-tablexml.valor = "90"
                        .
              end.
        end. 
    end.                       
end procedure.


procedure obtemtable.

    def input parameter p-root  as char.
    def input parameter p-tabela as char.
    def input parameter vh      as handle.
    def var p-campo as char.
    def var vitem as int.
    def var hc   as handle.
    def var loop as int.
    vitem = 0.
    par-root = p-root.
    create x-noderef hc.
    do loop = 1 to vh:num-children: /*faz o loop até o numero total de filhos*/
        vh:get-child(hc,loop).

        /*
        if hc:name = "numitem"
        then vitem = int(hc:node-value).
        */
        if hc:num-children > 1
        then run obtemtable(vh:name, hc:name, input hc:handle).
        else do:
            if hc:name <> "#text"
            then run obtemcampo(vh:name, hc:name, input hc:handle).
            else do:
                p-campo = vh:name.
                if p-campo = "nitem"
                then par-item = trim(hc:node-value).
                if p-tabela = "icmstot"
                then par-item = "".
                create tt-tablexml.
                tt-tablexml.root    = par-root.
                tt-tablexml.banco   = par-banco.
                tt-tablexml.tabela  = p-tabela. 
                tt-tablexml.campo   = p-campo.
                tt-tablexml.valor   = trim(hc:node-value).
                if par-item <> "" 
                then  tt-tablexml.banco   = par-item
                        .
                if tt-tablexml.root = "IPI"
                then tt-tablexml.root = "Imposto".
                if tt-tablexml.tabela = "Fat"
                then tt-tablexml.tabela = "Dup".
                if tt-tablexml.campo = "CSOSN"
                then assign
                        tt-tablexml.campo = "CST"
                        tt-tablexml.valor = "90"
                        .
              end.
        end. 
    end.                       
end procedure.

procedure obtemcampo.

    def input parameter p-root  as char.
    def input parameter p-campo as char.
    def input parameter vh      as handle.

    def var hc   as handle.
    def var loop as int.
    
    create x-noderef hc.
    /* A partir daqui monta o retorno */
    do loop = 1 to vh:num-children: /*faz o loop até o numero total de filhos*/
        vh:get-child(hc,loop).
        /*
        message "333" hc:num-children hc:name hc:node-value . pause.
        */
        
        if hc:num-children > 1
        then run obtemtable(p-root, hc:name, input hc:handle).
        else do:
            if hc:name <> "#text"
            then run obtemcampo(p-root, hc:name, input hc:handle).
            else do:

                if p-campo = "nitem"
                then par-item = trim(hc:node-value).
                
                if p-root = "icmstot"
                then par-item = "".
                create tt-tablexml.
                tt-tablexml.root    = par-root.
                tt-tablexml.banco   = par-banco.
                tt-tablexml.tabela  = p-root.
                tt-tablexml.campo   = p-campo. 
                tt-tablexml.valor   = trim(hc:node-value).
                if par-item <> ""
                then  tt-tablexml.banco   = par-item .
                if tt-tablexml.root = "IPI"
                then tt-tablexml.root = "Imposto".
                if tt-tablexml.tabela = "Fat"
                then tt-tablexml.tabela = "Dup".
                if tt-tablexml.campo = "CSOSN"
                then assign
                        tt-tablexml.campo = "CST"
                        tt-tablexml.valor = "90"
                        .
             end.
        end. 
    end.                       

end procedure.

