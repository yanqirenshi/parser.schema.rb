#|
  This file is a part of parser.schema.rb project.
|#

(defsystem "parser.schema.rb"
  :version "0.1.0"
  :author ""
  :license ""
  :depends-on ()
  :components ((:module "src"
                :components
                ((:file "parser.schema.rb"))))
  :description ""
  :long-description
  #.(read-file-string
     (subpathname *load-pathname* "README.markdown"))
  :in-order-to ((test-op (test-op "parser.schema.rb-test"))))
