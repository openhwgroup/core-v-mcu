# required argument: path to bitstream file
open_hw_manager
connect_hw_server
set targets [get_hw_targets]
foreach x $targets {
    puts "working on ";; puts $x
    if {[catch {open_hw_target [lindex $x 0]} errorstring]} {close_hw_target} else {
        if {[catch get_hw_devices errorstring]} {puts "goodbye"} else {
            puts "hello"
            if {[catch {set device [get_hw_devices -quiet -of_objects [current_hw_target]]} errorstring]} {puts "caught"} else {
                puts $device
                if [string equal $device [lindex $argv 1]] {
                    set_property PROGRAM.FILE [lindex $argv 0] $device
                    program_hw_devices $device
                    break
                }
            }
        }
        close_hw_target
    }
}
disconnect_hw_server
close_hw_manager
exit
