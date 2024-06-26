*&---------------------------------------------------------------------*
*& Report ZREPORT_3
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zreport_3.

*3 - Elaborar um programa ABAP onde deverão ser selecionados na tabela VBAK

TABLES: vbak, "Documento de vendas
        vbap. "Dados de item

"-----------------------------------------------------------------------------------------"
"-----------------------------------------------------------------------------------------"
"-----------------------------------------------------------------------------------------"
"Declaração de Variáveis, Estruturas e Tabelas Internas

TYPES: BEGIN OF ty_vbak, "Estrutura - Documento de vendas
  vbeln TYPE vbeln, "Documento de vendas
  erdat TYPE erdat, "Data de criação do registro
  auart TYPE auart, "Tipo de documento de vendas
  kunnr TYPE kunnr, "Emissor da ordem
END OF ty_vbak.

DATA: t_vbak TYPE STANDARD TABLE OF ty_vbak WITH HEADER LINE, "Tabela Interna - Documento de vendas
      ls_vbak TYPE ty_vbak.                                   "Estrutura - Documento de vendas

TYPES: BEGIN OF ty_vbap, "Estrutura - Dados de item
  vbeln  TYPE vbeln,  "Documento de vendas
  posnr  TYPE posnr,  "Item do documento de vendas
  matnr  TYPE matnr,  "Nº do material
  kwmeng TYPE kwmeng, "Quantidade da ordem acumulada em unidade de venda
  netwr  TYPE netwr,  "Valor líquido do item da ordem na moeda do documento
END OF ty_vbap.

DATA: t_vbap  TYPE STANDARD TABLE OF ty_vbap, "Tabela Interna - Dados de item
      ls_vbap TYPE ty_vbap.                   "Estrutura - Dados de item

TYPES: BEGIN OF ty_output, "Estrutura combinada
  vbeln  TYPE vbeln,  "Documento de vendas
  posnr  TYPE posnr,  "Item do documento de vendas
  matnr  TYPE matnr,  "Nº do material
  kwmeng TYPE kwmeng, "Quantidade da ordem acumulada em unidade de venda
  netwr  TYPE netwr,  "Valor líquido do item da ordem na moeda do documento
  erdat  TYPE erdat,  "Data de criação do registro
  auart  TYPE auart,  "Tipo de documento de vendas
  kunnr  TYPE kunnr,  "Emissor da ordem
END OF ty_output.

DATA: t_output TYPE TABLE OF ty_output, "Tabela Interna da Tabela de Saída
      ls_output TYPE ty_output.         "Estrutura da Tabela de Saída

"-----------------------------------------------------------------------------------------"
"-----------------------------------------------------------------------------------------"
"-----------------------------------------------------------------------------------------"

START-OF-SELECTION.
  PERFORM get_data.
  PERFORM fill_data.
  PERFORM display_data.
END-OF-SELECTION.

*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

*as ordens de venda criadas no mês 02/2008, retornando os campos Documento de
*vendas, Data de criação do registro, Tipo de documento de vendas e Emissor da ordem.

  SELECT vbeln, "Documento de vendas
         erdat, "Data de criação do registro
         auart, "Tipo de documento de vendas
         kunnr  "Emissor da ordem
    FROM vbak   "Da Tabela Documento de vendas
    INTO CORRESPONDING FIELDS OF  TABLE @t_vbak "Nos campos correspondentes da Tabela Interna - Documento de vendas
    WHERE erdat BETWEEN '20081001' AND '20081031'. "Onde a data está no mês de fevereiro de 2008
    "Altere estas datas para gerar dados, pois as datas pedidas no doc não retornam nada no sistema.

