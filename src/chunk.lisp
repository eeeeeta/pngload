(in-package :pngload)

(defvar *chunk* nil)

(defclass chunk ()
  ((length :reader chunk-length)
   (type :reader chunk-type)
   (data :reader chunk-data)
   (crc :reader chunk-crc)))

(defmethod print-object ((object chunk) stream)
  (print-unreadable-object (object stream :type t)
    (format stream "~S" (chunk-name object))))

(defun chunk-name (chunk)
  (case (chunk-type chunk)
    (#x49444154 :idat)
    (#x49484452 :ihdr)
    (#x49454e44 :iend)
    (#x504c5445 :plte)
    (#x6348524d :chrm)
    (#x67414d41 :gama)
    (#x69434350 :iccp)
    (#x73424954 :sbit)
    (#x73524742 :srgb)
    (#x624b4744 :bkgd)
    (#x68495354 :hist)
    (#x74524e53 :trns)
    (#x70485973 :phys)
    (#x73504c54 :splt)
    (#x74494d45 :time)
    (#x69545874 :itxt)
    (#x74455874 :text)
    (#x7a545874 :ztxt)
    (otherwise :unknown)))

(defun chunk-size ()
  (chunk-length *chunk*))

#++
(defun chunk-offset ()
  (cerror "continue" "chunk-offset")
  (- (chunk-length *chunk*) (parsley:buffer-position)))

(defun parse-chunk ()
  (let ((*chunk* (make-instance 'chunk)))
    (with-source (*png-source* :buffer nil)
      (with-slots (length type data crc) *chunk*
        (setf length (ub32be)
              type (ub32be)
              data (nest (parse-chunk-data (chunk-name *chunk*)))
              crc (ub32be))))
    *chunk*))
