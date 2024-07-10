def input param poperacao as char.
def input param parquivo as char.
def input param parquivorecid as recid.
def output param pxmlcodocorrencia as char.
def output param pxmlocorrencia as char.

def var vsituacao as char.
def var vdtbaixa as date.
def var vnossonumero like titprotesto.nossonumero.
def var vcodocorrencia as char.
def var vqtd as int.
def var lokJSON as log.
def var vlcEntrada as longchar.
def var vlcSaida   as longchar.


def var hEntrada as handle.
def var hSaida   as handle.

def temp-table ttjson serialize-name "jsonSoapResponse"
    field acao  as char serialize-name "operacao"
    field nome_arquivo as char
    field operacaoSol as char
    field codocorrencia as char
    field ocorrencia as char.

def temp-table tthd serialize-name "hd"
         field h01   as char
         field h02   as char
         field h03   as char
         field h04   as char
         field h05   as char
         field h06   as char
         field h07   as char
         field h08   as char
         field h09   as char
         field h10   as char
         field h11   as char
         field h12   as char
         field h13   as char
         field h14   as char
         field h15   as char
         field h16   as char
         field h17   as char.
def temp-table tttr serialize-name "tr"
         field t01  as char
         field t02  as char
         field t03  as char
         field t04  as char
         field t05  as char
         field t06  as char
         field t07  as char
         field t08  as char
         field t09  as char
         field t10  as char
         field t11  as char
         field t12  as char
         field t13  as char
         field t14  as char
         field t15  as char
         field t16  as char
         field t17  as char
         field t18  as char
         field t19  as char
         field t20  as char
         field t21  as char
         field t22  as char
         field t23  as char
         field t24  as char
         field t25  as char
         field t26  as char
         field t27  as char
         field t28  as char
         field t29  as char
         field t30  as char
         field t31  as char
         field t32  as char
         field t33  as char
         field t34  as char
         field t35  as char
         field t36  as char
         field t37  as char
         field t38  as char
         field t39  as char
         field t40  as char
         field t41  as char
         field t42  as char
         field t43  as char
         field t44  as char
         field t45  as char
         field t46  as char
         field t47  as char
         field t48  as char
         field t49  as char
         field t50  as char
         field t51  as char
         field t52  as char.
def temp-table tttl serialize-name "tl"
         field t01   as char
         field t02   as char
         field t03   as char
         field t04   as char
         field t05   as char
         field t06   as char
         field t07   as char
         field t08   as char.
         
def dataset dadosEntrada for ttjson, tthd, tttr, tttl.

hSaida = dataset dadosEntrada:handle.



def temp-table ttentrada serialize-name "dadosEntrada"
    field nome_arquivo as char.

hEntrada = temp-table ttentrada:handle.

create ttentrada.
ttentrada.nome_arquivo = parquivo.

hEntrada:WRITE-JSON("longchar",vLCEntrada, true, ?) no-error.

run api/wc-iepro.p ("retorno",
                    input vlcentrada,
                    output vlcSaida).




