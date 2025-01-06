project compileall

vsim -c work.cordic_tb

radix define fixed8 -fixed -signed -fraction 8 -base 10 -precision 5
radix define fixed13 -fixed -signed -fraction 13 -base 10 -precision 5
radix define fixed12 -fixed -signed -fraction 12 -base 10 -precision 5
radix define fixed21 -fixed -signed -fraction 21 -base 10 -precision 5

add wave -position end  sim:/cordic_tb/cordic_inst/clk
add wave -position end  sim:/cordic_tb/cordic_inst/rst
add wave -position end -radix fixed8 sim:/cordic_tb/cordic_inst/x
add wave -position end -radix fixed8 sim:/cordic_tb/cordic_inst/y
add wave -position end  sim:/cordic_tb/cordic_inst/start
add wave -position end -radix fixed8 sim:/cordic_tb/cordic_inst/rho
add wave -position end -radix fixed13 sim:/cordic_tb/cordic_inst/theta
add wave -position end  sim:/cordic_tb/cordic_inst/valid
add wave -position end  sim:/cordic_tb/cordic_inst/current_state
add wave -position end  -radix unsigned sim:/cordic_tb/cordic_inst/counter
add wave -position end -radix fixed12 sim:/cordic_tb/cordic_inst/x_t
add wave -position end -radix fixed12 sim:/cordic_tb/cordic_inst/y_t
add wave -position end -radix fixed21 sim:/cordic_tb/cordic_inst/z_t

run -all

wave zoom full