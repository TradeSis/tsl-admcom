/* Programa de exportacao para acessoria de cobranca Access */
/* Data da criacao: 12/07/2011                              */
/* Nede Junior Ultima Versão                                */
        
{admcab.i new}

def temp-table tt-estab
       field etbcod as int.

def temp-table tt-cliente           
    field registro          as int  
    field tipooper          as char
    field codigo            as int
    field nome              as char
    field cgccpf            as char
    field datanascim        as date
    field dddresidenc       as int
    field foneresidenc      as int
    field dddcelular        as int
    field fonecelular       as int
    field tipologresid      as char
    field enderecoresid     as char
    field complresid        as char
    field numeroresid       as char
    field numeroaptoresid   as char
    field referenciaend     as char
    field cepresid          as int
    field bairroresid       as char
    field cidaderesid       as char
    field ufresid           as char
    field empresa           as char
    field tipologrtrab      as char
    field enderecotrab      as char
    field compltrab         as char
    field numerotrab        as char
    field ceptrab           as int
    field bairrotrab        as char
    field cidadetrab        as char
    field uftrab            as char
    field dddtrab           as int
    field fonetrab          as int
    field cargo             as char
    field profissao         as char
    field nomepai           as char
    field nomemae           as char
    field nomeref1          as char
    field foneref1          as int
    field nomeref2          as char
    field foneref2          as int
    field codconjuge        as int
    field nomeconjuge       as char
    field cpfconjuge        as int
    field empresaconjuge    as char
    field tipologrconjuge   as char
    field enderecoconjuge   as char
    field complconjuge      as char
    field numeroconjuge     as char
    field cepconjuge        as int
    field bairroconjuge     as char
    field cidadeconjuge     as char
    field ufconjuge         as char
    field dddtrabconjuge    as int
    field fonetrabconjuge   as int
    field cargoconjuge      as char
    field profissaoconjuge  as char
    field codigoavalista    as int
    field nomeavalista      as char
    field cpfavalista       as int
    field tipologravalista  as char
    field enderresavalista  as char
    field complendavalista  as char
    field numeroresavalista as char
    field refenderavalista  as char
    field cepresavalista    as int
    field dddresavalista    as int
    field foneresavalisra   as int
    field bairroresavalista as char
    field cidaderesavalista as char
    field ufresavalista     as char
    field emprtrabavalista  as char
    field tipologrtrabavalista as char
    field endertrabavalista  as char
    field compltrabavalista  as char
    field numerotrabavalista as char
    field ceptrabavalista    as int
    field bairrotrabavalista as char
    field cidadetrabavalista as char
    field uftrabavalista     as char
    field dddtrabavalista    as int
    field fonetrabavalista   as int.
    
def temp-table tt-contrato
    field registro           as int format 9 initial 3
    field tipooper           as char
    field etbcod             like estab.etbcod
    field codigocliente      as int
    field numerotitulo       as char
    field qtdrenegociacao    as int
    field datacompra         as date
    field valorentrada       as dec
    field constaspc          as char
    field qtdparcelascontr   as int
    field valorcontrato      as dec
    field dataultpagamento   as date
    field lojacompra         as int
    field nomeagente         as char
    field especietitulo      as char
    field numultparcpaga     as char
    field saldocontrato      as int
    field vlrentcontrreneg   as int.
    
def temp-table tt-parcela    
    field registro           as int format 9 initial 4
    field tipooper           as char
    field numerotitulo       as char
    field numeroparcela      as char
    field vctoparcela        as date
    field valorparcela       as dec.

def temp-table tt-acordo
    field registro           as int format 9 initial 5
    field tipooper           as char
    field numerotitulo       as char
    field dataacordo         as int
    field descriacordo       as char
    field dataagendamento    as int.


def temp-table tt-produto
    field registro           as int format 9 initial 5
    field tipooper           as char
    field numerotitulo       as char
    field descrproduto       as char
    field qtdcomprada        as int
    field procod             as int.

def var vetbcod  like estab.etbcod.
def var varquivo as char.
def var varqexp  as char.
def var vdti     like plani.pladat.
def var vdtf     like plani.pladat.
def var vvlrtitulo as dec.

