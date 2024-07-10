/* Deleta o plani e cria um novo */
{admcab.i}

{gerxmlnfe.i}

def var vetbcod        as integer.
def var vnumero        as integer.
def var vserie         as char init "1".
def var vmetodo        as char.
def var varquivo       as char.
def var vretorno       as char.
def var vemite-cnpj    as char.
def var v-comando      as char.
def var p-valor        as char.

def var varquivo-ok    as char.

def new shared var varq-lista     as char.

def var vlinha         as char.

def var vok            as log.

def var vconta-tentativas as int.

def new shared temp-table tt-plani like plani
         field natoper    as char.
def new shared temp-table tt-movim like movim.

def new shared temp-table tt-a01_infnfe like a01_infnfe.

def temp-table tt-recupera
    field etbcod as integer
    field numero as integer
    index idx01 etbcod numero.
/*
message "           Menu temporariamente Desativado!!          " skip
   "Estamos buscando uma solução que evite a necessidade de recuperação de NFE."
                           view-as alert-box.

sresp = yes.

if sresp
then return. 
*/

form vetbcod    at 03   label "Filial"         skip
     vnumero    at 05   label "Nota"         skip
     vserie     at 04   label "Serie"         skip
        with frame f01 side-label.

assign varq-lista = "/admcom/audit/".

update varq-lista format "x(50)" label "Arquivo"   
        with frame f05 side-labels title "Informe o caminho do arquivo com a lista de notas".

if search(varq-lista) = ? or varq-lista = "/admcom/audit/"
then do:
        update vetbcod format ">>9"
            with frame f01.

        find first estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            message "Estabelecimento Invalido!" view-as alert-box.
            undo,retry.
        end.                
                
        update vnumero format ">>>>>>9"
            with frame f01.
                
        run p-recupera-nota (output vok).         
end.        
else do:

    input from value(varq-lista).

    repeat:

        import vlinha.

        if num-entries(vlinha,";") >= 2
        then do:
        
            find first tt-recupera
                 where tt-recupera.etbcod = int(entry(1,vlinha,";"))
                   and tt-recupera.numero = int(entry(2,vlinha,";"))
                                    no-lock no-error.
                                    
            if not avail tt-recupera
            then do:                         
                create tt-recupera.
                assign tt-recupera.etbcod = int(entry(1,vlinha,";"))
                       tt-recupera.numero = int(entry(2,vlinha,";")).
            end.    

        end.

    end.

end.

for each tt-recupera where tt-recupera.etbcod > 0.

    find first estab where estab.etbcod = tt-recupera.etbcod
                                no-lock no-error.
            
    assign vetbcod = tt-recupera.etbcod
           vnumero = tt-recupera.numero
           vserie = "1"
           vconta-tentativas = 1.
           
    bl_recupera_nota:       
    repeat:
        
        assign vok = no.
        run p-recupera-nota (output vok).
        if not vok and vconta-tentativas <= 3
        then do:
            
            message "Arquivo Zerado, aguardando 8 segundos".
            
            pause 8.
            
            next bl_recupera_nota.
            
        end.    
        else leave bl_recupera_nota.
        
        assign vconta-tentativas = vconta-tentativas + 1.
        
    end.
    
    pause 0 no-message.                    
                        
end.

pause.

procedure p-recupera-nota:        

def output parameter par-ok as log.

empty temp-table tt-plani.
empty temp-table tt-movim.

assign vemite-cnpj = estab.etbcgc.
        
assign vemite-cnpj = replace(vemite-cnpj,".","").
       vemite-cnpj = replace(vemite-cnpj,"/","").
       vemite-cnpj = replace(vemite-cnpj,"-","").

/*
assign vmetodo = "ConsultarXmlEnvioNfe".

assign vmetodo = "ConsultarNfe".
*/

assign vmetodo = "ConsultarXmlDistribuicaoNfe".

assign varquivo = "/admcom/nfe/ws/000/envio/"
                                 + string(vetbcod)
                                 + "_" + vmetodo + "_"
                                 + string(vnumero) + "_"
                                 + string(time).

            output to value(varquivo).
        
            geraXmlNfe(yes,
                       "cnpj_emitente",
                       vemite-cnpj,
                       no). 
                       
            geraXmlNfe(no,
                       "numero_nota",
                       string(vnumero),
                       no).
                       
            geraXmlNfe(no,
                       "serie_nota",
                       string(vserie),
                       yes).
                       
            output close.
    
            /* Apos esperar, realiza uma consulta ao NotaMax */ 
            run chama-ws3.p(input vetbcod,
                           input vnumero,
                           input "NotaMax",
                           input vmetodo,
                           input varquivo,
                           output vretorno).

