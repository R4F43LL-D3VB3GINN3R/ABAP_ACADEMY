*&---------------------------------------------------------------------*
*& Report ZREPORT_8
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zreport_8.

*"Elaborar um programa ABAP onde deverá ser criada uma tela de seleção com
*o campo Pagador como seleção múltipla, Documento de faturamento como seleção
*múltipla e Organização de vendas como seleção única e valor default ‘3020’. Seus tipos
*se encontram na tabela VBRK.

TABLES: vbrk, "Documento de Faturamento: Dados de Cabeçalho
        vbrp, "Documento de Faturamento: Dados de Item
        kna1, "Mestre de clientes (Parte Geral)
        makt. "Textos Breves de Material

"-------------------------
"    Tela de Seleção
"-------------------------

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS s_kunrg FOR vbrk-kunrg.             "Campo de Seleção Múltipla - Pagador
  SELECT-OPTIONS s_vbeln FOR vbrk-vbeln.             "Campo de Seleção Múltipla - Documento de Faturamento
  PARAMETERS p_vkorg TYPE vbrk-vkorg DEFAULT '1710'. "Organização de Vendas
SELECTION-SCREEN END OF BLOCK a1.
SELECTION-SCREEN SKIP 1.

"-----------------------------------------------------------------------------------------------
"-----------------------------------------------------------------------------------------------
"-----------------------------------------------------------------------------------------------
"Variáveis, Estruturas e Tabelas

TYPES: BEGIN OF ty_vbrk, "Documento de Faturamento: Dados de Cabeçalho
  vbeln TYPE vbrk-vbeln, "Documento de Faturamento
  fkdat TYPE vbrk-fkdat, "Data do Documento de Faturamento
  kunag TYPE vbrk-kunag, "Pagador
END OF ty_vbrk.

DATA: t_vbrk  TYPE TABLE OF ty_vbrk, "Tabela Interna - Documento de Faturamento: Dados de Cabeçalho
      ls_vbrk TYPE ty_vbrk. "Estrutura - Documento de Faturamento: Dados de Cabeçalho

TYPES: BEGIN OF ty_vbrp, "Estrutura - Documento de Faturamento: Dados de Item
  vbeln TYPE vbrp-vbeln, "Documento de Faturamento
  fkimg TYPE vbrp-fkimg, "Quantidade Faturada Efetivamente
  posnr TYPE vbrp-posnr, "Item do Documento de Faturamento
  brgew TYPE vbrp-brgew, "Peso Bruto
  ntgew TYPE vbrp-ntgew, "Peso Líquido
  netwr TYPE vbrp-netwr, "Valor Líquido do Item de Faturamento em Moeda do Documento
  matnr TYPE vbrp-matnr, "Número do Material
END OF ty_vbrp.

DATA: t_vbrp  TYPE TABLE OF ty_vbrp, "Tabela Interna - Estrutura - Documento de Faturamento: Dados de Item
      ls_vbrp TYPE ty_vbrp.          "Estutura - Estrutura - Documento de Faturamento: Dados de Item

TYPES: BEGIN OF ty_kna1, "Estrutura - Mestre de clientes (Parte Geral)
  kunnr TYPE kna1-kunnr, "Nº Cliente 1
  name1 TYPE kna1-name1, "Nome 1
  ort01 TYPE kna1-ort01, "Local
  regio TYPE kna1-regio, "Região (país, estado, província, condado)
  stras TYPE kna1-stras, "Rua e Nº
END OF ty_kna1.

DATA: t_kna1  TYPE TABLE OF ty_kna1, "Tabela Interna - Estrutura - Mestre de clientes (Parte Geral)
      ls_kna1 TYPE ty_kna1.          "Estrutura - Estrutura - Mestre de clientes (Parte Geral)

TYPES: BEGIN OF ty_makt, "Estrutura - Textos Breves de Material
  matnr TYPE makt-matnr, "Número do Material
  maktx TYPE makt-maktx, "Texto Breve de Material.
END OF ty_makt.

DATA: t_makt  TYPE TABLE OF ty_makt, "Tabela Interna - Estrutura - Textos Breves de Material
      ls_makt TYPE ty_makt.          "Estrutura - Estrutura - Textos Breves de Material

"-----------------------------------------------------------------------------------------------
"-----------------------------------------------------------------------------------------------
"-----------------------------------------------------------------------------------------------

START-OF-SELECTION.
  PERFORM get_data.
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
FORM get_data.