do on error undo with frame f1 width 80 side-label.    
             
    update vetbcod label "Filial " colon 25
                with frame f1 side-label width 80.

    if vetbcod = 0 
    then display "GERAL" @ estab.etbnom no-label with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        create tt-estab.
        assign tt-estab.etbcod = vetbcod.
        display estab.etbnom no-label with frame f1.
    end.

    do on error undo, retry:
          update vdti to 36 label "Data Inicial" 
                 vdtf label "Data Final" with frame f1.
          if  vdti > vdtf
          then do:
                message color red/with 
                "Data inválida" view-as alert-box.
                undo.
          end.
    end.
    
    update vvlrtitulo label "Valor Titulo acima de " colon 25 with frame f1. 
    varqexp = "cob" + string(today,"999999") + ".txt".
     
    if opsys = "unix"
    then varquivo = "/admcom/custom/nede/arquivos/" + varqexp.
    disp varquivo  to 76  label "Arquivo" format "x(50)" with frame f1.
    update varquivo with frame f1.

end.


for each tt-contrato:
    delete tt-contrato.
end.

for each tt-cliente:
    delete tt-cliente.
end.

for each tt-parcela:
    delete tt-parcela.
end.

for each tt-acordo:
    delete tt-acordo.
end.

for each tt-produto:
    delete tt-produto.
end.

def var vreftel as char.
def var vprotel as char.        
def var vfone   as char.
def buffer bclien for clien.
def buffer bcontrato for contrato.
def buffer btitulo for titulo.
def var vqtdparcelas as int.



for each estab where (if vetbcod <> 0
                          then estab.etbcod = vetbcod
                          else true) no-lock:

    disp "Estabelecimento :" estab.etbcod no-label
    with frame f4 row 11 centered.
    pause 0.

