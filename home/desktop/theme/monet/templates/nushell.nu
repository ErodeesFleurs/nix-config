$env.config.color_config = ($env.config.color_config | merge {
  separator: "@outline_variant@"
  leading_trailing_space_bg: "@surface_container_high@"
  header: { fg: "@primary@", attr: "b" }
  empty: "@on_surface_variant@"
  bool: "@secondary@"
  int: "@primary@"
  filesize: "@tertiary@"
  duration: "@tertiary@"
  date: "@secondary@"
  range: "@secondary@"
  float: "@primary@"
  string: "@on_surface@"
  nothing: "@on_surface_variant@"
  binary: "@secondary@"
  cell-path: "@primary@"
  row_index: { fg: "@outline@", attr: "b" }
  record: "@on_surface@"
  list: "@on_surface@"
  block: "@on_surface@"
  hints: "@outline@"
  search_result: { fg: "@on_primary_container@", bg: "@primary_container@" }
  shape_and: { fg: "@secondary@", attr: "b" }
  shape_binary: { fg: "@secondary@", attr: "b" }
  shape_block: "@primary@"
  shape_bool: "@secondary@"
  shape_closure: "@primary@"
  shape_custom: "@tertiary@"
  shape_datetime: "@secondary@"
  shape_external: "@primary@"
  shape_externalarg: "@on_surface@"
  shape_filepath: "@tertiary@"
  shape_flag: { fg: "@primary@", attr: "b" }
  shape_float: "@primary@"
  shape_garbage: { fg: "@on_error_container@", bg: "@error_container@", attr: "b" }
  shape_globpattern: "@tertiary@"
  shape_int: "@primary@"
  shape_internalcall: { fg: "@primary@", attr: "b" }
  shape_keyword: { fg: "@secondary@", attr: "b" }
  shape_list: "@on_surface@"
  shape_literal: "@secondary@"
  shape_match_pattern: "@tertiary@"
  shape_matching_brackets: { attr: "u" }
  shape_nothing: "@on_surface_variant@"
  shape_operator: "@secondary@"
  shape_pipe: "@outline@"
  shape_range: "@secondary@"
  shape_record: "@on_surface@"
  shape_redirection: "@secondary@"
  shape_signature: "@primary@"
  shape_string: "@on_surface@"
  shape_string_interpolation: "@tertiary@"
  shape_table: "@on_surface@"
  shape_variable: "@on_surface@"
  shape_vardecl: "@primary@"
})
