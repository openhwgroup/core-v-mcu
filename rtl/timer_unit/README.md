# Timer Unit provide 2 32-bit timers or a single 64-bit timer.
  in 32-bit mode each timer operate independently with interrupt on compare
  continous or single shot operation with optional pre-scaler.

  In 64-bit mode the two counters are concatenated.
  added MTIME mode to generate an interrupt whenever count value is equal to
  or greate than the compare value.

Added stoptimer input to disable counting when active.  
  