lokJSON = hsaida:READ-JSON("longchar",vlcsaida, "EMPTY") no-error.
pxmlocorrencia = "SEM RETORNO".
pxmlcodocorrencia = ?.
find first ttjson no-error.
if avail ttjson
then do:                                                                     
    pxmlocorrencia = ttjson.ocorrencia.
    pxmlcodocorrencia = ttjson.codocorrencia no-error.
    message pxmlocorrencia pxmlcodocorrencia ttjson.acao ttjson.operacaosol.
            
    if ttjson.acao = ttjson.operacaosol and
       pxmlcodocorrencia = "0"
    then do:

        for each tttr.
            disp tttr.t13
             tttr.t11 format "x(20)" column-label "nossonumero"
             tttr.t33 column-label "cod ocorrencia"
                tttr.t38 column-label "cod irreculard" tttr.t47 column-label "compl irreg"
                tttr.t32 tttr.t34 tttr.t35 tttr.t40                tttr.t42 tttr.t50
                with width 400.
            
            vnossonumero = tttr.t11.

            find titprotesto where titprotesto.operacao = poperacao and
                                   titprotesto.nossonumero = vnossonumero
                exclusive-lock no-wait no-error.
            if avail titprotesto
            then do: 
                
                disp titprotesto.ativo titprotesto.situacao titprotesto.acao titprotesto.protocolo
                    titprotesto.acaooper    
                titprotesto.dtacao.            
                
                    if tttr.t33 = "" or tttr.t33 = "0"
                    then vcodocorrencia = " ".
                    else vcodocorrencia = tttr.t33.    
                
                message titprotesto.nossonumero "titprotesto.ativo" titprotesto.ativo "titprotesto.protocolo" titprotesto.protocolo.
                
                if titprotesto.ativo = "ATIVO" 
                   /*titprotesto.dtacao <> today and
                   titprotesto.protocolo <> ?       */
                then do:
                 
                        
                    
                    find titprotsit where 
                            titprotsit.operacao      = titprotesto.operacao and
                            titprotsit.codocorrencia = vcodocorrencia no-lock no-error.
                    if avail titprotsit
                    then do: 
                        vsituacao =  titprotsit.situacao.  
                    end. 
                    else do: 
                        vsituacao    = if titprotesto.situacao = "CONFIRMADO" 
                                       then "RETIRADO"
                                       else "DEVOLVIDO".
                    end.
                    message titprotesto.nossonumero "titprotesto.codocorrencia" titprotesto.codocorrencia "tttr.t33" tttr.t33 "titprotesto.situacao" titprotesto.situacao 
                                "vsituacao" vsituacao.
                    if titprotesto.codocorrencia = vcodocorrencia and
                       titprotesto.situacao = vsituacao
                    then next.
                       
                    do: 
                        
                        do:
                            titprotesto.codocorrencia = vcodocorrencia.
                            titprotesto.codirreg      = tttr.t38.
                                              
                                                       
                            if avail titprotsit
                            then do:
                                titprotesto.situacao = titprotsit.situacao. 
                                titprotesto.ativo    = titprotsit.ativo. 
                            end.
                            else do:
                                titprotesto.ativo       = "BAIXADO".
                                titprotesto.situacao    = if titprotesto.situacao = "CONFIRMADO"
                                                          then "RETIRADO"
                                                          else vsituacao.
                            end.
                            titprotesto.acao    = "". 
                                                
                            titprotesto.vlcustas        =  dec(tttr.t35) + dec(tttr.t40) + dec(tttr.t42) + dec(tttr.t50).

                            vqtd = 0.                    
                            for each titprotparc of titprotesto no-lock.
                                vqtd = vqtd + 1.
                            end.
                            for each titprotparc of titprotesto.
                                titprotparc.titvlrcustas = titprotesto.vlcustas / vqtd.
                            end.
                            
                            message "titprotesto.nossonumero" titprotesto.nossonumero "atualiza" "titprotesto.codocorrencia" titprotesto.codocorrencia.
                            
                        
                            if titprotesto.codocorrencia = "1" /* PAGO EM CARTORIO */
                            then do:
                                vdtbaixa = date(int(substring(tttr.t37,3,2)), 
                                                int(substring(tttr.t37,1,2)),
                                                int(substring(tttr.t37,5,4)) ) no-error.
                                if vdtbaixa = ?
                                then vdtbaixa = today.
                                                                                
                                titprotesto.pagaCustas = no. /* custas fica com cliente se pago em cartorio - helio 31052022 */ 
                                titprotesto.dtbaixa = vdtbaixa.
                                
                                run iep/pgerapgtoparc.p (recid(titprotesto)).  
                                
                            end.    

                            run iep/bproatualiza.p (recid(titprotesto), today, "retorno", ?).
  
                            disp "atualizado".
                        end.
                    end.     
                end.
                 
            end.
        end.    
    end.
    else do on error undo.
        find titprotretorno where recid(titprotretorno) = parquivorecid no-error.
        if avail titprotretorno
        then do:
            titprotretorno.codocorrencia = pxmlcodocorrencia.
            titprotretorno.ocorrencia    = pxmlocorrencia.
        end.    
        
    end.

end.    

         
