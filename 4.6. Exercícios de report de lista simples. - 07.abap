*&---------------------------------------------------------------------*
*& Report ZREPORT_7
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zreport_7.

*Elaborar um programa ABAP onde deverá ser criada uma tela de seleção com
*o campo Fornecimento como seleção múltipla e Itinerário como seleção múltipla. Seus
*tipos se encontram na tabela LIKP.

TABLES: likp,  "Tabela Transparente - Fornecimento: Dados de Cabeçalho
        lips,  "Tabela Transparente - Documento SD: Fornecimento: Dados de Item
        tvrot. "Itinerários: Textos

"------------------
"Tela de Seleção
"------------------
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS s_autlf FOR likp-autlf. "Campo de Múltipla Escolha - Fornecimento
  SELECT-OPTIONS s_route FOR likp-route. "Campo de Múltipla Escolha - Itinerário
SELECTION-SCREEN END OF BLOCK a1.
SELECTION-SCREEN SKIP 1.

"-----------------------------------------------------------------------------------------------
"-----------------------------------------------------------------------------------------------
"-----------------------------------------------------------------------------------------------
"Variáveis, Estruturas e Tabelas

TYPES: BEGIN OF ty_likp, "Estrutura - Fornecimento: Dados de Cabeçalho
  vbeln TYPE likp-vbeln, "Fornecimento
  erdat TYPE likp-erdat, "Data de Criação
  route TYPE likp-route, "Itinerário
END OF ty_likp.

DATA: t_likp  TYPE TABLE OF ty_likp, "Tabela Interna - Estrutura - Fornecimento: Dados de Cabeçalho
      ls_likp TYPE ty_likp.          "Estrutura - Estrutura - Fornecimento: Dados de Cabeçalho

TYPES: BEGIN OF ty_lips, "Estrutura - Documento SD: Fornecimento: Dados de Item
  vbeln TYPE lips-vbeln, "Entrega/Fornecimento
  posnr TYPE lips-posnr, "Item de Remessa
  matnr TYPE lips-matnr, "Nº do Material
  werks TYPE lips-werks, "Centro
  lfimg TYPE lips-lfimg, "Quantidade Fornecida de Fato em UMV
  ntgew TYPE lips-ntgew, "Peso Líquido
END OF ty_lips.

DATA: t_lips  TYPE TABLE OF ty_lips, "Tabela Interna - Documento SD: Fornecimento: Dados de Item
      ls_lips TYPE ty_lips.          "Estrutura - Documento SD: Fornecimento: Dados de Item

TYPES: BEGIN OF ty_tvrot, "Estrutura - Itinerários: Textos
  route TYPE tvrot-route, "Itinerário
  bezei TYPE tvrot-bezei, "Denominação do Itinerário
END OF ty_tvrot.

DATA: t_tvrot  TYPE TABLE OF ty_tvrot, "Tabela Interna - Itinerários: Textos
      ls_tvrot TYPE ty_tvrot.          "Estrutura - Itinerários: Textos

"Variáveis para verificar últimos registros e totais.
DATA: lv_last_route TYPE tvrot-route,
      lv_sum_lfimg TYPE lips-lfimg,
      lv_sum_ntgew TYPE lips-ntgew,
      lv_count TYPE i,
      lv_total_count TYPE i,
      lv_first_iteration TYPE abap_bool.

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
FORM get_data .

*  Selecionar na tabela LIKP todos os Fornecimentos criados pelo usuário
*  ‘MMUELLER’ (Nome do responsável que adicionou o objeto), que sejam do Local de
*  expedição/local de recebimento de mercadoria = ‘1200’, Organização de vendas = ‘1000’
*  e que tenham Itinerários definidos (Itinerário <> branco), onde o campo Fornecimento
*  seja filtrado pelo campo Fornecimento da tela de seleção e o campo Itinerário seja
*  filtrado pelo campo Itinerário da tela de seleção, retornando os campos Fornecimento,
*  Data de criação do registro e Itinerário.

  SELECT vbeln, "Selecione Fornecimento
         erdat, "Data de Criação
         route  "Itinerário
         FROM likp "Da Tabela Transparente - Fornecimento: Dados de Cabeçalho
         INTO CORRESPONDING FIELDS OF TABLE @t_likp "Nos campos correspondentes da Tabela Interna - Estrutura - Fornecimento: Dados de Cabeçalho
         WHERE ernam = 'S4H_SD' "Onde o Nome do Responsável que Adicionou o Objeto for igual a S4H_SD
         AND vstel = '1710'     "E Local de Expedição/Local de Recebimento de Mercadoria for igual a '1710'
         AND vkorg = '1710'     "E Organização de Vendas for igual a '1710'
         AND route <> ''        "E Itinerário não for vazio
         AND autlf IN @s_autlf  "E Fornecimento estiver no Campo de Múltipla Escolha - Fornecimento
         AND route IN @s_route. "E Itinerário estiver no Campo de Múltipla Escolha - Itinerário

