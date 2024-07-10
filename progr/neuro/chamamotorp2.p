/*VERSAO 2 23062021*/


def input param pcpfcnpj like neuclien.cpfcnpj.
def input param pneuro_id_operacao as char.
def input param vcxacod as int. 
def output param pstatus as char.
def output param pmensagem as char.

def var cestcivil as char.
def var vsituacao-instrucao as char.
def var vinstrucao  as char.
def var vseguro as char.
def var vplanosaude as char.
def var vrenda  as dec.
def var vrenda_conjuge  as dec.
def var vlstdadosbanco as char.
def var vlstrefcomerc  as char.
def var vlstcartaocred as char.
def var vx as int.
def var vcartoes as char.
def var vct  as int.
def var auxcartao as char extent 7 format "x(20)"
      init ["Visa","Master","Banricompras","Hipercard",
            "Cartoes de Loja","American Express","Dinners"].
def var vveiculo       as char.
def var vlstdadosveic as char.     
def var vlstrefpessoais as char.
def var vlstspc as char.
def var vale-spc as char.
def var vche-spc as char.
def var vcre-spc as char.
def var vnac-spc as char.
def var vprops as char.
def var vPOLITICA as char.
def var vneu_cdoperacao as char.
def var vneu_politica as char.
def var vneuro-sit as char.
def var vneuro-mens as char.
def var vsit_credito as char.

def var var-saldototnov as dec.
def var vvctolimite            as date. 
def var vvlrLimite              as dec.


def new global shared var setbcod       as int.

{acha.i}            /* 03.04.2018 helio */
{neuro/achahash.i}  /* 03.04.2018 helio */
{neuro/varcomportamento.i} /* 03.04.2018 helio */
def var var-atrasoparcperc as char.
def var var-PARCPAG as int.

{/u/bsweb/progr/bsxml-iso.i}
def var vtime    as int.
def var vtimeini as int.
def var vchar as char.
def var vprocessa_credito   as log.
def var vtipo_cadastro      as char.
def var vtipoconsulta          as char init "CM".

def var vneurotech             as log init no.
def var vlojaneuro             as log init no. 

