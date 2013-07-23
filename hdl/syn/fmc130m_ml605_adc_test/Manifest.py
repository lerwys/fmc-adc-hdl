target = "xilinx"
action = "synthesis"

# good parameters (not supported by HDLmake)
# change this later in ISE project
#syn_device = "xc7k325t"
#syn_grade = "-2"
#syn_package = "ffg900"

#syn_device = "xc6slx45t"
#syn_grade = "-3"
#syn_package = "fgg484"

syn_device = "xc6vlx240t"
syn_grade = "-1"
syn_package = "ff1156"

syn_top = "virtex6_fmc_adc_130m_4ch_adc_test"
syn_project = "virtex6_fmc_adc_130m_4ch_adc_test.xise"

modules = { "local" : [ "../../top/ml605/fmc130m_adc_test" ] };

