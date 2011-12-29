
;;;;;;;;;;;;;;;;                  SCIMP                   ;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;  an impromptu sc server client library   ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;  (c)  ixi audio, 2010 - GPL > google it  ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;  www.ixi-audio.net - thor@ixi-audio.net  ;;;;;;;;;;;;;;;;;;;;

;;; note -> works only with Impromptu 2.5 and later :::::::::



;;;;;;;;;;;;;; STARTING THE IMPROMPTU - SC SERVER COMMUNICATION

;; first of all, start SuperCollider and evaluate the SynthDefs at the bottom of this file.
;; it will write those to a folder where the server will read them when booted. 
;; then you can do either of these
;; a) boot the localhost server of SuperCollider.app
;; b) Quit SuperCollider and run the SuperCollider Server (scsynth) in a terminal:
;;       cd to the location of your server and type
;;       ./scsynth -u 57110 


(sc:server:start-impromptu-osc) ; starts the impromptu osc server
(sc:server:address "localhost" 57110) ; defines where the sc audio server is
(print *scserver*)
(sc:server:notify 1) ; try to run this twice (server will say "/notify : already registered")
(sc:server:status)

(sys:clear-log-view)

;;;;;;;;;; CREATING SYNTHS

; the Node number is the key. Store that in a variable and control it.

; first mode
(define synth1 (next-node-id))
(sc:synth:new (now) synth1 "scimp_test" 0 0 "freq" 1111)
(sc:synth:set (now) synth1 "freq" (random 211 1888))

(sc:node:trace synth1)
(sc:group:dumpTree 0)
(sc:synth:free (now) synth1)

; second mode - the ID is returned and stored in the variable synth2
(define synth2 (sc:synth:new (now) "scimp_test" 0 0 "freq" 1111))
(sc:synth:set (now) synth2 "freq" (random 211 1888))
(sc:synth:set (now) synth2 "index" (random 211 1888))
(sc:synth:set (now) synth2 "modFreq" (random 11 188))
(sc:synth:free (now) synth2)

; third mode - a grain without a Node ID: The synth has to free itself
(sc:synth:grain (now) "marimba" "freq" (random 333 589) "amp" 1)

(sc:group:freeAll 0)

(sc:server:status)

;;;;;;;;;;;;;;;;; WORKING WITH BUFFERS

; loading sounds into buffers on the server (change path to your own sounds)
; first mode
(define mybuf (sc:synth:read "/Users/thor/Library/Application Support/SuperCollider/sounds/a11wlk01.wav" 0 0 11))
; second mode
(define mybuf2 (next-buffer-num))
(sc:synth:read mybuf2 "/Users/thor/Library/Application Support/SuperCollider/sounds/holeMONO.aif" 0 0 11))
; third mode - directly assigning the buffer to a bufnum
(sc:buffer:allocRead 11 "/Users/thor/Library/Application Support/SuperCollider/sounds/holeMONO.aif" 0 0)


(define bufsynth (sc:synth:new (now) "scimp_buf" 0 0 "bufnum" mybuf "loop" 1))
(sc:node:set (now) bufsynth "rate" (+ (random) 0.5))
(sc:node:set (now) bufsynth "rate" 1)
(sc:synth:free (now) bufsynth)

(sc:synth:grain (now) "scimp_buf" "bufnum" mybuf "rate" 1.2 "loop" 0)



;;;;;;;;;;;;;;;;;;; WORKING WITH NODES

;; example using group
(define synth3 (next-node-id))
(sc:synth:new (now) synth3 "scimp_buf" 0 0 "bufnum" mybuf "loop" 1)
(define delay (next-node-id))
(sc:synth:new (now) delay "scimp_delay" 0 0 "in" 10 "out" 0)
(sc:node:set (now) synth3 "out" 10)
(sc:node:after (now) delay synth3)
(sc:node:set (now) synth3 "out" 0)
(sc:synth:free (now) synth3)

; running on outbus 10 - where the delay above is located
(sc:synth:grain (now) "marimba" "freq" (random 222 999) "amp" 2 "out" 10)


(define synth2 (next-node-id))
(sc:synth:new (now) synth2 "scimp_buf" 0 0 "bufnum" mybuf2 "loop" 1)
(sc:node:set (now) synth2 "out" 10)
(sc:node:set (now) synth2 "out" 0)

(sc:group:freeAll 0)
(sc:server:status)


