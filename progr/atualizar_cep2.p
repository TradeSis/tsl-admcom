/* helio 08082023 - ID 36311 - Menu do admcom, n�o tras mais todas as informa��es. */
/*
Programa:  atualizar_cep2.p
Propósito: Importar para atualização de CEP de clientes
Autor:     Lucas Leote
Data:      Dez/2016
*/

{admcab.i}

/* Definindo variáveis e temp-table */
def temp-table tt-clien no-undo
        
        field   clinom      as char
        field   clicod      as int 
        field   etbcad      as int
        field   ciccgc      as char 
        field   zona        as char 
        field   endereco1   as char 
        field   numero1     as int 
        field   compl1      as char 
        field   bairro1     as char 
        field   cidade1     as char 
        field   ufecod1     as char
        field   cep1        as char 
        field   fone        as char 
        field   fax         as char 
        field   entbairro1  as char 
        field   entcidade1  as char 
        field   entbairro2  as char 
        field   entcidade2  as char
        field   entcidade3  as char
        
    index cli is unique primary clicod asc .

def var c-csv   as char no-undo format "x(50)".

/* Atribuindo diretório e nome do arquivo recebido */
assign c-csv = "/admcom/import/clientes_cep.csv".

/* Form que recebe os dados inputados pelo usuário */

update c-csv label "Pasta e arquivo"
with 1 col frame f1 title "  Informe os dados abaixo  " centered width 80.

if search(c-csv) = ? then do:
    message "Arquivo nao localizado"
        view-as alert-box.
    undo.        
end.        

message "Atualizando dados...".

/* Lendo o arquivo e gravando na temp-table */
def var vi as int no-undo init 0.
def var vt as int no-undo init 0.

input from value(c-csv) no-convert.
        repeat transaction:
            vt = vt + 1.
            if vt = 1 then next.
                create tt-clien.
                import delimiter ";" tt-clien no-error.
            if tt-clien.clicod = 0 then delete tt-clien.
        end.
input close.
hide message no-pause.
message "validando..." vt "linhas".
pause.
for each tt-clien.
        if tt-clien.clicod = 0
        then delete tt-clien.
        else do:
            find clien where clien.clicod = tt-clien.clicod exclusive no-wait no-error.
            if not avail clien then delete tt-clien.
        end.
end.
vi = 0.
for each tt-clien.
    vi = vi + 1.
end.    
if vi / vt * 100 <= 80
then do:
    hide message no-pause.
    message "arquivo com problema" view-as alert-box.
    undo.
end.    
/* Percorrendo a temp-table */
hide message no-pause.
message "arquivo com " vt "linhas. Confirma atualizar " vi "registros?" update sresp.
if sresp = no then return.

for each tt-clien where tt-clien.clicod > 0:

        find clien where clien.clicod = tt-clien.clicod exclusive no-wait no-error.
                if not avail clien then next.
                
                    clien.zona          = tt-clien.zona. 
                    clien.endereco[1]   = tt-clien.endereco1.
                    clien.numero[1]     = tt-clien.numero1.
                    clien.compl[1]      = tt-clien.compl1. 
                    clien.bairro[1]     = tt-clien.bairro1.  
                    clien.cidade[1]     = tt-clien.cidade1.   
                    clien.ufecod[1]     = tt-clien.ufecod1.
                    clien.cep[1]        = tt-clien.cep1. 
                    clien.fone          = tt-clien.fone.
                    clien.fax           = tt-clien.fax.
                    clien.entbairro[1]  = tt-clien.entbairro1.
                    clien.entcidade[1]  = tt-clien.entcidade1.
                    clien.entbairro[2]  = tt-clien.entbairro2.
                    clien.entcidade[2]  = tt-clien.entcidade2.
                    clien.entcidade[3]  = tt-clien.entcidade3.
                
end.

message "Dados atualizados!" view-as alert-box.