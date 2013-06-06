target = "xilinx"
action = "synthesis"

# good parameters (not supported by HDLmake)
# change this later in ISE project
#syn_device = "xc7k325t"
#syn_grade = "-2"
#syn_package = "ffg900"

syn_device = "xc6slx45t"
syn_grade = "-3"
syn_package = "fgg484"

syn_top = "kintex7_fmc_adc_130m_4ch"
syn_project = "kintex7_fmc_adc_130m_4ch.xise"

modules = { "local" : [ "../../top/kc705/fmc130m" ] };