assign v-comando = "/admcom/progr/perl-linux.sh " + vretorno.
                                                              
unix silent value(v-comando).

assign p-valor = "".

assign par-ok = no.
run p-verifica-tamanho-arquivo (input vretorno, output par-ok).

if not par-ok
then do: 
    return.
end.

run /admcom/progr/le_xml_nfe_tt.p(input vretorno).

hide frame f01.
                                                           
for each tt-plani.
   
   /****                                                        
   display tt-plani.serie
           tt-plani.numero
           tt-plani.placod  format ">>>>>>>>9"
           tt-plani.pladat
      /*   tt-plani.dtinclu 
           tt-plani.datexp  */
           tt-plani.etbcod
           tt-plani.emite
           tt-plani.desti   format ">>>>>>>>>>>9"
           tt-plani.opccod   format ">>>>9"
           tt-plani.bicms
           tt-plani.icms
           tt-plani.bsubst
           tt-plani.ICMSSubst
           tt-plani.protot
           tt-plani.frete
           tt-plani.descprod
           tt-plani.platot
           tt-plani.natoper format "x(62)"  label "Nat.Oper."
   /*      tt-plani.ufdes format "x(50)" */
            with frame f02 with 2 col width 80.
       
    for each tt-movim.
    
        find first produ of tt-movim no-lock no-error.
                                                               
        display tt-movim.etbcod  column-label "Fil" format ">>9"
                tt-movim.procod
                produ.pronom format "x(28)"
                tt-movim.movqtm label "Qtde" format ">>>>9"
                tt-movim.movpc
             /* tt-movim.placod format ">>>>>>>>9" */
             /* tt-movim.movtdc */
             /* tt-movim.movdat
                tt-movim.datexp 
                tt-movim.desti  */
                (tt-movim.movqtm * tt-movim.movpc) (total) label "Total"
                                format ">>>,>>9.99"
                    with frame f03 down width 80.
                                                               
    end.
    ****/
    
    
    if tt-plani.opccod = 1202
    then assign tt-plani.movtdc = 12.
    
    if tt-plani.opccod = 1152
        or tt-plani.opccod = 5152
    then assign tt-plani.movtdc = 6.

    if tt-plani.opccod = 5202
        or tt-plani.opccod = 6202
        or tt-plani.opccod = 5411
        or tt-plani.opccod = 6411
    then assign tt-plani.movtdc = 13.    

    if tt-plani.opccod = 5915
    then assign tt-plani.movtdc = 16.

    if tt-plani.opccod = 5929
    then assign tt-plani.movtdc = 48.
    
    if tt-plani.opccod = 5552
    then assign tt-plani.movtdc = 9.
    
    if tt-plani.opccod = 5602 or tt-plani.opccod = 1602
    then assign tt-plani.movtdc = 24.
    
    /*
    if tt-plani.movtdc = 0
    then
    update tt-plani.movtdc format ">>>>9" label "TipMov"
                with frame f04 overlay centered
                        title "Selecione o Tipo de Movimento" side-labels.
    
    if tt-plani.desti = 0
    then 
    update tt-plani.desti format ">>>>9" label "Destino"
                with frame f04 overlay centered
                        title "Selecione o Destino da Nota" side-labels.
                        
    */
                        
    if tt-plani.etbcod = 0
    then assign tt-plani.etbcod = vetbcod.    
    
    if tt-plani.numero = 0
    then assign tt-plani.numero = vnumero.
                                                           
    if tt-plani.serie = ""
    then assign tt-plani.serie = vserie.
                     
    assign tt-plani.notsit = no. /* No = Fechada */
                                 
end.

run p-grava-nfe-recuperada.p (output vok).

end.                    

procedure p-verifica-tamanho-arquivo:

    def input  parameter  p-arquivo as char.
    def output parameter  p-ok      as log.
    
    def var  vlinha    as  char.
    
    input from value(p-arquivo).
    
    repeat:
    
        import vlinha.
                                                           
        if vlinha = ""
        then assign p-ok = no.
        else assign p-ok = yes.
    
    end.
    
end procedure.



