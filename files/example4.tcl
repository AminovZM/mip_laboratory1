# создание объекта Simulator
set ns [new Simulator]
$ns rtproto DV
set nf [open out.nam w]
# все результаты моделирования будут записаны в переменную nf
$ns namtrace-all $nf
set f [open out.tr w]
# все регистрируемые события будут записаны в переменную f
$ns trace-all $f
proc finish {} {
	global ns f nf
	# описание глобальных переменных
	$ns flush-trace
	# прекращение трассировки
	close $f
	# закрытие файлов трассировки
	close $nf
	# закрытие файлов трассировки nam
	# запуск nam в фоновом режиме
	exec nam out.nam &
	exit 0
}

set N 6
for {set i 0} {$i < $N} {incr i} {
	set n($i) [$ns node]
}

for {set i 0} {$i < $N-2} {incr i} {
	$ns duplex-link $n($i) $n([expr ($i+1)%$N]) 1Mb 10ms DropTail
}

$ns duplex-link $n(1) $n(5) 2Mb 10ms DropTail
$ns duplex-link $n(4) $n(0) 2Mb 10ms DropTail

set udp0 [new Agent/UDP]
$ns attach-agent $n(0) $udp0
set cbr0 [new Agent/CBR]
$ns attach-agent $n(0) $cbr0
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005

set null0 [new Agent/Null]
$ns attach-agent $n(5) $null0

$ns connect $cbr0 $null0

$ns at 0.5 "$cbr0 start"
$ns rtmodel-at 1.0 down $n(0) $n(1)
$ns rtmodel-at 2.0 up $n(0) $n(1)
$ns at 4.5 "$cbr0 stop"
$ns at 5.0 "finish"
# at-событие для планировщика событий, которое запускает
# процедуру finish через 5 с после начала моделирования
$ns at 5.0 "finish"
# запуск модели
$ns run