for each titulo where
                titulo.empcod = 19
                and titulo.titnat = no
                and titulo.modcod = "CRE"
                and titulo.titdtven >= vdti
                and titulo.titdtven <= vdtf
                and titulo.titvlcob >= vvlrtitulo 
                and titulo.etbcod = estab.etbcod 
                and titulo.titsit = "LIB"
                and titulo.titvlpag = 0 
                no-lock break by titulo.titnum by titulo.titpar.
    
    find contrato where int(titulo.titnum) = contrato.contnum 
    no-lock no-error.
    
    if not avail contrato
    then next.

    find clien where clien.clicod = contrato.clicod no-lock.

    run ajusta-telefone (input clien.fone, output vfone).
    run ajusta-telefone (input clien.reftel, output vreftel).
    run ajusta-telefone (input clien.protel[1], output vprotel).
    
    find first tt-cliente where tt-cliente.codigo = clien.clicod
    no-lock no-error.
    
    
    if avail tt-cliente
    then do:
    
        if titulo.titnum <> tt-contrato.numerotitulo 
        then do:

            create tt-contrato.
            assign    
            tt-contrato.registro            = 3
            tt-contrato.tipooper            = "I"
            tt-contrato.etbcod              = estab.etbcod
            tt-contrato.codigocliente       = clien.clicod 
            tt-contrato.numerotitulo        = string(contrato.contnum)                     tt-contrato.qtdrenegociacao     = 0
            tt-contrato.datacompra          = contrato.dtinicial
            tt-contrato.valorentrada        = contrato.vlentra
            tt-contrato.constaspc           = ""
            tt-contrato.qtdparcelascontr    = 0
            tt-contrato.valorcontrato       = contrato.vltotal
            tt-contrato.dataultpagamento    = ?
            tt-contrato.lojacompra          = contrato.etbcod
            tt-contrato.nomeagente          = ""
            tt-contrato.especietitulo       = "C"
            tt-contrato.numultparcpaga      = ""
            tt-contrato.saldocontrato       = 0
            tt-contrato.vlrentcontrreneg    = 0.
        end.
    end.
    
    if not avail tt-cliente 
    then do:

        create tt-cliente.
        assign
        tt-cliente.registro             = 2
        tt-cliente.tipooper             = "I"
        tt-cliente.codigo               = clien.clicod
        tt-cliente.nome                 = clien.clinom
        tt-cliente.cgccpf               = clien.ciccgc
        tt-cliente.datanascim           = clien.dtnasc
        tt-cliente.dddresidenc          = 0 /*if clien.fone = ? then 0 else
                                            int(substring(vfone,1,2))*/
        tt-cliente.foneresidenc         = if clien.fone = ? then 0 else
                                                int(substring(vfone,3,10))               tt-cliente.dddcelular           = 0   
        tt-cliente.fonecelular          = 0   
        tt-cliente.tipologresid         = ""
        tt-cliente.enderecoresid        = clien.endereco[1]
        tt-cliente.complresid           = if clien.compl[1] = ? then "" else
                                                                clien.compl[1]
        tt-cliente.numeroresid          = string(clien.numero[1])
        tt-cliente.numeroaptoresid      = ""         
        tt-cliente.referenciaend        = ""
        tt-cliente.cepresid             = 0
        tt-cliente.bairroresid          = if clien.bairro[1] = ? then "" else  ~                                                               clien.bairro[1]
        tt-cliente.cidaderesid          = clien.cidade[1]
        tt-cliente.ufresid              = clien.ufecod[1]
        tt-cliente.empresa              = if clien.proemp[1] = ? then "" else 
                                                                clien.proemp[1]
        tt-cliente.tipologrtrab         = ""
        tt-cliente.enderecotrab         = ""
        tt-cliente.compltrab            = ""
        tt-cliente.numerotrab           = ""
        tt-cliente.ceptrab              = 0
        tt-cliente.bairrotrab           = ""
        tt-cliente.cidadetrab           = ""
        tt-cliente.uftrab               = ""
        tt-cliente.dddtrab              = 0 
        tt-cliente.fonetrab             = if clien.protel[1] = ? then 0 
                                            else int(substring(vprotel,3,10))
        tt-cliente.cargo                = ""
        tt-cliente.profissao            = ""
        tt-cliente.nomepai              = if clien.pai = ? then "" 
                                                           else clien.pai
        tt-cliente.nomemae              = if clien.mae = ? then "" 
                                                           else  clien.mae
        tt-cliente.nomeref1             = if clien.refnome = ? then "" 
                                                             else clien.refnome
        tt-cliente.foneref1             = if clien.reftel = ?   then 0 
                                            else int(substring(vreftel,3,10))
        tt-cliente.nomeref2             = ""
        tt-cliente.foneref2             = 0
        tt-cliente.codconjuge           = 0
        tt-cliente.nomeconjuge          = if clien.conjuge = ? then "" else    ~                                                             clien.conjuge
        tt-cliente.cpfconjuge           = 0
        tt-cliente.empresaconjuge       = ""
        tt-cliente.tipologrconjuge      = ""
        tt-cliente.enderecoconjuge      = ""
        tt-cliente.complconjuge         = ""
        tt-cliente.numeroconjuge        = ""
        tt-cliente.cepconjuge           = 0
        tt-cliente.bairroconjuge        = ""
        tt-cliente.cidadeconjuge        = ""
        tt-cliente.ufconjuge            = ""
        tt-cliente.dddtrabconjuge       = 0
        tt-cliente.fonetrabconjuge      = 0
        tt-cliente.cargoconjuge         = ""
        tt-cliente.profissaoconjuge     = ""
        tt-cliente.codigoavalista       = 0
        tt-cliente.nomeavalista         = ""
        tt-cliente.cpfavalista          = 0
        tt-cliente.tipologravalista     = ""
        tt-cliente.enderresavalista     = ""
        tt-cliente.complendavalista     = ""
        tt-cliente.numeroresavalista    = ""
        tt-cliente.refenderavalista     = ""
        tt-cliente.cepresavalista       = 0
        tt-cliente.dddresavalista       = 0
        tt-cliente.foneresavalisra      = 0
        tt-cliente.bairroresavalista    = ""
        tt-cliente.cidaderesavalista    = ""
        tt-cliente.ufresavalista        = ""
        tt-cliente.emprtrabavalista     = ""
        tt-cliente.tipologrtrabavalista = ""
        tt-cliente.endertrabavalista    = ""
        tt-cliente.compltrabavalista    = ""
        tt-cliente.numerotrabavalista   = ""
        tt-cliente.ceptrabavalista      = 0 
        tt-cliente.bairrotrabavalista   = ""
        tt-cliente.cidadetrabavalista   = ""
        tt-cliente.uftrabavalista       = ""
        tt-cliente.dddtrabavalista      = 0
        tt-cliente.fonetrabavalista     = 0 .
    


        create tt-contrato.
        assign    
        tt-contrato.registro            = 3
        tt-contrato.tipooper            = "I"
        tt-contrato.etbcod              = estab.etbcod
        tt-contrato.codigocliente       = clien.clicod 
        tt-contrato.numerotitulo        = string(contrato.contnum)
        tt-contrato.qtdrenegociacao     = 0
        tt-contrato.datacompra          = contrato.dtinicial
        tt-contrato.valorentrada        = contrato.vlentra
        tt-contrato.constaspc           = ""
        /*tt-contrato.qtdparcelascontr    = 0*/
        tt-contrato.valorcontrato       = contrato.vltotal
        tt-contrato.dataultpagamento    = ?
        tt-contrato.lojacompra          = contrato.etbcod
        tt-contrato.nomeagente          = ""
        tt-contrato.especietitulo       = "C"
        tt-contrato.numultparcpaga      = ""
        tt-contrato.saldocontrato       = 0
        tt-contrato.vlrentcontrreneg    = 0.

    
        find contnf where contnf.etbcod = contrato.etbcod and
                      contnf.contnum = contrato.contnum no-lock no-error.
        if not avail contnf then next.
        find plani where plani.etbcod = contnf.etbcod
                     and plani.placod = contnf.placod no-lock no-error. 
        for each movim where movim.placod = plani.placod and
                         movim.etbcod = plani.etbcod and
                         movim.movtdc = plani.movtdc   no-lock.
    
            find produ of movim no-lock.
        
            find tt-produto where tt-produto.procod = movim.procod and
                              tt-produto.numerotitulo = tt-parcela.numerotitulo
                              no-lock no-error.
                                
            if not avail tt-produto 
            then do:
            create tt-produto.
            assign    
                tt-produto.registro       = 6    
                tt-produto.tipooper       = "I"   
                tt-produto.numerotitulo   = titulo.titnum   
                tt-produto.descrproduto   = produ.pronom   
                tt-produto.qtdcomprada    = movim.movqtm.
                tt-produto.procod         = movim.procod.
            end.
        end.
    end. 
