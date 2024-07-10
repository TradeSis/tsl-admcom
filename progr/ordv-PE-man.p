
{tpalcis-wms.i}

def input parameter p-arq as char.

def new shared var vALCIS-ARQ-ORDVH   as int.

def new shared temp-table ttarq
    field Arquivo   as char format "x(25)"
    field tm        like tipo-alcis.tm format "x(45)" label "Tipo"
    field seq       as int.
 
def var vtm like ttarq.tm.
vtm = "".

def new shared temp-table ttheader
    field Tipo              as char format "x(4)"
    field Remetente         as char format "x(10)"
    field Nome_arquivo      as char format "x(4)"
    field Nome_interface    as char format "x(8)"
    field Site              as char format "xxx"
    field NotaFiscal        as char format "x(12)"
    field Proprietario      as char format "x(12)"
    field Fornecedor        as char format "x(12)"
    field Arquivo           as char format "x(20)"
    index i1 proprietario fornecedor notafiscal
    .

def new shared temp-table ttitem 
    field Tipo              as char format "x(4)"
    field Remetente         as char format "x(10)"
    field Nome_arquivo      as char format "x(4)"
    field Nome_interface    as char format "x(8)"
    field Produto           as char format "x(40)"
    field Quantidade        as char format "x(18)"
    field NotaFiscal        as char format "x(12)"
    field Proprietario      as char format "x(12)" 
    field Fornecedor        as char format "x(12)"
    field bloq              as char format "xx"
    field Qtde_no_Pack      as char format "x(18)"
    index i1 proprietario fornecedor notafiscal
    .

create ttarq.
ttarq.arquivo = p-arq.

run diretorio.

def var vemite as int.
def var vserie as char.
def var vnumero as int.
for each ttheader where ttheader.tipo = "PE" no-lock:

    vemite = int(ttheader.fornecedor).
    vserie = string(
      int(substr(ttheader.NotaFiscal,length(trim(ttheader.NotaFiscal)) - 2,3))
      ).
    vnumero = 
      int(substr(ttheader.NotaFiscal,1,length(trim(ttheader.NotaFiscal)) - 3)).

    find first plani where
               plani.etbcod = 900 and
               plani.emite  = vemite and
               plani.serie  = vserie and
               plani.numero = vnumero
               no-lock no-error.
    if avail plani
    then do:
        run  pedido-especial(input ttheader.arquivo).
    end.
end.    

procedure diretorio.
    def var vi as int.
    def var varquivo as char.
    /**********
    for each ttarq.
        delete ttarq.
    end.

    varquivo = "/admcom/relat/lealcis." + string(time).
    unix silent value("ls " + alcis-diretorio + " > " + varquivo).
    input from value(varquivo).
    **********/
    
    for each ttheader: delete ttheader. end.
    for each ttitem: delete ttitem. end.
        
    for each ttarq:
    /*
    repeat transaction.
        create ttarq.
        import ttarq.
      */  
        if substr(ttarq.arquivo,1,4) <> "CREC"
        then do.
            delete ttarq.
            next.
        end.
        
        find first tipo-alcis where tipo-alcis.tp = substr(ttarq.arquivo,1,4)
                        no-lock no-error.
        if avail tipo-alcis and
            (if vtm <> "" then tipo-alcis.tm = vtm else true)
        then do:                
            ttarq.tm  = tipo-alcis.tm.
            ttarq.seq = int(substr(ttarq.arquivo,5,5)).
            do vi = 1 to 5:
                if v-filtro[vi] = ""
                then do:
                    v-filtro[vi] = ttarq.tm.
                    leave.
                end.
                else if v-filtro[vi] = ttarq.tm
                     then leave.
            end.
        end.
        else do:
            delete ttarq.
        end.
    end.
    input close.
    unix silent value("rm -f " + varquivo).

    for each ttarq:
        run valida-arquivo-PE (ttarq.arquivo).    
        find first ttheader where ttheader.arquivo = ttarq.arquivo no-error.
        if avail ttheader 
        then do:
            if ttheader.tipo = "PE"
            then.
            else do:
                for each ttitem where
                     ttitem.proprietario = ttheader.proprietario and
                     ttitem.fornecedor   = ttheader.fornecedor and
                     ttitem.notafiscal   = ttheader.notafiscal
                     .
                    delete ttitem.
                end.     
                delete ttheader.
                delete ttarq.
            end.
        end.
        else do:
            delete ttarq.
        end.
    end.    
end procedure.

def temp-table tt-pedid like pedid.

procedure ver-pedido-especial:
    
    def input parameter p-pednum like pedid.pednum.
    
    for each tt-pedid: delete tt-pedid. end.
    def buffer bpedid for pedid.
    for each estab no-lock:
        for each bpedid where 
             bpedid.etbcod = estab.etbcod and
             bpedid.pedtdc = 6 and
             bpedid.pedsit = yes and
             bpedid.comcod = p-pednum
             no-lock:
            create tt-pedid.
            buffer-copy bpedid to tt-pedid.
        end.
    end. 
end procedure.