def var vpasta_log as char init "/ws/log/".
/*
find tab_ini where tab_ini.etbcod = 0
               and tab_ini.cxacod = 0
               and tab_ini.parametro = "WS P2K - Pasta LOG"
             no-lock no-error.
if avail tab_ini
then vpasta_log = tab_ini.valor.
*/


    find neuclien where neuclien.cpfcnpj = pcpfcnpj no-lock no-error.
               
    if not avail neuclien
    then do:
        pstatus     = "N".
        pmensagem   = "Cliente nao encontrato com cpf/cnpj " + if pcpfcnpj = ? then "NULL" else string(pcpfcnpj).
        return.
    end.
    find clien of neuclien no-lock no-error.
    if not avail clien
    then do:
        pstatus     = "N".
        pmensagem   = "Cliente cpf/cnpj " + (if pcpfcnpj = ? then "NULL" else string(pcpfcnpj)) + 
                        "Nao encontrato com codigo " + string(neuclien.clicod).
        return.
    end.    
            
    find cpclien where cpclien.clicod = clien.clicod no-lock no-error.

    vprocessa_credito = yes. /* FIXO */
    vneurotech = yes. /* fixo */
            
    
        
        
        find first contrato use-index iconcli
                    where contrato.clicod = clien.clicod no-lock no-error.
        if not avail contrato
        then vPOLITICA = "P2".   /* Regra, cliente nao possui cadastro */ 
        else vPOLITICA = "P3".

        if vprocessa_credito /* #6 */
        then do: 
            run log("submeteneuro Politica=" + vpolitica).

             run neuro/submeteneuro_v1802.p (input setbcod, 
                                             input vpolitica,
                                             input clien.clicod,   
                                             0,
                                             output vlojaneuro, 
                                             output vneurotech).
        end.
        else do: /* #6 */
                vlojaneuro = no.
                vneurotech = no.
                vsit_credito = "A".
        end.
        
        /* #3 */
        vneu_cdoperacao = "".       
        vneu_politica = "".


    if pneuro_id_operacao <> "" or
       pneuro_id_operacao <> "?"
    then do.
        find neuproposta where
                    neuproposta.etbcod  = setbcod
                and neuproposta.cxacod  = vcxacod /*#10 */
                and neuproposta.dtinclu = today
                and neuproposta.cpfcnpj = neuclien.cpfcnpj
                and neuproposta.neu_cdoperacao =
                                     pneuro_id_operacao
            no-lock no-error.
        if avail neuproposta
        then
            if neuproposta.tipoconsulta = "P2"
            then do:
                vneu_cdoperacao = neuproposta.neu_cdoperacao.
                vsit_credito    = neuproposta.neu_resultado.
                if vPOLITICA = "P2" /* quando for P2, vai resubmeter */
                then vneurotech = yes.
            end.    
    end.
    
        /* #3 */
        if  /* #3 - Quando Tiver P2 Pendente e nao for P2 Nao Sobe Neuro*/
            (vneu_cdoperacao <> "" and 
             vneu_politica   = "P2" and
             vPOLITICA       <> "P2") 
             or 
           (vneu_cdoperacao = "" and
           avail neuclien and
              ( (neuclien.vctolimite <> ? and neuclien.vctolimite >= today) and
                 neuclien.vlrlimite > 0) )  
        then do: 

            run log("Nao Sobe Neuro neu_cdoperacao(P2)=" + vneu_cdoperacao +
                    " neu_politica=" + vneu_politica +
                    " POLITICA=" + vPOLITICA).
            
            /* #1 LOG PARA PRIMEIRA AVALIACAO SUBMETE */
            vchar = "USANDO NEUCLIEN VCTO=" +
                    (if neuclien.vctolimite = ?
                     then "-" else string(neuclien.vctolimite)) +
                    " VLR=" + string(neuclien.vlrlimite).
            run log("gravaneuclilog " + vchar).
            run neuro/gravaneuclilog_v1802.p
                    (neuclien.cpfcnpj,
                     vtipoconsulta,
                     0,
                     setbcod,
                     vcxacod,
                     neuclien.sit_credito,
                     vchar).
            vvlrLimite   = neuclien.vlrlimite.
            vvctoLimite  = neuclien.vctolimite.
            vsit_credito = if vneu_cdoperacao <> "" /* #3 */
                           then "P" 
                           else "A".
        end.
        else do:
            /* #2
                cai neste ELSE
                QUANDO NAO POSSUIR NEUCLIEN
                QUANDO LIMITE NAO ESTIVER VALIDO
                QUANDO LIMITE FOR ZERADO e for LOJA ADMCOM
            */    
            
            /* #2 LOG PARA SUBMETE */ 
            vtimeini = mtime.
            vchar = if vneurotech
                    then "SUBMETE=" + vPOLITICA + " " + vneu_cdoperacao
                    else "NAO SUBMETE".
            run log("gravaneuclilog " + vchar).
            run neuro/gravaneuclilog_v1802.p
                    (neuclien.cpfcnpj,
                     vtipoconsulta,
                     vtimeini,
                     setbcod,
                     vcxacod,
                     neuclien.sit_credito,
                     vchar).

        end.
        

        /* #2 LOG PARA PRIMEIRA AVALIACAO SUBMETE */
        vchar = if vprocessa_credito
                then "Politica " + vpolitica +
                     " LJNeuro=" + string(vlojaneuro,"S/N") +
                     " Submete=" + string(vneurotech,"S/N")
                else "TPCadastro " + vtipo_cadastro + " SIT=" + vsit_credito.
        run log("gravaneuclilog PRIMEIRA AVALIACAO SUBMETE " + vchar).
        run neuro/gravaneuclilog_v1802.p 
                (neuclien.cpfcnpj, 
                 vtipoconsulta, 
                 0, 
                 setbcod, 
                 vcxacod, 
                 neuclien.sit_credito,
                 vchar).


            vtimeini = mtime.
            vchar = if vneurotech
                    then "SUBMETE=" + vPOLITICA + " " + vneu_cdoperacao
                    else "NAO SUBMETE".
            run log("gravaneuclilog " + vchar).
            run neuro/gravaneuclilog_v1802.p
                    (neuclien.cpfcnpj,
                     vtipoconsulta,
                     vtimeini,
                     setbcod,
                     vcxacod,
                     neuclien.sit_credito,
                     vchar).

            if vneurotech
            then do:

                cestcivil = if clien.estciv = 1 then "Solteiro" else
                            if clien.estciv = 2 then "Casado"   else
                            if clien.estciv = 3 then "Viuvo"    else
                            if clien.estciv = 4 then "Desquitado" else
                            if clien.estciv = 5 then "Divorciado" else
                            if clien.estciv = 6 then "Falecido" else "".
                                
                if avail cpclien and cpclien.var-log8 = true
                then assign vsituacao-instrucao = "Sim".
                else assign vsituacao-instrucao = "Nao".
          
                if avail cpclien and cpclien.var-char8 <> ?
                then vinstrucao = acha("INSTRUCAO",cpclien.var-char8).
                else vinstrucao = "".
           
                if avail cpclien and cpclien.var-char6 <> ?
                then vseguro = entry(1,trim(cpclien.var-char6),"=").
                else vseguro = "".
            
                if avail cpclien and cpclien.var-char7 <> ?
                then vplanosaude = entry(1,cpclien.var-char7,"=").
                else vplanosaude = "".

                vrenda         = if clien.prorenda[1] = ?
                                 then 0
                                 else clien.prorenda[1].
                vrenda_conjuge = if clien.prorenda[2] = ?
                                 then 0
                                 else clien.prorenda[2].

                vlstdadosbanco = "".
                do vx = 1 to 4.
                    /*    
                    if avail cpclien and
                    (cpclien.var-ext2[vx] = "BANRISUL" or 
                     cpclien.var-ext2[vx] = "CAIXA ECONOMICA FEDERAL" or
                     cpclien.var-ext2[vx] = "BANCO DO BRASIL" or
                     cpclien.var-ext2[vx] = "OUTROS")
                    then*/ do:   
                        vlstdadosbanco = vlstdadosbanco +
                                        (if vlstdadosbanco = "" then "" else ";") +
                                         texto(if avail cpclien then cpclien.var-ext2[vx] else "") + "|" +
                                         texto(if avail cpclien then cpclien.var-ext3[vx] else "") + "|" +
                                         texto(if avail cpclien then cpclien.var-ext4[vx] else "").
                    end.
                end.   

                vlstrefcomerc = "".
                do vx = 1 to 5:
                    vlstrefcomerc = vlstrefcomerc + 
                                    (if vlstrefcomerc = "" then "" else ";") +  
                                    Texto(clien.refcom[vx]) + "|".
                    if avail cpclien
                    then do:
                        if cpclien.var-ext1[vx] = "1" then   vlstrefcomerc = (vlstrefcomerc + "Apresentado").
                        else
                        if cpclien.var-ext1[vx] = "2" then vlstrefcomerc = (vlstrefcomerc + "Nao Apresentado").
                        else
                        if cpclien.var-ext1[vx] = "3" then vlstrefcomerc = vlstrefcomerc + "Nao possui cartao".
                        else vlstrefcomerc = (vlstrefcomerc + " ").  
                    end.                        
                    else vlstrefcomerc = vlstrefcomerc + " ".
                end.

                vlstcartaocred = "".
                    do vx = 1 to 7.
                        if avail cpclien  
                        then if int(cpclien.var-int[vx]) > 0
                             then vlstcartaocred = vlstcartaocred + auxcartao[vx].
                        if vx < 7 
                        then  vlstcartaocred = vlstcartaocred + ";".     
                    end.
            
                /* veiculo */
                vveiculo = "N".
                vlstdadosveic = "".
                find carro where carro.clicod = clien.clicod no-lock no-error.
                if avail carro
                then if carro.carsit 
                     then vveiculo = "S".
                if vveiculo = "S"
                then do:
                    vlstdadosveic = Texto(carro.marca) + ";" +
                                    Texto(carro.modelo) + ";" +
                                   (if carro.ano <> ?
                                    then string(carro.ano,"9999") else "").
                end.
                vlstrefpessoais = "".
                do vx = 1 to 3.
                    vlstrefpessoais = vlstrefpessoais +
                                      (if vlstrefpessoais = ""
                                       then "" else ";") +
                                      Texto(clien.entbairro[vx]) + "|" + 
                                      Texto(clien.entcep[vx])    + "|" + 
                                      Texto(clien.entcidade[vx]) + "|" +
                                      Texto(clien.entcompl[vx]). 
                end.
                vlstspc = "".
                vlstspc = if clien.entrefcom[1] <> ?
                          then enviaData(date(clien.entrefcom[1]))
                          else "".
                if vlstspc = ? then vlstspc = "".
                if vlstspc <> ""
                then do:
                    vale-spc = acha("alertas",clien.entrefcom[2]).
                    if vale-spc = ? then vale-spc = "".
                    vcre-spc = acha("credito",clien.entrefcom[2]).
                    if vcre-spc = ? then vcre-spc = "".
                    vche-spc = acha("cheques",clien.entrefcom[2]).
                    if vche-spc = ? then vche-spc = "".
                    vnac-spc = acha("nacional",clien.entrefcom[2]).
                    if vnac-spc = ? then vnac-spc = "".

                    vlstspc = vlstspc + "|" + vale-spc.
                    vlstspc = vlstspc + "|" + vcre-spc.
                    vlstspc = vlstspc + "|" + vche-spc.
                    vlstspc = vlstspc + "|" + vnac-spc.
                end.

                if vpolitica = "P2"
                then do:
                    vprops = 
                        /* helio 032021 politica de credito unificada */
                            /*"POLITICA="        + "CREDITO" + string(setbcod,"9999")*/
                        "POLITICA="        + "CREDITO_UNIFICADA"
                       + "&PROP_LOJAVENDA="       + string(setbcod,"9999") 
                       /*helio 032021 politica de credito unificada */
                       
                       + (if vneu_cdoperacao = ""
                          then ""
                          else "&PROP_IDOPERACAO=" + trim(vneu_cdoperacao))
                       +
                        "&PROP_CONTACLI="       + trim(string(clien.clicod)) + 
                        "&PROP_NOMECLI="        + trim(clien.clinom) +  
                        "&PROP_TIPOCREDITO="    + "NORMAL"    
                       + "&PROP_TIPOPESSOA=" + (if clien.tippes <> ?
                                                then string(clien.tippes,"F/J")
                                                else "")
                       + "&PROP_CPFCLI="         + texto(clien.ciccgc)   
                       + "&PROP_RGCLI="          + texto(clien.ciins)  
                       + "&PROP_DTNASCCLI="      +
                                    texto(string(clien.dtnasc,"99/99/9999"))
                       + "&PROP_CATEGCLI="       + trim(neuclien.catprof) 
                       + "&PROP_SEXOCLI="        + string(clien.sexo,"M/F")
                       + "&PROP_PLANOSAUDE="     + texto(vplanosaude)
                       + "&PROP_SEGURO="         + texto(vseguro)
                       + "&PROP_INSTRUCAOCLI="   + texto(vinstrucao)   
                       + "&PROP_INSTCOMP="       + texto(vsituacao-instrucao)
                       + "&PROP_NATURALCLI=" + 
                                            (if avail cpclien
                                               then Texto(cpclien.var-char10)
                                               else "")
                       + "&PROP_NOMEPAICLI="    + texto(clien.pai)
                       + "&PROP_ESTADOCIVIL="    + texto(cestcivil)   
                       + "&PROP_NOMEMAE="        + texto(clien.mae) 
                       + "&PROP_CONTAMAE=" + texto(string(neuclien.codigo_mae))
                       + "&PROP_DEPENDENTES="    + texto(string(clien.numdep))
                       + "&PROP_EMAILCLI=" + lc(texto(clien.zona))
                       + "&PROP_LOGRADCLI=" + Texto(clien.endereco[1])
                       + "&PROP_NUMERO="    + texto(string(clien.numero[1]))
                       + "&PROP_CEP="            +      Texto(clien.cep[1])  
                       + "&PROP_BAIRROCLI="      +      Texto(clien.bairro[1])
                       + "&PROP_COMPLEMENTO="    +      Texto(clien.compl[1])  
                       + "&PROP_CIDADE="         +      Texto(clien.cidade[1])
                       + "&PROP_UF="             +      Texto(clien.ufecod[1])

                       + "&PROP_TIPORESID="      + string(clien.tipres,
                                                            "Propria/Alugada")
                       + "&PROP_TEMPORESID="     +  texto( 
                               substr(string(int(temres),"999999"),1,2) + "/" +
                               substr(string(int(temres),"999999"),3,4) )
                       + "&PROP_CELULAR="        + Texto(clien.fax)  
                       + "&PROP_TELEFONE="       + Texto(clien.fone) 
                       + "&PROP_DTCADASTRO=" + 
                                texto(string(clien.dtcad,"99/99/9999"))
                       + "&PROP_EMPRESA="        + Texto(clien.proemp[1])  
                       + "&PROP_CNPJCOMERC="     +      
                                (if avail cpclien
                                 then Texto(cpclien.var-char1) else "")
                       + "&PROP_FONECOMERC="     + texto(clien.protel[1])
                      + "&PROP_DTADMISSAO="     +      texto(string(clien.prodta[1],"99/99/9999"))
                       + "&PROP_PROFISSAO="      + Texto(clien.proprof[1])
                        
                       + "&PROP_ENDCOMERC="      + texto(clien.endereco[2])
                       + "&PROP_NUMCOMERC="   + texto(string(clien.numero[2]))
                       + "&PROP_CIDADECOMERC=" + texto(clien.cidade[2])    
                       + "&PROP_UFCOMERC="    + texto(clien.ufecod[2])
                       + "&PROP_CEPCOMERC=" + texto(clien.cep[2])     
                       + "&PROP_RENDAMES="       +      string(vrenda)
                       + "&PROP_SOMARENDAS="     +      string(vrenda + vrenda_conjuge)
                        
                       + "&PROP_NOMECONJUGE=" +                                     texto(substr(clien.conjuge,1,50))   
                       + "&PROP_CPFCONJUGE="   +  texto(substr(clien.conjuge,51,20))
                       + "&PROP_DTNASCCONJUGE="  + 
                            (if clien.nascon = ?
                            then ""
                            else string(clien.nascon,"99/99/9999"))
                       + "&PROP_EMPRCONJUGE="    +    
                                texto(clien.proemp[2])
                       + "&PROP_DTADMCONJUGE=" +
                            (if clien.prodta[2] = ?
                            then ""
                            else string(clien.prodta[2],"99/99/9999"))
                               
                       + "&PROP_RENDACONJUGE="   +       string(vrenda_conjuge)  
                        
                       + "&PROP_PROFCONJUGE=" + texto(clien.proprof[2])    
                       + "&PROP_LSTDADOSBANCO="  +  vlstdadosbanco  
                       + "&PROP_LSTREFCOMERC="   +  vlstrefcomerc  
                       + "&PROP_LSTCARTAOCRED="  +  vlstcartaocred  
                       + "&PROP_VEICULO="        +  vveiculo
                       + "&PROP_LSTDADOSVEIC="   +  vlstdadosveic  
                       + "&PROP_LSTREFPESSOAIS=" +  vlstrefpessoais 
                       + "&PROP_LSTSPC="         +  vlstspc
                       + "&PROP_NOTA="           + (if  not avail cpclien then ""
                                                  else texto( string(cpclien.var-int3) )   )
                       + "&PROP_LOJACAD="        + trim(string(if neuclien.etbcod = 0 or neuclien.etbcod = ? then setbcod else neuclien.etbcod)) 
                       
                       + "&PROP_FLXPOLITICA="    + vPOLITICA.
                
                end.
                else do:
                    find current neuclien no-lock.         
                    run log("comportamento").
                    run neuro/comportamento.p (neuclien.clicod, ?,  
                                       output var-propriedades). 
                    var-atrasoparcperc = pega_prop("ATRASOPARCPERC").
                    if var-atrasoparcperc = ? then var-atrasoparcperc = "". 
                    var-parcpag = int(pega_prop("PARCPAG")). 
                    if var-parcpag = ? then var-parcpag = 0.

                    var-atrasoatual = int(pega_prop("ATRASOATUAL")). /* #9 */
                    var-saldototnov = dec(pega_prop("SALDOTOTNOV")). /* #9 */
                                    
                    vprops = 
                        /* helio 032021 politica de credito unificada */
                            /*"POLITICA="        + "CREDITO" + string(setbcod,"9999")*/
                        "POLITICA="        + "CREDITO_UNIFICADA"
                       + "&PROP_LOJAVENDA="       + string(setbcod,"9999") 
                        
                       + "&PROP_CONTACLI="     + trim(string(clien.clicod))
                       + "&PROP_NOMECLI="      + trim(clien.clinom)   
                       + "&PROP_CPFCLI="       + trim(clien.ciccgc)   
                       + "&PROP_DTNASCCLI="    + texto(string(clien.dtnasc,
                                                            "99/99/9999")) 
                       + "&PROP_LOGRADCLI="    + Texto(clien.endereco[1])
                       + "&PROP_NUMERO="       + Texto(string(clien.numero[1]))
                       + "&PROP_CEP="          + Texto(clien.cep[1])  
                       + "&PROP_BAIRROCLI="    + Texto(clien.bairro[1])
                       + "&PROP_COMPLEMENTO="  + Texto(clien.compl[1])  
                       + "&PROP_CIDADE="       + Texto(clien.cidade[1])
                       + "&PROP_UF="           + Texto(clien.ufecod[1])
                       + "&PROP_CELULAR="      + Texto(clien.fax)  
                       + "&PROP_TELEFONE="     + Texto(clien.fone) 
                       + "&PROP_DTCADASTRO=" + 
                                texto(string(clien.dtcad,"99/99/9999"))
                       + "&PROP_EMPRESA="        + Texto(clien.proemp[1])  
                       + "&PROP_DTADMISSAO="   + texto(string(clien.prodta[1],
                                                            "99/99/9999"))
                       + "&PROP_PROFISSAO="    + Texto(clien.proprof[1])
                       + "&PROP_RENDAMES="     + string(vrenda)
                       + "&PROP_SOMARENDAS="  + string(vrenda + vrenda_conjuge)
                       + "&PROP_LOJACAD="  + trim(string(if neuclien.etbcod = 0 or neuclien.etbcod = ? then setbcod else neuclien.etbcod)) 
                        + "&PROP_PARCPAG=" + string(var-parcpag)
                        + "&PROP_ATRASOPARCPERC=" + texto(var-atrasoparcperc)
                       + "&PROP_ATRASOATUAL="  + string(var-atrasoatual) /*#9*/
                       + "&PROP_SALDOTOTNOV="  + string(var-saldototnov) /*#9*/
                   /* #10 */
                   + "&PROP_PLANOSAUDE="   + texto(vplanosaude)
                   + "&PROP_SEGURO="       + texto(vseguro)
                   + "&PROP_INSTRUCAOCLI=" + texto(vinstrucao)
                   + "&PROP_ESTADOCIVIL="  + texto(cestcivil)
                   + "&PROP_DEPENDENTES="  + texto(string(clien.numdep))
                   + "&PROP_TIPORESID="    + string(clien.tipres,
                                                            "Propria/Alugada")
                   + "&PROP_TEMPORESID="   + Texto(
                               substr(string(int(temres),"999999"),1,2) + "/" +
                               substr(string(int(temres),"999999"),3,4))
                   + "&PROP_CPFCONJUGE="   + texto(substr(clien.conjuge,51,20))
                   + "&PROP_RENDACONJUGE=" + string(vrenda_conjuge)
                   + "&PROP_PROFCONJUGE="  + texto(clien.proprof[2])
                   + "&PROP_LSTDADOSBANCO=" + vlstdadosbanco
                   + "&PROP_LSTREFCOMERC=" + vlstrefcomerc
                   + "&PROP_LSTCARTAOCRED=" + vlstcartaocred
                   + "&PROP_VEICULO="      + vveiculo
                   + "&PROP_LSTDADOSVEIC=" + vlstdadosveic
                   + "&PROP_LSTREFPESSOAIS=" + vlstrefpessoais
                   + "&PROP_NOTA="         + (if not avail cpclien then ""
                                          else texto(string(cpclien.var-int3)))
                   + "&PROP_LIMITEATUAL="  + trim(string(neuclien.vlrlimite))  
                   + "&PROP_VALIDADELIM=" + (if neuclien.vctolimite = ? then "" 
                                 else string(neuclien.vctolimite,"99/99/9999"))
                    /* #10 */

                       + "&PROP_FLXPOLITICA="    + vPOLITICA.

                end.   
        
                vtimeini = mtime.
                run neuro/wcneurotech_v2101.p (setbcod,
                                               vcxacod,
                                               input vprops,
                                               input vPOLITICA,
                                               input vtimeini,
                                               input recid(neuclien), 
                                        input-output vneu_cdoperacao, /* #10 */
                                               input 0, /* #10 */
                                               output vvlrLimite, 
                                               output vvctolimite,
                                               output vneuro-sit, 
                                               output vneuro-mens,
                                               output pstatus,
                                               output pmensagem).

                if pstatus = "S" /* Sem Erros */
                then do: 
                    if vneuro-sit = "P"  
                    then vneuro-mens = if vneuro-mens = "" 
                                    then "Encaminhar Cliente a FILA DE CREDITO"
                                    else vneuro-mens.
                    else vneuro-mens = if vneuro-mens = ""
                                       then ""
                                       else vneuro-mens.
                    vsit_credito = vneuro-sit.
                end.
                else do:
                    vneurotech = no. /* Usa Processo ADMCOM */
                    pstatus = "S".
                    pmensagem = "".
                end.                
                /* #1 */
                vchar = if not vneurotech
                        then "ERRO MOTOR - USARA ADMCOM"
                        else "SIT=" + vsit_credito +
                             " VCTO=" + (if vvctolimite = ?
                                         then "-"
                                         else string(vvctolimite)) + 
                             " LIM=" + (if vvlrlimite = ?
                                        then "-"
                                        else string(vvlrlimite)).
                run log("gravaneuclilog " + vchar).
                run neuro/gravaneuclilog_v1802.p 
                        (neuclien.cpfcnpj, 
                         vtipoconsulta, 
                         0, 
                         setbcod, 
                         vcxaCOD, 
                         vsit_credito, 
                         vchar).
            end.
                        
            if vneurotech = no and
               vprocessa_credito = yes
            then do: /** ADMCOM **/
                run log("callimiteadmcom").
                vtime = mtime.
                vtimeini = mtime.
                run neuro/callimiteadmcom.p (recid(neuclien),
                                    "ADMA", /* #8a */
                                    vtime,
                                    setbcod,
                                    vcxacod,
                                    output vvlrLimite,
                                    output vvctoLimite,
                                    output vsit_credito).
                /* #2 */
                vchar = if vneurotech
                        then "USARA ADMCOM"
                        else "SIT=" + vsit_credito +
                             " VCTO=" + (if vvctolimite = ?
                                         then "-"
                                         else string(vvctolimite)) + 
                             " LIM=" + (if vvlrlimite = ?
                                        then "-"
                                        else string(vvlrlimite)).
                run log("gravaneuclilog " + vchar).
                run neuro/gravaneuclilog_v1802.p 
                        (neuclien.cpfcnpj,
                         vtipoconsulta,
                         0 /*vtimeini*/,
                         setbcod,
                         vcxacod,
                         neuclien.sit_credito,
                         vchar).

                if vsit_credito = "E"
                then do:
                    pstatus = "N".
                    pmensagem = "Erro ao calcular Limite Admcom". 
                end.
                vsit_credito = "A".
            end.





procedure log.

    def input parameter par-texto as char.

    def var varquivo as char.

    varquivo = vpasta_log + "Neurotech_" + string(today, "99999999") + "_" +
           string(setbcod) + "_" + string(vcxacod) + ".log".

    output to value(varquivo) append.
    put unformatted string(time,"HH:MM:SS")
        " AtualizacaoDadosCliente " par-texto skip.
    output close.
    
end procedure.