end.
end.

def var vqtd-parcelas as int.
def var vdtultimopag as date.
def var vultimaparpag as int.
def var vsaldocontrato as dec.
def var vspc as char.

/* busca todos os titulos dos contratos */
for each tt-contrato.
    
    vqtd-parcelas  = 0.
    vdtultimopag   = ?.
    vultimaparpag  = 0.
    vsaldocontrato = 0.
    vspc = "N".
    
    find contrato where 
    contrato.contnum = int(tt-contrato.numerotitulo) no-lock.
    
    find clispc where clispc.clicod  = contrato.clicod and
                      clispc.contnum = contrato.contnum no-lock no-error.

    if avail clispc 
    then do:
        if clispc.dtcanc = ?
        then vspc = "S".
    end.

    for each titulo where titulo.empcod = 19
                      and titulo.titnat = no
                      and titulo.modcod = "CRE"
                      and titulo.etbcod = contrato.etbcod
                      and titulo.clifor = contrato.clicod
                      and titulo.titnum = string(contrato.contnum)
                      no-lock.
        
                      
        create tt-parcela.
        assign
            tt-parcela.registro             = 4
            tt-parcela.tipooper             = "I"
            tt-parcela.numerotitulo         = titulo.titnum
            tt-parcela.numeroparcela        = string(titulo.titpar)
            tt-parcela.vctoparcela          = titulo.titdtven
            tt-parcela.valorparcela         = titulo.titvlcob.

        vqtd-parcelas = vqtd-parcelas + 1.    
        vsaldocontrato = contrato.vltotal.
        vsaldocontrato = vsaldocontrato - titulo.titvlpag.
        if titulo.titdtpag <> ?
        then assign
                vdtultimopag = titulo.titdtpag
                vultimaparpag = titulo.titpar.
        
        if vdtultimopag = ? then vdtultimopag = contrato.dtinicial.        

    end. 
    
    assign tt-contrato.qtdparcelascontr   = vqtd-parcelas.                     
    assign tt-contrato.saldocontrato      = vsaldocontrato.
    assign tt-contrato.dataultpagamento   = vdtultimopag.
    assign tt-contrato.numultparcpaga     = string(vultimaparpag).
    assign tt-contrato.constaspc          = vspc.


end.

