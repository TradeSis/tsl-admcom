def input parameter par-arqxml as longchar.

def shared temp-table tt-tablexml no-undo
    field root   as char
    field tabela as char
    field campo  as char
    field valor  as char
    .

DEFINE VARIABLE hDoc AS HANDLE.
DEFINE VARIABLE hRoot AS HANDLE.
DEFINE VARIABLE hRoota AS HANDLE.
DEFINE VARIABLE hRootb AS HANDLE.
DEFINE VARIABLE hRootc AS HANDLE.
DEFINE VARIABLE hRootd AS HANDLE.
DEFINE VARIABLE hRoote AS HANDLE.
DEFINE VARIABLE hRootf AS HANDLE.
DEFINE VARIABLE hRootg AS HANDLE.
DEFINE VARIABLE hRooth AS HANDLE.
DEFINE VARIABLE hTable AS HANDLE.
DEFINE VARIABLE hTexto AS HANDLE.
DEFINE VARIABLE hBuf AS HANDLE.
DEFINE VARIABLE hDBFld AS HANDLE.

DEFINE VARIABLE i AS INTEGER.
DEFINE VARIABLE j AS INTEGER.
DEFINE VARIABLE l AS INTEGER.
DEFINE VARIABLE m AS INTEGER.
DEFINE VARIABLE n AS INTEGER.
DEFINE VARIABLE o AS INTEGER.
DEFINE VARIABLE p AS INTEGER.
DEFINE VARIABLE q AS INTEGER.
DEFINE VARIABLE r AS INTEGER.

CREATE X-DOCUMENT hDoc.
CREATE X-NODEREF hRoot.
CREATE X-NODEREF hRoota.
CREATE X-NODEREF hRootb.
CREATE X-NODEREF hRootc.
CREATE X-NODEREF hRootd.
CREATE X-NODEREF hRoote.
CREATE X-NODEREF hRootf.
CREATE X-NODEREF hRootg.
CREATE X-NODEREF hRooth.
CREATE X-NODEREF hTable.
CREATE X-NODEREF hTexto.


hDoc:LOAD("LONGCHAR", par-arqxml, FALSE).
hDoc:GET-DOCUMENT-ELEMENT(hRoot).

