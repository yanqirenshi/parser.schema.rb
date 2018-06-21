#|
  This file is a part of parser.schema.rb project.
|#

(defsystem "parser.schema.rb-test"
  :defsystem-depends-on ("prove-asdf")
  :author ""
  :license ""
  :depends-on ("parser.schema.rb"
               "prove")
  :components ((:module "tests"
                :components
                ((:test-file "parser.schema.rb"))))
  :description "Test system for parser.schema.rb"

  :perform (test-op (op c) (symbol-call :prove-asdf :run-test-system c)))