run pi-exporta-arquivo. 
message "Arquivo " + varqexp + " gerado com sucesso" view-as alert-box.

procedure pi-exporta-arquivo.
output to value(varquivo).

    for each tt-cliente no-lock.
    
        run pi-registro2.
        
        for each tt-contrato where
            tt-contrato.codigocliente = tt-cliente.codigo no-lock.
            
            run pi-registro3.
        
            for each tt-parcela where 
                tt-contrato.numerotitulo = tt-parcela.numerotitulo no-lock.
                
                run pi-registro4.
            end.    
            
            for each tt-produto where 
                   tt-produto.numerotitulo = tt-contrato.numerotitulo no-lock.                            
                run pi-registro6.

            end.
        end.    

    end.

output close.
end procedure.         
         
procedure pi-registro2.

    /* Registro tipo 2 */    
    put unformatted
        tt-cliente.registro             format "9"
        tt-cliente.tipooper             format "x(1)"
        tt-cliente.codigo               format "9999999999"
        tt-cliente.nome                 format "x(50)"
        dec(tt-cliente.cgccpf)          format "999999999999999"
        tt-cliente.datanascim           format "99999999"
        tt-cliente.dddresidenc          format "9999"
        tt-cliente.foneresidenc         format "99999999"
        tt-cliente.dddcelular           format "9999"
        tt-cliente.fonecelular          format "99999999"
        tt-cliente.tipologresid         format "x(2)"
        tt-cliente.enderecoresid        format "x(70)"
        tt-cliente.complresid           format "x(40)"
        tt-cliente.numeroresid          format "x(6)"
        tt-cliente.numeroaptoresid      format "x(4)"
        tt-cliente.referenciaend        format "x(100)"
        tt-cliente.cepresid             format "99999999"
        tt-cliente.bairroresid          format "x(30)"
        tt-cliente.cidaderesid          format "x(30)"
        tt-cliente.ufresid              format "x(2)"
        tt-cliente.empresa              format "x(40)"
        tt-cliente.tipologrtrab         format "x(2)"
        tt-cliente.enderecotrab         format "x(70)"
        tt-cliente.compltrab            format "x(40)"
        tt-cliente.numerotrab           format "x(6)"
        tt-cliente.ceptrab              format "99999999"
        tt-cliente.bairrotrab           format "x(30)"
        tt-cliente.cidadetrab           format "x(30)"
        tt-cliente.uftrab               format "x(2)"
        tt-cliente.dddtrab              format "9999"
        tt-cliente.fonetrab             format "99999999"
        tt-cliente.cargo                format "x(30)"
        tt-cliente.profissao            format "x(30)"
        tt-cliente.nomepai              format "x(50)"
        tt-cliente.nomemae              format "x(50)"
        tt-cliente.nomeref1             format "x(30)"
        tt-cliente.foneref1             format "99999999"
        tt-cliente.nomeref2             format "x(30)"
        tt-cliente.foneref2             format "99999999"
        tt-cliente.codconjuge           format "9999999999"
        tt-cliente.nomeconjuge          format "x(50)"
        dec(tt-cliente.cpfconjuge)      format "999999999999999"
        tt-cliente.empresaconjuge       format "x(40)"
        tt-cliente.tipologrconjuge      format "x(2)"
        tt-cliente.enderecoconjuge      format "x(70)"
        tt-cliente.complconjuge         format "x(40)"
        tt-cliente.numeroconjuge        format "x(6)"
        tt-cliente.cepconjuge           format "99999999"
        tt-cliente.bairroconjuge        format "x(30)"
        tt-cliente.cidadeconjuge        format "x(30)"
        tt-cliente.ufconjuge            format "x(2)"
        tt-cliente.dddtrabconjuge       format "9999"
        tt-cliente.fonetrabconjuge      format "99999999"
        tt-cliente.cargoconjuge         format "x(30)"
        tt-cliente.profissaoconjuge     format "x(30)"
        tt-cliente.codigoavalista       format "9999999999"
        tt-cliente.nomeavalista         format "x(50)"
        dec(tt-cliente.cpfavalista)     format "999999999999999"
        tt-cliente.tipologravalista     format "x(2)"
        tt-cliente.enderresavalista     format "x(70)"
        tt-cliente.complendavalista     format "x(40)"
        tt-cliente.numeroresavalista    format "x(6)"
        tt-cliente.refenderavalista     format "x(100)"
        tt-cliente.cepresavalista       format "99999999"
        tt-cliente.dddresavalista       format "9999"
        tt-cliente.foneresavalisra      format "99999999"
        tt-cliente.bairroresavalista    format "x(30)"
        tt-cliente.cidaderesavalista    format "x(30)"
        tt-cliente.ufresavalista        format "x(2)"
        tt-cliente.emprtrabavalista     format "x(40)"
        tt-cliente.tipologrtrabavalista format "x(2)"
        tt-cliente.endertrabavalista    format "x(70)"
        tt-cliente.compltrabavalista    format "x(40)"
        tt-cliente.numerotrabavalista   format "x(6)"
        tt-cliente.ceptrabavalista      format "9999999"
        tt-cliente.bairrotrabavalista   format "x(30)"
        tt-cliente.cidadetrabavalista   format "x(30)"
        tt-cliente.uftrabavalista       format "x(2)"
        tt-cliente.dddtrabavalista      format "9999"
        tt-cliente.fonetrabavalista     format "99999999" 
    skip.