procedure pedido-especial:
    def input parameter p-arq as char.
    def buffer bpedid for pedid.
    def buffer bliped for liped.
    def var log-qtd-registros as int.
    log-qtd-registros = 0.
    def var vmovseq as int.
    vmovseq = 0.
    def var par-numcod as int.
    /***
    for each ttheader: delete ttheader. end.
    for each ttitem: delete ttitem. end.
    ***/

    for each plaped where plaped.forcod = plani.emite and
                          plaped.numero = plani.numero
                          no-lock,
        first pedid where pedid.etbcod = plaped.pedetb and
                          /*pedid.pedtdc = plaped.pedtdc and*/
                          pedid.pednum = plaped.pednum and
                          pedid.pedtdc = 1
                          no-lock:

        run ver-pedido-especial(input pedid.pednum).
        find first tt-pedid where
                   tt-pedid.comcod =  pedid.pednum no-lock no-error.
        if avail tt-pedid
        then do:           
            find first bpedid where bpedid.etbcod = tt-pedid.etbcod and
                                    bpedid.pedtdc = tt-pedid.pedtdc and
                                    bpedid.pednum = tt-pedid.pednum and
                                    bpedid.comcod = pedid.pednum
                                    no-lock no-error.
            if avail bpedid           
            then do:

                run gera-tdocbase(input p-arq,
                              input bpedid.etbcod,
                              input bpedid.condes,
                              input plani.emite,
                              input plani.numero,
                              input plani.serie,
                              input bpedid.pednum,
                              input bpedid.pedtdc).
            end.                                        
        end.
        else do:
            find first pedcompe where
                 pedcompe.tipo   = 0 and
                 pedcompe.etbcod = pedid.etbcod and
                 pedcompe.pedtdc = pedid.pedtdc and
                 pedcompe.pednum = pedid.pednum
                 no-lock no-error.
            if avail pedcompe
            then do:
                run gera-tdocbase(input p-arq,
                                  input pedcompe.etbcod_ori,
                              input pedcompe.etbcod_des,
                              input plani.emite,
                              input plani.numero,
                              input plani.serie,
                              input pedid.pednum,
                              input pedid.pedtdc).
                 
            end. 
            else do:
                if num-entries(pedid.pedobs[1],"") = 4
                then run gera-tdocbase(input p-arq,
                                       input entry(4,pedid.pedobs[1],""),
                                       input entry(4,pedid.pedobs[1],""),
                                       input plani.emite,
                                       input plani.numero,
                                       input plani.serie,
                                       input pedid.pednum,
                                       input pedid.pedtdc).
                                       
                else if num-entries(pedid.pedobs[1],"") = 3 and
                            (entry(2,pedid.pedobs[1],"") = "FILIAL" or
                             entry(2,pedid.pedobs[1],"") = "FL")
                then run gera-tdocbase(input p-arq,
                                       input entry(3,pedid.pedobs[1],""),
                                       input entry(3,pedid.pedobs[1],""),
                                       input plani.emite,
                                       input plani.numero,
                                       input plani.serie,
                                       input pedid.pednum,
                                       input pedid.pedtdc).
                       
                else do:
                    bell.
                    Message color red/with
                    "Interface nao sera gerada por falta de informacao" skip
                    "Pedido: " pedid.pednum   skip
                    "Detalhe:" pedid.pedobs[1] 
                    view-as alert-box.
                end.       
            end.    
        end.
    end.
    for each tdocbase where 
         tdocbase.tdcbcod = "ESP" and
         tdocbase.situacao = "A"  and
         tdocbase.campo_char3 = p-arq
         no-lock:
        
        run ordvh-993.p(recid(tdocbase), "PESP").

        
        /*
        output to value("/admcom/relat/" + string(tdocbase.dcbcod)).
        */
        unix silent value("mv -f " + alcis-diretorio + "/" +
                          tdocbase.campo_char3 + " " + alcis-diretorio-bkp).
        /*
        output close.*/                  
    end.  
end procedure.

