(binding_set
  (binding
    attrpath: (attrpath) @_typename (#eq? @_typename "type")
    expression: (_
                  (string_fragment) @_typevalue (#eq? @_typevalue "lua")))
  (binding
    attrpath: (attrpath) @_configname (#eq? @_configname "config")
    expression: (_
                  (string_fragment) @injection.content)
  )
  (#set! injection.language "lua")
)