end procedure.

procedure pi-registro3.
        
    /* Registro tipo 3 */
    put unformatted
        tt-contrato.registro            format "9"
        tt-contrato.tipooper            format "x(1)"
        "C" + string(tt-contrato.etbcod,"999") + tt-contrato.numerotitulo  
                                        format "x(25)"
        tt-contrato.qtdrenegociacao     format "99"
        tt-contrato.datacompra          format "99999999"
        tt-contrato.valorentrada * 100  format "999999999999"
        tt-contrato.constaspc           format "x(1)"
        tt-contrato.qtdparcelascontr    format "999"
        tt-contrato.valorcontrato * 100 format "999999999999"
        tt-contrato.dataultpagamento    format "99999999"
        tt-contrato.lojacompra          format "999"
        tt-contrato.nomeagente          format "x(30)"
        tt-contrato.especietitulo       format "x(1)"
        tt-contrato.numultparcpaga      format "x(3)"
        tt-contrato.saldocontrato * 100 format "999999999999"
        tt-contrato.vlrentcontrreneg * 100   format "999999999999"
    skip.
end procedure.
        
procedure pi-registro4.        
               
    /* Registro tipo 4 */
    put unformatted
        tt-parcela.registro             format "9" 
        tt-parcela.tipooper             format "x(1)"
        "C" + string(tt-contrato.etbcod,"999") + tt-contrato.numerotitulo  
                                        format "x(25)"
        tt-parcela.numeroparcela        format "x(3)"
        tt-parcela.vctoparcela          format "99999999"
        tt-parcela.valorparcela * 100   format "999999999999"
     skip.

end procedure.

procedure pi-registro5.

    /* Registro tipo 5 */    
    put unformatted
        tt-acordo.registro            format "9"
        tt-acordo.tipooper            format "x(1)"
        tt-acordo.numerotitulo        format "x(25)"
        tt-acordo.dataacordo          format "99999999"
        tt-acordo.descriacordo        format "x(400)"
        tt-acordo.dataagendamento     format "99999999"
    skip.



end procedure.

procedure pi-registro6.
    
    /* Registro tipo 6 */
    put unformatted
        tt-produto.registro             format "9"    
        tt-produto.tipooper             format "x(1)"
        "C" + string(tt-contrato.etbcod,"999") + tt-contrato.numerotitulo  
                                        format "x(25)"   
        tt-produto.descrproduto         format "x(50)"   
        tt-produto.qtdcomprada          format "9999"
    skip.    
          


end procedure.          

         
procedure ajusta-telefone.
def input parameter par-char as char.
def output parameter par-resp as char.


    def var v-i as int.
    def var v-lst as char extent 66
       init ["@",":",";",".",",","*","/","-",">","!","'",'"',"[","]",
       "q","Q","w","W","e","E","r","R","t","T","y","Y","u","U","i","I",
       "o","O","p","P","a","A","s","S","D","d","f","F","g","G","h","H",
       "j","J","L","l","Ç","ç","z","Z","x","X","c","C","v","V","b","B",
       "n","N","m","M"].
         
    if par-char = ?
    then par-char = "".
    else do v-i = 1 to 66:
         par-char = replace(par-char,v-lst[v-i],"").
    end.


end procedure.