*  Para cada registro encontrado na tabela LIKP, selecionar os Itens de
*  Fornecimento na tabela LIPS onde o campo Fornecimento relaciona as duas tabelas,
*  retornando os campos Fornecimento, Item de remessa, Nº do material, Centro,
*  Quantidade fornecida de fato em UMV e Peso líquido.

  SELECT vbeln, "Selecione o Entrega/Fornecimento
         posnr, "Item de Remessa
         matnr, "Nº do Material
         werks, "Centro
         lfimg, "Quantidade Fornecida de Fato em UMV
         ntgew  "Peso Líquido
         FROM lips "Da Tabela Transparente - Documento SD: Fornecimento: Dados de Item
         INTO CORRESPONDING FIELDS OF TABLE @t_lips "Nos campos correspondentes da Tabela Interna - Documento SD: Fornecimento: Dados de Item
         FOR ALL ENTRIES IN @t_likp "Relacionada com a Tabela Interna - Fornecimento: Dados de Cabeçalho
         WHERE vbeln = @t_likp-vbeln. "Onde os Fornecedores são os mesmos.

*  Para cada registro encontrado na tabela LIKP, selecionar na tabela TVROT as
*  descrições dos Itinerários selecionados desde que estas existam com Código de Idioma
*  ‘PT’, onde o campo Itinerário relaciona as duas tabelas, retornando os campos: Itinerário
*  e Denominação do Itinerário.

  SELECT route, "Selecione o Itinerário
         bezei  "Denominação do Itinerário
         FROM tvrot "Da Tabela Transparente - Itinerários: Textos
         INTO CORRESPONDING FIELDS OF TABLE @t_tvrot "Nos campos correspondentes da Tabela Interna - Itinerários: Textos
         FOR ALL ENTRIES IN @t_likp "Relacionado com a Tabela Interna - Fornecimento: Dados de Cabeçalho
         WHERE route = @t_likp-route "Onde os Itinerários são os mesmos.
         AND spras = 'P'. "E onde o idioma for Português

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

*  Para cada Itinerário (quebra) encontrado na tabela LIKP, o relatório deve exibir
*  seus fornecimentos e itens de fornecimento. No final de cada itinerário deverá ser
*  apresentada uma soma dos campos Quantidade fornecida de fato em UMV e Peso
*  líquido. Deverá também ser exibido um contador com a quantidade de registros
*  encontrados.
*  Imprimir os campos: Itinerário, Denominação do Itinerário, Fornecimento, Data de
*  criação do registro, Item de remessa, Nº do material, Centro, Quantidade fornecida de
*  fato em UMV e Peso líquido.

  CLEAR: lv_sum_lfimg, lv_sum_ntgew, lv_count, lv_total_count, lv_first_iteration.

  lv_last_route = ''.

  LOOP AT t_likp INTO ls_likp.
    IF lv_last_route NE ls_likp-route.
      IF lv_last_route IS NOT INITIAL.
        WRITE: / '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~',
               / 'Total Itinerário:', lv_last_route,
               / 'Total Quantidade Fornecida:', lv_sum_lfimg,
               / 'Total Peso Líquido:', lv_sum_ntgew,
               / 'Total Fornecimentos:', lv_count,
               / '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'.
        CLEAR: lv_sum_lfimg, lv_sum_ntgew, lv_count.
      ENDIF.

      READ TABLE t_tvrot INTO ls_tvrot WITH KEY route = ls_likp-route.
      IF sy-subrc = 0.
        WRITE: / 'Itinerário:', ls_likp-route,
               / 'Denominação:', ls_tvrot-bezei.
      ELSE.
        WRITE: / 'Itinerário:', ls_likp-route,
               / 'Denominação: Não Encontrada'.
      ENDIF.

      lv_last_route = ls_likp-route.
      lv_first_iteration = abap_true.
    ENDIF.

    IF lv_first_iteration = abap_true.
      WRITE: / 'Fornecimento:', ls_likp-vbeln,
             / 'Data de Criação:', ls_likp-erdat.
      lv_first_iteration = abap_false.
    ELSE.
      WRITE: / 'Fornecimento:', ls_likp-vbeln,
             / 'Data de Criação:', ls_likp-erdat.
    ENDIF.

    LOOP AT t_lips INTO ls_lips WHERE vbeln = ls_likp-vbeln.
      WRITE: / '  Item de Remessa:', ls_lips-posnr,
             / '  Nº do Material:', ls_lips-matnr,
             / '  Centro:', ls_lips-werks,
             / '  Quantidade Fornecida:', ls_lips-lfimg,
             / '  Peso Líquido:', ls_lips-ntgew.
      lv_sum_lfimg = lv_sum_lfimg + ls_lips-lfimg.
      lv_sum_ntgew = lv_sum_ntgew + ls_lips-ntgew.
      lv_count = lv_count + 1.
      lv_total_count = lv_total_count + 1.
    ENDLOOP.

  ENDLOOP.

  IF lv_last_route IS NOT INITIAL.
    WRITE: / '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~',
           / 'Total Itinerário:', lv_last_route,
           / 'Total Quantidade Fornecida:', lv_sum_lfimg,
           / 'Total Peso Líquido:', lv_sum_ntgew,
           / 'Total Fornecimentos:', lv_count,
           / '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'.
  ENDIF.

  WRITE: / 'Total de Registros Encontrados:', lv_total_count.

ENDFORM.
