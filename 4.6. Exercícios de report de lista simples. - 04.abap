*&---------------------------------------------------------------------*
*& Report ZREPORT_4
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zreport_4.

TABLES: t001w, "Tabela Transparente - Centros/Filiais
        marc,  "Tabela Transparente - Dados de Centro para Material
        makt.  "Tabela Transparente - Textos Breves de Material

"-----------------------------------------------------------------------------------------"
"-----------------------------------------------------------------------------------------"
"-----------------------------------------------------------------------------------------"
"Declaração de Variáveis, Estruturas e Tabelas

TYPES: BEGIN OF ty_t001w, "Estrutura da Tabela Transparente - Centros/Filiais
  werks TYPE t001w-werks, "Centro
  name1 TYPE t001w-name1, "Nome
  land1 TYPE t001w-land1, "País
  regio TYPE t001w-regio, "Região
END OF ty_t001w.

DATA: t_t001w TYPE TABLE OF ty_t001w WITH HEADER LINE, "Tabela Interna da Estrutura Centros/Filiais
      ls_t001w TYPE ty_t001w.                          "Estrutura  da Tabela Interna - Centros/Filiais

TYPES: BEGIN OF ty_marc, "Estrutura da Tabela Transparente - Dados de Centro para Material
  matnr TYPE marc-matnr, "Nº do material
  werks TYPE marc-werks, "Centro
END OF ty_marc.

DATA: t_marc TYPE TABLE OF ty_marc, "Tabela Interna da Estrutura - Dados de Centro para Material
      ls_marc TYPE ty_marc.         "Estrutura da Tabela Interna - Dados de Centro para Material

TYPES: BEGIN OF ty_makt, "Estrutura da Tabela Transparente - Textos Breves de Material
  matnr TYPE makt-matnr, "Nº do material
  maktx TYPE makt-maktx, "Denominação
END OF ty_makt.

DATA: t_makt TYPE TABLE OF ty_makt, "Tabela Interna da Estrutura - Textos Breves de Material
      ls_makt TYPE ty_makt.         "Estrutura da Tabela Interna - Textos Breves de Material

TYPES: BEGIN OF ty_output, "Estrutura da Tabela de Saída
  werks TYPE t001w-werks, "Centro
  name1 TYPE t001w-name1, "Nome
  land1 TYPE t001w-land1, "País
  regio TYPE t001w-regio, "Região
  matnr TYPE marc-matnr,  "Número do Material
  maktx TYPE makt-maktx,  "Denominação
END OF ty_output.

DATA: t_output TYPE TABLE OF ty_output, "Tabela Interna da Tabela de Saída
      ls_output TYPE ty_output.         "Estrutura da Tabela Interna de Saída

DATA: lv_last_werks TYPE t001w-werks,
      lv_count TYPE i.

lv_last_werks = ''.
lv_count = 0.

"-----------------------------------------------------------------------------------------"
"-----------------------------------------------------------------------------------------"
"-----------------------------------------------------------------------------------------"

"---------------
"Tela de Seleção
"---------------

*4 - Elaborar um programa ABAP onde deverá ser criada uma tela de seleção com
*o campo Centro como seleção múltipla e o campo Chave do calendário de fábrica como
*seleção única com o valor default ‘BR’. Os tipos dos campos podem ser encontrados na
*tabela T001W.

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_werks FOR t001w-werks DEFAULT 'BR00'.
  PARAMETERS:     p_fabcal TYPE t001w-fabkl DEFAULT 'BR'. "Seleção Única
SELECTION-SCREEN END OF BLOCK a1.
SELECTION-SCREEN SKIP 1.

"Processamento de sub rotinas
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

*Selecionar na tabela T001W todos os Centros que estiverem de acordo com o
*campo Centro da tela de seleção e que também estejam de acordo com o campo Chave
*do calendário de fábrica da tela de seleção, retornando os campos Centro, Nome 1, País
*e Região.

  SELECT werks, "Centro
       name1, "Nome
       land1, "País
       regio  "Região
  FROM t001w  "Da Tabela Transparente - Centros/Filiais
  INTO CORRESPONDING FIELDS OF TABLE @t_t001w "Nos campos correspondentes da Tabela Interna - Centros/Filiais
  WHERE werks IN @s_werks "Onde Centro é igual ao Parâmetro Centro
  AND fabkl = @p_fabcal. "Onde Chave do calendário de fábrica é igual ao Parâmetro Chave do calendário de fábrica

