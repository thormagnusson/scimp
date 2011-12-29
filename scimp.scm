
;;;;;;;;;;;;;;;;                  SCIMP                   ;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;  an impromptu sc server client library   ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;  (c)  ixi audio, 2010 - GPL > google it  ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;  www.ixi-audio.net - thor@ixi-audio.net  ;;;;;;;;;;;;;;;;;;;;

;;; note -> works only with Impromptu 2.5 and later :::::::::


;;;;;;;;;;;;;;;;; SERVER MAINTAINANCE

(define *scserver* (cons "localhost" 57110))

(define sc:server:start-impromptu-osc
   (lambda()
      (io:osc:start-server 57180)
      (io:osc:send-from-server-socket? #t)))

(define sc:server:address
   (lambda (ip port)
      (set! *scserver* (cons ip port))))

(define sc:server:quit
   (lambda ()
      (io:osc:send (now) *scserver* "/quit")))

(define sc:server:notify
   (lambda (arg)
      (io:osc:send (now) *scserver* "/notify" arg)))

(define sc:server:status
   (lambda ()
      (io:osc:send (now) *scserver* "/status")))

(define sc:server:cmd
   (lambda (args)
      (io:osc:send (now) *scserver* "/cmd" args)))

(define sc:server:dumpOSC
   (lambda (args)
      (io:osc:send (now) *scserver* "/dumpOSC" args)))

(define sc:server:sync
   (lambda (id)
      (io:osc:send (now) *scserver* "/sync" id)))

(define sc:server:clearSched
   (lambda ()
      (io:osc:send (now) *scserver* "/clearSched")))

(define sc:server:error
   (lambda (mode)
      (io:osc:send (now) *scserver* "/error" mode)))


;;;;;;;;;;;;;; RECEIVE 

(define (io:osc:receive time address . args)
   (print 'receiving-OSC-from-SC-server)
   (cond ((string=? address "/status.reply")
          (let loop ((statit '("? : " "UGens : " "Synths : " "Groups : " "SynthDefs : " "Avg CPU : " "Peak CPU : " "Sample Rate : " "Actual Sample Rate : " )) (stats args) )
          (if (not (null? statit)) 
              (begin (print (car statit) (car stats))(loop (cdr statit) (cdr stats))))))
         ((string=? address "/done")
          (print "done : " args))
         ((string=? address "/fail")
          (print "fail : " args))
         ((string=? address "/notify")
          (print "oo" args))
         ((string=? address "/synced")
          (print "synced" args))
         ((string=? address "/done")
          (print "done " args))
         ((string=? address "/late")
          (print "command received late " args))
         ((string=? address "/n_info")
          (print " n info : " args))
         ((string=? address "/g_dumpTree.reply")
          (print " n info : " args))
         ((string=? address "/g_queryTree.reply")
          (print " queryTree : " args))
         ((string=? address "/b_info")
          (print " buffer info (bufnum frames channels sample rate) : " args))
         ((string=? address "/n_go")
          (print " node started : " args))
         ((string=? address "/n_end")
          (print " node ended : " args))
         ((string=? address "/n_off")
          (print " node turned off : " args))
         ((string=? address "/n_on")
          (print " node turned on : " args))
         ((string=? address "/n_move")
          (print " node moved : " args))
         (else (print address '-> args))))





;;;;;;;;;;;;;; SYNTH DEFINITION COMMANDS


; not working (and won't work for now, check Rohan Drape's rsc3 library)
(define sc:synthdef:receive
   (lambda (id)
      (io:osc:send (now) *scserver* "/d_recv" bytes)))

(define sc:synthdef:load
   (lambda (path)
      (io:osc:send (now) *scserver* "/d_load" path)))

(define sc:synthdef:loadDir
   (lambda (dirpath)
      (io:osc:send (now) *scserver* "/d_loadDir" dirpath)))

(define sc:synthdef:free
   (lambda (defname)
      (io:osc:send (now) *scserver* "/d_free" defname)))



;;;;;;;;;;;;;; NODE

;; incrementer for node-id

(define next-node-id
   (let ((node-id 1000))
      (lambda ()
         (set! node-id (+ node-id 1))
         node-id)))

(define sc:node:free
   (lambda (id)
      (io:osc:send (now) *scserver* "/n_free" id)))

(define sc:node:run
   (lambda (id val)
      (io:osc:send (now) *scserver* "/n_run" id val)))

(define sc:node:set ; supporting multiple args
   (lambda (time id message . val)
      (if (= (length val) 1)
      (io:osc:send time *scserver* "/n_set" id message val)
      (apply io:osc:send time *scserver* "/n_set" id message val))))

(define sc:node:setn
   (lambda (time id args)
      (apply io:osc:send time *scserver* "/n_setn" id args)))

(define sc:node:fill
   (lambda (id args)
      (apply io:osc:send (now) *scserver* "/n_fill" id args)))

(define sc:node:map
   (lambda (id controlname bus)
      (io:osc:send (now) *scserver* "/n_map" id controlname bus)))

(define sc:node:mapn
   (lambda (id args)
      (apply io:osc:send (now) *scserver* "/n_mapn" id args)))

(define sc:node:mapa
   (lambda (id controlname bus)
      (io:osc:send (now) *scserver* "/n_mapa" id controlname bus)))

(define sc:node:mapan
   (lambda (id args)
      (apply io:osc:send (now) *scserver* "/n_mapan" id args)))

(define sc:node:before
   (lambda (id tgt)
      (io:osc:send (now) *scserver* "/n_before" id tgt)))

(define sc:node:after
   (lambda (time id tgt)
      (io:osc:send time *scserver* "/n_after" id tgt)))

(define sc:node:query
   (lambda (id)
      (io:osc:send (now) *scserver* "/n_query" id)))

(define sc:node:trace
   (lambda (id)
      (io:osc:send (now) *scserver* "/n_trace" id)))

(define sc:node:order
   (lambda (addact tgt nodeids)
      (apply io:osc:send (now) *scserver* "/n_order" addact tgt nodeids)))

(define sc:node:free
   (lambda (id)
      (io:osc:send (now) *scserver* "/n_free" id)))


;;;;;;;;;;;;;; SYNTH


;;;;;;; polymorphic synth

(define sc:synth:new
   (lambda (time id synthdef addAction . (tgt . args))      
      (if (string? id)
         (let ((node-id 0))
         (set! node-id (next-node-id))
            (apply io:osc:send time *scserver* "/s_new" id node-id synthdef addAction tgt args)
         node-id)       
            (apply io:osc:send time *scserver* "/s_new" synthdef id addAction tgt args)
      )))

(define sc:synth:grain
   (lambda (time synthdef . args)
      (apply io:osc:send time *scserver* "/s_new" synthdef -1 0 0 args)
      ))

; same as sc:node:set
(define (sc:synth:set time id message . val)
      (apply io:osc:send time *scserver* "/n_set" id message val))

; same as sc:node:free
(define sc:synth:free
   (lambda (time id)
      (io:osc:send time *scserver* "/n_free" id)))

(define sc:synth:get
   (lambda (id . args)
      (apply io:osc:send (now) *scserver* "/s_get" id args)))

(define sc:synth:getn
   (lambda (id message controlindex num)
      (apply io:osc:send (now) *scserver* "/s_getn" id controlindex num)))

(define sc:synth:nold
   (lambda (id)
      (io:osc:send (now) *scserver* "/s_nold" id )))



;;;;;;;;;;;;;;;;;;;;;;;;;;  GROUP

(define sc:group:new
   (lambda (id addaction tgt)
      (io:osc:send (now) *scserver* "/g_new" id addaction tgt)))

(define sc:group:head
   (lambda (group-id node-id)
      (io:osc:send (now) *scserver* "/g_head" group-id node-id)))

(define sc:group:tail
   (lambda (id action tgt)
      (io:osc:send (now) *scserver* "/g_tail" group-id node-id)))

(define sc:group:freeAll
   (lambda (id)
      (io:osc:send (now) *scserver* "/g_freeAll" id)))

(define sc:group:deepFree
   (lambda (id)
      (io:osc:send (now) *scserver* "/g_deepFree" id)))

(define sc:group:dumpTree
   (lambda (id)
      (io:osc:send (now) *scserver* "/g_dumpTree" id)))

(define sc:group:queryTree
   (lambda (id)
      (io:osc:send (now) *scserver* "/g_queryTree" id)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BUFFER


(define next-buffer-num
   (let ((buffer-num 1000))
      (lambda ()
         (set! buffer-num (+ buffer-num 1))
         buffer-num)))

(define sc:buffer:alloc
   (lambda (num frames channels)
      (io:osc:send (now) *scserver* "/b_alloc" num frames channels)))

(define sc:buffer:allocRead
   (lambda (num path startframe frames)
      (io:osc:send (now) *scserver* "/b_allocRead" num path startframe frames)))

(define sc:buffer:read
   (lambda (num path startframe frames)
      (io:osc:send (now) *scserver* "/b_allocRead" num path startframe frames)))

(define sc:synth:read
   (lambda (num path startframe . frames)      
      (if (string? num)
         (let ((buffer-num 0))
         (set! buffer-num (next-buffer-num))
            (apply io:osc:send (now) *scserver* "/b_allocRead" buffer-num num path startframe frames)
         buffer-num)       
            (apply io:osc:send (now) *scserver* "/b_allocRead" num path startframe frames))))


(define sc:buffer:allocReadChannel
   (lambda (num path start frames chnl)
      (io:osc:send (now) *scserver* "/b_allocReadChannel" num path start frames chnl)))

(define sc:buffer:b-read
   (lambda (num path startframe frames bufstartframe open)
      (io:osc:send (now) *scserver* "/b_read" num path startframe frames bufstartframe open)))

(define sc:buffer:b-readChannel
   (lambda (num path startframe frames bufstartframe open)
      (io:osc:send (now) *scserver* "/b_readChannel" num path startframe frames bufstartframe open)))

(define sc:buffer:write
   (lambda (num path headerformat sampleformat numframes startframe open)
      (io:osc:send (now) *scserver* "/b_write" num path headerformat sampleformat numframes startframe open)))

(define sc:buffer:free
   (lambda (num)
      (io:osc:send (now) *scserver* "/b_free" num)))

(define sc:buffer:zero
   (lambda (num)
      (io:osc:send (now) *scserver* "/b_zero" num)))

(define sc:buffer:set
   (lambda (num index val)
      (io:osc:send (now) *scserver* "/b_set" num index val)))

(define sc:buffer:setn
   (lambda (num index vals)
      (io:osc:send (now) *scserver* "/b_setn" num index vals)))

(define sc:buffer:fill
   (lambda (num index samples val)
      (io:osc:send (now) *scserver* "/b_fill" num index samples val)))

(define sc:buffer:close
   (lambda (num)
      (io:osc:send (now) *scserver* "/b_close" num)))


; need to create the responder:
(define sc:buffer:query
   (lambda (num)
      (io:osc:send (now) *scserver* "/b_query" num)))

; need to create the responder:
(define sc:buffer:get
   (lambda (num index)
      (io:osc:send (now) *scserver* "/b_get" num index)))

; need to create the responder:
(define sc:buffer:getn
   (lambda (num index numsamples)
      (io:osc:send (now) *scserver* "/b_getn" num index numsamples)))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CONTROL BUS

(define sc:controlbus:set
   (lambda (time index val)
      (io:osc:send time *scserver* "/c_set" index val)))

(define sc:controlbus:setn
   (lambda (time index args)
      (apply io:osc:send time *scserver* "/c_setn" index args)))

(define sc:controlbus:fill
   (lambda (index args)
      (apply io:osc:send (now) *scserver* "/c_fill" index args)))

(define sc:controlbus:get
   (lambda (index)
      (io:osc:send (now) *scserver* "/c_get" index)))

(define sc:controlbus:getn
   (lambda (index args)
      (apply io:osc:send (now) *scserver* "/c_getn" index args)))