*  Selecionar na tabela VBRK todos os Documentos de faturamento que esteja de
*  acordo com o campo Pagador da tela de seleção, Documento de Faturamento da tela de
*  seleção, Organização de vendas da tela de seleção, Tipo documento de faturamento =
*  ‘F2’ e Moeda do documento SD = ‘USD’. Retornar os campos Documento de
*  Faturamento, Data doc.faturamento p/índice de docs.faturamto e Pagador.

  SELECT vbeln, "Selecione Documento de Faturamento
         fkdat, "Data do Documento de Faturamento
         kunag  "Pagador
         FROM vbrk "Da Tabela Documento de Faturamento: Dados de Cabeçalho
         INTO CORRESPONDING FIELDS OF TABLE @t_vbrk "Nos campos correspondentes da Tabela Interna
         WHERE kunrg IN @s_kunrg "Onde o Pagador está no range de procura
         AND vbeln IN @s_vbeln   "E o Documento de Faturamento está no range de procura
         AND vkorg = @p_vkorg.   "E a Organização de Vendas é igual ao parâmetro

*  Para cada registro encontrado na tabela VBRK, selecionar os itens de faturamento
*  na tabela VBRP onde o campo Documentos de faturamento relaciona as duas tabelas,
*  retornando os campos Documento de faturamento, Item do documento de faturamento,
*  Quantidade faturada efetivamente, Peso líquido, Peso bruto, Valor líquido do item de
*  faturamento em moeda do documento e Nº do material.

  SELECT vbeln, "Selecione Documento de Faturamento
         fkimg, "Quantidade Faturada Efetivamente
         posnr, "Item do Documento de Faturamento
         brgew, "Peso Bruto
         ntgew, "Peso Líquido
         netwr, "Valor Líquido do Item de Faturamento em Moeda do Documento
         matnr  "Número do Material
         FROM vbrp "Da Tabela Transparente - Documento de Faturamento: Dados de Item
         INTO CORRESPONDING FIELDS OF TABLE @t_vbrp "Nos campos correspondentes da Tabela Interna - Documento de Faturamento: Dados de Item
         FOR ALL ENTRIES IN @t_vbrk "Relaciona a Tabela Interna - Documento de Faturamento: Dados de Cabeçalho
         WHERE vbeln = @t_vbrk-vbeln "Onde os Documentos de Faturamento são os mesmos.
         AND aland = 'US'.

*  Para cada registro encontrado na tabela VBRK, selecionar na tabela KNA1 os
*  dados do Pagador onde o campo Pagador da tabela VBRK se relaciona com o campo Nº
*  cliente 1 da tabela KNA1 e o campo Chave do país = ‘US’. Retornar os campos Nº
*  cliente 1, Nome 1, Local, Região (país, estado, província, condado) e Rua e nº.

  SELECT kunnr, "Selecione Nº Cliente 1
         name1, "Nome 1
         ort01, "Local
         regio, "Região (país, estado, província, condado)
         stras  "Rua e Nº
         FROM kna1 "Da Tabela Transparente - Mestre de clientes (Parte Geral)
         INTO CORRESPONDING FIELDS OF TABLE @t_kna1 "Nos campos correspondentes da Tabela Interna - Mestre de clientes (Parte Geral)
         FOR ALL ENTRIES IN @t_vbrk "Relacionando com a Tabela Interna - Documento de Faturamento: Dados de Cabeçalho
         WHERE kunnr = @t_vbrk-kunag. "Onde o Nº Cliente 1 é igual ao Pagador

*  Para cada registro encontrado na tabela VBRP, selecionar na tabela MAKT a
*  descrição dos materiais onde o campo Nº do material relaciona as duas tabelas e o
*  campo Código de idioma = ‘PT’. Retornar os campos Nº do material e Texto breve de
*  material.

  SELECT matnr, "Número do Material
         maktx  "Texto Breve de Material.
         FROM makt "Da Tabela Transparente - Textos Breves de Material
         INTO CORRESPONDING FIELDS OF TABLE @t_makt "Nos campos correspondentes da Tabela Interna - Textos Breves de Material
         FOR ALL ENTRIES IN @t_vbrp "Relacionando com a Tabela Interna - Documento de Faturamento: Dados de Item
         WHERE spras = 'P'          "Onde o idioma é Português
         AND matnr = @t_vbrp-matnr. "E os números de materiais são os mesmos.

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

