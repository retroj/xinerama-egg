;; Copyright 2017 John J Foerch. All rights reserved.
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions are
;; met:
;;
;;    1. Redistributions of source code must retain the above copyright
;;       notice, this list of conditions and the following disclaimer.
;;
;;    2. Redistributions in binary form must reproduce the above copyright
;;       notice, this list of conditions and the following disclaimer in
;;       the documentation and/or other materials provided with the
;;       distribution.
;;
;; THIS SOFTWARE IS PROVIDED BY JOHN J FOERCH ''AS IS'' AND ANY EXPRESS OR
;; IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
;; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;; DISCLAIMED. IN NO EVENT SHALL JOHN J FOERCH OR CONTRIBUTORS BE LIABLE
;; FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
;; BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
;; WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
;; OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
;; ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


(module xinerama
    (xinerama-screen-info?
     xinerama-screen-info-screen-number
     xinerama-screen-info-x-org
     xinerama-screen-info-y-org
     xinerama-screen-info-width
     xinerama-screen-info-height
     xinerama-query-extension
     xinerama-query-version
     xinerama-active?
     xinerama-query-screens)

(import chicken scheme foreign foreigners)

(use (srfi 1))

(foreign-declare "#include <X11/extensions/Xinerama.h>")

(define-record-type xinerama-screen-info
  (%make-xinerama-screen-info screen-number x-org y-org width height)
  xinerama-screen-info?
  (screen-number xinerama-screen-info-screen-number)
  (x-org xinerama-screen-info-x-org)
  (y-org xinerama-screen-info-y-org)
  (width xinerama-screen-info-width)
  (height xinerama-screen-info-height))

(define (make-xinerama-screen-info . _)
  (%make-xinerama-screen-info 0 0 0 0 0))

(define (xinerama-query-extension display)
  (let-location ((event-base int 0)
                 (error-base int 0))
    (if ((foreign-lambda bool XineramaQueryExtension
                         c-pointer (c-pointer int) (c-pointer int))
         display (location event-base) (location error-base))
        (list event-base error-base)
        #f)))

(define (xinerama-query-version display)
  (let-location ((major int 0)
                 (minor int 0))
    (let ((result
           ((foreign-lambda int XineramaQueryVersion
                            c-pointer (c-pointer int) (c-pointer int))
            display (location major) (location minor))))
      (if (zero? result)
          #f
          (list major minor)))))

(define xinerama-active?
  (foreign-lambda bool XineramaIsActive c-pointer))

(define (xinerama-query-screens display)
  (let-location ((count int 0))
    (let* ((blob ((foreign-lambda c-pointer
                                  XineramaQueryScreens
                                  c-pointer (c-pointer int))
                  display (location count)))
           (result (list-tabulate count make-xinerama-screen-info)))
      ((foreign-lambda* void ((c-pointer blob) (int count) (scheme-object result))
         "XineramaScreenInfo* xsi = (XineramaScreenInfo*)blob;\n"
         "int i;\n"
         "C_word rec;\n"
         "for (i = 0; i < count; ++i) {\n"
         "    rec = C_u_i_car(result);\n"
         "    C_i_setslot(rec, C_fix(1), C_fix(xsi->screen_number));\n"
         "    C_i_setslot(rec, C_fix(2), C_fix(xsi->x_org));\n"
         "    C_i_setslot(rec, C_fix(3), C_fix(xsi->y_org));\n"
         "    C_i_setslot(rec, C_fix(4), C_fix(xsi->width));\n"
         "    C_i_setslot(rec, C_fix(5), C_fix(xsi->height));\n"
         "    result = C_u_i_cdr(result);\n"
         "    xsi += 1;\n"
         "}\n"
         "free(blob);\n")
       blob count result)
      result)))

)