l1:
REPEAT i = 1 TO hRoot:NUM-CHILDREN:
  hRoot:GET-CHILD(hTable,i).
    
  if hTable:NUM-CHILDREN = 1
  then do:
        hTable:GET-CHILD(hTexto,1).
        if htexto:node-value = ""
        then do:
            hTable:GET-CHILD(hRoot,1).
            i = 0.
            next l1.
        end.
        create tt-tablexml.
        assign
            tt-tablexml.root   = hRoot:name
            tt-tablexml.tabela = hRoot:name
            tt-tablexml.campo  = hTable:name
            tt-tablexml.valor  = htexto:node-value
            .
  end.
  else if hTable:NUM-CHILDREN > 1
  then do:
    hRoot:GET-CHILD(hRoota,i).
    l2:
    REPEAT j = 1 TO hRoota:NUM-CHILDREN:
            hRoota:GET-CHILD(hTable,j).
      IF hTable:NUM-CHILDREN = 1 
      then do:
            hTable:GET-CHILD(hTexto,1).
          if htexto:node-value = ""
          then do:
            hTable:GET-CHILD(hRoota,1).
            j = 0.
            next l2.
          end.
          create tt-tablexml.
          assign
            tt-tablexml.root   = hRoot:name
            tt-tablexml.tabela = hRoota:name
            tt-tablexml.campo  = hTable:name
            tt-tablexml.valor  = htexto:node-value
            .

      end.
      else if hTable:NUM-CHILDREN > 1
      then do:
        hRoota:GET-CHILD(hRootb,j).
        l3:
        repeat l = 1 to hRootb:NUM-CHILDREN:
          hRootb:GET-CHILD(hTable,l).
          IF hTable:NUM-CHILDREN = 1
          then do:
            hTable:GET-CHILD(hTexto,1).
            if htexto:node-value = ""
            then do:
                hTable:GET-CHILD(hRootb,1).
                l = 0.
                next l3.
            end.
            create tt-tablexml.
            assign
                tt-tablexml.root   = hRoota:name
                tt-tablexml.tabela = hRootb:name
                tt-tablexml.campo  = hTable:name
                tt-tablexml.valor  = htexto:node-value
                .
          end.
          else IF hTable:NUM-CHILDREN > 1
          then do:
            hRootb:GET-CHILD(hRootc,l).
            l4:
            repeat m = 1 to hRootc:NUM-CHILDREN:
              hRootc:GET-CHILD(hTable,m).
              IF hTable:NUM-CHILDREN = 1
              then do:
                  hTable:GET-CHILD(hTexto,1).
                  if htexto:node-value = ""
                  then do:
                        hTable:GET-CHILD(hRootc,1).
                        m = 0.
                        next l4.
                  end.
                  create tt-tablexml.
                  assign
                    tt-tablexml.root   = hRootb:name
                    tt-tablexml.tabela = hRootc:name
                    tt-tablexml.campo  = hTable:name
                    tt-tablexml.valor  = htexto:node-value
                    .
              end.
              else IF hTable:NUM-CHILDREN > 1
              then do:
                hRootc:GET-CHILD(hRootd,m).
                l5:
                repeat n = 1 to hRootd:NUM-CHILDREN:
                  hRootd:GET-CHILD(hTable,n).
                  IF hTable:NUM-CHILDREN = 1
                  then do:
                      hTable:GET-CHILD(hTexto,1).
                      if htexto:node-value = ""
                      then do:
                        hTable:GET-CHILD(hRootd,1).
                        n = 0.
                        next l5.
                      end.
                      create tt-tablexml.
                      assign
                        tt-tablexml.root   = hRootc:name
                        tt-tablexml.tabela = hRootd:name
                        tt-tablexml.campo  = hTable:name
                        tt-tablexml.valor  = htexto:node-value
                        .
                  end.
                  else IF hTable:NUM-CHILDREN > 1
                  then do:
                    hRootd:GET-CHILD(hRoote,n).
                    l6:
                    repeat o = 1 to hRoote:NUM-CHILDREN:
                      hRoote:GET-CHILD(hTable,o).
                      IF hTable:NUM-CHILDREN = 1
                      then do:
                          hTable:GET-CHILD(hTexto,1).
                          if htexto:node-value = ""
                          then do:
                            hTable:GET-CHILD(hRoote,1).
                            o = 0.
                            next l6.
                          end.
                          create tt-tablexml.
                          assign
                            tt-tablexml.root   = hRootd:name
                            tt-tablexml.tabela = hRoote:name
                            tt-tablexml.campo  = hTable:name
                            tt-tablexml.valor  = htexto:node-value
                            .
                      end.
                      else IF hTable:NUM-CHILDREN > 1
                      then do:
                        hRoote:GET-CHILD(hRootf,o).
                        l7:
                        repeat p = 1 to hRootf:NUM-CHILDREN:
                          hRootf:GET-CHILD(hTable,p).
                          IF hTable:NUM-CHILDREN = 1
                          then do:
                            hTable:GET-CHILD(hTexto,p).
                            if htexto:node-value = ""
                            then do:
                                hTable:GET-CHILD(hRootf,1).
                                p = 0.
                                next l7.
                            end.
                            create tt-tablexml.
                            assign
                                tt-tablexml.root   = hRoote:name
                                tt-tablexml.tabela = hRootf:name
                                tt-tablexml.campo  = hTable:name
                                tt-tablexml.valor  = htexto:node-value
                                .
                           end.
                         end.
                       end.
                     end.
                   end.
                end.
              end.
            end.
          end.
        end.
      end.
    end. 
  END.
END.

DELETE OBJECT hDoc.
DELETE OBJECT hRoot.
DELETE OBJECT hRoota.
DELETE OBJECT hRootb.
DELETE OBJECT hRootc.
DELETE OBJECT hRootd.
DELETE OBJECT hRoote.
DELETE OBJECT hRootf.
DELETE OBJECT hTable.
DELETE OBJECT hTexto.

