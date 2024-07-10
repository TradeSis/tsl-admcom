
def input parameter p-arquivo as char.


def shared temp-table ClienteContratoEntrada
    field codigo_cpfcnpj as char
    field numero_contrato as char.

    def var v-return-mode        as log  no-undo.

    v-return-mode =
        TEMP-TABLE ClienteContratoEntrada:READ-XML("FILE",
                                  p-arquivo ,
                                  "EMPTY",
                                  ? /* v-schemapath*/ ,
                                  ? /*v-override-def-map*/ ,
                                  ? /*v-field-type-map*/ ,
                                  ? /*v-verify-schema-mode*/ ).

