project compileall

vsim -c work.cordic_tb

radix define fixed16 -fixed -signed -fraction 16 -base 10 -precision 3

add wave -position end  sim:/cordic_tb/cordic_inst/clk
add wave -position end  sim:/cordic_tb/cordic_inst/rst
add wave -position end -radix fixed16 sim:/cordic_tb/cordic_inst/x
add wave -position end -radix fixed16 sim:/cordic_tb/cordic_inst/y
add wave -position end  sim:/cordic_tb/cordic_inst/start
add wave -position end -radix fixed16 sim:/cordic_tb/cordic_inst/rho
add wave -position end -radix fixed16 sim:/cordic_tb/cordic_inst/theta
add wave -position end  sim:/cordic_tb/cordic_inst/valid
add wave -position end  sim:/cordic_tb/cordic_inst/current_state
add wave -position end  sim:/cordic_tb/cordic_inst/counter
add wave -position end -radix fixed16 sim:/cordic_tb/cordic_inst/x_t
add wave -position end -radix fixed16 sim:/cordic_tb/cordic_inst/y_t
add wave -position end -radix fixed16 sim:/cordic_tb/cordic_inst/z_t

run -all

wave zoom full