*Para cada ordem de venda encontrada na tabela VBAK selecionar na tabela
*VBAP seus itens onde o campo Documento de vendas relaciona as duas tabelas,
*retornando os campos Documento de vendas, Item do documento de vendas, Nº do
*material, Quantidade da ordem acumulada em unidade de venda e Valor líquido do item
*da ordem na moeda do documento.

  SELECT vbeln,  "Documento de vendas
         posnr,  "Item do documento de vendas
         matnr,  "Nº do material
         kwmeng, "Quantidade da ordem acumulada em unidade de venda
         netwr   "Valor líquido do item da ordem na moeda do documento
    FROM vbap  "Da Tabela Transparente - Dados de item
    INTO CORRESPONDING FIELDS OF TABLE @t_vbap "Nos campos correspondentes da Tabela Interna - Dados de item
    FOR ALL ENTRIES IN @t_vbak   "Relacionada com a Tabela Interna - Documento de vendas
    WHERE vbeln = @t_vbak-vbeln. "Onde possuem o mesmo número de Documento de Vendas.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form fill_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_data .

  "Alimenta a Tabela de Saída
  LOOP AT t_vbap INTO ls_vbap.
    READ TABLE t_vbak INTO ls_vbak WITH KEY vbeln = ls_vbap-vbeln.
      IF sy-subrc = 0 AND ls_vbak-kunnr <> ''. " Verifica se o emissor não está vazio
        ls_output-vbeln  = ls_vbap-vbeln.   " Copia o número do documento de vendas
        ls_output-posnr  = ls_vbap-posnr.   " Copia o número do item do documento de vendas
        ls_output-matnr  = ls_vbap-matnr.   " Copia o número do material
        ls_output-kwmeng = ls_vbap-kwmeng.  " Copia a quantidade da ordem acumulada em unidade de venda
        ls_output-netwr  = ls_vbap-netwr.   " Copia o valor líquido do item da ordem na moeda do documento
        ls_output-erdat  = ls_vbak-erdat.   " Copia a data de criação do registro
        ls_output-auart  = ls_vbak-auart.   " Copia o tipo de documento de vendas
        ls_output-kunnr  = ls_vbak-kunnr.   " Copia o emissor da ordem
        APPEND ls_output TO t_output.       " Adiciona a linha à tabela de saída
      ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_data .

"Imprimir todos os itens de cada ordem de venda.
*Na impressão do resultado, efetuar uma quebra no relatório pelo campo Emissor
*da Ordem, onde deverá ser impresso a quantidade de ordens encontrada para cada um
*dos emissores selecionados.

*Imprimir os campos: Emissor da ordem, Tipo de documento de vendas, Data de
*criação do registro, Documento de vendas, Item do documento de vendas, Nº do
*material, Quantidade da ordem acumulada em unidade de venda e Valor líquido do item
*da ordem na moeda do documento.

  SORT t_output BY kunnr. "Ordena Tabela Interna por Emissor.

  DATA: lv_last_kunnr TYPE kunnr,  "Último Emissor da Ordem
        lv_count      TYPE i.      "Contador de Ordens de Venda

  lv_last_kunnr = ''.  " Inicializa a variável do último emissor
  lv_count = 0.        " Inicializa o contador

*  Impressão dos Dados
  LOOP AT t_output INTO ls_output.
    IF lv_last_kunnr <> ls_output-kunnr.
      IF lv_last_kunnr <> ''.
        WRITE: / '--------------------------------------------------'.
        WRITE: / 'Emissor: ', lv_last_kunnr, 'Quantidade de Ordens: ', lv_count.
        WRITE: / '--------------------------------------------------'.
        lv_count = 0.
      ENDIF.
      WRITE: / 'Emissor: ', ls_output-kunnr. "Primeira linha escrita
      lv_last_kunnr = ls_output-kunnr.
    ENDIF.

    WRITE: / 'Documento de vendas: ', ls_output-vbeln,
           / 'Item do documento de vendas: ', ls_output-posnr,
           / 'Nº do material: ', ls_output-matnr,
           / 'Quantidade da ordem acumulada em unidade de venda: ', ls_output-kwmeng,
           / 'Valor líquido do item da ordem na moeda do documento: ', ls_output-netwr,
           / 'Data de criação do registro: ', ls_output-erdat,
           / 'Tipo de documento de vendas: ', ls_output-auart.
    WRITE: / '--------------------------------------------------'.
    lv_count = lv_count + 1.
  ENDLOOP.

  IF lv_last_kunnr <> ''.
    WRITE: / '--------------------------------------------------'.
    WRITE: / 'Emissor: ', lv_last_kunnr, 'Quantidade de Ordens: ', lv_count.
    WRITE: / '--------------------------------------------------'.
  ENDIF.

ENDFORM.