procedure valida-arquivo-PE:

    def input parameter par-arq as char.
    def var varquivo as char.

    varquivo = alcis-diretorio + "/" + par-arq.
    unix silent value("quoter " + varquivo + " > ./consulta-crec.arq" ). 

    def var v as int.
    def var vlinha as char.
    /*
    for each ttheader: delete ttheader. end.
    for each ttitem: delete ttitem. end.
    */
    input from ./consulta-crec.arq.
    repeat.
        v = v + 1.
        import vlinha.
        if v = 1 then do.
            create ttheader.
            assign ttheader.Remetente      = substr(vlinha,1 ,10)
               ttheader.Nome_arquivo   = substr(vlinha,11,4 )
               ttheader.Nome_interface = substr(vlinha,15,8 )
               ttheader.Site           = substr(vlinha,23,3 )
               ttheader.NotaFiscal     = substr(vlinha,26,12)
               ttheader.Proprietario   = substr(vlinha,38,12)
               ttheader.Fornecedor     = substr(vlinha,50,12)
               ttheader.arquivo        = par-arq
               .
            next.
        end.
        create ttitem.
        assign ttitem.Remetente      = substr(vlinha,  1,10)
           ttitem.Nome_arquivo   = substr(vlinha, 11,04)
           ttitem.Nome_interface = substr(vlinha, 15,08)
           ttitem.Produto        = substr(vlinha, 23,40)
           ttitem.Quantidade     = substr(vlinha, 63,18)
           ttitem.NotaFiscal     = substr(vlinha, 81,12)
           ttitem.Proprietario   = substr(vlinha, 93,12)
           ttitem.Fornecedor     = substr(vlinha,105,12)
           ttitem.bloq           = substr(vlinha,117, 2)
           ttitem.Qtde_no_Pack   = substr(vlinha,119,18).
    end.
    input close.

    for each ttheader where ttheader.arquivo = par-arq:
        for each ttitem where
                 ttitem.proprietario = ttheader.proprietario and
                 ttitem.fornecedor   = ttheader.fornecedor and
                 ttitem.notafiscal   = ttheader.notafiscal
                 no-lock.
            find produ where produ.procod = int(ttitem.produto) 
                        no-lock no-error.
            if avail produ and produ.proipival = 1
            then assign
                    ttitem.tipo = "PE"
                    ttheader.tipo = "PE" .
        end.             
    end.
end procedure.

procedure gera-tdocbase:
    def input parameter p-arq as char.
    def input parameter p-etbori like estab.etbcod.
    def input parameter p-etbdes like estab.etbcod.
    def input parameter p-emite  like plani.emite.
    def input parameter p-numero like plani.numero.
    def input parameter p-serie like plani.serie. 
    def input parameter p-pednum like pedid.pednum.
    def input parameter p-pedtdc like pedid.pedtdc.
    
    def var par-numcod as int.
    def buffer bpedcompe for pedcompe.
    def var log-qtd-registros as int.
    log-qtd-registros = 0.
    def var vmovseq as int.
    vmovseq = 0.

    find first tab_box where
                       tab_box.etbcod = p-etbori
                       no-lock no-error.
    run tdocbase-dcbcod.p(output par-numcod).
    do on error undo.
        create  tdocbase.
        ASSIGN  tdocbase.dcbcod    = par-numcod
                tdocbase.geraraut   = no
                tdocbase.dcbnum    = par-numcod
                tdocbase.tdcbcod   = "ESP"
                tdocbase.chave-ext = ? 
                tdocbase.DtDoc     = today
                tdocbase.DtEnv     = today
                tdocbase.HrEnv     = time
                tdocbase.Etbdes    = if p-etbdes > 0 then p-etbdes
                else p-etbori
                tdocbase.plani-etbcod = ?
                tdocbase.box  = if avail tab_box 
                                then tab_box.box else 0
                tdocbase.ordem = 1
                tdocbase.RomExterno     = yes
                tdocbase.plani-placod = ?
                tdocbase.campo_int1 = p-numero
                tdocbase.campo_int2 = p-etbori
                tdocbase.campo_char3 = p-arq
                        .
          
        if p-etbori = 200 
        then do. 
             tdocbase.Ecommerce = yes.
             tdocbase.clfcod    = ?.
        end.                
    end.
    for each ttitem where ttitem.Produto <> "" no-lock:
        do on error undo: 
            find first bpedcompe where
                 bpedcompe.tipo = 100 and
                 bpedcompe.etbcod = p-etbori /*pedcompe.etbcod*/ and
                 bpedcompe.pedtdc = p-pedtdc /*pedcompe.pedtdc*/ and
                 bpedcompe.pednum = p-pednum /*pedcompe.pednum*/ and
                 bpedcompe.procod = int(ttitem.Produto)
                 no-error.
            if not avail bpedcompe
            then do:     
                create bpedcompe.
                assign
                    bpedcompe.tipo = 100
                    bpedcompe.etbcod = p-etbori /*pedcompe.etbcod*/
                    bpedcompe.pedtdc = p-pedtdc /*pedcompe.pedtdc*/
                    bpedcompe.pednum = p-pednum /*pedcompe.pednum*/
                    bpedcompe.procod = int(ttitem.Produto)
                    .
            end.    
            bpedcompe.movqtm = dec(ttitem.Quantidade) / 1000000000
                .

            create  tdocbpro.
            assign
                log-qtd-registros = log-qtd-registros + 1
                vmovseq = vmovseq + 1
                tdocbpro.dcbcod  = tdocbase.dcbcod 
                tdocbpro.dcbpseq = vmovseq          
                tdocbpro.predt   = today
                tdocbpro.etbdes  = p-etbdes
                tdocbpro.campo_int3 = tdocbase.etbdes
                tdocbpro.procod  = bpedcompe.procod  
                tdocbpro.movqtm  = bpedcompe.movqtm
                tdocbpro.pednum  = p-pednum
                tdocbpro.campo_char1 = p-serie
                tdocbpro.campo_int1 = p-numero
                tdocbpro.campo_int2 = p-etbori
                .
        end.
    end.
end procedure.