; setn example 
; create a Group on Node 1 under Group 0
(define group 1)
(sc:group:new group 0 0)
;; setting sequence of control values (freq1, freq2, etc. or noise1, noise2, noise3, etc.) 
(define setnsynth (sc:synth:new (now) "scimp_nset" 0 group "freq" (random 333 999)))
(sc:node:setn (now) setnsynth '("freq1" 3 533 222 833 "amp1" 3 0.3 0.6 0.2))
(sc:synth:free (now) setnsynth)



;;;;;;;;;;;;;;;;;;; WORKING WITH GROUPS


(define group 1)
(sc:group:new group 0 0)

(define synth1 (sc:synth:new (now) "scimp_test" 0 group "freq" 1111))
(sc:synth:set (now) synth1 "freq" (random 211 1888))

(define synth2 (sc:synth:new (now) "scimp_test" 0 0 "freq" 1111))
(sc:synth:set (now) synth2 "freq" (random 211 1888))

(sc:group:freeAll group) ; group 1
(sc:group:freeAll 0) ; group 1 is in root group 0, so running this will free both synths



(define group2 2)
(sc:group:new group2 0 0)

; here we create 3 synths on the same group
(define synth1 (sc:synth:new (now) "scimp_test" 0 group2 "freq" (random 333 999)))
(sc:synth:set (now) synth1 "index" (random 211 1888))
(sc:synth:set (now) synth1 "modFreq" (random 11 1888))

(define synth2 (sc:synth:new (now) "scimp_test" 0 group2 "freq" (random 333 999)))
(sc:synth:set (now) synth2 "index" (random 211 888))
(sc:synth:set (now) synth2 "modFreq" (random 11 888))

(define synth3 (sc:synth:new (now) "scimp_test" 0 group2 "freq" (random 333 999)))
(sc:synth:set (now) synth3 "index" (random 211 888))
(sc:synth:set (now) synth3 "modFreq" (random 11 888))

; and now we can control the arguments of all synths by passing them to the group
(sc:node:set (now) group2 "modFreq" (random 111 999))
(sc:node:set (now) group2 "index" (random 111 999))
(sc:node:set (now) group2 "freq" (random 111 999))

(sc:server:status)
(sc:group:dumpTree group2) ; prints to console
(sc:group:queryTree group2) ; returns to client

(sc:node:query synth2) ; returns to client
(sc:node:trace synth2) ; prints to console
(sc:synth:get synth2 "freq" "amp" "out") ; get the values of the synth



; controlling the parameters of the FM synths above where the "freq" parameter of the group 
; is mapped to a control output of a synth (Like an LFO)
(define controlsynthi (sc:synth:new (now) "scimp_lfo" 0 0 "ctrlbus" 999 "freq" 11))
(sc:node:map group2 "freq" 999) ; we map the frequency to the value of the control bus
(sc:synth:set (now) controlsynthi "freq" (random 1 3))
(sc:synth:set (now) controlsynthi "mul" (random 1 190))
(sc:node:set (now) controlsynthi "freq" (random 2 72) "mul" (random 22 942)) ; setting two args at once


(sc:server:dumpOSC 1)

(sc:group:freeAll group2)



;;;;;;;;;;;;;;;;;;;;; CONTROL BUSSES



;; control bus example


;; now let's try to control the frequency of one synth by another through
;; hooking the input of one oscillator to the output of another using a control bus

(define group3 3)
(sc:group:new group3 0 0)

; the synth we'll control:
(define synth1 (sc:synth:new (now) "scimp_test" 0 group3 "freq" (random 333 999)))

; the control synth (outputting kr values on a bus)
(define controlsynthi (sc:synth:new (now) "scimp_lfo" 0 group3 "ctrlbus" 999 "freq" 11))
(sc:node:map synth1 "freq" 999) ; we map the frequency to the value of the control bus
(sc:node:set (now) controlsynthi "freq" (random 2 72) "mul" (random 22 942)) ; setting two args at once

; and we can also access the FM functions of the scimp_test synth, thus getting a double FM
(sc:synth:set (now) synth1 "index" (random 211 1888))
(sc:synth:set (now) synth1 "modFreq" (random 11 1888))

(sc:group:freeAll group3)


;; another example

(define group 3)
(sc:group:new group 0 0)

(define mycontrolbus 222)
(sc:controlbus:set (now) mycontrolbus 666)
(sc:controlbus:get mycontrolbus) ; we get posted that this value is indeed on the bus

(define synthi (sc:synth:new (now) "scimp_test" 0 group "freq" 1111))
(sc:synth:set (now) synthi "freq" (random 211 1888))
(sc:node:map synthi "freq" mycontrolbus) ; we map the frequency to the value of the control bus
(sc:controlbus:set (now) mycontrolbus (random 222 888)) ; setting a new value on the bus changes the freq


;     SynthDef(\scimp_lfo, {arg ctrlbus = 2, freq=4, mul=100;
;        Out.kr(ctrlbus, SinOsc.kr(freq, 0, mul: mul, add: 200)); // note the .kr
;     }).writeDefFile;

(define controlsynthi (sc:synth:new (now) "scimp_lfo" 0 group "ctrlbus" mycontrolbus "freq" 11))
(sc:node:map synthi "freq" mycontrolbus) ; we map the frequency to the value of the control bus
(sc:synth:set (now) controlsynthi "freq" (random 1 90))
(sc:synth:set (now) controlsynthi "mul" (random 1 90))

(sc:node:set (now) controlsynthi "freq" (random 2 72) "mul" (random 22 942)) ; setting two args at once
(sc:controlbus:get mycontrolbus) ; the controlsynth is now outputting values to the bus


(sc:group:freeAll group)




;;;;;;;;;;;;;;;;;;; PLAY






(sys:clear-log-view)
(sc:synth:grain (now) "marimba" "freq" (random 333 589) "amp" 1)



(dotimes (i 12)
   (sc:synth:grain (+ (now) (* i 7500)) "marimba" "freq" (random 333 589) "amp" 1))


(dotimes (i 24)
   (sc:synth:grain (+ (now) (* i 5000)) "marimba" "freq" (ixi:mtof (+ 60 i)) "amp" 0.1))


(
(define group 2)
(sc:group:new group 0 0)
(define synth2 (sc:synth:new (now) "scimp_test" 0 group "freq" 1111)))

(dotimes (i 33)
   (sc:synth:set (+ (now) (* (+ 1 i) 5000)) synth2 "freq" (random 211 1888))
   (sc:synth:set (+ (now) (* (+ 1 i) 5500)) synth2 "index" (random 211 1888))
   (sc:synth:set (+ (now) (* (+ 1 i) 5500)) synth2 "modFreq" (random 11 188)))

(sc:group:freeAll 0)
(sc:synth:free (now) synth2)


(define foo
   (lambda (out)
      (sc:synth:grain (now) "marimba" "freq" (random 333 589) "amp" 1 "out" out)
      (callback (+ (now) (random '(2500 5000 10000 15000))) 'foo out)))
 
(foo 0)
(define foo '())




;; similar to the above but now this will be routed through a delay
(define foo
   (lambda (out)
      (sc:synth:grain (now) "marimba" "freq" (random 333 589) "amp" 1 "out" out)
      (callback (+ (now) (random '(10000 15000))) 'foo out)))

(define delayplay
   (lambda ()
      (define delay (next-node-id))
      (sc:synth:new (now) delay "scimp_delay" 0 0 "in" 10 "out" 0)
      (foo 10)))

(delayplay)
(define foo '())



(define melody '((60 1) (66 1/4) (63 1/2) (63 1/2) (66 1/4) (57 1/2)))

(define foo
   (lambda (melo)
      (let loop ((mel melo))
      (print (car mel))
      (sc:synth:grain (now) "marimba" "freq" (ixi:mtof (car (car mel))) "amp" 1)
      (callback (+ (now) (* *second* (cadar mel))) loop (if (= 1 (length mel)) melody (cdr mel))))))
 
(foo melody)

(define melody '((60 1) (60 1) (60 1/2) (62 1/2) (64 1) (64 1/2) (62 1/2) (64 1/2) (65 1/2) (67 1)(72 1/2) (72 1/2) (67 1/2) (67 1/2) (64 1/2) (64 1/2) (60 1/2) (60 1/2) (67 1/2) (65 1/2) (64 1/2) (62 1/2) (60 2)))

(define melody '())

(sc:server:dumpOSC 1)

 
;;;;;;;;;;;;;;;;;; SC SYNTHDEFS

;; open SuperCollider, paste in the below and evaluate (SHIFT+RETURN)
		
SynthDef(\scimp_buf, { arg out = 0, bufnum, rate=1, loop=0;
	Out.ar( out,
		PlayBuf.ar(1, bufnum, rate, loop:loop)!2
	)
}).writeDefFile;

SynthDef(\marimba, {arg out=0, amp=0.3, t_trig=1, sustain=0.5, gate=1, freq=100, rq=0.006;
	var env, signal;
	var rho, theta, b1, b2;
	env = EnvGen.kr(Env.perc, gate, doneAction:2);
	b1 = 1.987 * 0.9889999999 * cos(0.09);
	b2 = 0.998057.neg;
	signal = SOS.ar(K2A.ar(t_trig), 0.3, 0.0, 0.0, b1, b2);
	signal = RHPF.ar(signal*0.8, freq, rq) + DelayC.ar(RHPF.ar(signal*0.9, freq*0.99999, rq*0.999), 0.02, 0.01223);
	signal = Decay2.ar(signal, 0.4, 0.3, signal);
	Out.ar(out, (signal*env)*(amp*0.65)!2);
}).writeDefFile;

SynthDef(\scimp_delay, { arg in=0, out = 0;
	var signal;
	signal = In.ar(in, 2);
	signal = signal + AllpassC.ar(signal, 3, 0.5, 2 ); 
    Out.ar( out, signal)
}).writeDefFile;

SynthDef(\scimp_test, {arg freq=440, modFreq=1, index=1, out=0, pan=0, amp=0.5;
	var signal;
	signal = SinOsc.ar(freq + SinOsc.ar(modFreq, 0, index), (2*pi).rand, amp);
	Out.ar(out, Pan2.ar(signal, pan));
}).writeDefFile;

SynthDef(\scimp_nset, { arg freq1 = 440, freq2 = 440, freq3 = 440, amp1 = 0.05, amp2 = 0.05, amp3 = 0.05; 
	Out.ar(0, Mix(SinOsc.ar([freq1, freq2, freq3], 0, [amp1, amp2, amp3])));
}).writeDefFile;

SynthDef(\scimp_lfo, {arg ctrlbus = 2, freq=4, mul=100;
        Out.kr(ctrlbus, SinOsc.kr(freq, 0, mul: mul, add: 200)); // note the .kr
}).writeDefFile;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


