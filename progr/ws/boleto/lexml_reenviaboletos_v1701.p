
def input parameter p-arquivo as char.



def shared temp-table ReenviaBoletosEntrada
    field codigo_cpfcnpj as char
    field banco as char
    field nossonumero as char.
unix silent value("cp  " + p-arquivo + " /admcom/work/helio.txt").

    def var v-return-mode        as log  no-undo.

    v-return-mode =
        TEMP-TABLE ReenviaBoletosEntrada:READ-XML("FILE",
                                  p-arquivo ,
                                  "EMPTY",
                                  ? /* v-schemapath*/ ,
                                  ? /*v-override-def-map*/ ,
                                  ? /*v-field-type-map*/ ,
                                  ? /*v-verify-schema-mode*/ ).

