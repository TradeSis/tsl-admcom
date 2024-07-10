{/admcom/progr/admbatch.i}

{/admcom/progr/tpalcis-wms.i}

    find abaswms where abaswms.wms = "ALCIS_VEX" no-lock.
    alcis-diretorio-bkp = abaswms.diretorio + "../../bkp/out".

alcis-diretorio-bkp = alcis-diretorio-bkp + "/".

def var vDeletaArquivo as log.
def var vqtdcarga as dec.
def var vsldconf  as dec.

def shared temp-table ttarq no-undo
    field arq as char format "x(50)"
    field interface     as char 
    field Arquivo       as char initial ?
    field diretorio     as char
    index idx is unique primary interface asc Arquivo asc.

def temp-table ttCONFheader no-undo
    field Remetente         as char format "x(10)"
    field NomeArquivo       as char format "x(4)"
    field NomeInterface     as char format "x(8)"
    field Site              as char format "x(3)"  
    field PROPRIETaRIO      as char format "x(12)"
    field NPedido           as char format "x(12)"     
    field Ncarga            as char format "x(12)"     
    field DataREAL          as char format "xxxxxxxx"  
    field HoraREAL          as char format "xxxxxxx"  
    field Peso              as char format "x(18)"
    field TipoPedido        as char format "x(4)"      
    field Transportadora    as char format "x(12)"     
    field Placa             as char format "x(10)"
    field Arquivo           as char
    index idx is unique primary Arquivo asc.    
    

def temp-table ttCONFitem       no-undo
    field Remetente         as char format "x(10)"
    field NomeArquivo       as char format "x(4)"
    field NomeInterface     as char format "x(8)"
    field Site              as char format "x(3)"
    field PROPRIETaRIO      as char format "x(12)"
    field NPedido           as char format "x(12)"
    field NItem             as char format "xxxx"
    field Produto           as char format "x(40)"
    field Quantidade        as char format "x(18)"
    field Unidade           as char format "x(6)"
    field Peso              as char format "x(18)"
    field Lote              as char format "x(20)"
    field Arquivo           as char
    index idx is unique primary arquivo asc Nitem asc.


def var vconta as int.
def var vlinha as char.

def var vhora as int.
def var vminu as int.