*Para cada Pagador (quebra) encontrado na tabela VBRK o relatório deve exibir
*seus Documentos de faturamento e itens do documento de faturamento.
*No final de cada Pagador também deverá ser apresentada a
*soma dos campos Quantidade faturada efetivamente, Peso líquido, Peso bruto, Valor
*líquido do item de faturamento em moeda do documento. Deverá ser exibido um
*contador com a quantidade de Documento de Faturamento para um mesmo pagador e
*no final um contador com a quantidade de registros encontrados.
*Imprimir os campos: Pagador, Documento de Faturamento, Data doc.faturamento
*p/índice de docs.faturamto, Nome 1, Local, Região, Rua e nº, Item do documento de
*faturamento, Nº do material, Texto breve de material, Quantidade faturada efetivamente,
*Peso líquido, Peso bruto e Valor líquido do item de faturamento em moeda do
*documento.

*   Agrupamento e exibição dos dados
  DATA: lv_last_kunag TYPE vbrk-kunag,
        lv_last_vbeln TYPE vbrk-vbeln,
        lv_total_fkimg TYPE vbrp-fkimg,
        lv_total_brgew TYPE vbrp-brgew,
        lv_total_ntgew TYPE vbrp-ntgew,
        lv_total_netwr TYPE vbrp-netwr,
        lv_doc_count TYPE i,
        lv_total_count TYPE i.

    LOOP AT t_vbrk INTO ls_vbrk.
      IF lv_last_kunag IS INITIAL OR lv_last_kunag <> ls_vbrk-kunag.
        IF lv_last_kunag IS NOT INITIAL.
          WRITE: / 'Total Quantidade Faturada: ', lv_total_fkimg,
                 / 'Total Peso Bruto: ', lv_total_brgew,
                 / 'Total Peso Líquido: ', lv_total_ntgew,
                 / 'Total Valor Líquido: ', lv_total_netwr,
                 / 'Número de Documentos de Faturamento: ', lv_doc_count,
                 / '============================================================'.
        ENDIF.
        CLEAR: lv_total_fkimg, lv_total_brgew, lv_total_ntgew, lv_total_netwr, lv_doc_count.
        lv_last_kunag = ls_vbrk-kunag.

        READ TABLE t_kna1 INTO ls_kna1 WITH KEY kunnr = ls_vbrk-kunag.
        WRITE: / 'Pagador: ', ls_kna1-name1,
               / 'Endereço: ', ls_kna1-stras, ', ', ls_kna1-ort01, ', ', ls_kna1-regio.
      ENDIF.

      IF lv_last_vbeln IS INITIAL OR lv_last_vbeln <> ls_vbrk-vbeln.
        lv_last_vbeln = ls_vbrk-vbeln.
        lv_doc_count = lv_doc_count + 1.
        lv_total_count = lv_total_count + 1.
        WRITE: / 'Documento de Faturamento: ', ls_vbrk-vbeln,
               / 'Data: ', ls_vbrk-fkdat.
      ENDIF.

      LOOP AT t_vbrp INTO ls_vbrp WHERE vbeln = ls_vbrk-vbeln.
        lv_total_fkimg = lv_total_fkimg + ls_vbrp-fkimg.
        lv_total_brgew = lv_total_brgew + ls_vbrp-brgew.
        lv_total_ntgew = lv_total_ntgew + ls_vbrp-ntgew.
        lv_total_netwr = lv_total_netwr + ls_vbrp-netwr.

        READ TABLE t_makt INTO ls_makt WITH KEY matnr = ls_vbrp-matnr.
        WRITE: / 'Item: ', ls_vbrp-posnr,
               / 'Quantidade: ', ls_vbrp-fkimg,
               / 'Peso Bruto: ', ls_vbrp-brgew,
               / 'Peso Líquido: ', ls_vbrp-ntgew,
               / 'Valor Líquido: ', ls_vbrp-netwr,
               / 'Material: ', ls_vbrp-matnr, ' - ', ls_makt-maktx.
      ENDLOOP.
    ENDLOOP.

*   Imprimir os totais finais
    WRITE: / 'Total Quantidade Faturada: ', lv_total_fkimg,
           / 'Total Peso Bruto: ', lv_total_brgew,
           / 'Total Peso Líquido: ', lv_total_ntgew,
           / 'Total Valor Líquido: ', lv_total_netwr,
           / 'Número de Documentos de Faturamento: ', lv_doc_count,
           / '============================================================'.

    WRITE: / 'Total de Registros Encontrados: ', lv_total_count.

ENDFORM.