*Para cada Centro encontrado na tabela T001W, selecionar na tabela MARC os
*materiais que foram ampliados para este centro onde o campo Centro relaciona as duas
*tabelas, retornando os campos Nº do material e Centro.

SELECT matnr, "Nº do material
       werks  "Centro
       FROM marc "Da Tabela Transparente - Dados de Centro para Material
       INTO CORRESPONDING FIELDS OF TABLE @t_marc "Nos campos correspondentes da Tabela Interna - Dados de Centro para Material
       FOR ALL ENTRIES IN @t_t001w "Relacionando os campos com a Tabela Interna - Dados de Centro para Material
       WHERE werks = @t_t001w-werks. "Onde os campos Centro são iguais

*Para cada Nº do material encontrado na tabela MARC, selecionar na tabela MAKT
*sua Denominação desde que estejam no Idioma ‘PT’.
*O campo Nº do material relaciona as duas tabelas, retornando os campos Nº do
*material e Denominação.

SELECT matnr, "Nº do material
       maktx  "Denominação
  FROM makt   "Da Tabela Transparente - Textos Breves de Material
  INTO CORRESPONDING FIELDS OF TABLE @t_makt "Nos campos correspondentes da Tabela Interna - Textos Breves de Material
  FOR ALL ENTRIES IN @t_marc "Relacionado com a Tabela Interna - Dados de Centro para Material
  WHERE matnr = @t_marc-matnr. "Onde o Nº do material é igual.

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

  LOOP AT t_t001w INTO ls_t001w.
    "Limpa a estrutura apenas uma vez por iteração do loop externo
    CLEAR: ls_output.
    ls_output-werks = ls_t001w-werks.
    ls_output-name1 = ls_t001w-name1.
    ls_output-land1 = ls_t001w-land1.
    ls_output-regio = ls_t001w-regio.

    "Encontrar materiais ampliados para este centro
    LOOP AT t_marc INTO ls_marc WHERE werks = ls_t001w-werks.
      " Verifica se há uma entrada correspondente na tabela makt
      READ TABLE t_makt INTO ls_makt WITH KEY matnr = ls_marc-matnr BINARY SEARCH.
        IF sy-subrc = 0.
          "Preencher os campos restantes
          ls_output-matnr = ls_makt-matnr.
          ls_output-maktx = ls_makt-maktx.
          "Adicionar entrada à tabela de saída
          APPEND ls_output TO t_output.
      ENDIF.
    ENDLOOP.
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

*O relatório deverá imprimir os dados de cada centro bem como todos os materiais
*encontrados para cada centro sua denominação.
*Ao final da impressão dos materiais deverá ser impressa no relatório a quantidade
*de materiais encontrados para cada um dos centros selecionados.
*Imprimir os campos Centro, Nome 1, País, Região, Nº do material e Denominação.
*Exemplo de Layout:

  SORT t_output BY werks.

" Percorrer a tabela de saída e imprimir os dados
  LOOP AT t_output INTO ls_output.
    IF lv_last_werks <> ls_output-werks.
      IF lv_last_werks <> ''.
        " Imprimir o total de materiais para o centro anterior
        WRITE: / 'Total de materiais para o centro', lv_last_werks, '=', lv_count.
        WRITE: / '-----------------------------------------------'.
        lv_count = 0.
      ENDIF.
      WRITE: / '-----------------------------------------------'.
      WRITE: / 'Centro:', ls_output-werks.
      lv_last_werks = ls_output-werks.
    ENDIF.

    " Imprimir os dados do material
    WRITE: / '-----------------------------------------------',
           / 'Nome:', ls_output-name1,
           / 'País:', ls_output-land1,
           / 'Região:', ls_output-regio.
    WRITE: / 'Número do Material:', ls_output-matnr,
           / 'Denominação:', ls_output-maktx.
    WRITE: / '-----------------------------------------------'.
    lv_count = lv_count + 1.
  ENDLOOP.

  " Imprimir o total de materiais para o último centro
  IF lv_last_werks <> ''.
    WRITE: / 'Total de materiais para o centro', lv_last_werks, '=', lv_count.
    WRITE: / '-----------------------------------------------'.
  ENDIF.

ENDFORM.