def var vetbcod as int.
def var vdcbcod as int.

    for each ttarq where ttarq.interface = "VEXM" and /* Esta interface */
                         ttarq.arq <> "".

        vdeletaarquivo = yes.
        
        find abasintegracao where 
                    abasintegracao.interface    = ttarq.interface and
                    abasintegracao.arquivo      = ttarq.arquivo   
                    no-lock no-error .  
        if not avail abasintegracao or
           (avail abasintegracao and abasintegracao.dtfim = ?)
        then do:
        
            input from value(ttarq.arq) no-echo.
            vconta = 0.
            repeat.
                vconta = vconta + 1.
                import unformatted vlinha.
                if vconta = 1 
                then do.
                    create ttCONFheader.
                    assign
                    ttCONFheader.Remetente      =   substr(vlinha, 1   ,   10  )    .
                    ttCONFheader.NomeArquivo    =   substr(vlinha, 11  ,   4   )    .
                    ttCONFheader.NomeInterface  =   substr(vlinha, 15  ,   8   )    .
                    ttCONFheader.Site           =   substr(vlinha, 23  ,   3   )    .
                    ttCONFheader.PROPRIETaRIO   =   substr(vlinha, 26  ,   12  )    .
                    ttCONFheader.NPedido        =   substr(vlinha, 38  ,   12  )    .
                    ttCONFheader.Ncarga         =   substr(vlinha, 50  ,   12  )    .
                    ttCONFheader.Data           =   substr(vlinha, 62  ,   8   )    .
                    ttCONFheader.Hora           =   substr(vlinha, 70  ,   5   )    .
                    ttCONFheader.Peso           =   substr(vlinha, 75  ,   18  )    .
                    ttCONFheader.TipoPedido     =   substr(vlinha, 93  ,   4   )    .
                    ttCONFheader.Transportadora =   substr(vlinha, 97  ,   12  )    .
                    ttCONFheader.Placa          =   substr(vlinha, 109 ,   10  ) . 

                    ttCONFheader.arquivo        =   ttarq.arquivo.
                
                    vhora = int(substring(ttCONFheader.hora,1,2)) * 60 * 60.
                    vminu = int(substring(ttCONFheader.hora,4,2)) * 60.

                    find abasintegracao where 
                        abasintegracao.interface    = ttarq.interface and
                        abasintegracao.arquivo      = ttarq.arquivo   
                        exclusive no-error .  
                    if not avail abasintegracao
                    then do:
                        create abasintegracao.
                        abasintegracao.interface    = ttarq.interface.
                        abasintegracao.arquivo      = ttarq.arquivo .
                        abasintegracao.diretorio    = ttarq.diretorio.    
                    end.
                    
                    abasintegracao.etbcD        = int(ttCONFheader.Proprietario).
                    
                    abasintegracao.data         = date(ttCONFheader.data).
                    abasintegracao.hora         = vhora + vminu.
                    abasintegracao.dtfim        = ?.
                    abasintegracao.hrfim        = ?.
                    abasintegracao.etbcod       = int(substr(ttCONFheader.npedido,1,3)).
                    abasintegracao.dcbcod       = int(substr(ttCONFheader.npedido,4,9)). 
                    
                    abasintegracao.NCarga       = abasintegracao.dcbcod.

                    abasintegracao.tipoPedido   = ttCONFheader.tipoPedido.
                
                    delete ttCONFheader.
                        
                    next.
                end.    

                create ttCONFitem.
                ttCONFitem.Remetente        =   substr(vlinha,  1   ,   10  ).
                ttCONFitem.NomeArquivo      =   substr(vlinha,  11  ,   4   ).
                ttCONFitem.NomeInterface    =   substr(vlinha,  15  ,   8   ).
                ttCONFitem.Site             =   substr(vlinha,  23  ,   3   ).
                ttCONFitem.PROPRIETaRIO     =   substr(vlinha,  26  ,   12  ).
                ttCONFitem.NPedido          =   substr(vlinha,  38  ,   12  ).
                ttCONFitem.NItem            =   substr(vlinha,  50  ,   4   ).
                ttCONFitem.Produto          =   substr(vlinha,  54  ,   40  ).
                ttCONFitem.Quantidade       =   (substr(vlinha,  94  ,   18  )).
                ttCONFitem.Unidade          =   substr(vlinha,  112 ,   6   ).
                ttCONFitem.Peso             =   (substr(vlinha,  118 ,   18  )).
                ttCONFitem.Lote             =   substr(vlinha,  136 ,   20  ).
                ttCONFitem.Arquivo          =   ttarq.arquivo.
            end.
            input close.

            find abasintegracao where 
                        abasintegracao.interface    = ttarq.interface and
                        abasintegracao.arquivo      = ttarq.arquivo 
                        no-lock no-error .  

            if avail abasintegracao
            then do:
                vconta = 0.
                for each ttCONFitem.   
                    vconta = vconta + 1.
            
                    create abascargaprod. 
                    abascargaprod.ArquivoIntegracao = abasintegracao.ArquivoIntegracao. 
                    abascargaprod.interface         = abasintegracao.interface. 
                    abascargaprod.Sequencia         = int(ttCONFitem.NItem). /*vconta. */ /* eh um arquivo conf*/
                    abascargaprod.dcbcod            = abasintegracao.dcbcod.
                    abascargaprod.qtdCarga          = dec(ttCONFitem.Quantidade) / 1000000000.
                    abascargaprod.procod            = int(ttCONFitem.produto).
                    
                    vqtdcarga = abascargaprod.qtdcarga.
                    for each abasconfprod where
                        abasconfprod.dcbcod  = abascargaprod.dcbcod and
                        abasconfprod.dcbpseq = abascargaprod.sequencia
                        exclusive.
                        
                        vsldconf =  abasconfprod.qtdconf - abasconfprod.qtdcarga.
                        
                        if vsldconf < vqtdcarga
                        then abasconfprod.qtdcarga = vsldconf.
                        else abasconfprod.qtdcarga = vqtdcarga.
                        vqtdcarga = vqtdcarga - abasconfprod.qtdcarga.
                        
                        find abascorteprod of abasconfprod  exclusive no-error.
                        if avail abascorteprod and abasconfprod.qtdCarga > 0
                        then do:
                            find abastransf    of abascorteprod exclusive no-error.
                            if avail abastransf
                            then do:
                                abastransf.qtdemWMS = abastransf.qtdemWMS - abasconfprod.qtdconf. 
                                abastransf.qtdemWMS = abastransf.qtdemWMS + abasconfprod.qtdCarga.
                                if abastransf.abtqtd > 
                                    (abastransf.qtdemWMS + abastransf.qtdatend)
                                then do:
                                    abastransf.abtsit = "AC". /* Volta pro Corte */
                                end.
                                else do:
                                    abastransf.abtsit = "SE". /* Separado*/
                                end.
                            end.                        
                        end.     
                    end.    
                    delete ttCONFitem.
                end.
                                         
            end.
        
        end.
        
        if vdeletaarquivo
        then do on error undo: 
            find abasintegracao where 
                        abasintegracao.interface    = ttarq.interface and
                        abasintegracao.arquivo      = ttarq.arquivo 
                        exclusive. 
            abasintegracao.dtfim = today.
            abasintegracao.hrfim = time.           

            /** PILOTO - NAO MUDA O ARQUIVO DE LUGAR 
            unix silent value("mv " + ttarq.arq + " " + alcis-diretorio-bkp).
            **/
        end.
        else do on error undo:
            find abasintegracao where 
                        abasintegracao.interface    = ttarq.interface and
                        abasintegracao.arquivo      = ttarq.arquivo 
                        exclusive. 
            delete abasintegracao.        
        end.
        
    end.

