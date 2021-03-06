(in-package :paren-psos)

(defgeneric represent-rjson-slot (object slot)
  (:documentation "Should return two parenscript forms, one for
the key to the slot and the other for the value of the slot.
Returns nil if the slot should not be included.")
  (:method ((object standard-object) (slot closer-mop:standard-effective-slot-definition))
    (let ((value
	   (if (closer-mop:slot-boundp-using-class (class-of object) object slot)
	       (closer-mop:slot-value-using-class (class-of object) object slot)
	       'undefined)))
      (if (or (null value) (eql 'undefined value))
	  nil
	  (values (parenscript:symbol-to-js-string (closer-mop:slot-definition-name slot))
		  (rjson:represent value))))))

(defmethod rjson-type ((object standard-object))
  (let ((name-symbol (class-name (class-of object))))
    (format nil "~A:~A"
	    (package-name (symbol-package name-symbol))   (symbol-name name-symbol))))

(defmethod represent-rjson ((object standard-object))
  "Represents an object's slots and such in an RJSON-compatible way."
  `(create ,@(mapcan #'(lambda (slot)
			 (multiple-value-bind (key value)
			     (represent-rjson-slot object slot)
			   (if (null key) nil (list key value))))
		     (closer-mop:class-slots (class-of object)))))

;(defclass paren-net-class (standard-class)
;  ()
;  (:documentation "A class that allows its"))
;
;(defclass paren-net-object ()
;  
;
;(defclass user ()
;  ((first-name
;    :initform nil
;    :initarg :first-name
;    :accessor person-first-name
;    :transmit-p t
