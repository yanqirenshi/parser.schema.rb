(defpackage parser.schema.rb
  (:use #:cl)
  (:import-from :cl-lex
                #:define-string-lexer)
  (:import-from :yacc
                #:define-parser))
(in-package :parser.schema.rb)

(defun file2string (pathname)
  (with-open-file (s pathname)
    (do ((line (read-line s) (read-line s nil 'eof))
         (out ""))
        ((eq line 'eof) out)
      (let* ((trimed_line (string-trim '(#\Space #\Tab #\Newline) line))
             (after-margin (if (= 0 (length trimed_line)) "" " ")))
        (unless (cl-ppcre:scan "^#.*$" trimed_line)
          (setf out (concatenate 'string out trimed_line after-margin)))))))

(define-string-lexer lexer_schema.rb
  ("ActiveRecord::Schema\.define"                   (return (values :def-class        $@)))
  ("enable_extension"                               (return (values :enable_extension :enable_extension)))
  ("do"                                             (return (values :do               $@)))
  ("end"                                            (return (values :end              $@)))
  ("add-index"                                      (return (values :add-index        $@)))
  ("add_foreign_key"                                (return (values :add-foreign-key  $@)))
  ("create_table"                                   (return (values :create-table     $@)))
  ("\\|t\\|"                                        (return (values :args             $@)))
  ("t\\.\\S+"                                       (return (values :column-type      $@)))
  ("\\("                                            (return (values '|(|              '|(|)))
  ("\\)"                                            (return (values '|)|              '|)|)))
  ("{"                                              (return (values '|{|              '|{|)))
  ("}"                                              (return (values '|}|              '|}|)))
  ("\\["                                            (return (values '|[|              '|[|)))
  ("\\]"                                            (return (values '|]|              '|]|)))
  ("\\S+:"                                          (return (values :hash-key         :hash-key)))
  ("true"                                           (return (values :true             :true)))
  ("false"                                          (return (values :false            :false)))
  ("null"                                           (return (values :null             :null)))
  ("\"([^\\\"]|\\.)*?\""                            (return (values :string           (string-trim "\"" $@))))
  ("-?0|[1-9][0-9]*(\\.[0-9]*)?([e|E][+-]?[0-9]+)?" (return (values :number           (read-from-string $@))))
  (":\\S+"                                          (return (values :ruby-symbol      :ruby-symbol)))
  (","                                              (return (values '|,|              '|,|))))

(defun parse-all (func)
  (multiple-value-bind (a b)
      (funcall func)
    (when a
      (format t "~a, ~a~%" a b)
      (parse-all func))))

;; (define-parser lexer_schema.rb
;;   (:start-symbol json)
;;   (:terminals ({ } [ ] |:| |,| |'| string number true false null))
;;   (json object
;;         array
;;         string
;;         number
;;         true
;;         false
;;         null)
;;   (array ([ ]
;;             #'(lambda (_lp _rp)
;;                 (declare (ignore _lp _rp))
;;                 (list :array)))
;;          ([ sequence ]
;;             #'(lambda (_lp sequence _rp)
;;                 (declare (ignore _lp _rp))
;;                 sequence)))
;;   (sequence json
;;             (json |,| sequence
;;                   #'(lambda (json _c sequence)
;;                       (declare (ignore _c))
;;                       (if (listp sequence)
;;                           (cons json sequence)
;;                           (list json sequence)))))
;;   (object ({ }
;;              #'(lambda (_lp _rp)
;;                  (declare (ignore _lp _rp))
;;                  (list :obj)))
;;           ({ members }
;;              #'(lambda (_lp members _rp)
;;                  (declare (ignore _lp _rp))
;;                  (cons :obj members))))
;;   (member (string |:| json
;;                   #'(lambda (string _c json)
;;                       (declare (ignore _c))
;;                       (cons string json))))
;;   (members member
;;            (member |,| members
;;                    #'(lambda (member _c members)
;;                        (declare (ignore _c))
;;                        (if (listp (car members))
;;                            (cons member members)
;;                            (list member members))))))
